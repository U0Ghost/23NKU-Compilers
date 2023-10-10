	.arch armv7-a

	.data
f:       
	.word   0            		@ 全局变量 f
n:      
	.word   0	    		@ 变量n
fib:    
	.space 180		@ int fib[45], 开辟4 * 45 Byte的空间

	.text
input_prompt:
        	.ascii  "Please enter the position (n) of the Fibonacci term:\000"
        	.align  2
format:
        	.ascii  "%d\000"
        	.align  2

error_message:
        	.ascii  "Please enter a valid number between 0 and 40!\n\000"
        	.align  2
result:
        	.ascii  "The %dth term of the Fibonacci sequence is: %d\n\000"

	.global main
	.type   main, %function
main:
   	@ 保存main函数的返回地址
        	mov     r7, lr			
		        
   	@ 打印输入提示信息
       	ldr     r0,  =input_prompt
        	bl      printf

  	@ 用户输入数n
       	ldr     r0, =format                            	@ 格式化参数%d 
        	sub     sp, sp, #4			@ 留出一个 4 Byte 的空间, 保存用户输入
        	mov     r1, sp			@ 将当前栈指针的值作为scanf的第二个参数传入
        	bl      scanf
        
        	ldr     r0, [sp]			@ 获取用户输入的数n
        	ldr     r1, =n			
        	str     r0, [r1]			@ 在变量n的地址处存储n的值，便于后续取用
        	add     sp, sp, #4			@ 恢复栈空间

    	@ 检查输入的n值是否合法 
        	ldr     r1, =n
        	ldr     r0, [r1]
        	cmp     r0, #0			
        	blt     invalid_input			@ 若n < 0, 跳转到提示错误信息的代码
        	cmp     r0, #40
        	bgt     invalid_input			@ 若n > 40, 跳转到提示错误信息的代码

    	@ 初始化前两项的值, r1存储循环变量 i 
        	mov     r1, #2              		@ i = 2
        	ldr     r2, =fib              		
        	mov     r3, #0              		@ fib[0] = 0
       	str     r3, [r2]                		@ fib[0]将写在fib对应位置的内存中
        	mov     r3, #1              		@ fib[1] = 1
        	str     r3, [r2, #4]          		@ fib[1]将写在fib对应位置的内存中
        
loop:
    	@ 循环体内部代码
        	sub     r5, r1, #1          	  	@ $r5 = i-1
        	ldr     r3, [r2, r5, LSL #2]    		@ 获取 fib[i-1]的值
        	sub     r5, r5, #1          		@ $r5 = i-2
        	ldr     r4, [r2, r5, LSL #2]    		@ 获取 fib[i-2]的值
        	add     r3, r3, r4          		@ 计算 fib[i] = fib[i-2] + fib[i-1]
        	str     r3, [r2, r1, LSL #2]    		@ fib[i]将写在fib对应位置的内存中
        
        	add     r1, r1, #1			@ i++

    	@ 判断循环条件（i <= n）
        	ldr     r4, =n
        	ldr     r0, [r4]
        	cmp     r1, r0
        	ble     loop			@ 若 i <= n，则继续循环，否则向下执行。

    	@ 将最终结果fib[n]存储在f中，即f = fib[n]
        	ldr     r4, =f
        	str     r3, [r4]            

    	@ 打印输出结果
        	ldr     r0, =result			@ r0存储字符串result，作为printf第1个参数
        	ldr     r1, =n
        	ldr     r1, [r1]			@ r1存储n，作为printf第2个参数
        	ldr     r2, =f
        	ldr     r2, [r2]			@ r2存储f，作为printf第3个参数
        	bl      printf

exit:
        	mov     lr, r7 
        	bx      lr			@ 退出

	invalid_input:
        	ldr     r0, =error_message
        	bl      printf			@ 打印错误信息
        	b       exit				@ 跳转程序退出的代码段

	.section   .note.GNU-stack,"",%progbits

