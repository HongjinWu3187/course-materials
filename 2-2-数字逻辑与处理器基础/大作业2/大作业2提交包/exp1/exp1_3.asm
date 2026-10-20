.data

.text
.globl main

main:
    # 读入数组长度n
    li $v0, 5   # syscall 5：读入整数
    syscall
    move $s0, $v0   # $s0保存n

    # a=new int[n]
    sll $a0, $s0, 2   # $申请字节数a0=n*4
    li $v0, 9   # syscall 9：申请空间
    syscall   # 申请空间首地址返回到$v0
    move $s1, $v0   # $s1保存数组首地址

    # 循环读入n个数据
    li $t0, 0   # $t0充当计数器i

read_loop:
    slt $t1, $t0, $s0   # 判断i<n是否成立
    beq $t1, $zero, read_end

    sll $t2, $t0, 2
    add $t3, $s1, $t2   # $t3=&a[i]

    li $v0, 5   # syscall 5：读入整数
    syscall
    sw $v0, 0($t3)   # 输入值存入内存

    addi $t0, $t0, 1   # i++
    j read_loop

read_end:
    # 为下一循环做准备
    li $t0, 0   # $t0充当下一循环计数器i
    addi $t4, $s0, 1   # $t4=n+1
    srl $t4, $t4, 1   # $t4=(n+1)/2

reverse_loop:
    slt $t1, $t0, $t4   # 判断i<(n+1)/2是否成立
    beq $t1, $zero, reverse_end

    # 计算&a[i]
    sll $t2, $t0, 2
    add $t3, $s1, $t2   # $t3=&a[i]

    # 计算&a[n-i-1]
    sub $t5, $s0, $t0
    addi $t5, $t5, -1   # $t5=n-i-1
    sll $t6, $t5, 2
    add $t7, $s1, $t6   # $t7=&a[n-i-1]

    # t=a[i]+1
    lw $t8, 0($t3)
    addi $t8, $t8, 1

    # a[i]=a[n-i-1]+1
    lw $t9, 0($t7)
    addi $t9, $t9, 1   # $t9=a[n-i-1]+1
    sw $t9, 0($t3)   # a[i]=a[n-i-1]+1

    # a[n-i-1]=t
    sw $t8, 0($t7)

    addi $t0, $t0, 1   # i++
    j reverse_loop

reverse_end:
    # 循环输出数组数据
    li $t0, 0   # $t0充当计数器i

print_loop:
    slt $t1, $t0, $s0   # 判断i<n是否成立
    beq $t1, $zero, print_end

    sll $t2, $t0, 2
    add $t3, $s1, $t2   # $t3=&a[i]
    lw $a0, 0($t3)   # $a0=a[i]

    li $v0, 1   # syscall 1：打印整数
    syscall

    addi $t0, $t0, 1   # i++
    j print_loop

print_end:
    # return 0
    li $v0, 10   # syscall 10：退出程序
    syscall 