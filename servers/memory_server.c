// Memory Manager Server for MitOS Microkernel
// Handles high-level memory operations

#include <stdint.h>
#include <stdbool.h>

#define MEMORY_SERVER_PORT 1
#define PAGE_SIZE 4096

// Memory server message types

enum {
    MEM_ALLOCATE,
    MEM_FREE,
    MEM_MAP_SHARED,
    MEM_GET_INFO
};

typedef struct {
    uint32_t total_memory;
    uint32_t free_memory;
    uint32_t used_memory;
} mem_info_t;

typedef struct {
    uint32_t type;
    uint32_t size;
    void* ptr;
    uint32_t sender;
    union {
        void* ptr;
        mem_info_t info;
    } response;
} mem_request_t;

// Simple heap management

typedef struct heap_block{
    uint32_t size;
    bool free;
    struct heap_block* next;
} heap_block_t;

static heap_block_t* heap_start = NULL;
static uint32_t total_heap_size = 0;

// Initialize memory server

void memory_server_init(){
    // Register with microkernel

    uint32_t port = syscall_create_port(MEMORY_SERVER_PORT);
    
    // Check if port creation succeeded (assuming 0 or negative value indicates error)
    if (port == 0 || port == (uint32_t)-1) {
        // Port creation failed - halt or handle error
        while(1); // Halt execution
    }

    // Initialize heap at a specific address

    heap_start = (heap_block_t*)0x2000000; // 2MB mark
    heap_start->size = 0x100000; // 1MB initial heap

    heap_start->free = true;
    heap_start->next = NULL;
    total_heap_size = 0x100000;
};

// Allocate memory

void* memory_allocator(uint32_t size){
    heap_block_t* current = heap_start;

    while(current != NULL){
        if(current->free && current->size >= size){
            // Found a suitable block

            if(current->size > size + sizeof(heap_block_t)){
                // Split the block

                heap_block_t* new_block = (heap_block_t*)((uint8_t*)current + sizeof(heap_block_t) + size);
                new_block->size = current->size - size - sizeof(heap_block_t);
                new_block->free = true;
                new_block->next = current->next;

                current->size = size;
                current->next = new_block;
            }

            current->free = false;
            return (void*)((uint8_t*)current + sizeof(heap_block_t));
        }
        current = current->next;
    }
    return NULL; // No suitable block found
};

// Free memory

void mem_free(void* ptr){
    if(ptr == NULL) return;

    heap_block_t* block = (heap_block_t*)((uint8_t*)ptr - sizeof(heap_block_t));
    block->free = true;

    // Coalesce adjacent free blocks

    heap_block_t* current = heap_start;
    while(current != NULL && current->next != NULL){
        if(current->free && current->next->free){
            current->size += sizeof(heap_block_t) + current->next->size;
            current->next = current->next->next;
        } else {
            current = current->next;
        }
    }
};

// Get memory information

mem_info_t get_memory_info(){
    mem_info_t info;
    info.total_memory = total_heap_size;
    info.used_memory = 0;

    heap_block_t* current = heap_start;
    while(current != NULL){
        if(!current->free){
            info.used_memory += current->size;
        }
        current = current->next;
    }
    info.free_memory = info.total_memory - info.used_memory;
    return info;
};

// Main memory server loop
void memory_server_main(){
    memory_server_init();

    while(1){
        // Wait for memory requests

        mem_request_t* request = (mem_request_t*)syscall_receive_message(MEMORY_SERVER_PORT, true);

        if(request == NULL) continue;

        switch(request->type){
            case MEM_ALLOCATE:{
                void* addr = memory_allocator(request->size);
                // Return allocated address
                syscall_send_response(request->sender, addr);
                break;
            }
            case MEM_FREE:
                mem_free(request->ptr);
                syscall_send_response(request->sender, 0);
                break;
            case MEM_GET_INFO:
                mem_info_t info = get_memory_info();
                syscall_send_response(request->sender, &info);
                break;
            default:
                // Unknown request
                syscall_send_response(request->sender, -1);
        }
    }
};