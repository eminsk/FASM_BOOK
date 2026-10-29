; ==============================================================================
; Глава 1: Hello World (C-Runtime Edition)
; Эквивалент на C:
;   #include <stdio.h>
;   int main() {
;       puts("Hello from FASM x64 using MSVCRT!");
;       printf("Answer: %d\n", 42);
;       return 0;
;   }
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szHello db 'Hello from FASM x64 using MSVCRT!', 0
    szFmt   db 'Answer to life, the universe, and everything: %d', 10, 0

section '.text' code readable executable
main:
    ; Резервируем Shadow Space (32 байта) + 8 байт для 16-байтного выравнивания стека
    sub rsp, 40

    ; 1. Вызов puts(szHello)
    ; 1-й аргумент передается в RCX
    lea rcx, [szHello]
    call [puts]

    ; 2. Вызов printf(szFmt, 42)
    ; 1-й аргумент (форматная строка) в RCX, 2-й аргумент (число) в RDX
    lea rcx, [szFmt]
    mov edx, 42
    call [printf]

    ; 3. Возврат из программы: код 0
    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, \
           puts, 'puts', \
           printf, 'printf', \
           exit, 'exit'
