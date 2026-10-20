.data

.text
.globl main

main:
    # 读入整数n
    li $v0, 5   # syscall 5：读入整数
    syscall 
    move $a0, $v0   # $a0保存参数n

    # 调用、打印fibonacci(n)
    jal fibonacci   # $v0存放返回值
    move $a0, $v0   # $a0存放要打印的整数
    li $v0, 1   # syscall 1：打印整数
    syscall

    # 程序结束
    li $v0, 10   # syscall 10：退出程序
    syscall
    

# int fibonacci(int n)部分
fibonacci:
    # if(n==0) return 0
    beq $a0, $zero, fib_zero

    # else if(n==1) return 1
    li $t0, 1   # $t0=1
    beq $a0, $t0, fib_one

    # 递归情形，先保存$ra、n和中间结果
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $a0, 4($sp)

    # 计算fibonacci(n-1)
    addi $a0, $a0, -1   # $a0=n-1
    jal fibonacci   # 调用fibonacci(n-1)
    sw $v0, 0($sp)   # 栈中保存fibonacci(n-1)结果

    # 计算fibonacci(n-2)
    lw $a0, 4($sp)   # 恢复原来的n
    addi $a0, $a0, -2   # $a0=n-2
    jal fibonacci   # 调用fibonacci(n-2)

    # fibonacci(n-1)+fibonacci(n-2)
    lw $t1, 0($sp)   # $t1=fibonacci(n-1)
    add $v0, $t1, $v0   # $v0=fibonacci(n-1)+fibonacci(n-2)

    # 恢复现场并返回
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

fib_zero:
    li $v0, 0   # 返回0
    jr $ra

fib_one:
    li $v0, 1   # 返回1
    jr $ra