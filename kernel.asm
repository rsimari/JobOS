; =======================================================================
; 		     	      JobOS Kernel
; =======================================================================	
; This kernel runs an interactive REPL that can run and list included programs

	BITS 16
start: jmp os_main

os_main: 
	; main kernel routine
	; initialize segments 
	mov ax, 0x1000
	mov ds, ax	
	
	; set up stack
	cli 
	mov ss, ax
	mov sp, 0FFFFh
	sti 

	mov es, ax
	mov fs, ax

	; show kernel load successful and start repl
	mov si, 0
	mov si, kernel_load
	call os_clear_screen
	call os_print_string

	call os_game
	nop

	call os_launch_repl

	jmp $


os_launch_repl: 
	; passed in, nothing. 
	pusha 

	mov cl, 0 ; line 1	

.repl_loop:
	add cl, 1
	
	cmp cl, 25
	jl .new_line
	mov cl, 0
	call os_clear_screen

.new_line:
	mov dx, 0 
	mov dh, cl
	; new line, set cursor etc. 
	call cursor_new_line 

.print_jobos:

	mov si, jobos
	call os_print_string 

.single_line: 
	; commands we should support - ls - list available programs/actions, run something  

	; wait for input 
	call os_read_char

	
.check_new_line: 
	cmp dl, 13 ; dl contains read char 
	je .repl_loop ;  jump if new line

.check_back_space: 
	cmp dl, 8
	jne .continue_reading 
	
	call get_cursor_x	
	
	cmp al, 7
	jle .single_line

	mov al, dl
	push cx
	call os_write_char
	mov al, 0
	call os_write_char
	mov al, 8
	call os_write_char
	pop cx

	jmp .single_line

.continue_reading: 
	mov al, dl
 
	push cx
	call os_write_char ; prints char at the cursor position  
	pop cx

	jmp .single_line ; keep getting chars 

.end:

	jmp .repl_loop ; jump back


	popa 
	ret 

 

; ================================================================
; 			    OS CALLS 
; ================================================================


os_read_char: 
	; places resulting char in dx 
	push ax
	push cx

	mov ah, 00h
	int 16h 
	mov dl, 0
	mov dl, al
	
	pop cx
	pop ax
	ret 

os_write_char: 
	; pass char in al 

	push bx 
	push dx

	mov bh, 0 
	mov dx, 1

	mov ah, 0Eh
	int 10h 

	pop dx
	pop bx

	ret 

os_clear_screen:
	pusha

	mov dx, 0

	; move curser to top
	mov bh, 0
	mov ah, 2
	int 10h
	; end move curser

	; clear screen
	mov ah, 6
	mov al, 0
	mov bh, 7
	mov cx, 0
	mov dh, 24
	mov dl, 79
	int 10h

	popa
	ret


os_print_string: ; pass string in si
	pusha

	mov ah, 0Eh
.repeat:

	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp short .repeat

.done: 
	;call os_new_line
	popa 
	ret 







; ================================================================
; 			KERNEL SUBROUTINES
; ================================================================

get_cursor_x:
	; passes back cursor x in al 

	push bx
	push cx
	push dx

	mov ah, 03h
	int 10h

	mov al, dl 	; row column stored in dl

	pop dx
	pop cx
	pop bx
	
	ret

cursor_new_line:
	;passed in: dh contains current row number 

	push ax
	push cx

	mov ah, 02h      
	mov dl, 00h
	int 10h
	
	pop cx
	pop ax 

	ret

os_game:
	pusha

	call os_clear_screen
	nop

	mov ax, 13h ; change to graphics mode
	int 10h
	mov ax, 0A000h
	mov es, ax

	call draw_jobos
	nop

	mov cl, 01h

	game_loop:
		cmp cl, 00h
		je exit_game

		jmp game_loop

	exit_game:
		mov ax, 3
		int 10h		; back to text mode

		mov ah, 0Bh
		mov bh, 00h ; change background color back to black
		mov bl, 00h
		int 10h

		popa
		;ret

put_pixel:
	; input: set ax with Y coord, set bx with X coord, dl with

	push cx
	push ax

	mov cx, 320
	mul cx

	add ax, bx
	mov di, ax
	mov dl, 9
	mov [es:di], dl

	pop ax
	pop cx

	ret

rm_pixel:
	; input: set ax with Y coord, set bx with X coord

	push cx
	push ax
	push dx

	mov cx, 320
	mul cx

	add ax, bx
	mov di, ax
	mov dl, 0
	mov [es:di], dl

	pop dx
	pop ax
	pop cx

	ret

draw_jobos:
	pusha

	mov bx, 0

	draw_horiz_loop:
		mov ax, 0
		inc bx

		call put_pixel
		nop

		mov ax, 403
		call put_pixel
		nop

		cmp bx, 320
		je draw_exit
		nop
		jmp draw_horiz_loop

	draw_exit:

	call move_ball

	popa
	ret

move_ball:
	pusha

	call draw_pongs
	nop

	mov cx, 01h
	mov dx, 00h  ; set wait time

	mov ax, 213
	mov bx, 251  ; create initial pixel
	call put_pixel

	move_right_loop:
		cmp bx, 325
		jg move_left_loop

		call rm_pixel
		inc bx
		call put_pixel

		int 15h    ; wait
		jmp move_right_loop

	move_left_loop:
		cmp bx, 231
		jl move_right_loop

		call rm_pixel
		sub bx, 1
		call put_pixel

		int 15h ; wait
		jmp move_left_loop

	move_exit:

	popa
	ret

draw_pongs:
	pusha

	mov ax, 100
	mov bx, 100
	call put_pixel

	pong_loop1: ; draw left paddle
		cmp ax, 120
		jg pong_exit1 

		inc ax
		call put_pixel

		jmp pong_loop1

	pong_exit1:
		mov bx, 200
		mov ax, 100

	pong_loop2:  ; draw right paddle
		cmp ax, 120
		jg pong_exit2

		inc ax
		call put_pixel

		jmp pong_loop2

	pong_exit2:

	popa
	ret


; ================================================================
; 		      STRING AND VARIABLES
; ================================================================

kernel_load db "Welcome to JobOS", 0
jobos db "JobOS> ",0

times 512-($-$$) db 0
