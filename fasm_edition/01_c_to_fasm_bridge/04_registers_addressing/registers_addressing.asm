; ==============================================================================
; Глава 4: Регистры, Размеры Данных и Режимы Адресации в x86-64
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szTitle         db '=== Chapter 4: x86-64 Registers and Addressing Modes ===', 10, 0
    szZeroExtFmt    db '1. 32-bit write zero-extension: RAX = 0x%016llX (High 32 bits cleared!)', 10, 0
    szSubRegsFmt    db '2. Sub-registers: EAX=0x%08X, AX=0x%04X, AL=0x%02X, AH=0x%02X', 10, 0
    szAddressFmt    db '3. Array addressing: array[%d] at offset %d = %d', 10, 0
    szLeaFmt        db '4. LEA instruction arithmetic (x*5 + 100): input=%d -> result=%d', 10, 0

    ; Массив из 5 32-битных целых чисел (DWORD)
    my_array        dd 100, 200, 300, 400, 500

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 40

    lea rcx, [szTitle]
    call [printf]

    ; --- 1. Zero-extension при записи в младшие 32 бита ---
    ; Заполняем RAX всеми единицами (0xFFFFFFFFFFFFFFFF)
    mov rax, -1
    ; Пишем в 32-битный EAX значение 0x12345678.
    ; В архитектуре x86-64 процессор АВТОМАТИЧЕСКИ обнуляет старшие 32 бита RAX!
    mov eax, 0x12345678

    lea rcx, [szZeroExtFmt]
    mov rdx, rax
    call [printf]

    ; --- 2. Доступ к субрегистрам ---
    mov eax, 0xAABBCCDD
    movzx ebx, ax       ; AX = 0xCCDD
    movzx esi, al       ; AL = 0xDD
    movzx edi, ah       ; AH = 0xCC

    lea rcx, [szSubRegsFmt]
    mov edx, eax
    mov r8d, ebx
    mov r9d, esi
    ; 5-й аргумент для printf передается через стек [RSP + 32]
    mov qword [rsp + 32], rdi
    call [printf]

    ; --- 3. Комплексная адресация: [base + index*scale + displacement] ---
    ; Читаем элемент array[3] (индекс 3, масштаб 4 байта)
    mov rsi, 3
    mov edx, [my_array + rsi*4]   ; чтение по формуле адреса

    lea rcx, [szAddressFmt]
    mov edx, esi                  ; index = 3
    lea r8d, [rsi*4]              ; offset = 12
    mov r9d, [my_array + rsi*4]   ; value = 400
    call [printf]

    ; --- 4. Инструкция LEA (Load Effective Address) для быстрой математики ---
    ; Вычисляем x * 5 + 100 за 2 инструкции LEA без умножения!
    ; Пусть x = 12
    mov eax, 12
    ; LEA edx, [rax + rax*4]  => edx = 12 + 48 = 60 (x * 5)
    lea edx, [rax + rax*4]
    ; LEA edx, [rdx + 100]    => edx = 60 + 100 = 160
    lea edx, [rdx + 100]

    lea rcx, [szLeaFmt]
    mov edx, eax                  ; input = 12
    lea r8d, [rax + rax*4 + 100]  ; result = 160
    call [printf]

    add rsp, 40
    pop rdi
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
