#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "syscall.h"

void trap_handler(uint64_t scause, uint64_t sepc,struct pt_regs *regs) {
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
        uint64_t interrupt_code = scause & ~(1UL << 63);
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
            do_timer();
        } else {
            printk("other interrupt: %d\n", interrupt_code);
        }
    } else {
        uint64_t exception_code = scause;
        //用户态系统调用
        if(exception_code==8){
            uint64_t a7=regs->x[17]; //系统调用号
            uint64_t a0=regs->x[10]; //参数1
            uint64_t a1=regs->x[11]; //参数2
            uint64_t a2=regs->x[12]; //参数3
            uint64_t ret=-1;
            if(a7==SYS_write){
                ret=sys_write((unsigned int)a0,(const char *)a1,(size_t)a2);
            }else if(a7==SYS_getpid){
                ret=sys_getpid();
            }else{
                printk("unknown syscall %d\n",a7);
            }
            regs->x[10]=ret; //将返回值写入 a0
            regs->sepc+=4; //指令地址后移
            return;
        }

        printk("exception: %d\n", exception_code);
    }   
}