# 寄存器分配说明：
# $s0：N，序列长度
# $s1：输入文件描述符
# $s2：数组a的首地址，其中a[1]存放在0($s2)
# $s3：二维数组dp的首地址
# $s4：dp每一行的长度，即N+1
# $s5：INF，表示一个很大的数
# $s6：外层循环变量i
# $s7：内层循环变量j
# $t0：临时变量，常用于计算下标或偏移
# $t1：临时变量，常用于计算下标或偏移
# $t2：临时变量，常用于计算下标或偏移
# $t3：临时变量，常用于保存地址或结果
# $t4：当前外层循环中的a[i-1]
# $t5：当前外层循环中的a[i]
# $t6：当前要访问的dp单元地址
# $t7：当前dp单元原值
# $t8：候选转移值，常为dp[i-1][j-1]
# $t9：条件判断结果
# $a0-$a2：syscall参数
# $v0：syscall编号或返回值

.data
input_file: .asciiz "test.dat"
.align 2
in_buff: .space 10000   # 输入数据缓冲区

.text
.globl main

main:
    #-------------------
    # 打开输入文件test.dat
    la $a0, input_file
    li $a1, 0
    li $a2, 0
    li $v0, 13   # syscall 13：打开文件
    syscall
    move $s1, $v0

    #-------------------
    # 读取输入数据、关闭输入文件
    move $a0, $s1
    la $a1, in_buff
    li $a2, 10000   # 最多读取10000 byte
    li $v0, 14   # syscall 14：读文件
    syscall

    move $a0, $s1
    li $v0, 16   # syscall 16：关闭文件
    syscall

    #-------------------
    # 读取N并确定数组a的首地址
    la $t0, in_buff
    lw $s0, 0($t0)   # $s0=N
    addi $s2, $t0, 4   # $s2指向a[1]

    #-------------------
    # 申请dp数组空间
    addi $s4, $s0, 1   # $s4=N+1
    mul $t0, $s4, $s4   # $t0=(N+1)*(N+1)
    sll $a0, $t0, 2   # $a0为申请的总字节数
    li $v0, 9   # syscall 9：申请空间
    syscall
    move $s3, $v0   # $s3保存dp首地址

    #-------------------
    # 初始化dp数组为INF
    li $s5, 0x7fffffff   # $s5=INF
    mul $t0, $s4, $s4   # $t0=dp元素总数
    li $t1, 0   # $t1作为计数器
    move $t2, $s3   # $t2指向当前dp单元

init_dp_loop:
    slt $t9, $t1, $t0   # 判断计数器是否小于元素总数
    beq $t9, $zero, init_dp_end 
    sw $s5, 0($t2)   # 当前dp单元赋值为INF
    addi $t2, $t2, 4
    addi $t1, $t1, 1
    j init_dp_loop

init_dp_end:
    #-------------------
    # 设置dp[1][1]=-1
    mul $t0, $s4, 1
    addi $t0, $t0, 1   # $t0=1*(N+1)+1
    sll $t0, $t0, 2
    add $t1, $s3, $t0   # $t1=&dp[1][1]
    li $t2, -1
    sw $t2, 0($t1)   # dp[1][1]=-1

    #-------------------
    # 外层循环：for i=2 to N
    li $s6, 2   # $s6=i=2

outer_loop:
    slt $t9, $s0, $s6   # 判断N<i是否成立
    bne $t9, $zero, outer_end

    addi $t0, $s6, -2
    sll $t0, $t0, 2   # $t0=(i-2)*4
    add $t1, $s2, $t0
    lw $t4, 0($t1)   # 读取a[i-1]，$t4=a[i-1]

    addi $t0, $s6, -1
    sll $t0, $t0, 2   # $t0=(i-1)*4
    add $t1, $s2, $t0
    lw $t5, 0($t1)   # 读取a[i]，$t5=a[i]

    #-------------------
    # 内层循环：for j=2 to i
    li $s7, 2   # $s7=j=2

inner_loop:
    slt $t9, $s6, $s7   # 判断i<j是否成立
    bne $t9, $zero, inner_end

    #-------------------
    # 读取dp[i-1][j-1]
    addi $t0, $s6, -1   # $t0=i-1
    mul $t0, $t0, $s4   # $t0=(i-1)*(N+1)
    addi $t1, $s7, -1   # $t1=j-1
    add $t0, $t0, $t1   # $t0=(i-1)*(N+1)+(j-1)
    sll $t0, $t0, 2
    add $t6, $s3, $t0
    lw $t8, 0($t6)   # $t8=dp[i-1][j-1]

    #-------------------
    # if a[i-1]<a[i]
    # dp[i][j]=min(dp[i][j],dp[i-1][j-1])
    
    slt $t9, $t4, $t5   # 判断是否a[i-1]<a[i]
    beq $t9, $zero, skip_first_if

    mul $t0, $s6, $s4   # $t0=i*(N+1)
    add $t0, $t0, $s7   # $t0=i*(N+1)+j
    sll $t0, $t0, 2 
    add $t6, $s3, $t0
    lw $t7, 0($t6)   # $t7=dp[i][j]

    slt $t9, $t8, $t7   # 判断候选值是否更小
    beq $t9, $zero, skip_first_if
    sw $t8, 0($t6)   # dp[i][j]=dp[i-1][j-1]

skip_first_if:
    #-------------------
    # if dp[i-1][j-1]<a[i]
    # dp[i][i-j+1]=min(dp[i][i-j+1],a[i-1])

    slt $t9, $t8, $t5   # 判断dp[i-1][j-1]<a[i]
    beq $t9, $zero, skip_second_if

    sub $t1, $s6, $s7   # $t1=i-j
    addi $t1, $t1, 1   # $t1=i-j+1
    mul $t0, $s6, $s4   # $t0=i*(N+1)
    add $t0, $t0, $t1   # $t0=i*(N+1)+(i-j+1)
    sll $t0, $t0, 2
    add $t6, $s3, $t0
    lw $t7, 0($t6)   # $t7=dp[i][i-j+1]

    slt $t9, $t4, $t7   # 判断a[i-1]是否更小
    beq $t9, $zero, skip_second_if
    sw $t4, 0($t6)   # dp[i][i-j+1]=a[i-1]

skip_second_if:
    addi $s7, $s7, 1   # j++
    j inner_loop

inner_end:
    addi $s6, $s6, 1   # i++
    j outer_loop

outer_end:
    #-------------------
    # 检查dp[N][N/2]是否小于INF
    srl $t1, $s0, 1   # $t1=N/2
    mul $t0, $s0, $s4   # $t0=N*(N+1)
    add $t0, $t0, $t1   # $t0=N*(N+1)+N/2
    sll $t0, $t0, 2
    add $t2, $s3, $t0
    lw $t3, 0($t2)   # $t3=dp[N][N/2]

    slt $t9, $t3, $s5   # 判断dp[N][N/2]<INF
    beq $t9, $zero, output_zero

output_one:
    #-------------------
    # 输出1
    li $a0, 1   # $a0=1
    li $v0, 1   # syscall 1：打印整数
    syscall
    j program_end

output_zero:
    #-------------------
    # 输出0
    li $a0, 0   # $a0=0
    li $v0, 1   # syscall 1：打印整数
    syscall

program_end:
    #-------------------
    # 程序结束
    li $v0, 10   # syscall 10：退出程序
    syscall
