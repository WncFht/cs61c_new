.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
	li t0, 0 # i = 0
	mv t1, a0 # t1 = int* array
	li a0, 0 # return = 0 
	lw t2, 0(t1) # max = array[0]
	bgt a1, t0, loop_start # if length > 0 then loop_start
	li a0, 36 
	j exit

loop_start:
	bge t0, a1, loop_end # if i >= n, break
	slli t3, t0, 2 # get offset
	add t3, t3, t1 # t3 = &array[i]
	lw t3, 0(t3) # t3 = array[i]
	bge t2, t3, loop_continue # if max >= array[i] then loop_continue
	mv t2, t3 # max = array[i]
	mv a0, t0 # return = i

loop_continue:
	addi t0, t0, 1 # i++
	j loop_start

loop_end:
	# Epilogue
	ret
