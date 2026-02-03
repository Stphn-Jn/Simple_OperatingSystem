[org 0x7c00]

; Set Video Mode 13h
mov ah, 0x00
mov al, 0x13
int 0x10

; Initial Position (Center)
mov cx, 160     ; X
mov dx, 100     ; Y

main_loop:
    ; Draw current pixel
    mov ah, 0x0c
    mov al, 0x0e    ; Yellow
    int 0x10

    ; Wait for key press
    mov ah, 0x00
    int 0x16        ; Keyboard Interrupt (Returns ASCII in AL)

    ; Handle Movement
    cmp al, 'w'
    je move_up
    cmp al, 's'
    je move_down
    cmp al, 'a'
    je move_left
    cmp al, 'd'
    je move_right
    jmp main_loop   ; Ignore other keys

move_up:
    dec dx
    jmp main_loop
move_down:
    inc dx
    jmp main_loop
move_left:
    dec cx
    jmp main_loop
move_right:
    inc cx
    jmp main_loop

times 510-($-$$) db 0
dw 0xaa55