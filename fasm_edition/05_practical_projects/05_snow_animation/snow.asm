; ==============================================================================
; Практический Проект 5: Анимация Снегопада в Консоли (Console Snow Particles)
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

WIDTH       = 40
HEIGHT      = 12
BUFFER_SIZE = WIDTH * HEIGHT
MAX_FRAMES  = 8

section '.rdata' data readable
    szTitle     db '==================================================', 10
                db '   Console ASCII Snow Particle Animation (FASM)   ', 10
                db '==================================================', 10, 0
    szFrameHdr  db '--- Frame #%d ---', 10, 0
    szNewLine   db 10, 0
    szDone      db 'Snow simulation completed successfully!', 10, 0

section '.data' data readable writeable
    rng_seed    dd 987654321

section '.bss' readable writeable
    screen      rb BUFFER_SIZE + 1
    row_buf     rb WIDTH + 1

section '.text' code readable executable
main:
    push rbx
    push rsi
    push rdi
    sub rsp, 56

    lea rcx, [szTitle]
    call [printf]

    ; 1. Инициализация буфера экрана пробелами
    mov rcx, BUFFER_SIZE
    lea rdi, [screen]
    mov al, ' '
    rep stosb

    ; 2. Главный цикл генерации кадров (MAX_FRAMES кадров)
    mov ebx, 1

.frame_loop:
    cmp ebx, MAX_FRAMES
    jg .simulation_done

    lea rcx, [szFrameHdr]
    mov edx, ebx
    call [printf]

    mov esi, BUFFER_SIZE - WIDTH - 1
.shift_down:
    cmp esi, 0
    jl .spawn_new_snow
    mov al, byte [screen + rsi]
    mov byte [screen + rsi + WIDTH], al
    dec esi
    jmp .shift_down

.spawn_new_snow:
    xor edi, edi
.spawn_loop:
    cmp edi, WIDTH
    jge .render_screen

    call get_random
    and eax, 0x07
    mov cl, ' '
    cmp eax, 0
    jne .store_top
    mov cl, '*'
.store_top:
    mov byte [screen + rdi], cl
    inc edi
    jmp .spawn_loop

.render_screen:
    xor esi, esi
.draw_row:
    cmp esi, HEIGHT
    jge .frame_next

    mov eax, esi
    imul eax, WIDTH
    lea r8, [screen + rax]

    xor edi, edi
.copy_char:
    cmp edi, WIDTH
    jge .print_row
    mov al, [r8 + rdi]
    mov [row_buf + rdi], al
    inc edi
    jmp .copy_char

.print_row:
    mov byte [row_buf + WIDTH], 0
    lea rcx, [row_buf]
    call [puts]

    inc esi
    jmp .draw_row

.frame_next:
    lea rcx, [szNewLine]
    call [printf]

    inc ebx
    jmp .frame_loop

.simulation_done:
    lea rcx, [szDone]
    call [printf]

    add rsp, 56
    pop rdi
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

get_random:
    mov eax, [rng_seed]
    imul eax, 1103515245
    add eax, 12345
    mov [rng_seed], eax
    shr eax, 16
    and eax, 0x7FFF
    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', puts, 'puts', exit, 'exit'
