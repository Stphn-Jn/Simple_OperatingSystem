[org 0x7c00]
KERNEL_OFFSET equ 0x1000

jmp short start
nop
times 33 db 0       ; BIOS Parameter Block padding

start:
    cli             
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  
    sti             

    mov [BOOT_DRIVE], dl

    ; Check for LBA Extensions
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error

    ; Load Kernel via LBA Packet
    mov ah, 0x42            
    mov dl, [BOOT_DRIVE]
    mov si, disk_packet     
    int 0x13
    jc disk_error
    
    jmp KERNEL_OFFSET

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

align 4
disk_packet:
    db 0x10                 ; Packet size
    db 0                    ; Reserved
    dw 60                   ; Sectors to read
    dw KERNEL_OFFSET        ; Offset
    dw 0                    ; Segment
    dq 1                    ; Start at Sector 1 (Kernel)

BOOT_DRIVE db 0
times 510-($-$$) db 0
dw 0xaa55