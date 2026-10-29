; ==============================================================================
; Глава 2: If / Else и условные переходы в FASM x64
; Эквивалент на C:
;   int a = 15, b = 20;
;   if (a < b) printf("a (%d) is less than b (%d)\n", a, b);
;   else       printf("a (%d) is greater or equal to b (%d)\n", a, b);
;   // Branchless conditional move (cmov):
;   int min_val = (a < b) ? a : b;
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szLess      db 'Branch Test: a (%d) is strictly LESS than b (%d)', 10, 0
    szGreaterEq db 'Branch Test: a (%d) is GREATER OR EQUAL to b (%d)', 10, 0
    szCmov      db 'CMOV Branchless Result: Minimum of (%d, %d) is %d', 10, 0

    valA        dd 15
    valB        dd 20

section '.text' code readable executable
main:
    sub rsp, 40

    mov eax, [valA]
    mov ebx, [valB]

    ; Сравнение a и b
    cmp eax, ebx
    jge .is_greater_or_equal

.is_less:
    lea rcx, [szLess]
    mov edx, eax
    mov r8d, ebx
    call [printf]
    jmp .test_cmov

.is_greater_or_equal:
    lea rcx, [szGreaterEq]
    mov edx, eax
    mov r8d, ebx
    call [printf]

.test_cmov:
    ; Демонстрация CMOV (Conditional Move без предсказания ветвлений)
    ; edx = valA, r8d = valB
    mov edx, [valA]
    mov r8d, [valB]
    mov r9d, edx        ; r9d = valA (предполагаем минимум)
    cmp r8d, edx        ; сравниваем valB с valA
    cmovl r9d, r8d      ; если valB < valA, r9d = valB

    lea rcx, [szCmov]
    call [printf]

    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
