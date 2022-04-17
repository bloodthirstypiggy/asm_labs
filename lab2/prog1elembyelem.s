	.arch armv8-a
	.data
    .align  2
matrix:
    .word -1, -2, -3, -4, -5, -6
    .word 7, 8, 9, 10, 11, 12
    .word -13, -14, -15, -16, -17, -18
    .word 19, 20, 21, -22, 23, 24
    //.word 5, 2, 6
    //.word 7,8,9
    //.word 1,2,3
maxs:
    .skip 16
    //.skip 12
n:
	.byte	4
    //.byte 3
m:
    .byte   6
    //.byte 3
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
    adr x2, n
    ldrsb x0, [x2] // x0 = n
    adr x2, m
    ldrsb x1, [x2] // x1 = m
    mov x2, #0
    adr x2, matrix // x2 = &matrix
    adr x3, maxs    // x3 = & maxs
    ldrsw x8, [x2,x4,lsl #2] // first element will be the greatest ?
    mov x4 ,#-1      // x4 = index inside string
    mov x5, #0    // x5 = index of strings
    mov x9, x2  //x9 =  &matrix
    mov x6, x1 // x6 = x1 + shift
    mov x11, #0 // x11 = i in gnome search
    mov x12, #1 // x12 = j in gnome search
    mov x13,#0 // x13 = a[i]
    mov x14,#0  // x14 = a[j]
    b L2
L3:
    lsl x10, x5, #2 // x10 = shift to store maxs
    str w8, [x3, x10] // x8 = localmax
    add x5,x5,#1
    cmp x5, x0
    bge L1_gnome_sort
    add x9, x9, x1, lsl#2
    mov x4, #0
    ldrsw x8, [x9,x4, lsl#2]
    mov x4, #-1
L2:
    add x4,x4, #1
    cmp x4, x6 //out of string check
    bge L3
    ldrsw x7, [x9, x4, lsl #2] // x7 = take another element
    cmp x7, x8 // check max
    ble L2
    mov x8, x7
    b L2
L1_gnome_sort:
    cmp x12, x0
    bge L1
    mov x5, #0
    ldrsw x13, [x3, x11, lsl #2]
    ldrsw x14, [x3, x12, lsl #2]
    cmp x13, x14
    .ifdef rev
    bgt L_gt
    add x11, x11, #1
    add x12, x12, #1
    b L1_gnome_sort
    .endif
    ble L_gt
    add x11, x11, #1
    add x12, x12, #1
    b L1_gnome_sort
L_gt:
    lsl x15, x11, #2 // x15 = for shift indexes
    str w14, [x3, x15]
    lsl x15, x12, #2
    str w13, [x3, x15]
    b rebuild_matrix
return_after_rebuild:
    ldrsw x13, [x3, x11, lsl#2]
    ldrsw x14, [x3, x12, lsl#2]
    cmp x11, #0
    bgt igreaternull
    add x11, x11, #1
    add x12, x12, #1
    b L1_gnome_sort
igreaternull:
    sub x11, x11, #1
    sub x12, x12, #1
    b L1_gnome_sort
rebuild_matrix:
    cmp x5,x1
    bge return_after_rebuild
    lsl x18, x1, #2
    mul x6, x11, x18
    lsl x19, x5, #2
    add x6, x6, x19
    ldrsw x8, [x2,x6] //x8 - reuse for buffer
    lsl x10, x1, #2
    add x9, x6, x10
    ldrsw x17, [x2, x9]
    str w17, [x2,x6] //x11 reuse for buffer
    str w8, [x2, x9]
    add x5, x5, #1
    b rebuild_matrix


L1:
    mov x0, #0
    mov x8, #93
    svc #0
	.size	_start, .-_start
