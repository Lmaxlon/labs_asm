.arch armv8-a
//hword - 16/2, word - 32/4, quad 64/8
    .data
    .align 3
n:
    .word 5
m:
    .word 6
matrix:
    .word 4, 2, 1, 8
    .word 8, -5, 4, -3
    .word 14, 11, -27, 9
    .word 5, 0, 8, 7
    .word 7, 16, -199, 28
    .text
    .align 2
    .global _start
    .type _start, %function
_start:
    adr x2, n //strings
    ldrsw x0, [x2]
    adr x2, m //columns
    ldrsw x1, [x2]
    adr x2, matrix
    mov x3, #0//iterator
    mov x4, #1//1, 3, 5 - odd; 2, 4, 6 - even
    mov x7, #1//check sorting !!!0 to 1
    mov x9, x1//saver of columns
    mov x10, #1//strings iterator
l1:
    tst x4, #1
    beq even
    bne odd
odd:
    cmp x3, x1
    bge flag
    ldrsw x5, [x2, x3, lsl #2]//
    add x3, x3, #1//
    cmp x3, x1
    bgt flag
    ldrsw x6, [x2, x3, lsl #2]//
    sub x3, x3, #1//
    cmp x3, x1
    bgt flag
    cmp w5, w6
.ifdef rev
    bgt move
    b unmove
.else
    blt move
    b unmove
.endif
even:
    add x3, x3, #1
    cmp x3, x1
    bge flag
    ldrsw x5, [x2, x3, lsl #2]
    add x3, x3, #1
    cmp x3, x1
    bgt flag
    ldrsw x6, [x2, x3, lsl #2]
    sub x3, x3, #1
    cmp x3, x1
    bgt flag
    cmp w5, w6
.ifdef rev
    bgt move
    b unmove
.else
    blt move
    b unmove
.endif
move:
    str w6, [x2, x3, lsl #2]//
    add x3, x3, #1//
    str w5, [x2, x3, lsl #2]
    add x3, x3, #1
    mov x7, #1
    b l1
unmove:
    str w5, [x2, x3, lsl #2]
    add x3, x3, #1
    str w6, [x2, x3, lsl #2]
    add x3, x3, #1
    b l1
flag:
    add x4, x4, #1
    sub x3, x3, x9
    cmp x7, #0
    beq newstring
    mov x7, #0
    b l1
newstring:
    cmp x10, x0
    bge exit
    mov x4, #1
    mov x3, #0
    umull x3, w10, w9
    add x10, x10, #1
    umull x1, w10, w9
    mov x7, #1//!!!added new string in ths plce
    b l1
exit:
    mov x0, #1
    mov x8, #93
    svc #0
         .size _start, .-_start
