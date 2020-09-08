# io64.s
> io32.inc 在 macOS 下的 64 位替代版本

## 前置条件

```bash
brew install nasm gdb
```

## 程序框架

除了 MASM 和 NASM 的固有区别之外，基本与 io32.inc 一致。

```assembly
%include        "io64.s"

section .data

; 数据段内容

section .text

; 以下代码段内容

_main:  ; 必须以 _main 作为程序入口
        
        ; 主程序内容

        exit    0
```

举一个 Hello World 的例子：

```assembly
%include        "io64.s"

section .data

msg:    db      "Hi there", 10, 0

section .text

_main:
        mov     rax, msg        ; NASM 中没有 `offset` 关键字
        call    dispmsg
        exit    0
```

## 编译运行方式

1. 将你的 asm 文件和 `make.sh`，`io64.s` 两个文件放在同一个文件夹下
2. 执行 `sh make.sh your_source_file.s`，没有错误的情况下编译出的可执行文件名为 `your_source_file`
3. 执行 `./your_source_file` 运行程序

## 子程序表

除了过程入口的部分寄存器需要换成 64 位之外，其他过程与 io32.inc 的版本使用方式一致。

### 输出程序

| 子程序名 | 入口 | 功能说明 |
|---------|-----|---------|
| dispmsg | rax = 字符串首地址 | 显示一串字符，以 0 结尾 |
| dispc | al = 要输出的字符 | 显示 al 中的内容对应的 ASCII 字符 |
| dispcrlf | | 显示换行，相当于 C 中的 `puts("")` |
| disphb | al = 8 位数据 | 以 16 进制显示 al 中的内容 |
| disphw | ax = 16 位数据 | 以 16 进制显示 ax 中的内容 |
| disphd | eax = 32 位数据 | 以 16 进制显示 eax 中的内容 |
| disphq | rax = 64 位数据 | 以 16 进制显示 rax 中的内容 |
| dispuib | al = 8 位数据 | 以无符号十进制显示 al 中的内容 |
| dispuiw | ax = 16 位数据 | 以无符号十进制显示 ax 中的内容 |
| dispuid | eax = 32 位数据 | 以无符号十进制显示 eax 中的内容 |
| dispuiq | rax = 64 位数据 | 以无符号十进制显示 rax 中的内容 |
| disprq | | 以 16 进制显示八个 64 位通用寄存器的内容 |
| disprd | | 以 16 进制显示八个 32 位通用寄存器的内容 |

**备注**
- 上面的所有输入输出功能均通过系统功能调用指令 syscall 实现
- 对于 dispcrlf，理论上来说 macOS 下换行只需要 lf 不需要 cr，但为了与 io32.inc 保持一致所以依然使用 dispcrlf 这个名字
- 对于 32 位以下寄存器内容的显示程序 disprw 和 disprb 并未实现（因为懒）