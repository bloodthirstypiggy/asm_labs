	.arch armv8-a
//	Integral of the exponent by the Simpson method	
	.data
msg_input:
	.asciz	"Enter x, n: "
fmt_input:
	.asciz	"%f %f"
msg_result:
	.string	" result: %f\n"
output_fname:
	.asciz	"output.txt"
output_mode:
	.asciz	"w"
output_fd:
	.skip	4
msg_error:
	.asciz "Incorrect input \n"
fmt_member:
	.asciz	"number:%d   value:%lf \n"
pi:
	.float 1.570796
	.text
	.align	2
	.global	main
	.type	main, %function
	.equ	stack_size, 32
	.equ	x_offset, 16
	.equ	n_offset, 24
main:
	# 32 bites: 0 - 22 mantissa
	#	     23-30 offset
	#		31 sign
	sub sp, sp, stack_size
	stp x29, x30, [sp]
	mov x29, sp

	#output of the input message
	adr x0, msg_input
	bl printf

	#take x and n values
	ldr x0, =fmt_input
	add x1, x29, x_offset
	add x2, x29, n_offset
	bl scanf

	#check what we have
	cmp x0, 2
	//bne error

	//check range
	ldr s0, [x29, x_offset]
	fmov s1, #-1.0
	fcmp s0,s1
	blt error
	fmov s1, #1.0
	fcmp s0,s1
	bgt error
	ldr s9, [x29, n_offset]
	fmov s1, wzr
	fcmp s9, s1
	ble error

	#lib function
	ldr s0, [x29, x_offset]
	fcvt d0, s0
	bl acos
	ldr x0, =msg_result
	bl printf
	#own implementation
	bl work
	ldr x0, =msg_result
	fcvt d0, s0
	bl printf
	#???????????????????????????/

	#exit	
	b exitnah
	ret

error:
	adr x0, stderr
	ldr x0, [x0]
	ldr x1, =msg_error
	bl fprintf
	mov x0, #1
exitnah:
	mov x0, #0
	ldp x29, x30, [sp]
	add sp, sp, stack_size
	bl exit
work:							//(2n)!/((n!)^2) * 4^n * (2n+1)) * x^(2n+1)
	str x30, [sp, #-8]!
	bl open_file
	fmov s13, wzr	//result(n-1)
	fmov s16, wzr	// main result
	fmov s1, w5		//    s1 = n
work_start:
	mov w5, #0
	fmov s10, wzr
	fmov s15, wzr		//result x(n)
	fmov s6, #1.0
	fmov s2, #1.0		//2n!
	fmov s4, #1.0		//4^n
	fmov s7, #1.0		//n! ^ 2
	fmov s8, #1.0		//2n+1
	ldr s9, [x29, x_offset]	//x
	fmov s12, s9		//x^(2n+1)
	fmov s11, s9// x^(2n+1)
	fmov s17, wzr
	fmov s16, wzr
	b result

get_2n:
	fmov s13, s1
	fadd s13, s13, s13
	fmov s14, s13
	fsub s14, s14, s6
	fmul s13, s13, s14
	fmul s2, s2, s13
get_4n:
	fmov s13, #4
	fmul s4, s4, s13
get_n2:
	fmov s13, s1
	fmul s13, s13, s13
	fmul s7, s7, s13
get_2nplus1:
	fmov s13, s1
	fadd s13, s13, s13
	fadd s13, s13, s6
	fmov s8, s13
get_x:
	fmul s12, s12, s9
	fmul s12, s12, s9

result:
	fmul s15, s11, s2
	fdiv s15, s15, s4
	fdiv s15, s15, s7
	fdiv s15, s15, s8

	
	
	


	stp s0,s1, [sp, #-16]!
	stp s2,s3, [sp, #-16]!
	stp s4,s5, [sp, #-16]!
	stp s6,s7, [sp, #-16]!
	stp s8,s9, [sp, #-16]!
	stp s10,s11, [sp, #-16]!
	str s12, [sp, #-8]!


	str s15, [sp, #-8]! 	//cur result
	str s16, [sp, #-8]!	// sum
	str s17, [sp, #-8]!  //prev 
	fmov s0, s15
	bl save_current_result
	ldr s17, [sp], #8  //prev 
	ldp s15, s16, [sp], #16
	ldr s12, [sp], #8
	ldp s10,s11,[sp], #16
	ldp s8,s9,[sp], #16
	ldp s6,s7,[sp], #16
	ldp s4,s5,[sp], #16
	ldp s2,s3,[sp], #16
	ldp s0,s1,[sp], #16

	
	fadd s16, s16, s15		// main result ++
	fadd s1, s1, s6
	fsub s14, s15, s17	 // result - prev result
	fabs s14, s14		// |result - prev result|
	ldr s15, [x29, n_offset]
	fcmp s14, s15
	blt end
	fmov s17, s15
	fmov s15, wzr
	b get_2n

end:

	bl close_file
	fmov s0, s16
	adr x0, pi
	ldr s3, [x0]
	fsub s0, s3, s0
	ldr x30, [sp], #8
	ret

open_file:
	str x30, [sp, #-8]!
	ldr x0, =output_fname
	ldr x1, =output_mode
	bl fopen

	ldr x1, =output_fd
	str x0, [x1]		//store output file descriptor
	ldr x30,[sp], #8
	ret

close_file:
	str x30, [sp, #-8]!
	adr x0, output_fd
	ldr x0, [x0]
	bl close
	mov x0, #0
	adr x1, output_fd
	str x0, [x1]
	ldr x30, [sp], #8
	ret
save_current_result:
	str x30, [sp,#-8]!
	//s0 - current result, s1 - n
	fcvtas x2, s1
	fcvt d0, s0
	add x2, x2, #1
	ldr x0, =output_fd
	ldr x0, [x0]
	ldr x1, =fmt_member
	bl fprintf
	ldr x30, [sp], #8
	ret
	.size main, (.-main)
	




	





		ret
	.size	main, .-main
