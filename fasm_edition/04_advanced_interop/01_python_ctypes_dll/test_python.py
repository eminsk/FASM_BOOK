"""
Verification script for fast_math.dll built with FASM x64.
Calls assembly functions directly from Python via ctypes.
"""

import ctypes
import os
import sys

def main():
    dll_path = os.path.join(os.path.dirname(__file__), "fast_math.dll")
    if not os.path.exists(dll_path):
        print(f"[ERROR] DLL not found at: {dll_path}")
        print("Please compile fast_math.asm first using FASM.EXE!")
        return 1

    print(f"[*] Loading native FASM x64 DLL: {dll_path}")
    lib = ctypes.CDLL(dll_path)

    # 1. add_integers(int a, int b) -> int
    lib.add_integers.argtypes = [ctypes.c_int, ctypes.c_int]
    lib.add_integers.restype = ctypes.c_int
    res_int = lib.add_integers(123, 456)
    print(f"[1] add_integers(123, 456) = {res_int}")
    assert res_int == 579, f"Expected 579, got {res_int}"

    # 2. multiply_doubles(double a, double b) -> double
    lib.multiply_doubles.argtypes = [ctypes.c_double, ctypes.c_double]
    lib.multiply_doubles.restype = ctypes.c_double
    res_dbl = lib.multiply_doubles(3.5, 4.0)
    print(f"[2] multiply_doubles(3.5, 4.0) = {res_dbl}")
    assert abs(res_dbl - 14.0) < 1e-6, f"Expected 14.0, got {res_dbl}"

    # 3. fast_dot_product(float* a, float* b, int n) -> float
    lib.fast_dot_product.argtypes = [
        ctypes.POINTER(ctypes.c_float),
        ctypes.POINTER(ctypes.c_float),
        ctypes.c_int
    ]
    lib.fast_dot_product.restype = ctypes.c_float

    vec_a = (ctypes.c_float * 4)(1.0, 2.0, 3.0, 4.0)
    vec_b = (ctypes.c_float * 4)(5.0, 6.0, 7.0, 8.0)
    res_dot = lib.fast_dot_product(vec_a, vec_b, 4)
    print(f"[3] fast_dot_product([1,2,3,4], [5,6,7,8]) = {res_dot}")
    # 1*5 + 2*6 + 3*7 + 4*8 = 5 + 12 + 21 + 32 = 70.0
    assert abs(res_dot - 70.0) < 1e-5, f"Expected 70.0, got {res_dot}"

    print("[SUCCESS] All Python -> FASM x64 ctypes assertions PASSED 100%!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
