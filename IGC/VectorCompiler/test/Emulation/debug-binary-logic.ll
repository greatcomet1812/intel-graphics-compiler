;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2022-2025 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================
;
; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXEmulate -march=genx64 -mtriple=spir64-unknown-unknown  -mcpu=XeHPG -mattr=+emulate_i64 -S < %s | FileCheck %s
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXEmulate -march=genx64 -mtriple=spir64-unknown-unknown  -mcpu=XeHPG -mattr=+emulate_i64 -S < %s | FileCheck %s
; ------------------------------------------------
; GenXEmulate
; ------------------------------------------------
; This test checks that GenXEmulate pass follows
; 'How to Update Debug Info' llvm guideline.
;
; Debug MD for this test was created with debugify pass.
;
; Binary instructions lowering

; CHECK: void @test_emulate{{.*}} !dbg [[SCOPE:![0-9]*]]
; CHECK: entry:
; CHECK-DAG: void @llvm.dbg.value(metadata i64 [[VAL1_V:%[A-z0-9.]*]], metadata [[VAL1_MD:![0-9]*]], metadata !DIExpression()), !dbg [[VAL1_LOC:![0-9]*]]
; CHECK-DAG: [[VAL1_V]] = {{.*}}, !dbg [[VAL1_LOC]]
; CHECK-DAG: void @llvm.dbg.value(metadata i64 [[VAL2_V:%[A-z0-9.]*]], metadata [[VAL2_MD:![0-9]*]], metadata !DIExpression()), !dbg [[VAL2_LOC:![0-9]*]]
; CHECK-DAG: [[VAL2_V]] = {{.*}}, !dbg [[VAL2_LOC]]
; CHECK-DAG: void @llvm.dbg.value(metadata i64 [[VAL3_V:%[A-z0-9.]*]], metadata [[VAL3_MD:![0-9]*]], metadata !DIExpression()), !dbg [[VAL3_LOC:![0-9]*]]
; CHECK-DAG: [[VAL3_V]] = {{.*}}, !dbg [[VAL3_LOC]]
; CHECK-DAG: void @llvm.dbg.value(metadata i64 [[VAL4_V:%[A-z0-9.]*]], metadata [[VAL4_MD:![0-9]*]], metadata !DIExpression()), !dbg [[VAL4_LOC:![0-9]*]]
; CHECK-DAG: [[VAL4_V]] = {{.*}}, !dbg [[VAL4_LOC]]
; CHECK-DAG: void @llvm.dbg.value(metadata i64 [[VAL5_V:%[A-z0-9.]*]], metadata [[VAL5_MD:![0-9]*]], metadata !DIExpression()), !dbg [[VAL5_LOC:![0-9]*]]
; CHECK-DAG: [[VAL5_V]] = {{.*}}, !dbg [[VAL5_LOC]]
; CHECK: store i64{{.*}} !dbg [[STR1_LOC:![0-9]*]]

define void @test_emulate(i64 %a, i64 %b, i64* %dst) !dbg !6 {
entry:
  %0 = add i64 %a, %b, !dbg !15
  call void @llvm.dbg.value(metadata i64 %0, metadata !9, metadata !DIExpression()), !dbg !15
  %1 = sub i64 %b, %a, !dbg !16
  call void @llvm.dbg.value(metadata i64 %1, metadata !11, metadata !DIExpression()), !dbg !16
  %2 = and i64 %0, %1, !dbg !17
  call void @llvm.dbg.value(metadata i64 %2, metadata !12, metadata !DIExpression()), !dbg !17
  %3 = xor i64 %1, %2, !dbg !18
  call void @llvm.dbg.value(metadata i64 %3, metadata !13, metadata !DIExpression()), !dbg !18
  %4 = or i64 %1, %2, !dbg !19
  call void @llvm.dbg.value(metadata i64 %4, metadata !14, metadata !DIExpression()), !dbg !19
  store i64 %4, i64* %dst, !dbg !20
  ret void, !dbg !21
}

; CHECK-DAG: [[FILE:![0-9]*]] = !DIFile(filename: "binary_logic.ll", directory: "/")
; CHECK-DAG: [[SCOPE]] = distinct !DISubprogram(name: "test_emulate", linkageName: "test_emulate", scope: null, file: [[FILE]], line: 1
; CHECK-DAG: [[VAL1_MD]] = !DILocalVariable(name: "1", scope: [[SCOPE]], file: [[FILE]], line: 1
; CHECK-DAG: [[VAL1_LOC]] = !DILocation(line: 1, column: 1, scope: [[SCOPE]])
; CHECK-DAG: [[VAL2_MD]] = !DILocalVariable(name: "2", scope: [[SCOPE]], file: [[FILE]], line: 2
; CHECK-DAG: [[VAL2_LOC]] = !DILocation(line: 2, column: 1, scope: [[SCOPE]])
; CHECK-DAG: [[VAL3_MD]] = !DILocalVariable(name: "3", scope: [[SCOPE]], file: [[FILE]], line: 3
; CHECK-DAG: [[VAL3_LOC]] = !DILocation(line: 3, column: 1, scope: [[SCOPE]])
; CHECK-DAG: [[VAL4_MD]] = !DILocalVariable(name: "4", scope: [[SCOPE]], file: [[FILE]], line: 4
; CHECK-DAG: [[VAL4_LOC]] = !DILocation(line: 4, column: 1, scope: [[SCOPE]])
; CHECK-DAG: [[VAL5_MD]] = !DILocalVariable(name: "5", scope: [[SCOPE]], file: [[FILE]], line: 5
; CHECK-DAG: [[VAL5_LOC]] = !DILocation(line: 5, column: 1, scope: [[SCOPE]])
; CHECK-DAG: [[STR1_LOC]] = !DILocation(line: 6, column: 1, scope: [[SCOPE]])

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #0

attributes #0 = { nounwind readnone speculatable }

!llvm.dbg.cu = !{!0}
!llvm.debugify = !{!3, !4}
!llvm.module.flags = !{!5}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "debugify", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "binary_logic.ll", directory: "/")
!2 = !{}
!3 = !{i32 7}
!4 = !{i32 5}
!5 = !{i32 2, !"Debug Info Version", i32 3}
!6 = distinct !DISubprogram(name: "test_emulate", linkageName: "test_emulate", scope: null, file: !1, line: 1, type: !7, scopeLine: 1, unit: !0, retainedNodes: !8)
!7 = !DISubroutineType(types: !2)
!8 = !{!9, !11, !12, !13, !14}
!9 = !DILocalVariable(name: "1", scope: !6, file: !1, line: 1, type: !10)
!10 = !DIBasicType(name: "ty64", size: 64, encoding: DW_ATE_unsigned)
!11 = !DILocalVariable(name: "2", scope: !6, file: !1, line: 2, type: !10)
!12 = !DILocalVariable(name: "3", scope: !6, file: !1, line: 3, type: !10)
!13 = !DILocalVariable(name: "4", scope: !6, file: !1, line: 4, type: !10)
!14 = !DILocalVariable(name: "5", scope: !6, file: !1, line: 5, type: !10)
!15 = !DILocation(line: 1, column: 1, scope: !6)
!16 = !DILocation(line: 2, column: 1, scope: !6)
!17 = !DILocation(line: 3, column: 1, scope: !6)
!18 = !DILocation(line: 4, column: 1, scope: !6)
!19 = !DILocation(line: 5, column: 1, scope: !6)
!20 = !DILocation(line: 6, column: 1, scope: !6)
!21 = !DILocation(line: 7, column: 1, scope: !6)
