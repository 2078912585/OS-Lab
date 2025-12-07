#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "stdint.h"
#include "stdlib.h"
#include <stddef.h>

#define SYS_write 64
#define SYS_getpid 172

struct pt_regs{
    uint64_t x[32];
    uint64_t sepc,sstatus;
};

uint64_t sys_write(unsigned int fd, const char* buf, size_t count);
uint64_t sys_getpid();

#endif