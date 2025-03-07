;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2024-2025 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXFloatControl -march=genx64 -mcpu=XeHPG \
; RUN: -mtriple=spir64-unknown-unknown -S < %s | FileCheck %s
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXFloatControl -march=genx64 -mcpu=XeHPG \
; RUN: -mtriple=spir64-unknown-unknown -S < %s | FileCheck %s
; RUN: %llc_typed_ptrs %s -march=genx64 -mcpu=XeHPG -vc-skip-ocl-runtime-info \
; RUN: -finalizer-opts='-dumpcommonisa -isaasmToConsole' -o /dev/null | \
; RUN: FileCheck %s --check-prefix=CHECK-VISA
; RUN: %llc_opaque_ptrs %s -march=genx64 -mcpu=XeHPG -vc-skip-ocl-runtime-info \
; RUN: -finalizer-opts='-dumpcommonisa -isaasmToConsole' -o /dev/null | \
; RUN: FileCheck %s --check-prefix=CHECK-VISA

; CHECK-LABEL: define dllexport spir_kernel void @kernel
; CHECK-NEXT: [[AND_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[AND_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[AND_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[AND:[^ ]+]] = and i32 [[AND_RDREGION]], -1265
; CHECK-NEXT: [[AND_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[AND_READ_PREDEF]], i32 [[AND]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[AND_WRREGION]])
; CHECK-NEXT: [[OR_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[OR_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[OR_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[OR:[^ ]+]] = or i32 [[OR_RDREGION]], 1216
; CHECK-NEXT: [[OR_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[OR_READ_PREDEF]], i32 [[OR]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK:     ret
; CHECK-VISA-LABEL: .function "kernel_BB_0"
; CHECK-VISA:      and (M1, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0xfffffb0f:d
; CHECK-VISA-NEXT: or (M1, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0x4c0:d
; CHECK-VISA:      ret (M1, 1)
define dllexport spir_kernel void @kernel(i32 %a, i64 %privBase) #0 {
  call spir_func i32 @stackcall(i32 %a) #1
  ret void
}

; CHECK-LABEL: define internal spir_func i32 @stackcall
; CHECK-NEXT: [[AND_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[AND_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[AND_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[AND:[^ ]+]] = and i32 [[AND_RDREGION]], -1265
; CHECK-NEXT: [[AND_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[AND_READ_PREDEF]], i32 [[AND]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[AND_WRREGION]])
; CHECK-NEXT: [[OR_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[OR_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[OR_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[OR:[^ ]+]] = or i32 [[OR_RDREGION]], 16
; CHECK-NEXT: [[OR_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[OR_READ_PREDEF]], i32 [[OR]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[OR_WRREGION]])
; CHECK:      [[READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[READ_PREDEF]], i32 [[AND_RDREGION]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[WRREGION]])
; CHECK-NEXT: ret
; CHECK-VISA-LABEL: .function "_BB_0"
; CHECK-VISA:      mov (M1_NM, 1) [[REG:V[0-9]+]](0,0)<1> %cr0(0,0)<0;1,0>
; CHECK-VISA-NEXT: and (M1_NM, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0xfffffb0f:d
; CHECK-VISA-NEXT: or (M1_NM, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0x10:d
; CHECK-VISA:      mov (M1_NM, 1) %cr0(0,0)<1> [[REG]](0,0)<0;1,0>
; CHECK-VISA-NEXT: fret (M1, 16)
define internal spir_func i32 @stackcall(i32 %a) #1 {
  %b = call spir_func i32 @subroutine1(i32 %a) #2
  ret i32 %b
}

; CHECK-LABEL: define internal spir_func i32 @subroutine1
; CHECK-NEXT: [[AND_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[AND_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[AND_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[AND:[^ ]+]] = and i32 [[AND_RDREGION]], -1265
; CHECK-NEXT: [[AND_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[AND_READ_PREDEF]], i32 [[AND]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[AND_WRREGION]])
; CHECK-NEXT: [[OR_READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[OR_RDREGION:[^ ]+]] = call i32 @llvm.genx.rdregioni.i32.v4i32.i16(<4 x i32> [[OR_READ_PREDEF]], i32 0, i32 1, i32 1, i16 0, i32 undef)
; CHECK-NEXT: [[OR:[^ ]+]] = or i32 [[OR_RDREGION]], 32
; CHECK-NEXT: [[OR_WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[OR_READ_PREDEF]], i32 [[OR]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[OR_WRREGION]])
; CHECK:      [[READ_PREDEF:[^ ]+]] = call <4 x i32> @llvm.genx.read.predef.reg.v4i32.v4i32(i32 14, <4 x i32> undef)
; CHECK-NEXT: [[WRREGION:[^ ]+]] = call <4 x i32> @llvm.genx.wrregioni.v4i32.i32.i16.i1(<4 x i32> [[READ_PREDEF]], i32 [[AND_RDREGION]], i32 0, i32 1, i32 1, i16 0, i32 undef, i1 true)
; CHECK-NEXT: call <4 x i32> @llvm.genx.write.predef.reg.v4i32.v4i32(i32 14, <4 x i32> [[WRREGION]])
; CHECK-NEXT: ret
; CHECK-VISA-LABEL: .function "subroutine1_BB_1"
; CHECK-VISA:      mov (M1_NM, 1) [[REG:V[0-9]+]](0,0)<1> %cr0(0,0)<0;1,0>
; CHECK-VISA-NEXT: and (M1_NM, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0xfffffb0f:d
; CHECK-VISA-NEXT: or (M1_NM, 1) %cr0(0,0)<1> %cr0(0,0)<0;1,0> 0x20:d
; CHECK-VISA:      mov (M1_NM, 1) %cr0(0,0)<1> [[REG]](0,0)<0;1,0>
; CHECK-VISA-NEXT: ret (M1, 1)
define internal spir_func i32 @subroutine1(i32 %a) #2 {
  %b = call spir_func i32 @subroutine2(i32 %a) #3
  ret i32 %b
}

; CHECK-LABEL: define internal spir_func i32 @subroutine2
; CHECK-NOT: predef
; CHECK:     ret
; CHECK-VISA-LABEL: .function "subroutine2_BB_2"
; CHECK-VISA-NOT: %cr0
; CHECK-VISA:     ret (M1, 1)
define internal spir_func i32 @subroutine2(i32 %a) #3 {
  %b = add i32 %a, 1
  ret i32 %b
}

attributes #0 = { noinline nounwind "CMGenxMain" }
attributes #1 = { noinline nounwind "CMStackCall" "CMFloatControl"="16" }
attributes #2 = { noinline nounwind "CMFloatControl"="32" }
attributes #3 = { noinline nounwind }

!genx.kernels = !{!2}
!genx.kernel.internal = !{!7}

!0 = !{i32 0, i32 0}
!1 = !{}
!2 = !{void (i32, i64)* @kernel, !"kernel", !3, i32 0, !4, !5, !6, i32 0}
!3 = !{i32 2, i32 96}
!4 = !{i32 72, i32 64}
!5 = !{i32 0}
!6 = !{!"buffer_t read_write"}
!7 = !{void (i32, i64)* @kernel, !0, !8, !1, !8}
!8 = !{i32 0, i32 1}
