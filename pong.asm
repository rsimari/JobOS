os_game:
	pusha

	call os_clear_screen
	nop

	mov ax, 13h ; change to graphics mode
	int 10h
	mov ax, 0A000h
	mov es, ax

	call draw_title
	nop
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
	ret

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
