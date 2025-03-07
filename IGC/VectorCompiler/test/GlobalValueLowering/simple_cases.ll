;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2020-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXGlobalValueLowering -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-TYPED-PTRS
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXGlobalValueLowering -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-OPAQUE-PTRS

target datalayout = "e-p:64:64-i64:64-n8:16:32"

@simple_global_array = internal global [8 x i32] [i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49], align 4

define dllexport void @simple_array(i64 %provided.offset) {
; COM: all the lowered globals are at the function entry
; CHECK-TYPED-PTRS: %[[GADDR:[^ ]+]] = call i64 @llvm.genx.gaddr.i64.p0a8i32([8 x i32]* @simple_global_array)
; CHECK-TYPED-PTRS: %[[INTTOPTR:[^ ]+]] = inttoptr i64 %[[GADDR]] to [8 x i32]*
; CHECK-OPAQUE-PTRS: %[[GADDR:[^ ]+]] = call i64 @llvm.genx.gaddr.i64.p0(ptr @simple_global_array)
; CHECK-OPAQUE-PTRS: %[[INTTOPTR:[^ ]+]] = inttoptr i64 %[[GADDR]] to ptr

  %ptrtoint.case = ptrtoint [8 x i32]* @simple_global_array to i64
; COM: optimized out
; CHECK-TYPED-PTRS-NOT: %ptrtoint.case = ptrtoint [8 x i32]* @simple_global_array to i64
; CHECK-OPAQUE-PTRS-NOT: %ptrtoint.case = ptrtoint ptr @simple_global_array to i64
  %ptrtoint.case.user = add i64 %ptrtoint.case, 3
; CHECK: %ptrtoint.case.user = add i64 %[[GADDR]], 3

  %gep.case = getelementptr inbounds [8 x i32], [8 x i32]* @simple_global_array, i64 0, i64 %provided.offset
; CHECK-TYPED-PTRS: %gep.case = getelementptr inbounds [8 x i32], [8 x i32]* %[[INTTOPTR]], i64 0, i64 %provided.offset
; CHECK-OPAQUE-PTRS: %gep.case = getelementptr inbounds [8 x i32], ptr %[[INTTOPTR]], i64 0, i64 %provided.offset
  ret void
}
