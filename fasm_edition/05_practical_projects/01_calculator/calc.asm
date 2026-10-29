; ==============================================================================
; Практический Проект 1: Консольный Калькулятор Выражений (Expression Calculator)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '==================================================', 10
                db '   FASM x64 Native Calculator & Expression Parser  ', 10
                db '==================================================', 10, 0
    szCalcTest  db 'Test 1: %d + %d = %d', 10
                db 'Test 2: %d - %d = %d', 10
                db 'Test 3: %d * %d = %d', 10
                db 'Test 4: %d / %d = %d (Remainder: %d)', 10, 0
    szParseFmt  db 'Parsed expression "%s" -> Result = %d', 10, 0

    test_expr   db '100 + 45', 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 64

    lea rcx, [szTitle]
    call [printf]

    ; 1. Базовые арифметические тесты
    mov ebx, 120
    mov esi, 45

    ; сложение
    lea eax, [ebx + esi]
    ; вычитание
    mov edi, ebx
    sub edi, esi
    ; умножение
    mov edx, ebx
    imul edx, esi
    ; деление
    mov eax, ebx
    xor edx, edx
    div esi

    ; Выводим результаты
    lea rcx, [szCalcTest]
    mov edx, ebx        ; 120
    mov r8d, esi        ; 45
    lea r9d, [ebx + esi]; 165
    mov [rsp + 32], rbx ; 120
    mov [rsp + 40], rsi ; 45
    mov [rsp + 48], rdi ; 75
    call [printf]

    ; 2. Парсинг строки '100 + 45'
    lea rcx, [test_expr]
    call parse_simple_expression

    lea rcx, [szParseFmt]
    lea rdx, [test_expr]
    mov r8d, eax
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

; ------------------------------------------------------------------------------
; int parse_simple_expression(const char* str [RCX])
; ------------------------------------------------------------------------------
parse_simple_expression:
    push rbx
    push rsi
    push rdi
    sub rsp, 48

    mov rsi, rcx

    xor ebx, ebx
.read_num1:
    movzx eax, byte [rsi]
    cmp al, ' '
    je .skip_space1
    cmp al, '0'
    jb .got_op
    cmp al, '9'
    ja .got_op
    sub al, '0'
    imul ebx, 10
    add ebx, eax
.skip_space1:
    inc rsi
    jmp .read_num1

.got_op:
    movzx edi, al
    inc rsi

    xor r8d, r8d
.read_num2:
    movzx eax, byte [rsi]
    test al, al
    jz .calc
    cmp al, ' '
    je .skip_space2
    cmp al, '0'
    jb .calc
    cmp al, '9'
    ja .calc
    sub al, '0'
    imul r8d, 10
    add r8d, eax
.skip_space2:
    inc rsi
    jmp .read_num2

.calc:
    cmp dil, '+'
    je .op_add
    cmp dil, '-'
    je .op_sub
    cmp dil, '*'
    je .op_mul
    cmp dil, '/'
    je .op_div

.op_add:
    lea eax, [ebx + r8d]
    jmp .done
.op_sub:
    mov eax, ebx
    sub eax, r8d
    jmp .done
.op_mul:
    mov eax, ebx
    imul eax, r8d
    jmp .done
.op_div:
    mov eax, ebx
    xor edx, edx
    test r8d, r8d
    jz .div_zero
    div r8d
    jmp .done
.div_zero:
    xor eax, eax

.done:
    add rsp, 48
    pop rdi
    pop rsi
    pop rbx
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
