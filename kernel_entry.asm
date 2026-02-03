[bits 32]
[extern _main] ; MinGW GCC adds this underscore

_start:
    call _main ; Call the C function
    jmp $