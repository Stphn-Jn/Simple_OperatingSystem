[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl        ; Save physical drive index

mov bp, 0x9000
mov sp, bp

disk_reset:
    mov ah, 0
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_reset

mov ah, 0x02
mov al, 50                  ; Load enough sectors for our expanding kernel
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