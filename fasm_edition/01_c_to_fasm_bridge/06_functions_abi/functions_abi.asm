; ==============================================================================
; Глава 6: Функции, Стек и Microsoft x64 Calling Convention
; Эквивалент на C:
;   long long sum6(long long a, long long b, long long c,
;                  long long d, long long e, long long f) {
;       return a + b + c + d + e + f;
;   }
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szHeader    db '=== Chapter 6: Function Call ABI and 6-Parameter Sum ===', 10, 0
    szResult    db 'sum6(10, 20, 30, 40, 50, 60) = %lld (Expected: 210)', 10, 0
    szMatch     db 'Verification: PASS! x64 ABI Stack Frame is 100%% Correct.', 10, 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    ; Выделяем место в стеке:
    ; 32 байта (Shadow space для sum6)
    ; + 16 байт (для 5-го и 6-го параметров: 2 * 8 = 16)
    ; + 8 байт (для выравнивания стека по 16 байт)
    ; Итого: 32 + 16 + 8 = 56 байт
    sub rsp, 56

    lea rcx, [szHeader]
    call [printf]

    ; Подготовка аргументов для sum6:
    ; 1-й: RCX = 10
    ; 2-й: RDX = 20
    ; 3-й: R8  = 30
    ; 4-й: R9  = 40
    ; 5-й: [RSP + 32] = 50
    ; 6-й: [RSP + 40] = 60
    mov rcx, 10
    mov rdx, 20
    mov r8,  30
    mov r9,  40
    mov qword [rsp + 32], 50
    mov qword [rsp + 40], 60
    call sum6

    ; Результат вернулся в RAX
    mov rbx, rax

    lea rcx, [szResult]
    mov rdx, rbx
    call [printf]

    cmp rbx, 210
    jne .skip_pass
    lea rcx, [szMatch]
    call [printf]

.skip_pass:
    xor ecx, ecx
    call [ExitProcess]

; ------------------------------------------------------------------------------
; Функция: sum6(a, b, c, d, e, f)
; Принимает:
;   RCX = a
;   RDX = b
;   R8  = c
;   R9  = d
; Стек вызывающей стороны:
;   [RSP + 8]  - сохраненный RIP (адрес возврата)
;   [RSP + 16] - начало Shadow Space вызывающего (32 байта)
;   [RSP + 40] - 5-й аргумент (e)
;   [RSP + 48] - 6-й аргумент (f)
; ------------------------------------------------------------------------------
sum6:
    ; Суммируем первые 4 параметра из регистров
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9

    ; Считываем 5-й и 6-й параметры из стека вызывающей стороны
    add rax, qword [rsp + 40]
    add rax, qword [rsp + 48]

    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
