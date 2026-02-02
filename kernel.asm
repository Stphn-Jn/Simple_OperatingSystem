[org 0x1000]

mov ax, 0x03        ; Text Mode
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
    mov di, cmd_fdisk
    call strcmp
    jc .do_fdisk

    mov si, input_buffer
    mov di, cmd_pacman
    call strcmp
    jc .do_pacman

    mov si, input_buffer
    mov di, cmd_sysinfo
    call strcmp
    jc .do_sysinfo

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
    cmp byte [is_partitioned], 1
    jne install_loop
    mov si, sda1_row
    call print_string
    jmp install_loop

.do_fdisk:
    mov si, msg_fdisk_run
    call print_string
    mov byte [is_partitioned], 1
    jmp install_loop

.do_pacman:
    cmp byte [is_partitioned], 0
    je .err_no_disk
    mov si, msg_pac_run
    call print_string
    call simulate_progress
    mov byte [is_installed], 1
    jmp install_loop
.err_no_disk:
    mov si, err_fdisk
    call print_string
    jmp install_loop

.do_sysinfo:
    mov si, msg_cpu_probe
    call print_string
    
    ; --- CPUID Logic ---
    xor eax, eax        ; EAX = 0: Get Vendor ID
    cpuid               ; Returns ID in EBX, EDX, ECX
    
    mov [cpu_vendor], ebx
    mov [cpu_vendor+4], edx
    mov [cpu_vendor+8], ecx
    
    mov si, msg_vendor
    call print_string
    mov si, cpu_vendor
    call print_string
    mov si, newline
    call print_string
    jmp install_loop

.do_neofetch:
    mov si, neo_art
    call print_string
    jmp install_loop

reboot:
    jmp 0xFFFF:0000

; --- UTILITIES ---
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

simulate_progress:
    mov cx, 20
.lp:
    mov ah, 0x0e
    mov al, '#'
    int 0x10
    push cx
    mov cx, 0x0FFF
.d: loop .d
    pop cx
    loop .lp
    mov si, newline
    call print_string
    ret

; --- DATA ---
is_partitioned db 0
is_installed   db 0
welcome_msg    db '--- Arch-PingOS Deployment Shell ---', 13, 10, 0
prompt         db '[root@live-iso]# ', 0
newline        db 13, 10, 0
cmd_lsblk      db 'lsblk', 0
cmd_fdisk      db 'fdisk', 0
cmd_pacman     db 'pacman', 0
cmd_sysinfo    db 'sysinfo', 0
cmd_neofetch   db 'neofetch', 0
cmd_reboot     db 'reboot', 0

msg_cpu_probe  db 'Polling CPUID registers...', 13, 10, 0
msg_vendor     db 'CPU Vendor: ', 0
cpu_vendor     times 13 db 0 ; Space for 12 chars + null terminator

neo_art        db '       /\         root@pingos', 13, 10
               db '      /  \        -----------', 13, 10
               db '     /\   \       OS: Arch-PingOS x86', 13, 10
               db '    /      \      Host: Physical Hardware', 13, 10
               db '   /   /\   \     Kernel: 1.0.0-ping-custom', 13, 10
               db '  /   /  \   \    Uptime: 16-bit Real Mode', 13, 10
               db ' /___/    \___\   Shell: Ping-Bash', 13, 10, 0

table_header   db 13, 10, 'NAME      MAJ:MIN   SIZE   TYPE   DESCRIPTION', 13, 10, '---------------------------------------------------', 13, 10, 0
sda_row        db 'sda         8:0     10M    disk   (Physical Drive)', 13, 10, 0
sda1_row       db '`-sda1      8:1      9M    part   (System Partition)', 13, 10, 0
msg_fdisk_run  db 'fdisk: Partition sda1 successfully mapped.', 13, 10, 0
msg_pac_run    db 'pacman: Initializing base system download...', 13, 10, 0
msg_success    db 13, 10, 'SUCCESS. The system is ready for deployment.', 13, 10, 0
err_cmd        db 'Command not found.', 13, 10, 0
err_fdisk      db 'Error: Run fdisk first!', 13, 10, 0
input_buffer   times 64 db 0