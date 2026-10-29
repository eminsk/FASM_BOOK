; ==============================================================================
; Глава: SIMD Векторизация (SSE Packed Floats 128-бит) в FASM x64
; Обработка 4 чисел float32 одновременно за одну инструкцию процессора!
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Chapter: SSE SIMD Vector Operations (4 x Float32) ===', 10, 0
    szVecAddFmt db 'Vector Addition [A + B]:', 10
                db '  A = (1.0, 2.0, 3.0, 4.0)', 10
                db '  B = (5.0, 6.0, 7.0, 8.0)', 10
                db '  R = (%.1f, %.1f, %.1f, %.1f)', 10, 0
    szDotFmt    db 'Dot Product [A . B] = %.2f (Expected: 1*5 + 2*6 + 3*7 + 4*8 = 70.0)', 10, 0

    align 16
    vecA        dd 1.0, 2.0, 3.0, 4.0
    vecB        dd 5.0, 6.0, 7.0, 8.0

section '.bss' readable writeable
    align 16
    vecResult   dd 4 dup (?)

section '.text' code readable executable
main:
    push rbx
    sub rsp, 88

    lea rcx, [szTitle]
    call [printf]

    ; 1. Векторное сложение 4-х компонентов (A + B)
    movaps xmm0, dqword [vecA]         ; xmm0 = (1.0, 2.0, 3.0, 4.0)
    movaps xmm1, dqword [vecB]         ; xmm1 = (5.0, 6.0, 7.0, 8.0)
    addps  xmm0, xmm1                  ; xmm0 = (6.0, 8.0, 10.0, 12.0)
    movaps dqword [vecResult], xmm0    ; сохраняем результат в память

    ; Печатаем результат сложения
    cvtss2sd xmm0, [vecResult + 0]
    cvtss2sd xmm1, [vecResult + 4]
    cvtss2sd xmm2, [vecResult + 8]
    cvtss2sd xmm3, [vecResult + 12]

    lea rcx, [szVecAddFmt]
    movq rdx, xmm0
    movq r8,  xmm1
    movq r9,  xmm2
    movq rax, xmm3
    mov [rsp + 32], rax
    call [printf]

    ; 2. Вычисление скалярного произведения (Dot Product: A . B)
    movaps xmm0, dqword [vecA]
    movaps xmm1, dqword [vecB]
    dpps xmm0, xmm1, 0xF1              ; xmm0[0] = 70.0f
    cvtss2sd xmm1, xmm0                ; xmm1 = 70.0 (double)

    lea rcx, [szDotFmt]
    movq rdx, xmm1
    movapd xmm1, xmm1
    call [printf]

    add rsp, 88
    pop rbx
    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
