.arch armv8-a
.data
.align 3
n:
 .word 4
m:
 .word 4
matrix:
 .word 4, 2, 1, 8
 .word 0, 5, 4, -3
 .word 14, 11, 27, -9
res:
 .skip 16
 .text
 .align 2
 .global _start
 .type _start, %function
_start:
  adr x2, n
  ldrsw x0, [x2]
  adr x2, m
  ldrsw x1, [x2]
  adr x2, matrix
  mov x3, #0
L1:
  ldrsw x4, [x2, x3, lsl #2]
  add x5, x3, #1
  ldrsw x6, [x2, x5, lsl #2]
  cmp x4, x6
  bgt L2
  sub x7, x1, #1
  cmp x7, x5
  beq L3
  b L1
L2:
  str w4, [x2, x5, lsl #2]
  str w6, [x2, x3, lsl #2]
  add x3, x3, #2
  b L1
L3:
  sub x3, x3, #1
  b L1
