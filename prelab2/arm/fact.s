    .arch armv7-a
    .global	factorial

    @ 数据段
    .data
input:
    .asciz	"%d\000"
    .align	2
result:
    .asciz	"%d为对应的阶乘结果。\n\000"

    @ 代码段
    .text
factorial:
    push	{r7, lr} @栈帧指针r7和返回地址lr压栈。
	sub	sp, sp, #8 @sp-=8 新的栈帧，和下一条指令结合 得到新的栈帧指针。
	add	r7, sp, #0
	str	r0, [r7, #4] @ 参数存入r7+4的地址。
	ldr	r3, [r7, #4] @ r3 为参数num，也等于此时的num，每次从r7+4的地方取出对应的值进行运算。
	cmp	r3, #0
	bne	.not_zero @ num非0就执行bne跳转到not_zero
	mov	r3, #1
	b	.end
.not_zero:
	ldr	r3, [r7, #4] @ 同上
	sub	r3, r3, #1
	mov	r0, r3
	bl	factorial
	mov	r2, r0 @ 函数得到的结果存入r2
	ldr	r3, [r7, #4] @ 同上
	mul	r3, r3, r2 @ 相乘
.end:
	mov	r0, r3 @ 运算结果r3放入r0中返回main
	add	r7, r7, #8 @ 恢复函数栈帧
	mov	sp, r7 @ 恢复sp
	@ sp needed
	pop	{r7, pc} @ 栈帧指针和返回地址出栈。

	.global main
	.type main, %function
main:
	str lr,[sp,#-4] @ 保存lr到堆栈中
	sub sp,sp,#4 @ 留出4字节空间，保存用户输入

	ldr r0,addr_of_input@ scanf的格式化字符串参数
	mov r1,sp @ 堆栈顶层作为scanf的第二个参数
	bl scanf @ 调用scanf

	ldr r0,[sp] @ 加载输入的参数num给r0
	bl factorial @ 调用factorial，结果保存在r0

	mov r1,r0 @ 结果赋值给r1，作为printf第二个参数
	ldr r0,addr_of_result @ 返回地址，作为printf第一个参数
	bl printf @调用printf

	add sp,sp,#4 @ 恢复函数栈帧
	ldr lr,[sp],#4 @ 弹出保存的lr
	bx lr

addr_of_input:
	.word input
addr_of_result:
	.word result

	.section	.note.GNU-stack,"",%progbits
