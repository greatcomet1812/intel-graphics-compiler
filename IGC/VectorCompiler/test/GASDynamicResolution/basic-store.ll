;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2022-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================
;
; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXGASDynamicResolution -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-TYPED-PTRS
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXGASDynamicResolution -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-OPAQUE-PTRS
;
; This test verifies whether optimization which allows to avoid additional control flow
; generation works per kernel. Below LLVM module implements two kernels:
; - kernelA - contains store instruction operating on generic pointer which always
;             points to local memory. Additional controflow is required as local->generic
;             cast was detected.
; - kernelB - contains store instruction operating on generic pointer which always
;             point to global memory

target datalayout = "e-p:64:64-p3:32:32-i64:64-n8:16:32:64"

define spir_kernel void @kernelA(i32 addrspace(3)* %local_buffer) #0 {
  %generic_ptr = addrspacecast i32 addrspace(3)* %local_buffer to i32 addrspace(4)*
  ; CHECK-TYPED-PTRS: %[[P3I32_TO_I64:.*]] = ptrtoint i32 addrspace(4)* %generic_ptr to i64
  ; CHECK-OPAQUE-PTRS: %[[P3I32_TO_I64:.*]] = ptrtoint ptr addrspace(4) %generic_ptr to i64
  ; CHECK: %[[I64_TO_V2I32:.*]] = bitcast i64 %[[P3I32_TO_I64:.*]] to <2 x i32>
  ; CHECK: %[[TAGGED_MEMORY:.*]] = insertelement <2 x i32> %[[I64_TO_V2I32:.*]], i32 1073741824, i64 1
  ; CHECK: %[[V2I32_TO_I64:.*]] = bitcast <2 x i32> %[[TAGGED_MEMORY:.*]] to i64
  ; CHECK-TYPED-PTRS: generic_ptr.tagged = inttoptr i64 %[[V2I32_TO_I64:.*]] to i32 addrspace(4)*
  ; CHECK-OPAQUE-PTRS: generic_ptr.tagged = inttoptr i64 %[[V2I32_TO_I64:.*]] to ptr addrspace(4)

  store i32 5, i32 addrspace(4)* %generic_ptr, align 4
  ; CHECK-TYPED-PTRS: %[[P4I32_TO_I64:.*]] = ptrtoint i32 addrspace(4)* %generic_ptr.tagged to i64
  ; CHECK-OPAQUE-PTRS: %[[P4I32_TO_I64:.*]] = ptrtoint ptr addrspace(4) %generic_ptr.tagged to i64
  ; CHECK: %[[I64_TO_V2I32:.*]] = bitcast i64 %[[P4I32_TO_I64:.*]] to <2 x i32>
  ; CHECK: %[[TAG:.*]] = extractelement <2 x i32> %[[I64_TO_V2I32:.*]], i64 1
  ; CHECK: %isLocalTag = icmp eq i32 %[[TAG:.*]], 1073741824
  ; CHECK: br i1 %isLocalTag, label %LocalBlock, label %GlobalBlock

  ; CHECK: LocalBlock:
  ; CHECK-TYPED-PTRS: %[[LOCAL_PTR:.*]] = addrspacecast i32 addrspace(4)* %generic_ptr.tagged to i32 addrspace(3)*
  ; CHECK-TYPED-PTRS: store i32 5, i32 addrspace(3)* %[[LOCAL_PTR]], align 4
  ; CHECK-OPAQUE-PTRS: %[[LOCAL_PTR:.*]] = addrspacecast ptr addrspace(4) %generic_ptr.tagged to ptr addrspace(3)
  ; CHECK-OPAQUE-PTRS: store i32 5, ptr addrspace(3) %[[LOCAL_PTR]], align 4

  ; CHECK: GlobalBlock:
  ; CHECK-TYPED-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast i32 addrspace(4)* %generic_ptr.tagged to i32 addrspace(1)*
  ; CHECK-TYPED-PTRS: store i32 5, i32 addrspace(1)* %[[GLOBAL_PTR]], align 4
  ; CHECK-OPAQUE-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast ptr addrspace(4) %generic_ptr.tagged to ptr addrspace(1)
  ; CHECK-OPAQUE-PTRS: store i32 5, ptr addrspace(1) %[[GLOBAL_PTR]], align 4

  ret void
}

define spir_kernel void @kernelB(i32 addrspace(1)* %global_buffer) #0 {
  %generic_ptr = addrspacecast i32 addrspace(1)* %global_buffer to i32 addrspace(4)*

  store i32 5, i32 addrspace(4)* %generic_ptr, align 4
  ; CHECK-TYPED-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast i32 addrspace(4)* %generic_ptr to i32 addrspace(1)*
  ; CHECK-TYPED-PTRS: store i32 5, i32 addrspace(1)* %[[GLOBAL_PTR]], align 4
  ; CHECK-OPAQUE-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast ptr addrspace(4) %generic_ptr to ptr addrspace(1)
  ; CHECK-OPAQUE-PTRS: store i32 5, ptr addrspace(1) %[[GLOBAL_PTR]], align 4
  ret void
}

attributes #0 = { noinline nounwind "CMGenxMain" }
