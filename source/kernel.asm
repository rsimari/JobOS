; 
; Rob Kernel For JobOS
;

BITS 16

disk_buffer equ 24576

os_call_vectors:
	jmp os_main
	jmp os_print_string

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

	mov ax, 2000h			; Set all segments to match where kernel is loaded
	; mov ds, ax			; After this, we don't need to bother with
	; mov es, ax			; segments ever again, as MikeOS and its programs
	; mov fs, ax			; live entirely in 64K
	; mov gs, ax			; es, fs, gs are extra segments for stuff like memory

	cmp dl, 0
	je no_change
	mov [bootdev], dl		; Save boot device number
	push es 			; pushes es onto stack 
	mov ah, 8			; Get drive parameters
	int 13h				; 13h for write string
	pop es				; pops es back off of stack
	and cx, 3Fh			; Maximum sector number
	mov [SecsPerTrack], cx		; Sector numbers start at 1
	movzx dx, dh			; Maximum head number
	add dx, 1			; Head numbers start at 0 - add 1 for total
	mov [Sides], dx

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
