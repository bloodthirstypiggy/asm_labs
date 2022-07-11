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
	mov x21, x1
	mov x12,  #4
1:
	mov x5, #0	//r
	mov x6, #0	//g
	mov x7, #0	//b

	mov x9, #2
	udiv x9, x2, x9
	mul x9, x9, x4	//array of width/2 by rgbrgbrgb
	
	mov x13, #2
	udiv x13, x3, x13	//height/2

	mov x14, #0	//counter big
	mov x8,  #0	//counter small

	mul x15,x2,x4 //width * channels

	mov x16, x0	//pointer to the beginning of the whole matrix

	mov w10, #0 //max
2:
	cmp x8, x9	//
	beq 9f
	ldrb w5,[x16], #1	//r
	ldrb w6,[x16], #1	//g
	ldrb w7,[x16], #1	//b
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
	strb w10, [x21], #1
	strb w10, [x21], #1
	strb w10, [x21], #1
	
	cmp x4, x12	//if channels =4
	beq 7f
	b 8f
7:
	ldrb w11, [x16], #1
	strb w11, [x21], #1

8:
	add x8, x8, x4		//add amount of channels
	b 2b

9:
	cmp x14, x13		//counter big and high/2
	beq myexit
	add x16, x16, x15	//move x16 to the next position in matrix
	add x14, x14, #1
	mov x8, #0
	b 2b

myexit:
   ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    mov x16, #32
    add sp, sp, x16
    ret
.size AsmGray, .-AsmGray
