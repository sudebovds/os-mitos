# MitOS Architecture Overview

This document provides a high-level overview of how your operating system will work.

---

## System Boot Sequence

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPUTER POWERS ON                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  BIOS (Built into motherboard)                              │
│  - Performs Power-On Self Test (POST)                       │
│  - Initializes hardware                                     │
│  - Loads first 512 bytes from disk to 0x7C00               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  YOUR BOOTLOADER (boot.asm)                                 │
│  - Running in 16-bit Real Mode                              │
│  - Loads kernel from disk into memory                       │
│  - Sets up Global Descriptor Table (GDT)                    │
│  - Switches to 32-bit Protected Mode                        │
│  - Jumps to kernel entry point                              │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  KERNEL (kernel.c + kernel_entry.asm)                       │
│  - Running in 32-bit Protected Mode                         │
│  - Sets up Interrupt Descriptor Table (IDT)                 │
│  - Initializes memory management                            │
│  - Starts device drivers                                    │
│  - Loads file system                                        │
│  - Switches to user mode and starts shell                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Memory Layout

```
High Memory
│
├─── 0xFFFFFFFF ─────────────────────────
│
│         (Reserved/Unused)
│
├─── 0xC0000000 ───────────────────────── Kernel Space (Ring 0)
│                                          - Kernel code
│         Kernel Memory                   - Kernel heap
│                                          - Page tables
│                                          - Device drivers
├─── 0x00100000 (1 MB) ───────────────────
│
│         Extended Memory                 User Space (Ring 3)
│                                          - User programs
├─── 0x000A0000 (640 KB) ─────────────     - User heap/stack
│         VGA Memory                       - Shared libraries
│         (text mode: 0xB8000)
├─── 0x00007E00 ─────────────────────────
│         Bootloader code (loaded here)
├─── 0x00007C00 ─────────────────────────
│         BIOS Data Area
├─── 0x00000500 ─────────────────────────
│         BIOS/DOS Reserved
├─── 0x00000000 ─────────────────────────
Low Memory
```

---

## Kernel Architecture (Monolithic)

```
┌───────────────────────────────────────────────────────────────┐
│                      USER APPLICATIONS                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │  Shell   │  │ Notepad  │  │ Explorer │  │Calculator│     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │             │              │             │            │
└───────┼─────────────┼──────────────┼─────────────┼───────────┘
        │             │              │             │
        └─────────────┴──────────────┴─────────────┘
                      │                         Ring 3 (User Mode)
        ══════════════════════════════════════════════════════════
                      │                         Ring 0 (Kernel Mode)
                      ▼
┌───────────────────────────────────────────────────────────────┐
│                   SYSTEM CALL INTERFACE                        │
│  open() close() read() write() fork() exec() exit() ...       │
└───────────────────────────────────┬───────────────────────────┘
                                    │
┌───────────────────────────────────┴───────────────────────────┐
│                      KERNEL CORE                               │
│                                                                │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │ Process Manager  │  │ Memory Manager   │                  │
│  │ - Scheduling     │  │ - Paging         │                  │
│  │ - Context switch │  │ - Virtual memory │                  │
│  │ - IPC            │  │ - Heap (kmalloc) │                  │
│  └──────────────────┘  └──────────────────┘                  │
│                                                                │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │ File System (VFS)│  │ Interrupt Handler│                  │
│  │ - FAT32          │  │ - IDT            │                  │
│  │ - devfs          │  │ - ISRs           │                  │
│  └──────────────────┘  └──────────────────┘                  │
│                                                                │
└────────────────────────────────┬──────────────────────────────┘
                                 │
┌────────────────────────────────┴──────────────────────────────┐
│                      DEVICE DRIVERS                            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │
│  │Keyboard│ │ Mouse  │ │  VGA   │ │  ATA   │ │ Timer  │     │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘     │
└────────────────────────────────┬──────────────────────────────┘
                                 │
┌────────────────────────────────┴──────────────────────────────┐
│                         HARDWARE                               │
│  CPU | Memory | Disk | Keyboard | Mouse | Display | Timer     │
└───────────────────────────────────────────────────────────────┘
```

---

## Process Management

```
┌─────────────────────────────────────────────────────┐
│              PROCESS SCHEDULER                      │
│                                                     │
│  Timer Interrupt (every 10-20ms)                   │
│         │                                           │
│         ▼                                           │
│  Save current process state                        │
│         │                                           │
│         ▼                                           │
│  Pick next process from READY queue                │
│         │                                           │
│         ▼                                           │
│  Restore new process state                         │
│         │                                           │
│         ▼                                           │
│  Jump to new process                               │
│                                                     │
└─────────────────────────────────────────────────────┘

Process States:
┌─────────┐   fork()    ┌─────────┐   schedule()  ┌─────────┐
│   NEW   │ ─────────> │  READY  │ ───────────> │ RUNNING │
└─────────┘            └─────────┘              └─────────┘
                            ▲                         │
                            │                         │
                            │ I/O complete            │ I/O request
                            │                         ▼
                       ┌─────────┐              ┌─────────┐
                       │TERMINATED│             │ BLOCKED │
                       └─────────┘              └─────────┘
                            ▲                         │
                            └─────── exit() ──────────┘
```

---

## Virtual Memory (Paging)

```
Virtual Address (32-bit)
┌──────────────┬──────────────┬──────────────┐
│ Directory    │  Table       │  Offset      │
│ (10 bits)    │  (10 bits)   │  (12 bits)   │
└──────┬───────┴──────┬───────┴──────┬───────┘
       │              │              │
       ▼              ▼              ▼
   Directory      Table Index    Byte in Page
     Index

Translation Process:
1. Use Directory Index to find Page Table in Page Directory
2. Use Table Index to find Physical Frame in Page Table
3. Add Offset to get Physical Address

┌─────────────────┐
│ Page Directory  │ ────┐
│  (1024 entries) │     │
└─────────────────┘     │
                        ▼
                ┌─────────────────┐
                │   Page Table    │
                │  (1024 entries) │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Physical Memory │
                │   (4KB pages)   │
                └─────────────────┘

Benefits:
- Each process has its own address space
- Memory protection
- Can use more memory than physically available (swapping)
- Can map same physical page to multiple processes
```

---

## Interrupt Handling

```
Hardware Interrupt (e.g., Keyboard)
         │
         ▼
┌─────────────────────────────────────┐
│ CPU looks up handler in IDT         │
│ (Interrupt Descriptor Table)        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Save CPU state (registers, flags)   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Call ISR (Interrupt Service Routine)│
│ - Read from keyboard port           │
│ - Process scancode                  │
│ - Add to keyboard buffer            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Send EOI (End of Interrupt) to PIC  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Restore CPU state                   │
└──────────────┬──────────────────────┘
               │
               ▼
         Return to program
```

---

## File System Structure (FAT32)

```
┌─────────────────────────────────────────────────┐
│              BOOT SECTOR                        │
│  - Bytes per sector                             │
│  - Sectors per cluster                          │
│  - Number of FATs                               │
│  - Root directory cluster                       │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────┐
│              FAT #1                             │
│  (File Allocation Table)                        │
│  Maps clusters to next cluster in chain         │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────┐
│              FAT #2 (Backup)                    │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────┐
│              DATA AREA                          │
│  ┌──────────────────────────────┐              │
│  │ Root Directory (Cluster 2)   │              │
│  │  ┌────────────────────┐      │              │
│  │  │ file1.txt (Cluster 3)     │              │
│  │  │ folder/   (Cluster 5)     │              │
│  │  └────────────────────┘      │              │
│  └──────────────────────────────┘              │
│  ┌──────────────────────────────┐              │
│  │ Cluster 3: file1.txt data    │              │
│  └──────────────────────────────┘              │
│  ┌──────────────────────────────┐              │
│  │ Cluster 5: folder directory  │              │
│  └──────────────────────────────┘              │
└─────────────────────────────────────────────────┘
```

---

## GUI Architecture

```
┌─────────────────────────────────────────────────────┐
│                  DESKTOP ENVIRONMENT                 │
│  ┌────────────┐                                     │
│  │  Taskbar   │  [Start] [App1] [App2]    [Clock]  │
│  └────────────┘                                     │
│                                                     │
│  ┌───────────────────────────────────────┐         │
│  │ Window 1: Notepad                  [_][□][X]    │
│  │ ─────────────────────────────────────         │
│  │                                               │
│  │  Hello, World!                                │
│  │  ▌                                            │
│  │                                               │
│  └───────────────────────────────────────┘         │
│                                                     │
│  ┌───────────────────────────────────────┐         │
│  │ Window 2: Terminal              [_][□][X]      │
│  │ ─────────────────────────────────────         │
│  │ C:\> dir                                      │
│  │ file1.txt  file2.txt                          │
│  │ C:\> ▌                                        │
│  └───────────────────────────────────────┘         │
└─────────────────────────────────────────────────────┘

Rendering Pipeline:
┌──────────────────┐
│ Application draws│
│  to window buffer│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Window Manager   │
│  composits all   │
│  window buffers  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Copy to screen   │
│  framebuffer     │
│  (double buffer) │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Display on screen│
└──────────────────┘
```

---

## Development Workflow

```
1. Write Code
   ├── boot/boot.asm
   ├── kernel/kernel.c
   └── drivers/keyboard.c

2. Compile
   ├── nasm -f bin boot.asm -o boot.bin
   ├── i686-elf-gcc -c kernel.c -o kernel.o
   └── i686-elf-gcc -c keyboard.c -o keyboard.o

3. Link
   └── i686-elf-ld -o kernel.bin -Ttext 0x1000 kernel.o keyboard.o

4. Create Disk Image
   └── cat boot.bin kernel.bin > os-image.bin

5. Test in QEMU
   └── qemu-system-i386 -drive format=raw,file=os-image.bin

6. Debug if needed
   └── qemu-system-i386 -s -S -drive format=raw,file=os-image.bin
       (then connect with GDB)
```

---

## Key Concepts to Understand

### 1. Real Mode vs Protected Mode
- **Real Mode (16-bit)**: What BIOS uses, limited to 1MB memory
- **Protected Mode (32-bit)**: What we'll use, access to 4GB memory

### 2. Rings (Protection Levels)
- **Ring 0 (Kernel)**: Full hardware access
- **Ring 3 (User)**: Limited access, must use system calls

### 3. Interrupts
- **Hardware interrupts**: From devices (keyboard, timer, disk)
- **Software interrupts**: System calls (INT 0x80)
- **Exceptions**: Errors (divide by zero, page fault)

### 4. Memory Segmentation vs Paging
- **Segmentation**: Divide memory into segments (we'll use flat model)
- **Paging**: Divide memory into fixed-size pages (4KB)

### 5. Context Switching
- Saving one process state and loading another
- Happens on timer interrupt or when process blocks

---

## Next Steps

Now that you understand the architecture:

1. ✅ Set up development environment (GETTING_STARTED.md)
2. 📖 Read Phase 1.2 in ROADMAP.md
3. 💻 Start writing your bootloader!

The bootloader is the first piece of code that runs. It's written in Assembly because C can't run before the environment is set up.
