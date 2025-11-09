section .data
    LEN equ 10
    buf db LEN dup(0)
    endl db 10
section .text
global _start


ParseNumber:
; Writes char form of a number from a register to memory
; RAX - input
; RDX - output, start addr in memory of the parsed number
; RCX - output, number of chars in the parsed number

    mov rcx, LEN-1
    
    ; If input < 10, nothing to parse
    cmp rax, 10
    jl _end
    
_parse:
    ; divide rax by 10 to get the next digit in rdx
    ; and write the char to mem (digit + '0')
    xor rdx, rdx
    mov rbx, 10
    div rbx
    
    mov [buf+rcx], dl
    add byte [buf+rcx], 30h
    dec rcx                  ; mem pointer
    
    ; if the main part < 10, write the last digit to mem and finish
    cmp rax, 10
    jge _parse

_end:
    mov [buf+rcx], al
    add byte [buf+rcx], 30h
    
    ; move to the start of number string in mem
    mov rdx, buf
    add rdx, rcx
    
    mov rax, LEN
    sub rax, rcx
    mov rcx, rax
ret


_start:
    mov rax, 12345
    call ParseNumber
    
    mov rax, 1
    mov rdi, 1
    mov rsi, rdx
    mov rdx, rcx
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, endl
    mov rdx, 1
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall
