; ==============================================================================
; Глава: Побитовая Логика и Сдвиги (AND, OR, XOR, NOT, SHL, SHR, SAR)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Section 3: Bitwise Logic & Shift Operations ===', 10, 0
    szLogFmt    db 'Bitwise Ops: A=0x%02X, B=0x%02X', 10
                db '  AND: 0x%02X', 10
                db '  OR:  0x%02X', 10
                db '  XOR: 0x%02X', 10
                db '  NOT: 0x%02X', 10, 0
    szShiftFmt  db 'Shift Ops for val = 0x%08X (-16 in decimal):', 10
                db '  Logical Right Shift  (SHR by 2): 0x%08X (zero-filled)', 10
                db '  Arithmetic Right Shift (SAR by 2): 0x%08X (sign-preserved = -4)', 10, 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 64

    lea rcx, [szTitle]
    call [printf]

    ; 1. Логические операции
    mov al, 11001010b   ; 0xCA
    mov bl, 10101111b   ; 0xAF

    mov cl, al
    and cl, bl          ; cl = 0x8A (AND)

    mov dl, al
    or  dl, bl          ; dl = 0xEF (OR)

    mov sil, al
    xor sil, bl         ; sil = 0x65 (XOR)

    mov dil, al
    not dil             ; dil = 0x35 (NOT)

    lea rcx, [szLogFmt]
    movzx edx, al
    movzx r8d, bl
    movzx r9d, cl
    movzx eax, dl
    mov [rsp + 32], rax
    movzx eax, sil
    mov [rsp + 40], rax
    movzx eax, dil
    mov [rsp + 48], rax
    call [printf]

    ; 2. Логический против арифметического сдвига вправо (SHR vs SAR)
    mov eax, -16        ; 0xFFFFFFF0
    mov ebx, eax
    shr ebx, 2          ; 0x3FFFFFFC (логический сдвиг, вдвигает нули)

    mov edx, eax
    sar edx, 2          ; 0xFFFFFFFC (-4, арифметический сдвиг сохраняет знаковый бит!)

    lea rcx, [szShiftFmt]
    mov r8d, ebx
    mov r9d, edx
    mov edx, eax
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
