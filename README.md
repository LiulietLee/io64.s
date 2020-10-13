# io64.s
> MASM io32.inc 在 macOS 下的 64 位替代版本

## 前置条件

```bash
brew install nasm
```

## 程序框架

除了 MASM 和 NASM 的固有区别之外，基本与 io32.inc 一致。

```assembly
%include        "io64.s"

section .data

; 数据段内容

section .text

; 以下代码段内容

start:
        
        ; 主程序内容

        exit    0
```

举一个 Hello World 的例子：

```assembly
%include        "io64.s"

section .data

msg:    db      "Hi there", 10, 0

section .text

start:
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

| 过程名 | 入口 | 功能说明 |
|---------|-----|---------|
| dispmsg | rax = 字符串首地址 | 显示一串字符，以 0 结尾 |
| dispc | al = 要输出的字符 | 显示 al 中的内容对应的 ASCII 字符 |
| dispcrlf | | 显示换行，相当于 C 中的 `puts("")` |
| dispbb | al = 8 位数据 | 以二进制显示 al 中的内容 |
| dispbw | ax = 16 位数据 | 以二进制显示 ax 中的内容 |
| dispbd | eax = 32 位数据 | 以二进制显示 eax 中的内容 |
| dispbq | rax = 64 位数据 | 以二进制显示 rax 中的内容 |
| disphb | al = 8 位数据 | 以 16 进制显示 al 中的内容 |
| disphw | ax = 16 位数据 | 以 16 进制显示 ax 中的内容 |
| disphd | eax = 32 位数据 | 以 16 进制显示 eax 中的内容 |
| disphq | rax = 64 位数据 | 以 16 进制显示 rax 中的内容 |
| dispuib | al = 8 位数据 | 以无符号十进制显示 al 中的内容 |
| dispuiw | ax = 16 位数据 | 以无符号十进制显示 ax 中的内容 |
| dispuid | eax = 32 位数据 | 以无符号十进制显示 eax 中的内容 |
| dispuiq | rax = 64 位数据 | 以无符号十进制显示 rax 中的内容 |
| dispsib | al = 8 位数据 | 以有符号十进制显示 al 中的内容 |
| dispsiw | ax = 16 位数据 | 以有符号十进制显示 ax 中的内容 |
| dispsid | eax = 32 位数据 | 以有符号十进制显示 eax 中的内容 |
| dispsiq | rax = 64 位数据 | 以有符号十进制显示 rax 中的内容 |
| disprq | | 以 16 进制显示八个 64 位通用寄存器的内容 |
| disprd | | 以 16 进制显示八个 32 位通用寄存器的内容 |
| disprf | | 显示标志位 |

### 输出程序

| 过程名 | 入口 | 出口 | 功能说明 |
|--------|-----|------|---------|
| readmsg | rax = 缓冲区首地址 | rax = 输入字符个数 | 从键盘输入一串字符并存入缓冲区中 |
| readc | | al = 输入字符 | 从键盘输入一个字符到 al |
| readuib | | al = 8 位数据 | 从键盘输入一个无符号十进制数字到 al |
| readuiw | | ax = 16 位数据 | 从键盘输入一个无符号十进制数字到 ax |
| readuid | | eax = 32 位数据 | 从键盘输入一个无符号十进制数字到 eax |
| readuiq | | rax = 64 位数据 | 从键盘输入一个无符号十进制数字到 rax |
| readsib | | al = 8 位数据 | 从键盘输入一个有符号十进制数字到 al |
| readsiw | | ax = 16 位数据 | 从键盘输入一个有符号十进制数字到 ax |
| readsid | | eax = 32 位数据 | 从键盘输入一个有符号十进制数字到 eax |
| readsiq | | rax = 64 位数据 | 从键盘输入一个有符号十进制数字到 rax |
| readbb | | al = 8 位数据 | 从键盘输入二进制数到 al |
| readbw | | ax = 16 位数据 | 从键盘输入二进制数到 ax |
| readbd | | eax = 32 位数据 | 从键盘输入二进制数到 eax |
| readbq | | rax = 64 位数据 | 从键盘输入二进制数到 rax |
| readhb | | al = 8 位数据 | 从键盘输入 16 进制数到 al |
| readhw | | ax = 16 位数据 | 从键盘输入 16 进制数到 ax |
| readhd | | eax = 32 位数据 | 从键盘输入 16 进制数到 eax |
| readhq | | rax = 64 位数据 | 从键盘输入 16 进制数到 rax |

**备注**
- 上面的所有输入输出功能均通过系统功能调用指令 syscall 实现
- 对于 dispcrlf，理论上来说 macOS 下换行只需要 lf 不需要 cr，但为了与 io32.inc 保持一致所以依然使用 dispcrlf 这个名字

### 副产物

> 在写上面那些程序的时候顺带写的一些帮助程序，同样可以直接使用

| 宏名 | 入口 | 出口 | 功能说明 |
|----|-----|-----|---------|
| exit | 一个立即数 | | 退出程序，通常用法是在程序最后写上 `exit 0` |
| syscall_write | | | 调用 write 系统功能 |
| syscall_read | | | 调用 read 系统功能 |
| __disp2c | ax = "c1c2" | | 显示两个字符 c1c2 |
| __disp4c | eax = "c1c2c3c4" | | 显示四个字符 c1c2c3c4 |

| 过程名 | 入口 | 出口 | 功能说明 |
|---------|-----|-----|---------|
| __strlen | rax = 字符串地址 | rax = 字符串长度 | 计算一个以 0 结尾的字符串的长度 |
| __toupper | al = 字符 | al = 大写字符 | 将小写字母转换为大写字母，对非小写字母之外的字符不作处理 |
