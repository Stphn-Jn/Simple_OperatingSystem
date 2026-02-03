[bits 32]
[extern _main]   ; Must have the underscore

_start:
    call _main   ; Must have the underscore
    jmp $