[org 0x7c00]      ; BIOS loads bootloader at this memory address

; Print 'G' to the screen
mov ah, 0x0e      ; BIOS scrolling teletype function
mov al, 'G'       ; Character to print
int 0x10          ; Call BIOS video interrupt

jmp $             ; Infinite loop (prevents CPU from executing trash memory)

times 510-($-$$) db 0  ; Fill remaining space with zeros up to byte 510
dw 0xaa55              ; Magic number (bytes 511-512) to make it bootable