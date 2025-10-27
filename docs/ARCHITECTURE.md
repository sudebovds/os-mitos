# MitOS Microkernel Architecture Overview

This document provides a high-level overview of the MitOS microkernel architecture.

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
│  BOOTLOADER (boot.asm)                                      │
│  - Running in 16-bit Real Mode                              │
│  - Loads microkernel from disk into memory                  │
│  - Sets up Global Descriptor Table (GDT)                    │
│  - Switches to 32-bit Protected Mode                        │
│  - Jumps to kernel entry point                              │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  MICROKERNEL (kernel.c)                                     │
│  - Running in 32-bit Protected Mode                         │
│  - Sets up Interrupt Descriptor Table (IDT)                 │
│  - Initializes minimal memory management                    │
│  - Sets up IPC (Inter-Process Communication)                │
│  - Starts essential system servers                          │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  SYSTEM SERVERS (User Space)                                │
│  - VFS Server (Virtual File System)                         │
│  - Device Manager Server                                    │
│  - Network Server                                           │
│  - Window Manager Server                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Microkernel Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                      USER APPLICATIONS                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │  Shell   │  │ Notepad  │  │ Explorer │  │Calculator│     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │             │              │             │            │
└───────┼─────────────┼──────────────┼─────────────┼───────────┘
        │             │              │             │       Ring 3
═══════════════════════════════════════════════════════════════
        │             │              │             │       Ring 1-2
┌───────┼─────────────┼──────────────┼─────────────┼───────────┐
│                    SYSTEM SERVERS (User Space)                │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  VFS Server  │  │Device Manager│  │Window Manager│       │
│  │              │  │              │  │              │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                  │                  │               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │Network Server│  │ Process Mgr  │  │ Memory Mgr   │       │
│  │              │  │   Server     │  │   Server     │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                  │                  │               │
└─────────┼──────────────────┼──────────────────┼───────────────┘
          │                  │                  │       
═══════════════════════════════════════════════════════════════
          │                  │                  │       Ring 0
          ▼                  ▼                  ▼
┌───────────────────────────────────────────────────────────────┐
│                    MICROKERNEL CORE                           │
│                                                                │
│  ┌─────────────────────────────────────────────────────┐     │
│  │            Inter-Process Communication (IPC)         │     │
│  │  - Message Passing                                   │     │
│  │  - Synchronous & Asynchronous                        │     │
│  │  - Port-based communication                          │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                                │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │   Scheduler      │  │  Basic Memory    │                  │
│  │   - Threads      │  │  - Page tables   │                  │
│  │   - Priorities   │  │  - Address spaces│                  │
│  └──────────────────┘  └──────────────────┘                  │
│                                                                │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │Interrupt Handler │  │  Hardware        │                  │
│  │  - IDT           │  │  Abstraction     │                  │
│  │  - IRQ routing   │  │  Layer (HAL)     │                  │
│  └──────────────────┘  └──────────────────┘                  │
│                                                                │
└────────────────────────────────┬──────────────────────────────┘
                                 │
┌────────────────────────────────┴──────────────────────────────┐
│                         HARDWARE                               │
│  CPU | Memory | Disk | Keyboard | Mouse | Display | Timer     │
└───────────────────────────────────────────────────────────────┘
```

---

## IPC (Inter-Process Communication)

```
Process A wants to read a file:
═════════════════════════════════════════════════════════

Process A                 Microkernel              VFS Server
    │                         │                         │
    │ send_msg(VFS_PORT,      │                         │
    │         "open file.txt")│                         │
    │────────────────────────>│                         │
    │                         │ route_message()         │
    │                         │────────────────────────>│
    │                         │                         │ process request
    │                         │                         │ open("file.txt")
    │                         │<────────────────────────│
    │                         │     reply(fd=3)         │
    │<────────────────────────│                         │
    │    receive(fd=3)        │                         │
    │                         │                         │

Benefits of Microkernel IPC:
- Isolation: Server crash doesn't crash kernel
- Security: Servers run with limited privileges  
- Modularity: Easy to add/remove servers
- Debugging: Easier to debug individual servers
```

---

## Memory Management in Microkernel

```
┌─────────────────────────────────────────────────────┐
│              MICROKERNEL (Ring 0)                   │
│                                                     │
│  Basic Page Table Management:                      │
│  - Map/unmap pages                                 │
│  - Handle page faults                              │
│  - Manage address spaces                           │
└──────────────────────┬──────────────────────────────┘
                       │ IPC
┌──────────────────────▼──────────────────────────────┐
│         MEMORY MANAGER SERVER (User Space)          │
│                                                     │
│  High-level Memory Services:                       │
│  - Heap allocation (malloc/free)                   │
│  - Shared memory regions                           │
│  - Memory-mapped files                             │
│  - Swap management                                 │
└─────────────────────────────────────────────────────┘

Virtual Address Space Layout:
┌─────────────────────────────────────────────────────┐
│ 0xFFFFFFFF ─────────────────────────────────────    │
│              Kernel Space (Microkernel only)        │
│ 0xC0000000 ─────────────────────────────────────    │
│              Server Space                           │
│              - VFS Server                           │
│              - Device Manager                       │
│              - Window Manager                       │
│ 0x80000000 ─────────────────────────────────────    │
│              User Application Space                 │
│              - Code                                 │
│              - Data                                 │
│              - Heap                                 │
│              - Stack                                │
│ 0x00000000 ─────────────────────────────────────    │
└─────────────────────────────────────────────────────┘
```

---

## Device Driver Architecture

```
Traditional Monolithic:           Microkernel:
┌──────────────┐                 ┌──────────────┐
│   Kernel     │                 │ Microkernel  │
│  ┌────────┐  │                 │              │
│  │ Driver │  │                 └───────┬──────┘
│  └────────┘  │                         │ IPC
└──────────────┘                 ┌───────▼──────┐
                                 │Device Manager│
                                 │   Server     │
                                 │  ┌────────┐  │
                                 │  │ Driver │  │
                                 │  └────────┘  │
                                 └──────────────┘

Benefits:
- Driver crash doesn't crash kernel
- Drivers can be restarted
- Better security isolation
- Easier development and debugging
```

---

## System Servers

### 1. VFS Server (Virtual File System)
- Manages all file operations
- Coordinates with device drivers
- Implements file system abstraction

### 2. Process Manager Server
- Creates/destroys processes
- Manages process information
- Handles parent-child relationships

### 3. Memory Manager Server
- High-level memory allocation
- Shared memory management
- Swap space management

### 4. Device Manager Server
- Loads device drivers
- Manages device enumeration
- Handles hot-plug events

### 5. Network Server
- TCP/IP stack
- Socket management
- Network device coordination

### 6. Window Manager Server
- GUI rendering
- Window management
- Event distribution

---

## Microkernel Development Phases

### Phase 1: Minimal Microkernel
- [x] Bootloader
- [ ] Protected mode setup
- [ ] Basic memory management (paging)
- [ ] Simple IPC (synchronous messages)
- [ ] Thread scheduling

### Phase 2: Essential Servers
- [ ] Memory Manager Server
- [ ] Process Manager Server
- [ ] Simple VFS Server

### Phase 3: Device Support
- [ ] Device Manager Server
- [ ] Keyboard driver (as server)
- [ ] Display driver (as server)
- [ ] Disk driver (as server)

### Phase 4: User Interface
- [ ] Window Manager Server
- [ ] Graphics subsystem
- [ ] Event system

### Phase 5: Applications
- [ ] Shell
- [ ] Basic utilities
- [ ] GUI applications

---

## IPC Message Format

```c
typedef struct {
    uint32_t sender_id;     // Who sent the message
    uint32_t receiver_id;   // Who should receive it
    uint32_t message_type;  // Type of message
    uint32_t data_length;   // Length of data
    union {
        uint32_t values[4]; // Small data
        void*    pointer;   // Pointer to larger data
    } data;
} ipc_message_t;

// Example: File open request
ipc_message_t msg = {
    .sender_id = current_process_id,
    .receiver_id = VFS_SERVER_ID,
    .message_type = VFS_OPEN_FILE,
    .data_length = strlen(filename),
    .data.pointer = filename
};
```

---

## Comparison: Microkernel vs Monolithic

| Aspect | Microkernel | Monolithic |
|--------|-------------|------------|
| **Kernel Size** | Small (~10-50KB) | Large (~1-10MB) |
| **Services Location** | User space servers | Kernel space |
| **IPC Overhead** | Higher | Lower |
| **Stability** | Better (isolation) | Crash affects all |
| **Security** | Better (principle of least privilege) | All code runs privileged |
| **Modularity** | High | Lower |
| **Performance** | Slightly slower | Faster |
| **Development** | Easier to debug | Complex debugging |

---

## Next Steps

1. ✅ Development environment ready
2. ✅ Basic bootloader complete
3. 🔄 **Current**: Implement microkernel core
   - Basic IPC mechanism
   - Thread scheduler
   - Memory management primitives
4. 📋 **Next**: Create first system server (Memory Manager)

The microkernel approach will make your OS more robust and easier to develop!