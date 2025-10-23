# Quick Installation Guide - Remaining Tools

You already have NASM and Make installed! You just need:
1. GCC Cross-Compiler (i686-elf-gcc)
2. QEMU Emulator

---

## Option A: Install via MSYS2 (Recommended)

### Step 1: Install/Update MSYS2

If you don't have MSYS2:
1. Download from: https://www.msys2.org/
2. Install to C:\msys64
3. Run MSYS2 MSYS terminal

If you already have MSYS2:
1. Open MSYS2 MSYS terminal
2. Update it:
```bash
pacman -Syu
```

### Step 2: Install QEMU

In MSYS2 terminal:
```bash
pacman -S mingw-w64-x86_64-qemu
```

### Step 3: Install Cross-Compiler Build Dependencies

```bash
pacman -S base-devel mingw-w64-x86_64-gcc wget tar gdb
```

### Step 4: Build Cross-Compiler

This takes 30-60 minutes but is the proper way:

```bash
cd ~
mkdir cross-compiler
cd cross-compiler

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# Download sources
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz

# Extract
tar -xzf binutils-2.41.tar.gz
tar -xzf gcc-13.2.0.tar.gz

# Build binutils
mkdir build-binutils
cd build-binutils
../binutils-2.41/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make -j4
make install
cd ..

# Build GCC
mkdir build-gcc
cd build-gcc
../gcc-13.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make -j4 all-gcc
make -j4 all-target-libgcc
make install-gcc
make install-target-libgcc
```

### Step 5: Add to Windows PATH

Add these to your Windows PATH:
```
C:\msys64\usr\bin
C:\msys64\mingw64\bin
C:\msys64\home\[YourUsername]\opt\cross\bin
```

To add to PATH:
1. Win + X → System → Advanced System Settings
2. Environment Variables → Path → Edit → New
3. Add each path above
4. OK → OK → OK

### Step 6: Restart VS Code

Close completely and reopen.

---

## Option B: Pre-built Cross-Compiler (Faster - 10 minutes)

### Step 1: Download Pre-built Cross-Compiler

1. Go to: https://github.com/lordmilko/i686-elf-tools/releases
2. Download: `i686-elf-tools-windows.zip`
3. Extract to: `C:\i686-elf-tools\`

### Step 2: Install QEMU

Choose one:

**Via Chocolatey** (if you have it):
```powershell
choco install qemu
```

**Via Official Installer**:
1. Download from: https://qemu.weilnetz.de/w64/
2. Install QEMU
3. It will add itself to PATH

**Via MSYS2**:
1. Install MSYS2 (see Option A, Step 1)
2. Run: `pacman -S mingw-w64-x86_64-qemu`

### Step 3: Add to Windows PATH

Add these paths:
```
C:\i686-elf-tools\bin
C:\msys64\mingw64\bin          (if using MSYS2 for QEMU)
C:\Program Files\qemu           (if using QEMU installer)
```

### Step 4: Restart VS Code

Close completely and reopen.

---

## Option C: Use WSL2 (Alternative Approach)

If you're comfortable with Linux:

1. Install WSL2 with Ubuntu
2. In Ubuntu terminal:
```bash
sudo apt update
sudo apt install build-essential nasm qemu-system-x86 gcc
sudo apt install gcc-multilib g++-multilib

# Build cross-compiler (same as Option A but in Linux)
```

Then access your project from WSL.

---

## Verify Installation

After installing, run:
```powershell
.\tools\verify.ps1
```

You should see all checkmarks!

---

## My Recommendation

**For you**: Use **Option B** (pre-built) because:
- ✅ NASM and Make already work
- ✅ Quick setup (10 minutes)
- ✅ Less chance of build errors
- ✅ Gets you coding faster

You can always rebuild from source later if needed!

---

## Quick Commands for Option B

```powershell
# 1. Download i686-elf-tools from GitHub (manual download)
# 2. Extract to C:\i686-elf-tools
# 3. Download QEMU from qemu.weilnetz.de (manual download)
# 4. Install QEMU
# 5. Add to PATH (manual - see above)
# 6. Restart VS Code
# 7. Test:
.\tools\verify.ps1
```

---

## Troubleshooting

**"Command not found" after adding to PATH**
- Make sure you restarted VS Code COMPLETELY
- Check PATH was added correctly: `$env:Path -split ';'`

**Cross-compiler build fails in MSYS2**
- Make sure you're using MSYS2 MSYS (not MinGW64)
- Check free disk space (need 5GB+)
- Try pre-built version instead

**QEMU won't start**
- Check if virtualization is enabled in BIOS
- Try running as administrator
- Check Windows Defender isn't blocking it

---

## Next Step After Installation

Once verify.ps1 shows all green checkmarks:
1. Read ROADMAP.md Phase 1.2
2. Start writing your bootloader!
3. Create boot/boot.asm
