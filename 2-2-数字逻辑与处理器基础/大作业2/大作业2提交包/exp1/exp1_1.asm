.data
buffer: .space 8   # 存放两个int，共8 byte
input_file: .asciiz "a.in"   # 输入文件名
output_file: .asciiz "a.out"   # 输出文件名

.text
.globl main

main:
    # 打开输入文件a.in
    la $a0, input_file
    li $a1, 0   # flag=0，表示只读
    li $a2, 0
    li $v0, 13   # syscall 13：打开文件
    syscall
    move $s0, $v0

    # 从a.in中读取两个整数
    move $a0, $s0
    la $a1, buffer
    li $a2, 8   # 读取8 byte
    li $v0, 14   # syscall 14：读文件
    syscall   # 读文件内容到buffer

    # 关闭输入文件
    move $a0, $s0
    li $v0, 16   # syscall 16：关闭文件
    syscall

    # 打开输出文件a.out
    la $a0, output_file
    li $a1, 1   # flag=1，表示只写
    li $a2, 0
    li $v0, 13   # syscall 13：打开文件
    syscall
    move $s1, $v0 

    # 将两个整数写入a.out
    move $a0, $s1
    la $a1, buffer
    li $a2, 8   # 写入8 byte
    li $v0, 15   # syscall 15：写文件
    syscall   # 将buffer内容写入文件

    # 关闭输出文件
    move $a0, $s1
    li $v0, 16   # syscall 16：关闭文件
    syscall   # 关闭输出文件

    # 从键盘输入整数i，计算并打印i=i+10
    li $v0, 5   # syscall 5：读入整数
    syscall
    move $t0, $v0   # $t0保存输入的i
    addi $t0, $t0, 10
    move $a0, $t0   # $a0存放要打印的整数
    li $v0, 1   # syscall 1：打印整数
    syscall

    # 结束程序
    li $v0, 10   # syscall 10：退出程序
    syscall
