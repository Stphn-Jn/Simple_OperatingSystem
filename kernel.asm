[org 0x1000]

; Sync segments
xor ax, ax
mov ds, ax
mov es, ax

mov ax, 0x03        ; Reset video mode
int 0x10

mov si, welcome_msg
call print_string

install_loop:
    mov si, prompt
    call print_string
    call clear_buffer
    call get_input

    ; --- Command Routing ---
    mov si, input_buffer
    mov di, cmd_lsblk
    call strcmp
    jc .do_lsblk

    mov si, input_buffer
    mov di, cmd_neofetch
    call strcmp
    jc .do_neofetch

    mov si, input_buffer
    mov di, cmd_reboot
    call strcmp
    jc reboot

    cmp byte [input_buffer], 0
    je install_loop
    mov si, err_cmd
    call print_string
    jmp install_loop

.do_lsblk:
    mov si, table_header
    call print_string
    mov si, sda_row
    call print_string
    jmp install_loop

.do_neofetch:
    ; Hardware Probes
    xor eax, eax
    cpuid
    mov [cpu_vendor], ebx
    mov [cpu_vendor+4], edx
    mov [cpu_vendor+8], ecx

    call detect_memory      ; Find total RAM in MB

    mov si, neo_art_top
    call print_string
    mov si, neo_cpu_label
    call print_string
    mov si, cpu_vendor
    call print_string
    mov si, newline
    call print_string
    mov si, neo_ram_label
    call print_string
    mov ax, [total_ram_mb]
    call print_int
    mov si, mb_suffix
    call print_string
    mov si, neo_art_bottom
    call print_string
    jmp install_loop

reboot:
    jmp 0xFFFF:0000

; --- MEMORY DETECTION (E820) ---
detect_memory:
    pusha
    mov di, 0x8000          ; Buffer for memory map
    xor ebx, ebx            ; Continuation value (0 to start)
    xor bp, bp              ; Counter
    mov edx, 0x534D4150     ; 'SMAP'
.loop:
    mov eax, 0xE820
    mov ecx, 24             ; Entry size
    int 0x15
    jc .done                ; Carry set = end of map
    cmp eax, 0x534D4150
    jne .done
    
    ; Check if Type is 1 (Usable RAM)
    cmp dword [di + 16], 1
    jne .skip
    
    ; Get base address + length
    mov eax, [di + 8]       ; Low 32 bits of length
    shr eax, 20             ; Convert bytes to MB
    add [total_ram_mb], ax
    
.skip:
    test ebx, ebx
    jz .done
    inc bp
    jmp .loop
.done:
    popa
    ret

; --- HELPERS ---
print_int:
    pusha
    mov cx, 0
    mov bx, 10
.lp1:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .lp1
.lp2:
    pop dx
    add dl, '0'
    mov al, dl
    mov ah, 0x0e
    int 0x10
    loop .lp2
    popa
    ret

print_string:
    mov ah, 0x0e
.lp: lodsb
    cmp al, 0
    je .dn
    int 0x10
    jmp .lp
.dn: ret

get_input:
    mov di, input_buffer
    mov cx, 0
.lp:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .dn
    cmp al, 0x08
    je .back
    mov ah, 0x0e
    int 0x10
    stosb
    inc cx
    jmp .lp
.back:
    cmp cx, 0
    je .lp
    dec di
    dec cx
    call backspace_ui
    jmp .lp
.dn: mov al, 0
    stosb
    mov si, newline
    call print_string
    ret

backspace_ui:
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    ret

clear_buffer:
    pusha
    mov di, input_buffer
    mov al, 0
    mov cx, 64
    rep stosb
    popa
    ret

strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .ne
    cmp al, 0
    je .eq
    inc si
    inc di
    jmp .loop
.ne: clc
    ret
.eq: stc
    ret

; --- DATA ---
total_ram_mb   dw 0
welcome_msg    db '--- Arch-PingOS Professional Terminal ---', 13, 10, 0
prompt         db '[root@arch]# ', 0
newline        db 13, 10, 0
mb_suffix      db ' MB', 13, 10, 0
cmd_lsblk      db 'lsblk', 0
cmd_neofetch   db 'neofetch', 0
cmd_reboot     db 'reboot', 0

neo_art_top    db '       /\         root@pingos', 13, 10
               db '      /  \        -----------', 13, 10
               db '     /\   \       OS: Arch-PingOS', 13, 10, 0
neo_cpu_label  db '    /      \      CPU: ', 0
neo_ram_label  db '   /   /\   \     RAM: ', 0
neo_art_bottom db '  /   /  \   \    Kernel: 1.0-LBA', 13, 10
               db ' /___/    \___\   Shell: Ping-Bash', 13, 10, 0

cpu_vendor     times 13 db 0
table_header   db 13, 10, 'NAME      MAJ:MIN   SIZE   TYPE   DESCRIPTION', 13, 10, '---------------------------------------------------', 13, 10, 0
sda_row        db 'sda         8:0     32M    disk   (Physical Flash)', 13, 10, 0
err_cmd        db 'Unknown command.', 13, 10, 0
input_buffer   times 64 db 0