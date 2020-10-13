%include        "io64.s"

section .data

msg:    db      "Hi there", 10, 0

section .text

start:
        mov     rax, msg
        call    dispmsg
        exit    0