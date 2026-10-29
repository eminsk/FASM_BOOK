; ==============================================================================
; Глава: Вариативные Функции в Microsoft x64 ABI (Variadic Functions: printf/sprintf)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Chapter: Variadic Calls in Microsoft x64 ABI ===', 10, 0
    szFmt       db 'Variadic: Int=%d, Hex=0x%08X, Float=%.2f, Str="%s", 6th=%d, 7th=%d', 10, 0
    szText      db 'FASM Power', 0
    val_float   dq 42.75

section '.text' code readable executable
main:
    push rbx
    ; Резервируем место под параметры:
    ; 32 байта Shadow Space
    ; + 8 байт (5-й аргумент: указатель на строку szText)
    ; + 8 байт (6-й аргумент: число 888)
    ; + 8 байт (7-й аргумент: число 999)
    ; + 8 байт для 16-байтного выравнивания стека
    ; Итого: 32 + 24 + 8 = 64 байта
    sub rsp, 64

    lea rcx, [szTitle]
    call [printf]

    ; Microsoft x64 ABI для вариативных функций (printf):
    ; - 1-й аргумент: RCX (форматная строка)
    ; - 2-й аргумент: RDX (целое число 123)
    ; - 3-й аргумент: R8  (шестнадцатеричное число 0xDEADBEEF)
    ; - 4-й аргумент: R9 И XMM3 (двойное дублирование для float/double!)
    ; - 5-й аргумент: [RSP + 32] (указатель на szText)
    ; - 6-й аргумент: [RSP + 40] (888)
    ; - 7-й аргумент: [RSP + 48] (999)
    lea rcx, [szFmt]
    mov edx, 123
    mov r8d, 0xDEADBEEF

    movsd xmm3, [val_float]
    movq r9, xmm3               ; в variadic x64 ABI float передается и в XMM, и в GPR!

    lea rax, [szText]
    mov qword [rsp + 32], rax
    mov qword [rsp + 40], 888
    mov qword [rsp + 48], 999

    call [printf]

    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
