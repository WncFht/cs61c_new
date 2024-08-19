.globl pow inc_arr

.data
fail_message: .asciiz "%s test failed\n"  # 失败时的消息格式
pow_string: .asciiz "pow"                 # "pow"函数的名字
inc_arr_string: .asciiz "inc_arr"         # "inc_arr"函数的名字

success_message: .asciiz "Tests passed.\n" # 测试通过时的消息
array:
    .word 1, 2, 3, 4, 5                   # 初始化数组，存储 1 到 5 的数字
exp_inc_array_result:
    .word 2, 3, 4, 5, 6                   # 期望的结果数组，存储 2 到 6 的数字

.text
main:
    # pow: 计算 2 的 7 次方，应该返回 128
    li a0, 2            # 将 2 加载到寄存器 a0（基数）
    li a1, 7            # 将 7 加载到寄存器 a1（指数）
    jal pow             # 调用 pow 函数，返回结果在 a0 中
    li t0, 128          # 将预期值 128 加载到寄存器 t0
    beq a0, t0, next_test # 如果结果正确，跳到下一个测试
    la a0, pow_string    # 否则，加载 "pow" 的字符串地址到 a0
    j failure            # 跳到失败处理程序
    
next_test:
    # inc_arr: 将数组 "array" 的每个元素加 1
    la a0, array         # 加载数组的起始地址到 a0
    li a1, 5             # 加载数组长度 5 到 a1
    jal inc_arr          # 调用 inc_arr 函数
    jal check_arr        # 验证 inc_arr 的输出是否正确
    # 如果所有测试都通过，打印成功消息并退出程序
    li a0, 4
    la a1, success_message # 加载成功消息地址到 a1
    ecall                # 打印成功消息
    li a0, 10            # 准备退出程序
    ecall                # 系统调用退出程序

# pow 函数: 计算 a0 的 a1 次方。
# 类似于以下 C 代码：
# uint32_t pow(uint32_t a0, uint32_t a1) {
#     uint32_t s0 = 1;
#     while (a1 != 0) {
#         s0 *= a0;
#         a1 -= 1;
#     }
#     return s0;
# }
pow:
    # BEGIN PROLOGUE
    addi sp, sp, -4     # 在栈上分配空间保存寄存器
    sw s0, 0(sp)        # 保存返回地址
    # END PROLOGUE
    li s0, 1            # 初始化 s0 为 1，存储中间结果
pow_loop:
    beq a1, zero, pow_end # 如果指数为 0，跳到结束
    mul s0, s0, a0       # 乘以基数，更新 s0
    addi a1, a1, -1      # 指数减 1
    j pow_loop           # 重复循环
pow_end:
    mv a0, s0            # 将最终结果存储到 a0 中
    # BEGIN EPILOGUE
    lw s0, 0(sp)         # 恢复返回地址
    addi sp, sp, 4       # 恢复栈指针
    # END EPILOGUE
    ret                  # 返回到调用函数

# inc_arr 函数: 对数组中的每个元素执行加 1 操作
# a0 保存数组的起始地址，a1 保存数组的长度
inc_arr:
    # BEGIN PROLOGUE
    addi sp, sp, -12      # 在栈上分配空间保存寄存器
    sw ra, 0(sp)         # 保存返回地址
    sw s0, 4(sp)         
    sw s1, 8(sp)         
    # END PROLOGUE
    mv s0, a0            # 将数组的起始地址保存到 s0
    mv s1, a1            # 将数组长度保存到 s1
    li t0, 0             # 初始化计数器 t0 为 0
inc_arr_loop:
    beq t0, s1, inc_arr_end # 如果处理完所有元素，跳到结束
    slli t1, t0, 2        # 将数组索引转换为字节偏移量
    add a0, s0, t1        # 计算数组元素的地址
    addi sp, sp, -4
    sw t0, 0(sp)          # 保存 t0 以调用 helper_fn
    jal helper_fn         # 调用 helper_fn 来递增该元素
    lw t0, 0(sp)          # 恢复 t0
    addi sp, sp, 4
    addi t0, t0, 1        # 计数器加 1
    j inc_arr_loop        # 跳回循环
inc_arr_end:
    # BEGIN EPILOGUE
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12
    # END EPILOGUE
    ret                   # 返回到调用函数

# helper_fn 函数: 将内存地址 a0 处的 32 位值加 1
# 类似于 C 代码: "*a0 = *a0 + 1"
helper_fn:
    # BEGIN PROLOGUE
    addi sp, sp, -4      # 在栈上分配空间保存寄存器
    sw s0, 0(sp)         # 保存返回地址
    # END PROLOGUE
    lw t1, 0(a0)         # 加载内存地址 a0 处的值到 t1
    addi s0, t1, 1       # t1 值加 1
    sw s0, 0(a0)         # 将新值存回内存地址 a0 处
    # BEGIN EPILOGUE
    lw s0, 0(sp)         # 恢复返回地址
    addi sp, sp, 4       # 恢复栈指针
    # END EPILOGUE
    ret                  # 返回到调用函数

# 你可以忽略以下部分，它是为了验证数组操作是否正确

# 检查 inc_arr 函数的结果，应该包含 2 3 4 5 6。
check_arr:
    la t0, exp_inc_array_result  # 加载期望结果数组的地址到 t0
    la t1, array                # 加载当前数组的地址到 t1
    addi t2, t1, 20             # 计算数组末尾位置
check_arr_loop:
    beq t1, t2, check_arr_end   # 如果数组已检查完毕，跳到结束
    lw t3, 0(t0)                # 加载期望数组的当前值到 t3
    lw t4, 0(t1)                # 加载当前数组的当前值到 t4
    beq t3, t4, continue        # 如果值匹配，继续检查
    la a0, inc_arr_string       # 加载 "inc_arr" 字符串地址到 a0
    j failure                   # 跳到失败处理程序
continue:
    addi t0, t0, 4              # 更新期望数组的指针
    addi t1, t1, 4              # 更新当前数组的指针
    j check_arr_loop            # 跳回循环
check_arr_end:
    ret                         # 检查通过，返回

# 打印失败消息并终止程序
failure:
	mv a3, a0                   # 将失败的测试名称加载到 a3
    li a0, 4                    # 设置系统调用为字符串打印
    la a1, fail_message         # 加载失败消息的地址到 a1
    ecall                       # 执行系统调用，打印失败消息
    li a0, 10                   # 设置系统调用为程序退出
    ecall                       # 执行系统调用，退出程序
