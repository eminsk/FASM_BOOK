; ==============================================================================
; Глава: Конвертация и Округление Вещественных Чисел (SSE Rounding)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle      db '=== Chapter: Floating Point Conversion and Rounding Modes ===', 10, 0
    szConvertFmt db '1. Int to Double: %d -> %f', 10, 0
    szTruncFmt   db '2. Truncation towards zero (cvttsd2si): %f -> %d', 10, 0
    szRoundFmt   db '3. Rounding Modes for %f:', 10
                 db '   - Floor (round down): %f', 10
                 db '   - Ceil  (round up):   %f', 10
                 db '   - Nearest even:       %f', 10, 0

    val_test    dq 3.75
    val_neg     dq -3.75

section '.text' code readable executable
main:
    push rbx
    sub rsp, 48

    lea rcx, [szTitle]
    call [printf]

    ; 1. Конвертация Int -> Double (cvtsi2sd)
    mov eax, 12345
    cvtsi2sd xmm0, eax

    lea rcx, [szConvertFmt]
    mov edx, 12345
    movq r8, xmm0
    movapd xmm2, xmm0
    call [printf]

    ; 2. Усечение Double -> Int (cvttsd2si)
    movsd xmm0, [val_test]
    cvttsd2si edx, xmm0     ; edx = 3

    lea rcx, [szTruncFmt]
    movq rdx, xmm0
    movapd xmm1, xmm0
    mov r8d, 3
    call [printf]

    ; 3. Округление (roundsd)
    ; Mode 0x01 = Floor (округление вниз)
    ; Mode 0x02 = Ceil  (округление вверх)
    ; Mode 0x00 = Nearest (к ближайшему)
    movsd xmm0, [val_test]
    roundsd xmm1, xmm0, 1   ; floor = 3.0
    roundsd xmm2, xmm0, 2   ; ceil  = 4.0
    roundsd xmm3, xmm0, 0   ; nearest = 4.0

    lea rcx, [szRoundFmt]
    movq rdx, xmm0
    movq r8,  xmm1
    movq r9,  xmm2
    movq rax, xmm3
    mov [rsp + 32], rax
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
