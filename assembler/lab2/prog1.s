.arch armv8-a
//hword - 16/2, word - 32/4, quad - 64/8
	.data
	.align	3
n:
    .word 3
m:
    .word 5
matrix://64 bit to 32 bit must do
    //obratnya sortirovka with make
    //ldrsw for otricatelnye chisla
    .word 4, 2, 1, 8
    .word 14, 27, 3, 6
    .word 13, 5, 32, 21
    .word 12, 11, 7, 9
     //4, 2, 8, 1, 11
result:
    .skip 16
    .text
    .align 2
    .global _start
    .type _start, %function
_start:
    adr x2, n
    ldrsw x0, [x2]//strings
    adr x2, m
    ldrsw x1, [x2]//columns
    adr x2, matrix
    mov x3, #0//here was result(now there other iterator)
    mov w4, #0//iterator1
    mov w5, #1//iterator2
    mov w6, #0//checker sorting strings
    mov w9, #0//strings iterator
    mov w10, #0//plus iterators
    mov w11, w1
L0://NEED added info for next strings (iterators)
    cmp w4, w11
    bge nextsort
    cmp w5, w11
    bge nextsort
    ldrsw x6, [x2, x4, lsl #2]//ldrsw must do
    ldrsw x7, [x2, x5, lsl #2]
    cmp w6, w7
    bgt move1
    cmp w6, w7
    blt move2
nextsort:
    cmp w3, #1
    beq addnextsort
    mov w4, #1
    add w4, w4, w10
    mov x5, #2
    add x5, x5, x10
    mov w3, #1//flag nedeed then we remake sort
    b L0
addnextsort:
    mov w4, #0
    add w4, w4, w10
    mov w5, #1
    add w5, w5, w10
    mov w3, #0//flag remakes sorting
    cmp w8, #0
    beq nextstring
    mov w8, #0
    b L0
move1://signed greather than
    str w6, [x2, x5, lsl #2]
    str w7, [x2, x4, lsl #2]
    mov w8, #1
    b iterator
move2://signed less than
    str w6, [x2, x4, lsl #2]
    str w7, [x2, x5, lsl #2]
    b iterator
nextstring:
    cmp w9, w0
    beq exit
    //string - 1 ogr - 5 iter +5
    // 2 10 +5
    //3 15 +5
    add w10, w10, w1
    add w4, w4, w11
    add w5, w5, w11
    add w11, w11, w1
    add w9, w9, #1
    b L0
iterator:
    add w4, w4, #2//+1 iteration1 (index)
    add w5, w5, #2//+1 iteration2 (index)
    b L0
exit:
    mov x0, #1
    mov x8, #93
    svc #0
        .size _start, .-_start
