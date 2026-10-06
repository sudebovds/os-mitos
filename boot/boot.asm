; MitOS Microkernel Bootloader
; Loads microkernel from disk and switches to protected mode

[org 0x7c00]
[bits 16]

; Constants
KERNEL_OFFSET equ 0x1000

start:
    ; Set up segments
    cli                 ; Disable interrupts during setup
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti                 ; Re-enable interrupts
    
    ; Save boot drive
    mov [BOOT_DRIVE], dl
    
    ; Clear screen first
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Print loading message
    mov si, MSG_LOADING
    call print_string
    
    ; Debug: Print a test character to verify print works
    mov ah, 0x0E
    mov al, '!'
    int 0x10
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    
    ; Load kernel from disk
    call load_kernel
    
    ; Print message before switching to protected mode
    mov si, MSG_SWITCHING_PM
    call print_string
    
    ; Switch to protected mode
    call switch_to_pm
    
    ; Never reached
    jmp $

;-------------------------------------------------------------------------------
; Load kernel from disk
;-------------------------------------------------------------------------------
load_kernel:
    pusha
    
    mov si, MSG_LOAD_KERNEL
    call print_string
    
    ; Setup disk read
    mov bx, KERNEL_OFFSET   ; Load to 0x1000
    mov dh, 6               ; Load 6 sectors (enough for ~3KB kernel)
    mov dl, [BOOT_DRIVE]
    call disk_load
    
    mov si, MSG_KERNEL_LOADED
    call print_string
    
    popa
    ret

;-------------------------------------------------------------------------------
; Disk load function
;-------------------------------------------------------------------------------
disk_load:
    pusha
    push dx         ; Save dx (contains sector count in dh and drive in dl)
    
    mov ah, 0x02    ; BIOS read function
    mov al, dh      ; Number of sectors to read (from dh)
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x02    ; Start from sector 2 (sector 1 is bootloader)
    mov dh, 0x00    ; Head 0
    ; dl already contains boot drive
    
    int 0x13        ; BIOS disk interrupt
    
    jc disk_error   ; If carry flag set, disk error occurred
    
    pop dx          ; Restore dx
    cmp al, dh      ; Compare sectors actually read (al) with requested (dh)
    jne sectors_error
    
    popa
    ret

disk_error:
    mov si, MSG_DISK_ERROR
    call print_string
    jmp $

sectors_error:
    mov si, MSG_SECTORS_ERROR
    call print_string
    jmp $

;-------------------------------------------------------------------------------
; 16-bit functions (MUST be before protected mode switch!)
;-------------------------------------------------------------------------------
print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

;-------------------------------------------------------------------------------
; Switch to protected mode
;-------------------------------------------------------------------------------
switch_to_pm:
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm

;-------------------------------------------------------------------------------
; 32-bit protected mode
;-------------------------------------------------------------------------------
[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    call KERNEL_OFFSET
    
    ; If kernel returns, halt
    cli
    hlt
    jmp $

;-------------------------------------------------------------------------------
; GDT
;-------------------------------------------------------------------------------
gdt_start:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;-------------------------------------------------------------------------------
; Data
;-------------------------------------------------------------------------------
BOOT_DRIVE: db 0
MSG_LOADING: db 'MitOS Microkernel Bootloader v0.1', 0x0D, 0x0A, 0
MSG_LOAD_KERNEL: db 'Loading microkernel...', 0x0D, 0x0A, 0
MSG_KERNEL_LOADED: db 'Microkernel loaded successfully!', 0x0D, 0x0A, 0
MSG_SWITCHING_PM: db 'Switching to protected mode...', 0x0D, 0x0A, 0
MSG_DISK_ERROR: db 'Disk read error!', 0x0D, 0x0A, 0
MSG_SECTORS_ERROR: db 'Sectors error!', 0x0D, 0x0A, 0

;-------------------------------------------------------------------------------
; Boot signature
;-------------------------------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55