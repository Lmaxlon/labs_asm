    .arch armv8-a
    .data
mes1:
    .string "Usage:\n"
    .equ mes1len, .-mes1
mes2:
    .string "You must input parametr namefile\n"
    .equ mes2len, .-mes2
mes3:
    .string "Input string: \n"
    .equ mes3len, .-mes3
mes4:
    .string "File already exists! Rewrite?\n"
    .equ mes4len, .-mes4
mes5:
    .string "Ok, please restart a program\n"
    .equ mes5len, .-mes5
mes6:
    .string "Y/N\n"
    .equ mes6len, .-mes6
ans:
    .text
    .align 2
    .global _start
    .type _start, %function
_start:
    ldr x0, [sp]
    cmp x0, #2
    beq 2f
    mov x0, #2
    adr x1, mes1
    mov x2, mes1len
    mov x8, #64
    svc #0
    mov x0, #2
    ldr x1, [sp, #8]
    mov x2, #0
0:
    ldrb w3, [x1, x2]
    cbz w3, 1f
    add  x2, x2, #1
    b 0b
1:
    mov x0, #2
    adr x1, mes2
    mov x2, mes2len
    mov x8, #64
    svc #0
    mov x0, #1
    b 5f
2:
    mov x0, #-100
    ldr x1, [sp, #16]
    mov x2, #0xc1
    mov x3, #0600
    mov x8, #56
    svc #0
    cmp x0, #-17
    beq 3f
    cmp x0, #0
    blt 4f
l0:
    str x0, [sp, #24]
    bl work
    cmp x0, #0
    blt 4f
    mov x0, #0
    b 5f
3:
    mov x0, #1
    adr x1, mes4
    mov x2, mes4len
    mov x8, #64
    svc #0
    mov x0, #1
    adr x1, mes6
    mov x2, mes6len
    mov x8, #64
    svc #0
    mov x0, #0
    adr x1, ans
    mov x2, #3
    mov x8, #63
    svc #0
    cmp x0, #2
    beq 6f
    mov x0, #-17
    b 4f
4:
    bl writeerr
    mov x0, #1
    b 5f
5:
    mov x8, #93
    svc #0
6:
    adr x1, ans
    ldrb w0, [x1]
    cmp w0, 'Y'
    beq 7f
    cmp w0, 'y'
    beq 7f
    cmp w0, 'N'
    beq 8f
    cmp w0, 'n'
    beq 8f
    mov x0, #-17
    b 4b
7:
    mov x0, #-100
    ldr x1, [sp, #16]
    mov x2, #0x201
    mov x8, #56
    svc #0
    cmp x0, #0
    blt 4b
    b l0
8:
    mov x0, #1
    adr x1, mes5
    mov x2, mes5len
    mov x8, #64
    svc #0
    mov x0, #-2
    b 4b
    .size   _start, .-_start
    .type   work, %function
    .equ    filename, 16
    .equ    fd, 24
    .equ    bufin, 32
    .equ    bufout, 48
    .text
    .align 2
work:
    mov x16, #64
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
0:
    mov x0, #1
    adr x1, mes3
    mov x2, mes3len
    mov x8, #64
    svc #0
    mov x0, #0
    add x1, x29, bufin
    mov x2, #16
    mov x8, #63
    svc #0
    cmp x0, #0
//    cbz 1f
    blt 5f
    add x0, x0, x29
    add x0, x0, bufin//end info bufin
    add x3, x29, bufin//adress start bufin
    ldrb w6, [x1]
//    cbz w7, 1f
    mov w7, #0
    mov x16, bufout
    add x4, x29, x16//adress start bufout
    mov w6, ' '
1:
    cmp x3, x0
    bgt 4f
    ldrb w2, [x3], #1
    cbz w2, 15f
    cmp w2, '\n'
    beq 2f
    cmp w2, ' '
    beq 6f
    cmp w2, '\t'
    beq 3f
    add w5, w5, #1
    mov w1, #1
    b 1b
2:
    strb w2, [x4]
    b 3f
3:
    nop
    tst w5, #1
    beq 7f
    bne 8f
4:
    ldr x0, [x29, fd]
    add x1, x29, bufout
    mov x8, #64
    svc #0
    mov x0, #0
    add x1, x29, bufin
    mov x2, #16
    mov x8, #63
    svc #0
    cmp x0, #0
   // cbz 1f
    blt 5f
    b 1b
6:
    mov w7, #0
    cmp x5, x7
    bhi 3b
    beq 1b
7:
    mov x7, x3
    add x5, x5, #1
    sub x3, x3, x5
    b 10f
8:
    mov x7, x3
    add x5, x5, #1
    sub x3, x3, x5
    b 9f
9:
    cmp x3, x7
    beq 11f
    ldrb w2, [x3], #1
    cmp w2, '\n'
    beq 12f
    strb w2, [x4], #1
    b 9b
10:
    cmp x3, x7
    beq 13f
    ldrb w2, [x3], #1
    strb w2, [x4], #1
    b 10b
11:
    sub x4, x4, #1
    strb w6, [x4], #1
    mov w5, #0
    mov x3, x7
    b 1b
12:
    mov w2, '\n'
    strb w2, [x3], #1
    mov x0, #0
    mov x1, x3
    mov x2, #16
    mov x8, #63
    svc #0
   // cmp x0, #0
  //  blt
    mov w5, #0
    b 1b
13:
    sub x4, x4, #1
    strb w6, [x4], #1
    sub x3, x3, x5
    b 9b
14:
    adr x0, fd
    ldr x0, [x0]
    mov x8, #57
    svc #0
    b 16f
15:
    ldr x0, [x29, fd]
    add x1, x29, bufout
    mov x8, #64
    svc #0
    b 14b
16:
    ldp x29, x30, [sp]
    mov x16, #80
    add sp, sp, x16
    ret
    .type writeerr, %function
	.data
usage:
	.string	"Program does not require parameters\n"
	.equ	usagelen, .-usage
nofile:
	.string	"Error: No such file or directory\n"
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






















