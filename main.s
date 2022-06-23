	.arch armv8-a
//	Copy all odd words in each string from file1 to file2
	.data
mes2:
	.string	"Input filename for write\n"
	.equ	mes2len, .-mes2
mes3:
	.string	"File exists. Rewrite(Y/N)?\n"
	.equ	mes3len, .-mes3
ans:
	.skip	3
name1:
	.skip	1024
name2:
	.skip	1024
	.align	3
fd1:
	.skip	8
fd2:
	.skip	8
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
    	ldr x1, [sp, #16]
    	mov x8, #56
    	mov x0, #-100
    	mov x2, #0x241
    	mov x3, 0666
	svc	#0

    adr x1, fd2
    str x0, [x1]

	bl	work
	adr	x0, fd2
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	b	1f

#	bl	writeerr
#	adr	x0, fd1
#	ldr	x0, [x0]
#	mov	x8, #57
#	svc	#0
#	adr	x0, fd2
#	ldr	x0, [x0]
#	mov	x8, #57
#	svc	#0
#	mov	x0, #1
1:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
	.type	work, %function
	.equ	f2, 24    //file descr for out
	.equ	tmp, 32
    .equ    flag, 40        //odd or not
	.equ	bufin, 48
	.equ	bufout, 64
	.text
	.align	2
work:
	mov	x16, #8240
	sub	sp, sp, x16
	stp	x29, x30, [sp]
	mov	x29, sp            // x29 = frame pointer
    adr x1, fd2
    ldr x1, [x1]
	str	x1, [x29, f2]
    add x1, x29, bufin
    add x6, x29, bufout
    b 0f
	//str	xzr, [x29, flg]
before0:
    add x1, x29, bufin
    add x6, x29, bufout
    mov x8, #0
    mov x7, #0
    mov x0, #0
    mov	x2, #16              //change buffer number
	mov	x8, #63
	svc	#0
    mov x8, #0
    mov x3, x1 // copy x1 to use in 1         x3 = x1
    str x0, [x29, tmp]                        //if flag == 16 mb overflow
    b 1f

0:
    add x1, x29, bufin
    add x6, x29, bufout
    mov x7, #0
    mov x0, #0
    mov x2, #16
    mov x8, #63
    svc #0
    cmp x0, #0
    beq 12f                       //empty + EOF
    mov x8, #0
    mov x3, x1
    str x0, [x29, tmp]
    b before

before:
    cmp x0, #0
    beq 0b
    ldrb w2, [x3], #1
    sub x0, x0, #1
    cbz w2, 11f // ???
    cmp w2, '\n'
    beq 92f
    cmp w2, ' '
    beq before
    cmp w2, '\t'
    beq before
    add x7, x7, #1
    b after_before
1:
    ldrb w2, [x3], #1           //w2 = first character
    sub x0, x0, #1
    cmp x0, #0
    blt 11f
    add x7, x7, #1                  // x7 = odd in word
after_before:
    cbz w2, 11f // do
    cmp w2, '\n'
    beq 2f
    cmp w2, ' '
    beq 2f // do
    cmp w2, '\t'
    beq 2f
//    cmp x0, #0
//    beq 12f
    cmp x0, #0
    beq last
    ldrb w4, [x3], #1               //w4 = second character
    sub x0, x0, #1
    add x7, x7, #1
    cbz w4, 5f // do
    cmp w4, '\n'
    beq 5f
    cmp w4, ' '
    beq 5f // do
    cmp w4, '\t'
    beq 5f
    cmp x0, #0
    beq w4last

4:
    strb w4, [x6]
    add x6, x6, #1
    add x8, x8, #1
    str w2, [x6]
    add x6, x6, #1         //store 2 character and increase x6(bufout)
    add x8, x8, #1
    b 1b

w4last:
    strb w4, [x6]
    add x6, x6, #1
    add x8, x8, #1
    strb w2, [x6]
    add x6, x6, #1
    add x8, x8, #1

    b 11f


last:
    ldr x0, [x29, tmp]
    cmp x0, #16
    blt uberlast
    strb w2, [x29, flag]
    b 11f
uberlast:
    strb w2, [x6]
    add x6, x6, #1
    add x8, x8, #1
    b 11f

2:              //x7 nechetnii, zna4it bukva 4etnaya                    // end of buffer (cntrl d)

    cmp w2, '\n'
    beq 92f
   mov x7, #0
    b findnext

findnext:
    cmp x0, #0
    beq before11
    ldrb w2, [x3], #1
    sub x0,x0, #1
    cmp w2, '\n'
    beq 92f
    cmp w2, ' '
    beq findnext
    cmp w2, '\t'
    beq findnext
    ldrb w10, [x29, flag]
    cmp w10, ' '
    beq needspace
    mov w10, ' '
    strb w10, [x6]
    add x6, x6, #1
    add x8, x8, #1
    b after_before

before11:
    mov w10, ' '
    strb w10, [x29, flag]
    b 11f
5:
    strb w2, [x6]
    add x6, x6, #1
    add x8, x8, #1
    cbz w4, 11f
    cmp w4, '\n'
    beq 92f
    cmp x0, #0
    beq before115
    //mov w4, ' '
    //strb w4, [x6]
    //add x6, x6, #1
    //add x8, x8, #1
    mov x7, #0
    b findnext

before115:
    mov w10, ' '
    str w10, [x29, flag]
    b 11f

92:
    mov w2, '\n'
    strb w2, [x6]
    add x6, x6, #1
    add x8, x8, #1
    adr x10, fd2 
    ldr x0, [x10]
    add x1, x29, bufout
    mov x2, x8                  //x8 = kolvo simvolov v bufout
    mov x8, #64
    svc #0

    b 0b

11:
	adr x0, fd2
     ldr x0, [x0]
    add x1, x29, bufout
    mov x2, x8                  //x8 = kolvo simvolov v bufout
    mov x8, #64
    svc #0
    ldr x0, [x29, tmp]
    cmp x0, #16
    str wzr, [x29, tmp]
    beq bufferoverflow
    b 12f
bufferoverflow:
    ldrb w4, [x29, flag]
    cbz w4, before0
    ldr x0, [x29, f2]
    add x1, x29, bufin
    mov x0, #0
    mov	x2, #16              //change buffer number
	mov	x8, #63
	svc	#0
    str x0, [x29, tmp]
    add x6, x29, bufout
    mov x8, #0
    mov x3, x1
    cmp x0, #0
    ble 12f
    ldrb w2,[x3],#1
    sub x0, x0, #1
    add x7, x7, #1
    cmp w2, '\n'
    beq 9234f
    cmp w2, ' '
    beq 923f
    cmp w2, '\t'
    beq 923f
    ldrb w10, [x29, flag]
    cmp w10, ' '
    beq needspace
    strb w2,[x6]
    add x6, x6, #1
    add x8, x8, #1
    ldrb w4,[x29, flag] //?????
    add x7, x7, #1
    str wzr, [x29, flag]
    strb w4, [x6]
    add x6, x6, #1
    add x8, x8, #1
    b 1b


needspace:
    strb w10, [x6]
    add x6, x6, #1
    add x8, x8, #1
    str wzr, [x29, flag]
   b after_before


 9234:
    ldrb w10, [x29, flag]
    cmp w10, ' '
    beq 92b
 923:
    ldrb w10, [x29, flag]
    cmp w10, ' '
    beq findnext
    mov x7, #0
    ldrb w12, [x29, flag]
    str wzr, [x29, flag]
    strb w12, [x6]
    add x6, x6, #1
    add x8, x8, #1
    cmp w2, '\n'
    beq 92b
    cmp w2, ' '
    beq findnext
    cmp w2, '\t'
    beq findnext










12:
	ldp	x29, x30, [sp]
	mov	x16, #8240
	add	sp, sp, x16
	ret
	.size	work, .-work
	.type	writeerr, %function
	.data
usage:
	.string	"Program does not require parameters\n"
	.equ	usagelen, .-usage
nofile:
	.string	"No such file or directory\n"
	.equ	nofilelen, .-nofile
permission:
	.string	"Permission denied\n"
	.equ	permissionlen, .-permission
exist:
	.string	"File exists\n"
	.equ	existlen, .-exist
isdir:
	.string	"Is a directory\n"
	.equ	isdirlen, .-isdir
toolong:
	.string	"File name too long\n"
	.equ	toolonglen, .-toolong
readerror:
	.string "Error readig filename\n"
	.equ	readerrorlen, .-readerror
unknown:
	.string	"Unknown error\n"
	.equ	unknownlen, .-unknown
	.text
	.align	2
writeerr:
	cbnz	x0, 0f
	adr	x1, usage
	mov	x2, usagelen
	b	7f
0:
	cmp	x0, #-2
	bne	1f
	adr	x1, nofile
	mov	x2, nofilelen
	b	7f
1:
	cmp	x0, #-13
	bne	2f
	adr	x1, permission
	mov	x2, permissionlen
	b	7f
2:
	cmp	x0, #-17
	bne	3f
	adr	x1, exist
	mov	x2, existlen
	b	7f
3:
	cmp	x0, #-21
	bne	4f
	adr	x1, isdir
	mov	x2, isdirlen
	b	7f
4:
	cmp	x0, #-36
	bne	5f
	adr	x1, toolong
	mov	x2, toolonglen
	b	7f
5:
	cmp	x0, #1
	bne	6f
	adr	x1, readerror
	mov	x2, readerrorlen
	b	7f
6:
	adr	x1, unknown
	mov	x2, unknownlen
7:
	mov	x0, #2
	mov	x8, #64
	svc	#0
	ret
	.size	writeerr, .-writeerr
