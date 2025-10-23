# Phase 1.2 Complete: Basic Bootloader

## What We Built

A simple 512-byte bootloader that:
- ✅ Loads at address 0x7C00 (where BIOS puts it)
- ✅ Clears the screen
- ✅ Prints welcome messages
- ✅ Runs in 16-bit real mode
- ✅ Has proper boot signature (0xAA55)

## Files Created

- **boot/boot.asm** - Bootloader source code (assembly)
- **Makefile** - Build automation
- **build/boot.bin** - Compiled 512-byte bootloader
- **build/os-image.bin** - Bootable OS image

## How to Build and Run

```bash
# Build the OS
make

# Run in QEMU
make run

# Clean build files
make clean

# Show bootloader info
make info
```

## What You Should See

When you run `make run`, QEMU opens and displays:

```
Welcome to MitOS!

MitOS v0.1 - Bootloader
Status: Bootloader loaded successfully!

This is a 16-bit real mode bootloader.
Kernel loading will be implemented next...
```

## Understanding the Code

### Memory Layout
- **0x7C00**: Where BIOS loads our bootloader
- **Stack**: Grows downward from 0x7C00
- **Code**: Starts at 0x7C00

### Key Functions

1. **clear_screen**: Uses BIOS int 0x10 to clear screen
2. **print_string**: Prints null-terminated strings using BIOS int 0x10

### Boot Signature
The last 2 bytes MUST be `0x55 0xAA` or BIOS won't boot it!

## Next Steps (Phase 1.3)

- [ ] Load kernel from disk
- [ ] Setup GDT (Global Descriptor Table)
- [ ] Switch to 32-bit protected mode
- [ ] Jump to kernel code

## Troubleshooting

**QEMU doesn't start:**
- Make sure QEMU is installed: `qemu-system-i386 --version`
- Check build succeeded: `ls -la build/`

**Black screen in QEMU:**
- Check boot signature: `make info` (should show "55 AA" at end)
- Verify bootloader is exactly 512 bytes: `ls -la build/boot.bin`

**Nothing prints:**
- BIOS interrupts (int 0x10) might not work in some emulators
- Try running on different emulator or real hardware

## Congratulations! 🎉

You've successfully created a bootloader that runs on bare metal (well, in an emulator)!

This is a huge milestone - you've written code that runs WITHOUT an operating system underneath it!
