; ==============================================================================
; Практический Проект 6: Нативное Оконное GUI-Приложение (Win64 Native GUI)
; Чистый Win32/Win64 API: окно, контролы (Кнопка, Поле ввода, Статик), WndProc
; ==============================================================================

format PE64 GUI 5.0
entry main

include 'win64a.inc'

ID_BUTTON = 101
ID_EDIT   = 102
ID_STATIC = 103

section '.data' data readable writeable
    szClassName   db 'FasmBookGuiClass', 0
    szAppTitle    db 'FASM x64 Modern Native Application', 0
    szBtnClass    db 'BUTTON', 0
    szEditClass   db 'EDIT', 0
    szStaticClass db 'STATIC', 0

    szBtnText     db 'Click Me!', 0
    szEditText    db 'Hello from FASM GUI!', 0
    szStaticText  db 'Enter text above and press the button:', 0

    szMsgTitle    db 'FASM x64 Notification', 0
    szMsgTemplate db 'You typed in the input box:', 13, 10, '"%s"', 0

    hInst         dq 0
    hWndMain      dq 0
    hBtn          dq 0
    hEdit         dq 0
    hStatic       dq 0

    wc            WNDCLASSEX
    msg           MSG
    buffer        rb 256
    format_buf    rb 512

section '.text' code readable executable
main:
    sub rsp, 40

    ; Получаем HINSTANCE процесса
    xor ecx, ecx
    call [GetModuleHandleA]
    mov [hInst], rax

    ; Заполняем структуру WNDCLASSEX
    mov [wc.cbSize], sizeof.WNDCLASSEX
    mov [wc.style], CS_HREDRAW or CS_VREDRAW
    lea rax, [WndProc]
    mov [wc.lpfnWndProc], rax
    mov [wc.cbClsExtra], 0
    mov [wc.cbWndExtra], 0
    mov rax, [hInst]
    mov [wc.hInstance], rax

    xor ecx, ecx
    mov edx, IDI_APPLICATION
    call [LoadIconA]
    mov [wc.hIcon], rax
    mov [wc.hIconSm], rax

    xor ecx, ecx
    mov edx, IDC_ARROW
    call [LoadCursorA]
    mov [wc.hCursor], rax

    mov [wc.hbrBackground], COLOR_WINDOW + 1
    mov [wc.lpszMenuName], 0
    lea rax, [szClassName]
    mov [wc.lpszClassName], rax

    ; Регистрируем класс окна
    lea rcx, [wc]
    call [RegisterClassExA]

    ; Создаем главное окно
    sub rsp, 64
    mov rax, 80000000h              ; CW_USEDEFAULT
    mov qword [rsp + 32], rax       ; x
    mov qword [rsp + 40], rax       ; y
    mov qword [rsp + 48], 440       ; width
    mov qword [rsp + 56], 260       ; height

    xor ecx, ecx                    ; dwExStyle
    lea rdx, [szClassName]          ; lpClassName
    lea r8,  [szAppTitle]           ; lpWindowName
    mov r9d, WS_OVERLAPPEDWINDOW or WS_VISIBLE ; dwStyle

    push 0                          ; lpParam
    push [hInst]                    ; hInstance
    push 0                          ; hMenu
    push 0                          ; hWndParent
    call [CreateWindowExA]
    add rsp, 64 + 32

    mov [hWndMain], rax

    ; Главный цикл сообщений (Message Loop)
.msg_loop:
    lea rcx, [msg]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call [GetMessageA]
    test eax, eax
    jle .exit_loop

    lea rcx, [msg]
    call [TranslateMessage]
    lea rcx, [msg]
    call [DispatchMessageA]
    jmp .msg_loop

.exit_loop:
    mov ecx, dword [msg.wParam]
    call [ExitProcess]

; ------------------------------------------------------------------------------
; LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
; ------------------------------------------------------------------------------
WndProc:
    push rbx
    push rsi
    push rdi
    sub rsp, 72

    mov [rsp + 96], rcx     ; hWnd
    mov [rsp + 104], rdx    ; uMsg
    mov [rsp + 112], r8     ; wParam
    mov [rsp + 120], r9     ; lParam

    cmp edx, WM_CREATE
    je .on_create
    cmp edx, WM_COMMAND
    je .on_command
    cmp edx, WM_DESTROY
    je .on_destroy

.default_proc:
    mov rcx, [rsp + 96]
    mov rdx, [rsp + 104]
    mov r8,  [rsp + 112]
    mov r9,  [rsp + 120]
    call [DefWindowProcA]
    jmp .return_result

.on_create:
    mov rbx, rcx            ; hWnd

    ; 1. Статик метка
    sub rsp, 64
    mov qword [rsp + 32], 30        ; x
    mov qword [rsp + 40], 25        ; y
    mov qword [rsp + 48], 360       ; w
    mov qword [rsp + 56], 20        ; h
    push 0
    push [hInst]
    push ID_STATIC
    push rbx
    xor ecx, ecx
    lea rdx, [szStaticClass]
    lea r8, [szStaticText]
    mov r9d, WS_CHILD or WS_VISIBLE
    call [CreateWindowExA]
    add rsp, 64 + 32
    mov [hStatic], rax

    ; 2. Поле ввода (EDIT)
    sub rsp, 64
    mov qword [rsp + 32], 30        ; x
    mov qword [rsp + 40], 55        ; y
    mov qword [rsp + 48], 360       ; w
    mov qword [rsp + 56], 26        ; h
    push 0
    push [hInst]
    push ID_EDIT
    push rbx
    mov ecx, WS_EX_CLIENTEDGE
    lea rdx, [szEditClass]
    lea r8, [szEditText]
    mov r9d, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL
    call [CreateWindowExA]
    add rsp, 64 + 32
    mov [hEdit], rax

    ; 3. Кнопка (BUTTON)
    sub rsp, 64
    mov qword [rsp + 32], 130       ; x
    mov qword [rsp + 40], 100       ; y
    mov qword [rsp + 48], 150       ; w
    mov qword [rsp + 56], 35        ; h
    push 0
    push [hInst]
    push ID_BUTTON
    push rbx
    xor ecx, ecx
    lea rdx, [szBtnClass]
    lea r8, [szBtnText]
    mov r9d, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON
    call [CreateWindowExA]
    add rsp, 64 + 32
    mov [hBtn], rax

    xor eax, eax
    jmp .return_result

.on_command:
    mov rax, [rsp + 112]
    and eax, 0xFFFF
    cmp eax, ID_BUTTON
    jne .default_proc

    mov rcx, [hEdit]
    lea rdx, [buffer]
    mov r8d, 256
    call [GetWindowTextA]

    lea rcx, [format_buf]
    lea rdx, [szMsgTemplate]
    lea r8, [buffer]
    call [wsprintfA]

    mov rcx, [rsp + 96]
    lea rdx, [format_buf]
    lea r8, [szMsgTitle]
    mov r9d, MB_OK or MB_ICONINFORMATION
    call [MessageBoxA]

    xor eax, eax
    jmp .return_result

.on_destroy:
    xor ecx, ecx
    call [PostQuitMessage]
    xor eax, eax

.return_result:
    add rsp, 72
    pop rdi
    pop rsi
    pop rbx
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            user32, 'USER32.DLL'

    import kernel32, \
           GetModuleHandleA, 'GetModuleHandleA', \
           ExitProcess, 'ExitProcess'

    import user32, \
           RegisterClassExA, 'RegisterClassExA', \
           CreateWindowExA, 'CreateWindowExA', \
           DefWindowProcA, 'DefWindowProcA', \
           GetMessageA, 'GetMessageA', \
           TranslateMessage, 'TranslateMessage', \
           DispatchMessageA, 'DispatchMessageA', \
           PostQuitMessage, 'PostQuitMessage', \
           GetWindowTextA, 'GetWindowTextA', \
           MessageBoxA, 'MessageBoxA', \
           wsprintfA, 'wsprintfA', \
           LoadCursorA, 'LoadCursorA', \
           LoadIconA, 'LoadIconA'
