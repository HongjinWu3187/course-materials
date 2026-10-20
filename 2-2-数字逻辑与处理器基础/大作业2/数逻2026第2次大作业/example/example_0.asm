.data
in_buff: .space 512
out_buff: .space 512
input_file: .asciiz "example.in"
output_file: .asciiz "example.out"
comma: .asciiz ", "
.text
la $a0, input_file #input_file 是一个字符串
li $a1, 0 #flag 0为读取 1为写入
li $a2, 0 #mode is ignored 设置为0就可以了
li $v0, 13 #13 为打开文件的 syscall 编号
syscall # 如果打开成功 ， 文件描述符返回到$v0中
 move $a0,$v0 # 将文件描述符载入到 $a0中
 la $a1, in_buff #in_buff 为数据暂存区
 li $a2, 512 #读取512个byte
 li $v0, 14 #14 为读取文件的 syscall 编号
 syscall
 li $v0 16 #16 为关闭文件的 syscall 编号
 syscall

#地址初始化，循环变量赋值为N
la $s0, in_buff
la $s1, out_buff
lw $s2, 0($s0)
li $t0, 0

#地址加4 循环变量减1
for: addi $s0, $s0, 4
addi $t0, $t0, 1
lw $t1, 0($s0)
sw $t1, 0($s1)
addi $s1, $s1, 4
#打印整数
move $a0, $t1
li $v0, 1
syscall
#打印逗号
la $a0, comma
li $v0, 4
syscall
bne $t0 $s2 for

la $a0, output_file #output_file 是一个字符串
li $a1, 1 #flag 0为读取 1为写入
li $a2, 0 #mode is ignored 设置为0就可以了
li $v0, 13 #13 为打开文件的 syscall 编号
syscall # 如果打开成功 ， 文件描述符返回到$v0中

move $a0,$v0 # 将文件描述符载入到 $a0中
la $a1, out_buff #in_buff 为数据暂存区
sll $s2 $s2 2
move $a2, $s2 #写入512个byte
li $v0, 15 #15 为写入文件的 syscall 编号
syscall
#此时$a0 中的文件描述符没变
#直接调用 syscall 16 关闭它
li $v0 16 #16 为关闭文件的 syscall 编号
syscall
