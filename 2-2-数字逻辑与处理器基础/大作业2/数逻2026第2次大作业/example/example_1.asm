.data
    .a
    string: .asciiz "Hello World!\n"
    
.text
main:
    la $a0 string #载入字符串地址
    li $v0 4      #4代表打印字符串
    syscall       #执行系统调用

    li $v0 17     #17代表exit
    syscall       #执行系统调用
