;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================
;
; REQUIRES: llvm-14-plus, regkeys
; RUN: igc_opt --opaque-pointers --regkey PrintToConsole --CheckInstrTypes -igc-serialize-metadata --enable-instrtypes-print -S < %s 2>&1 | FileCheck %s
; ------------------------------------------------
; CheckInstrTypes
; ------------------------------------------------

; Test checks whether usage of generic pointers is properly detected when memcpy is present in a module

; CHECK: hasGenericAddressSpacePointers: 1
; CHECK: hasDynamicGenericLoadStore: 1

define void @test_func(i8 addrspace(4)* %src, i8 addrspace(4)* %dst) {
entry:
  call void @llvm.memcpy.p4i8.p4i8.i32(i8 addrspace(4)* %dst, i8 addrspace(4)* %src, i32 4, i1 false)
  ret void
}

declare void @llvm.memcpy.p4i8.p4i8.i32(i8 addrspace(4)*, i8 addrspace(4)*, i32, i1)

!IGCMetadata = !{!0}
!igc.functions = !{!4}

!0 = !{!"ModuleMD", !1}
!1 = !{!"FuncMD", !2, !3}
!2 = !{!"FuncMDMap[0]", void (i8 addrspace(4)*, i8 addrspace(4)*)* @test_func}
!3 = !{!"FuncMDValue[0]"}
!4 = !{void (i8 addrspace(4)*, i8 addrspace(4)*)* @test_func, !5}
!5 = !{!6}
!6 = !{!"function_type", i32 0}
