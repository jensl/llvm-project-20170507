; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=AVX,AVX512,AVXNOVLBW,AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512,AVXNOVLBW,AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512,AVX512VLBW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,+avx512vbmi | FileCheck %s --check-prefixes=AVX,AVX512,AVX512VLBW,VBMI

define <2 x i64> @var_shuffle_v2i64(<2 x i64> %v, <2 x i64> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v2i64:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movq %xmm1, %rax
; SSSE3-NEXT:    andl $1, %eax
; SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm1, %rcx
; SSSE3-NEXT:    andl $1, %ecx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v2i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq %xmm1, %rax
; AVX-NEXT:    andl $1, %eax
; AVX-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX-NEXT:    andl $1, %ecx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    retq
  %index0 = extractelement <2 x i64> %indices, i32 0
  %index1 = extractelement <2 x i64> %indices, i32 1
  %v0 = extractelement <2 x i64> %v, i64 %index0
  %v1 = extractelement <2 x i64> %v, i64 %index1
  %ret0 = insertelement <2 x i64> undef, i64 %v0, i32 0
  %ret1 = insertelement <2 x i64> %ret0, i64 %v1, i32 1
  ret <2 x i64> %ret1
}

define <4 x i32> @var_shuffle_v4i32(<4 x i32> %v, <4 x i32> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v4i32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm2, %rax
; SSSE3-NEXT:    movq %rax, %rcx
; SSSE3-NEXT:    sarq $32, %rcx
; SSSE3-NEXT:    movq %xmm1, %rdx
; SSSE3-NEXT:    movq %rdx, %rsi
; SSSE3-NEXT:    sarq $32, %rsi
; SSSE3-NEXT:    andl $3, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $3, %esi
; SSSE3-NEXT:    andl $3, %eax
; SSSE3-NEXT:    andl $3, %ecx
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpextrq $1, %xmm1, %rax
; AVX-NEXT:    movq %rax, %rcx
; AVX-NEXT:    sarq $32, %rcx
; AVX-NEXT:    vmovq %xmm1, %rdx
; AVX-NEXT:    movq %rdx, %rsi
; AVX-NEXT:    sarq $32, %rsi
; AVX-NEXT:    andl $3, %edx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    andl $3, %eax
; AVX-NEXT:    andl $3, %ecx
; AVX-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vpinsrd $1, -24(%rsp,%rsi,4), %xmm0, %xmm0
; AVX-NEXT:    vpinsrd $2, -24(%rsp,%rax,4), %xmm0, %xmm0
; AVX-NEXT:    vpinsrd $3, -24(%rsp,%rcx,4), %xmm0, %xmm0
; AVX-NEXT:    retq
  %index0 = extractelement <4 x i32> %indices, i32 0
  %index1 = extractelement <4 x i32> %indices, i32 1
  %index2 = extractelement <4 x i32> %indices, i32 2
  %index3 = extractelement <4 x i32> %indices, i32 3
  %v0 = extractelement <4 x i32> %v, i32 %index0
  %v1 = extractelement <4 x i32> %v, i32 %index1
  %v2 = extractelement <4 x i32> %v, i32 %index2
  %v3 = extractelement <4 x i32> %v, i32 %index3
  %ret0 = insertelement <4 x i32> undef, i32 %v0, i32 0
  %ret1 = insertelement <4 x i32> %ret0, i32 %v1, i32 1
  %ret2 = insertelement <4 x i32> %ret1, i32 %v2, i32 2
  %ret3 = insertelement <4 x i32> %ret2, i32 %v3, i32 3
  ret <4 x i32> %ret3
}

define <8 x i16> @var_shuffle_v8i16(<8 x i16> %v, <8 x i16> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v8i16:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movd %xmm1, %r8d
; SSSE3-NEXT:    pextrw $1, %xmm1, %r9d
; SSSE3-NEXT:    pextrw $2, %xmm1, %r10d
; SSSE3-NEXT:    pextrw $3, %xmm1, %esi
; SSSE3-NEXT:    pextrw $4, %xmm1, %edi
; SSSE3-NEXT:    pextrw $5, %xmm1, %eax
; SSSE3-NEXT:    pextrw $6, %xmm1, %ecx
; SSSE3-NEXT:    pextrw $7, %xmm1, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $7, %r8d
; SSSE3-NEXT:    andl $7, %r9d
; SSSE3-NEXT:    andl $7, %r10d
; SSSE3-NEXT:    andl $7, %esi
; SSSE3-NEXT:    andl $7, %edi
; SSSE3-NEXT:    andl $7, %eax
; SSSE3-NEXT:    andl $7, %ecx
; SSSE3-NEXT:    andl $7, %edx
; SSSE3-NEXT:    movzwl -24(%rsp,%rdx,2), %edx
; SSSE3-NEXT:    movd %edx, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%rcx,2), %ecx
; SSSE3-NEXT:    movd %ecx, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movzwl -24(%rsp,%rax,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%rdi,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; SSSE3-NEXT:    movzwl -24(%rsp,%rsi,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%r10,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movzwl -24(%rsp,%r9,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm3
; SSSE3-NEXT:    movzwl -24(%rsp,%r8,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSSE3-NEXT:    retq
;
; AVXNOVLBW-LABEL: var_shuffle_v8i16:
; AVXNOVLBW:       # %bb.0:
; AVXNOVLBW-NEXT:    vmovd %xmm1, %eax
; AVXNOVLBW-NEXT:    vpextrw $1, %xmm1, %r10d
; AVXNOVLBW-NEXT:    vpextrw $2, %xmm1, %ecx
; AVXNOVLBW-NEXT:    vpextrw $3, %xmm1, %edx
; AVXNOVLBW-NEXT:    vpextrw $4, %xmm1, %esi
; AVXNOVLBW-NEXT:    vpextrw $5, %xmm1, %edi
; AVXNOVLBW-NEXT:    vpextrw $6, %xmm1, %r8d
; AVXNOVLBW-NEXT:    vpextrw $7, %xmm1, %r9d
; AVXNOVLBW-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVXNOVLBW-NEXT:    andl $7, %eax
; AVXNOVLBW-NEXT:    andl $7, %r10d
; AVXNOVLBW-NEXT:    andl $7, %ecx
; AVXNOVLBW-NEXT:    andl $7, %edx
; AVXNOVLBW-NEXT:    andl $7, %esi
; AVXNOVLBW-NEXT:    andl $7, %edi
; AVXNOVLBW-NEXT:    andl $7, %r8d
; AVXNOVLBW-NEXT:    andl $7, %r9d
; AVXNOVLBW-NEXT:    movzwl -24(%rsp,%rax,2), %eax
; AVXNOVLBW-NEXT:    vmovd %eax, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $1, -24(%rsp,%r10,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $2, -24(%rsp,%rcx,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $3, -24(%rsp,%rdx,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $4, -24(%rsp,%rsi,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $5, -24(%rsp,%rdi,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $6, -24(%rsp,%r8,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $7, -24(%rsp,%r9,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    retq
;
; AVX512VLBW-LABEL: var_shuffle_v8i16:
; AVX512VLBW:       # %bb.0:
; AVX512VLBW-NEXT:    vpermw %xmm0, %xmm1, %xmm0
; AVX512VLBW-NEXT:    retq
  %index0 = extractelement <8 x i16> %indices, i32 0
  %index1 = extractelement <8 x i16> %indices, i32 1
  %index2 = extractelement <8 x i16> %indices, i32 2
  %index3 = extractelement <8 x i16> %indices, i32 3
  %index4 = extractelement <8 x i16> %indices, i32 4
  %index5 = extractelement <8 x i16> %indices, i32 5
  %index6 = extractelement <8 x i16> %indices, i32 6
  %index7 = extractelement <8 x i16> %indices, i32 7
  %v0 = extractelement <8 x i16> %v, i16 %index0
  %v1 = extractelement <8 x i16> %v, i16 %index1
  %v2 = extractelement <8 x i16> %v, i16 %index2
  %v3 = extractelement <8 x i16> %v, i16 %index3
  %v4 = extractelement <8 x i16> %v, i16 %index4
  %v5 = extractelement <8 x i16> %v, i16 %index5
  %v6 = extractelement <8 x i16> %v, i16 %index6
  %v7 = extractelement <8 x i16> %v, i16 %index7
  %ret0 = insertelement <8 x i16> undef, i16 %v0, i32 0
  %ret1 = insertelement <8 x i16> %ret0, i16 %v1, i32 1
  %ret2 = insertelement <8 x i16> %ret1, i16 %v2, i32 2
  %ret3 = insertelement <8 x i16> %ret2, i16 %v3, i32 3
  %ret4 = insertelement <8 x i16> %ret3, i16 %v4, i32 4
  %ret5 = insertelement <8 x i16> %ret4, i16 %v5, i32 5
  %ret6 = insertelement <8 x i16> %ret5, i16 %v6, i32 6
  %ret7 = insertelement <8 x i16> %ret6, i16 %v7, i32 7
  ret <8 x i16> %ret7
}

define <16 x i8> @var_shuffle_v16i8(<16 x i8> %v, <16 x i8> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v16i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %index0 = extractelement <16 x i8> %indices, i32 0
  %index1 = extractelement <16 x i8> %indices, i32 1
  %index2 = extractelement <16 x i8> %indices, i32 2
  %index3 = extractelement <16 x i8> %indices, i32 3
  %index4 = extractelement <16 x i8> %indices, i32 4
  %index5 = extractelement <16 x i8> %indices, i32 5
  %index6 = extractelement <16 x i8> %indices, i32 6
  %index7 = extractelement <16 x i8> %indices, i32 7
  %index8 = extractelement <16 x i8> %indices, i32 8
  %index9 = extractelement <16 x i8> %indices, i32 9
  %index10 = extractelement <16 x i8> %indices, i32 10
  %index11 = extractelement <16 x i8> %indices, i32 11
  %index12 = extractelement <16 x i8> %indices, i32 12
  %index13 = extractelement <16 x i8> %indices, i32 13
  %index14 = extractelement <16 x i8> %indices, i32 14
  %index15 = extractelement <16 x i8> %indices, i32 15
  %v0 = extractelement <16 x i8> %v, i8 %index0
  %v1 = extractelement <16 x i8> %v, i8 %index1
  %v2 = extractelement <16 x i8> %v, i8 %index2
  %v3 = extractelement <16 x i8> %v, i8 %index3
  %v4 = extractelement <16 x i8> %v, i8 %index4
  %v5 = extractelement <16 x i8> %v, i8 %index5
  %v6 = extractelement <16 x i8> %v, i8 %index6
  %v7 = extractelement <16 x i8> %v, i8 %index7
  %v8 = extractelement <16 x i8> %v, i8 %index8
  %v9 = extractelement <16 x i8> %v, i8 %index9
  %v10 = extractelement <16 x i8> %v, i8 %index10
  %v11 = extractelement <16 x i8> %v, i8 %index11
  %v12 = extractelement <16 x i8> %v, i8 %index12
  %v13 = extractelement <16 x i8> %v, i8 %index13
  %v14 = extractelement <16 x i8> %v, i8 %index14
  %v15 = extractelement <16 x i8> %v, i8 %index15
  %ret0 = insertelement <16 x i8> undef, i8 %v0, i32 0
  %ret1 = insertelement <16 x i8> %ret0, i8 %v1, i32 1
  %ret2 = insertelement <16 x i8> %ret1, i8 %v2, i32 2
  %ret3 = insertelement <16 x i8> %ret2, i8 %v3, i32 3
  %ret4 = insertelement <16 x i8> %ret3, i8 %v4, i32 4
  %ret5 = insertelement <16 x i8> %ret4, i8 %v5, i32 5
  %ret6 = insertelement <16 x i8> %ret5, i8 %v6, i32 6
  %ret7 = insertelement <16 x i8> %ret6, i8 %v7, i32 7
  %ret8 = insertelement <16 x i8> %ret7, i8 %v8, i32 8
  %ret9 = insertelement <16 x i8> %ret8, i8 %v9, i32 9
  %ret10 = insertelement <16 x i8> %ret9, i8 %v10, i32 10
  %ret11 = insertelement <16 x i8> %ret10, i8 %v11, i32 11
  %ret12 = insertelement <16 x i8> %ret11, i8 %v12, i32 12
  %ret13 = insertelement <16 x i8> %ret12, i8 %v13, i32 13
  %ret14 = insertelement <16 x i8> %ret13, i8 %v14, i32 14
  %ret15 = insertelement <16 x i8> %ret14, i8 %v15, i32 15
  ret <16 x i8> %ret15
}

define <2 x double> @var_shuffle_v2f64(<2 x double> %v, <2 x i64> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v2f64:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movq %xmm1, %rax
; SSSE3-NEXT:    andl $1, %eax
; SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm1, %rcx
; SSSE3-NEXT:    andl $1, %ecx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq %xmm1, %rax
; AVX-NEXT:    andl $1, %eax
; AVX-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX-NEXT:    andl $1, %ecx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; AVX-NEXT:    retq
  %index0 = extractelement <2 x i64> %indices, i32 0
  %index1 = extractelement <2 x i64> %indices, i32 1
  %v0 = extractelement <2 x double> %v, i64 %index0
  %v1 = extractelement <2 x double> %v, i64 %index1
  %ret0 = insertelement <2 x double> undef, double %v0, i32 0
  %ret1 = insertelement <2 x double> %ret0, double %v1, i32 1
  ret <2 x double> %ret1
}

define <4 x float> @var_shuffle_v4f32(<4 x float> %v, <4 x i32> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v4f32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm2, %rax
; SSSE3-NEXT:    movq %rax, %rcx
; SSSE3-NEXT:    sarq $32, %rcx
; SSSE3-NEXT:    movq %xmm1, %rdx
; SSSE3-NEXT:    movq %rdx, %rsi
; SSSE3-NEXT:    sarq $32, %rsi
; SSSE3-NEXT:    andl $3, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $3, %esi
; SSSE3-NEXT:    andl $3, %eax
; SSSE3-NEXT:    andl $3, %ecx
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpextrq $1, %xmm1, %rax
; AVX-NEXT:    movq %rax, %rcx
; AVX-NEXT:    sarq $32, %rcx
; AVX-NEXT:    vmovq %xmm1, %rdx
; AVX-NEXT:    movq %rdx, %rsi
; AVX-NEXT:    sarq $32, %rsi
; AVX-NEXT:    andl $3, %edx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    andl $3, %eax
; AVX-NEXT:    andl $3, %ecx
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],mem[0],xmm0[3]
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],mem[0]
; AVX-NEXT:    retq
  %index0 = extractelement <4 x i32> %indices, i32 0
  %index1 = extractelement <4 x i32> %indices, i32 1
  %index2 = extractelement <4 x i32> %indices, i32 2
  %index3 = extractelement <4 x i32> %indices, i32 3
  %v0 = extractelement <4 x float> %v, i32 %index0
  %v1 = extractelement <4 x float> %v, i32 %index1
  %v2 = extractelement <4 x float> %v, i32 %index2
  %v3 = extractelement <4 x float> %v, i32 %index3
  %ret0 = insertelement <4 x float> undef, float %v0, i32 0
  %ret1 = insertelement <4 x float> %ret0, float %v1, i32 1
  %ret2 = insertelement <4 x float> %ret1, float %v2, i32 2
  %ret3 = insertelement <4 x float> %ret2, float %v3, i32 3
  ret <4 x float> %ret3
}

define <16 x i8> @var_shuffle_v16i8_from_v16i8_v32i8(<16 x i8> %v, <32 x i8> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v16i8_from_v16i8_v32i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v16i8_from_v16i8_v32i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %index0 = extractelement <32 x i8> %indices, i32 0
  %index1 = extractelement <32 x i8> %indices, i32 1
  %index2 = extractelement <32 x i8> %indices, i32 2
  %index3 = extractelement <32 x i8> %indices, i32 3
  %index4 = extractelement <32 x i8> %indices, i32 4
  %index5 = extractelement <32 x i8> %indices, i32 5
  %index6 = extractelement <32 x i8> %indices, i32 6
  %index7 = extractelement <32 x i8> %indices, i32 7
  %index8 = extractelement <32 x i8> %indices, i32 8
  %index9 = extractelement <32 x i8> %indices, i32 9
  %index10 = extractelement <32 x i8> %indices, i32 10
  %index11 = extractelement <32 x i8> %indices, i32 11
  %index12 = extractelement <32 x i8> %indices, i32 12
  %index13 = extractelement <32 x i8> %indices, i32 13
  %index14 = extractelement <32 x i8> %indices, i32 14
  %index15 = extractelement <32 x i8> %indices, i32 15
  %v0 = extractelement <16 x i8> %v, i8 %index0
  %v1 = extractelement <16 x i8> %v, i8 %index1
  %v2 = extractelement <16 x i8> %v, i8 %index2
  %v3 = extractelement <16 x i8> %v, i8 %index3
  %v4 = extractelement <16 x i8> %v, i8 %index4
  %v5 = extractelement <16 x i8> %v, i8 %index5
  %v6 = extractelement <16 x i8> %v, i8 %index6
  %v7 = extractelement <16 x i8> %v, i8 %index7
  %v8 = extractelement <16 x i8> %v, i8 %index8
  %v9 = extractelement <16 x i8> %v, i8 %index9
  %v10 = extractelement <16 x i8> %v, i8 %index10
  %v11 = extractelement <16 x i8> %v, i8 %index11
  %v12 = extractelement <16 x i8> %v, i8 %index12
  %v13 = extractelement <16 x i8> %v, i8 %index13
  %v14 = extractelement <16 x i8> %v, i8 %index14
  %v15 = extractelement <16 x i8> %v, i8 %index15
  %ret0 = insertelement <16 x i8> undef, i8 %v0, i32 0
  %ret1 = insertelement <16 x i8> %ret0, i8 %v1, i32 1
  %ret2 = insertelement <16 x i8> %ret1, i8 %v2, i32 2
  %ret3 = insertelement <16 x i8> %ret2, i8 %v3, i32 3
  %ret4 = insertelement <16 x i8> %ret3, i8 %v4, i32 4
  %ret5 = insertelement <16 x i8> %ret4, i8 %v5, i32 5
  %ret6 = insertelement <16 x i8> %ret5, i8 %v6, i32 6
  %ret7 = insertelement <16 x i8> %ret6, i8 %v7, i32 7
  %ret8 = insertelement <16 x i8> %ret7, i8 %v8, i32 8
  %ret9 = insertelement <16 x i8> %ret8, i8 %v9, i32 9
  %ret10 = insertelement <16 x i8> %ret9, i8 %v10, i32 10
  %ret11 = insertelement <16 x i8> %ret10, i8 %v11, i32 11
  %ret12 = insertelement <16 x i8> %ret11, i8 %v12, i32 12
  %ret13 = insertelement <16 x i8> %ret12, i8 %v13, i32 13
  %ret14 = insertelement <16 x i8> %ret13, i8 %v14, i32 14
  %ret15 = insertelement <16 x i8> %ret14, i8 %v15, i32 15
  ret <16 x i8> %ret15
}

define <16 x i8> @var_shuffle_v16i8_from_v32i8_v16i8(<32 x i8> %v, <16 x i8> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v16i8_from_v32i8_v16i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pushq %rbp
; SSSE3-NEXT:    movq %rsp, %rbp
; SSSE3-NEXT:    pushq %r15
; SSSE3-NEXT:    pushq %r14
; SSSE3-NEXT:    pushq %r13
; SSSE3-NEXT:    pushq %r12
; SSSE3-NEXT:    pushq %rbx
; SSSE3-NEXT:    andq $-32, %rsp
; SSSE3-NEXT:    subq $608, %rsp # imm = 0x260
; SSSE3-NEXT:    movaps %xmm2, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %eax
; SSSE3-NEXT:    movq %rax, {{[0-9]+}}(%rsp) # 8-byte Spill
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %eax
; SSSE3-NEXT:    movq %rax, {{[0-9]+}}(%rsp) # 8-byte Spill
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %eax
; SSSE3-NEXT:    movq %rax, {{[0-9]+}}(%rsp) # 8-byte Spill
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r11d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r14d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r15d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r12d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r13d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r10d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r8d
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %edi
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %esi
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %ecx
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %edx
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %eax
; SSSE3-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movzbl {{[0-9]+}}(%rsp), %r9d
; SSSE3-NEXT:    andl $31, %r9d
; SSSE3-NEXT:    movzbl 64(%rsp,%r9), %ebx
; SSSE3-NEXT:    movd %ebx, %xmm8
; SSSE3-NEXT:    andl $31, %eax
; SSSE3-NEXT:    movzbl 96(%rsp,%rax), %eax
; SSSE3-NEXT:    movd %eax, %xmm15
; SSSE3-NEXT:    andl $31, %edx
; SSSE3-NEXT:    movzbl 128(%rsp,%rdx), %eax
; SSSE3-NEXT:    movd %eax, %xmm9
; SSSE3-NEXT:    andl $31, %ecx
; SSSE3-NEXT:    movzbl 160(%rsp,%rcx), %eax
; SSSE3-NEXT:    movd %eax, %xmm3
; SSSE3-NEXT:    andl $31, %esi
; SSSE3-NEXT:    movzbl 192(%rsp,%rsi), %eax
; SSSE3-NEXT:    movd %eax, %xmm10
; SSSE3-NEXT:    andl $31, %edi
; SSSE3-NEXT:    movzbl 224(%rsp,%rdi), %eax
; SSSE3-NEXT:    movd %eax, %xmm7
; SSSE3-NEXT:    andl $31, %r8d
; SSSE3-NEXT:    movzbl 256(%rsp,%r8), %eax
; SSSE3-NEXT:    movd %eax, %xmm11
; SSSE3-NEXT:    andl $31, %r10d
; SSSE3-NEXT:    movzbl 288(%rsp,%r10), %eax
; SSSE3-NEXT:    movd %eax, %xmm6
; SSSE3-NEXT:    andl $31, %r13d
; SSSE3-NEXT:    movzbl 320(%rsp,%r13), %eax
; SSSE3-NEXT:    movd %eax, %xmm12
; SSSE3-NEXT:    andl $31, %r12d
; SSSE3-NEXT:    movzbl 352(%rsp,%r12), %eax
; SSSE3-NEXT:    movd %eax, %xmm5
; SSSE3-NEXT:    andl $31, %r15d
; SSSE3-NEXT:    movzbl 384(%rsp,%r15), %eax
; SSSE3-NEXT:    movd %eax, %xmm13
; SSSE3-NEXT:    andl $31, %r14d
; SSSE3-NEXT:    movzbl 416(%rsp,%r14), %eax
; SSSE3-NEXT:    movd %eax, %xmm4
; SSSE3-NEXT:    andl $31, %r11d
; SSSE3-NEXT:    movzbl 448(%rsp,%r11), %eax
; SSSE3-NEXT:    movd %eax, %xmm14
; SSSE3-NEXT:    movq {{[0-9]+}}(%rsp), %rax # 8-byte Reload
; SSSE3-NEXT:    andl $31, %eax
; SSSE3-NEXT:    movzbl 480(%rsp,%rax), %eax
; SSSE3-NEXT:    movd %eax, %xmm1
; SSSE3-NEXT:    movq {{[0-9]+}}(%rsp), %rax # 8-byte Reload
; SSSE3-NEXT:    andl $31, %eax
; SSSE3-NEXT:    movzbl 512(%rsp,%rax), %eax
; SSSE3-NEXT:    movd %eax, %xmm2
; SSSE3-NEXT:    movq {{[0-9]+}}(%rsp), %rax # 8-byte Reload
; SSSE3-NEXT:    andl $31, %eax
; SSSE3-NEXT:    movzbl 544(%rsp,%rax), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm15 = xmm15[0],xmm8[0],xmm15[1],xmm8[1],xmm15[2],xmm8[2],xmm15[3],xmm8[3],xmm15[4],xmm8[4],xmm15[5],xmm8[5],xmm15[6],xmm8[6],xmm15[7],xmm8[7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm3 = xmm3[0],xmm9[0],xmm3[1],xmm9[1],xmm3[2],xmm9[2],xmm3[3],xmm9[3],xmm3[4],xmm9[4],xmm3[5],xmm9[5],xmm3[6],xmm9[6],xmm3[7],xmm9[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm15[0],xmm3[1],xmm15[1],xmm3[2],xmm15[2],xmm3[3],xmm15[3]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm7 = xmm7[0],xmm10[0],xmm7[1],xmm10[1],xmm7[2],xmm10[2],xmm7[3],xmm10[3],xmm7[4],xmm10[4],xmm7[5],xmm10[5],xmm7[6],xmm10[6],xmm7[7],xmm10[7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm6 = xmm6[0],xmm11[0],xmm6[1],xmm11[1],xmm6[2],xmm11[2],xmm6[3],xmm11[3],xmm6[4],xmm11[4],xmm6[5],xmm11[5],xmm6[6],xmm11[6],xmm6[7],xmm11[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm6 = xmm6[0],xmm7[0],xmm6[1],xmm7[1],xmm6[2],xmm7[2],xmm6[3],xmm7[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm6 = xmm6[0],xmm3[0],xmm6[1],xmm3[1]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm5 = xmm5[0],xmm12[0],xmm5[1],xmm12[1],xmm5[2],xmm12[2],xmm5[3],xmm12[3],xmm5[4],xmm12[4],xmm5[5],xmm12[5],xmm5[6],xmm12[6],xmm5[7],xmm12[7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm4 = xmm4[0],xmm13[0],xmm4[1],xmm13[1],xmm4[2],xmm13[2],xmm4[3],xmm13[3],xmm4[4],xmm13[4],xmm4[5],xmm13[5],xmm4[6],xmm13[6],xmm4[7],xmm13[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm4 = xmm4[0],xmm5[0],xmm4[1],xmm5[1],xmm4[2],xmm5[2],xmm4[3],xmm5[3]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm14[0],xmm1[1],xmm14[1],xmm1[2],xmm14[2],xmm1[3],xmm14[3],xmm1[4],xmm14[4],xmm1[5],xmm14[5],xmm1[6],xmm14[6],xmm1[7],xmm14[7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm4[0],xmm0[1],xmm4[1]
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm6[0]
; SSSE3-NEXT:    leaq -40(%rbp), %rsp
; SSSE3-NEXT:    popq %rbx
; SSSE3-NEXT:    popq %r12
; SSSE3-NEXT:    popq %r13
; SSSE3-NEXT:    popq %r14
; SSSE3-NEXT:    popq %r15
; SSSE3-NEXT:    popq %rbp
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v16i8_from_v32i8_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    vpextrb $0, %xmm1, %eax
; AVX-NEXT:    vmovaps %ymm0, (%rsp)
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    movzbl (%rsp,%rax), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    vpextrb $1, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $1, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $2, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $2, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $3, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $3, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $4, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $4, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $5, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $5, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $6, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $6, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $7, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $7, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $8, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $8, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $9, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $9, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $10, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $10, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $11, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $11, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $12, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $12, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $13, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $13, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $14, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $14, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    vpextrb $15, %xmm1, %eax
; AVX-NEXT:    andl $31, %eax
; AVX-NEXT:    vpinsrb $15, (%rsp,%rax), %xmm0, %xmm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %index0 = extractelement <16 x i8> %indices, i32 0
  %index1 = extractelement <16 x i8> %indices, i32 1
  %index2 = extractelement <16 x i8> %indices, i32 2
  %index3 = extractelement <16 x i8> %indices, i32 3
  %index4 = extractelement <16 x i8> %indices, i32 4
  %index5 = extractelement <16 x i8> %indices, i32 5
  %index6 = extractelement <16 x i8> %indices, i32 6
  %index7 = extractelement <16 x i8> %indices, i32 7
  %index8 = extractelement <16 x i8> %indices, i32 8
  %index9 = extractelement <16 x i8> %indices, i32 9
  %index10 = extractelement <16 x i8> %indices, i32 10
  %index11 = extractelement <16 x i8> %indices, i32 11
  %index12 = extractelement <16 x i8> %indices, i32 12
  %index13 = extractelement <16 x i8> %indices, i32 13
  %index14 = extractelement <16 x i8> %indices, i32 14
  %index15 = extractelement <16 x i8> %indices, i32 15
  %v0 = extractelement <32 x i8> %v, i8 %index0
  %v1 = extractelement <32 x i8> %v, i8 %index1
  %v2 = extractelement <32 x i8> %v, i8 %index2
  %v3 = extractelement <32 x i8> %v, i8 %index3
  %v4 = extractelement <32 x i8> %v, i8 %index4
  %v5 = extractelement <32 x i8> %v, i8 %index5
  %v6 = extractelement <32 x i8> %v, i8 %index6
  %v7 = extractelement <32 x i8> %v, i8 %index7
  %v8 = extractelement <32 x i8> %v, i8 %index8
  %v9 = extractelement <32 x i8> %v, i8 %index9
  %v10 = extractelement <32 x i8> %v, i8 %index10
  %v11 = extractelement <32 x i8> %v, i8 %index11
  %v12 = extractelement <32 x i8> %v, i8 %index12
  %v13 = extractelement <32 x i8> %v, i8 %index13
  %v14 = extractelement <32 x i8> %v, i8 %index14
  %v15 = extractelement <32 x i8> %v, i8 %index15
  %ret0 = insertelement <16 x i8> undef, i8 %v0, i32 0
  %ret1 = insertelement <16 x i8> %ret0, i8 %v1, i32 1
  %ret2 = insertelement <16 x i8> %ret1, i8 %v2, i32 2
  %ret3 = insertelement <16 x i8> %ret2, i8 %v3, i32 3
  %ret4 = insertelement <16 x i8> %ret3, i8 %v4, i32 4
  %ret5 = insertelement <16 x i8> %ret4, i8 %v5, i32 5
  %ret6 = insertelement <16 x i8> %ret5, i8 %v6, i32 6
  %ret7 = insertelement <16 x i8> %ret6, i8 %v7, i32 7
  %ret8 = insertelement <16 x i8> %ret7, i8 %v8, i32 8
  %ret9 = insertelement <16 x i8> %ret8, i8 %v9, i32 9
  %ret10 = insertelement <16 x i8> %ret9, i8 %v10, i32 10
  %ret11 = insertelement <16 x i8> %ret10, i8 %v11, i32 11
  %ret12 = insertelement <16 x i8> %ret11, i8 %v12, i32 12
  %ret13 = insertelement <16 x i8> %ret12, i8 %v13, i32 13
  %ret14 = insertelement <16 x i8> %ret13, i8 %v14, i32 14
  %ret15 = insertelement <16 x i8> %ret14, i8 %v15, i32 15
  ret <16 x i8> %ret15
}
