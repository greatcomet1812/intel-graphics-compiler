;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2023-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; RUN: %llc_typed_ptrs %s -march=genx64 -mcpu=Xe2 -vc-skip-ocl-runtime-info -finalizer-opts='-dumpvisa -dumpcommonisa -isaasmToConsole' -o /dev/null | \
; RUN: FileCheck %s
; RUN: %llc_opaque_ptrs %s -march=genx64 -mcpu=Xe2 -vc-skip-ocl-runtime-info -finalizer-opts='-dumpvisa -dumpcommonisa -isaasmToConsole' -o /dev/null | \
; RUN: FileCheck %s

declare i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32>, i32, i32, i32, i16, i32) #1
declare !genx_intrinsic_id !28 <64 x i8> @llvm.vc.internal.lsc.load.2d.tgm.bti.v64i8.v2i8(<2 x i8>, i32, i32, i32, i32, i32) #2
declare !genx_intrinsic_id !29 void @llvm.vc.internal.lsc.store.2d.tgm.bti.v2i8.v64i8(<2 x i8>, i32, i32, i32, i32, i32, <64 x i8>) #3

declare void @llvm.vc.internal.lsc.store.quad.tgm.v4i1.v2i8.v4i32.v4i32(<4 x i1>, <2 x i8>, i8, i32, <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32>) #3

define dllexport spir_kernel void @test_genx(<2 x i32> %base, <2 x i32> %x, <2 x i32> %y, i16 %offset) local_unnamed_addr #0 {
  %offset.new = add i16 %offset, 4
  %x.sc = tail call i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32> %x, i32 0, i32 1, i32 1, i16 %offset, i32 0)
  %y.sc = tail call i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32> %y, i32 0, i32 1, i32 1, i16 %offset, i32 0)
  %base.sc.ld = tail call i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32> <i32 1, i32 2>, i32 0, i32 1, i32 1, i16 %offset, i32 0)
  %base.sc.st = tail call i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32> <i32 1, i32 2>, i32 0, i32 1, i32 1, i16 %offset.new, i32 0)
; CHECK: lsc_load_block2d.tgm  V{{[0-9]+}}:8x8  bti(V{{[0-9]+}})[V{{[0-9]+}},V{{[0-9]+}}]
  %ld.tgm = call <64 x i8> @llvm.vc.internal.lsc.load.2d.tgm.bti.v64i8.v2i8(<2 x i8> zeroinitializer, i32 %base.sc.ld, i32 8, i32 8, i32 %x.sc, i32 %y.sc)
; CHECK: lsc_store_block2d.tgm  bti(V{{[0-9]+}})[V{{[0-9]+}},V{{[0-9]+}}]  V{{[0-9]+}}:8x8
  call void @llvm.vc.internal.lsc.store.2d.tgm.bti.v2i8.v64i8(<2 x i8> zeroinitializer, i32 %base.sc.st, i32 8, i32 8, i32 %x.sc, i32 %y.sc, <64 x i8> %ld.tgm)
  ret void
}

define spir_kernel void @test_internal(<4 x i32> %x, <2 x i32> %base, i16 %offset) local_unnamed_addr #0 {
  %offset.new = add i16 %offset, 4
  %base.new = tail call i32 @llvm.genx.rdregioni.i32.v2i32.i16(<2 x i32> %base, i32 0, i32 1, i32 1, i16 %offset.new, i32 0)
; CHECK: lsc_store_quad.tgm (M1, 4)  bti(V{{[0-9]+}})
  call void @llvm.vc.internal.lsc.store.quad.tgm.v4i1.v2i8.v4i32.v4i32(<4 x i1> <i1 true, i1 true, i1 true, i1 true>, <2 x i8> zeroinitializer, i8 1, i32 %base.new, <4 x i32> %x, <4 x i32> %x, <4 x i32> %x, <4 x i32> %x, <4 x i32> %x)
  ret void
}

attributes #0 = { noinline nounwind "CMGenxMain" }
attributes #1 = { nofree nosync nounwind readnone }
attributes #2 = { nounwind readonly }
attributes #3 = { nounwind writeonly }

!spirv.Source = !{!1}
!opencl.spir.version = !{!2}
!opencl.ocl.version = !{!1}
!opencl.used.extensions = !{!0}
!opencl.used.optional.core.features = !{!0}
!spirv.Generator = !{!3}
!genx.kernels = !{!4, !9}
!genx.kernel.internal = !{!8, !13}

!0 = !{}
!1 = !{i32 0}
!2 = !{i32 1, i32 1}
!3 = !{i16 6, i16 14}
!4 = !{void (<2 x i32>, <2 x i32>, <2 x i32>, i16)* @test_genx, !"test_genx", !5, i32 0, !6, !1, !7, i32 0}
!5 = !{i32 0, i32 0, i32 0, i32 0}
!6 = !{i32 8, i32 16, i32 24, i32 32}
!7 = !{!""}
!8 = !{void (<2 x i32>, <2 x i32>, <2 x i32>, i16)* @test_genx, null, null, null, null}
!9 = !{void (<4 x i32>, <2 x i32>, i16)* @test_internal, !"test_internal", !10, i32 0, !11, !1, !12, i32 0}
!10 = !{i32 0, i32 0, i32 0}
!11 = !{i32 64, i32 128, i32 256}
!12 = !{!""}
!13 = !{void (<4 x i32>, <2 x i32>, i16)* @test_internal, null, null, null, null}

!25 = !{i32 10973}
!28 = !{i32 10919}
!29 = !{i32 10937}
