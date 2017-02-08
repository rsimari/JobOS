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
	call os_move_cursor

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
os_repeat:

	lodsb
	cmp al, 0
	je os_done
	int 10h
	jmp short os_repeat

os_done: 
	call os_new_line
	popa 
	ret 

os_end: 
	mov ah, 00h
	;int 19h

os_new_line:
	pusha

	mov ah, 02h
	inc dh      ; increments the row number
	mov dl, 00h
	int 10h

	popa
	ret

os_write_char_at_cursor:
	pusha

	mov ah, 0Ah
	mov al, 48h
	int 10h

	popa
	ret




kernel_load db "Welcome to JobOS", 0


times 512-($-$$) db 0

