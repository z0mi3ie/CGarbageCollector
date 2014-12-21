.text
.align 4
.globl getEbp #Frame pointer
.globl getEsp #Stack pointer 
.globl getEbx
.globl getEsi
.globl getEdi
getEbp:
  movl %ebp, %eax
  ret
getEsp:
  movl %esp, %eax
  ret
getEbx:
  movl %ebx, %eax
  ret
getEsi:
  movl %esi, %eax
  ret
getEdi:
  movl %edi, %eax
  ret 
