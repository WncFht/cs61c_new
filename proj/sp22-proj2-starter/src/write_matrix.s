.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
	addi sp, sp, -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a1 # s0 = int* matrix
	mv s1, a2 # s1 = rows 
	mv s2, a3 # s2 = cols

	li a1, 1 # write-only
	call fopen
	li t0, -1
	beq a0, t0, fopen_fail # if a0 == t0 then fopen_fail
	mv s3, a0 # s3 = File*

	addi sp, sp, -8
	sw s1, 0(sp) # save rows and cols to the memory
	sw s2, 4(sp)

	mv a0, s3 # File*
	mv a1, sp # int* buffer = sp
	li a2, 2 # two element
	li a3, 4 # sizeof(int)
	call fwrite

	addi sp, sp, 8
	li t0, 2
	bne a0, t0, fwrite_fail # if a0 != t0 then fwrite_fail

	mul a2, s1, s2 # elements = rows * cols
	mv a0, s3 # Filw*
	mv a1, s0 # a1 = int* matrix
	li a3, 4 # sizeof(int)
	call fwrite
	mul t0, s1, s2
	bne a0, t0, fwrite_fail # if a0 != t0 then fwrite_fail

	mv a0, s3
	call fclose
	bne a0, x0, fclose_fail # if a0 != x0 then fclose_fail
	# Epilogue
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp, 20

	ret

fopen_fail:
	li a0, 27
	j exit

fwrite_fail:
	li a0, 30
	j exit

fclose_fail:
	li a0, 28
	j exit