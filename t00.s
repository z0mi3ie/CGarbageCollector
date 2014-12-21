	.file	"t00.c"
	.comm	globalPtr,4,4
	.section	.rodata
	.align 4
.LC0:
	.string	"calling memInitialize(100), which returns %d\n"
.LC1:
	.string	"FAILURE\n"
	.align 4
.LC2:
	.string	"calling memAllocate(15, 0), which returns %p\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-16, %esp
	subl	$64, %esp
	movl	$100, (%esp)
	call	memInitialize
	movl	%eax, 56(%esp)
	movl	$.LC0, %edx
	movl	stderr, %eax
	movl	56(%esp), %ecx
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	cmpl	$1, 56(%esp)
	je	.L2
	movl	stderr, %eax
	movl	%eax, %edx
	movl	$.LC1, %eax
	movl	%edx, 12(%esp)
	movl	$8, 8(%esp)
	movl	$1, 4(%esp)
	movl	%eax, (%esp)
	call	fwrite
	jmp	.L3
.L2:
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	globalPtr, %ecx
	movl	$.LC2, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	movl	$0, 60(%esp)
	jmp	.L4
.L5:
	movl	$0, 4(%esp)
	movl	$15, (%esp)
	call	memAllocate
	movl	60(%esp), %edx
	movl	%eax, 16(%esp,%edx,4)
	movl	60(%esp), %eax
	movl	16(%esp,%eax,4), %ecx
	movl	$.LC2, %edx
	movl	stderr, %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	fprintf
	addl	$1, 60(%esp)
.L4:
	cmpl	$2, 60(%esp)
	jle	.L5
	movl	16(%esp), %eax
	movl	16(%esp), %edx
	movl	%edx, (%eax)
	call	memDump
.L3:
	movl	$0, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.6.3 20120306 (Red Hat 4.6.3-2)"
	.section	.note.GNU-stack,"",@progbits
