[org 0x7c00]
KERNEL_OFFSET equ 0x1000

jmp short start
nop
times 33 db 0       ; Padding for the BIOS Parameter Block (Standard for USB/HDD)

start:
    cli             
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; Move stack below the bootloader for safety
    sti             

    mov [BOOT_DRIVE], dl

    ; Reset disk system (Essential for hardware)
    mov ah, 0
    mov dl, [BOOT_DRIVE]
    int 0x13

    ; Load Kernel
    mov ah, 0x02
    mov al, 50      
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, [BOOT_DRIVE]
    mov bx, KERNEL_OFFSET
    int 0x13

    jc disk_error
    jmp KERNEL_OFFSET

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

BOOT_DRIVE db 0
times 510-($-$$) db 0
dw 0xaa55