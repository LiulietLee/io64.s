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

; %1 = al/ax/eax/rax
; %2 = dl/dx/edx/rdx
; %3 = proc name
%macro  __dispsi_reg 3
        push    rax
        push    rdx
        rol     %1, 1
        jnc     __dispsiproc%3
        mov     %2, %1
        mov     al, "-"
        call    dispc
        mov     %1, %2
        ror     %1, 1
        neg     %1
        rol     %1, 1
__dispsiproc%3:
        ror     %1, 1
        call    %3
        pop     rdx
        pop     rax
        ret
%endmacro

; al = input data
dispsib: __dispsi_reg al, dl, dispuib

; ax = input data
dispsiw: __dispsi_reg ax, dx, dispuiw

; eax = input data
dispsid: __dispsi_reg eax, edx, dispuid

; rax = input data
dispsiq: __dispsi_reg rax, rdx, dispuiq

; ax = c1 c2
%macro  __disp2c 0
        call    dispc
        xchg    al, ah
        call    dispc
        xchg    al, ah
%endmacro

; %1 = jcond
; %2 = msg
%macro  __disprf 2
        mov     ax, %2
        __disp2c
        %1      __disprfone%1
        mov     ax, "=0"
        __disp2c
        jmp     __disprfend%1
__disprfone%1:
        mov     ax, "=1"
        __disp2c
__disprfend%1:
        call    dispcrlf
%endmacro

disprf:
        push    rax
        __disprf        jc, "CF"
        __disprf        jo, "OF"
        __disprf        jp, "PF"
        __disprf        jz, "ZF"
        __disprf        js, "SF"
        pop     rax
        ret

; eax = c1c2c3c4
%macro  __disp4c 0
        __disp2c
        rol     eax, 16
        __disp2c
        rol     eax, 16
%endmacro

; %1 = rax/eax
; %2 = reg
; %3 = str
; %4 = disphq/disphd
%macro  __disprq_reg 4
        mov     %1, %3
        __disp4c
        mov     %1, %2
        call    %4
        mov     %1, 9
        call    dispc
%endmacro

disprq:
        push    rax

        push    rax
        mov     rax, "RAX="
        __disp4c
        pop     rax
        call    disphq
        mov     rax, 9
        call    dispc

        __disprq_reg    rax, rbx, "RBX=", disphq
        call    dispcrlf

        __disprq_reg    rax, rcx, "RCX=", disphq
        __disprq_reg    rax, rdx, "RDX=", disphq
        call    dispcrlf

        __disprq_reg    rax, rsi, "RSI=", disphq
        __disprq_reg    rax, rdi, "RDI=", disphq
        call    dispcrlf

        __disprq_reg    rax, rbp, "RBP=", disphq
        __disprq_reg    rax, rsp, "RSP=", disphq
        call    dispcrlf

        pop     rax
        ret

disprd:
        push    rax

        push    rax
        mov     rax, "EAX="
        __disp4c
        pop     rax
        call    disphd
        mov     rax, 9
        call    dispc

        __disprq_reg    eax, ebx, "EBX=", disphd
        __disprq_reg    eax, ecx, "ECX=", disphd
        __disprq_reg    eax, edx, "EDX=", disphd
        call    dispcrlf

        __disprq_reg    eax, esi, "ESI=", disphd
        __disprq_reg    eax, edi, "EDI=", disphd
        __disprq_reg    eax, ebp, "EBP=", disphd
        __disprq_reg    eax, esp, "ESP=", disphd
        call    dispcrlf

        pop     rax
        ret

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

; al = input binary
readbb: __narrow_reg_range_q al, bl, readbq

; ax = input binary
readbw: __narrow_reg_range_q ax, bx, readbq

; eax = input binary
readbd: __narrow_reg_range_q eax, ebx, readbq

; rax = output binary
readbq:
        push    rdx

        xor     rdx, rdx
__rdbqreadc:
        call    readc
        cmp     al, "0"
        je      __rdbqzero
        cmp     al, "1"
        jne     __rdbqdone
        shl     rdx, 1
        or      rdx, 1
        jmp     __rdbqreadc
__rdbqzero:
        shl     rdx, 1
        jmp     __rdbqreadc

__rdbqdone:
        mov     rax, rdx
        pop     rdx
        ret

; al = input data
readsib: __narrow_reg_range_q al, bl, readsiq

; ax = input data
readsiw: __narrow_reg_range_q ax, bx, readsiq

; eax = input data
readsid: __narrow_reg_range_q eax, ebx, readsiq

; rax = input data
readsiq:
        push    rbx
        push    rdx
        push    rcx
        push    rdi

        xor     rbx, rbx
        xor     rax, rax
        xor     rdi, rdi
        mov     rcx, 10

        call    readc
        cmp     al, "-"
        jne     __rdsiqnoneg
        mov     rdi, 1
__rdsiqreadch:
        call    readc
__rdsiqnoneg:
        cmp     al, "0"
        jb      __rdsiqdone
        cmp     al, "9"
        ja      __rdsiqdone
        sub     al, "0"
        xchg    rax, rbx
        mul     rcx
        add     rax, rbx
        xchg    rax, rbx
        jmp     __rdsiqreadch

__rdsiqdone:
        mov     rax, rbx
        cmp     rdi, 1
        jne     __rdsiqend
        neg     rax
__rdsiqend:
        pop     rdi
        pop     rcx
        pop     rdx
        pop     rbx
        ret

_main:
        call    start
        ret
