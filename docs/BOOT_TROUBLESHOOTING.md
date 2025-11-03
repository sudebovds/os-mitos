# Boot Troubleshooting Guide

## Problem Summary

When running `make run`, QEMU displayed only a black screen with a blinking cursor and no output from the bootloader or kernel.

---

## Root Causes Identified

### 1. **Incorrect Code Section Ordering** ⚠️

**Problem:**
The `print_string` function was defined AFTER the `[bits 32]` directive in the bootloader, causing it to be assembled as 32-bit code even though it was being called from 16-bit real mode.

**Location:** `boot/boot.asm`

**Why it failed:**
- The bootloader starts in 16-bit real mode (`[bits 16]`)
- The `print_string` function was placed after the protected mode section
- When assembled, it was encoded as 32-bit instructions
- Calling it from 16-bit mode resulted in completely wrong instruction execution
- The CPU executed garbage instructions, likely causing a hang before any output

**Fix:**
Moved the `print_string` function to appear BEFORE the `switch_to_pm` function and protected mode code:

```asm
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
    ; ... rest of protected mode code
```

---

### 2. **ELF Format Instead of Flat Binary** ⚠️⚠️

**Problem:**
The kernel was being linked as an ELF executable, not a flat binary. When the bootloader jumped to `KERNEL_OFFSET` (0x1000), it was jumping to ELF headers, not actual executable code.

**Location:** `Makefile`

**Why it failed:**
- The linker (`i686-elf-ld`) produces ELF format by default
- ELF files have headers, section tables, and metadata before the actual code
- The bootloader expected raw machine code at 0x1000
- Jumping to ELF headers caused invalid instruction execution
- This resulted in a triple fault and system reboot loop

**Fix:**
Modified the Makefile to convert the ELF binary to a flat binary using `objcopy`:

```makefile
# Link microkernel
$(MICROKERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(MICROKERNEL_OBJ)
	@echo "[LD]  Linking microkernel..."
	$(LD) $(KERNEL_LDFLAGS) -o $(BUILD_DIR)/microkernel.elf $^
	@echo "[OBJCOPY] Converting to flat binary..."
	objcopy -O binary $(BUILD_DIR)/microkernel.elf $@
```

**What this does:**
- First links to `microkernel.elf` (ELF format with debug symbols)
- Then converts to `microkernel.bin` (flat binary, raw machine code)
- The bootloader can now jump directly to executable code

---

### 3. **Incorrect Sector Count** ⚠️

**Problem:**
The bootloader was trying to read 15 sectors from disk, but the kernel was only ~2.7KB (~6 sectors). The BIOS disk read failed because those sectors didn't exist.

**Location:** `boot/boot.asm` - `load_kernel` function

**Why it failed:**
- Kernel size: 2788 bytes = ~5.45 sectors
- Bootloader requested: 15 sectors
- BIOS `int 0x13` failed because sectors 7-15 don't exist in the image
- Error handler displayed "Disk read error!" and halted

**Original code:**
```asm
mov dh, 15              ; Load 15 sectors
```

**Fix:**
```asm
mov dh, 6               ; Load 6 sectors (enough for ~3KB kernel)
```

**Calculation:**
- Kernel size: 2788 bytes
- Sector size: 512 bytes
- Sectors needed: ⌈2788 ÷ 512⌉ = 6 sectors
- We load 6 sectors to have a small buffer for kernel growth

---

## Symptoms Timeline

| Stage | Symptom | Cause |
|-------|---------|-------|
| **Initial** | Black screen, blinking cursor, no output | `print_string` assembled as 32-bit code |
| **After fix #1** | Infinite reboot loop, saw bootloader messages | Kernel in ELF format, not flat binary |
| **After fix #2** | "Disk read error!" message | Trying to read too many sectors |
| **After fix #3** | ✅ **Success!** Kernel boots and displays output | All issues resolved |

---

## Debugging Techniques Used

### 1. **Minimal Test Bootloader**
Created a simple test bootloader (`boot_test.asm`) that only prints "ABCOK":
- Confirmed QEMU video output was working
- Isolated the problem to the main bootloader code
- Eliminated hardware/emulator issues

### 2. **Boot Signature Verification**
Checked the last 2 bytes of the bootloader (offset 0x1FE-0x1FF):
```powershell
$bytes = [System.IO.File]::ReadAllBytes("build\mitos.img")
"Boot signature: 0x{0:X2} 0x{1:X2}" -f $bytes[510], $bytes[511]
# Output: 0x55 0xAA ✅
```

### 3. **Progressive Debug Output**
Added debug markers in the bootloader:
```asm
mov ah, 0x0E
mov al, '!'
int 0x10
```
This helped track execution flow and identify where code was failing.

### 4. **Sector Calculation**
Calculated exact kernel size and sectors needed:
```
Kernel size: 2788 bytes
Sectors: ⌈2788 ÷ 512⌉ = 6 sectors
```

---

## Key Lessons Learned

### 1. **Assembly Directive Ordering Matters**
In x86 assembly, the position of `[bits 16]` and `[bits 32]` directives determines how subsequent code is assembled. Functions must be in the correct section.

### 2. **Binary Format is Critical for Bootloaders**
Bootloaders expect **flat binaries** (raw machine code), not structured formats like ELF. Always use `objcopy -O binary` when creating kernels loaded by custom bootloaders.

### 3. **BIOS Disk Reads Must Match Actual Size**
Always calculate the exact number of sectors needed:
```
sectors_needed = ⌈file_size_bytes ÷ 512⌉
```

### 4. **Debugging OS Code Requires Creative Approaches**
- Use minimal test cases to isolate problems
- Add visual debug output (characters, patterns)
- Verify binary structure and signatures
- Test each component independently

---

## Prevention Checklist

For future bootloader/kernel development:

- [ ] Verify all 16-bit functions are before `[bits 32]` directive
- [ ] Always convert kernel ELF to flat binary with `objcopy`
- [ ] Calculate exact sector count based on actual file size
- [ ] Test bootloader with minimal kernel first
- [ ] Verify boot signature (0x55 0xAA) is present
- [ ] Add debug output at key stages (bootloader, kernel entry, kernel main)
- [ ] Use `-nographic` or `-serial stdio` to capture early boot messages
- [ ] Check linker scripts match expected load addresses

---

## Additional Resources

### Useful QEMU Debugging Commands

```bash
# Run with serial output
qemu-system-i386 -drive format=raw,file=build/mitos.img -serial stdio

# Run with GDB debugging
qemu-system-i386 -s -S -drive format=raw,file=build/mitos.img
# In another terminal:
gdb -ex 'target remote :1234' build/microkernel.elf

# Dump boot sector
xxd -l 512 build/mitos.img

# Check file sizes
ls -lh build/
```

### Common Boot Errors

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| Black screen, no cursor | Boot signature missing | Add `dw 0xAA55` at end |
| Blinking cursor only | Code not executing | Check `[org 0x7c00]` directive |
| "Disk read error" | Wrong sector count or CHS values | Verify sector calculation |
| Infinite reboot | Triple fault (invalid instruction) | Check binary format, memory access |
| Garbage characters | Wrong bit mode for function | Verify `[bits 16/32]` placement |

---

## Final Working Configuration

**Bootloader:** 512 bytes (1 sector)
**Kernel:** ~2.7 KB (6 sectors loaded)
**Total Image:** 3300 bytes

**Boot Process:**
1. BIOS loads bootloader at 0x7C00 ✅
2. Bootloader prints startup messages ✅
3. Bootloader reads 6 sectors from disk to 0x1000 ✅
4. Bootloader switches to protected mode ✅
5. Bootloader jumps to kernel at 0x1000 ✅
6. Kernel initializes VGA and prints status ✅
7. Kernel enters idle loop (HLT) ✅

---

**Document Version:** 1.0  
**Date:** November 3, 2025  
**Status:** Resolved ✅
