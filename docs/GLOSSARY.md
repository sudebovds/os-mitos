# OS Development Glossary

A comprehensive guide to all the terminology you'll encounter while building your operating system.

---

## A

**ATA (Advanced Technology Attachment)**
- Interface standard for connecting storage devices (hard drives)
- Also called IDE (Integrated Drive Electronics)
- We'll use ATA PIO mode to read/write from disk

**Assembly Language**
- Low-level programming language
- Direct representation of machine code
- Each instruction corresponds to one CPU operation
- Example: `mov eax, 5` (move value 5 into register eax)

---

## B

**BIOS (Basic Input/Output System)**
- Firmware built into motherboard
- First code that runs when computer powers on
- Loads bootloader from disk and executes it
- Provides basic hardware services in real mode

**Bootloader**
- First program loaded by BIOS
- Must fit in 512 bytes (one sector)
- Loads the kernel into memory
- Switches from 16-bit to 32-bit mode
- Jumps to kernel entry point

**Boot Sector**
- First 512 bytes of a bootable disk
- Must end with magic bytes: 0x55 0xAA
- Loaded by BIOS to address 0x7C00

---

## C

**Context Switch**
- Saving state of one process and loading another
- Includes: registers, stack pointer, page directory
- Triggered by timer interrupt or system call
- Critical for multitasking

**CPU Registers**
- Small, fast storage locations in CPU
- General purpose: EAX, EBX, ECX, EDX, ESI, EDI
- Special purpose: ESP (stack pointer), EBP (base pointer), EIP (instruction pointer)
- Control: CR0, CR3 (page directory), EFLAGS

**Cross-Compiler**
- Compiler that produces code for different platform
- We use i686-elf-gcc: runs on Windows, produces code for bare-metal x86
- Needed because normal gcc targets Windows/Linux, not bare metal

---

## D

**DMA (Direct Memory Access)**
- Hardware feature allowing devices to access memory without CPU
- Makes disk/network operations faster
- We'll use PIO mode initially (simpler but slower)

**Driver**
- Software that controls hardware device
- Examples: keyboard driver, disk driver, graphics driver
- Usually part of kernel in monolithic systems

---

## E

**ELF (Executable and Linkable Format)**
- Standard format for executables on Unix/Linux
- Our kernel will be compiled to ELF format
- Contains: code sections, data sections, symbol tables

**Exception**
- CPU-generated interrupt due to error
- Examples: division by zero, page fault, invalid opcode
- Must be handled or system crashes (triple fault)

---

## F

**FAT32 (File Allocation Table 32)**
- Simple file system
- Uses table to track which clusters belong to which files
- Good for learning (simpler than NTFS/ext4)
- Still used on USB drives

**Framebuffer**
- Region of memory representing screen pixels
- In text mode: 0xB8000 (80x25 characters)
- In graphics mode: VESA provides address
- Write to framebuffer to draw on screen

---

## G

**GCC (GNU Compiler Collection)**
- Open-source compiler for C/C++
- We use i686-elf-gcc variant
- Converts C code to assembly/machine code

**GDT (Global Descriptor Table)**
- Table defining memory segments
- Required in protected mode
- We'll use "flat model": all segments cover all memory
- Contains: null descriptor, code segment, data segment

**GDB (GNU Debugger)**
- Tool for debugging programs
- Can debug QEMU remotely
- Set breakpoints, inspect memory, step through code

---

## H

**Heap**
- Memory region for dynamic allocation
- Grows as needed
- Managed by allocator (malloc/free or kmalloc/kfree)
- In kernel: used for data structures, buffers

**Hardware Interrupt**
- Signal from device to CPU
- Causes CPU to stop current task and handle interrupt
- Examples: keyboard press, timer tick, disk ready
- Uses IRQ (Interrupt Request) lines

---

## I

**IDT (Interrupt Descriptor Table)**
- Table of interrupt handlers
- 256 entries (interrupts 0-255)
- CPU uses this to find which function to call for each interrupt
- Similar to GDT but for interrupts

**IPC (Inter-Process Communication)**
- Methods for processes to communicate
- Techniques: pipes, shared memory, message passing, signals
- Important for multitasking OS

**IRQ (Interrupt Request)**
- Hardware interrupt line
- IRQ 0: Timer
- IRQ 1: Keyboard
- IRQ 12: Mouse
- IRQ 14/15: Disk (ATA)

**ISR (Interrupt Service Routine)**
- Function called when interrupt occurs
- Must save state, handle interrupt, restore state
- Must send EOI (End Of Interrupt) to PIC

---

## K

**Kernel**
- Core of operating system
- Manages: memory, processes, devices, file system
- Runs in Ring 0 (privileged mode)
- Only part of OS with full hardware access

**kmalloc/kfree**
- Kernel equivalents of malloc/free
- Allocate/free memory from kernel heap
- Used for dynamic kernel data structures

---

## L

**Linker Script**
- File telling linker how to combine object files
- Specifies: memory layout, entry point, sections
- Example: linker.ld
- Controls where kernel is loaded in memory

**LBA (Logical Block Addressing)**
- Modern way to address disk sectors
- Uses simple sector numbers (0, 1, 2, ...)
- Alternative to CHS (Cylinder-Head-Sector)

---

## M

**MBR (Master Boot Record)**
- First sector of disk (sector 0)
- Contains: bootloader code (446 bytes), partition table (64 bytes), signature (2 bytes)
- Loaded by BIOS to 0x7C00

**Memory Mapping**
- Making region of memory accessible at specific address
- Example: mapping VGA memory, mapping file into memory
- Uses paging system

**Multitasking**
- Running multiple programs at same time
- Preemptive: OS forcibly switches tasks (we'll use this)
- Cooperative: tasks voluntarily yield CPU

---

## N

**NASM (Netwide Assembler)**
- Assembler for x86 architecture
- Converts assembly code to machine code
- Used for bootloader and low-level kernel code

---

## O

**Object File (.o)**
- Compiled but not linked code
- Contains machine code, symbols, relocations
- Linker combines multiple .o files into executable

**OSDev**
- Community dedicated to OS development
- Website: osdev.org
- Invaluable resource for tutorials and documentation

---

## P

**Page**
- Fixed-size block of memory (4KB on x86)
- Virtual memory divided into pages
- Physical memory divided into frames
- Paging maps pages to frames

**Page Directory**
- Top-level paging structure
- Contains 1024 entries
- Each entry points to page table
- Address stored in CR3 register

**Page Table**
- Second-level paging structure
- Contains 1024 entries
- Each entry maps virtual page to physical frame
- Enables 4GB virtual address space

**Page Fault**
- Exception when accessing unmapped page
- Can be used for: lazy loading, copy-on-write, swapping
- Must be handled by kernel

**PCI (Peripheral Component Interconnect)**
- Bus standard for connecting devices
- Used to enumerate and configure hardware
- More advanced than PIO/MMIO

**PCB (Process Control Block)**
- Data structure representing a process
- Contains: PID, state, registers, memory map, open files
- Kernel maintains PCB for each process

**PIC (Programmable Interrupt Controller)**
- Chip managing hardware interrupts
- Maps IRQs to interrupt numbers
- Must be initialized and remapped in kernel
- Modern systems use APIC instead

**PIO (Programmed Input/Output)**
- Method where CPU directly reads/writes to device ports
- Simpler than DMA but slower
- Used for: keyboard, mouse, simple disk operations

**Protected Mode**
- 32-bit mode with memory protection
- Access to 4GB memory
- Segmentation and paging available
- Privilege levels (rings)

---

## Q

**QEMU**
- Open-source machine emulator
- Emulates x86 CPU and devices
- Perfect for testing OS without real hardware or rebooting
- Supports remote debugging with GDB

---

## R

**Real Mode**
- 16-bit mode CPUs start in
- Legacy mode for BIOS compatibility
- Limited to 1MB memory
- No memory protection
- Bootloader runs in this mode

**Ring 0**
- Highest privilege level (kernel mode)
- Full access to hardware and memory
- Can execute privileged instructions
- Where kernel runs

**Ring 3**
- Lowest privilege level (user mode)
- Restricted access to hardware
- Cannot execute privileged instructions
- Must use system calls to access kernel
- Where user programs run

**RTC (Real-Time Clock)**
- Hardware clock that keeps track of time
- Continues running even when computer is off
- Accessed via CMOS ports
- Provides date/time to OS

---

## S

**Scheduler**
- Component that decides which process runs next
- Algorithms: Round-Robin, Priority-based, Multilevel queue
- Runs on timer interrupt
- Performs context switch

**Sector**
- Smallest addressable unit on disk
- Usually 512 bytes
- Disks are divided into sectors
- File systems use multiple sectors (clusters)

**Segmentation**
- Memory protection mechanism
- Divides memory into segments
- Each segment has base address and limit
- We'll use flat model (all segments same size)

**Stack**
- Memory region for function calls
- Grows downward (on x86)
- Stores: return addresses, local variables, function arguments
- Each process has its own stack
- ESP register points to top of stack

**System Call**
- Interface between user programs and kernel
- User program triggers interrupt (INT 0x80)
- Kernel performs privileged operation
- Returns result to user program

---

## T

**Task State Segment (TSS)**
- Data structure for hardware task switching
- We'll use it for stack switching (Ring 3 → Ring 0)
- Contains stack pointers for each privilege level

**Timer (PIT - Programmable Interval Timer)**
- Hardware timer generating periodic interrupts
- IRQ 0
- Used for: multitasking, timekeeping, delays
- Configurable frequency

**TLB (Translation Lookaside Buffer)**
- CPU cache for page table entries
- Speeds up virtual-to-physical address translation
- Must be flushed when changing page tables

**Triple Fault**
- CPU exception while handling exception while handling exception
- CPU gives up and resets
- Usually indicates serious kernel bug
- In QEMU, causes reboot

---

## U

**User Mode**
- See Ring 3
- Programs run with limited privileges
- Safer - bugs can't crash system

---

## V

**VBE (VESA BIOS Extensions)**
- Standard for graphics modes
- Provides high resolution and color depth
- Alternative to VGA text mode
- Used for GUI

**VFS (Virtual File System)**
- Abstraction layer over file systems
- Provides common interface
- Allows multiple file system types
- User programs use VFS, not specific FS

**VGA (Video Graphics Array)**
- Standard display interface
- Text mode: 80x25 characters at 0xB8000
- Graphics mode: 320x200 or 640x480
- 16 colors in text mode

**Virtual Memory**
- Abstraction where each process has own address space
- Uses paging to map virtual to physical
- Benefits: isolation, protection, more memory than RAM

---

## X

**x86**
- Instruction set architecture by Intel
- 32-bit (we're targeting i686)
- x86-64 is 64-bit version
- Most common desktop/laptop CPU architecture

---

## Common Acronyms Quick Reference

| Acronym | Meaning |
|---------|---------|
| ATA | Advanced Technology Attachment |
| BIOS | Basic Input/Output System |
| DMA | Direct Memory Access |
| ELF | Executable and Linkable Format |
| FAT | File Allocation Table |
| GCC | GNU Compiler Collection |
| GDB | GNU Debugger |
| GDT | Global Descriptor Table |
| GUI | Graphical User Interface |
| IDT | Interrupt Descriptor Table |
| IPC | Inter-Process Communication |
| IRQ | Interrupt Request |
| ISR | Interrupt Service Routine |
| LBA | Logical Block Addressing |
| MBR | Master Boot Record |
| MMIO | Memory-Mapped Input/Output |
| OS | Operating System |
| PCB | Process Control Block |
| PCI | Peripheral Component Interconnect |
| PIC | Programmable Interrupt Controller |
| PIO | Programmed Input/Output |
| PIT | Programmable Interval Timer |
| RAM | Random Access Memory |
| RTC | Real-Time Clock |
| TLB | Translation Lookaside Buffer |
| TSS | Task State Segment |
| VBE | VESA BIOS Extensions |
| VFS | Virtual File System |
| VGA | Video Graphics Array |

---

## Need More Info?

For detailed explanations of any concept:
1. Check ARCHITECTURE.md for diagrams
2. Search OSDev.org wiki
3. Read Intel x86 manuals
4. Ask for clarification!

---

This glossary will grow as we progress through development.
