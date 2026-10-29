; ==============================================================================
; Глава: Вещественные Числа (SSE Float & Double) в FASM x64
; Эквивалент на C:
;   double compute(double r, double h) {
;       const double PI = 3.141592653589793;
;       return PI * r * r * h; // объем цилиндра
;   }
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Section 2: Floating Point Arithmetic (SSE2) ===', 10, 0
    szSingleFmt db 'Single-Precision (32-bit float): 5.5 + 2.25 = %f, sqrt(16.0) = %f', 10, 0
    szDoubleFmt db 'Double-Precision (64-bit double): Cylinder Volume (r=3.0, h=5.0) = %f', 10, 0

    val_f1      dd 5.5
    val_f2      dd 2.25
    val_16      dd 16.0

    val_r       dq 3.0
    val_h       dq 5.0
    val_pi      dq 3.141592653589793

section '.text' code readable executable
main:
    push rbx
    sub rsp, 48

    lea rcx, [szTitle]
    call [printf]

    ; --- 1. Одинарная точность (Float, 32 бита) ---
    movss xmm0, [val_f1]
    addss xmm0, [val_f2]        ; xmm0 = 7.75f
    cvtss2sd xmm1, xmm0         ; преобразуем во float64 (double) для передачи в printf

    movss xmm2, [val_16]
    sqrtss xmm2, xmm2           ; xmm2 = 4.0f
    cvtss2sd xmm3, xmm2         ; преобразуем в double

    ; В Microsoft x64 ABI аргументы с плавающей точкой в variadic printf
    ; передаются ОДНОВРЕМЕННО в XMM и соответствующих целочисленных регистрах:
    ; 1-й float аргумент: RDX и XMM1
    ; 2-й float аргумент: R8 и XMM2
    lea rcx, [szSingleFmt]
    movq rdx, xmm1
    movq r8, xmm3
    movapd xmm2, xmm3
    call [printf]

    ; --- 2. Двойная точность (Double, 64 бита) ---
    ; Вычисляем объем цилиндра: V = PI * r * r * h
    movsd xmm0, [val_r]
    movsd xmm1, [val_h]
    call cylinder_volume

    ; Результат вернулся в XMM0
    lea rcx, [szDoubleFmt]
    movq rdx, xmm0
    movapd xmm1, xmm0
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

; ------------------------------------------------------------------------------
; double cylinder_volume(double r [XMM0], double h [XMM1])
; ------------------------------------------------------------------------------
cylinder_volume:
    mulsd xmm0, xmm0            ; r * r
    mulsd xmm0, xmm1            ; r * r * h
    mulsd xmm0, [val_pi]        ; PI * r * r * h
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
