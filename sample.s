%include        "io64.s"

section .data

msg:    db      "Hi there", 10, 0

section .text

_main:
        mov     rax, 0x1234567812345678
        call    disphb
        exit    0
