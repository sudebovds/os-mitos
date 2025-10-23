# Development Environment Setup Checklist

Use this checklist to track your progress setting up the development environment.

---

## Step 1: Install MSYS2

- [x] Downloaded MSYS2 from https://www.msys2.org/
- [x] Installed to `C:\msys64`
- [x] Ran initial update: `pacman -Syu`
- [x] Ran second update: `pacman -Su`

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Step 2: Install Basic Tools in MSYS2

Open MSYS2 MSYS terminal and run these commands:

- [x] `pacman -S base-devel`
- [x] `pacman -S mingw-w64-x86_64-gcc`
- [x] `pacman -S make`
- [x] `pacman -S nasm`
- [x] `pacman -S wget tar`
- [x] `pacman -S gdb`

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Step 3: Build GCC Cross-Compiler

This is the most time-consuming step (30-60 minutes total).

### Preparation
- [x] Installed cross-compiler dependencies
- [x] Created build directory: `~/cross-compiler`
- [x] Downloaded binutils source
- [x] Downloaded GCC source
- [x] Extracted source files

### Build Binutils
- [x] Configured binutils for i686-elf target
- [x] Compiled binutils (`make`)
- [x] Installed binutils (`make install`)
- [x] Verified: `~/opt/cross/bin/i686-elf-as --version` works

### Build GCC
- [x] Configured GCC for i686-elf target
- [x] Compiled GCC (`make all-gcc` and `make all-target-libgcc`)
- [x] Installed GCC (`make install-gcc` and `make install-target-libgcc`)
- [x] Verified: `~/opt/cross/bin/i686-elf-gcc --version` works

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

**Note**: If this step is too complex, you can use pre-built binaries from:
https://github.com/lordmilko/i686-elf-tools/releases

---

## Step 4: Install QEMU

Choose ONE option:

### Option A: Using MSYS2 (Recommended)
- [x] Ran: `pacman -S mingw-w64-x86_64-qemu`
- [x] Verified: `qemu-system-i386 --version` in MSYS2

### Option B: Official Installer
- [x] Downloaded from https://qemu.weilnetz.de/w64/
- [x] Installed QEMU
- [x] Added to PATH: `C:\Program Files\qemu`
- [x] Verified: `qemu-system-i386 --version` in PowerShell

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Step 5: Configure Windows PATH

Add these directories to your Windows PATH environment variable:

- [x] Added: `C:\msys64\usr\bin`
- [x] Added: `C:\msys64\mingw64\bin`
- [x] Added: `C:\msys64\home\[YourUsername]\opt\cross\bin`
      (Replace [YourUsername] with your actual username)
- [x] Restarted VS Code
- [x] Restarted any open PowerShell terminals

**How to add to PATH**:
1. Win + X → System → Advanced System Settings
2. Environment Variables → User variables → Path
3. Edit → New → Add each path
4. OK → OK → OK

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Step 6: Verify Installation

Open a **NEW** PowerShell terminal in VS Code and test each command:

- [x] `nasm -version` - Shows NASM version
- [x] `i686-elf-gcc --version` - Shows GCC version (13.x)
- [x] `i686-elf-ld --version` - Shows linker version
- [x] `qemu-system-i386 --version` - Shows QEMU version
- [x] `make --version` - Shows Make version

**All commands should work!**

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Step 7: Install VS Code Extensions

- [ ] **C/C++** (ms-vscode.cpptools) - C/C++ IntelliSense
- [ ] **x86 and x86_64 Assembly** - Assembly syntax highlighting
- [ ] **Hex Editor** (ms-vscode.hexeditor) - View binary files
- [ ] **Makefile Tools** (ms-vscode.makefile-tools) - Makefile support

**Status**: ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Troubleshooting Log

Use this section to note any issues you encounter:

### Issue 1:
**Problem**: 

**Solution**: 

### Issue 2:
**Problem**: 

**Solution**: 

---

## Final Verification

Before proceeding to Phase 1.2 (Creating the Bootloader):

- [ ] All tools installed and working
- [ ] PATH configured correctly
- [ ] All verification commands pass
- [ ] VS Code extensions installed
- [ ] QEMU tested and working

**Overall Status**: ⬜ Not Ready | ⏳ Almost There | ✅ Ready for Phase 1.2!

---

## Estimated Time

- **Quick Setup** (using pre-built cross-compiler): 30-60 minutes
- **Full Setup** (building cross-compiler): 2-3 hours
  - Active work: 30 minutes
  - Compilation time: 1.5-2.5 hours

---

## Next Steps

Once everything is checked off:

1. ✅ Mark this phase complete in ROADMAP.md
2. 📝 Proceed to Phase 1.2: Create BIOS Bootloader
3. 🚀 Start writing your first bootloader code!

---

**Started**: __________
**Completed**: __________
**Total Time**: __________
