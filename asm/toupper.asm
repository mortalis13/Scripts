; Converts lowercase to uppercase taking input from stdin, writing to stdout
; Reads input byte by byte, subtracts 0x20 from letters a-z, leaving other chars as is
; ./toupper < input.txt > output.txt

section .data
section .bss
    buf resb 1

section .text
global _start

_start:

_read:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 1
    syscall
    
    cmp rax, 0
    je _end
    
    cmp byte [buf], 'a'
    jl _skip
    cmp byte [buf], 'z'
    jg _skip
    
    sub byte [buf], 20h

_skip:
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 1
    syscall
    jmp _read

_end:
    mov rax, 3ch
    mov rdi, 0
    syscall
