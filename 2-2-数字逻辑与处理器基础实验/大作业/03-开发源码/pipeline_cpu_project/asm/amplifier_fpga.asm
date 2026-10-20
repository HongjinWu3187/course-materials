# Memory layout, byte addresses:
#   0x0000  input word stream
#   0x0200  head[]
#   0x0600  to_arr[]
#   0x0a00  len_arr[]
#   0x0e00  next_arr[]
#   0x1200  f_arr[]
#   0x1600  g_arr[]
#   0x1a00  display_lut[16]
#   0x1b00  h_value
#   0x1b04  result
#   0x3ffc  stack top

.text
main:
    addiu $sp, $zero, 0x3ffc
    addiu $s3, $zero, 0x0000
    lw    $s0, 0($s3)
    addiu $s3, $s3, 4

    addiu $t0, $zero, 0
init_loop:
    slt   $t9, $s0, $t0
    bne   $t9, $zero, init_end
    sll   $t1, $t0, 2

    addiu $t2, $zero, 0x0200
    addu  $t3, $t2, $t1
    sw    $zero, 0($t3)

    addiu $t2, $zero, 0x1200
    addu  $t3, $t2, $t1
    sw    $zero, 0($t3)

    addiu $t2, $zero, 0x1600
    addu  $t3, $t2, $t1
    sw    $zero, 0($t3)

    addiu $t0, $t0, 1
    j     init_loop

init_end:
    addiu $s2, $zero, 0
    addiu $t0, $zero, 1

build_node_loop:
    slt   $t9, $s0, $t0
    bne   $t9, $zero, build_end

    lw    $t1, 0($s3)
    addiu $s3, $s3, 4
    addiu $t2, $zero, 0

build_edge_loop:
    slt   $t9, $t2, $t1
    beq   $t9, $zero, build_edge_end

    lw    $t3, 0($s3)
    addiu $s3, $s3, 4
    lw    $t4, 0($s3)
    addiu $s3, $s3, 4

    addiu $s2, $s2, 1
    sll   $t5, $s2, 2

    addiu $t6, $zero, 0x0600
    addu  $t7, $t6, $t5
    sw    $t3, 0($t7)

    addiu $t6, $zero, 0x0a00
    addu  $t7, $t6, $t5
    sw    $t4, 0($t7)

    sll   $t6, $t0, 2
    addiu $t7, $zero, 0x0200
    addu  $t8, $t7, $t6
    lw    $t9, 0($t8)

    addiu $t6, $zero, 0x0e00
    addu  $t7, $t6, $t5
    sw    $t9, 0($t7)

    sw    $s2, 0($t8)
    addiu $t2, $t2, 1
    j     build_edge_loop

build_edge_end:
    addiu $t0, $t0, 1
    j     build_node_loop

build_end:
    lw    $t0, 0($s3)
    addiu $t1, $zero, 0x1b00
    sw    $t0, 0($t1)

    addiu $a0, $zero, 1
    addiu $a1, $zero, 0
    addiu $a2, $zero, 0
    jal   dfs

    addiu $t0, $zero, 0x1200
    lw    $a0, 4($t0)
    j     program_done

impossible:
    addiu $a0, $zero, 0

program_done:
    addiu $t0, $zero, 0x1b04
    sw    $a0, 0($t0)
    jal   uart_send_hex16

display_loop:
    addiu $s6, $zero, 0x1b04
    lw    $s7, 0($s6)
    addiu $s5, $zero, 0x1a00
    lui   $s4, 0x4000
    ori   $s4, $s4, 0x0010

    andi  $t0, $s7, 0x000f
    sll   $t1, $t0, 2
    addu  $t1, $s5, $t1
    lw    $t2, 0($t1)
    ori   $t2, $t2, 0x0100
    sw    $t2, 0($s4)
    jal   delay

    srl   $t0, $s7, 4
    andi  $t0, $t0, 0x000f
    sll   $t1, $t0, 2
    addu  $t1, $s5, $t1
    lw    $t2, 0($t1)
    ori   $t2, $t2, 0x0200
    sw    $t2, 0($s4)
    jal   delay

    srl   $t0, $s7, 8
    andi  $t0, $t0, 0x000f
    sll   $t1, $t0, 2
    addu  $t1, $s5, $t1
    lw    $t2, 0($t1)
    ori   $t2, $t2, 0x0400
    sw    $t2, 0($s4)
    jal   delay

    srl   $t0, $s7, 12
    andi  $t0, $t0, 0x000f
    sll   $t1, $t0, 2
    addu  $t1, $s5, $t1
    lw    $t2, 0($t1)
    ori   $t2, $t2, 0x0800
    sw    $t2, 0($s4)
    jal   delay

    j     display_loop

dfs:
    addiu $sp, $sp, -36
    sw    $s7, 0($sp)
    sw    $s6, 4($sp)
    sw    $s5, 8($sp)
    sw    $s4, 12($sp)
    sw    $s3, 16($sp)
    sw    $s2, 20($sp)
    sw    $s1, 24($sp)
    sw    $s0, 28($sp)
    sw    $ra, 32($sp)

    addu  $s0, $a0, $zero
    addu  $s1, $a1, $zero
    addu  $s2, $a2, $zero
    addiu $s3, $zero, 0

    sll   $t0, $s0, 2
    addiu $t1, $zero, 0x1200
    addu  $t2, $t1, $t0
    sw    $zero, 0($t2)

    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    sw    $zero, 0($t2)

    addiu $t1, $zero, 0x0200
    addu  $t2, $t1, $t0
    lw    $s4, 0($t2)

dfs_edge_loop:
    beq   $s4, $zero, dfs_edge_end

    sll   $t0, $s4, 2
    addiu $t1, $zero, 0x0600
    addu  $t2, $t1, $t0
    lw    $s5, 0($t2)

    addiu $t1, $zero, 0x0a00
    addu  $t2, $t1, $t0
    lw    $s6, 0($t2)

    beq   $s5, $s1, dfs_next_edge

    addiu $t1, $zero, 0x1b00
    lw    $t2, 0($t1)
    slt   $t3, $s6, $t2
    beq   $t3, $zero, impossible

    addu  $a0, $s5, $zero
    addu  $a1, $s0, $zero
    addu  $a2, $s6, $zero
    jal   dfs

    sll   $t0, $s5, 2
    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    lw    $t3, 0($t2)
    addu  $t3, $t3, $s6

    sll   $t0, $s0, 2
    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    lw    $t4, 0($t2)
    slt   $t5, $t4, $t3
    beq   $t5, $zero, skip_update_g
    sw    $t3, 0($t2)

skip_update_g:
    sll   $t0, $s5, 2
    addiu $t1, $zero, 0x1200
    addu  $t2, $t1, $t0
    lw    $t3, 0($t2)

    sll   $t0, $s0, 2
    addiu $t1, $zero, 0x1200
    addu  $t2, $t1, $t0
    lw    $t4, 0($t2)
    addu  $t4, $t4, $t3
    sw    $t4, 0($t2)

    addiu $s3, $s3, 1

dfs_next_edge:
    sll   $t0, $s4, 2
    addiu $t1, $zero, 0x0e00
    addu  $t2, $t1, $t0
    lw    $s4, 0($t2)
    j     dfs_edge_loop

dfs_edge_end:
    beq   $s3, $zero, dfs_leaf

    addiu $t0, $zero, 1
    beq   $s0, $t0, dfs_return

    sll   $t0, $s0, 2
    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    lw    $t3, 0($t2)
    addu  $t3, $t3, $s2

    addiu $t4, $zero, 0x1b00
    lw    $t5, 0($t4)
    slt   $t6, $t5, $t3
    beq   $t6, $zero, dfs_return

    addiu $t1, $zero, 0x1200
    addu  $t2, $t1, $t0
    lw    $t3, 0($t2)
    addiu $t3, $t3, 1
    sw    $t3, 0($t2)

    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    addiu $t3, $zero, 1
    sw    $t3, 0($t2)
    j     dfs_return

dfs_leaf:
    sll   $t0, $s0, 2
    addiu $t1, $zero, 0x1200
    addu  $t2, $t1, $t0
    sw    $zero, 0($t2)

    addiu $t1, $zero, 0x1600
    addu  $t2, $t1, $t0
    addiu $t3, $zero, 1
    sw    $t3, 0($t2)

dfs_return:
    lw    $s7, 0($sp)
    lw    $s6, 4($sp)
    lw    $s5, 8($sp)
    lw    $s4, 12($sp)
    lw    $s3, 16($sp)
    lw    $s2, 20($sp)
    lw    $s1, 24($sp)
    lw    $s0, 28($sp)
    lw    $ra, 32($sp)
    addiu $sp, $sp, 36
    jr    $ra

delay:
    addiu $t8, $zero, 2000
delay_loop:
    addiu $t8, $t8, -1
    bne   $t8, $zero, delay_loop
    jr    $ra

uart_send_hex16:
    addiu $sp, $sp, -4
    sw    $ra, 0($sp)

    srl   $t0, $a0, 12
    andi  $t0, $t0, 0x000f
    jal   uart_send_nibble

    srl   $t0, $a0, 8
    andi  $t0, $t0, 0x000f
    jal   uart_send_nibble

    srl   $t0, $a0, 4
    andi  $t0, $t0, 0x000f
    jal   uart_send_nibble

    andi  $t0, $a0, 0x000f
    jal   uart_send_nibble

    lw    $ra, 0($sp)
    addiu $sp, $sp, 4
    jr    $ra

uart_send_nibble:
    addiu $t1, $zero, 10
    slt   $t2, $t0, $t1
    bne   $t2, $zero, uart_digit_decimal
    addiu $t3, $t0, 55
    j     uart_digit_ready

uart_digit_decimal:
    addiu $t3, $t0, 48

uart_digit_ready:
    lui   $t6, 0x4000
    ori   $t6, $t6, 0x0020
    lui   $t5, 0x4000
    ori   $t5, $t5, 0x0018

uart_wait_ready:
    lw    $t4, 0($t6)
    andi  $t4, $t4, 0x0010
    bne   $t4, $zero, uart_wait_ready
    sw    $t3, 0($t5)
    jr    $ra
