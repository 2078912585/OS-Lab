    .extern start_kernel
    .extern sbi_set_timer
    .extern get_cycles
    .extern mm_init
    .extern task_init
    .extern setup_vm
    .extern early_pgtbl
    .extern setup_vm_final
    .extern PA2VA_OFFSET
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶

    call setup_vm  #映射
    call relocate
    call mm_init #初始化内存管理系统
    call task_init #初始化线程数据结构 
    call setup_vm_final
    
    # set stvec = _traps
    la t0,_traps
    csrw stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
    csrs sie,t0

    # set first time interrupt
    call get_cycles
    li t0,10000000
    add a0,a0,t0
    call sbi_set_timer

    # set sstatus[SIE]=1
    li t0,(1<<1)
    csrs sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel

    .globl relocate
relocate:
    li t0,0x80000000
    li t1,0xffffffdf
    slli t1,t1,32
    or t0,t0,t1

    add ra,ra,t0     # set ra = ra + PA2VA_OFFSET
    add sp,sp,t0     # set sp = sp + PA2VA_OFFSET 

    sfence.vma zero,zero        # need a fence to ensure the new translations are in use

    # set satp
    la t0,early_pgtbl
    srli t0,t0,12
    li t1,(8<<60)               # MODE=8 Sv39
    or t0,t0,t1
    csrw satp,t0
    
    sfence.vma zero, zero
    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # 分配 4KiB 栈空间

    .globl boot_stack_top
boot_stack_top:
