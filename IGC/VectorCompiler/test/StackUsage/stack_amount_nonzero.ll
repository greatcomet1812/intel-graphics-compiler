;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2021-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXStackUsage -march=genx64 -mcpu=Gen9 -mtriple=spir64-unknown-unknown -enable-ldst-lowering=true -mattr=+ocl_runtime -S < %s | FileCheck %s
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXStackUsage -march=genx64 -mcpu=Gen9 -mtriple=spir64-unknown-unknown -enable-ldst-lowering=true -mattr=+ocl_runtime -S < %s | FileCheck %s

; COM: test for VC.Stack.Amount attr with nonzero amount

target datalayout = "e-p:64:64-i64:64-n8:16:32:64"

%struct._b128 = type { i32, [3 x i32] }

define internal spir_func void @foo() {
  %1 = alloca %struct._b128, align 4
  ret void
}

define dllexport spir_kernel void @main() #0 {
  call spir_func void @foo()
; CHECK: "VC.Stack.Amount"="24"
  ret void
}

attributes #0 = { "CMGenxMain" }

!genx.kernel.internal = !{!0}
!0 = !{void ()* @main}
