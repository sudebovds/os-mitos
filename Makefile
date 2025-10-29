# MitOS Microkernel Build System

# Tools
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
QEMU = qemu-system-i386

# Flags
CFLAGS = -ffreestanding -m32 -g -c -Wall -Wextra
LDFLAGS = -nostdlib
KERNEL_LDFLAGS = -T kernel/linker.ld $(LDFLAGS)
SERVER_LDFLAGS = -T servers/server_linker.ld $(LDFLAGS)

# Directories
BUILD_DIR = build
BOOT_DIR = boot
KERNEL_DIR = kernel
SERVERS_DIR = servers
INCLUDE_DIR = include

# Source files
BOOT_SRC = $(BOOT_DIR)/boot.asm
KERNEL_ENTRY_SRC = $(KERNEL_DIR)/kernel_entry.asm
MICROKERNEL_SRC = $(KERNEL_DIR)/kernel.c
MEMORY_SERVER_SRC = $(SERVERS_DIR)/memory_server.c
VFS_SERVER_SRC = $(SERVERS_DIR)/vfs_server.c

# Object files
KERNEL_ENTRY_OBJ = $(BUILD_DIR)/kernel_entry.o
MICROKERNEL_OBJ = $(BUILD_DIR)/kernel.o
MEMORY_SERVER_OBJ = $(BUILD_DIR)/memory_server.o
VFS_SERVER_OBJ = $(BUILD_DIR)/vfs_server.o

# Binary files
BOOTLOADER = $(BUILD_DIR)/boot.bin
MICROKERNEL_BIN = $(BUILD_DIR)/microkernel.bin
MEMORY_SERVER_BIN = $(BUILD_DIR)/memory_server.bin
VFS_SERVER_BIN = $(BUILD_DIR)/vfs_server.bin
OS_IMAGE = $(BUILD_DIR)/mitos.img

# Default target
all: $(OS_IMAGE)
	@echo "================================"
	@echo "MitOS Microkernel Build Complete"
	@echo "================================"
	@echo "Kernel size: $$(stat -c%s $(MICROKERNEL_BIN) 2>/dev/null || echo 'N/A')"
	@echo "Total image: $$(stat -c%s $(OS_IMAGE) 2>/dev/null || echo 'N/A')"
	@echo ""
	@echo "Run 'make run' to test in QEMU"

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Bootloader
$(BOOTLOADER): $(BOOT_SRC) | $(BUILD_DIR)
	@echo "[ASM] Building bootloader..."
	$(ASM) -f bin $< -o $@

# Kernel entry point
$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILD_DIR)
	@echo "[ASM] Building kernel entry..."
	$(ASM) -f elf32 $< -o $@

# Microkernel core
$(MICROKERNEL_OBJ): $(MICROKERNEL_SRC) | $(BUILD_DIR)
	@echo "[CC]  Compiling microkernel..."
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) $< -o $@

# Link microkernel
$(MICROKERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(MICROKERNEL_OBJ)
	@echo "[LD]  Linking microkernel..."
	$(LD) $(KERNEL_LDFLAGS) -o $@ $^

# Memory server
$(MEMORY_SERVER_OBJ): $(MEMORY_SERVER_SRC) | $(BUILD_DIR)
	@echo "[CC]  Compiling memory server..."
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) $< -o $@

$(MEMORY_SERVER_BIN): $(MEMORY_SERVER_OBJ)
	@echo "[LD]  Linking memory server..."
	$(LD) $(SERVER_LDFLAGS) -o $@ $^

# Create OS image
$(OS_IMAGE): $(BOOTLOADER) $(MICROKERNEL_BIN)
	@echo "[IMG] Creating OS image..."
	cat $(BOOTLOADER) $(MICROKERNEL_BIN) > $@

# Run in QEMU
run: $(OS_IMAGE)
	@echo "Starting QEMU..."
	$(QEMU) -drive format=raw,file=$(OS_IMAGE) -m 32

# Run with debugging
debug: $(OS_IMAGE)
	@echo "Starting QEMU in debug mode..."
	@echo "Connect with: gdb -ex 'target remote :1234' $(MICROKERNEL_BIN)"
	$(QEMU) -s -S -drive format=raw,file=$(OS_IMAGE) -m 32

# Run with serial output
run-serial: $(OS_IMAGE)
	$(QEMU) -drive format=raw,file=$(OS_IMAGE) -serial stdio -m 32

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Show microkernel statistics
stats: $(MICROKERNEL_BIN)
	@echo "=== MitOS Microkernel Statistics ==="
	@echo "Kernel size: $$(stat -c%s $(MICROKERNEL_BIN) 2>/dev/null || echo 'Not built')"
	@echo "Sections:"
	@size $(MICROKERNEL_BIN) 2>/dev/null || echo "Not built yet"
	@echo ""
	@echo "Symbols:"
	@nm $(MICROKERNEL_BIN) 2>/dev/null | grep -c " T " | xargs echo "  Functions:" || echo "  Functions: N/A"
	@nm $(MICROKERNEL_BIN) 2>/dev/null | grep -c " D " | xargs echo "  Data symbols:" || echo "  Data symbols: N/A"

# Help
help:
	@echo "MitOS Microkernel Build System"
	@echo "=============================="
	@echo "Targets:"
	@echo "  make         - Build the microkernel"
	@echo "  make run     - Run in QEMU"
	@echo "  make debug   - Debug with GDB"
	@echo "  make stats   - Show kernel statistics"
	@echo "  make clean   - Clean build files"
	@echo "  make help    - Show this help"

.PHONY: all run debug run-serial clean stats help
