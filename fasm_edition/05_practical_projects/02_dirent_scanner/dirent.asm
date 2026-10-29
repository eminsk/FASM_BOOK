; ==============================================================================
; Практический Проект 2: Сканер Директорий (DIRENT / FindFirstFile x64)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

FILE_ATTRIBUTE_DIRECTORY = 0x00000010
INVALID_HANDLE_VALUE     = -1

section '.rdata' data readable
    szTitle     db '==================================================', 10
                db '   FASM x64 Native Directory Enumerator (DIRENT)   ', 10
                db '==================================================', 10, 0
    szPattern   db '*.*', 0
    szDirEntry  db '  [DIR ]  %-30s', 10, 0
    szFileEntry db '  [FILE]  %-30s  (%u bytes)', 10, 0
    szSummary   db '--------------------------------------------------', 10
                db 'Scan Complete: Found %d files and %d subdirectories.', 10, 0
    szError     db '[ERROR] FindFirstFileA failed to open directory!', 10, 0

section '.data' data readable writeable
    file_count  dd 0
    dir_count   dd 0
    hFind       dq 0

section '.bss' readable writeable
    findData    WIN32_FIND_DATAA

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    ; 3 регистра = 24 байта. Стек выровнен по 16 байтам.
    ; Вычитаем 48 байт (кратно 16, включает 32 байта Shadow Space):
    sub rsp, 48

    lea rcx, [szTitle]
    call [printf]

    lea rcx, [szPattern]
    lea rdx, [findData]
    call [FindFirstFileA]

    cmp rax, INVALID_HANDLE_VALUE
    je .failed

    mov [hFind], rax

.file_loop:
    mov eax, [findData.dwFileAttributes]
    test eax, FILE_ATTRIBUTE_DIRECTORY
    jnz .is_directory

.is_file:
    inc dword [file_count]
    lea rcx, [szFileEntry]
    lea rdx, [findData.cFileName]
    mov r8d, [findData.nFileSizeLow]
    call [printf]
    jmp .find_next

.is_directory:
    inc dword [dir_count]
    lea rcx, [szDirEntry]
    lea rdx, [findData.cFileName]
    call [printf]

.find_next:
    mov rcx, [hFind]
    lea rdx, [findData]
    call [FindNextFileA]
    test eax, eax
    jnz .file_loop

    mov rcx, [hFind]
    call [FindClose]

    lea rcx, [szSummary]
    mov edx, [file_count]
    mov r8d, [dir_count]
    call [printf]
    jmp .exit_ok

.failed:
    lea rcx, [szError]
    call [printf]

.exit_ok:
    add rsp, 48
    pop rdi
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, \
           FindFirstFileA, 'FindFirstFileA', \
           FindNextFileA, 'FindNextFileA', \
           FindClose, 'FindClose', \
           ExitProcess, 'ExitProcess'

    import msvcrt, printf, 'printf', exit, 'exit'
