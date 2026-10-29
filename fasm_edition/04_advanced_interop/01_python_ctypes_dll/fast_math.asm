; ==============================================================================
; Глава: Создание Высокопроизводительной x64 DLL для Python (ctypes)
; Компилируется напрямую в fast_math.dll без внешних линкеров!
; ==============================================================================

format PE64 GUI DLL
entry DllEntryPoint

include 'win64a.inc'

section '.text' code readable executable

proc DllEntryPoint hinstDLL, fdwReason, lpvReserved
    mov eax, 1          ; TRUE (успешная инициализация)
    ret
endp

; ------------------------------------------------------------------------------
; int add_integers(int a [ECX], int b [EDX])
; ------------------------------------------------------------------------------
proc add_integers a, b
    lea eax, [ecx + edx]
    ret
endp

; ------------------------------------------------------------------------------
; double multiply_doubles(double a [XMM0], double b [XMM1])
; ------------------------------------------------------------------------------
proc multiply_doubles a, b
    mulsd xmm0, xmm1
    ret
endp

; ------------------------------------------------------------------------------
; float fast_dot_product(const float* a [RCX], const float* b [RDX], int count [R8D])
; Вычисляет скалярное произведение двух массивов float с использованием SIMD SSE
; ------------------------------------------------------------------------------
proc fast_dot_product a, b, count
    xorps xmm0, xmm0    ; xmm0 = аккумулятор суммы (0.0)
    test r8d, r8d
    jle .done

.loop:
    movss xmm1, [rcx]   ; xmm1 = a[i]
    mulss xmm1, [rdx]   ; xmm1 = a[i] * b[i]
    addss xmm0, xmm1   ; sum += a[i] * b[i]

    add rcx, 4
    add rdx, 4
    dec r8d
    jnz .loop

.done:
    ret
endp

; ------------------------------------------------------------------------------
; Секция экспорта функций (.edata)
; ------------------------------------------------------------------------------
section '.edata' export data readable
    export 'fast_math.dll',\
           add_integers, 'add_integers',\
           multiply_doubles, 'multiply_doubles',\
           fast_dot_product, 'fast_dot_product'

section '.reloc' fixups data readable discardable
    if $=$$
        dd 0, 8         ; фиктивная запись релокации для ASLR загрузчика Windows 64
    end if

section '.idata' import data readable writeable
    library kernel32, 'KERNEL32.DLL'
    import kernel32, ExitProcess, 'ExitProcess'
