//file already exists. rewrite? (new flag)
//buffer overflow
	.arch armv8-a
	.data
mes1:
	.string	"Usage:\n"
	.equ	mes1len, .-mes1
mes2:
	.string	"You must input parameter namefile\n"
	.equ	mes2len, .-mes2
mes3:
	.string	"Input string: \n"
	.equ	mes3len, .-mes3
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
    .skip 3
	.align	3
//fd:
//	.skip	8
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	ldr	x0, [sp]
	cmp	x0, #2
	beq	2f
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
    add x2, x2, #1
    b 0b
1:
//    mov x8, #64
//    svc #0
    mov x0, #2
    adr x1, mes2
    mov x2, mes2len
    mov x8, #64
    svc #0
    mov x0, #1
    b 1f
2:
    ldr x0, [sp, #16]
    bl work
    cmp x0, #0
    blt err_ex
    mov x0, #0
    b 1f
err_ex:
    bl writeerr
    mov x0, #1
    b 1f
1:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
	.type	work, %function
	.equ	filename, 16
	.equ	fd, 24
	.equ	tmp, 32
	.equ	flg, 40
	.equ	wrd, 44
	.equ	bufin, 48
	.equ	bufout, 64 //4144
	.text
	.align	2
work:
	mov	x16, #80 //#8240
	sub	sp, sp, x16
	stp	x29, x30, [sp]
	mov	x29, sp
	str	x0, [x29, filename]
	str	xzr, [x29, flg]
1:

   // b cont2
    b 0f
    mov x0, #0
    adr x1, filename
    mov x2, #1024
    mov x8, #63
    svc #0
    cmp x0, #1
    ble 2f
    b 0f
2:
    mov x0, #1
    ldp x29, x30, [sp]
    mov x16, #80 //#8240
    add sp, sp, x16
    ret
0:
    mov x0, #1
    adr x1, mes3
    mov x2, mes3len
    mov x8, #64
    svc #0
	mov x0, #0
	add	x1, x29, bufin
	mov	x2, #16//#4096
	mov	x8, #63
	svc	#0//
brrr:
    cmp x0, #0
    cbz x0, 11f
    blt not_sucess//!!!
    mov x13, x0
	add	x0, x0, x29
	add	x0, x0, bufin//end of info in bifin
	ldr	w1, [x29, flg]//1, 0 - now a word/between
	add	x3, x29, bufin//adress start of bufin
  //  ldrb w7, [x3]
 //   cbz w7, 11f
  //  mov w7, #0
	mov	x16, bufout
	add	x4, x29, x16//adress of start bufout
	ldr	w5, [x29, wrd]//number of symbols in string
	mov	w6, ' '
//    mov x12, #0
1:
//    cmp	x3, x0//x3
//	bge	11f//
//    cmp x12, #16
//    bge buf_overflow
//    add x12, x12, #1
	ldrb	w2, [x3], #1
	cbz	w2, 11f
	cmp	w2, '\n'
	beq	2f
	cmp	w2, ' '
	beq	check
	cmp	w2, '\t'
	beq	3f
    add w5, w5, #1
    mov w1, #1
    b 1b
buf_overflow:
    mov x0, #0
    add x1, x29, bufin
    mov x2, #16
    mov x8, #63
    svc #0
    b brrr
2:
    mov w1, #0
    b 10f
not_sucess:
    str x0, [x29, tmp]
    ldr x0, [x29, fd]
    mov x1, #0
    mov x8, #46
    svc #0
    ldr x0, [x29, tmp]
    b 14f
next_str://before open a file
//    strb w2, [x4]
    mov w2, '\n'
    strb w2, [x4], #1
/*    mov x0, #1
    adr x1, mes3
    mov x2, mes3len
    mov x8, #64
    svc #0 */
    str w1, [x29, flg]
    str w5, [x29, wrd]
    mov x0, #0
    mov x1, x3
    mov x2, #16//#4096
    mov x8, #63
    svc #0
    cmp x0, #0
    blt not_sucess//!!!
    mov w5, #0

    b 11f
//    b 0b
check:
    mov w1, #0
    mov x7, #0
    cmp x5, x7
    bhi 3f
    beq 1b
3:
    mov w1, #0
    tst w5, #1
    beq 4f//even
    bne odd//odd
4:
//    sub x3, x3, #1
    mov x7, x3//x7 - end of word
    add x5, x5, #1//
    sub x3, x3, x5
    b 5f
5:
    cmp x3, x7
    beq 6f
    ldrb w2, [x3], #1
    strb w2, [x4], #1
    b 5b
6:
    sub x4, x4, #1//
    strb w6, [x4], #1
    sub x3, x3, x5
    b 7f
7:
    cmp x3, x7
    beq 8f
    ldrb w2, [x3], #1
    cmp w2, '\n'
    beq next_str
    strb w2, [x4], #1
    b 7b
8:
    sub x4, x4, #1//
    strb w6, [x4], #1
  //  add x3, x3, #1
    mov w5, #0
    mov x3, x7
    b 1b
odd:
//    sub x3, x3, #1
    mov x7, x3
    add x5, x5, #1//
    sub x3, x3, x5
    b 9f
9:
    cmp x3, x7
    beq 8b
    ldrb w2, [x3], #1
    cmp w2, '\n'
    beq next_str
    strb w2, [x4], #1
    b 9b
10:
    strb w2, [x4]
    b 3b
11:
//    mov w2, #0
//    sub x4, x4, #2
//    strb w2, [x4], #1
    str w1, [x29, flg]
    str w5, [x29, wrd]
    ldr x0, [x29, filename]
//    mov x1, x0   //old strings in this place
//    mov x0, #-100
//    mov x2, #1
//    mov x8, #56
//    svc #0
/////////////////
  //  b continue//
cont2:
    mov x1, x0
    mov x0, #-100
    mov x2, #0xc1
    mov x3, #0600
    mov x8, #56
    svc #0
    cmp x0, #-17
    beq file_exist
////////
    cmp x0, #0
    blt exit_err//in this place i leave procedure1 and go to procedure2
 //   b 0b
    b 12f
continue:
    str x0, [x29, fd]
    mov x16, bufout
    add x1, x29, x16
    sub x2, x4, x1
    cbz x2, 0b
    str x2, [x29, tmp]
    b 12f
file_exist:
    //must do metka "file exist rewrite?
    //please restart a programm
    //exit
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
    beq 20f
    mov x0, #-17
    b exit_err
exit_err:
    ret
20:
    adr x1, ans
    ldrb w0, [x1]
    cmp w0, 'Y'
    beq 21f
    cmp w0, 'y'
    beq 21f
    cmp w0, 'N'
    beq 22f
    cmp w0, 'n'
    beq 22f
    mov x0, #-17
    b exit_err
21:
    ldr x0, [x29, filename]
    mov x1, x0
    mov x0, #-100
    mov x2, #0x201
    mov x8, #56
    svc #0
    cmp x0, #0
    blt exit_err
  //  b 0b//
    str x0, [x29, fd]
    b 12f
22:
    mov x0, #1
    adr x1, mes5
    mov x2, mes5len
    mov x8, #64
    svc #0
    mov x0, #-2
    b exit_err
12:
    ldr x0, [x29, fd]
    add x1, x29, bufout
  //  mov x2, #16
    sub x2, x4, x1
    mov x8, #64
    svc #0
   // b 14f//
    b close
close:
    ldr x0, [x29, fd]
    mov x8, #57
    svc #0
    b 14f
13:
    str x0, [x29, tmp]
    ldr x0, [x29, fd]
    mov x1, #0
    mov x8, #46
    svc #0
    ldr x0, [x29, tmp]
14:
	ldp	x29, x30, [sp]
	mov	x16, #80//#8240
	add	sp, sp, x16
	ret
err1:
    bl writeerr
    mov x0, #1
    ret
	.size	work, .-work
	.type	writeerr, %function
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
