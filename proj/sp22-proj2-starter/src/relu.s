.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
	li t0, 0 # t0 = 0
	bgt a1, t0, loop_start # if length > 0 then loop_start
	li a0, 36
	j exit

loop_start:
	bge t0, a1, loop_end # jump if t0 >= length
	slli t1, t0, 2 # set offset
	add t1, t1, a0 # get &head[0]
	lw t2, 0(t1) # get head[t0]
	bge t2, x0, loop_continue # if (head[t0] >= 0) do Nothing
	sw x0, 0(t1) # set it to zero

loop_continue:
	addi t0, t0, 1 # add one
	j loop_start # jump to loop_start

loop_end:
	# Epilogue
	ret
