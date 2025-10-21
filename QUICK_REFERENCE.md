# Quick Reference Card

Essential commands and information for OS development.

---

## Setup Status

Run this to check what's installed:
```powershell
.\tools\verify.ps1
```

---

## MSYS2 Terminal Commands

```bash
# Update MSYS2
pacman -Syu

# Install tools
pacman -S base-devel make nasm mingw-w64-x86_64-gcc mingw-w64-x86_64-qemu gdb

# Navigate to project (from MSYS2)
cd /c/Work/OperationSystem

# Run setup script
bash tools/setup.sh
```

---

## Build Commands (Once Setup Complete)

```bash
# Build OS
make

# Run in QEMU
make run

# Clean build files
make clean

# Build in debug mode
make debug

# Run with GDB debugging
make debug-gdb
```

---

## QEMU Commands

```bash
# Run OS image
qemu-system-i386 -drive format=raw,file=os-image.bin

# Run with serial output
qemu-system-i386 -drive format=raw,file=os-image.bin -serial stdio

# Run with debugging
qemu-system-i386 -s -S -drive format=raw,file=os-image.bin
# Then in another terminal:
gdb
(gdb) target remote localhost:1234
(gdb) continue
```

---

## Useful GDB Commands

```gdb
# Connect to QEMU
target remote localhost:1234

# Set breakpoint
break kernel_main
break *0x1000

# Show registers
info registers

# Examine memory (hex)
x/10x 0x7c00

# Examine memory (instructions)
x/10i 0x7c00

# Step instruction
si

# Continue execution
continue

# Show backtrace
backtrace
```

---

## x86 Assembly Quick Reference

### Registers
```asm
; General purpose (32-bit)
eax, ebx, ecx, edx    ; Accumulator, Base, Counter, Data
esi, edi              ; Source Index, Destination Index
esp, ebp              ; Stack Pointer, Base Pointer
eip                   ; Instruction Pointer

; 16-bit versions
ax, bx, cx, dx

; 8-bit versions
al, ah, bl, bh, cl, ch, dl, dh

; Segment registers
cs, ds, es, fs, gs, ss
```

### Common Instructions
```asm
mov dest, src         ; Move data
add dest, src         ; Add
sub dest, src         ; Subtract
inc dest              ; Increment
dec dest              ; Decrement
push src              ; Push to stack
pop dest              ; Pop from stack
call addr             ; Call function
ret                   ; Return from function
jmp addr              ; Jump
cmp op1, op2          ; Compare
je addr               ; Jump if equal
jne addr              ; Jump if not equal
int num               ; Software interrupt
hlt                   ; Halt CPU
```

---

## Memory Map Reference

```
0x00000000  BIOS/Real mode IVT
0x00000500  BIOS data area
0x00007C00  Bootloader loaded here (512 bytes)
0x00007E00  Bootloader stack/free
0x00010000  Kernel loaded here (64KB+)
0x000A0000  VGA memory start
0x000B8000  VGA text mode (80x25)
0x000C0000  BIOS ROM
0x00100000  Extended memory (1MB+)
0xC0000000  Kernel space (typical)
0xFFFFFFFF  End of 32-bit address space
```

---

## VGA Text Mode

**Memory**: 0xB8000  
**Format**: Character + Attribute  
**Size**: 80 columns × 25 rows = 2000 characters = 4000 bytes

### Color Codes
```
Black       = 0x0    Dark Gray  = 0x8
Blue        = 0x1    Light Blue = 0x9
Green       = 0x2    Light Green= 0xA
Cyan        = 0x3    Light Cyan = 0xB
Red         = 0x4    Light Red  = 0xC
Magenta     = 0x5    Light Mag. = 0xD
Brown       = 0x6    Yellow     = 0xE
Light Gray  = 0x7    White      = 0xF
```

### Attribute Byte
```
Bit 7    6 5 4    3 2 1 0
    |    |---     |---
    |      |        └─ Foreground color
    |      └────────── Background color
    └─────────────── Blink (if enabled)
```

Example: White on blue = 0x1F (background 1, foreground F)

---

## Important Port Addresses

```
0x20, 0x21   PIC1 (Master) command/data
0xA0, 0xA1   PIC2 (Slave) command/data
0x40-0x43    PIT (Timer)
0x60, 0x64   Keyboard
0x70, 0x71   CMOS/RTC
0x3D4, 0x3D5 VGA cursor control
0x1F0-0x1F7  Primary ATA bus
0x170-0x177  Secondary ATA bus
```

---

## BIOS Interrupts (Real Mode)

```asm
; Video
int 0x10
; AH=0x00: Set video mode
; AH=0x0E: Teletype output (print character in AL)

; Disk
int 0x13
; AH=0x00: Reset disk
; AH=0x02: Read sectors
; AH=0x42: Extended read (LBA)

; Keyboard
int 0x16
; AH=0x00: Wait for keystroke
; AH=0x01: Check for keystroke
```

---

## Bootloader Checklist

```asm
; Essential bootloader structure
[org 0x7c00]              ; Origin at boot location
[bits 16]                 ; 16-bit real mode

start:
    cli                   ; Disable interrupts
    xor ax, ax
    mov ds, ax            ; Set data segment to 0
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00        ; Set stack

    ; Your code here
    ; - Load kernel from disk
    ; - Setup GDT
    ; - Switch to protected mode
    ; - Jump to kernel

times 510-($-$$) db 0     ; Pad to 510 bytes
dw 0xAA55                 ; Boot signature
```

---

## GDT Entry Structure

```
Bits 0-15:    Limit (low)
Bits 16-31:   Base (low)
Bits 32-39:   Base (middle)
Bits 40-47:   Access byte
Bits 48-51:   Limit (high)
Bits 52-55:   Flags
Bits 56-63:   Base (high)
```

---

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| Roadmap | `ROADMAP.md` | Development plan |
| Getting Started | `GETTING_STARTED.md` | Setup instructions |
| Setup Guide | `docs/SETUP_GUIDE.md` | Detailed setup |
| Checklist | `docs/SETUP_CHECKLIST.md` | Track progress |
| Architecture | `docs/ARCHITECTURE.md` | System design |
| Glossary | `docs/GLOSSARY.md` | Terminology |
| Verify Script | `tools/verify.ps1` | Check installation |

---

## Next Steps Flowchart

```
1. Setup Environment
   ├─ Install MSYS2
   ├─ Install tools (NASM, GCC, QEMU)
   └─ Verify with verify.ps1
   
2. Write Bootloader
   ├─ boot.asm (512 bytes)
   ├─ Load kernel from disk
   └─ Switch to protected mode
   
3. Basic Kernel
   ├─ kernel_entry.asm
   ├─ kernel.c
   └─ Print to screen
   
4. Build System
   ├─ Makefile
   └─ linker.ld
   
5. Test in QEMU
   └─ See "Hello, World!"
```

---

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| "Command not found" | Add to PATH, restart VS Code |
| Triple fault in QEMU | Check GDT setup, check stack |
| Black screen | Check boot signature (0x55AA) |
| Bootloader too big | Must be ≤510 bytes |
| Can't find kernel | Check disk reading code |

---

## Useful Resources

- **OSDev Wiki**: https://wiki.osdev.org/
- **Intel Manuals**: https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html
- **NASM Docs**: https://nasm.us/doc/
- **GCC Docs**: https://gcc.gnu.org/onlinedocs/
- **QEMU Docs**: https://qemu.org/docs/master/

---

## Print This Card!

Keep this reference handy while coding. Most common commands and values are here.

**Current Phase**: Setup  
**Next Phase**: Bootloader  
**Goal**: Boot and print "Hello, World!"
