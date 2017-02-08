#!/bin/sh

# This script starts the QEMU PC emulator, booting from the

nasm -f bin -o kernel.bin kernel.asm

nasm -f bin -o bootloader.bin bootloader.asm

cat kernel.bin >> bootloader.bin

dd status=noxfer conv=notrunc if=bootloader.bin of=jobos.flp

qemu-system-x86_64 -soundhw pcspk -fda jobos.flp

