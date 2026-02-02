[org 0x7c00]

mov si, WELCOME_MSG    ; Point SI register to our string label
call print_string      ; Call our new print function

jmp $                  

print_string:
    mov ah, 0x0e       ; BIOS teletype mode
.loop:
    lodsb              
    cmp al, 0          
    je .done           
    int 0x10           
    jmp .loop          
.done:
    ret

WELCOME_MSG: db 'Welcome to PingOS!', 0

times 510-($-$$) db 0
dw 0xaa55