# Development Environment Setup Guide for Windows

This guide will help you set up everything needed to develop your OS on Windows.

---

## Prerequisites

- Windows 10/11
- At least 10 GB free disk space
- Administrator access
- Internet connection

---

## Step 1: Install MSYS2 (Unix-like Environment for Windows)

MSYS2 provides a Unix-like terminal and package manager for Windows, which we need for our cross-compiler and build tools.

### Installation Steps:

1. **Download MSYS2**:
   - Go to https://www.msys2.org/
   - Download the installer (msys2-x86_64-XXXXXXXX.exe)

2. **Run the installer**:
   - Install to default location: `C:\msys64`
   - Click "Next" through the installation
   - Check "Run MSYS2 now" at the end

3. **Update MSYS2**:
   ```bash
   pacman -Syu
   ```
   - If it asks to close the terminal, close it and reopen MSYS2
   - Run the update again:
   ```bash
   pacman -Su
   ```

---

## Step 2: Install Required Tools in MSYS2

Open **MSYS2 MSYS** terminal (not MinGW64!) and run:

```bash
# Install base development tools
pacman -S base-devel

# Install GCC and binutils
pacman -S mingw-w64-x86_64-gcc

# Install Make
pacman -S make

# Install NASM (assembler)
pacman -S nasm

# Install wget and other utilities
pacman -S wget tar

# Install GDB for debugging
pacman -S gdb
```

Type `Y` when prompted to confirm installation.

---

## Step 3: Build GCC Cross-Compiler

A cross-compiler is needed to compile code for your OS (i686-elf target) rather than Windows.

### 3.1 Install Prerequisites

```bash
# Install dependencies
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr mingw-w64-x86_64-mpc mingw-w64-x86_64-isl
```

### 3.2 Create Build Directory

```bash
mkdir -p ~/cross-compiler
cd ~/cross-compiler
```

### 3.3 Download Source Code

```bash
# Download binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz

# Download GCC
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz

# Extract
tar -xzf binutils-2.41.tar.gz
tar -xzf gcc-13.2.0.tar.gz
```

### 3.4 Set Environment Variables

```bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```

### 3.5 Build Binutils

```bash
mkdir build-binutils
cd build-binutils

../binutils-2.41/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror

make
make install

cd ..
```

This will take 5-15 minutes depending on your computer.

### 3.6 Build GCC

```bash
mkdir build-gcc
cd build-gcc

../gcc-13.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers

make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

cd ..
```

This will take 15-30 minutes.

### 3.7 Verify Installation

```bash
$HOME/opt/cross/bin/i686-elf-gcc --version
```

You should see something like: `i686-elf-gcc (GCC) 13.2.0`

---

## Step 4: Install QEMU (Emulator)

QEMU will let us test our OS without rebooting or using real hardware.

### Option A: Using MSYS2 (Recommended)

```bash
pacman -S mingw-w64-x86_64-qemu
```

### Option B: Official Installer

1. Download from: https://qemu.weilnetz.de/w64/
2. Install to default location
3. Add to PATH: `C:\Program Files\qemu`

### Verify Installation

```bash
qemu-system-i386 --version
```

---

## Step 5: Configure PATH Permanently

To use these tools from PowerShell and VS Code, we need to add them to Windows PATH.

### Add to System PATH:

1. Open **System Environment Variables**:
   - Press `Win + X` → System → Advanced System Settings → Environment Variables

2. Edit **Path** under **User variables**:
   - Click "New" and add these paths:
   ```
   C:\msys64\usr\bin
   C:\msys64\mingw64\bin
   C:\msys64\home\[YourUsername]\opt\cross\bin
   ```
   Replace `[YourUsername]` with your actual Windows username.

3. Click "OK" to save

4. **Restart VS Code** or any open terminals

---

## Step 6: Verify Everything Works

Open a **NEW** PowerShell terminal in VS Code and test:

```powershell
# Test NASM
nasm -version

# Test cross-compiler
i686-elf-gcc --version

# Test QEMU
qemu-system-i386 --version

# Test make
make --version
```

All commands should work without errors!

---

## Step 7: Install VS Code Extensions (Optional but Recommended)

Install these extensions in VS Code:

1. **C/C++** (Microsoft) - For C/C++ IntelliSense
2. **x86 and x86_64 Assembly** - For assembly syntax highlighting
3. **Hex Editor** - For viewing binary files
4. **Makefile Tools** - For Makefile support

---

## Alternative: Pre-built Cross-Compiler (Faster Setup)

If building the cross-compiler fails or takes too long, you can use a pre-built version:

1. Download from: https://github.com/lordmilko/i686-elf-tools/releases
2. Extract to `C:\cross-compiler\`
3. Add `C:\cross-compiler\bin` to PATH

---

## Troubleshooting

### "Command not found" errors
- Make sure MSYS2 paths are in your Windows PATH
- Restart your terminal/VS Code after adding to PATH
- Use forward slashes in MSYS2: `/c/Work/` instead of `C:\Work\`

### Cross-compiler build fails
- Make sure you're using **MSYS2 MSYS** terminal, not MinGW
- Install all dependencies: `pacman -S base-devel`
- Check you have enough disk space (at least 5GB free)

### QEMU doesn't start
- Try running from MSYS2 terminal first
- Check if antivirus is blocking it
- Make sure virtualization is enabled in BIOS

### "Permission denied" errors
- Run MSYS2 as administrator
- Check file permissions with `ls -la`

---

## Next Steps

Once everything is installed and verified:

1. Create the project directory structure
2. Write your first bootloader
3. Test it in QEMU

**Continue to: Phase 1.2 - Creating the Bootloader**

---

## Quick Reference

### Useful MSYS2 Commands

```bash
# Update all packages
pacman -Syu

# Search for a package
pacman -Ss package-name

# Install a package
pacman -S package-name

# Remove a package
pacman -R package-name
```

### Converting Windows Paths in MSYS2

- Windows: `C:\Work\OperationSystem`
- MSYS2: `/c/Work/OperationSystem`

### Building Your OS (Preview)

```bash
# Navigate to project
cd /c/Work/OperationSystem

# Build
make

# Run in QEMU
make run
```

We'll create these build commands in the next phase!
