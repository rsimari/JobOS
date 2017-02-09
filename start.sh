#!/bin/sh

# This script starts the QEMU PC emulator, booting from the

nasm -O0 -f bin -o kernel.bin kernel.asm

nasm -O0 -f bin -o bootloader.bin bootloader.asm

nasm -O0 -f bin -o teletype.bin teletype.asm

dd status=noxfer conv=notrunc seek=5 bs=512 if=teletype.bin of=jobos.flp

cat kernel.bin >> bootloader.bin

dd status=noxfer conv=notrunc if=bootloader.bin of=jobos.flp

qemu-system-x86_64 -soundhw pcspk -fda jobos.flp

