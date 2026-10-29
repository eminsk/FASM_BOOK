; ==============================================================================
; Глава 1: Hello World (Pure Win64 API Edition)
; Демонстрация прямого обращения к Windows API (Kernel32) без libc/msvcrt.
; ==============================================================================

format PE64 console
entry start

include 'win64a.inc'

STD_OUTPUT_HANDLE = -11

section '.data' data readable writeable
    szMessage   db 'Hello World from Pure Windows x64 API!', 13, 10
    MSG_LEN     = $ - szMessage
    bytesWritten dq 0

section '.text' code readable executable
start:
    sub rsp, 40

    ; Получаем дескриптор стандартного вывода (stdout)
    ; HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    mov ecx, STD_OUTPUT_HANDLE
    call [GetStdHandle]
    mov rbx, rax    ; дескриптор stdout в rbx

    ; Выводим сообщение в консоль:
    ; WriteFile(hOut, szMessage, MSG_LEN, &bytesWritten, NULL)
    ; RCX = hOut
    ; RDX = lpBuffer
    ; R8D = nNumberOfBytesToWrite
    ; R9  = lpNumberOfBytesWritten
    ; [RSP + 32] = lpOverlapped (NULL)
    mov rcx, rbx
    lea rdx, [szMessage]
    mov r8d, MSG_LEN
    lea r9, [bytesWritten]
    mov qword [rsp + 32], 0
    call [WriteFile]

    ; Завершаем процесс: ExitProcess(0)
    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL'

    import kernel32, \
           GetStdHandle, 'GetStdHandle', \
           WriteFile, 'WriteFile', \
           ExitProcess, 'ExitProcess'
