; ==============================================================================
; Глава: Сканирование Битов и Битовые Поля (BT, BTS, BTR, BSF, BSR, POPCNT)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.rdata' data readable
    szTitle     db '=== Chapter: Bit Scanning and Hardware POPCNT in x64 ===', 10, 0
    szBitFmt    db 'Bit Test/Set Operations on mask 0x%08X:', 10
                db '  Set bit 3  (BTS): 0x%08X', 10
                db '  Reset bit 0 (BTR): 0x%08X', 10, 0
    szScanFmt   db 'Bit Scan on value 0x%08X:', 10
                db '  Lowest set bit index  (BSF): bit #%d', 10
                db '  Highest set bit index (BSR): bit #%d', 10
                db '  Hardware Population Count (POPCNT): %d set bits', 10, 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 48

    lea rcx, [szTitle]
    call [printf]

    ; 1. Bit Test and Set / Reset
    mov eax, 00010001b      ; 0x11
    mov ebx, eax
    bts ebx, 3              ; устанавливаем 3-й бит -> 0x19

    mov edx, eax
    btr edx, 0              ; сбрасываем 0-й бит -> 0x10

    lea rcx, [szBitFmt]
    mov r8d, ebx
    mov r9d, edx
    mov edx, eax
    call [printf]

    ; 2. Сканирование битов: BSF, BSR, POPCNT
    ; Число: 0x240 (биты 6 и 9 установлены)
    mov eax, 240h
    bsf ebx, eax            ; BSF найдет младший установленный бит: 6
    bsr esi, eax            ; BSR найдет старший установленный бит: 9
    popcnt edi, eax         ; POPCNT посчитает число единиц: 2

    lea rcx, [szScanFmt]
    mov edx, eax            ; 0x240
    mov r8d, ebx            ; 6
    mov r9d, esi            ; 9
    mov dword [rsp + 32], edi ; 2
    call [printf]

    add rsp, 48
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
