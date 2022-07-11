.include "macros.s"

func_define AsmGray
AsmGray:
/**
x0 - inputData adress
x1 - outputData adress
x2 - width of the image
x3 - height of the image
x4 - amount of channels
**/
	mov x16, #32
	sub sp, sp, x16
	stp x29, x30, [sp]
	stp x27, x28, [sp, #16]
	mov x20, x0
	mov x21, x1
	mov x12,  #4
1:
	mov x5, #0	//r
	mov x6, #0	//g
	mov x7, #0	//b
	
	mov x8, #0	//counter

	mul x9, x2, x3 //width * length * channel
	mul x9, x9, x4
	
	mov w10, #0 //max
2:
	cmp x8, x9
	bge myexit
	ldrb w5,[x20], #1	//r
	ldrb w6,[x20], #1	//g
	//ldrb w7,[x20], #1	//b

	/*stp x0,x1, [sp, #-16]!
	stp x2,x3, [sp, #-16]!
	stp x4,x5, [sp, #-16]!
	stp x6,x7, [sp, #-16]!
	str x8, [sp, #-8]!
	*/

	mov w0, w5
	mov w1, w6
	
	bl findmax	//take w0, w1 and return greatest in w0
	ldrb w7, [x20], #1
	mov w1, w7
	bl findmax	//in w0 we have max now

	/*ldr x8, [sp], #8
	ldp x7, x6 [sp], #16
	ldp x5, x4 [sp], #16
	ldp x3, x2 [sp], #16
	ldp x1, x0 [sp], #16*/
	/*

	cmp w5, w6			//r >? g
	ble 3f				//r < g
	cmp w5, w7			//r >? b
	ble 4f			//	r<b
	mov w10, w5		//r wins
	b 5f
3:
	cmp w6, w7		//g >? b
	ble 4f			// g < b
	mov w10, w6
	b 5f
4:
	mov w10, w7
	b 5f
5:
*/
	strb w0, [x21], #1
	strb w0, [x21], #1
	strb w0, [x21], #1
	
	cmp x4, x12	//if channels =4
	beq 7f
	b 8f
7:
	ldrb w11, [x20], #1
	strb w11, [x21], #1

8:
	add x8, x8, x4		//add amount of channels
	b 2b

myexit:
   ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    mov x16, #32
    add sp, sp, x16
    ret
.size AsmGray, .-AsmGray

.type findmax, %function
.data
.text
.align 2
findmax:
	cmp w0, w1
	ble 1f
	ret
1:
	mov w0, w1
	ret


.size findmax, .-findmax
