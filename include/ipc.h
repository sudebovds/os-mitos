#ifndef _IPC_H
#define _IPC_H

#include <stdint.h>

// IPC message types
#define IPC_TYPE_REQUEST  0x01
#define IPC_TYPE_RESPONSE 0x02
#define IPC_TYPE_NOTIFY   0x03

// Well-known ports
#define PORT_MEMORY_MANAGER  1
#define PORT_VFS_SERVER     2
#define PORT_DEVICE_MANAGER 3

// Message structure
typedef struct {
    uint32_t sender_pid;
    uint32_t receiver_port;
    uint32_t type;
    uint32_t length;
    uint8_t data[256];
} ipc_message_t;

#endif /* _IPC_H */