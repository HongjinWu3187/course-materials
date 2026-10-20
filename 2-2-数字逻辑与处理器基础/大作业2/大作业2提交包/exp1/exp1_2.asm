.data

.text
.globl main

main:
    # 读入整数i和j
    li $v0, 5   # syscall 5：读入整数
    syscall
    move $t0, $v0   # $t0保存i
    li $v0, 5
    syscall
    move $t1, $v0   # $t1保存j

    # i=-i
    sub $t0, $zero, $t0

    # if(j<0) j=-j
    bltz $t1, neg_j   # 若j<0，跳转到neg_j取绝对值
    j init_loop   # 否则进入循环初始化

neg_j:
    sub $t1, $zero, $t1   # $t1=-j，即取绝对值

init_loop:
    li $t2, 0   # 初始化temp=0，$t2保存temp

for_loop:
    # 判断循环条件
    slt $t3, $t2, $t1   # 若temp<j，则$t3=1
    beq $t3, $zero, end_loop   # 若temp>=j，结束循环

    # 循环过程
    addi $t0, $t0, 1   # i+=1
    addi $t2, $t2, 1   # ++temp
    j for_loop

end_loop:
    # printf("%d",i)
    move $a0, $t0
    li $v0, 1   # syscall 1：打印整数
    syscall

    # 将最终结果存入$v0
    move $v0, $t0