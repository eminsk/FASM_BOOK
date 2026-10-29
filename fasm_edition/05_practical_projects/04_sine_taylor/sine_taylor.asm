; ==============================================================================
; Практический Проект 4: Вычисление Синуса Рядом Тейлора (Taylor Series Sine)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '==================================================', 10
                db '   Taylor Series SINE in x64 SSE2 vs CRT sin()    ', 10
                db '==================================================', 10, 0
    szAngleFmt  db 'Angle: %5.1f deg (%8.5f rad):', 10
                db '  FASM Taylor sin(x): %10.7f', 10
                db '  MSVCRT std  sin(x): %10.7f', 10
                db '  Difference:         %10.2e', 10
                db '--------------------------------------------------', 10, 0

    deg_to_rad  dq 0.017453292519943295
    val_30      dq 30.0
    val_45      dq 45.0
    val_60      dq 60.0
    val_90      dq 90.0

    fact3_inv   dq 0.16666666666666666
    fact5_inv   dq 0.00833333333333333
    fact7_inv   dq 0.00019841269841269
    fact9_inv   dq 0.00000275573192239

    align 16
    abs_mask    dq 0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF

section '.text' code readable executable
main:
    push rbx
    push rsi
    ; 2 пуша (16 байт) + 8 байт адреса возврата = 24 байта.
    ; Чтобы выровнять стек по 16 байт, вычитаем 40 байт: 24 + 40 = 64 (кратно 16)
    sub rsp, 40

    lea rcx, [szTitle]
    call [printf]

    movsd xmm0, [val_30]
    call test_angle

    movsd xmm0, [val_45]
    call test_angle

    movsd xmm0, [val_60]
    call test_angle

    movsd xmm0, [val_90]
    call test_angle

    xor ecx, ecx
    call [ExitProcess]

test_angle:
    ; На входе в функцию RSP % 16 == 8 (адрес возврата в стеке).
    ; Вычитаем 104 байта: 104 + 8 = 112 (кратно 16). Стек идеально выровнен!
    sub rsp, 104

    movsd [rsp + 48], xmm0

    mulsd xmm0, [deg_to_rad]
    movsd [rsp + 56], xmm0

    call fasm_taylor_sin
    movsd [rsp + 64], xmm0

    movsd xmm0, [rsp + 56]
    call [sin]
    movsd [rsp + 72], xmm0

    movsd xmm1, [rsp + 64]
    subsd xmm1, xmm0
    andpd xmm1, dqword [abs_mask]

    lea rcx, [szAngleFmt]
    movsd xmm0, [rsp + 48]
    movq rdx, xmm0
    movsd xmm1, [rsp + 56]
    movq r8, xmm1
    movsd xmm2, [rsp + 64]
    movq r9, xmm2
    movsd xmm3, [rsp + 72]
    movq rax, xmm3
    mov [rsp + 32], rax
    movq rax, xmm1
    mov [rsp + 40], rax
    call [printf]

    add rsp, 104
    ret

fasm_taylor_sin:
    movsd xmm1, xmm0
    mulsd xmm1, xmm0

    movsd xmm2, xmm0
    mulsd xmm2, xmm1
    movsd xmm3, xmm2
    mulsd xmm3, [fact3_inv]

    movsd xmm4, xmm0
    subsd xmm4, xmm3

    mulsd xmm2, xmm1
    movsd xmm3, xmm2
    mulsd xmm3, [fact5_inv]
    addsd xmm4, xmm3

    mulsd xmm2, xmm1
    movsd xmm3, xmm2
    mulsd xmm3, [fact7_inv]
    subsd xmm4, xmm3

    mulsd xmm2, xmm1
    movsd xmm3, xmm2
    mulsd xmm3, [fact9_inv]
    addsd xmm4, xmm3

    movsd xmm0, xmm4
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', sin, 'sin', exit, 'exit'
