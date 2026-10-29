<div align="center">

# ⚡ FASM_BOOK: Professional Assembly Language Mastery
### From C/C++ to High-Performance Native x86-64 Assembly (Windows Edition) & ARM64 Fundamentals

[![FASM Version](https://img.shields.io/badge/FASM-v1.73.35-blue.svg?style=for-the-badge&logo=assemblyscript)](https://flatassembler.net/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64%20%7C%20ARM64-0078D6.svg?style=for-the-badge&logo=windows)](https://microsoft.com)
[![Build Status](https://img.shields.io/badge/Build-Passing%20100%25-brightgreen.svg?style=for-the-badge&logo=checkmarx)](./fasm_edition/build_all.bat)
[![Tests Passed](https://img.shields.io/badge/Tests-49%2F49%20PASS-success.svg?style=for-the-badge&logo=pytest)](./fasm_edition/test_all.ps1)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-ZERO%20(Pure%20Native)-orange.svg?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg?style=for-the-badge)](./LICENSE.md)

<p align="center">
  <b>Универсальное практическое руководство и эталонная кодовая база по программированию на чистом ассемблере Flat Assembler (FASM x64) для Windows, а также оригинальный академический курс по низкоуровневой архитектуре ARM64.</b>
</p>

[🚀 Быстрый старт](#-быстрый-старт-quick-start) •
[📂 Структура проекта](#-структура-проекта) •
[🧠 Архитектура и ABI](#-архитектура-и-соглашения-о-вызовах-abi) •
[💡 Примеры кода](#-галерея-примеров-кода) •
[🧪 Тестирование](#-автоматическое-тестирование-и-верификация) •
[English Readme](#-english-summary)

</div>

---

## 🌟 О проекте (Project Overview)

Репозиторий **FASM_BOOK** решает главную проблему перехода разработчиков от высокоуровневых языков (C, C++, Python) к аппаратному уровню:

> **«Ассемблер — это не сложно, если вы понимаете, как абстракции C/C++ отображаются в реальные регистры, стек и инструкции процессора».**

Репозиторий объединяет два дополняющих друг друга направления:
1. **🔥 FASM Edition (`fasm_edition/`) — Новая нативная практическая реализация**:
   - 100% автономная сборка на чистом **Flat Assembler (FASM v1.73.35)** для Windows x64.
   - Никаких внешних линкеров, огромных SDK или Visual Studio: исполняемые файлы генерируются за 1 проход за доли секунды.
   - Разбор всех фундаментальных конструкций: от условных переходов и циклов до SIMD SSE-векторизации, атомарных инструкций многопоточности, интеграции с Python через `ctypes` и полноценного Win64 GUI.
2. **📚 Academic ARM64 Foundations (`section_1/` – `section_3/`, `projects/`)**:
   - Оригинальный курс *"A Gentle Introduction to Assembly Language Programming"*, раскрывающий особенности RISC-архитектуры ARMv8 (Apple Silicon M1-M4 и ARM Linux) с синтаксисом GNU Assembler.

---

## 🚀 Быстрый старт (Quick Start)

Все инструменты уже включены в репозиторий в каталоге [`tools/fasm/`](./tools/fasm/). Вам не требуется устанавливать сторонние компиляторы или настраивать переменные среды.

### 1. Клонирование репозитория
```cmd
git clone https://github.com/eminsk/FASM_BOOK.git
cd FASM_BOOK
```

### 2. Сборка всех 25 модулей (1 клик)
Запустите корневой скрипт сборки:
```cmd
build_all_fasm.bat
```
Либо перейдите в каталог `fasm_edition` и выполните:
```cmd
cd fasm_edition
build_all.bat
```
*Результат*: Все 25 программ (консольные утилиты, DLL и GUI) будут скомпилированы напрямую за ~1.5 секунды.

### 3. Запуск полного цикла автоматического тестирования
```cmd
test_all_fasm.bat
```
Автоматический тестовый раннер на PowerShell выполнит компиляцию всех модулей, запустит бинарные файлы, проверит возвращаемые коды, валидирует математические вычисления и выполнит интеграционный тест с Python:
```
===============================================================================
Scorecard: Total Tests Passed: 49 | Failed: 0 (100% SUCCESS!)
===============================================================================
```

### 4. Очистка бинарных артефактов
```cmd
cd fasm_edition
clean.bat
```

---

## 📂 Структура проекта

```
FASM_BOOK/
├── tools/                               # Автономный инструментарий FASM
│   └── fasm/
│       ├── FASM.EXE                     # Официальный Flat Assembler v1.73.35 x64
│       └── INCLUDE/                     # Полный набор заголовочных файлов Win64/Win32
│
├── fasm_edition/                        # ⚡ НАСТОЛЬНАЯ ПРАКТИЧЕСКАЯ РЕДАКЦИЯ (FASM x64)
│   ├── 01_c_to_fasm_bridge/             # РАЗДЕЛ 1: Мост от C/C++ к x64 Ассемблеру
│   │   ├── 00_kickstart/                # Руководство: x86-64 vs ARM64, FastCall ABI, Стек
│   │   ├── 01_hello_world/              # Hello World: через MSVCRT (puts/printf) и Win32 API
│   │   ├── 02_if_else/                  # Ветвления, сравнения (CMP), флаги, branchless (CMOV)
│   │   ├── 03_loops/                    # Циклы while, for, команды break и continue
│   │   ├── 04_registers_addressing/     # Субрегистры (RAX..AL), адресация [base+idx*scale+disp], LEA
│   │   ├── 05_switch_jump_tables/       # Конструкция switch через jump table (O(1) скорость)
│   │   ├── 06_functions_abi/            # Вызовы функций: передача 6 параметров, кадр стека
│   │   ├── 07_fizzbuzz/                 # Задача FizzBuzz на чистом FASM x64
│   │   ├── 08_structs_oop/              # Структуры (struc), смещения и указатель "this" (ООП)
│   │   └── 09_constants_sections/       # Секции PE: .rdata (const), .data (rw), .bss (динамическая)
│   │
│   ├── 02_floating_point_simd/          # РАЗДЕЛ 2: Вещественные Числа и SIMD Векторизация
│   │   ├── 01_float_arithmetic/         # SSE2: вычисления с float32 и float64 (объем цилиндра)
│   │   ├── 02_conversion_rounding/      # Конвертация float <-> int, округление (roundsd: Floor, Ceil)
│   │   └── 03_simd_vectors/             # 128-битные SIMD-инструкции (4 x float32 параллельно)
│   │
│   ├── 03_bit_manipulation/             # РАЗДЕЛ 3: Побитовые Операции и Арифметика
│   │   ├── 01_bitwise_logic/            # AND, OR, XOR, NOT, сдвиги SHR (логический) и SAR (знаковый)
│   │   ├── 02_bitfields_scanning/       # Проверка бит (BT/BTS/BTR), поиск (BSF/BSR), POPCNT
│   │   └── 03_endianness/               # Порядок байтов Little vs Big Endian, инструкция BSWAP
│   │
│   ├── 04_advanced_interop/             # РАЗДЕЛ 4: Продвинутые Технологии и Интероп
│   │   ├── 01_python_ctypes_dll/        # PE64 DLL (fast_math.dll) + тест на Python (ctypes)
│   │   ├── 02_atomics_spinlocks/        # Атомарные LOCK CMPXCHG, LOCK XADD, спинлок + PAUSE
│   │   └── 03_variadic_crt/             # Вариативные вызовы функций (printf) в x64 ABI
│   │
│   ├── 05_practical_projects/           # РАЗДЕЛ 5: Готовые Прикладные Проекты
│   │   ├── 01_calculator/               # Парсер строковых математических выражений и калькулятор
│   │   ├── 02_dirent_scanner/           # Сканер файлов и папок (FindFirstFileA / FindNextFileA)
│   │   ├── 03_monte_carlo_pi/           # Метод Монте-Карло: число Пи на 1,000,000 точек в SSE2
│   │   ├── 04_sine_taylor/              # Вычисление sin(x) рядом Тейлора против MSVCRT sin()
│   │   ├── 05_snow_animation/           # Консольная анимация падающего снега (система частиц)
│   │   └── 06_win64_gui_app/            # Нативное GUI-приложение Windows (Окно, Кнопка, Поле ввода)
│   │
│   ├── build_all.bat                    # Пакетная сборка FASM Edition
│   ├── test_all.ps1                     # Автоматический тестовый раннер
│   ├── clean.bat                        # Очистка артефактов компиляции
│   └── README.md                        # Детальное руководство по FASM Edition
│
├── section_1/ ... section_3/            # 📚 Оригинальные разделы курса (ARM64 GNU Assembler)
├── projects/                            # 📚 Оригинальные проекты (Apple Silicon / Linux)
├── python/                              # 📚 Исходные материалы по интеропу с Python
├── reference_material/                  # 📚 Справочники: архитектура ARMv8, ISA specs
├── build_all_fasm.bat                   # Мастер-скрипт сборки из корня репозитория
└── test_all_fasm.bat                    # Мастер-скрипт тестирования из корня репозитория
```

---

## 🧠 Архитектура и соглашения о вызовах (ABI)

### Сравнение архитектур: ARM64 vs x86-64

| Параметр | ARM64 (AArch64) | x86-64 (Intel / AMD) в FASM |
|---|---|---|
| **Тип архитектуры** | RISC (фиксированная длина команд 32 бита) | CISC (переменная длина команд от 1 до 15 байт) |
| **Регистры общего назначения** | `x0` – `x30` (64-бит), `w0` – `w30` (32-бит) | `RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8 – R15` |
| **Указатель стека** | `SP` | `RSP` |
| **Указатель команд** | `PC` | `RIP` (поддерживается относительная адресация `[rel label]`) |
| **Адрес возврата** | Регистр связывания `LR` (`x30`) | На вершине стека (команда `ret` снимает адрес) |
| **Передача аргументов (целые)** | `x0` – `x7` (до 8 аргументов) | `RCX, RDX, R8, R9` (до 4 аргументов) |
| **Передача аргументов (вещественные)** | `d0` – `d7` | `XMM0` – `XMM3` |
| **Стек для аргументов** | Аргументы 9+ помещаются в стек | Аргументы 5+ помещаются в стек (`[RSP + 32]`, `[RSP + 40]`) |
| **Теневое пространство (Shadow Space)** | Отсутствует | **Обязательно 32 байта** перед каждым `call` |
| **Выравнивание стека** | 16 байт | **Строго 16 байт** в момент выполнения `call` |
| **Векторные регистры** | `v0` – `v31` (128-бит NEON) | `XMM0` – `XMM15` (128-бит SSE/AVX) |

### Ключевые правила Microsoft x64 FastCall Calling Convention:
1. **Первые 4 параметра**: Передаются через `RCX, RDX, R8, R9` для целых чисел/указателей или `XMM0..XMM3` для вещественных чисел.
2. **Теневое пространство (Shadow Space / Home Space)**: Вызывающая функция (Caller) обязана выделить в стеке минимум 32 байта (`sub rsp, 32` или `sub rsp, 40` с учетом выравнивания) перед любым вызовом (`call`).
3. **16-байтное выравнивание стека**: Перед командой `call` стек должен быть строго кратен 16 (`RSP % 16 == 0`). Сама инструкция `call` пушит 8-байтный адрес возврата, поэтому внутри вызванной функции на старте `RSP % 16 == 8`.
4. **Сохраняемые регистры (Non-Volatile)**: `RBX, RBP, RDI, RSI, R12, R13, R14, R15, XMM6..XMM15`. Если ваша функция модифицирует эти регистры, она обязана сохранить их в прологе и восстановить в эпилоге.

---

## 💡 Галерея примеров кода

### 1. Мост C/C++ к FASM: Вызов функции с 6 аргументами
В C:
```c
long long sum6(long long a, long long b, long long c, long long d, long long e, long long f) {
    return a + b + c + d + e + f;
}
```
В FASM x64 ([`functions_abi.asm`](./fasm_edition/01_c_to_fasm_bridge/06_functions_abi/functions_abi.asm)):
```fasm
format PE64 console
entry main
include 'win64a.inc'

section '.text' code readable executable
main:
    sub rsp, 56                 ; 32 (shadow) + 16 (2 args) + 8 (align) = 56
    mov rcx, 10                 ; 1-й аргумент -> RCX
    mov rdx, 20                 ; 2-й аргумент -> RDX
    mov r8,  30                 ; 3-й аргумент -> R8
    mov r9,  40                 ; 4-й аргумент -> R9
    mov qword [rsp + 32], 50    ; 5-й аргумент -> стек
    mov qword [rsp + 40], 60    ; 6-й аргумент -> стек
    call sum6
    ; Результат 210 вернулся в RAX
    ...

sum6:
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    add rax, qword [rsp + 40]   ; 5-й аргумент из стека вызывающего
    add rax, qword [rsp + 48]   ; 6-й аргумент из стека вызывающего
    ret
```

### 2. SIMD Векторизация 4x Float32 за 1 такт
В FASM x64 ([`simd_vector.asm`](./fasm_edition/02_floating_point_simd/03_simd_vectors/simd_vector.asm)):
```fasm
; Сложение двух 4-мерных векторов float32 одновременно:
movaps xmm0, dqword [vecA]      ; xmm0 = (1.0, 2.0, 3.0, 4.0)
movaps xmm1, dqword [vecB]      ; xmm1 = (5.0, 6.0, 7.0, 8.0)
addps  xmm0, xmm1               ; xmm0 = (6.0, 8.0, 10.0, 12.0)

; Аппаратное скалярное произведение через SSE 4.1 dpps:
dpps xmm0, dqword [vecB], 0xF1  ; xmm0[0] = 70.0 (Dot Product A . B)
```

### 3. Нативная DLL для Python на FASM
В FASM x64 ([`fast_math.asm`](./fasm_edition/04_advanced_interop/01_python_ctypes_dll/fast_math.asm)):
```fasm
format PE64 GUI DLL
entry DllEntryPoint
include 'win64a.inc'

section '.text' code readable executable
proc DllEntryPoint hinstDLL, fdwReason, lpvReserved
    mov eax, 1
    ret
endp

proc fast_dot_product a, b, count
    xorps xmm0, xmm0
.loop:
    movss xmm1, [rcx]
    mulss xmm1, [rdx]
    addss xmm0, xmm1
    add rcx, 4
    add rdx, 4
    dec r8d
    jnz .loop
    ret
endp

section '.edata' export data readable
    export 'fast_math.dll', fast_dot_product, 'fast_dot_product'

section '.reloc' fixups data readable discardable
    if $=$$
        dd 0, 8                 ; корректный фиксап для Windows x64 ASLR
    end if
```
Вызов из Python ([`test_python.py`](./fasm_edition/04_advanced_interop/01_python_ctypes_dll/test_python.py)):
```python
import ctypes
lib = ctypes.CDLL("./fast_math.dll")
lib.fast_dot_product.argtypes = [ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.fast_dot_product.restype = ctypes.c_float

a = (ctypes.c_float * 4)(1.0, 2.0, 3.0, 4.0)
b = (ctypes.c_float * 4)(5.0, 6.0, 7.0, 8.0)
assert lib.fast_dot_product(a, b, 4) == 70.0
```

---

## 🧪 Автоматическое тестирование и верификация

Тестовый набор [`test_all.ps1`](./fasm_edition/test_all.ps1) производит сквозную валидацию всех компонентов:

| Модуль | Тип | Статус сборки | Время работы | Статус проверки |
|---|---|---|---|---|
| `hello_crt.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~45 мс | ✅ Код 0 (Pass) |
| `hello_winapi.asm` | Pure Win32 EXE | ✅ Скомпилирован (2048 B) | ~22 мс | ✅ Код 0 (Pass) |
| `if_else.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~25 мс | ✅ Код 0 (Pass) |
| `loops.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~23 мс | ✅ Код 0 (Pass) |
| `registers_addressing.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~24 мс | ✅ Код 0 (Pass) |
| `switch_table.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~23 мс | ✅ Код 0 (Pass) |
| `functions_abi.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~25 мс | ✅ Код 0 (Pass) |
| `fizzbuzz.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~22 мс | ✅ Код 0 (Pass) |
| `structs_oop.asm` | Console EXE | ✅ Скомпилирован (2048 B) | ~24 мс | ✅ Код 0 (Pass) |
| `constants_sections.asm` | Console EXE | ✅ Скомпилирован (3072 B) | ~23 мс | ✅ Код 0 (Pass) |
| `floats.asm` | SSE2 FP EXE | ✅ Скомпилирован (2048 B) | ~22 мс | ✅ Код 0 (Pass) |
| `rounding.asm` | SSE4.1 EXE | ✅ Скомпилирован (2048 B) | ~24 мс | ✅ Код 0 (Pass) |
| `simd_vector.asm` | 128-bit SIMD EXE | ✅ Скомпилирован (2560 B) | ~25 мс | ✅ Код 0 (Pass) |
| `bitwise.asm` | Logic EXE | ✅ Скомпилирован (2048 B) | ~23 мс | ✅ Код 0 (Pass) |
| `bitfields.asm` | Bit Scan EXE | ✅ Скомпилирован (2048 B) | ~22 мс | ✅ Код 0 (Pass) |
| `endianness.asm` | BSWAP EXE | ✅ Скомпилирован (2048 B) | ~24 мс | ✅ Код 0 (Pass) |
| `fast_math.asm` | Native PE64 DLL | ✅ Скомпилирован (3072 B) | — | ✅ Ctypes Pass |
| `spin_lock.asm` | Atomic / Lock EXE | ✅ Скомпилирован (2048 B) | ~24 мс | ✅ Код 0 (Pass) |
| `variadic.asm` | Variadic CRT EXE | ✅ Скомпилирован (2048 B) | ~23 мс | ✅ Код 0 (Pass) |
| `calc.asm` | Expression Calc | ✅ Скомпилирован (2048 B) | ~25 мс | ✅ Код 0 (Pass) |
| `dirent.asm` | Dir Scanner WinAPI | ✅ Скомпилирован (3072 B) | ~22 мс | ✅ Код 0 (Pass) |
| `pi_monte_carlo.asm` | Monte Carlo FP | ✅ Скомпилирован (3072 B) | ~32 мс | ✅ Код 0 (Pass) |
| `sine_taylor.asm` | Taylor Series FP | ✅ Скомпилирован (2048 B) | ~22 мс | ✅ Код 0 (Pass) |
| `snow.asm` | Console Animation | ✅ Скомпилирован (3072 B) | ~25 мс | ✅ Код 0 (Pass) |
| `gui_app.asm` | Native Win64 GUI | ✅ Скомпилирован (3072 B) | Interactive | ✅ Valid PE64 GUI |
| **Итого** | **25 компонентов** | **100% Успешно** | **< 2 сек** | **49 / 49 PASS** |

---

## 🌐 English Summary

**FASM_BOOK** is a comprehensive, production-grade guide and reference codebase for low-level assembly language development.

Key highlights:
- **FASM Edition (`fasm_edition/`)**: A clean-slate, standalone x86-64 assembly course for Windows using **Flat Assembler (FASM)**.
- **Zero Toolchain Overhead**: Bundles the lightweight FASM compiler (`tools/fasm/FASM.EXE`) with complete standard Windows headers. Direct binary generation without intermediate linkers or bulky toolchains.
- **Complete Pedagogical Bridge**: Bridges concepts directly from C/C++ to low-level assembly: conditionals, loops, jump tables, struct layout & OOP `this` pointer emulation, SIMD vectorization (4x float32), atomic instructions (`lock cmpxchg`, `lock xadd`, spinlocks), Python `ctypes` DLL interop, and native Win64 GUI applications with controls and event loops.
- **Automated Verification**: Single-command build (`build_all_fasm.bat`) and comprehensive automated test suite (`test_all_fasm.bat`), achieving 100% pass rates across 49 test assertions.
- **Preserved ARM64 Heritage**: Retains original academic materials for Apple Silicon (M1-M4) and ARM Linux GNU Assembler.

---

## 📜 Лицензия (License)

Материалы репозитория распространяются по лицензии **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)**. Подробности см. в файле [LICENSE.md](./LICENSE.md).

---

<div align="center">
  <sub>Создано и адаптировано для сообщества низкоуровневой разработки. Развивайте проект, создавайте форки и открывайте pull request'ы!</sub>
</div>
