; ==============================================================================
; Глава 7: Полная программа FizzBuzz в FASM x64
; Классическая задача: числа от 1 до 30.
;   - Если число кратно 3 и 5 -> "FizzBuzz"
;   - Если число кратно 3     -> "Fizz"
;   - Если число кратно 5     -> "Buzz"
;   - Иначе                   -> само число
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szHeader    db '=== Chapter 7: FizzBuzz x64 (1 to 30) ===', 10, 0
    szFizzBuzz  db '%2d: FizzBuzz', 10, 0
    szFizz      db '%2d: Fizz', 10, 0
    szBuzz      db '%2d: Buzz', 10, 0
    szNumber    db '%2d: %d', 10, 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 40

    lea rcx, [szHeader]
    call [printf]

    mov ebx, 1          ; i = 1

.loop_start:
    cmp ebx, 30
    jg .loop_done

    ; Проверяем деление на 15
    mov eax, ebx
    xor edx, edx
    mov ecx, 15
    div ecx             ; edx = remainder
    test edx, edx
    jz .print_fizzbuzz

    ; Проверяем деление на 3
    mov eax, ebx
    xor edx, edx
    mov ecx, 3
    div ecx
    test edx, edx
    jz .print_fizz

    ; Проверяем деление на 5
    mov eax, ebx
    xor edx, edx
    mov ecx, 5
    div ecx
    test edx, edx
    jz .print_buzz

    ; Печатаем число
    lea rcx, [szNumber]
    mov edx, ebx
    mov r8d, ebx
    call [printf]
    jmp .next_iter

.print_fizzbuzz:
    lea rcx, [szFizzBuzz]
    mov edx, ebx
    call [printf]
    jmp .next_iter

.print_fizz:
    lea rcx, [szFizz]
    mov edx, ebx
    call [printf]
    jmp .next_iter

.print_buzz:
    lea rcx, [szBuzz]
    mov edx, ebx
    call [printf]

.next_iter:
    inc ebx
    jmp .loop_start

.loop_done:
    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
