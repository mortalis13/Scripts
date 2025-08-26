section .data
    buf: db "Wow", 10
section .bss

section .text
global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 4
    syscall
    
    mov rax, 3ch
    mov rdi, 0
    syscall
