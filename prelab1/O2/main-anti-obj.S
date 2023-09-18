
main.o：     文件格式 elf64-x86-64


Disassembly of section .text.startup:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   %rbp
   5:	48 8d 2d 00 00 00 00 	lea    0x0(%rip),%rbp        # c <main+0xc>
   c:	48 89 ef             	mov    %rbp,%rdi
   f:	48 83 ec 10          	sub    $0x10,%rsp
  13:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  1a:	00 00 
  1c:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  21:	31 c0                	xor    %eax,%eax
  23:	48 8d 74 24 04       	lea    0x4(%rsp),%rsi
  28:	e8 00 00 00 00       	call   2d <main+0x2d>
  2d:	8b 54 24 04          	mov    0x4(%rsp),%edx
  31:	83 fa 01             	cmp    $0x1,%edx
  34:	7e 3e                	jle    74 <main+0x74>
  36:	83 c2 01             	add    $0x1,%edx
  39:	be 01 00 00 00       	mov    $0x1,%esi
  3e:	b8 02 00 00 00       	mov    $0x2,%eax
  43:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  48:	0f af f0             	imul   %eax,%esi
  4b:	83 c0 01             	add    $0x1,%eax
  4e:	39 c2                	cmp    %eax,%edx
  50:	75 f6                	jne    48 <main+0x48>
  52:	31 c0                	xor    %eax,%eax
  54:	48 89 ef             	mov    %rbp,%rdi
  57:	e8 00 00 00 00       	call   5c <main+0x5c>
  5c:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  61:	64 48 2b 04 25 28 00 	sub    %fs:0x28,%rax
  68:	00 00 
  6a:	75 0f                	jne    7b <main+0x7b>
  6c:	48 83 c4 10          	add    $0x10,%rsp
  70:	31 c0                	xor    %eax,%eax
  72:	5d                   	pop    %rbp
  73:	c3                   	ret    
  74:	be 01 00 00 00       	mov    $0x1,%esi
  79:	eb d7                	jmp    52 <main+0x52>
  7b:	e8 00 00 00 00       	call   80 <main+0x80>
