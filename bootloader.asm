; JobOS Bootloader File
; Hands off to kernel 
; Based on MikeOS Bootloader 
; JobFS
; Initialization 
	BITS 16
	jmp short bootstrap_start ; Jump past the disk description 
	nop 

; ==============================================================================
;                     Disk Description Table for BIOS 
; ==============================================================================


; 		1.44 IBM Floppy Disk Specs 

OEMLabel 	db "JOBOSBOOT"	; disk label
BytesPerSector 	dw 512 		; bytes/sector 
SectorsPerCluster db 1 		; sectors/cluster
ReservedForBoot	dw 1		; sectors reserved for the boot
RootDirEntries 	dw 224 		; number of entries with root directory 
TotalSectors 	dw 2880		; logical sectors numbers 
MediumType	db 0F0h 	; 1.4 M floppy 
SectorsPerTrack dw 18 		; Sectors per track 
NumSides	dw 2		; Number of sides to disk
HiddenSectors 	dd 0 		; NUmber of hidden sectors 
LargeSectors 	dd 0		; Large sector number
DriveNum	dw 0 		; Drive number
Signature	db 41		; Floppy disk signature 
VolumeID 	dd 0		; Volume ID 
VolumeLabel	db "JohnAndRob"	; Volume label 
FileSystem 	db "JobFS"	; File System Identifier 

; ===============================================================================
;                    	    END OF DISC DESCRIPTOR 
; ===============================================================================


; ===============================================================================
; 		      	     BEGIN BOOTSTRAPPING 
; ===============================================================================

bootstrap_start: 
	mov ax, 07C0h	; set up 8K Buffer and 4096-byte stack
	add ax, 544	; 8K buffer (512 + 32 (this) paragraphs) 

	cli		; prevent interrupts during segment/stack initialization 
	mov ss, ax
	mov sp, 4096
	sti 		; enable interrupts 
	
	mov ax, 07C0h	; set data segment to where we are
	mov ds, ax 
	

	; get boot device number 
	mov [boot_dev_num], dl
	
	mov ah, 8 ; get the drive parameters from BIOS 
	int 13h 
	
	jc disk_error 	; Error - jump to drive error 
	
	; get max number of sectors ! 
	and cx, 3Fh ; 00111111 since [5:0] give logical last index of sector 
	mov [SectorsPerTrack], cx	; store the actual sectors per track to our variable. 

	movzx dx, dh 	; last index of heads is in dh
	add dx, 1 	; number of actual is heads is the addition, since indexes start at 0
	mov [NumSides], dx 	; store the actual number of sides (rather than default) 
 
	mov si, kernel_load	;
	call print_string 	; relay to user that kernel is loading 
	
	call load_kernel 	; load the kernel 

	jmp $

; =================================================================
; 	       LOADS KERNEL FROM SECTOR 2 OF DISC
; =================================================================
load_kernel: 
	mov ax, 1 ; logical sector 2 is kernel
	
	; set dx to 0 
	mov dx, 0

	; add one to the remainder (giving 2) 
	add dl, 02h 	; physical sectors don't start at 0
	
	; prepare for int 13h 
	mov cl, dl 	; sectors in CL for 13h int
	mov dh, 0	; Calculate the head - side 0 
	mov ch, 0 	; track 0

	mov dl, byte [boot_dev_num] ; set device parameters

	; Now we want to set ES:BX to point to our buffer
	; interrupt places loaded mem into ES+BX, place Kernel at 1000h 
	mov bx, 1000h 	; mov data segment pointer into bx
	mov es, bx	; 
	mov bx, 0000h 	; offset of 0000h 
			; uses this many instructions 
			; because segment reg. are weird
	mov ah, 2h	; code for 13h read sector
	mov al, 14 	; read 14 sectors just for fun

	pusha

read_kernel: 

	popa		; in case int call changes things
	pusha 

	int 13h 	; read the registers!

	jnc run_kernel	; if read works, go!
	call reset_floppy	;otherwise, try again
	jnc read_kernel	; if reset works, try again
	
	jmp reboot	; if it doesn't, try rebooting

run_kernel: 
	
	popa	
	
	mov dl, byte [boot_dev_num] 
	
	jmp 1000h:0000h
	
; Kernel is located immediately after this sector in 'root' 
	

; ================================================================
;			   DISK ERROR
; ================================================================ 

disk_error: 
	mov si, floppy_error	; go for it
	call print_string 

	mov ah, 00h 
	int 16h			; read a key from the keyboard 
	
	call reboot 

; =================================================================
;                        SUBROUTINES 
; =================================================================

print_string:
	pusha 

	mov ah, 0Eh
.repeat: 
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp short .repeat
.done: 

	popa 
	ret 

reboot: 
	mov ax, 0
	int 19h 

reset_floppy:  	;resets the floppy disk if necessary 
	pusha
	mov ah, 00h
	mov dl, byte [boot_dev_num]
	stc
	int 13h

	popa
	ret 

; ==================================================================
;                           VARIABLES 
; ==================================================================

	kernel_file db "KERNEL BIN" ; name of filename to find 
	
	floppy_error db "Floppy disk error: Press a key...", 0
	file_not_found db "Cannot find kernel.bin file.", 0

	boot_dev_num db 0	; boot device number 
	kernel_load db "Loading the kernel...", 0


; ==================================================================
;			END OF BOOT SECTOR
; ==================================================================

	times 510-($-$$) db 0
	dw 0xAA55

; ==================================================================
;		       BUFFER START (IF NEEDED) 
; ==================================================================	


