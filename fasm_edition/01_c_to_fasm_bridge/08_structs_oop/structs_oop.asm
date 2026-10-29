; ==============================================================================
; Глава 8: Структуры данных и ООП паттерны (Указатель "this") в FASM x64
; Эквивалент на C++:
;   struct Point { int x, y; };
;   class Rectangle {
;   public:
;       Point tl, br;
;       int width()  { return br.x - tl.x; }
;       int height() { return br.y - tl.y; }
;       int area()   { return width() * height(); }
;   };
; ==============================================================================

format PE64 console
entry main

include 'win64a.inc'

; Определение структуры Point (8 байт: 2 x DWORD)
struc Point
{
    .x  dd ?
    .y  dd ?
}

; Определение структуры Rectangle (16 байт)
struc Rectangle
{
    .tl_x dd ?
    .tl_y dd ?
    .br_x dd ?
    .br_y dd ?
}

section '.data' data readable writeable
    szHeader    db '=== Chapter 8: Structs and OOP Method (this pointer) ===', 10, 0
    szRectInfo  db 'Rectangle coords: TL=(%d, %d), BR=(%d, %d)', 10, 0
    szMetrics   db 'Calculated: Width = %d, Height = %d, Area = %d sq. units', 10, 0

    ; Создаем и инициализируем экземпляр структуры:
    ; top_left = (10, 20), bottom_right = (50, 60)
    my_rect:
        .tl_x dd 10
        .tl_y dd 20
        .br_x dd 50
        .br_y dd 60

section '.text' code readable executable
main:
    push rbx
    push rsi
    sub rsp, 56

    lea rcx, [szHeader]
    call [printf]

    ; Выводим координаты прямоугольника
    lea rcx, [szRectInfo]
    mov edx, [my_rect.tl_x]
    mov r8d, [my_rect.tl_y]
    mov r9d, [my_rect.br_x]
    mov eax, [my_rect.br_y]
    mov [rsp + 32], rax
    call [printf]

    ; Вызываем "метод" Rectangle_Area:
    ; В x64 C++ указатель 'this' передается первым аргументом в RCX!
    lea rcx, [my_rect]
    call Rectangle_GetMetrics

    ; Функция вернула:
    ; EAX = Area, EDX = Width, R8D = Height
    lea rcx, [szMetrics]
    mov r9d, eax            ; area -> 4-й аргумент (R9D)
    ; 2-й аргумент (EDX) уже содержит Width
    ; 3-й аргумент (R8D) уже содержит Height
    call [printf]

    add rsp, 56
    pop rsi
    pop rbx
    xor ecx, ecx
    call [exit]

; ------------------------------------------------------------------------------
; "Метод": Rectangle_GetMetrics(Rectangle* this [RCX])
; Возвращает:
;   EAX = Area
;   EDX = Width
;   R8D = Height
; ------------------------------------------------------------------------------
Rectangle_GetMetrics:
    ; this->tl.x  = [rcx + 0]
    ; this->tl.y  = [rcx + 4]
    ; this->br.x  = [rcx + 8]
    ; this->br.y  = [rcx + 12]

    ; width = br.x - tl.x
    mov edx, [rcx + 8]
    sub edx, [rcx + 0]

    ; height = br.y - tl.y
    mov r8d, [rcx + 12]
    sub r8d, [rcx + 4]

    ; area = width * height
    mov eax, edx
    imul eax, r8d

    ret

section '.idata' import data readable
    library kernel32, 'KERNEL32.DLL', \
            msvcrt, 'MSVCRT.DLL'

    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', exit, 'exit'
