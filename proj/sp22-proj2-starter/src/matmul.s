.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
	li t0, 1
    blt a1, t0, error # if a1 < 1 then error
    blt a2, t0, error # if a2 < 1 then error
    blt a4, t0, error # if a4 < 1 then error
    blt a5, t0, error # if a5 < 1 then error
	bne a2, a4, error # if a2 != a4 then error
	addi sp, sp, -28 # sub sp
	sw ra, 0(sp) # save ra
	sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
	li t0, 0 # t0 = i
	li t1, 0 # t1 = j
	mv s0, a0 # s0 = int* A
	mv s1, a3 # s1 = int* B
	mv s2, a6 # s2 = int* result
	mv s3, a1 # s3 = Ah
	mv s4, a2 # s4 = Aw Bh
	mv s5, a5 # s5 = Bw
	j outer_loop_start
	# Prologue

error:
	li a0, 38
	j exit

outer_loop_start:
	bge t0, s3, outer_loop_end # if i >= A_h then outer_loop_end
	slli t2, t0, 2 # t2 = i * 4
	mul t2, s4, t2 # t2 = i * 4 * width
	add t2, t2, s0 # t2 = &array[width * i]

inner_loop_start:
	bge t1, s5, inner_loop_end # if j >= Bw then outer_loop_end
	slli t3, t1, 2 # t3 = j * 4
	add t3, t3, s1 # t3 = &array[j]
	mv a0, t2 # a0 = &array[width * i] 
	mv a1, t3 # a1 = &array[j]
	mv a2, s4 # a2 = number to calculate
	li a3, 1 # a3 = 1
	mv a4, s5 # a4 = Bw
	addi sp, sp, -12
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
	jal dot
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
	addi sp, sp, 12 # save and call
	mul t3, t0, s5 # t3 = i * Ah
	add t3, t3, t1 # t3 = i * Ah + j
	slli t3, t3, 2
	add t3, t3, s2 # get address of the result
	sw a0, 0(t3)
	addi t1, t1 1 # j = j + 1
	j inner_loop_start

inner_loop_end:
	addi t0, t0, 1 # i = i + 1
	li t1, 0
	j outer_loop_start

outer_loop_end:
    lw ra, 0(sp) # save ra
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2 ,12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28 # sub sp
	# Epilogue
	ret
