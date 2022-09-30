    .arch armv8-a
    .data
    .align 3
str:
    .word 5
col:
    .word 2
matrix:
    .word 5, 3
    .word 0, 1
    .word 2, -7
    .word 0, 7
    .word 7, 16
    .text
    .align 2
    .global _start
    .type _start, %function
_start:
    adr x2, str
    ldrsw x0, [x2]
    adr x2, col
    ldrsw x1, [x2]
    adr x2, matrix
    mov x3, #0//elements' iterator
    mov x4, #0//strings' iterator
    mov x5, #0//first index
    mov x6, x1//last index
    sub x6, x6, #1
    mov x9, #1//1 - change, 0 - ok
    mov x14, x0
    sub x14, x14, #1//saver index of col
    mov x15, #0//checker that all sorts maked
//nechet:
//bgt 3f
//bgt 2f
//chet:
//bgt 2f
//bgt 3f
//tst x4, #1
//beq chet
//bne nechet
1:
    tst x1, #1
    bne reverse_1
    cmp x3, x6
    bgt 2f//!!! 3f
    ldrsw x7, [x2, x3, lsl #2]//first elem
    add x3, x3, #1
    cmp x3, x6
    bgt 3f//!!! 2f
    ldrsw x8, [x2, x3, lsl #2]//second elem
    b 4f
reverse_1:
    cmp x3, x6
    bgt 3f
    ldrsw x7, [x2, x3, lsl #2]//first elem
    add x3, x3, #1
    cmp x3, x6
    bgt 2f
    ldrsw x8, [x2, x3, lsl #2]//second elem
    b 4f
2:
    add x15, x15, #1
    cmp x9, #0
    beq rem1//5f
    mov x9, #0
    mov x3, x5
    add x3, x3, #1
    b 1b
3:
    add x15, x15, #1
    cmp x9, #0
    beq rem2//5f
    mov x9, #0
    mov x3, x5
    b 1b
rem1:
    cmp x15, #2
    bge 5f
    mov x15, #0
    mov x9, #1
    b 2b
rem2:
    cmp x15, #2
    bge 5f
    mov x15, #0
    mov x9, #1
    b 3b
4:
    cmp x7, x8
.ifdef rev
    bgt move
    b unmove
.else
    blt move
    b unmove
.endif
move:
    sub x3, x3, #1
    str w8, [x2, x3, lsl #2]
    add x3, x3, #1
    str w7, [x2, x3, lsl #2]
    mov x9, #1
    add x3, x3, #1
    b 1b
unmove:
    sub x3, x3, #1
    str w7, [x2, x3, lsl #2]
    add x3, x3, #1
    str w8, [x2, x3, lsl #2]
    add x3, x3, #1
    b 1b
5:
    mov x15, #0
    add x4, x4, #1
    cmp x4, x14
    bgt exit
    umull x5, w4, w1//first index ??
    add x6, x5, x1//last index
    sub x6, x6, #1//last index too
    mov x3, x5//elements' iterator
    b 1b
exit:
    mov x0, #1
    mov x8, #93
    svc #0
         .size _start, .-_start
