; 
; Rob Kernel For JobOS
;

BITS 16

disk_buffer equ 24576

os_call_vectors:
	jmp os_main
	jmp os_print_string
	jmp os_wait_for_key
	jmp os_get_file_list

; Main Kernel Code

os_main:
	cli 		   ; clears all interrupts

	mov ax, 0
	mov ss, ax     ; sets stack segment
	mov sp, 0FFFFh ; sets stack pointer

	sti 		   ; restores interrupts	

	cld 		   ; clears all flags 

	mov ax, 2000h
	mov ds, ax     ; sets data segment to 2000h where it was loaded. 

	mov ax, 1003h			; Set text output with certain attributes
	mov bx, 0			; to be bright, and not blinking
	int 10h				; sets more pallette registers


option_screen:
	mov ax, os_init_message  ; print welcome message to screen
	mov cx, 10011111b		 ; set text settings
	call os_draw_background  ; draws stuff to screen


	os_init_message		db 'Welcome to JobOS!', 0

; =========================
; INCLUDE SYS CALL FILES
; =========================

	%INCLUDE "features/screen.asm"
