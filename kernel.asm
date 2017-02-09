; =======================================================================
; 		     	      JobOS Kernel
; =======================================================================	
; This kernel runs an interactive REPL that can run and list included programs

	BITS 16
start: jmp os_main

os_main: ; main kernel routine
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

.single_line: ; commands we should support - ls - list available programs/actions, run something  

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

; ================================================================
; 		      STRING AND VARIABLES
; ================================================================

kernel_load db "Welcome to JobOS", 0
jobos db "JobOS> ",0

times 512-($-$$) db 0
