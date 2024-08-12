.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

	# Prologue
	li t0, 1
	blt a2, t0, exit_length # if a2 < 1 then exit_length
	blt a3, t0, exit_stride # if a3 < 1 then exit_stride
	blt a4, t0, exit_stride # if a4 < 1 then exit_stride
	li t0, 0 # i = 0
	li t3, 0 # dot = 0

loop_start:
	bge t0, a2, loop_end # if i >= n then loop_end
	slli t1, t0, 2 # get array 1 element offset
	mv t2, t1 # get array 2 element offset
	mul t1, t1, a3 # multiply stride
	mul t2, t2, a4 # multiply stride
	add t1, a0, t1 # get array &1[i * stride]
	add t2, a1, t2 # get array &2[i * stride]
	lw t1, 0(t1) # get value
	lw t2, 0(t2) # get value
	mul t1, t2, t1 #multiply
	add t3, t1, t3 # dot += multiply
	addi t0, t0, 1 # i++
	j loop_start

loop_end:
	mv a0, t3
	# Epilogue
	ret

exit_length:
	li a0, 36
	j exit

exit_stride:
	li a0, 37
	j exit
