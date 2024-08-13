.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
	# Prologue
	addi sp, sp, -52
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp)
	sw s4, 16(sp)
	sw s5, 20(sp)
	sw s6, 24(sp)
	sw s7, 28(sp)
	sw s8, 32(sp)
	sw s9, 36(sp)
	sw s10, 40(sp)
	sw s11, 44(sp)
	sw ra, 48(sp)
	
	# check
	li t0, 5
	bne t0, a0, wrong_arg # if t0 != a0 then wrong_arg
	mv s0, a1 # s0 = argv
	mv s1, a2 # s1 = mode

	# Read pretrained m0
	li a0, 8
	call malloc
	beqz a0, malloc_fail
	mv s2, a0 # s2 = m0, row, column
	lw a0, 4(s0)
	mv a1, s2
	addi a2, s2, 4
	call read_matrix
	mv s3, a0 # s3 = m0	

	# Read pretrained m1
	li a0, 8
	call malloc
	beqz a0, malloc_fail
	mv s4, a0 # s4 = m1, row, column
	lw a0, 8(s0)
	mv a1, s4
	addi a2, s4, 4
	call read_matrix
	mv s5, a0 # s5 = m1
	
	# Read input matrix
	li a0, 8
	call malloc
	beqz a0, malloc_fail
	mv s6, a0 #s6 = input, tow column
	lw a0, 12(s0)
	mv a1, s6
	addi a2, s6, 4
	call read_matrix
	mv s7, a0 # s7 = input

	# Compute h = matmul(m0, input)
	lw t0, 0(s2)
	lw t1, 0(s6)
	mul s8, t0, t1 # s8 = h size
	mv a0, s8
	slli a0, a0, 2
	call malloc
	beqz a0, malloc_fail
	mv s9, a0 # s9 = h matrix
	mv a0, s3
	lw a1, 0(s2)
	lw a2, 4(s2)
	mv a3, s7
	lw a4, 0(s6)
	lw a5, 4(s6)
	mv a6, s9
	call matmul

	# Compute h = relu(h)
	mv a0, s9
	mv a1, s8
	call relu

	# Compute o = matmul(m1, h)
	lw t0, 0(s4) # 0(s2) h row
	lw t1, 4(s6) # 4(s6) h column
	mul s10, t0, t1 # s10 = matrix o size
	mv a0, s10
	slli a0, a0, 2
	call malloc
	beqz a0, malloc_fail
	mv s11, a0 # s11 = matrix 0
	mv a0, s5
	lw a1, 0(s4)
	lw a2, 4(s4)
	mv a3, s9
	lw a4, 0(s2)
	lw a5, 4(s6)
	mv a6, s11
	call matmul

	# Write output matrix o
	lw a0, 16(s0)
	mv a1, s11
	lw a2, 0(s4)
	lw a3, 4(s6)
	call write_matrix

	# Compute and return argmax(o)
	mv a0, s11
	mv a1, s10
	call argmax
	mv s0, a0

	# If enabled, print argmax(o) and newline
	li t0, 0
	bne t0, s1, not_print
	call print_int
	li a0, '\n'
	call print_char

not_print:
	mv a0, s2
	call free
	mv a0, s3
	call free
	mv a0, s4
	call free
	mv a0, s5
	call free
	mv a0, s6
	call free
	mv a0, s7
	call free
	mv a0, s9
	call free
	mv a0, s11
	call free
	mv a0, s0
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)
	lw s6, 24(sp)
	lw s7, 28(sp)
	lw s8, 32(sp)
	lw s9, 36(sp)
	lw s10, 40(sp)
	lw s11, 44(sp)
	lw ra, 48(sp)
	addi sp, sp, 52
	ret

wrong_arg:
	li a0, 31
	j exit

malloc_fail:
	li a0, 26
	j exit
