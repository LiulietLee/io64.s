global  _main
default rel

STDIN_FD        equ 0
STDOUT_FD       equ 1
SYS_EXIT_NUM    equ 0x02000001
SYS_READ_NUM    equ 0x02000003
SYS_WRITE_NUM   equ 0x02000004

%macro  exit    1
        mov     rax, SYS_EXIT_NUM
        mov     rdi, %1
        syscall
%endmacro

%macro  sys_write_call 0
        mov     rax, SYS_WRITE_NUM
        mov     rdi, STDOUT_FD
        syscall
%endmacro

%macro  sys_read_call 0
        mov     rax, SYS_READ_NUM
        mov     rdi, STDIN_FD
        syscall
%endmacro

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
        sys_write_call

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
        mov     rsi, rsp
        mov     rdx, 1
        sys_write_call
        pop     ax

        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        pop     rax
        ret

dispcrlf:
        push    rax
        mov     al, 10
        call    dispc
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

; al = input data
dispuib:
        push    rax
        push    rbx

        mov     rbx, rax
        xor     rax, rax
        mov     al, bl
        call    dispuiq
        
        pop     rbx
        pop     rax
        ret

; ax = input data
dispuiw:
        push    rax
        push    rbx

        mov     rbx, rax
        xor     rax, rax
        mov     ax, bx
        call    dispuiq
        
        pop     rbx
        pop     rax
        ret

; eax = input data
dispuid:
        push    rax
        push    rbx

        mov     rbx, rax
        xor     rax, rax
        mov     eax, ebx
        call    dispuiq
        
        pop     rbx
        pop     rax
        ret

; rax = input data
dispuiq:
        push    rcx
        push    rdx
        push    rax
        push    rsi
        push    rdi

        xor     rcx, rcx
        xor     rsi, rsi
        mov     rdi, __btoh_tb

__dispuiwloop:
        xor     rdx, rdx
        mov     rbx, 10
        div     rbx
        mov     rbx, rax
        mov     si, dx
        mov     al, [rdi + rsi]
        push    ax
        inc     rcx
        mov     rax, rbx
        cmp     rax, 0
        je      __dispuiwprint
        jmp     __dispuiwloop

__dispuiwprint:
        pop     ax
        call    dispc
        loop    __dispuiwprint

        pop     rdi
        pop     rsi
        pop     rax
        pop     rdx
        pop     rcx
        ret

; %1 = reg, %2 = msg address
%macro  __disprq_reg 2
        mov     rax, %2
        call    dispmsg
        mov     rax, %1
        call    disphq
        mov     rax, 9
        call    dispc
%endmacro
disprq:
        push    rax

        push    rax
        mov     rax, __raxequstr
        call    dispmsg
        pop     rax
        call    disphq
        mov     rax, 9
        call    dispc

        __disprq_reg    rbx, __rbxequstr
        call    dispcrlf

        __disprq_reg    rcx, __rcxequstr
        __disprq_reg    rdx, __rdxequstr
        call    dispcrlf

        __disprq_reg    rsi, __rsiequstr
        __disprq_reg    rdi, __rdiequstr
        call    dispcrlf

        __disprq_reg    rbp, __rbpequstr
        __disprq_reg    rsp, __rspequstr
        call    dispcrlf

        pop     rax
        ret

%macro  __disprd_reg 2
        mov     rax, "E"
        call    dispc
        mov     rax, %2
        inc     rax
        call    dispmsg
        mov     eax, %1
        call    disphd
        mov     rax, 9
        call    dispc
%endmacro
disprd:
        push    rax

        push    rax
        mov     rax, "E"
        call    dispc
        mov     rax, __raxequstr
        inc     rax
        call    dispmsg
        pop     rax
        call    disphd
        mov     rax, 9
        call    dispc

        __disprd_reg    ebx, __rbxequstr
        __disprd_reg    ecx, __rcxequstr
        __disprd_reg    edx, __rdxequstr
        call    dispcrlf

        __disprd_reg    esi, __rsiequstr
        __disprd_reg    edi, __rdiequstr
        __disprd_reg    ebp, __rbpequstr
        __disprd_reg    esp, __rspequstr
        call    dispcrlf

        pop     rax
        ret

__raxequstr:    db "RAX = ", 0
__rbxequstr:    db "RBX = ", 0
__rcxequstr:    db "RCX = ", 0
__rdxequstr:    db "RDX = ", 0
__rsiequstr:    db "RSI = ", 0
__rdiequstr:    db "RDI = ", 0
__rbpequstr:    db "RBP = ", 0
__rspequstr:    db "RSP = ", 0

; al = ascii code
readc:

        ret

; input:        rax = buffer address
; output:       rax = input length
readmsg:
        push    rdi
        push    rsi
        push    rdx
        push    rcx

        mov     rsi, rax
        mov     rdx, 0xff
        sys_read_call
        
        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        ret