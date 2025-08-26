; Converts lowercase to uppercase taking input from stdin, writing to stdout
; Reads buffered input, subtracts 0x20 from letters a-z on the buffer, leaving other chars as is, writes the converted buffer to stdout
; rax=0 -> sys_read, reads to rsi, rdx bytes, leaves number of read bytes in rax
; rax=1 -> sys_write, writes rdx bytes to buffer in rsi
; ./toupper < input.txt > output.txt

section .data
section .bss
    buf resb 128

section .text
global _start

_start:

_read:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 128
    syscall
    
    cmp rax, 0
    je _end
    
    mov r8, rax
    mov r9, 0
_convert:
    cmp byte [buf+r9], 'a'
    jl _skip
    cmp byte [buf+r9], 'z'
    jg _skip
    
    sub byte [buf+r9], 20h
    
_skip:
    inc r9
    cmp r9, r8
    jne _convert

    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, r8
    syscall
    
    jmp _read

_end:
    mov rax, 3ch
    mov rdi, 0
    syscall
