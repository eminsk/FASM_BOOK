; ==============================================================================
; Глава 9: Секции Памяти: .rdata (const), .data (rw), .bss (uninitialized)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

; 1. Секция констант (Только для чтения - READ-ONLY)
section '.rdata' data readable
    szTitle         db '=== Chapter 9: PE64 Memory Sections (.rdata, .data, .bss) ===', 10, 0
    szConstString   db 'Immutable constant string located in .rdata section', 0
    PI_APPROX       dq 3.141592653589793
    szReportFmt     db 'Read-only string: "%s"', 10
                    db 'Mutable counter: %d -> incremented to %d', 10
                    db 'BSS buffer formatted dynamically: "%s"', 10, 0

; 2. Секция инициализированных данных (Чтение и Запись - READ/WRITE)
section '.data' data readable writeable
    counter         dd 100
    szBssFmt        db 'Formatted into BSS memory! (prev counter = %d)', 0

; 3. Секция неинициализированных данных (.bss - Чтение и Запись)
section '.bss' readable writeable
    buffer          rb 256

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 56

    lea rcx, [szTitle]
    call [printf]

    ; 1. Чтение из .data и модификация
    mov ebx, [counter]
    inc dword [counter]
    mov esi, [counter]

    ; 2. Запись в буфер в секции .bss
    lea rcx, [buffer]
    lea rdx, [szBssFmt]
    mov r8d, ebx
    call [sprintf]

    ; 3. Печать отчета
    lea rcx, [szReportFmt]
    lea rdx, [szConstString]
    mov r8d, ebx
    mov r9d, esi
    lea rax, [buffer]
    mov [rsp + 32], rax
    call [printf]

    add rsp, 56
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', sprintf, 'sprintf', exit, 'exit'
