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

%macro  syscall_write 0
        mov     rax, SYS_WRITE_NUM
        mov     rdi, STDOUT_FD
        syscall
%endmacro

%macro  syscall_read 0
        mov     rax, SYS_READ_NUM
        mov     rdi, STDIN_FD
        syscall
%endmacro

; %1 = al/bl/eax
; %2 = bl/bx/ebx
; %3 = proc name
%macro __narrow_reg_range_q 3
        push    rbx
        mov     rbx, rax
        xor     rax, rax
        mov     %1, %2
        call    %3
        mov     %2, %1
        mov     rax, rbx
        pop     rbx
        ret
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
        syscall_write

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
        syscall_write
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

        movzx   rax, al
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
__dispbb:
        push    rax
        push    rcx
        push    rdx

        mov     rcx, 8
        mov     rdx, rax
__dispbbloop:
        shl     dl, 1
        jc      __dispbbone
        mov     al, "0"
        call    dispc
        loop    __dispbbloop
        jmp     __dispbbdone
__dispbbone:
        mov     al, "1"
        call    dispc
        loop    __dispbbloop

__dispbbdone:
        pop     rdx
        pop     rcx
        pop     rax
        ret

; al = input data
dispbb:
        push    rax
        call    __dispbb
        mov     al, "B"
        call    dispc
        pop     rax
        ret

; ax = input data
dispbw:
        push    rax
        push    rcx
        mov     rcx, 2
__dispbwloop:
        rol     ax, 8
        call    __dispbb
        loop    __dispbwloop
        mov     al, "B"
        call    dispc
        pop     rcx
        pop     rax
        ret

; eax = input data
dispbd:
        push    rax
        push    rcx
        mov     rcx, 4
__dispbdloop:
        rol     eax, 8
        call    __dispbb
        loop    __dispbdloop
        mov     al, "B"
        call    dispc
        pop     rcx
        pop     rax
        ret

; rax = input data
dispbq:
        push    rax
        push    rcx
        mov     rcx, 8
__dispbqloop:
        rol     rax, 8
        call    __dispbb
        loop    __dispbqloop
        mov     al, "B"
        call    dispc
        pop     rcx
        pop     rax
        ret

; al = input data
dispuib: __narrow_reg_range_q al, bl, dispuiq

; ax = input data
dispuiw: __narrow_reg_range_q ax, bx, dispuiq

; eax = input data
dispuid: __narrow_reg_range_q eax, ebx, dispuiq

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
        push    rdi
        push    rsi
        push    rdx
        push    rcx
        
        push    rax
        mov     rsi, rsp
        mov     rdx, 1
        syscall_read
        pop     rax

        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
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
        syscall_read
        
        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        ret

; al = input unsigned int
readuib: __narrow_reg_range_q al, bl, readuiq

; ax = input unsigned int
readuiw: __narrow_reg_range_q ax, bx, readuiq

; eax = input unsigned int
readuid: __narrow_reg_range_q eax, ebx, readuiq

; rax = input unsigned int
readuiq:
        push    rbx
        push    rdx
        push    rcx

        xor     rbx, rbx
        xor     rax, rax
        mov     rcx, 10

__rduiqreadch:
        call    readc
        cmp     al, "0"
        jb      __rduiqdone
        cmp     al, "9"
        ja      __rduiqdone
        sub     al, "0"
        xchg    rax, rbx
        mul     rcx
        add     rax, rbx
        xchg    rax, rbx
        jmp     __rduiqreadch

__rduiqdone:
        mov     rax, rbx
        pop     rcx
        pop     rdx
        pop     rbx
        ret

; input:        al = input character
; output:       al = uppercase
__toupper:
        cmp     al, "a"
        jb      __tocapdone
        cmp     al, "z"
        ja      __tocapdone
        sub     al, "a" - "A"
__tocapdone:
        ret

; al = input hex
readhb: __narrow_reg_range_q al, bl, readhq

; ax = input hex
readhw: __narrow_reg_range_q ax, bx, readhq

; eax = input hex
readhd: __narrow_reg_range_q eax, ebx, readhq

; rax = input hex
readhq:
        push    rbx
        xor     rbx, rbx

__rdhqreadc:
        call    readc
        call    __toupper
        cmp     al, "0"
        jb      __rdhqdone
        cmp     al, "9"
        ja      __rdhqalpha
        sub     al, "0"
        jmp     __rdhqupdrbx
__rdhqalpha:
        cmp     al, "A"
        jb      __rdhqdone
        cmp     al, "F"
        ja      __rdhqdone
        sub     al, "A"
        add     al, 10
__rdhqupdrbx:
        shl     rbx, 4
        add     bl, al
        jmp     __rdhqreadc
        
__rdhqdone:
        mov     rax, rbx
        pop     rbx
        ret
