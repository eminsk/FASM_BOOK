; ==============================================================================
; Глава 5: Switch-Case и Таблицы Переходов (Jump Tables) в FASM x64
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szHeader    db '=== Chapter 5: Jump Table Switch-Case Demonstration ===', 10, 0
    szCase0     db '  [JumpTable] CMD 0: Initialize System', 10, 0
    szCase1     db '  [JumpTable] CMD 1: Process Audio', 10, 0
    szCase2     db '  [JumpTable] CMD 2: Render Frame', 10, 0
    szCase3     db '  [JumpTable] CMD 3: Save Data', 10, 0
    szDefault   db '  [JumpTable] DEFAULT: Unknown Command ID (%d)', 10, 0

    ; Таблица 64-битных адресов меток (QWORD)
    align 8
    jump_table  dq case_0, case_1, case_2, case_3
    MAX_CASES   = 4

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 40

    lea rcx, [szHeader]
    call [printf]

    ; Тестируем команды 0, 1, 2, 3, а также некорректную 99
    mov esi, 0

.test_loop:
    cmp esi, 5
    jge .done

    mov ecx, esi
    cmp esi, 4
    jne .do_dispatch
    mov ecx, 99 ; для 4-й итерации проверим некорректную команду 99

.do_dispatch:
    call dispatch_command

    inc esi
    jmp .test_loop

.done:
    add rsp, 40
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

; ------------------------------------------------------------------------------
; Функция dispatch_command(cmd in ECX)
; ------------------------------------------------------------------------------
dispatch_command:
    sub rsp, 40

    mov edx, ecx        ; сохраняем команду для default

    ; 1. Проверка диапазона (Bounds Check)
    cmp ecx, 0
    jl case_default
    cmp ecx, MAX_CASES
    jge case_default

    ; 2. Косвенный переход по таблице адресов (O(1) время выполнения!)
    movsxd rcx, ecx
    lea rax, [jump_table]
    jmp qword [rax + rcx*8]

case_0:
    lea rcx, [szCase0]
    call [printf]
    jmp case_end

case_1:
    lea rcx, [szCase1]
    call [printf]
    jmp case_end

case_2:
    lea rcx, [szCase2]
    call [printf]
    jmp case_end

case_3:
    lea rcx, [szCase3]
    call [printf]
    jmp case_end

case_default:
    lea rcx, [szDefault]
    call [printf]

case_end:
    add rsp, 40
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
