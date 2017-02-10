# JobOS

## An Operating System written in x86 assembly by John Joyce and Robert Simari

### Description:

Our OS was written from scratch in the 1978 version of 16 bit x86 Intel assembly language. We used a virtual 1.44 IBM floppy disk to load our bootloader and kernel.  The interface of our OS is a simple text-based repl where a user can type and run simple commands or programs (run & ls). Currently you can interact with the repl by simply typing commands and pressing delete to remove characters. The kernel currently has logic to recognize invalid commands and prompt a user with error messages. The 'run' command begins the specified program, while the 'ls' command lists the programs available to run.

The OS is kicked off by the bootloader, which resides on the first sector of the floppy disk. This code acts as an MBR and bootstraps the kernel. It first details the floppy disk specifications, which are used when making BIOS calls to read disk. Next, we bootstrap by pulling sectors 2-15 of the disk into RAM beginning at location 2000h. If there is an error during this process, the floppy disk is rebooted. If the error persists, the processor is reset. Otherwise, we conclude by cleaning up and jumping to 2000h, where the main routine of our kernel sits. 

The kernel file begins with a list of 'jmp' instructions to various system calls. This allows programs to make system calls without knowing specifically where in memory the routines are (programs include jobos.inc, which equates system call names to their addresses at the beginning of the kernel file). The kernel continues by initializing the various segments. For the most part, our os stays within a single 64k segment. However, our stack segment is separate and begins at the beginning of memory (addr. 0). The data segment, code segment, extra segment, all begin at 2000h. After performing some set up, os_main calls the os_run_repl routine, which begins the REPL. 

The REPL logic is a bit complicated. Essentially it flows as follows: - print new line, print prompt ("JobOS>"), read char, check char for newline or backspace, which must both be handled appropriately, save char in buffer, write char to screen, repeat. If a newline is detected, we attempt to parse the command, determining it the command 'run' or 'ls' has been entered using an system call that tokenizes strings based on a specific char. 

The JobOS filesystem is primitive, but will be improved. Currently, programs can only be the length of 2 sectors on disk, or 512 * 2 bytes. Only three programs can exist, being stored at sectors 6, 8, and 10 on disk. They are loaded into memory in the bootloader. Each valid program must begin with the indentifying 2 bytes "JR" followed by a 12-byte program name. Following this, the program code can reside. 

The 'ls' command simply scans those locations for the identifier "JR" and prints the following name to the screen if a valid program is found. 

The 'run' command does a similar scan, comparing the title of the program to the text entered in the REPL. If a match is found, we push our registers and jump to the program, which must end with the 'ret' command to return to the REPL. 

We'd like to develop the FS such that programs can be stored on any of the even sectors on disk (as there are 2880 sectors on one disk!) and loaded into memory when appropriate. This could present issues, however, as we have to load entire sectors into memory prior to determining whether a valid program exists there. 

The first program on the disk is 'Teletype', which essentially mimics a Teletype machine, just allowing one to write and backspace, exiting the programming by pressing the 'ESC' key. 

We also wrote a simple program in graphics mode that shows a simple pong-like animation. When executed it switches the kernel into graphics mode and uses a routine to write/read from the video buffer. It creates two paddles like in pong and a ball bounces between the paddles using an animation routine. The animation routine uses loops and the BIOS wait interrupt to show the ball moving back and forth. In the future we hope to turn this into a fully functional game.

In the 1970s, hackers were using simple computers and assembly instructions to write things like interpreters and games. These hackers were writing much simpler software compared to today, but they had a much stronger understanding of the hardware and instructions worked. The primary goal of this project was to obtain a similar understanding of how an OS and the BIOS works. I think it is safe to say we learned a ton. We also learned that bugs are much much harder to find in assembly. 

In creating this historical artifact we tried to emulate what the MIT Hackers' experienced with writing code in assembly. We tried to only work with tools that the hackers had access to (besides a PC emulator). We started by writing very simple routines in assembly using the limited BIOS interrupt calls that help us interact with hardware. We found that interacting this closely with the hardware can be equally empowering and frustrating. Once we had these simple system calls like reading characters from the keyboard we could more and more complex things like string parsing. 

### To Run Our OS on Ubuntu:

1. git clone https://gitlab.com/rsimari/JobOS.git
2. cd JobOS/
3. sudo apt-get install build-essential qemu nasm
4. sh start.sh


