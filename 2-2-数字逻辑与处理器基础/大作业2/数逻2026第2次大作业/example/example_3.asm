.text
main:
    li $v0 5      #5代表读入一个整数
    syscall       #ִ执行系统调用
    move $a0 $v0  #将读入的整数作为第一个参数
    li $v0 5      #5代表读入一个整数
    syscall       #ִ执行系统调用
    move $a1 $v0  #将读入的整数作为第二个参数
    
    jal product   #跳转到子过程product
    move $a0 $v0  #将返回值赋值给$a0
    li $v0 1      #1代表打印一个整数
    syscall       #ִ执行系统调用
    
    li $v0 17     #17代表exit
    syscall       #ִ执行系统调用

product:
    move $t0 $a0  #将第一个参数赋值给t0作为累加值
    move $t1 $a1  #将第二个参数赋值给t1作为计数器
    move $t2 $zero#结果清零
    addi $sp $sp -16 #移动栈指针到栈顶
    sw $t0 12($sp)   #存入本地变量t0
    sw $t1 8($sp)    #存入本地变量t1
    sw $t2 4($sp)    #存入本地变量t2
    sw $ra 0($sp)    #存入过程返回地址
    loop: add $t2 $t2 $t0  #结果累计t0
          sw $t2 4($sp)    #存入本地变量t2
          addi $t1 $t1 -1  #计数器减一
          sw $t1 8($sp)    #存入本地变量t2
          bnez $t1 loop    #如果计数器不为0循环继续
    move $v0 $t2  #将结果赋给返回值
    lw $ra 0($sp) #出栈过程返回地址
    jr $ra        #跳转回上一级过程
    
