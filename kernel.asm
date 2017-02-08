	BITS 16
start: jmp os_main
os_main:
	cli 
	mov ax, 0x1000
	mov ds, ax
	mov ss, ax
	mov sp, 0FFFFh
	sti 

	mov es, ax
	mov fs, ax


	mov si, 0
	mov si, kernel_load
	call os_clear_screen
	call os_print_string
	;call os_write_char_at_cursor
	;call os_move_cursor

	call os_launch_repl
	jmp $

os_clear_screen:
	pusha

	mov dx, 0

	; move curser to top
	mov bh, 0
	mov ah, 2
	int 10h
	; end move curser

	mov ah, 6
	mov al, 0
	mov bh, 7
	mov cx, 0
	mov dh, 24
	mov dl, 79
	int 10h

	popa
	ret

os_print_string:
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

os_end: 
	mov ah, 00h
	;int 19h

os_new_line:
	;passed in: dh contains current row number 

	push ax
	push dx

	mov ah, 02h      
	mov dl, 00h
	int 10h

	pop ax 
	pop dx 

	ret


os_launch_repl: 
	; passed in, nothing. 
	pusha 

	mov cl, 1 ; line 1	

.repl_loop:
	
	mov dh, cl
	; new line, set cursor etc. 
	call os_new_line 


	mov si, jobos
	call os_print_string 

.single_line: ; commands we should support - ls - list available programs/actions, run something  

	; wait for input 
	call os_read_char
	
.check_new_line: 
	cmp dl, 13 ; dl contains read char 
	je .new_line ;  jump if new line

.check_back_space: 
	cmp dl, 8
	jne .continue_reading 
	
	mov ax, 0
	mov al, dl
	call os_write_char
	mov al, 0
	call os_write_char
	mov al, 8
	call os_write_char
	
	jmp .single_line

.continue_reading: 
	mov ax, 0
	mov al, dl
 
	call os_write_char ; prints char at the cursor position  

	jmp .single_line ; keep getting chars 

.new_line:
	inc cl
	jmp .repl_loop ; jump back


	popa 
	ret 


os_backspace: 
	
 

os_read_char: 

	; places resulting char in dx 
	push ax

	mov ah, 00h
	int 16h 
	mov dl, 0
	mov dl, al

	pop ax
	ret 

; returns column in al
os_get_cursor_index: 
	push bx
	push cx
	push dx


	mov ah, 03h
	mov bh, 0
	int 10h 

	mov al, dl ; passes back in al 

	pop bx
	pop cx
	pop dx
	
	ret 


os_write_char: 
	; pass char in al 

	push bx 
	push cx 

	mov bh, 0 
	mov cx, 1

	mov ah, 0Eh
	int 10h 

	pop bx
	pop cx

	ret 

kernel_load db "Welcome to JobOS", 0
jobos db "JobOS> ",0

times 512-($-$$) db 0

