; ==============================================================================
; Глава 3: Циклы (While, For, Break, Continue) в FASM x64
; Эквивалент на C:
;   int i = 0;
;   while (i < 5) { printf("while: %d\n", i); i++; }
;   for (int j = 1; j <= 10; j++) {
;       if (j == 3) continue; // пропуск
;       if (j == 7) break;    // ранний выход
;       printf("for: %d\n", j);
;   }
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szWhileFmt    db '  [while loop] i = %d', 10, 0
    szForFmt      db '  [for loop] j = %d', 10, 0
    szHeaderWhile db '=== 1. While Loop Demo (0 to 4) ===', 10, 0
    szHeaderFor   db '=== 2. For Loop Demo with Continue (skip 3) & Break (stop at 7) ===', 10, 0
    szFinished    db '=== Loops Demonstration Finished Successfully ===', 10, 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 40

    ; 1. Заголовок While
    lea rcx, [szHeaderWhile]
    call [printf]

    ; Инициализация i = 0
    xor ebx, ebx

.while_loop:
    cmp ebx, 5
    jge .while_done

    lea rcx, [szWhileFmt]
    mov edx, ebx
    call [printf]

    inc ebx
    jmp .while_loop

.while_done:
    ; 2. Заголовок For
    lea rcx, [szHeaderFor]
    call [printf]

    ; Инициализация j = 1 в регистре rsi
    mov esi, 1

.for_loop:
    cmp esi, 10
    jg .for_done

    ; Проверка на continue: если j == 3, пропускаем печать
    cmp esi, 3
    je .for_continue

    ; Проверка на break: если j == 7, прерываем цикл
    cmp esi, 7
    je .for_break

    lea rcx, [szForFmt]
    mov edx, esi
    call [printf]

.for_continue:
    inc esi
    jmp .for_loop

.for_break:
    ; Выход из цикла по условию break

.for_done:
    lea rcx, [szFinished]
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
