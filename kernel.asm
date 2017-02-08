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
	call os_print_string	


	jmp $

os_print_string:
	pusha

	mov ah, 0Eh
os_repeat:

	lodsb
	cmp al, 0
	je os_done
	int 10h
	jmp short os_repeat
os_done: 

	popa 
	ret 

os_end: 
	mov ah, 00h
	;int 19h


kernel_load db "hello", 0


times 512-($-$$) db 0

