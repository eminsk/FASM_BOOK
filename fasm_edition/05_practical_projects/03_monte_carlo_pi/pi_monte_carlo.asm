; ==============================================================================
; Практический Проект 3: Вычисление Числа Пи Методом Монте-Карло (SSE2 Float)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

TOTAL_DARTS = 1000000

section '.rdata' data readable
    szTitle     db '==================================================', 10
                db '   Monte Carlo PI Estimation (1,000,000 Darts)    ', 10
                db '==================================================', 10, 0
    szProgress  db 'Simulating %d random points using SSE2 FP unit...', 10, 0
    szResult    db 'Hits in circle: %d / %d', 10
                db 'Estimated PI:   %.6f', 10
                db 'True PI:        3.141593', 10
                db 'Absolute Error: %.6f', 10, 0

    val_one     dq 1.0
    val_four    dq 4.0
    val_true_pi dq 3.141592653589793
    rand_max_inv dq 0.00003051850947599719

    align 16
    abs_mask dq 0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF

section '.data' data readable writeable
    hits        dd 0
    rng_state   dd 123456789

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 48

    lea rcx, [szTitle]
    call [printf]

    lea rcx, [szProgress]
    mov edx, TOTAL_DARTS
    call [printf]

    mov ebx, TOTAL_DARTS
    xor esi, esi

.dart_loop:
    call next_random_float
    movsd xmm2, xmm0

    call next_random_float
    movsd xmm3, xmm0

    mulsd xmm2, xmm2
    mulsd xmm3, xmm3
    addsd xmm2, xmm3

    comisd xmm2, [val_one]
    ja .miss
    inc esi

.miss:
    dec ebx
    jnz .dart_loop

    mov [hits], esi

    cvtsi2sd xmm0, esi
    mov eax, TOTAL_DARTS
    cvtsi2sd xmm1, eax
    divsd xmm0, xmm1
    mulsd xmm0, [val_four]

    movsd xmm1, xmm0
    subsd xmm1, [val_true_pi]
    andpd xmm1, dqword [abs_mask]

    lea rcx, [szResult]
    mov edx, esi
    mov r8d, TOTAL_DARTS
    movq r9, xmm0
    movq rax, xmm1
    mov [rsp + 32], rax
    call [printf]

    add rsp, 48
    pop rdi
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

next_random_float:
    mov eax, [rng_state]
    imul eax, 1664525
    add eax, 1013904223
    mov [rng_state], eax

    shr eax, 16
    and eax, 0x7FFF

    cvtsi2sd xmm0, eax
    mulsd xmm0, [rand_max_inv]
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
