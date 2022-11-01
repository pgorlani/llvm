// RUN: %clang_cc1 -fsycl-is-host -emit-llvm %s -o - | FileCheck %s -check-prefix CHECK-HOST
// RUN: %clang_cc1 -fsycl-is-device -emit-llvm %s -o - | FileCheck %s -check-prefix CHECK-DEV

// Test if a dummy __host__ function (returning undef) is generated for every __device__ function without a host counterpart in sycl-host compilation.

#include "../CodeGenCUDA/Inputs/cuda.h"
#include "Inputs/sycl.hpp"

// CHECK-HOST: ret i32 2
// CHECK-DEV: ret i32 1
__device__ int fun0() { return 1; }
__host__ int fun0() { return 2; }

// CHECK-HOST: ret i32 3
// CHECK-DEV: ret i32 3
__host__ __device__ int fun1() { return 3; }

// CHECK-HOST: ret i32 4
// CHECK-DEV: ret i32 4
__host__ int fun2() { return 4; }

// CHECK-HOST: ret i32 undef
// CHECK-DEV: ret i32 5
__device__ int fun3() { return 5; }

int main(){

  sycl::queue deviceQueue;

  deviceQueue.submit([&](sycl::handler &h) {
    h.single_task<class kern>([]() {
      fun0();
      fun1();
      fun2();
      fun3();
    });
  });

  return 0;
}

