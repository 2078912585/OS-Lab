#include "syscall.h"
#include "proc.h"
#include "printk.h"


uint64_t sys_write(unsigned int fd, const char* buf, size_t count){
    //标准输出
    if(fd==1){
        for(uint64_t i=0;i<count;i++){
            printk("%c",buf[i]);
        }
    }else{
        return -1; 
    }
    return count;
}
uint64_t sys_getpid(){
    return current->pid;
}