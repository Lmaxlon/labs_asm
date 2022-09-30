
    .arch armv8-a

    .data
    .align 2

EPSILON:
    .float 1e-7

no_file_arg:
    .asciz "No file argument provided\n"

file_open_error:
    .asciz "File open error\n"

size_not_positive:
    .asciz "n is not positive\n"

size_not_less_than_20:
    .asciz "n must be less than 20\n"

read_file_mode:
    .asciz "r"

scanf_float:
    .asciz "%f"
scanf_int:
    .asciz "%d"

print_float:
    .asciz "%f\n"

det_zero:
    .asciz "This system of equations is unsolvable or has multiple solutions\n"

    .text
    .align 2


    .macro push reg
        str \reg, [sp, #-8]!
    .endm
    .macro pop reg
        ldr \reg, [sp], #8
    .endm
    .macro matoffset res, x, y, cols
        madd \res, \y, \cols, \x
    .endm

    .type det, %function
det:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x0 = matrix
    // x1 = n

    push x0
    push x1

    add x0, x1, x1
    bl malloc
    mov x10, x0

    pop x2
    pop x0
    add x11, x10, x2

    mov x3, #0
    2:
        cmp x3, x2
        beq 1f
        strb w3, [x10, x3]
        add x3, x3, #1
        b 2b
    1:

    sub x2, x2, #1 // n - 1
    mov x1, #0

    fmov s0, wzr

    mov x3, #0
    mov x4, #1
    permute:
        cmp x1, x2
        beq compute_term

        strb w3, [x11, x1]

        cmp x1, x3
        beq 1f
            ldrb w12, [x10, x1]
            ldrb w13, [x10, x3]
            strb w13, [x10, x1]
            strb w12, [x10, x3]
            neg x4, x4
        1:

        add x1, x1, #1
        mov x3, x1
        b permute
    compute_term:
        mov x5, #0
        scvtf s1, x4//signed cvt fix point to swim point
        1:
            cmp x5, x2
            bgt 2f

            ldrb w6, [x10, x5]
            add x7, x2, #1
            matoffset x6, x6, x5, x7
            ldr s2, [x0, x6, lsl #2]

            fmul s1, s1, s2

            add x5, x5, #1
            b 1b
        2:
        fadd s0, s0, s1
    revert_permutation:
        cmp x1, #0
        beq exit_permutations

        sub x1, x1, #1
        ldrb w3, [x11, x1]

        cmp x1, x3
        beq 1f
            ldrb w12, [x10, x1]
            ldrb w13, [x10, x3]
            strb w13, [x10, x1]
            strb w12, [x10, x3]
            neg x4, x4
        1:

        add x3, x3, #1

        cmp x3, x2
        ble permute
        b revert_permutation
    exit_permutations:

    mov x0, x10
    bl free

    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    .size   det, (. - det)


    .global main
    .type main, %function
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    // x0 = argc
    // x1 = argv

    cmp x0, #1
    bne 1f
        // no first argument
        adr x0, no_file_arg
        bl printf
        b exit
    1:

    ldr x0, [x1, #8]   // char* filename
    adr x1, read_file_mode
    bl fopen

    cmp x0, xzr
    bne 1f
        adr x0, file_open_error
        bl printf
        b exit
    1:
    mov x28, x0

    adr x1, scanf_int
    push xzr
    mov x2, sp
    bl fscanf

    pop x19
    cmp x19, xzr
    bgt 1f
        adr x0, size_not_positive
        bl printf
        b exit
    1:
    cmp x19, #20
    blt 1f
        adr x0, size_not_less_than_20
        bl printf
        b exit
    1:

    mul x0, x19, x19 // n * n
    lsl x0, x0, #2  // n * n * 4
    bl malloc

    mov x20, x0 // float* matrix = malloc()

    mov x21, #0
    read_matrix:
        cmp x21, x19 // x
        bge 1f

        mov x22, #0
        read_col:
            cmp x22, x19 // y
            bge 2f

            mov x0, x28
            adr x1, scanf_float
            matoffset x2, x21, x22, x19
            add x2, x20, x2, lsl #2 // &matrix[y * n + x]
            bl fscanf

            add x22, x22, #1
            b read_col
        2:

        add x21, x21, #1
        b read_matrix
    1:

    lsl x0, x19, #2  // n * 4
    bl malloc

    mov x21, x0 // float* x = malloc()

    mov x22, #0
    read_x:
        cmp x22, x19 // i
        bge 1f

        mov x0, x28
        adr x1, scanf_float
        add x2, x21, x22, lsl #2
        bl fscanf

        add x22, x22, #1
        b read_x
    1:

    mov x0, x20 // matrix
    mov x1, x19 // n
    bl det

    fmov s8, s0

    adr x0, EPSILON
    ldr s2, [x0]
    fabs s1, s0
    fcmp s1, s2
    bgt 1f
        adr x0, det_zero
        bl printf
        b exit
    1:

    mul x0, x19, x19 // n * n
    lsl x0, x0, #2  // n * n * 4
    bl malloc

    mov x22, x0 // temp matrix

    mov x23, #0
    cramer:
        cmp x23, x19
        beq cramer_end

        // copy matrix
        mov x0, x22
        mov x1, x20
        mul x2, x19, x19 // n * n
        lsl x2, x2, #2  // n * n * 4
        bl memcpy

        mul x0, x23, x19
        add x0, x22, x0, lsl #2 // i-th row of matrix
        mov x1, x21 // x
        lsl x2, x19, #2  // n*4
        bl memcpy

        mov x0, x22
        mov x1, x19
        bl det

        fdiv s0, s0, s8

        adr x0, print_float
        fcvt d0, s0//cvt double to single
        bl printf

        add x23, x23, #1
        b cramer
    cramer_end:

    mov x0, x28
    bl fclose
exit:
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

    .size   main, (. - main)
