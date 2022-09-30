.arch armv8-a
//	res=(a*e-b*c+d/b)/((b+c)*a)
//hword - 16/2, word - 32/4, quad - 64/8
	.data
	.align	3
res:
	.skip	8
//w1
a:
	.hword	80
//w2
b:
	.hword	25  //0
//w3
c:
	.word   800000 //800
//w4
d:
	.hword  600
//w5
e:
	.word	300  //4294967294

	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr	x0, a
	ldrsh	w1, [x0]
	adr	x0, b
	ldrsh	w2, [x0]
	adr	x0, c
	ldrsh	x3, [x0]
	adr	x0, d
	ldrsh	w4, [x0]
	adr	x0, e
	ldrsh	w5, [x0]
//start program
    umull   x6, w5, w1
    umull  x7, w2, w3
    cmp    w2, w4
    bgt    exit
    udiv   w8, w4, w2
    cmp    x6, x7
    blt    exit
    subs   x9, x6, x7
    adds   x10, x9, x8
    adds   w11, w2, w3
    umull  x12, w1, w11
    cmp    x12, x10
    bgt    exit
    udiv   x8, x10, x12
	adr	x0, res
	str	x8, [x0]
	mov	x0, #0
	mov	x8, #93
	svc	#0
exit:
    mov x0, #1
    mov x8, #93
    svc #0
	.size	_start, .-_start
