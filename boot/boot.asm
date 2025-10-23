; MitOS Bootloader
; Simple bootloader that prints a message and hangs
; This is the first code that runs when the computer starts

[org 0x7c00]              ; BIOS loads bootloader at address 0x7C00
[bits 16]                 ; We start in 16-bit real mode

start:
    ; Set up segments
    xor ax, ax            ; Zero out AX register
    mov ds, ax            ; Set Data Segment to 0
    mov es, ax            ; Set Extra Segment to 0
    mov ss, ax            ; Set Stack Segment to 0
    mov sp, 0x7c00        ; Set Stack Pointer (grows downward from bootloader)

    ; Clear screen
    call clear_screen

    ; Print welcome message
    mov si, msg_welcome   ; SI = pointer to message
    call print_string

    ; Print OS name
    mov si, msg_os_name
    call print_string

    ; Print status
    mov si, msg_status
    call print_string

    ; Hang (infinite loop)
    jmp $

;-------------------------------------------------------------------------------
; Function: clear_screen
; Clears the screen using BIOS interrupt
;-------------------------------------------------------------------------------
clear_screen:
    pusha                 ; Save all registers
    mov ah, 0x00          ; Set video mode
    mov al, 0x03          ; 80x25 text mode
    int 0x10              ; BIOS video services
    popa                  ; Restore all registers
    ret

;-------------------------------------------------------------------------------
; Function: print_string
; Prints a null-terminated string to screen
; Input: SI = pointer to string
;-------------------------------------------------------------------------------
print_string:
    pusha                 ; Save all registers
    mov ah, 0x0e          ; BIOS teletype output

.print_char:
    lodsb                 ; Load byte from SI into AL, increment SI
    cmp al, 0             ; Check if null terminator
    je .done              ; If zero, we're done
    int 0x10              ; Print character in AL
    jmp .print_char       ; Print next character

.done:
    popa                  ; Restore all registers
    ret

;-------------------------------------------------------------------------------
; Data section
;-------------------------------------------------------------------------------
msg_welcome:    db 'Welcome to MitOS!', 0x0D, 0x0A, 0x0D, 0x0A, 0
msg_os_name:    db 'MitOS v0.1 - Bootloader', 0x0D, 0x0A, 0
msg_status:     db 'Status: Bootloader loaded successfully!', 0x0D, 0x0A, 0x0D, 0x0A
                db 'This is a 16-bit real mode bootloader.', 0x0D, 0x0A
                db 'Kernel loading will be implemented next...', 0x0D, 0x0A, 0

;-------------------------------------------------------------------------------
; Boot sector padding and signature
;-------------------------------------------------------------------------------
times 510-($-$$) db 0     ; Pad with zeros to byte 510
dw 0xAA55                 ; Boot signature (must be at bytes 511-512)
