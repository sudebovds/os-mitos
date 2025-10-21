# Quick Setup Script for MitOS Development Environment
# Run this in MSYS2 MSYS terminal (not MinGW!)

echo "=========================================="
echo "MitOS Development Environment Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Update MSYS2
echo -e "${YELLOW}Step 1: Updating MSYS2...${NC}"
pacman -Syu --noconfirm
echo -e "${GREEN}✓ MSYS2 updated${NC}"
echo ""

# Step 2: Install basic tools
echo -e "${YELLOW}Step 2: Installing basic development tools...${NC}"
pacman -S --noconfirm base-devel mingw-w64-x86_64-gcc make nasm wget tar gdb
echo -e "${GREEN}✓ Basic tools installed${NC}"
echo ""

# Step 3: Install QEMU
echo -e "${YELLOW}Step 3: Installing QEMU...${NC}"
pacman -S --noconfirm mingw-w64-x86_64-qemu
echo -e "${GREEN}✓ QEMU installed${NC}"
echo ""

# Step 4: Build cross-compiler
echo -e "${YELLOW}Step 4: Building GCC cross-compiler (this will take 30-60 minutes)...${NC}"
read -p "Do you want to build the cross-compiler now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Create build directory
    mkdir -p ~/cross-compiler
    cd ~/cross-compiler

    # Set environment variables
    export PREFIX="$HOME/opt/cross"
    export TARGET=i686-elf
    export PATH="$PREFIX/bin:$PATH"

    # Download sources
    echo -e "${YELLOW}Downloading binutils...${NC}"
    wget -q --show-progress https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz
    
    echo -e "${YELLOW}Downloading GCC...${NC}"
    wget -q --show-progress https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz

    # Extract
    echo -e "${YELLOW}Extracting archives...${NC}"
    tar -xzf binutils-2.41.tar.gz
    tar -xzf gcc-13.2.0.tar.gz

    # Build binutils
    echo -e "${YELLOW}Building binutils...${NC}"
    mkdir -p build-binutils
    cd build-binutils
    ../binutils-2.41/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
    make -j$(nproc)
    make install
    cd ..
    echo -e "${GREEN}✓ Binutils built and installed${NC}"

    # Build GCC
    echo -e "${YELLOW}Building GCC (this is the longest step)...${NC}"
    mkdir -p build-gcc
    cd build-gcc
    ../gcc-13.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
    make -j$(nproc) all-gcc
    make -j$(nproc) all-target-libgcc
    make install-gcc
    make install-target-libgcc
    cd ..
    echo -e "${GREEN}✓ GCC built and installed${NC}"

    # Verify
    if [ -f "$HOME/opt/cross/bin/i686-elf-gcc" ]; then
        echo -e "${GREEN}✓ Cross-compiler successfully built!${NC}"
        $HOME/opt/cross/bin/i686-elf-gcc --version
    else
        echo -e "${RED}✗ Cross-compiler build failed!${NC}"
    fi
else
    echo -e "${YELLOW}Skipping cross-compiler build.${NC}"
    echo "You can download pre-built binaries from:"
    echo "https://github.com/lordmilko/i686-elf-tools/releases"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Add to Windows PATH:"
echo "   - C:\\msys64\\usr\\bin"
echo "   - C:\\msys64\\mingw64\\bin"
echo "   - C:\\msys64\\home\\$(whoami)\\opt\\cross\\bin"
echo ""
echo "2. Restart VS Code and PowerShell terminals"
echo ""
echo "3. Verify installation in PowerShell:"
echo "   nasm -version"
echo "   i686-elf-gcc --version"
echo "   qemu-system-i386 --version"
echo ""
echo "4. Check docs/SETUP_CHECKLIST.md to track your progress"
echo ""
