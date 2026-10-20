# 寄存器分配说明：
# $s0：main中保存n；dfs中保存当前结点u
# $s1：main中保存文件描述符；dfs中保存父结点parent
# $s2：main中保存边编号edge_cnt；dfs中保存当前结点到父结点的边长edge_to_parent
# $s3：main中保存输入缓冲区指针；dfs中保存sons，即当前结点的儿子数量
# $s4：dfs中保存当前扫描的边编号e
# $s5：dfs中保存当前邻接点v
# $s6：dfs中保存当前边长len
# $s7：dfs中保存临时地址或临时结果
# $t0-$t9：临时变量，用于地址计算、循环计数、比较结果
# $a0-$a2：syscall参数；dfs调用参数u、parent、edge_to_parent
# $v0：syscall编号、syscall返回值、函数返回值
# $ra：过程返回地址，递归调用时压栈保存
# $sp：栈指针，用于递归dfs保存现场

.data
input_file: .asciiz "test.dat"
.align 2
in_buff: .space 50000   # 输入数据缓冲区
head: .space 8004   # head[i]表示结点i的第一条边编号
to_arr: .space 20000   # to_arr[e]表示边e指向的结点
len_arr: .space 20000   # len_arr[e]表示边e的边长
next_arr: .space 20000   # next_arr[e]表示同一起点的下一条边
f_arr: .space 8004   # f[i]表示子树内最少放大器数量
g_arr: .space 8004   # g[i]表示子树向上所需的最大信号消耗
h_val: .word 0   # 信号初始强度h

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
    move $s1, $v0   # $s1保存输入文件描述符

    #-------------------
    # 读取二进制输入数据
    move $a0, $s1
    la $a1, in_buff
    li $a2, 50000   # 最多读取50000byte
    li $v0, 14   # syscall 14：读文件
    syscall   # 将test.dat内容读入in_buff

    #-------------------
    # 关闭输入文件
    move $a0, $s1
    li $v0, 16   # syscall 16：关闭文件
    syscall

    #-------------------
    # 读取n并初始化数组
    la $s3, in_buff   # $s3指向输入缓冲区开头
    lw $s0, 0($s3)   # $s0=n
    addi $s3, $s3, 4   # 输入指针后移
    
    li $t0, 0   # $t0作为初始化下标i

init_loop:
    slt $t9, $s0, $t0   # 判断n<i是否成立
    bne $t9, $zero, init_end

    sll $t1, $t0, 2   # $t1=i*4

    la $t2, head
    add $t3, $t2, $t1   # $t3=&head[i]
    sw $zero, 0($t3)   # head[i]=0

    la $t2, f_arr
    add $t3, $t2, $t1   # $t3=&f[i]
    sw $zero, 0($t3)   # f[i]=0

    la $t2, g_arr
    add $t3, $t2, $t1   # $t3=&g[i]
    sw $zero, 0($t3)   # g[i]=0

    addi $t0, $t0, 1   # i++
    j init_loop

init_end:
    #-------------------
    # 建立邻接表
    # 输入第i行：k v1 len1 v2 len2 ...
    li $s2, 0   # $s2=edge_cnt=0
    li $t0, 1   # $t0=i=1

build_node_loop:
    slt $t9, $s0, $t0   # 判断n<i是否成立
    bne $t9, $zero, build_end

    lw $t1, 0($s3)   # $t1=k
    addi $s3, $s3, 4   # 输入指针后移
    li $t2, 0   # $t2=当前结点已读边数

build_edge_loop:
    slt $t9, $t2, $t1   # 判断已读边数<k是否成立
    beq $t9, $zero, build_edge_end

    lw $t3, 0($s3)   # $t3=v
    addi $s3, $s3, 4   # 输入指针后移
    lw $t4, 0($s3)   # $t4=len
    addi $s3, $s3, 4   # 输入指针后移

    addi $s2, $s2, 1   # edge_cnt++

    sll $t5, $s2, 2   # $t5=edge_cnt*4

    la $t6, to_arr
    add $t7, $t6, $t5   # $t7=&to_arr[edge_cnt]
    sw $t3, 0($t7)   # to_arr[edge_cnt]=v

    la $t6, len_arr
    add $t7, $t6, $t5   # $t7=&len_arr[edge_cnt]
    sw $t4, 0($t7)   # len_arr[edge_cnt]=len

    sll $t6, $t0, 2   # $t6=i*4
    la $t7, head
    add $t8, $t7, $t6   # $t8=&head[i]
    lw $t9, 0($t8)   # $t9=head[i]

    la $t6, next_arr
    add $t7, $t6, $t5   # $t7=&next_arr[edge_cnt]
    sw $t9, 0($t7)   # next_arr[edge_cnt]=head[i]

    sw $s2, 0($t8)   # head[i]=edge_cnt

    addi $t2, $t2, 1   # 已读边数加1
    j build_edge_loop

build_edge_end:
    addi $t0, $t0, 1   # i++
    j build_node_loop

build_end:
    #-------------------
    # 读取信号强度h
    lw $t0, 0($s3)   # $t0=h
    la $t1, h_val
    sw $t0, 0($t1)   # h_val=h

    #-------------------
    # 调用dfs(1,0,0)
    li $a0, 1   # $a0=当前结点u=1
    li $a1, 0   # $a1=父结点parent=0
    li $a2, 0   # $a2=到父结点的边长为0
    jal dfs   # 从服务器结点1开始DFS

    #-------------------
    # 输出f[1]
    la $t0, f_arr   # $t0=f首地址
    lw $a0, 4($t0)   # $a0=f[1]
    li $v0, 1   # syscall 1：打印整数
    syscall

    #-------------------
    # 程序结束
    li $v0, 10   # syscall 10：退出程序
    syscall


#-------------------
# dfs(u,parent,edge_to_parent)
# 参数：$a0=u, $a1=parent, $a2=edge_to_parent
# 功能：递归计算f[u]和g[u]
dfs:
    #-------------------
    # 建立栈帧并保存现场
    addi $sp, $sp, -36
    sw $s7, 0($sp)
    sw $s6, 4($sp)
    sw $s5, 8($sp)
    sw $s4, 12($sp)
    sw $s3, 16($sp)
    sw $s2, 20($sp)
    sw $s1, 24($sp)
    sw $s0, 28($sp)
    sw $ra, 32($sp)

    move $s0, $a0   # $s0=u
    move $s1, $a1   # $s1=parent
    move $s2, $a2   # $s2=edge_to_parent
    li $s3, 0   # sons=0

    #-------------------
    # f[u]=0，g[u]=0
    sll $t0, $s0, 2   # $t0=u*4

    la $t1, f_arr
    add $t2, $t1, $t0   # $t2=&f[u]
    sw $zero, 0($t2)   # f[u]=0

    la $t1, g_arr
    add $t2, $t1, $t0   # $t2=&g[u]
    sw $zero, 0($t2)   # g[u]=0

    #-------------------
    # 取head[u]，开始遍历邻接边
    la $t1, head
    add $t2, $t1, $t0   # $t2=&head[u]
    lw $s4, 0($t2)   # $s4=e=head[u]

dfs_edge_loop:
    beq $s4, $zero, dfs_edge_end

    #-------------------
    # 读取当前边的v和len
    sll $t0, $s4, 2   # $t0=e*4

    la $t1, to_arr
    add $t2, $t1, $t0   # $t2=&to_arr[e]
    lw $s5, 0($t2)   # $s5=v

    la $t1, len_arr
    add $t2, $t1, $t0   # $t2=&len_arr[e]
    lw $s6, 0($t2)   # $s6=len

    #-------------------
    # if(v==parent) continue
    beq $s5, $s1, dfs_next_edge

    #-------------------
    # if(len>=h) output 0 and exit
    la $t1, h_val
    lw $t2, 0($t1)   # $t2=h
    slt $t3, $s6, $t2
    beq $t3, $zero, impossible   # 若len>=h，impossible

    #-------------------
    # dfs(v,u,len)
    move $a0, $s5   # $a0=v
    move $a1, $s0   # $a1=u
    move $a2, $s6   # $a2=len
    jal dfs   # 递归处理子结点v

    #-------------------
    # g[u]=max(g[u],g[v]+len)
    sll $t0, $s5, 2   # $t0=v*4
    la $t1, g_arr
    add $t2, $t1, $t0
    lw $t3, 0($t2)   # $t3=g[v]
    add $t3, $t3, $s6   # $t3=g[v]+len

    sll $t0, $s0, 2   # $t0=u*4
    la $t1, g_arr
    add $t2, $t1, $t0
    lw $t4, 0($t2)   # $t4=g[u]

    slt $t5, $t4, $t3   # 判断g[u]<g[v]+len
    beq $t5, $zero, skip_update_g
    sw $t3, 0($t2)   # g[u]=g[v]+len

skip_update_g:
    #-------------------
    # f[u]+=f[v]
    sll $t0, $s5, 2   # $t0=v*4
    la $t1, f_arr
    add $t2, $t1, $t0
    lw $t3, 0($t2)   # $t3=f[v]

    sll $t0, $s0, 2   # $t0=u*4
    la $t1, f_arr
    add $t2, $t1, $t0
    lw $t4, 0($t2)   # $t4=f[u]
    add $t4, $t4, $t3   # $t4=f[u]+f[v]
    sw $t4, 0($t2)   # f[u]+=f[v]

    #-------------------
    # sons++
    addi $s3, $s3, 1

dfs_next_edge:
    #-------------------
    # e=next_arr[e]
    sll $t0, $s4, 2   # $t0=e*4
    la $t1, next_arr
    add $t2, $t1, $t0
    lw $s4, 0($t2)   # e=next_arr[e]
    j dfs_edge_loop   # 继续遍历邻接边

dfs_edge_end:
    #-------------------
    # if(sons==0) leaf
    beq $s3, $zero, dfs_leaf   # 若sons==0，当前结点为叶子

    #-------------------
    # else if(u!=root and g[u]+edge_to_parent>h)
    li $t0, 1   # $t0=1，即root编号
    beq $s0, $t0, dfs_return   # 若u是root，不在root处安装放大器

    sll $t0, $s0, 2   # $t0=u*4
    la $t1, g_arr
    add $t2, $t1, $t0
    lw $t3, 0($t2)   # $t3=g[u]
    add $t3, $t3, $s2   # $t3=g[u]+edge_to_parent

    la $t4, h_val
    lw $t5, 0($t4)   # $t5=h
    slt $t6, $t5, $t3   # 判断h<g[u]+edge_to_parent
    beq $t6, $zero, dfs_return   # 若不超过h，不需要放大器

    #-------------------
    # f[u]++，g[u]=1
    la $t1, f_arr
    add $t2, $t1, $t0
    lw $t3, 0($t2)   # $t3=f[u]
    addi $t3, $t3, 1   # f[u]++
    sw $t3, 0($t2)   # 保存f[u]

    la $t1, g_arr
    add $t2, $t1, $t0   # $t2=&g[u]
    li $t3, 1
    sw $t3, 0($t2)   # g[u]=1
    j dfs_return   # 返回调用者

dfs_leaf:
    #-------------------
    # 叶子结点：f[u]=0，g[u]=1
    sll $t0, $s0, 2   # $t0=u*4

    la $t1, f_arr
    add $t2, $t1, $t0   # $t2=&f[u]
    sw $zero, 0($t2)   # f[u]=0

    la $t1, g_arr
    add $t2, $t1, $t0   # $t2=&g[u]
    li $t3, 1
    sw $t3, 0($t2)   # g[u]=1

dfs_return:
    #-------------------
    # 恢复现场并返回
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra


impossible:
    #-------------------
    # 不可能传遍全树，输出0并结束
    li $a0, 0   # $a0=0
    li $v0, 1   # syscall 1：打印整数
    syscall   # 输出0

    li $v0, 10   # syscall 10：退出程序
    syscall