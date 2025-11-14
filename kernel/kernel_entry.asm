; MitOS Microkernel Entry Point
; Sets up stack and calls C kernel

[bits 32]
[extern kernel_main]

section .text
global _start

_start:
    ; Set up stack
    mov esp, 0x90000
    
    ; Clear registers
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    
    ; Call C kernel
    call kernel_main
    
    ; Hang if kernel returns
    jmp $