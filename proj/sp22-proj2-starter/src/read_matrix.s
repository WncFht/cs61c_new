.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
	addi sp, sp, -24 # save register
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	mv s0, a1 # s0 = &row
	mv s1, a2 # s1 = &col
	li a1, 0 # a1 = 0, a0 = char *filename
	call fopen # fopen
	li t0, -1 # t0 = -1
	beq a0, t0, fopen_fail
	mv s2, a0 # s2 = File*
	li a0, 8
	call malloc # malloc(8)
	beqz a0, malloc_fail
	mv s3, a0 # s3 = void* buffer
	mv a0, s2 # a0 = File*
	mv a1, s3 # a1 = int* buffer
	li a2, 8 # read 8 bytes
	call fread # call fread
	li t0, 8
	bne t0, a0, fread_fail # if t0 != a0 then fread_fail
	lw t0, 0(s3) # t0 = buffer[0]
	sw t0, 0(s0) # row = buffer[0]
	lw t1, 4(s3) # t0 = buffer[1]
	sw t1, 0(s1) # col = buffer[1]
	mul t0, t0, t1 # t0 = row * col
	slli t0, t0, 2 # t0 = t0 * int_size = size
	mv s4, t0 # s4 = t0 = size

	mv a0, s3
	call free # free memory

	mv a0, s4 # a0 = size
	call malloc # call malloc
	beqz a0, malloc_fail
	mv s3, a0 # s3 = void* buffer
	mv a0, s2 # a0 = File *
	mv a1, s3 # a1 = void* buffer
	mv a2, s4 # a2 = size
	call fread # call fread
	bne a0, s4, fread_fail # if a0 != s4 then fread_fail
	mv a0, s2
	call fclose
	bne a0, x0, fclose_fail # if a0 != x0 then fclose_fail
	mv a0, s3
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	addi sp, sp, 24 # load register
	ret

fopen_fail:
	li a0, 27
	j exit

malloc_fail:
	li a0, 26
	j exit

fread_fail:
	li a0, 29
	j exit

fclose_fail:
	li a0, 28
	j exit