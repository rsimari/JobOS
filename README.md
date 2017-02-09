###JobOS

#An Operating System written in x86 assembly by John Joyce and Robert Simari

#Description:

	Our OS was written from scratch in the 1978 version of 16 bit x86 Intel assembly language. We also used a virtual 1.44 IBM floppy disk to load our bootloader and kernel.  The interface of our OS is a simple text-based repl where a user can type and run simple commands or programs. Currently you can interact with the repl by simply typing commands and pressing delete to remove characters. The kernel currently has logic to recognize invalid commands and prompt a user with error messages. 

	< Explanation of your specific stuff John >

	We also wrote a simple program in graphics mode that shows a simple pong-like animation. When ran it switches the kernel into graphics mode and uses a route to write/read from the video buffer. It creates two paddles like in pong and a ball bounces between the paddles using an animation routine. The animation routine uses loops and the BIOS wait interrupt to show the ball moving back and forth. In the future we hope to turn this into a fully functional game.

	In creating this historical artifact we tried to emulate what the MIT Hackers' experienced with writing code in assembly. We tried to only work with tools that the hackers had access to (besides a PC emulator). We started by writing very simple routines in assembly using the limited BIOS interrupt calls that help us interact with hardware. We found that interacting this closely with the hardware can be equally empowering and frustrating. Once we had these simple system calls like reading characters from the keyboard we could more and more complex things like string parsing. 

#To Run Our OS on Ubuntu:

1. git clone https://gitlab.com/rsimari/JobOS.git
2. cd JobOS/
3. sudo apt-get install build-essential qemu nasm
4. sh start.sh

