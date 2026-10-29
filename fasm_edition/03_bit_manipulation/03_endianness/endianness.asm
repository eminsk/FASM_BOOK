; ==============================================================================
; Глава: Порядок Байтов (Endianness) и Инструкция BSWAP в FASM x64
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Chapter: Endianness Conversion & BSWAP ===', 10, 0
    szMemoryFmt db '1. In x86 Little-Endian Memory, 0x12345678 is stored as bytes:', 10
                db '   [+0]: 0x%02X, [+1]: 0x%02X, [+2]: 0x%02X, [+3]: 0x%02X', 10, 0
    szSwap32Fmt db '2. 32-bit BSWAP (Little <-> Big Endian Network Order):', 10
                db '   Original: 0x%08X  -->  Swapped: 0x%08X', 10, 0
    szSwap64Fmt db '3. 64-bit BSWAP:', 10
                db '   Original: 0x%016llX  -->  Swapped: 0x%016llX', 10, 0

    val32       dd 0x12345678
    val64       dq 0x0123456789ABCDEF

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 56

    lea rcx, [szTitle]
    call [printf]

    ; 1. Порядок байт в памяти
    lea rsi, [val32]
    movzx edx, byte [rsi + 0] ; 0x78
    movzx r8d, byte [rsi + 1] ; 0x56
    movzx r9d, byte [rsi + 2] ; 0x34
    movzx eax, byte [rsi + 3] ; 0x12
    mov [rsp + 32], rax
    lea rcx, [szMemoryFmt]
    call [printf]

    ; 2. 32-битный BSWAP
    mov edx, [val32]    ; 0x12345678
    mov r8d, edx
    bswap r8d           ; 0x78563412
    lea rcx, [szSwap32Fmt]
    call [printf]

    ; 3. 64-битный BSWAP
    mov rdx, [val64]    ; 0x0123456789ABCDEF
    mov r8, rdx
    bswap r8            ; 0xEFCDAB8967452301
    lea rcx, [szSwap64Fmt]
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
