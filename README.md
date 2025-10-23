# MitOS - Windows-like x86 Operating System

A fully functional Windows-like operating system built from scratch using C/C++ and x86 Assembly.

## Project Status

🚧 **Currently in Development** - Phase 1: Setting up development environment

## Features (Planned)

- [x] Development environment setup
- [x] Custom bootloader (BIOS/MBR)
- [ ] Kernel with interrupt handling
- [ ] Memory management (paging, heap allocation)
- [ ] Multitasking and process scheduling
- [ ] File system (FAT32)
- [ ] Device drivers (keyboard, mouse, VGA, ATA)
- [ ] Graphical User Interface (GUI)
- [ ] Window manager (Windows-like)
- [ ] User applications (shell, text editor, file manager)
- [ ] Networking stack (TCP/IP)

## Architecture

- **Target**: x86 (i686) 32-bit
- **Bootloader**: Custom BIOS bootloader
- **Kernel**: Monolithic kernel written in C/C++
- **User Space**: Ring 3 applications
- **File System**: FAT32 (initially)
- **GUI**: VESA graphics mode with custom window manager

## Documentation

- [Development Roadmap](ROADMAP.md) - Detailed development plan and milestones
- [Setup Guide](docs/SETUP_GUIDE.md) - How to set up the development environment
- [Architecture](docs/ARCHITECTURE.md) - System architecture documentation (coming soon)
- [API Reference](docs/API.md) - Kernel API documentation (coming soon)

## Building

### Prerequisites

- GCC cross-compiler (i686-elf-gcc)
- NASM assembler
- Make
- QEMU (for testing)

See [Setup Guide](docs/SETUP_GUIDE.md) for detailed installation instructions.

### Build Commands

```bash
# Build the OS
make

# Run in QEMU
make run

# Clean build files
make clean

# Build and run in debug mode
make debug
```

## Project Structure

```
OperationSystem/
├── boot/          # Bootloader code
├── kernel/        # Kernel core
├── drivers/       # Device drivers
├── fs/            # File system
├── gui/           # GUI system
├── libc/          # C standard library
├── apps/          # User applications
├── include/       # Header files
├── docs/          # Documentation
└── tools/         # Build tools and scripts
```

## Testing

The OS is tested using QEMU emulator. Real hardware testing will be done in later phases.

```bash
# Run in QEMU
qemu-system-i386 -drive format=raw,file=os-image.bin
```

## Contributing

This is a learning project. Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Ask questions

## Development Timeline

- **Weeks 1-3**: Bootloader and basic kernel
- **Weeks 4-10**: Memory management
- **Weeks 11-15**: Process management
- **Weeks 16-20**: File system
- **Weeks 21-32**: GUI and window manager
- **Weeks 33+**: Applications and polish

See [ROADMAP.md](ROADMAP.md) for detailed timeline.

## Resources

### Books
- "Operating Systems: Design and Implementation" by Andrew Tanenbaum
- "Operating System Concepts" by Silberschatz, Galvin, Gagne
- Intel 64 and IA-32 Architectures Software Developer's Manual

### Websites
- [OSDev.org](https://wiki.osdev.org/) - OS development wiki
- [Intel Documentation](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [BIOS Interrupt List](http://www.ctyme.com/intr/int.htm)

## License

This project is for educational purposes.

## Author

Built with guidance from GitHub Copilot as a learning project in OS development.

---

**Current Phase**: Setting up development environment  
**Last Updated**: October 21, 2025
