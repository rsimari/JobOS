	BITS 16
	%INCLUDE "jobos.inc"
	ORG 2048
	id dw "JR"
	name db "Teletype", 0, 0, 0, 0 
start:	
	 	
 
	mov si, tele_prompt
	call os_clear_screen

	call os_print_string

	
.read: 		; commands we should support - ls - list available programs/actions, run something  

	; wait for input 
	call os_read_char
	
.check_back: 
	cmp dl, 8
	jne .check_esc 

	mov al, dl

	push cx
	call os_write_char
	mov al, 0
	call os_write_char
	mov al, 8
	call os_write_char
	pop cx

	jmp .read

.check_esc: 
	cmp dl, 27
	jne .write

	jmp exit
	

.write: 

	mov al, dl
 
	push cx
	call os_write_char 	; prints char at the cursor position  
	pop cx

	jmp .read 	; keep getting chars

exit:
	ret


tele_prompt db "Welcome to Teletype - Press ESC to exit", 13, 10, 0
