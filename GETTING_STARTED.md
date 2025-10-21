# Getting Started - Step by Step Instructions

Welcome to MitOS development! Follow these steps to get your development environment ready.

## Current Status: Tools Need Installation

The verification script shows that the following tools are missing:
- ❌ NASM (assembler)
- ❌ i686-elf-gcc (cross-compiler)
- ❌ i686-elf-ld (linker)
- ❌ QEMU (emulator)
- ❌ Make (build tool)

## Quick Start Guide

### Option 1: Automated Setup (Recommended for Beginners)

This is the easiest way - let the script do most of the work.

1. **Download and Install MSYS2**:
   - Go to: https://www.msys2.org/
   - Download: `msys2-x86_64-XXXXXXXX.exe`
   - Run installer → Install to `C:\msys64`
   - ✅ At the end, check "Run MSYS2 now"

2. **Open MSYS2 MSYS Terminal** (important - not MinGW!):
   - Look for "MSYS2 MSYS" in Start Menu
   - You should see a purple terminal icon

3. **Navigate to Your Project**:
   ```bash
   cd /c/Work/OperationSystem
   ```

4. **Run the Setup Script**:
   ```bash
   bash tools/setup.sh
   ```
   
   This will:
   - Update MSYS2
   - Install all required tools (NASM, Make, QEMU, etc.)
   - Optionally build the GCC cross-compiler (takes 30-60 min)

5. **Add Tools to Windows PATH**:
   - Press `Win + X` → System → Advanced System Settings
   - Click "Environment Variables"
   - Under "User variables", select "Path" and click "Edit"
   - Click "New" and add these paths:
     ```
     C:\msys64\usr\bin
     C:\msys64\mingw64\bin
     C:\msys64\home\[YourUsername]\opt\cross\bin
     ```
     (Replace `[YourUsername]` with your actual Windows username)
   - Click OK on all dialogs

6. **Restart VS Code** completely (close all windows)

7. **Verify Installation**:
   In a NEW PowerShell terminal in VS Code:
   ```powershell
   .\tools\verify.ps1
   ```
   You should see all ✓ green checkmarks!

---

### Option 2: Manual Setup (More Control)

Follow the detailed instructions in `docs/SETUP_GUIDE.md` step by step.

Use `docs/SETUP_CHECKLIST.md` to track your progress.

---

### Option 3: Pre-built Cross-Compiler (Fastest)

If building the cross-compiler is taking too long or failing:

1. **Install MSYS2** (steps 1-2 from Option 1)

2. **Install Basic Tools in MSYS2**:
   ```bash
   pacman -Syu
   pacman -S base-devel make nasm mingw-w64-x86_64-qemu
   ```

3. **Download Pre-built Cross-Compiler**:
   - Go to: https://github.com/lordmilko/i686-elf-tools/releases
   - Download: `i686-elf-tools-windows.zip`
   - Extract to: `C:\cross-compiler\`

4. **Add to PATH**:
   Add these paths (Win + X → System → Environment Variables):
   ```
   C:\msys64\usr\bin
   C:\msys64\mingw64\bin
   C:\cross-compiler\bin
   ```

5. **Verify**:
   ```powershell
   .\tools\verify.ps1
   ```

---

## What Each Tool Does

| Tool | Purpose | Example |
|------|---------|---------|
| **NASM** | Assembles x86 assembly code | `boot.asm` → `boot.bin` |
| **i686-elf-gcc** | Compiles C/C++ for your OS | `kernel.c` → `kernel.o` |
| **i686-elf-ld** | Links object files together | `*.o` → `kernel.bin` |
| **QEMU** | Emulates x86 computer | Test your OS without rebooting |
| **Make** | Automates the build process | Run `make` to build everything |

---

## Troubleshooting

### "Command not found" after adding to PATH
- **Solution**: Make sure you restarted VS Code COMPLETELY
- Try: Close all VS Code windows and reopen

### MSYS2 terminal says "bash: cd: /c/Work/OperationSystem: No such file or directory"
- **Reason**: You might be in the wrong directory
- **Solution**: Type `pwd` to see current directory
- Use: `cd /c/Work/OperationSystem` (forward slashes!)

### Cross-compiler build fails
- **Solution 1**: Use pre-built binaries (Option 3 above)
- **Solution 2**: Make sure you have at least 10GB free disk space
- **Solution 3**: Run MSYS2 as Administrator

### QEMU won't start
- **Check**: Is virtualization enabled in BIOS?
- **Check**: Is antivirus blocking it?
- **Try**: Run from MSYS2 first: `qemu-system-i386 --version`

### verify.ps1 shows weird characters
- **Reason**: PowerShell encoding issues with checkmarks
- **Solution**: Ignore the display issue - focus on "✓" vs "✗" results

---

## Time Estimates

| Method | Active Time | Waiting Time | Total |
|--------|-------------|--------------|-------|
| Option 1 (Full build) | 30 min | 30-60 min | 1-1.5 hours |
| Option 2 (Manual) | 45 min | 30-60 min | 1.5-2 hours |
| Option 3 (Pre-built) | 20 min | 5 min | 25 min |

**Recommendation**: If you're eager to start coding, use **Option 3**. You can always rebuild the cross-compiler later.

---

## After Setup is Complete

Once `verify.ps1` shows all tools installed:

1. ✅ Mark Phase 1.1 as complete
2. 📖 Read about bootloaders in `ROADMAP.md`
3. 🚀 Start Phase 1.2: Writing your first bootloader!

---

## Need Help?

If you get stuck:

1. Check `docs/SETUP_GUIDE.md` for detailed explanations
2. Check `docs/SETUP_CHECKLIST.md` to see what step failed
3. Look at the troubleshooting section above
4. Search for the error on OSDev.org forums

---

## Your Next Command

Choose your preferred option above, then run the appropriate commands to get started!

**Quick start (recommended)**:
1. Install MSYS2 from https://www.msys2.org/
2. Open MSYS2 MSYS terminal
3. Run: `cd /c/Work/OperationSystem && bash tools/setup.sh`

Good luck! 🚀
