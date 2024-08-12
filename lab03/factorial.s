.globl factorial

.data
n: .word 7

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    li t0, 1
    beq a0, t0, exit
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    addi a0, a0, -1
    jal ra, factorial
    lw t1, 0(sp)
    lw ra, 4(sp)
    mul a0, t1, a0
    addi sp, sp, 8

exit:
    ret





#    addi sp, sp, -4
#    sw ra, 0(sp)
#    beq a0, zero, .Lend
#    li t0, 1
#    addi t1, a0, 0
#
#.Lloop:
#    beq t1, t0, .Lend
#    mul t0, t0, t1
#    addi t1, t1, -1
#    j .Lloop
#
#.Lend:
#    lw ra, 0(sp)
#    addi sp, sp, 4
#    jr ra 
