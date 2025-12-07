#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret  ret;
    asm volatile(
        //将 eid（Extension ID）放入寄存器 a7 中，
        // fid（Function ID）放入寄存器 a6 中，
        // 将 arg[0-5] 放入寄存器 a[0-5] 中。
        "mv a7,%[eid]\n"
        "mv a6,%[fid]\n"
        "mv a0,%[arg0]\n"
        "mv a1,%[arg1]\n"
        "mv a2,%[arg2]\n"
        "mv a3,%[arg3]\n"
        "mv a4,%[arg4]\n"
        "mv a5,%[arg5]\n"
        //执行 ecall 指令,进入 M 模式
        "ecall\n"
        //获取返回值
        "mv %[error],a0\n"
        "mv %[value],a1"
        //输出操作数
        : [error] "=r" (ret.error), [value] "=r" (ret.value)
        //输入操作数
        : [eid] "r" (eid), [fid] "r" (fid),
          [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2),
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
}

struct sbiret sbi_set_timer(uint64_t stime_value){
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
}


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
}