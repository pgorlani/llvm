// RUN: %clang_cc1 -triple nvptx64-nvidia-cuda -aux-triple x86_64-unknown-linux-gnu \
// RUN:     -fsycl-is-device -internal-isystem %S/Inputs -sycl-std=2020 \
// RUN:     -ast-dump %s | FileCheck %s

// Check that aux builtins have the correct __device__ attribute

__attribute__((device)) void df() {
  int x = __nvvm_read_ptx_sreg_ctaid_x();
}

void fun() {
  df();
}

// CHECK: FunctionDecl {{.*}} __nvvm_read_ptx_sreg_ctaid_x
// CHECK-NEXT: BuiltinAttr 
// CHECK-NEXT: NoThrowAttr
// CHECK-NEXT: ConstAttr
// CHECK-NEXT: CUDADeviceAttr
