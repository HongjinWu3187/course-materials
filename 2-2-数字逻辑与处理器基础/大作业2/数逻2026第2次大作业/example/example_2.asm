 .data
    stringz: .asciiz "Hello World!\n"
    string: .ascii "Hello World!\n"
    #让array对齐到4byte边界
    .align 4  #没有这句话可能会出错
    array: .space  512
    #以下常数数组会自动对齐到对应边界
    barray: .byte  1,2,3,4
    harray: .half  1,2,3,4
    warray: .word  1,2,3,4
    
    
.text
main:
    la $a0 stringz #载入字符串地址
    li $v0 4      #4代表打印字符串
    syscall       #执行系统调用
    
    la $a0 string #载入字符串地址
    li $v0 4      #4代表打印字符串
    syscall       #执行系统调用
    
    la $t0 barray #载入byte数组地址
    lb $a0 0($t0) #读取barray[0]
    li $v0 1      #1代表打印一个整数
    syscall       #打印array[0]的数据
    lb $a0 1($t0) #读取barray[1]
    li $v0 1      #1代表打印一个整数
    syscall       #打印array[0]的数据
    lb $a0 2($t0) #读取barray[2]
    li $v0 1      #1代表打印一个整数
    syscall       #打印array[0]的数据
    lb $a0 3($t0) #读取barray[3]
    li $v0 1      #1代表打印一个整数
    syscall       #打印array[0]的数据
    
    li $a0 10 #10代表换行符'\n'
    li $v0 11 #11代表打印字符
    syscall   #换个行
    
    la $t0 array #载入array的地址
    li $t1 123   
    sw $t1 0($t0) #在array[0]的位置存入123
    lw $a0 0($t0) #读取array[0]的数据
    li $v0 1      #1代表打印一个整数
    syscall       #打印array[0]的数据
    
    
    li $v0 17     #17代表exit
    syscall       #执行系统调用
