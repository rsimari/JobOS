; =======================================================================
; 		     	      JobOS Kernel
;			By John Joyce & Robert Simari
; =======================================================================	
; This kernel runs an interactive REPL that can run and list included programs

	BITS 16


os_call_vectors: 
	jmp os_main		;0000h
	jmp os_print_string 	;0003h
	jmp os_write_char	;0006h
	jmp os_read_char	;0009h
	jmp os_clear_screen	;000Ch
	jmp os_compare_strings	;000fh
	jmp os_string_token	;0012h
	jmp os_get_cursor_x	;0015h



os_main: 

	; initialize segments 
	mov ax,0	
	
	; set up stack
	cli 
	mov ss, ax
	mov sp, 0FFFFh
	sti 

	cld 

	mov ax, 2000h
	
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax


	; show kernel load successful and start repl
	mov si, 0
	mov si, kernel_load

	call os_clear_screen
	call os_print_string

	call os_run_repl

	jmp $


os_run_repl: 
 
	pusha 	
	
	mov cl, 0	; cl stores row number we are on	
	
.repl_loop:

	mov bx, input
	
	cmp cl, 24
	jl .new_line

	mov cl, -1
	call os_clear_screen

.new_line:

	add cl, 1

	mov dx, 0 
	mov dh, cl
	 
	call cursor_new_line
	

.print_prompt:

	mov si, jobos
	call os_print_string 

.read_char: 		; commands we should support - ls - list available programs/actions, run something  

	; wait for input 
	call os_read_char

	
.check_new_line: 
	cmp dl, 13 	; dl contains read char 
	je .parse_command ;  jump if new line

.check_back_space: 
	cmp dl, 8
	jne .write_char 


	call os_get_cursor_x

	cmp al, 7
	jle .read_char

	sub bx, 1

	mov al, dl

	push cx
	call os_write_char
	mov al, 0
	call os_write_char
	mov al, 8
	call os_write_char
	pop cx

	jmp .read_char

.write_char: 

	; store char
	mov [bx], byte dl 
	add bx, 1

	mov al, dl
 
	push cx
	call os_write_char 	; prints char at the cursor position  
	pop cx

	jmp .read_char 	; keep getting chars 

.parse_command:
	mov [bx], byte 0 	;

	; here we will parse the command 
	mov si, input 		; if user just enters, get command again
	cmp [si], byte 0
	je .repl_loop

	mov si, input
	mov al, ' '
	call os_string_token 	; tokenize the string to get the command 
	
	cmp di, 0
	je .compare_ls

	mov ax, di

.compare_run:

	;; SI POINTS TO BEGINNING OF FIRST TOKEN, DI TO BEGINNING OF SECOND 

	mov di, run_string 	; compare with run command string
	call os_compare_strings
	jne .compare_ls

	; otherwise, lets go
	mov si, ax
	
	jmp .run_program

.compare_ls:

	mov di, ls_string
	call os_compare_strings 
	jne .print_usage


	; if it is equal, we need to list the programs available.  
	; we will check block 6, 8, 10 for programs

	jmp .list_programs 	; 
	
.end:

	jmp .repl_loop ; jump back


	popa
	ret

.print_usage: 	; takes si as 'usage' argument 

	add cl, 1

	mov dx, 0 
	mov dh, cl
	 
	call cursor_new_line
	
	mov si, instructions
	call os_print_string

	jmp .repl_loop
	
.list_programs: 
 
	; will search sectors 6,8,10 for programs 0x0800, 0x0C00, 0x1000
.check_6:
	; check for program at 0x0800
	mov ax, word [0x0800] 
	mov si, 0x0802
	
	cmp ax, [program_id]
	jne .check_8
	call .print_and_newline

.check_8:

	; check for program at 0x0C00
	mov ax, word [0x0C00] 
	mov si, 0x0C02

	cmp ax, [program_id]
	jne .check_10
	call .print_and_newline

.check_10:
	; check for program at 0x1000
	mov ax, word [0x1000]
	mov si, 0x1002
	cmp ax, [program_id]
	jne .end
	call .print_and_newline

.print_and_newline:
	add cl, 1

	mov dh, cl 
	call cursor_new_line

	call os_print_string 
	
	ret

.run_program:	; going to call a program that we find 
	; program name is in si 

.run_6:
	; check for program at 0x0800
	mov di, 0x0802

	call os_compare_strings
	jne .run_8
	
	pusha

 	
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0
	
	call  080Ch
	
	popa

	jmp os_main

.run_8:

	; check for program at 0x0C00
	mov di, 0x0C02
	call os_compare_strings
	jne .run_10

	pusha
	call 0x0C00
	popa
	jmp .repl_loop

.run_10:
	; check for program at 0x1000
	mov di, 0x1002
	call os_compare_strings
	mov si, no_program_err
	jne .no_program_err
	call 0x1002
	jmp .repl_loop

.no_program_err:
	call .print_and_newline
	jmp .repl_loop


; ================================================================
; 			  SYSTEM CALLS 
; ================================================================


os_read_char: 
	; places resulting char in dx 
	push ax
	push bx
	push cx

	mov ah, 00h
	int 16h 
	mov dl, 0
	mov dl, al
	

	;mov ax, 2000h
	;mov ds, ax
	;mov es, ax

	pop cx
	pop bx
	pop ax
	
	
	ret 

os_write_char: 
	; pass char in al 

	
	pusha

	mov bh, 0 
	mov dx, 1

	mov ah, 0Eh
	int 10h 

	;mov ax, 2000h
	;mov ds, ax
	;mov es, ax

	popa

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



os_print_string: 	; pass string in si
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


os_compare_strings: 	; pass string 1 in si, string 2 in di
	pusha 

.continue:
	mov al, byte [si]
	mov dl, byte [di]

	cmp al, dl
	jne .not_equal

	cmp al, 0 	; end of string 
	je .equal
	
	inc si
	inc di
	
	jmp .continue	

.equal:
	popa 
	stc 	; set carry flag
	ret


.not_equal:
	popa
	clc 	; clear carry flag 
	ret
	


os_string_token: 	; pass string in si, delimiter in al, stores pointer to next token in di 
	push si 
	push ax

.next:
	
	cmp byte [si], 0
	je .none_found
	
	cmp al, byte [si]
	je .return_token
	

	inc si
	jmp .next 
	
.none_found:
	mov di, 0
	pop ax
	pop si
	ret

.return_token:

	mov [si], byte 0
	inc si
	mov di, si
	
	pop ax
	pop si
	ret 


os_get_cursor_x:
	; passes back cursor x in al 

	push bx
	push cx
	push dx
	
	
	mov bh, 0 
	mov ah, 03h
	int 10h


	;mov ax, 2000h
	;mov ds, ax
	;mov es, ax

	mov al, dl 	; row column stored in dl

	pop dx
	pop cx
	pop bx
	
	ret

	 	

; ================================================================
; 			UTILITY SUBROUTINES
; ================================================================


cursor_new_line:
	;passed in: dh contains current row number 

	push ax
	push cx
	push bx
	
	mov bh, 0
	mov ah, 02h      
	mov dl, 00h
	int 10h
	
	pop bx
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
; 		      	      DATA
; ================================================================

	kernel_load db "Welcome to JobOS", 0
	jobos db "JobOS> ",0

	command times 32 db 0
	input times 242 db 0

	run_string db "run", 0
	ls_string db "ls", 0
 
	instructions db "JobOS Commands: RUN and LS", 0

	program_id dw "JR"

	no_program_err db "Error: Invalid RUN parameter.", 0
	

