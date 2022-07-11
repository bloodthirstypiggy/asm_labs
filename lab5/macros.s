.macro pop, r
ldr \r, [sp], #8
.endm
.macro push, r
str \r, [sp, #-8]!
.endm
.macro inc, r
add \r, \r, #1
.endm
.macro dec, r
sub \r, \r, #1
.endm
.macro func_define, func
.global \func
.align 2
.type \func, %function
.endm
.macro push_registers
push x19
push x20
push x21
push x22
push x23
push x24
push x25
push x26
push x27
push x28
push x29
push x30
.endm
.macro pop_registers
pop x30
pop x29
pop x28
pop x27
pop x26
pop x25
pop x24
pop x23
pop x22
pop x21
pop x20
pop x19
.endm
