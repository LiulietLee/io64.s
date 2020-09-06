%macro  exit    1
        mov     rax, 0x02000001
        mov     rdi, %1
        syscall
%endmacro

global  _main
default rel

; input:    rax = address of string with end 0
; output:   rax = length of string
__strlen:
        push    rsi
        push    rdx
        
        mov     rsi, rax
        xor     rax, rax

__strlenloop:
        mov     dl, [rsi]
        cmp     dl, 0
        je      __strlenend
        inc     rax
        inc     rsi
        jmp     __strlenloop

__strlenend:
        pop     rdx
        pop     rsi
        ret

; rax = address of string
dispmsg:
        push    rax
        push    rsi
        push    rdi
        push    rcx

        mov     rsi, rax
        call    __strlen
        mov     rdx, rax
        mov     rax, 0x02000004
        mov     rdi, 1
        syscall

        pop     rcx
        pop     rdi
        pop     rsi
        pop     rax
        ret

; al = input character
dispc:
        push    rax
        push    rdi
        push    rsi
        push    rdx
        push    rcx

        push    ax
        mov     rdi, 1
        mov     rsi, rsp
        mov     rdx, 1
        mov     rax, 0x02000004
        syscall
        pop     ax

        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        pop     rax
        ret

dispcrlf:
        push    rax
        push    rdi
        push    rsi
        push    rdx
        push    rcx

        mov     ax, 10
        push    ax
        mov     rdi, 1
        mov     rsi, rsp
        mov     rdx, 1
        mov     rax, 0x02000004
        syscall
        pop     ax

        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        pop     rax
        ret

; al = input data
__disphb:
        push    rax
        push    rbx
        push    rdx
        push    rsi
        push    rcx

        and     rax, 0x000000ff
        mov     rbx, rax
        xor     rax, rax
        xor     rcx, rcx
        xor     rsi, rsi
        mov     rdx, __btoh_tb

        mov     si, bx
        shr     si, 4
        mov     al, [rdx + rsi]
        call    dispc

        mov     si, bx
        and     si, 0x000f
        mov     al, [rdx + rsi]
        call    dispc
        
        pop     rcx
        pop     rsi
        pop     rdx
        pop     rbx
        pop     rax
        ret
__btoh_tb:
        db      "0123456789ABCDEF"

; al = input data
disphb:
        push    rax

        call    __disphb
        mov     al, "H"
        call    dispc
        
        pop     rax
        ret

; ax = input data
disphw:
        push    rax
        push    rcx

        xchg    ah, al
        mov     rcx, 2
__disphwloop:
        call    __disphb
        shr     rax, 8
        loop    __disphwloop
        
        mov     al, "H"
        call    dispc

        pop     rcx
        pop     rax
        ret

; eax = input data
disphd:
        push    rax
        push    rcx

        xchg    ah, al
        rol     eax, 16
        xchg    ah, al

        mov     rcx, 4
__disphdloop:
        call    __disphb
        shr     eax, 8
        loop    __disphdloop

        mov     al, "H"
        call    dispc
        
        pop     rcx
        pop     rax
        ret

; rax = input data
disphq:
        push    rax
        push    rcx

        rol     rax, 8
        mov     rcx, 8
__disphqlooop:
        call    __disphb
        rol     rax, 8
        loop    __disphqlooop

        mov     al, "H"
        call    dispc
        
        pop     rcx
        pop     rax
        ret

readc:
        ret

readmsg:

        ret