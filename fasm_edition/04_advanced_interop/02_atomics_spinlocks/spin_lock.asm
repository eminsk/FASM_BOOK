; ==============================================================================
; Глава: Атомарные Инструкции и Спинлоки (LOCK CMPXCHG, LOCK XADD, PAUSE)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

section '.data' data readable writeable
    szTitle     db '=== Chapter: Hardware Atomic Operations & Spin-Lock ===', 10, 0
    szXaddFmt   db '1. Atomic Fetch-and-Add (LOCK XADD):', 10
                db '   Old value = %d, Added = %d, New value = %d', 10, 0
    szCasFmt    db '2. Compare-and-Swap (LOCK CMPXCHG):', 10
                db '   Target was %d -> updated to %d (Success: %s)', 10, 0
    szLockFmt   db '3. Spin-Lock Critical Section entered and released safely!', 10, 0
    szTrue      db 'YES', 0
    szFalse     db 'NO', 0

    shared_counter dd 100
    cas_target     dd 500
    my_spin_lock   dd 0

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 56

    lea rcx, [szTitle]
    call [printf]

    ; 1. Атомарное прибавление с получением старого значения (LOCK XADD)
    mov edx, 25
    lock xadd [shared_counter], edx

    lea rcx, [szXaddFmt]
    mov r8d, 25
    mov r9d, [shared_counter]
    call [printf]

    ; 2. Сравнение с обменом (LOCK CMPXCHG)
    mov eax, 500
    mov edx, 777
    lock cmpxchg [cas_target], edx

    lea rcx, [szCasFmt]
    mov edx, 500
    mov r8d, [cas_target]
    lea r9, [szTrue]
    jz .cas_success
    lea r9, [szFalse]
.cas_success:
    call [printf]

    ; 3. Проверка спинлока (Spin-Lock)
    lea rcx, [my_spin_lock]
    call spin_lock_acquire

    ; --- Внутри критической секции ---
    inc dword [shared_counter]

    lea rcx, [my_spin_lock]
    call spin_lock_release

    lea rcx, [szLockFmt]
    call [printf]

    xor ecx, ecx
    call [ExitProcess]

; ------------------------------------------------------------------------------
; void spin_lock_acquire(int* lock_ptr [RCX])
; ------------------------------------------------------------------------------
spin_lock_acquire:
.spin:
    lock bts dword [rcx], 0
    jnc .acquired

.wait_release:
    pause
    test dword [rcx], 1
    jnz .wait_release
    jmp .spin

.acquired:
    ret

; ------------------------------------------------------------------------------
; void spin_lock_release(int* lock_ptr [RCX])
; ------------------------------------------------------------------------------
spin_lock_release:
    mov dword [rcx], 0
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
