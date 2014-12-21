	.file	"alloc.c"
	.local	heap
	.comm	heap,4,4
	.local	heap_length
	.comm	heap_length,4,4
	.local	heap_begin
	.comm	heap_begin,4,4
	.section	.rodata
	.align 4
	.type	ALLOC_BM, @object
	.size	ALLOC_BM, 4
ALLOC_BM:
	.long	-2147483648
	.align 4
	.type	MARK_BM, @object
	.size	MARK_BM, 4
MARK_BM:
	.long	1073741824
	.align 4
	.type	LENGTH_BM, @object
	.size	LENGTH_BM, 4
LENGTH_BM:
	.long	1073741823
	.local	esp
	.comm	esp,4,4
	.local	ebp
	.comm	ebp,4,4
	.align 4
.LC0:
	.string	"size is less than or equal to 0"
.LC1:
	.string	"heap is not null"
.LC2:
	.string	"heap failed to initialize"
	.text
	.globl	memInitialize
	.type	memInitialize, @function
memInitialize:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$40, %esp
	cmpl	$0, 8(%ebp)
	jne	.L2
	movl	$.LC0, (%esp)
	call	error
	jmp	.L3
.L2:
	movl	heap, %eax
	testl	%eax, %eax
	je	.L4
	movl	$.LC1, (%esp)
	call	error
	jmp	.L3
.L4:
	movl	8(%ebp), %eax
	sall	$2, %eax
	movl	%eax, (%esp)
	call	malloc
	movl	%eax, heap
	movl	heap, %eax
	testl	%eax, %eax
	jne	.L5
	movl	$.LC2, (%esp)
	call	error
	jmp	.L3
.L5:
	movl	heap, %eax
	movl	%eax, heap_begin
	movl	8(%ebp), %eax
	movl	%eax, heap_length
	movl	$0, -12(%ebp)
	jmp	.L6
.L7:
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	$0, (%eax)
	addl	$1, -12(%ebp)
.L6:
	movl	-12(%ebp), %eax
	cmpl	8(%ebp), %eax
	jb	.L7
	movl	heap, %eax
	movl	LENGTH_BM, %edx
	andl	8(%ebp), %edx
	movl	%edx, (%eax)
	movl	heap, %eax
	addl	$4, %eax
	movl	$0, (%eax)
	movl	$1, %eax
.L3:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	memInitialize, .-memInitialize
	.section	.rodata
.LC3:
	.string	"==== memAllocate ====\n"
	.align 4
.LC4:
	.string	"first Size is greater than allocated memory"
	.text
	.globl	memAllocate
	.type	memAllocate, @function
memAllocate:
.LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$88, %esp
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC3, %eax
	movl	%edx, 12(%esp)
	movl	$22, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	movl	heap, %eax
	movl	%eax, -12(%ebp)
	movl	$0, -16(%ebp)
	movl	$1073741823, -20(%ebp)
	call	getEsp
	movl	%eax, esp
	call	getEbp
	movl	%eax, ebp
	movl	heap_length, %eax
	subl	$2, %eax
	cmpl	8(%ebp), %eax
	ja	.L9
	movl	$.LC4, (%esp)
	call	error
	jmp	.L10
.L9:
	movl	$0, -24(%ebp)
	jmp	.L11
.L13:
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseAlloc
	movl	%eax, -28(%ebp)
	cmpl	$0, -28(%ebp)
	jne	.L12
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	cmpl	-20(%ebp), %eax
	jg	.L12
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	8(%ebp), %edx
	addl	$2, %edx
	cmpl	%edx, %eax
	jb	.L12
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -20(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
.L12:
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	addl	%eax, -24(%ebp)
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	sall	$2, %eax
	addl	%eax, -12(%ebp)
.L11:
	movl	heap_length, %eax
	cmpl	%eax, -24(%ebp)
	jl	.L13
	cmpl	$0, -16(%ebp)
	jne	.L14
	call	GC_mark
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	sweep
	movl	%eax, -32(%ebp)
	call	memJoin
	cmpl	$0, -32(%ebp)
	jne	.L15
	movl	$0, %eax
	jmp	.L10
.L15:
	movl	12(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	memAllocate
	jmp	.L10
.L14:
	movl	$-2147483648, -36(%ebp)
	movl	$0, -40(%ebp)
	movl	8(%ebp), %eax
	addl	$2, %eax
	movl	%eax, -44(%ebp)
	movl	-40(%ebp), %eax
	movl	-36(%ebp), %edx
	orl	%edx, %eax
	orl	-44(%ebp), %eax
	movl	%eax, -48(%ebp)
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -52(%ebp)
	movl	-16(%ebp), %eax
	addl	$8, %eax
	movl	%eax, -56(%ebp)
	movl	-48(%ebp), %edx
	movl	-16(%ebp), %eax
	movl	%edx, (%eax)
	movl	-16(%ebp), %eax
	leal	4(%eax), %edx
	movl	12(%ebp), %eax
	movl	%eax, (%edx)
	movl	8(%ebp), %eax
	leal	2(%eax), %edx
	movl	-52(%ebp), %eax
	cmpl	%eax, %edx
	jae	.L16
	movl	-52(%ebp), %eax
	subl	8(%ebp), %eax
	subl	$2, %eax
	movl	%eax, -60(%ebp)
	movl	-60(%ebp), %eax
	sall	$2, %eax
	movl	%eax, -64(%ebp)
	movl	-64(%ebp), %eax
	shrl	$2, %eax
	movl	%eax, -60(%ebp)
	movl	-44(%ebp), %eax
	sall	$2, %eax
	addl	%eax, -16(%ebp)
	movl	-16(%ebp), %eax
	movl	-60(%ebp), %edx
	movl	%edx, (%eax)
.L16:
	movl	-56(%ebp), %eax
.L10:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE1:
	.size	memAllocate, .-memAllocate
	.type	GC_getAllocatedHeader, @function
GC_getAllocatedHeader:
.LFB2:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$40, %esp
	movl	heap, %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	jmp	.L18
.L21:
	movl	8(%ebp), %eax
	cmpl	-16(%ebp), %eax
	jb	.L19
	movl	8(%ebp), %eax
	cmpl	-12(%ebp), %eax
	ja	.L19
	movl	-16(%ebp), %eax
	jmp	.L20
.L19:
	movl	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	sall	$2, %eax
	addl	%eax, -12(%ebp)
.L18:
	movl	heap, %eax
	movl	heap_length, %edx
	subl	$1, %edx
	sall	$2, %edx
	addl	%edx, %eax
	cmpl	-12(%ebp), %eax
	jae	.L21
	movl	$0, %eax
.L20:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE2:
	.size	GC_getAllocatedHeader, .-GC_getAllocatedHeader
	.globl	GC_mark
	.type	GC_mark, @function
GC_mark:
.LFB3:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$72, %esp
	movl	$__data_start, -16(%ebp)
	movl	$_end, -24(%ebp)
	jmp	.L23
.L24:
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_recurse_marker
	addl	$4, -16(%ebp)
.L23:
	movl	-16(%ebp), %eax
	cmpl	-24(%ebp), %eax
	jb	.L24
	movl	ebp, %eax
	movl	%eax, -20(%ebp)
	jmp	.L25
.L26:
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)
.L25:
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	testl	%eax, %eax
	jne	.L26
	movl	-20(%ebp), %eax
	movl	%eax, -28(%ebp)
	movl	esp, %eax
	movl	%eax, -32(%ebp)
	movl	$0, -12(%ebp)
	jmp	.L27
.L29:
	movl	-12(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-28(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L28
	movl	-12(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-28(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_recurse_marker
.L28:
	addl	$1, -12(%ebp)
.L27:
	movl	-12(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-28(%ebp), %eax
	cmpl	-32(%ebp), %eax
	jae	.L29
	call	getEbx
	movl	%eax, -36(%ebp)
	call	getEsi
	movl	%eax, -40(%ebp)
	call	getEdi
	movl	%eax, -44(%ebp)
	movl	-36(%ebp), %eax
	movl	%eax, -56(%ebp)
	movl	-40(%ebp), %eax
	movl	%eax, -52(%ebp)
	movl	-44(%ebp), %eax
	movl	%eax, -48(%ebp)
	movl	$0, -12(%ebp)
	jmp	.L30
.L31:
	movl	-12(%ebp), %eax
	leal	0(,%eax,4), %edx
	leal	-56(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, (%esp)
	call	GC_recurse_marker
	addl	$1, -12(%ebp)
.L30:
	cmpl	$2, -12(%ebp)
	jle	.L31
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE3:
	.size	GC_mark, .-GC_mark
	.globl	GC_recurse_marker
	.type	GC_recurse_marker, @function
GC_recurse_marker:
.LFB4:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$40, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L32
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L32
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_getAllocatedHeader
	movl	%eax, -16(%ebp)
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseMark
	movl	%eax, %edx
	movl	MARK_BM, %eax
	cmpl	%eax, %edx
	je	.L38
.L34:
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, %edx
	movl	MARK_BM, %eax
	orl	%edx, %eax
	movl	%eax, %edx
	movl	-16(%ebp), %eax
	movl	%edx, (%eax)
	movl	$2, -12(%ebp)
	jmp	.L35
.L37:
	movl	-12(%ebp), %eax
	sall	$2, %eax
	addl	-16(%ebp), %eax
	movl	%eax, -20(%ebp)
	cmpl	$0, -20(%ebp)
	je	.L36
	movl	-20(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_recurse_marker
.L36:
	addl	$1, -12(%ebp)
.L35:
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	cmpl	-12(%ebp), %eax
	jg	.L37
	jmp	.L32
.L38:
	nop
.L32:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4:
	.size	GC_recurse_marker, .-GC_recurse_marker
	.globl	GC_isAllocated
	.type	GC_isAllocated, @function
GC_isAllocated:
.LFB5:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$56, %esp
	movl	heap, %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	$0, -20(%ebp)
	jmp	.L40
.L45:
	movl	8(%ebp), %eax
	cmpl	-16(%ebp), %eax
	jb	.L41
	movl	8(%ebp), %eax
	cmpl	-12(%ebp), %eax
	ja	.L41
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseAlloc
	movl	%eax, -28(%ebp)
	cmpl	$-2147483648, -28(%ebp)
	jne	.L42
	movl	$1, -24(%ebp)
	jmp	.L43
.L42:
	movl	$0, -24(%ebp)
.L43:
	movl	-24(%ebp), %eax
	jmp	.L44
.L41:
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	addl	%eax, -20(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	sall	$2, %eax
	addl	%eax, -12(%ebp)
.L40:
	movl	heap, %eax
	movl	heap_length, %edx
	sall	$2, %edx
	addl	%edx, %eax
	cmpl	-12(%ebp), %eax
	jae	.L45
	movl	$-1, %eax
.L44:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE5:
	.size	GC_isAllocated, .-GC_isAllocated
	.globl	GC_sweep
	.type	GC_sweep, @function
GC_sweep:
.LFB6:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$40, %esp
	movl	$0, -12(%ebp)
	jmp	.L47
.L50:
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseAlloc
	movl	%eax, -16(%ebp)
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseMark
	movl	%eax, -20(%ebp)
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -24(%ebp)
	cmpl	$-2147483648, -16(%ebp)
	jne	.L48
	cmpl	$0, -20(%ebp)
	jne	.L49
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%eax, %edx
	movl	-24(%ebp), %eax
	movl	%eax, (%edx)
.L49:
	cmpl	$1073741824, -20(%ebp)
	jne	.L48
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	heap, %edx
	movl	-12(%ebp), %ecx
	sall	$2, %ecx
	addl	%ecx, %edx
	movl	(%edx), %edx
	andl	$-1073741825, %edx
	movl	%edx, (%eax)
.L48:
	movl	-24(%ebp), %eax
	addl	%eax, -12(%ebp)
.L47:
	movl	heap_length, %eax
	cmpl	%eax, -12(%ebp)
	jl	.L50
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE6:
	.size	GC_sweep, .-GC_sweep
	.type	memJoin, @function
memJoin:
.LFB7:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$56, %esp
	movl	$0, -12(%ebp)
	movl	heap, %eax
	movl	%eax, -16(%ebp)
	movl	$0, -20(%ebp)
	movl	$0, -24(%ebp)
	jmp	.L52
.L54:
	cmpl	$0, -20(%ebp)
	je	.L53
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseAlloc
	movl	%eax, -28(%ebp)
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseAlloc
	movl	%eax, -32(%ebp)
	cmpl	$0, -28(%ebp)
	jne	.L53
	cmpl	$0, -32(%ebp)
	jne	.L53
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -36(%ebp)
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -40(%ebp)
	movl	-40(%ebp), %eax
	movl	-36(%ebp), %edx
	addl	%eax, %edx
	movl	-20(%ebp), %eax
	movl	%edx, (%eax)
	movl	$1, -12(%ebp)
.L53:
	movl	-16(%ebp), %eax
	movl	%eax, -20(%ebp)
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, (%esp)
	call	parseLength
	addl	%eax, -24(%ebp)
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	sall	$2, %eax
	addl	%eax, -16(%ebp)
.L52:
	movl	heap_length, %eax
	cmpl	%eax, -24(%ebp)
	jl	.L54
	cmpl	$1, -12(%ebp)
	jne	.L51
	call	memJoin
.L51:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE7:
	.size	memJoin, .-memJoin
	.globl	GC_isInHeap
	.type	GC_isInHeap, @function
GC_isInHeap:
.LFB8:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	heap, %eax
	cmpl	%eax, 8(%ebp)
	jb	.L57
	movl	heap, %eax
	movl	heap_length, %edx
	sall	$2, %edx
	addl	%edx, %eax
	cmpl	8(%ebp), %eax
	jb	.L57
	movl	$1, %eax
	jmp	.L58
.L57:
	movl	$0, %eax
.L58:
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE8:
	.size	GC_isInHeap, .-GC_isInHeap
	.section	.rodata
.LC5:
	.string	"[%d] %08x   %08x\n"
	.align 4
.LC6:
	.string	"---------------------------------"
.LC7:
	.string	">> [%d] %08x    %08x\n"
	.text
	.globl	testDump
	.type	testDump, @function
testDump:
.LFB9:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%ebx
	subl	$36, %esp
	movl	$0, -12(%ebp)
	jmp	.L60
	.cfi_offset 3, -12
.L63:
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	testl	%eax, %eax
	jne	.L61
	movl	heap, %eax
	movl	%eax, %ecx
	addl	-12(%ebp), %ecx
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %edx
	movl	$.LC5, %eax
	movl	%ecx, 12(%esp)
	movl	%edx, 8(%esp)
	movl	-12(%ebp), %edx
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	printf
	jmp	.L62
.L61:
	movl	$.LC6, (%esp)
	call	puts
	movl	heap, %eax
	movl	%eax, %ecx
	addl	-12(%ebp), %ecx
	movl	heap, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %edx
	movl	$.LC7, %eax
	movl	%ecx, 12(%esp)
	movl	%edx, 8(%esp)
	movl	-12(%ebp), %edx
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	printf
	movl	heap, %eax
	addl	-12(%ebp), %eax
	leal	1(%eax), %ebx
	movl	heap, %eax
	movl	-12(%ebp), %edx
	addl	$1, %edx
	sall	$2, %edx
	addl	%edx, %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	leal	1(%eax), %ecx
	movl	$.LC7, %eax
	movl	%ebx, 12(%esp)
	movl	%edx, 8(%esp)
	movl	%ecx, 4(%esp)
	movl	%eax, (%esp)
	call	printf
	movl	$.LC6, (%esp)
	call	puts
	addl	$1, -12(%ebp)
.L62:
	addl	$1, -12(%ebp)
.L60:
	movl	heap_length, %eax
	cmpl	%eax, -12(%ebp)
	jl	.L63
	addl	$36, %esp
	popl	%ebx
	.cfi_restore 3
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE9:
	.size	testDump, .-testDump
	.section	.rodata
	.align 4
.LC8:
	.string	"Global Memory: start=%08x end=%08x length=%d\n\n"
.LC9:
	.string	"%08x %08x\n"
	.align 4
.LC10:
	.string	"Stack Memory: start=%08x end=%08x length=%d\n\n"
.LC11:
	.string	"Registers\n\n"
.LC12:
	.string	"ebx %08x* "
.LC13:
	.string	"ebx %08x  "
.LC14:
	.string	"esi %08x* "
.LC15:
	.string	"esi %08x  "
.LC16:
	.string	"edi %08x* "
.LC17:
	.string	"edi %08x  "
.LC18:
	.string	"Heap\n\n"
.LC19:
	.string	"Block %d "
.LC20:
	.string	"Free "
.LC21:
	.string	"Allocated "
.LC22:
	.string	"Marked %08x\n"
.LC23:
	.string	"Unmarked %08x\n"
.LC24:
	.string	"%08x  "
.LC25:
	.string	"%08x* "
	.text
	.globl	memDump
	.type	memDump, @function
memDump:
.LFB10:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%esi
	pushl	%ebx
	addl	$-128, %esp
	movl	$_end, %edx
	movl	$__data_start, %eax
	movl	%edx, %ecx
	subl	%eax, %ecx
	movl	%ecx, %eax
	sarl	$2, %eax
	movl	%eax, -56(%ebp)
	movl	$__data_start, -12(%ebp)
	movl	$_end, -60(%ebp)
	movl	$0, -16(%ebp)
	.cfi_offset 3, -16
	.cfi_offset 6, -12
	call	sweep
	movl	$_end, %ebx
	movl	$__data_start, %ecx
	movl	$.LC8, %edx
	movl	stderr, %eax
	movl	-56(%ebp), %esi
	movl	%esi, 16(%esp)
	movl	%ebx, 12(%esp)
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L65
.L67:
	movl	heap, %eax
	cmpl	%eax, -12(%ebp)
	je	.L66
	cmpl	$heap_length, -12(%ebp)
	je	.L66
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L66
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L66
	movl	-12(%ebp), %eax
	movl	(%eax), %ebx
	movl	-12(%ebp), %ecx
	movl	$.LC9, %edx
	movl	stderr, %eax
	movl	%ebx, 12(%esp)
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	movl	$1, -16(%ebp)
.L66:
	addl	$4, -12(%ebp)
.L65:
	movl	-12(%ebp), %eax
	cmpl	-60(%ebp), %eax
	jb	.L67
	cmpl	$1, -16(%ebp)
	jne	.L68
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
.L68:
	movl	ebp, %eax
	movl	%eax, -20(%ebp)
	movl	$0, -24(%ebp)
	jmp	.L69
.L70:
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)
.L69:
	movl	-20(%ebp), %eax
	movl	(%eax), %eax
	testl	%eax, %eax
	jne	.L70
	movl	-20(%ebp), %eax
	movl	%eax, -64(%ebp)
	movl	esp, %eax
	movl	%eax, -68(%ebp)
	movl	ebp, %edx
	movl	esp, %eax
	movl	%edx, %esi
	subl	%eax, %esi
	movl	esp, %ebx
	movl	ebp, %ecx
	movl	$.LC10, %edx
	movl	stderr, %eax
	movl	%esi, 16(%esp)
	movl	%ebx, 12(%esp)
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	movl	$0, -28(%ebp)
	jmp	.L71
.L73:
	movl	-28(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-64(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L72
	movl	-28(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-64(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L72
	movl	-28(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-64(%ebp), %eax
	movl	(%eax), %ebx
	movl	-28(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-64(%ebp), %eax
	movl	%eax, %ecx
	movl	$.LC9, %edx
	movl	stderr, %eax
	movl	%ebx, 12(%esp)
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	movl	$1, -24(%ebp)
.L72:
	addl	$1, -28(%ebp)
.L71:
	movl	-28(%ebp), %eax
	sall	$2, %eax
	negl	%eax
	addl	-64(%ebp), %eax
	cmpl	-68(%ebp), %eax
	ja	.L73
	cmpl	$1, -24(%ebp)
	jne	.L74
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
.L74:
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC11, %eax
	movl	%edx, 12(%esp)
	movl	$11, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	call	getEbx
	movl	%eax, -72(%ebp)
	movl	-72(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L75
	movl	-72(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L76
	movl	$.LC12, %edx
	movl	stderr, %eax
	movl	-72(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L76
.L75:
	movl	$.LC13, %edx
	movl	stderr, %eax
	movl	-72(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L76:
	call	getEsi
	movl	%eax, -76(%ebp)
	movl	-76(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L77
	movl	-76(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L78
	movl	$.LC14, %edx
	movl	stderr, %eax
	movl	-76(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L78
.L77:
	movl	$.LC15, %edx
	movl	stderr, %eax
	movl	-76(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L78:
	call	getEdi
	movl	%eax, -80(%ebp)
	movl	-80(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	cmpl	$1, %eax
	jne	.L79
	movl	-80(%ebp), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L80
	movl	$.LC16, %edx
	movl	stderr, %eax
	movl	-80(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L80
.L79:
	movl	$.LC17, %edx
	movl	stderr, %eax
	movl	-80(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L80:
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC18, %eax
	movl	%edx, 12(%esp)
	movl	$6, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	movl	heap, %eax
	movl	%eax, -32(%ebp)
	movl	$0, -36(%ebp)
	jmp	.L81
.L96:
	movl	-32(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	parseLength
	movl	%eax, -84(%ebp)
	movl	-32(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, %edx
	movl	ALLOC_BM, %eax
	andl	%edx, %eax
	movl	%eax, -88(%ebp)
	movl	-32(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, %edx
	movl	MARK_BM, %eax
	andl	%edx, %eax
	movl	%eax, -92(%ebp)
	cmpl	$0, -88(%ebp)
	jne	.L82
	movl	$.LC19, %edx
	movl	stderr, %eax
	movl	-84(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L82:
	cmpl	$-2147483648, -88(%ebp)
	jne	.L83
	movl	-84(%ebp), %eax
	leal	-2(%eax), %ecx
	movl	$.LC19, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L83:
	movl	$0, -40(%ebp)
	cmpl	$0, -88(%ebp)
	jne	.L84
	cmpl	$0, -92(%ebp)
	jne	.L84
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC20, %eax
	movl	%edx, 12(%esp)
	movl	$5, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	movl	$0, -40(%ebp)
	jmp	.L85
.L84:
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC21, %eax
	movl	%edx, 12(%esp)
	movl	$10, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	movl	$1, -40(%ebp)
.L85:
	cmpl	$1073741824, -92(%ebp)
	jne	.L86
	movl	-32(%ebp), %eax
	addl	$4, %eax
	movl	(%eax), %ecx
	movl	$.LC22, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L87
.L86:
	movl	-32(%ebp), %eax
	addl	$4, %eax
	movl	(%eax), %ecx
	movl	$.LC23, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L87:
	cmpl	$1, -40(%ebp)
	jne	.L88
	movl	$0, -44(%ebp)
	movl	-32(%ebp), %eax
	addl	$8, %eax
	movl	%eax, -48(%ebp)
	movl	$0, -52(%ebp)
	jmp	.L89
.L95:
	movl	-52(%ebp), %ecx
	movl	$-1840700269, %edx
	movl	%ecx, %eax
	imull	%edx
	leal	(%edx,%ecx), %eax
	movl	%eax, %edx
	sarl	$2, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	sall	$3, %eax
	subl	%edx, %eax
	movl	%ecx, %edx
	subl	%eax, %edx
	testl	%edx, %edx
	jne	.L90
	movl	-48(%ebp), %ecx
	movl	$.LC24, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L90:
	addl	$1, -44(%ebp)
	movl	-48(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isInHeap
	testl	%eax, %eax
	jne	.L91
	movl	-48(%ebp), %eax
	movl	(%eax), %ecx
	movl	$.LC24, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L92
.L91:
	movl	-48(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	GC_isAllocated
	cmpl	$1, %eax
	jne	.L93
	movl	-48(%ebp), %eax
	movl	(%eax), %ecx
	movl	$.LC25, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	jmp	.L92
.L93:
	movl	-48(%ebp), %eax
	movl	(%eax), %ecx
	movl	$.LC24, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
.L92:
	movl	-44(%ebp), %ecx
	movl	$-1840700269, %edx
	movl	%ecx, %eax
	imull	%edx
	leal	(%edx,%ecx), %eax
	movl	%eax, %edx
	sarl	$2, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	sall	$3, %eax
	subl	%edx, %eax
	movl	%ecx, %edx
	subl	%eax, %edx
	testl	%edx, %edx
	jne	.L94
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
.L94:
	addl	$4, -48(%ebp)
	addl	$1, -52(%ebp)
.L89:
	movl	-84(%ebp), %eax
	subl	$2, %eax
	cmpl	-52(%ebp), %eax
	jg	.L95
.L88:
	movl	stderr, %eax
	movl	%eax, 4(%esp)
	movl	$10, (%esp)
	call	fputc
	movl	-84(%ebp), %eax
	addl	%eax, -36(%ebp)
	movl	-84(%ebp), %eax
	sall	$2, %eax
	addl	%eax, -32(%ebp)
.L81:
	movl	heap_length, %eax
	cmpl	%eax, -36(%ebp)
	jl	.L96
	subl	$-128, %esp
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE10:
	.size	memDump, .-memDump
	.section	.rodata
	.align 4
.LC26:
	.string	"!!!!!!!!!!!!\n!! LENGTH IS 0 !!\n!!!!!!!!!!!!\n"
	.text
	.type	parseLength, @function
parseLength:
.LFB11:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	LENGTH_BM, %eax
	andl	8(%ebp), %eax
	testl	%eax, %eax
	jne	.L98
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC26, %eax
	movl	%edx, 12(%esp)
	movl	$44, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
.L98:
	movl	LENGTH_BM, %eax
	andl	8(%ebp), %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE11:
	.size	parseLength, .-parseLength
	.type	parseAlloc, @function
parseAlloc:
.LFB12:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	ALLOC_BM, %eax
	andl	8(%ebp), %eax
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE12:
	.size	parseAlloc, .-parseAlloc
	.type	parseMark, @function
parseMark:
.LFB13:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	MARK_BM, %eax
	andl	8(%ebp), %eax
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE13:
	.size	parseMark, .-parseMark
	.section	.rodata
.LC27:
	.string	"error: %s\n"
	.text
	.type	error, @function
error:
.LFB14:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	$.LC27, %edx
	movl	stderr, %eax
	movl	8(%ebp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	movl	$0, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE14:
	.size	error, .-error
	.ident	"GCC: (GNU) 4.6.3 20120306 (Red Hat 4.6.3-2)"
	.section	.note.GNU-stack,"",@progbits
