    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    # 判断是否来自用户态
    csrr t0,sscratch
    beqz t0,no_swap_first
    csrw sscratch,sp
    mv sp,t0

no_swap_first:
    addi sp,sp,-34*8   # 开辟栈空间
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
    sd x1,1*8(sp)
    sd x2,2*8(sp)
    sd x3,3*8(sp)
    sd x4,4*8(sp)
    sd x5,5*8(sp)
    sd x6,6*8(sp)
    sd x7,7*8(sp)
    sd x8,8*8(sp)
    sd x9,9*8(sp)
    sd x10,10*8(sp)
    sd x11,11*8(sp)
    sd x12,12*8(sp)
    sd x13,13*8(sp)
    sd x14,14*8(sp)
    sd x15,15*8(sp)
    sd x16,16*8(sp)
    sd x17,17*8(sp)
    sd x18,18*8(sp)
    sd x19,19*8(sp)
    sd x20,20*8(sp)
    sd x21,21*8(sp)
    sd x22,22*8(sp)
    sd x23,23*8(sp)
    sd x24,24*8(sp)
    sd x25,25*8(sp)
    sd x26,26*8(sp)
    sd x27,27*8(sp)
    sd x28,28*8(sp)
    sd x29,29*8(sp)
    sd x30,30*8(sp)
    sd x31,31*8(sp)
    csrr t0,sepc
    sd t0,32*8(sp)
    csrr t0,sstatus
    sd t0,33*8(sp)

    # call trap_handler
    csrr a0,scause
    csrr a1,sepc
    mv a2,sp
    call trap_handler

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
    csrw sepc,t0

    ld x31,31*8(sp)
    ld x30,30*8(sp)
    ld x29,29*8(sp)
    ld x28,28*8(sp)
    ld x27,27*8(sp)
    ld x26,26*8(sp)
    ld x25,25*8(sp)
    ld x24,24*8(sp)
    ld x23,23*8(sp)
    ld x22,22*8(sp)
    ld x21,21*8(sp)
    ld x20,20*8(sp)
    ld x19,19*8(sp)
    ld x18,18*8(sp)
    ld x17,17*8(sp)
    ld x16,16*8(sp)
    ld x15,15*8(sp)
    ld x14,14*8(sp)
    ld x13,13*8(sp)
    ld x12,12*8(sp)
    ld x11,11*8(sp)
    ld x10,10*8(sp)
    ld x9,9*8(sp)
    ld x8,8*8(sp)
    ld x7,7*8(sp)
    ld x6,6*8(sp)
    ld x5,5*8(sp)
    ld x4,4*8(sp)
    ld x3,3*8(sp)
    ld x1,1*8(sp)
    ld x0,0*8(sp)
    ld x2,2*8(sp)
    addi sp,sp,34*8   # 释放栈空间

    # 如果为用户态（再次交换）
    csrr t0,sscratch
    beqz t0,no_swap_last
    csrw sscratch,sp
    mv sp,t0

no_swap_last:
    # return from trap
    sret

    .extern dummy
    .globl __dummy
__dummy:
    # 交换寄存器值
    csrr t0,sscratch
    csrw sscratch,sp
    mv sp,t0

    la t0,dummy
    csrw sepc,t0
    sret

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
    sd s1,56(a0)
    sd s2,64(a0)
    sd s3,72(a0)
    sd s4,80(a0)
    sd s5,88(a0)
    sd s6,96(a0)
    sd s7,104(a0)
    sd s8,112(a0)
    sd s9,120(a0)
    sd s10,128(a0)
    sd s11,136(a0)

    # 保存 sepc ,sstatus,sscratch
    csrr t0,sepc
    sd t0,152(a0)
    csrr t0,sstatus
    sd t0,160(a0)
    csrr t0,sscratch
    sd t0,168(a0)

    # 切换页表
    li t0,0x80000000
    li t1,0xffffffdf
    slli t1,t1,32
    or t0,t0,t1         # PA2VA_OFFSET=0xffffffdf80000000
    ld t1,176(a1)       # next->pgd
    sub t1,t1,t0        # 物理地址
    srli t1,t1,12       # PPN
    li t0,(8<<60)       # MOOD=8 SV39
    or t0,t0,t1
    csrw satp,t0
    sfence.vma zero, zero

    # 恢复下一个进程 sepc,sstatus,sscratch
    ld t0,152(a1)
    csrw sepc,t0
    ld t0,160(a1)
    csrw sstatus,t0
    ld t0,168(a1)
    csrw sscratch,t0


    #next是否为第一次调度
    ld t0,144(a1)
    beqz t0,first_schedule

    #恢复下一个进程上下文
    ld ra,32(a1)
    ld sp,40(a1)
    ld s0,48(a1)
    ld s1,56(a1)
    ld s2,64(a1)
    ld s3,72(a1)
    ld s4,80(a1)
    ld s5,88(a1)
    ld s6,96(a1)
    ld s7,104(a1)
    ld s8,112(a1)
    ld s9,120(a1)
    ld s10,128(a1)
    ld s11,136(a1)


    j switch_done

first_schedule:
    ld ra,32(a1)
    ld sp,40(a1)
    j switch_done

switch_done:
    ret
