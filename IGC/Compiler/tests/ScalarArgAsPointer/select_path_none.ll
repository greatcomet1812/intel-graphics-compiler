;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2023-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; REQUIRES: llvm-14-plus
; RUN: igc_opt --opaque-pointers --igc-scalar-arg-as-pointer-analysis -igc-serialize-metadata -S %s | FileCheck %s
;
; Tests "select" instruction, when no path leads to scalar as pointer.
;
; CHECK-NOT: !{!"m_OpenCLArgScalarAsPointersSet{{[[][0-9][]]}}", i32 0}
; CHECK-NOT: !{!"m_OpenCLArgScalarAsPointersSet{{[[][0-9][]]}}", i32 1}
; CHECK-NOT  !{!"m_OpenCLArgScalarAsPointersSet{{[[][0-9][]]}}", i32 2}

define spir_kernel void @test(i1 %s, i32 addrspace(1)* %a, i32 addrspace(1)* %b) #0 {
entry:
  %0 = select i1 %s, i32 addrspace(1)* %a, i32 addrspace(1)* %b
  %add.ptr = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 0
  store i32 39, i32 addrspace(1)* %add.ptr, align 4
  ret void
}

!igc.functions = !{!0}

!0 = !{void (i1, i32 addrspace(1)*, i32 addrspace(1)*)* @test, !1}
!1 = !{!2}
!2 = !{!"function_type", i32 0}
