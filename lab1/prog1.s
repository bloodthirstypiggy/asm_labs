	.arch armv8-a
//	res=a*a*a + b*b*b / (a*a*c - b*b*d + e)
	.data
	.align	3
res:
	.skip	8
e:
	.long	10
b:
	.short	3
c:
	.short	1
d:
	.short	1
a:
	.short	1
	.text
	.align	2
	.global _start	
	.type	_start, %function
_start:
	adr	x0, a
	ldrh	w1, [x0]
	adr	x0, b
	ldrh	w2, [x0]
	adr	x0, c
	ldrh	w3, [x0]
	adr	x0, d
	ldrh	w4, [x0]
	adr	x0, e
	ldr	w8, [x0] // w8 for e
	mul	w5, w1, w1 // w5 is for a^3 and for b^3
	umull	x10, w5, w1 // x10 is for a^3
	mul	w5, w2, w2
	umull	x11, w5, w2 // x11 is for b^3
	adds	x10, x10, x11 //overbuf? a^3 + b^3  ! there won't be overbuf
	mul	w5, w1, w1 //w5 is for aac
	umull	x12, w5, w3 //x12 for aac
	mul	w5, w2, w2 // w5 also for bbd
	umull	x13, w5, w4 //x13 for bbd
	subs	x14,x12,x13 //overbuf? aac - bbd    ! there is an overbuf in here
	bcc	L0
	adds	x14, x14, w8, uxtw //aac-bbd +e in x7 register  ! there is an overbuf in here
	bcs	L0
	udiv	x14, x10, x14
	adr	x0, res
	str	x14, [x0]
	mov 	x0, #0 // no error
	b 	L1
  L0:
	mov	x0, #1 // error over here
  L1:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
