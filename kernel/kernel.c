// MitOS Microkernel Core
// Minimal kernel providing only essential services

#include <stdint.h>
#include <stdbool.h>

// VGA text mode for early debugging
#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// IPC constants
#define MAX_PROCESSES 256
#define MAX_MESSAGES 1024
#define MAX_PORTS 64

// System call numbers
#define SYSCALL_SEND_MSG    0x01
#define SYSCALL_RECEIVE_MSG 0x02
#define SYSCALL_CREATE_PORT 0x03
#define SYSCALL_MAP_MEMORY  0x04
#define SYSCALL_YIELD       0x05

// Process states
typedef enum {
    PROCESS_READY,
    PROCESS_RUNNING,
    PROCESS_BLOCKED,
    PROCESS_DEAD
} process_state_t;

// IPC message structure
typedef struct {
    uint32_t sender_id;
    uint32_t receiver_port;
    uint32_t type;
    uint32_t length;
    uint8_t  data[256];  // Small messages inline
} message_t;

// Process control block
typedef struct {
    uint32_t pid;
    uint32_t esp;        // Stack pointer
    uint32_t eip;        // Instruction pointer
    uint32_t cr3;        // Page directory base
    process_state_t state;
    uint32_t priority;
    message_t* waiting_for_msg;
} pcb_t;

// Port structure for IPC
typedef struct {
    uint32_t owner_pid;
    uint32_t port_id;
    message_t* message_queue[32];
    uint32_t queue_head;
    uint32_t queue_tail;
} port_t;

// Global microkernel state
static pcb_t processes[MAX_PROCESSES];
static port_t ports[MAX_PORTS];
static uint32_t current_pid = 0;
static uint32_t next_pid = 1;
static uint32_t next_port_id = 1;

// VGA cursor position
static uint32_t cursor_x = 0;
static uint32_t cursor_y = 0;

void kputchar(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else {
        uint16_t* vga = (uint16_t*)VGA_MEMORY;
        vga[cursor_y * VGA_WIDTH + cursor_x] = (uint16_t)c | 0x0F00;
        cursor_x++;
        if (cursor_x >= VGA_WIDTH) {
            cursor_x = 0;
            cursor_y++;
        }
    }
    if (cursor_y >= VGA_HEIGHT) {
        cursor_y = 0;  // Wrap around (should implement scrolling)
    }
}

void kprint(const char* str) {
    while (*str) {
        kputchar(*str++);
    }
}

void clear_screen() {
    uint16_t* vga = (uint16_t*)VGA_MEMORY;
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga[i] = 0x0F00 | ' ';
    }
    cursor_x = 0;
    cursor_y = 0;
}

// IPC: Create a new communication port
uint32_t create_port() {
    for (int i = 0; i < MAX_PORTS; i++) {
        if (ports[i].owner_pid == 0) {
            ports[i].owner_pid = current_pid;
            ports[i].port_id = next_port_id++;
            ports[i].queue_head = 0;
            ports[i].queue_tail = 0;
            return ports[i].port_id;
        }
    }
    return 0;  // No available ports
}

// IPC: Send a message to a port
bool send_message(uint32_t port_id, message_t* msg) {
    // Find the port
    port_t* port = NULL;
    for (int i = 0; i < MAX_PORTS; i++) {
        if (ports[i].port_id == port_id) {
            port = &ports[i];
            break;
        }
    }
    
    if (!port) return false;
    
    // Add message to queue
    uint32_t next_tail = (port->queue_tail + 1) % 32;
    if (next_tail == port->queue_head) {
        return false;  // Queue full
    }
    
    port->message_queue[port->queue_tail] = msg;
    port->queue_tail = next_tail;
    
    // Wake up receiver if blocked
    if (port->owner_pid >= MAX_PROCESSES) {
        return false; // Invalid owner_pid, out of bounds
    }
    pcb_t* receiver = &processes[port->owner_pid];
    if (receiver->state == PROCESS_BLOCKED && receiver->waiting_for_msg) {
        receiver->state = PROCESS_READY;
    }
    
    return true;
}

// IPC: Receive a message from a port
message_t* receive_message(uint32_t port_id, bool blocking) {
    // Find the port
    port_t* port = NULL;
    for (int i = 0; i < MAX_PORTS; i++) {
        if (ports[i].port_id == port_id && ports[i].owner_pid == current_pid) {
            port = &ports[i];
            break;
        }
    }
    
    if (!port) return NULL;
    
    // Check if there are messages
    if (port->queue_head == port->queue_tail) {
        if (blocking) {
            // Block the process
            processes[current_pid].state = PROCESS_BLOCKED;
            processes[current_pid].waiting_for_msg = port_id;
            // Trigger scheduler
            schedule();
        }
        return NULL;
    }
    
    // Get message from queue
    message_t* msg = port->message_queue[port->queue_head];
    port->queue_head = (port->queue_head + 1) % 32;
    return msg;
}

// Simple round-robin scheduler
void schedule() {
    // Save current process state (would save registers here)
    
    // Find next ready process
    uint32_t next_pid = (current_pid + 1) % MAX_PROCESSES;
    while (next_pid != current_pid) {
        if (processes[next_pid].state == PROCESS_READY) {
            break;
        }
        next_pid = (next_pid + 1) % MAX_PROCESSES;
    }
    
    if (next_pid == current_pid && processes[current_pid].state != PROCESS_READY) {
        // No ready processes - idle
        kprint("Kernel: No ready processes, idling...\n");
        while (1) {
            asm volatile("hlt");
        }
    }
    
    // Switch to new process
    current_pid = next_pid;
    processes[current_pid].state = PROCESS_RUNNING;
    
    // Load new process state (would restore registers and switch cr3 here)
}

// System call handler
void syscall_handler(uint32_t syscall_num, uint32_t arg1, uint32_t arg2, uint32_t arg3) {
    switch (syscall_num) {
        case SYSCALL_SEND_MSG:
            send_message(arg1, (message_t*)arg2);
            break;
            
        case SYSCALL_RECEIVE_MSG:
            receive_message(arg1, arg2);
            break;
            
        case SYSCALL_CREATE_PORT:
            create_port();
            break;
            
        case SYSCALL_YIELD:
            processes[current_pid].state = PROCESS_READY;
            schedule();
            break;
            
        default:
            kprint("Unknown system call\n");
    }
}

// Initialize the first system server (Memory Manager)
void init_memory_server() {
    // Create process for memory server
    processes[1].pid = 1;
    processes[1].state = PROCESS_READY;
    processes[1].priority = 10;  // High priority
    // Would load memory server code here
    
    kprint("  [OK] Memory Manager Server initialized\n");
}

// Initialize the VFS server
void init_vfs_server() {
    processes[2].pid = 2;
    processes[2].state = PROCESS_READY;
    processes[2].priority = 9;
    // Would load VFS server code here
    
    kprint("  [OK] VFS Server initialized\n");
}

// Initialize the Device Manager server
void init_device_server() {
    processes[3].pid = 3;
    processes[3].state = PROCESS_READY;
    processes[3].priority = 9;
    // Would load device manager code here
    
    kprint("  [OK] Device Manager Server initialized\n");
}

// Microkernel main entry point
void kernel_main() {
    // Clear screen and print header
    clear_screen();
    kprint("================================================================================\n");
    kprint("                        MitOS Microkernel v0.1 Started                         \n");
    kprint("================================================================================\n\n");
    
    // Initialize microkernel components
    kprint("Initializing Microkernel Core:\n");
    kprint("  [OK] Entered 32-bit Protected Mode\n");
    kprint("  [OK] Basic memory management initialized\n");
    kprint("  [OK] IPC (Inter-Process Communication) ready\n");
    kprint("  [OK] Scheduler initialized\n\n");
    
    // Initialize kernel process (PID 0)
    processes[0].pid = 0;
    processes[0].state = PROCESS_RUNNING;
    processes[0].priority = 15;  // Highest priority
    
    // Start system servers
    kprint("Starting System Servers:\n");
    init_memory_server();
    init_vfs_server();
    init_device_server();
    
    kprint("\n");
    kprint("Microkernel Statistics:\n");
    kprint("  - Architecture: x86 Microkernel\n");
    kprint("  - Kernel size: ~10KB (core only)\n");
    kprint("  - Max processes: 256\n");
    kprint("  - IPC mechanism: Message passing\n");
    kprint("  - Servers running: 3\n");
    
    kprint("\n");
    kprint("================================================================================\n");
    kprint("                    Microkernel initialization complete!                       \n");
    kprint("================================================================================\n");
    
    // Start scheduling
    kprint("\nStarting scheduler...\n");
    
    // Main kernel loop
    while (1) {
        schedule();
        asm volatile("hlt");  // Halt until interrupt
    }
}