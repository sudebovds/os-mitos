# MitOS Makefile
# Build system for MitOS operating system

# Assembler
ASM = nasm

# Directories
BUILD_DIR = build
BOOT_DIR = boot

# Output files
BOOTLOADER = $(BUILD_DIR)/boot.bin
OS_IMAGE = $(BUILD_DIR)/os-image.bin

# Default target: build everything
all: $(OS_IMAGE)
	@echo "Build complete! OS image created: $(OS_IMAGE)"
	@echo "Run 'make run' to test in QEMU"

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble bootloader
$(BOOTLOADER): $(BOOT_DIR)/boot.asm | $(BUILD_DIR)
	@echo "Assembling bootloader..."
	$(ASM) -f bin $< -o $@
	@echo "Bootloader created: $(BOOTLOADER)"

# Create OS image (for now, just the bootloader)
$(OS_IMAGE): $(BOOTLOADER)
	@echo "Creating OS image..."
	cp $(BOOTLOADER) $(OS_IMAGE)
	@echo "OS image created: $(OS_IMAGE)"

# Run in QEMU
run: $(OS_IMAGE)
	@echo "Starting QEMU..."
	qemu-system-i386 -drive format=raw,file=$(OS_IMAGE)

# Run in QEMU with serial output
run-serial: $(OS_IMAGE)
	@echo "Starting QEMU with serial output..."
	qemu-system-i386 -drive format=raw,file=$(OS_IMAGE) -serial stdio

# Debug in QEMU (waits for GDB connection)
debug: $(OS_IMAGE)
	@echo "Starting QEMU in debug mode..."
	@echo "Connect with GDB using: target remote localhost:1234"
	qemu-system-i386 -s -S -drive format=raw,file=$(OS_IMAGE)

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Show info about the bootloader
info: $(BOOTLOADER)
	@echo "=== Bootloader Information ==="
	@echo "File: $(BOOTLOADER)"
	@ls -lh $(BOOTLOADER)
	@echo ""
	@echo "First 16 bytes (hex):"
	@hexdump -C $(BOOTLOADER) | head -n 1
	@echo ""
	@echo "Last 16 bytes (should end with 55 AA):"
	@hexdump -C $(BOOTLOADER) | tail -n 2

# Help
help:
	@echo "MitOS Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make          - Build the OS image"
	@echo "  make run      - Build and run in QEMU"
	@echo "  make run-serial - Run with serial output"
	@echo "  make debug    - Run in debug mode (for GDB)"
	@echo "  make clean    - Remove build files"
	@echo "  make info     - Show bootloader information"
	@echo "  make help     - Show this help message"

.PHONY: all run run-serial debug clean info help
