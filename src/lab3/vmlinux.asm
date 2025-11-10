
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm_final
    .extern PA2VA_OFFSET
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶
ffffffe000200000:	00006117          	auipc	sp,0x6
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm  #映射
ffffffe000200008:	5c1000ef          	jal	ra,ffffffe000200dc8 <setup_vm>
    call relocate
ffffffe00020000c:	044000ef          	jal	ra,ffffffe000200050 <relocate>
    call mm_init #初始化内存管理系统
ffffffe000200010:	418000ef          	jal	ra,ffffffe000200428 <mm_init>
    call task_init #初始化线程数据结构 
ffffffe000200014:	458000ef          	jal	ra,ffffffe00020046c <task_init>
    call setup_vm_final
ffffffe000200018:	098010ef          	jal	ra,ffffffe0002010b0 <setup_vm_final>
    
    # set stvec = _traps
    la t0,_traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	08028293          	addi	t0,t0,128 # ffffffe00020009c <_traps>
    csrw stvec,t0
ffffffe000200024:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
ffffffe000200028:	02000293          	li	t0,32
    csrs sie,t0
ffffffe00020002c:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
ffffffe000200030:	230000ef          	jal	ra,ffffffe000200260 <get_cycles>
    li t0,10000000
ffffffe000200034:	009892b7          	lui	t0,0x989
ffffffe000200038:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
ffffffe00020003c:	00550533          	add	a0,a0,t0
    call sbi_set_timer
ffffffe000200040:	32d000ef          	jal	ra,ffffffe000200b6c <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
ffffffe000200044:	00200293          	li	t0,2
    csrs sstatus,t0
ffffffe000200048:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
ffffffe00020004c:	1e80106f          	j	ffffffe000201234 <start_kernel>

ffffffe000200050 <relocate>:

    .globl relocate
relocate:
    li t0,0x80000000
ffffffe000200050:	0010029b          	addiw	t0,zero,1
ffffffe000200054:	01f29293          	slli	t0,t0,0x1f
    li t1,0xffffffdf
ffffffe000200058:	0010031b          	addiw	t1,zero,1
ffffffe00020005c:	02031313          	slli	t1,t1,0x20
ffffffe000200060:	fdf30313          	addi	t1,t1,-33
    slli t1,t1,32
ffffffe000200064:	02031313          	slli	t1,t1,0x20
    or t0,t0,t1
ffffffe000200068:	0062e2b3          	or	t0,t0,t1

    add ra,ra,t0     # set ra = ra + PA2VA_OFFSET
ffffffe00020006c:	005080b3          	add	ra,ra,t0
    add sp,sp,t0     # set sp = sp + PA2VA_OFFSET 
ffffffe000200070:	00510133          	add	sp,sp,t0

    sfence.vma zero,zero        # need a fence to ensure the new translations are in use
ffffffe000200074:	12000073          	sfence.vma

    # set satp
    la t0,early_pgtbl
ffffffe000200078:	00008297          	auipc	t0,0x8
ffffffe00020007c:	f8828293          	addi	t0,t0,-120 # ffffffe000208000 <early_pgtbl>
    srli t0,t0,12
ffffffe000200080:	00c2d293          	srli	t0,t0,0xc
    li t1,(8<<60)               # MODE=8 Sv39
ffffffe000200084:	fff0031b          	addiw	t1,zero,-1
ffffffe000200088:	03f31313          	slli	t1,t1,0x3f
    or t0,t0,t1
ffffffe00020008c:	0062e2b3          	or	t0,t0,t1
    csrw satp,t0
ffffffe000200090:	18029073          	csrw	satp,t0
    
    sfence.vma zero, zero
ffffffe000200094:	12000073          	sfence.vma
    ret
ffffffe000200098:	00008067          	ret

ffffffe00020009c <_traps>:
    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    addi sp,sp,-33*8   # 开辟栈空间
ffffffe00020009c:	ef810113          	addi	sp,sp,-264 # ffffffe000205ef8 <_sbss+0xef8>
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
ffffffe0002000a0:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)
ffffffe0002000a4:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)
ffffffe0002000a8:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)
ffffffe0002000ac:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)
ffffffe0002000b0:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)
ffffffe0002000b4:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
ffffffe0002000b8:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
ffffffe0002000bc:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)
ffffffe0002000c0:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)
ffffffe0002000c4:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)
ffffffe0002000c8:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
ffffffe0002000cc:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
ffffffe0002000d0:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
ffffffe0002000d4:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
ffffffe0002000d8:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
ffffffe0002000dc:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
ffffffe0002000e0:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
ffffffe0002000e4:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)
ffffffe0002000e8:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
ffffffe0002000ec:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
ffffffe0002000f0:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
ffffffe0002000f4:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
ffffffe0002000f8:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
ffffffe0002000fc:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
ffffffe000200100:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
ffffffe000200104:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
ffffffe000200108:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
ffffffe00020010c:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)
ffffffe000200110:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
ffffffe000200114:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
ffffffe000200118:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
ffffffe00020011c:	0ff13c23          	sd	t6,248(sp)
    csrr t0,sepc
ffffffe000200120:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
ffffffe000200124:	10513023          	sd	t0,256(sp)

    # call trap_handler
    csrr a0,scause
ffffffe000200128:	14202573          	csrr	a0,scause
    csrr a1,sepc
ffffffe00020012c:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe000200130:	40d000ef          	jal	ra,ffffffe000200d3c <trap_handler>

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
ffffffe000200134:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
ffffffe000200138:	14129073          	csrw	sepc,t0

    ld x31,31*8(sp)
ffffffe00020013c:	0f813f83          	ld	t6,248(sp)
    ld x30,30*8(sp)
ffffffe000200140:	0f013f03          	ld	t5,240(sp)
    ld x29,29*8(sp)
ffffffe000200144:	0e813e83          	ld	t4,232(sp)
    ld x28,28*8(sp)
ffffffe000200148:	0e013e03          	ld	t3,224(sp)
    ld x27,27*8(sp)
ffffffe00020014c:	0d813d83          	ld	s11,216(sp)
    ld x26,26*8(sp)
ffffffe000200150:	0d013d03          	ld	s10,208(sp)
    ld x25,25*8(sp)
ffffffe000200154:	0c813c83          	ld	s9,200(sp)
    ld x24,24*8(sp)
ffffffe000200158:	0c013c03          	ld	s8,192(sp)
    ld x23,23*8(sp)
ffffffe00020015c:	0b813b83          	ld	s7,184(sp)
    ld x22,22*8(sp)
ffffffe000200160:	0b013b03          	ld	s6,176(sp)
    ld x21,21*8(sp)
ffffffe000200164:	0a813a83          	ld	s5,168(sp)
    ld x20,20*8(sp)
ffffffe000200168:	0a013a03          	ld	s4,160(sp)
    ld x19,19*8(sp)
ffffffe00020016c:	09813983          	ld	s3,152(sp)
    ld x18,18*8(sp)
ffffffe000200170:	09013903          	ld	s2,144(sp)
    ld x17,17*8(sp)
ffffffe000200174:	08813883          	ld	a7,136(sp)
    ld x16,16*8(sp)
ffffffe000200178:	08013803          	ld	a6,128(sp)
    ld x15,15*8(sp)
ffffffe00020017c:	07813783          	ld	a5,120(sp)
    ld x14,14*8(sp)
ffffffe000200180:	07013703          	ld	a4,112(sp)
    ld x13,13*8(sp)
ffffffe000200184:	06813683          	ld	a3,104(sp)
    ld x12,12*8(sp)
ffffffe000200188:	06013603          	ld	a2,96(sp)
    ld x11,11*8(sp)
ffffffe00020018c:	05813583          	ld	a1,88(sp)
    ld x10,10*8(sp)
ffffffe000200190:	05013503          	ld	a0,80(sp)
    ld x9,9*8(sp)
ffffffe000200194:	04813483          	ld	s1,72(sp)
    ld x8,8*8(sp)
ffffffe000200198:	04013403          	ld	s0,64(sp)
    ld x7,7*8(sp)
ffffffe00020019c:	03813383          	ld	t2,56(sp)
    ld x6,6*8(sp)
ffffffe0002001a0:	03013303          	ld	t1,48(sp)
    ld x5,5*8(sp)
ffffffe0002001a4:	02813283          	ld	t0,40(sp)
    ld x4,4*8(sp)
ffffffe0002001a8:	02013203          	ld	tp,32(sp)
    ld x3,3*8(sp)
ffffffe0002001ac:	01813183          	ld	gp,24(sp)
    ld x1,1*8(sp)
ffffffe0002001b0:	00813083          	ld	ra,8(sp)
    ld x0,0*8(sp)
ffffffe0002001b4:	00013003          	ld	zero,0(sp)
    ld x2,2*8(sp)
ffffffe0002001b8:	01013103          	ld	sp,16(sp)
    addi sp,sp,33*8   # 释放栈空间
ffffffe0002001bc:	10810113          	addi	sp,sp,264

    # return from trap
    sret
ffffffe0002001c0:	10200073          	sret

ffffffe0002001c4 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    la t0,dummy
ffffffe0002001c4:	00000297          	auipc	t0,0x0
ffffffe0002001c8:	4d828293          	addi	t0,t0,1240 # ffffffe00020069c <dummy>
    csrw sepc,t0
ffffffe0002001cc:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001d0:	10200073          	sret

ffffffe0002001d4 <__switch_to>:

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
ffffffe0002001d4:	02153023          	sd	ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
ffffffe0002001d8:	02253423          	sd	sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
ffffffe0002001dc:	02853823          	sd	s0,48(a0)
    sd s1,56(a0)
ffffffe0002001e0:	02953c23          	sd	s1,56(a0)
    sd s2,64(a0)
ffffffe0002001e4:	05253023          	sd	s2,64(a0)
    sd s3,72(a0)
ffffffe0002001e8:	05353423          	sd	s3,72(a0)
    sd s4,80(a0)
ffffffe0002001ec:	05453823          	sd	s4,80(a0)
    sd s5,88(a0)
ffffffe0002001f0:	05553c23          	sd	s5,88(a0)
    sd s6,96(a0)
ffffffe0002001f4:	07653023          	sd	s6,96(a0)
    sd s7,104(a0)
ffffffe0002001f8:	07753423          	sd	s7,104(a0)
    sd s8,112(a0)
ffffffe0002001fc:	07853823          	sd	s8,112(a0)
    sd s9,120(a0)
ffffffe000200200:	07953c23          	sd	s9,120(a0)
    sd s10,128(a0)
ffffffe000200204:	09a53023          	sd	s10,128(a0)
    sd s11,136(a0)
ffffffe000200208:	09b53423          	sd	s11,136(a0)

    #next是否为第一次调度
    ld t0,144(a1)
ffffffe00020020c:	0905b283          	ld	t0,144(a1)
    beqz t0,first_schedule
ffffffe000200210:	04028063          	beqz	t0,ffffffe000200250 <first_schedule>
    #恢复下一个进程上下文

    ld ra,32(a1)
ffffffe000200214:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe000200218:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
ffffffe00020021c:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
ffffffe000200220:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
ffffffe000200224:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
ffffffe000200228:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
ffffffe00020022c:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
ffffffe000200230:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
ffffffe000200234:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
ffffffe000200238:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
ffffffe00020023c:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
ffffffe000200240:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
ffffffe000200244:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
ffffffe000200248:	0885bd83          	ld	s11,136(a1)
    j switch_done
ffffffe00020024c:	0100006f          	j	ffffffe00020025c <switch_done>

ffffffe000200250 <first_schedule>:

first_schedule:
    ld ra,32(a1)
ffffffe000200250:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe000200254:	0285b103          	ld	sp,40(a1)
    j switch_done
ffffffe000200258:	0040006f          	j	ffffffe00020025c <switch_done>

ffffffe00020025c <switch_done>:

switch_done:
    ret
ffffffe00020025c:	00008067          	ret

ffffffe000200260 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200260:	fe010113          	addi	sp,sp,-32
ffffffe000200264:	00813c23          	sd	s0,24(sp)
ffffffe000200268:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
ffffffe00020026c:	c01027f3          	rdtime	a5
ffffffe000200270:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
ffffffe000200274:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200278:	00078513          	mv	a0,a5
ffffffe00020027c:	01813403          	ld	s0,24(sp)
ffffffe000200280:	02010113          	addi	sp,sp,32
ffffffe000200284:	00008067          	ret

ffffffe000200288 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200288:	fe010113          	addi	sp,sp,-32
ffffffe00020028c:	00113c23          	sd	ra,24(sp)
ffffffe000200290:	00813823          	sd	s0,16(sp)
ffffffe000200294:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200298:	fc9ff0ef          	jal	ra,ffffffe000200260 <get_cycles>
ffffffe00020029c:	00050713          	mv	a4,a0
ffffffe0002002a0:	00004797          	auipc	a5,0x4
ffffffe0002002a4:	d6078793          	addi	a5,a5,-672 # ffffffe000204000 <TIMECLOCK>
ffffffe0002002a8:	0007b783          	ld	a5,0(a5)
ffffffe0002002ac:	00f707b3          	add	a5,a4,a5
ffffffe0002002b0:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
ffffffe0002002b4:	fe843503          	ld	a0,-24(s0)
ffffffe0002002b8:	0b5000ef          	jal	ra,ffffffe000200b6c <sbi_set_timer>
ffffffe0002002bc:	00000013          	nop
ffffffe0002002c0:	01813083          	ld	ra,24(sp)
ffffffe0002002c4:	01013403          	ld	s0,16(sp)
ffffffe0002002c8:	02010113          	addi	sp,sp,32
ffffffe0002002cc:	00008067          	ret

ffffffe0002002d0 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
ffffffe0002002d0:	fe010113          	addi	sp,sp,-32
ffffffe0002002d4:	00113c23          	sd	ra,24(sp)
ffffffe0002002d8:	00813823          	sd	s0,16(sp)
ffffffe0002002dc:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002e0:	00006797          	auipc	a5,0x6
ffffffe0002002e4:	d2878793          	addi	a5,a5,-728 # ffffffe000206008 <kmem>
ffffffe0002002e8:	0007b783          	ld	a5,0(a5)
ffffffe0002002ec:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002002f4:	0007b703          	ld	a4,0(a5)
ffffffe0002002f8:	00006797          	auipc	a5,0x6
ffffffe0002002fc:	d1078793          	addi	a5,a5,-752 # ffffffe000206008 <kmem>
ffffffe000200300:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
ffffffe000200304:	00001637          	lui	a2,0x1
ffffffe000200308:	00000593          	li	a1,0
ffffffe00020030c:	fe843503          	ld	a0,-24(s0)
ffffffe000200310:	75d010ef          	jal	ra,ffffffe00020226c <memset>
    return (void *)r;
ffffffe000200314:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200318:	00078513          	mv	a0,a5
ffffffe00020031c:	01813083          	ld	ra,24(sp)
ffffffe000200320:	01013403          	ld	s0,16(sp)
ffffffe000200324:	02010113          	addi	sp,sp,32
ffffffe000200328:	00008067          	ret

ffffffe00020032c <kfree>:

void kfree(void *addr) {
ffffffe00020032c:	fd010113          	addi	sp,sp,-48
ffffffe000200330:	02113423          	sd	ra,40(sp)
ffffffe000200334:	02813023          	sd	s0,32(sp)
ffffffe000200338:	03010413          	addi	s0,sp,48
ffffffe00020033c:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
ffffffe000200340:	fd843783          	ld	a5,-40(s0)
ffffffe000200344:	00078693          	mv	a3,a5
ffffffe000200348:	fd840793          	addi	a5,s0,-40
ffffffe00020034c:	fffff737          	lui	a4,0xfffff
ffffffe000200350:	00e6f733          	and	a4,a3,a4
ffffffe000200354:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
ffffffe000200358:	fd843783          	ld	a5,-40(s0)
ffffffe00020035c:	00001637          	lui	a2,0x1
ffffffe000200360:	00000593          	li	a1,0
ffffffe000200364:	00078513          	mv	a0,a5
ffffffe000200368:	705010ef          	jal	ra,ffffffe00020226c <memset>

    r = (struct run *)addr;
ffffffe00020036c:	fd843783          	ld	a5,-40(s0)
ffffffe000200370:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200374:	00006797          	auipc	a5,0x6
ffffffe000200378:	c9478793          	addi	a5,a5,-876 # ffffffe000206008 <kmem>
ffffffe00020037c:	0007b703          	ld	a4,0(a5)
ffffffe000200380:	fe843783          	ld	a5,-24(s0)
ffffffe000200384:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe000200388:	00006797          	auipc	a5,0x6
ffffffe00020038c:	c8078793          	addi	a5,a5,-896 # ffffffe000206008 <kmem>
ffffffe000200390:	fe843703          	ld	a4,-24(s0)
ffffffe000200394:	00e7b023          	sd	a4,0(a5)

    return;
ffffffe000200398:	00000013          	nop
}
ffffffe00020039c:	02813083          	ld	ra,40(sp)
ffffffe0002003a0:	02013403          	ld	s0,32(sp)
ffffffe0002003a4:	03010113          	addi	sp,sp,48
ffffffe0002003a8:	00008067          	ret

ffffffe0002003ac <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe0002003ac:	fd010113          	addi	sp,sp,-48
ffffffe0002003b0:	02113423          	sd	ra,40(sp)
ffffffe0002003b4:	02813023          	sd	s0,32(sp)
ffffffe0002003b8:	03010413          	addi	s0,sp,48
ffffffe0002003bc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003c0:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe0002003c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002003c8:	000017b7          	lui	a5,0x1
ffffffe0002003cc:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002003d0:	00f70733          	add	a4,a4,a5
ffffffe0002003d4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003d8:	00f777b3          	and	a5,a4,a5
ffffffe0002003dc:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003e0:	01c0006f          	j	ffffffe0002003fc <kfreerange+0x50>
        kfree((void *)addr);
ffffffe0002003e4:	fe843503          	ld	a0,-24(s0)
ffffffe0002003e8:	f45ff0ef          	jal	ra,ffffffe00020032c <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f0:	000017b7          	lui	a5,0x1
ffffffe0002003f4:	00f707b3          	add	a5,a4,a5
ffffffe0002003f8:	fef43423          	sd	a5,-24(s0)
ffffffe0002003fc:	fe843703          	ld	a4,-24(s0)
ffffffe000200400:	000017b7          	lui	a5,0x1
ffffffe000200404:	00f70733          	add	a4,a4,a5
ffffffe000200408:	fd043783          	ld	a5,-48(s0)
ffffffe00020040c:	fce7fce3          	bgeu	a5,a4,ffffffe0002003e4 <kfreerange+0x38>
    }
}
ffffffe000200410:	00000013          	nop
ffffffe000200414:	00000013          	nop
ffffffe000200418:	02813083          	ld	ra,40(sp)
ffffffe00020041c:	02013403          	ld	s0,32(sp)
ffffffe000200420:	03010113          	addi	sp,sp,48
ffffffe000200424:	00008067          	ret

ffffffe000200428 <mm_init>:

void mm_init(void) {
ffffffe000200428:	ff010113          	addi	sp,sp,-16
ffffffe00020042c:	00113423          	sd	ra,8(sp)
ffffffe000200430:	00813023          	sd	s0,0(sp)
ffffffe000200434:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)(PHY_END+PA2VA_OFFSET));
ffffffe000200438:	c0100793          	li	a5,-1023
ffffffe00020043c:	01b79593          	slli	a1,a5,0x1b
ffffffe000200440:	00009517          	auipc	a0,0x9
ffffffe000200444:	bc050513          	addi	a0,a0,-1088 # ffffffe000209000 <_ekernel>
ffffffe000200448:	f65ff0ef          	jal	ra,ffffffe0002003ac <kfreerange>
    printk("...mm_init done!\n");
ffffffe00020044c:	00003517          	auipc	a0,0x3
ffffffe000200450:	bb450513          	addi	a0,a0,-1100 # ffffffe000203000 <_srodata>
ffffffe000200454:	4f9010ef          	jal	ra,ffffffe00020214c <printk>
}
ffffffe000200458:	00000013          	nop
ffffffe00020045c:	00813083          	ld	ra,8(sp)
ffffffe000200460:	00013403          	ld	s0,0(sp)
ffffffe000200464:	01010113          	addi	sp,sp,16
ffffffe000200468:	00008067          	ret

ffffffe00020046c <task_init>:
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

extern void __dummy();

void task_init() {
ffffffe00020046c:	fe010113          	addi	sp,sp,-32
ffffffe000200470:	00113c23          	sd	ra,24(sp)
ffffffe000200474:	00813823          	sd	s0,16(sp)
ffffffe000200478:	02010413          	addi	s0,sp,32
    srand(2024);
ffffffe00020047c:	7e800513          	li	a0,2024
ffffffe000200480:	54d010ef          	jal	ra,ffffffe0002021cc <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
ffffffe000200484:	e4dff0ef          	jal	ra,ffffffe0002002d0 <kalloc>
ffffffe000200488:	00050713          	mv	a4,a0
ffffffe00020048c:	00006797          	auipc	a5,0x6
ffffffe000200490:	b8478793          	addi	a5,a5,-1148 # ffffffe000206010 <idle>
ffffffe000200494:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200498:	00006797          	auipc	a5,0x6
ffffffe00020049c:	b7878793          	addi	a5,a5,-1160 # ffffffe000206010 <idle>
ffffffe0002004a0:	0007b783          	ld	a5,0(a5)
ffffffe0002004a4:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe0002004a8:	00006797          	auipc	a5,0x6
ffffffe0002004ac:	b6878793          	addi	a5,a5,-1176 # ffffffe000206010 <idle>
ffffffe0002004b0:	0007b783          	ld	a5,0(a5)
ffffffe0002004b4:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe0002004b8:	00006797          	auipc	a5,0x6
ffffffe0002004bc:	b5878793          	addi	a5,a5,-1192 # ffffffe000206010 <idle>
ffffffe0002004c0:	0007b783          	ld	a5,0(a5)
ffffffe0002004c4:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe0002004c8:	00006797          	auipc	a5,0x6
ffffffe0002004cc:	b4878793          	addi	a5,a5,-1208 # ffffffe000206010 <idle>
ffffffe0002004d0:	0007b783          	ld	a5,0(a5)
ffffffe0002004d4:	0007bc23          	sd	zero,24(a5)
    idle->thread.first_schedule=0;
ffffffe0002004d8:	00006797          	auipc	a5,0x6
ffffffe0002004dc:	b3878793          	addi	a5,a5,-1224 # ffffffe000206010 <idle>
ffffffe0002004e0:	0007b783          	ld	a5,0(a5)
ffffffe0002004e4:	0807b823          	sd	zero,144(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe0002004e8:	00006797          	auipc	a5,0x6
ffffffe0002004ec:	b2878793          	addi	a5,a5,-1240 # ffffffe000206010 <idle>
ffffffe0002004f0:	0007b703          	ld	a4,0(a5)
ffffffe0002004f4:	00006797          	auipc	a5,0x6
ffffffe0002004f8:	b2478793          	addi	a5,a5,-1244 # ffffffe000206018 <current>
ffffffe0002004fc:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200500:	00006797          	auipc	a5,0x6
ffffffe000200504:	b1078793          	addi	a5,a5,-1264 # ffffffe000206010 <idle>
ffffffe000200508:	0007b703          	ld	a4,0(a5)
ffffffe00020050c:	00006797          	auipc	a5,0x6
ffffffe000200510:	b1478793          	addi	a5,a5,-1260 # ffffffe000206020 <task>
ffffffe000200514:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    for(int i=1;i<NR_TASKS;i++){
ffffffe000200518:	00100793          	li	a5,1
ffffffe00020051c:	fef42623          	sw	a5,-20(s0)
ffffffe000200520:	14c0006f          	j	ffffffe00020066c <task_init+0x200>
        task[i]=(struct task_struct *)kalloc();
ffffffe000200524:	dadff0ef          	jal	ra,ffffffe0002002d0 <kalloc>
ffffffe000200528:	00050693          	mv	a3,a0
ffffffe00020052c:	00006717          	auipc	a4,0x6
ffffffe000200530:	af470713          	addi	a4,a4,-1292 # ffffffe000206020 <task>
ffffffe000200534:	fec42783          	lw	a5,-20(s0)
ffffffe000200538:	00379793          	slli	a5,a5,0x3
ffffffe00020053c:	00f707b3          	add	a5,a4,a5
ffffffe000200540:	00d7b023          	sd	a3,0(a5)
        task[i]->state=TASK_RUNNING;
ffffffe000200544:	00006717          	auipc	a4,0x6
ffffffe000200548:	adc70713          	addi	a4,a4,-1316 # ffffffe000206020 <task>
ffffffe00020054c:	fec42783          	lw	a5,-20(s0)
ffffffe000200550:	00379793          	slli	a5,a5,0x3
ffffffe000200554:	00f707b3          	add	a5,a4,a5
ffffffe000200558:	0007b783          	ld	a5,0(a5)
ffffffe00020055c:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe000200560:	00006717          	auipc	a4,0x6
ffffffe000200564:	ac070713          	addi	a4,a4,-1344 # ffffffe000206020 <task>
ffffffe000200568:	fec42783          	lw	a5,-20(s0)
ffffffe00020056c:	00379793          	slli	a5,a5,0x3
ffffffe000200570:	00f707b3          	add	a5,a4,a5
ffffffe000200574:	0007b783          	ld	a5,0(a5)
ffffffe000200578:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
ffffffe00020057c:	495010ef          	jal	ra,ffffffe000202210 <rand>
ffffffe000200580:	00050793          	mv	a5,a0
ffffffe000200584:	00078713          	mv	a4,a5
ffffffe000200588:	00a00793          	li	a5,10
ffffffe00020058c:	02f767bb          	remw	a5,a4,a5
ffffffe000200590:	0007879b          	sext.w	a5,a5
ffffffe000200594:	0017879b          	addiw	a5,a5,1
ffffffe000200598:	0007869b          	sext.w	a3,a5
ffffffe00020059c:	00006717          	auipc	a4,0x6
ffffffe0002005a0:	a8470713          	addi	a4,a4,-1404 # ffffffe000206020 <task>
ffffffe0002005a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005a8:	00379793          	slli	a5,a5,0x3
ffffffe0002005ac:	00f707b3          	add	a5,a4,a5
ffffffe0002005b0:	0007b783          	ld	a5,0(a5)
ffffffe0002005b4:	00068713          	mv	a4,a3
ffffffe0002005b8:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe0002005bc:	00006717          	auipc	a4,0x6
ffffffe0002005c0:	a6470713          	addi	a4,a4,-1436 # ffffffe000206020 <task>
ffffffe0002005c4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005c8:	00379793          	slli	a5,a5,0x3
ffffffe0002005cc:	00f707b3          	add	a5,a4,a5
ffffffe0002005d0:	0007b783          	ld	a5,0(a5)
ffffffe0002005d4:	fec42703          	lw	a4,-20(s0)
ffffffe0002005d8:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
ffffffe0002005dc:	00006717          	auipc	a4,0x6
ffffffe0002005e0:	a4470713          	addi	a4,a4,-1468 # ffffffe000206020 <task>
ffffffe0002005e4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005e8:	00379793          	slli	a5,a5,0x3
ffffffe0002005ec:	00f707b3          	add	a5,a4,a5
ffffffe0002005f0:	0007b783          	ld	a5,0(a5)
ffffffe0002005f4:	00000717          	auipc	a4,0x0
ffffffe0002005f8:	bd070713          	addi	a4,a4,-1072 # ffffffe0002001c4 <__dummy>
ffffffe0002005fc:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe000200600:	00006717          	auipc	a4,0x6
ffffffe000200604:	a2070713          	addi	a4,a4,-1504 # ffffffe000206020 <task>
ffffffe000200608:	fec42783          	lw	a5,-20(s0)
ffffffe00020060c:	00379793          	slli	a5,a5,0x3
ffffffe000200610:	00f707b3          	add	a5,a4,a5
ffffffe000200614:	0007b783          	ld	a5,0(a5)
ffffffe000200618:	00078693          	mv	a3,a5
ffffffe00020061c:	00006717          	auipc	a4,0x6
ffffffe000200620:	a0470713          	addi	a4,a4,-1532 # ffffffe000206020 <task>
ffffffe000200624:	fec42783          	lw	a5,-20(s0)
ffffffe000200628:	00379793          	slli	a5,a5,0x3
ffffffe00020062c:	00f707b3          	add	a5,a4,a5
ffffffe000200630:	0007b783          	ld	a5,0(a5)
ffffffe000200634:	00001737          	lui	a4,0x1
ffffffe000200638:	00e68733          	add	a4,a3,a4
ffffffe00020063c:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.first_schedule=1;
ffffffe000200640:	00006717          	auipc	a4,0x6
ffffffe000200644:	9e070713          	addi	a4,a4,-1568 # ffffffe000206020 <task>
ffffffe000200648:	fec42783          	lw	a5,-20(s0)
ffffffe00020064c:	00379793          	slli	a5,a5,0x3
ffffffe000200650:	00f707b3          	add	a5,a4,a5
ffffffe000200654:	0007b783          	ld	a5,0(a5)
ffffffe000200658:	00100713          	li	a4,1
ffffffe00020065c:	08e7b823          	sd	a4,144(a5)
    for(int i=1;i<NR_TASKS;i++){
ffffffe000200660:	fec42783          	lw	a5,-20(s0)
ffffffe000200664:	0017879b          	addiw	a5,a5,1
ffffffe000200668:	fef42623          	sw	a5,-20(s0)
ffffffe00020066c:	fec42783          	lw	a5,-20(s0)
ffffffe000200670:	0007871b          	sext.w	a4,a5
ffffffe000200674:	01f00793          	li	a5,31
ffffffe000200678:	eae7d6e3          	bge	a5,a4,ffffffe000200524 <task_init+0xb8>
    }

    printk("...task_init done!\n");
ffffffe00020067c:	00003517          	auipc	a0,0x3
ffffffe000200680:	99c50513          	addi	a0,a0,-1636 # ffffffe000203018 <_srodata+0x18>
ffffffe000200684:	2c9010ef          	jal	ra,ffffffe00020214c <printk>
}
ffffffe000200688:	00000013          	nop
ffffffe00020068c:	01813083          	ld	ra,24(sp)
ffffffe000200690:	01013403          	ld	s0,16(sp)
ffffffe000200694:	02010113          	addi	sp,sp,32
ffffffe000200698:	00008067          	ret

ffffffe00020069c <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe00020069c:	fd010113          	addi	sp,sp,-48
ffffffe0002006a0:	02113423          	sd	ra,40(sp)
ffffffe0002006a4:	02813023          	sd	s0,32(sp)
ffffffe0002006a8:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe0002006ac:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe0002006b0:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe0002006b4:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe0002006b8:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe0002006bc:	fff00793          	li	a5,-1
ffffffe0002006c0:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002006c4:	fe442783          	lw	a5,-28(s0)
ffffffe0002006c8:	0007871b          	sext.w	a4,a5
ffffffe0002006cc:	fff00793          	li	a5,-1
ffffffe0002006d0:	00f70e63          	beq	a4,a5,ffffffe0002006ec <dummy+0x50>
ffffffe0002006d4:	00006797          	auipc	a5,0x6
ffffffe0002006d8:	94478793          	addi	a5,a5,-1724 # ffffffe000206018 <current>
ffffffe0002006dc:	0007b783          	ld	a5,0(a5)
ffffffe0002006e0:	0087b703          	ld	a4,8(a5)
ffffffe0002006e4:	fe442783          	lw	a5,-28(s0)
ffffffe0002006e8:	fcf70ee3          	beq	a4,a5,ffffffe0002006c4 <dummy+0x28>
ffffffe0002006ec:	00006797          	auipc	a5,0x6
ffffffe0002006f0:	92c78793          	addi	a5,a5,-1748 # ffffffe000206018 <current>
ffffffe0002006f4:	0007b783          	ld	a5,0(a5)
ffffffe0002006f8:	0087b783          	ld	a5,8(a5)
ffffffe0002006fc:	fc0784e3          	beqz	a5,ffffffe0002006c4 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000200700:	00006797          	auipc	a5,0x6
ffffffe000200704:	91878793          	addi	a5,a5,-1768 # ffffffe000206018 <current>
ffffffe000200708:	0007b783          	ld	a5,0(a5)
ffffffe00020070c:	0087b703          	ld	a4,8(a5)
ffffffe000200710:	00100793          	li	a5,1
ffffffe000200714:	00f71e63          	bne	a4,a5,ffffffe000200730 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000200718:	00006797          	auipc	a5,0x6
ffffffe00020071c:	90078793          	addi	a5,a5,-1792 # ffffffe000206018 <current>
ffffffe000200720:	0007b783          	ld	a5,0(a5)
ffffffe000200724:	0087b703          	ld	a4,8(a5)
ffffffe000200728:	fff70713          	addi	a4,a4,-1
ffffffe00020072c:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000200730:	00006797          	auipc	a5,0x6
ffffffe000200734:	8e878793          	addi	a5,a5,-1816 # ffffffe000206018 <current>
ffffffe000200738:	0007b783          	ld	a5,0(a5)
ffffffe00020073c:	0087b783          	ld	a5,8(a5)
ffffffe000200740:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000200744:	fe843783          	ld	a5,-24(s0)
ffffffe000200748:	00178713          	addi	a4,a5,1
ffffffe00020074c:	fd843783          	ld	a5,-40(s0)
ffffffe000200750:	02f777b3          	remu	a5,a4,a5
ffffffe000200754:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe000200758:	00006797          	auipc	a5,0x6
ffffffe00020075c:	8c078793          	addi	a5,a5,-1856 # ffffffe000206018 <current>
ffffffe000200760:	0007b783          	ld	a5,0(a5)
ffffffe000200764:	0187b783          	ld	a5,24(a5)
ffffffe000200768:	fe843603          	ld	a2,-24(s0)
ffffffe00020076c:	00078593          	mv	a1,a5
ffffffe000200770:	00003517          	auipc	a0,0x3
ffffffe000200774:	8c050513          	addi	a0,a0,-1856 # ffffffe000203030 <_srodata+0x30>
ffffffe000200778:	1d5010ef          	jal	ra,ffffffe00020214c <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020077c:	f49ff06f          	j	ffffffe0002006c4 <dummy+0x28>

ffffffe000200780 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
ffffffe000200780:	fd010113          	addi	sp,sp,-48
ffffffe000200784:	02113423          	sd	ra,40(sp)
ffffffe000200788:	02813023          	sd	s0,32(sp)
ffffffe00020078c:	03010413          	addi	s0,sp,48
ffffffe000200790:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
ffffffe000200794:	00006797          	auipc	a5,0x6
ffffffe000200798:	88478793          	addi	a5,a5,-1916 # ffffffe000206018 <current>
ffffffe00020079c:	0007b783          	ld	a5,0(a5)
ffffffe0002007a0:	fd843703          	ld	a4,-40(s0)
ffffffe0002007a4:	06f70063          	beq	a4,a5,ffffffe000200804 <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
ffffffe0002007a8:	00006797          	auipc	a5,0x6
ffffffe0002007ac:	87078793          	addi	a5,a5,-1936 # ffffffe000206018 <current>
ffffffe0002007b0:	0007b783          	ld	a5,0(a5)
ffffffe0002007b4:	fef43423          	sd	a5,-24(s0)
    current=next;
ffffffe0002007b8:	00006797          	auipc	a5,0x6
ffffffe0002007bc:	86078793          	addi	a5,a5,-1952 # ffffffe000206018 <current>
ffffffe0002007c0:	fd843703          	ld	a4,-40(s0)
ffffffe0002007c4:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
ffffffe0002007c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002007cc:	0187b703          	ld	a4,24(a5)
ffffffe0002007d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002007d4:	0107b603          	ld	a2,16(a5)
ffffffe0002007d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002007dc:	0087b783          	ld	a5,8(a5)
ffffffe0002007e0:	00078693          	mv	a3,a5
ffffffe0002007e4:	00070593          	mv	a1,a4
ffffffe0002007e8:	00003517          	auipc	a0,0x3
ffffffe0002007ec:	87850513          	addi	a0,a0,-1928 # ffffffe000203060 <_srodata+0x60>
ffffffe0002007f0:	15d010ef          	jal	ra,ffffffe00020214c <printk>
    __switch_to(prev,next);
ffffffe0002007f4:	fd843583          	ld	a1,-40(s0)
ffffffe0002007f8:	fe843503          	ld	a0,-24(s0)
ffffffe0002007fc:	9d9ff0ef          	jal	ra,ffffffe0002001d4 <__switch_to>
ffffffe000200800:	0080006f          	j	ffffffe000200808 <switch_to+0x88>
        return;
ffffffe000200804:	00000013          	nop
    
}
ffffffe000200808:	02813083          	ld	ra,40(sp)
ffffffe00020080c:	02013403          	ld	s0,32(sp)
ffffffe000200810:	03010113          	addi	sp,sp,48
ffffffe000200814:	00008067          	ret

ffffffe000200818 <do_timer>:

void do_timer(){
ffffffe000200818:	ff010113          	addi	sp,sp,-16
ffffffe00020081c:	00113423          	sd	ra,8(sp)
ffffffe000200820:	00813023          	sd	s0,0(sp)
ffffffe000200824:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
ffffffe000200828:	00005797          	auipc	a5,0x5
ffffffe00020082c:	7f078793          	addi	a5,a5,2032 # ffffffe000206018 <current>
ffffffe000200830:	0007b703          	ld	a4,0(a5)
ffffffe000200834:	00005797          	auipc	a5,0x5
ffffffe000200838:	7dc78793          	addi	a5,a5,2012 # ffffffe000206010 <idle>
ffffffe00020083c:	0007b783          	ld	a5,0(a5)
ffffffe000200840:	00f70c63          	beq	a4,a5,ffffffe000200858 <do_timer+0x40>
ffffffe000200844:	00005797          	auipc	a5,0x5
ffffffe000200848:	7d478793          	addi	a5,a5,2004 # ffffffe000206018 <current>
ffffffe00020084c:	0007b783          	ld	a5,0(a5)
ffffffe000200850:	0087b783          	ld	a5,8(a5)
ffffffe000200854:	00079663          	bnez	a5,ffffffe000200860 <do_timer+0x48>
        schedule();
ffffffe000200858:	04c000ef          	jal	ra,ffffffe0002008a4 <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
ffffffe00020085c:	0340006f          	j	ffffffe000200890 <do_timer+0x78>
        current->counter--;
ffffffe000200860:	00005797          	auipc	a5,0x5
ffffffe000200864:	7b878793          	addi	a5,a5,1976 # ffffffe000206018 <current>
ffffffe000200868:	0007b783          	ld	a5,0(a5)
ffffffe00020086c:	0087b703          	ld	a4,8(a5)
ffffffe000200870:	fff70713          	addi	a4,a4,-1
ffffffe000200874:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
ffffffe000200878:	00005797          	auipc	a5,0x5
ffffffe00020087c:	7a078793          	addi	a5,a5,1952 # ffffffe000206018 <current>
ffffffe000200880:	0007b783          	ld	a5,0(a5)
ffffffe000200884:	0087b783          	ld	a5,8(a5)
ffffffe000200888:	00079463          	bnez	a5,ffffffe000200890 <do_timer+0x78>
            schedule();
ffffffe00020088c:	018000ef          	jal	ra,ffffffe0002008a4 <schedule>
}
ffffffe000200890:	00000013          	nop
ffffffe000200894:	00813083          	ld	ra,8(sp)
ffffffe000200898:	00013403          	ld	s0,0(sp)
ffffffe00020089c:	01010113          	addi	sp,sp,16
ffffffe0002008a0:	00008067          	ret

ffffffe0002008a4 <schedule>:

void schedule(){
ffffffe0002008a4:	fd010113          	addi	sp,sp,-48
ffffffe0002008a8:	02113423          	sd	ra,40(sp)
ffffffe0002008ac:	02813023          	sd	s0,32(sp)
ffffffe0002008b0:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
ffffffe0002008b4:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
ffffffe0002008b8:	fe043023          	sd	zero,-32(s0)
    //找到 counter 最大的线程
    for(int i=0;i<NR_TASKS;i++){
ffffffe0002008bc:	fc042e23          	sw	zero,-36(s0)
ffffffe0002008c0:	0700006f          	j	ffffffe000200930 <schedule+0x8c>
        if(task[i]->counter>max_counter){
ffffffe0002008c4:	00005717          	auipc	a4,0x5
ffffffe0002008c8:	75c70713          	addi	a4,a4,1884 # ffffffe000206020 <task>
ffffffe0002008cc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008d0:	00379793          	slli	a5,a5,0x3
ffffffe0002008d4:	00f707b3          	add	a5,a4,a5
ffffffe0002008d8:	0007b783          	ld	a5,0(a5)
ffffffe0002008dc:	0087b783          	ld	a5,8(a5)
ffffffe0002008e0:	fe043703          	ld	a4,-32(s0)
ffffffe0002008e4:	04f77063          	bgeu	a4,a5,ffffffe000200924 <schedule+0x80>
            max_counter=task[i]->counter;
ffffffe0002008e8:	00005717          	auipc	a4,0x5
ffffffe0002008ec:	73870713          	addi	a4,a4,1848 # ffffffe000206020 <task>
ffffffe0002008f0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008f4:	00379793          	slli	a5,a5,0x3
ffffffe0002008f8:	00f707b3          	add	a5,a4,a5
ffffffe0002008fc:	0007b783          	ld	a5,0(a5)
ffffffe000200900:	0087b783          	ld	a5,8(a5)
ffffffe000200904:	fef43023          	sd	a5,-32(s0)
            next=task[i];
ffffffe000200908:	00005717          	auipc	a4,0x5
ffffffe00020090c:	71870713          	addi	a4,a4,1816 # ffffffe000206020 <task>
ffffffe000200910:	fdc42783          	lw	a5,-36(s0)
ffffffe000200914:	00379793          	slli	a5,a5,0x3
ffffffe000200918:	00f707b3          	add	a5,a4,a5
ffffffe00020091c:	0007b783          	ld	a5,0(a5)
ffffffe000200920:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
ffffffe000200924:	fdc42783          	lw	a5,-36(s0)
ffffffe000200928:	0017879b          	addiw	a5,a5,1
ffffffe00020092c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200930:	fdc42783          	lw	a5,-36(s0)
ffffffe000200934:	0007871b          	sext.w	a4,a5
ffffffe000200938:	01f00793          	li	a5,31
ffffffe00020093c:	f8e7d4e3          	bge	a5,a4,ffffffe0002008c4 <schedule+0x20>
        }
    }
    //如果所有线程的 counter 都为 0，则重新为每个线程分配时间片，分配策略为将线程的 priority 赋值给 counter
    if(max_counter==0){
ffffffe000200940:	fe043783          	ld	a5,-32(s0)
ffffffe000200944:	12079463          	bnez	a5,ffffffe000200a6c <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
ffffffe000200948:	00100793          	li	a5,1
ffffffe00020094c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200950:	10c0006f          	j	ffffffe000200a5c <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
ffffffe000200954:	00005717          	auipc	a4,0x5
ffffffe000200958:	6cc70713          	addi	a4,a4,1740 # ffffffe000206020 <task>
ffffffe00020095c:	fd842783          	lw	a5,-40(s0)
ffffffe000200960:	00379793          	slli	a5,a5,0x3
ffffffe000200964:	00f707b3          	add	a5,a4,a5
ffffffe000200968:	0007b703          	ld	a4,0(a5)
ffffffe00020096c:	00005697          	auipc	a3,0x5
ffffffe000200970:	6b468693          	addi	a3,a3,1716 # ffffffe000206020 <task>
ffffffe000200974:	fd842783          	lw	a5,-40(s0)
ffffffe000200978:	00379793          	slli	a5,a5,0x3
ffffffe00020097c:	00f687b3          	add	a5,a3,a5
ffffffe000200980:	0007b783          	ld	a5,0(a5)
ffffffe000200984:	01073703          	ld	a4,16(a4)
ffffffe000200988:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
ffffffe00020098c:	00005717          	auipc	a4,0x5
ffffffe000200990:	69470713          	addi	a4,a4,1684 # ffffffe000206020 <task>
ffffffe000200994:	fd842783          	lw	a5,-40(s0)
ffffffe000200998:	00379793          	slli	a5,a5,0x3
ffffffe00020099c:	00f707b3          	add	a5,a4,a5
ffffffe0002009a0:	0007b783          	ld	a5,0(a5)
ffffffe0002009a4:	0187b583          	ld	a1,24(a5)
ffffffe0002009a8:	00005717          	auipc	a4,0x5
ffffffe0002009ac:	67870713          	addi	a4,a4,1656 # ffffffe000206020 <task>
ffffffe0002009b0:	fd842783          	lw	a5,-40(s0)
ffffffe0002009b4:	00379793          	slli	a5,a5,0x3
ffffffe0002009b8:	00f707b3          	add	a5,a4,a5
ffffffe0002009bc:	0007b783          	ld	a5,0(a5)
ffffffe0002009c0:	0107b603          	ld	a2,16(a5)
ffffffe0002009c4:	00005717          	auipc	a4,0x5
ffffffe0002009c8:	65c70713          	addi	a4,a4,1628 # ffffffe000206020 <task>
ffffffe0002009cc:	fd842783          	lw	a5,-40(s0)
ffffffe0002009d0:	00379793          	slli	a5,a5,0x3
ffffffe0002009d4:	00f707b3          	add	a5,a4,a5
ffffffe0002009d8:	0007b783          	ld	a5,0(a5)
ffffffe0002009dc:	0087b783          	ld	a5,8(a5)
ffffffe0002009e0:	00078693          	mv	a3,a5
ffffffe0002009e4:	00002517          	auipc	a0,0x2
ffffffe0002009e8:	6bc50513          	addi	a0,a0,1724 # ffffffe0002030a0 <_srodata+0xa0>
ffffffe0002009ec:	760010ef          	jal	ra,ffffffe00020214c <printk>
            if(task[i]->counter>max_counter){
ffffffe0002009f0:	00005717          	auipc	a4,0x5
ffffffe0002009f4:	63070713          	addi	a4,a4,1584 # ffffffe000206020 <task>
ffffffe0002009f8:	fd842783          	lw	a5,-40(s0)
ffffffe0002009fc:	00379793          	slli	a5,a5,0x3
ffffffe000200a00:	00f707b3          	add	a5,a4,a5
ffffffe000200a04:	0007b783          	ld	a5,0(a5)
ffffffe000200a08:	0087b783          	ld	a5,8(a5)
ffffffe000200a0c:	fe043703          	ld	a4,-32(s0)
ffffffe000200a10:	04f77063          	bgeu	a4,a5,ffffffe000200a50 <schedule+0x1ac>
                max_counter=task[i]->counter;
ffffffe000200a14:	00005717          	auipc	a4,0x5
ffffffe000200a18:	60c70713          	addi	a4,a4,1548 # ffffffe000206020 <task>
ffffffe000200a1c:	fd842783          	lw	a5,-40(s0)
ffffffe000200a20:	00379793          	slli	a5,a5,0x3
ffffffe000200a24:	00f707b3          	add	a5,a4,a5
ffffffe000200a28:	0007b783          	ld	a5,0(a5)
ffffffe000200a2c:	0087b783          	ld	a5,8(a5)
ffffffe000200a30:	fef43023          	sd	a5,-32(s0)
                next=task[i];
ffffffe000200a34:	00005717          	auipc	a4,0x5
ffffffe000200a38:	5ec70713          	addi	a4,a4,1516 # ffffffe000206020 <task>
ffffffe000200a3c:	fd842783          	lw	a5,-40(s0)
ffffffe000200a40:	00379793          	slli	a5,a5,0x3
ffffffe000200a44:	00f707b3          	add	a5,a4,a5
ffffffe000200a48:	0007b783          	ld	a5,0(a5)
ffffffe000200a4c:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
ffffffe000200a50:	fd842783          	lw	a5,-40(s0)
ffffffe000200a54:	0017879b          	addiw	a5,a5,1
ffffffe000200a58:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200a5c:	fd842783          	lw	a5,-40(s0)
ffffffe000200a60:	0007871b          	sext.w	a4,a5
ffffffe000200a64:	01f00793          	li	a5,31
ffffffe000200a68:	eee7d6e3          	bge	a5,a4,ffffffe000200954 <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
ffffffe000200a6c:	fe843783          	ld	a5,-24(s0)
ffffffe000200a70:	00078663          	beqz	a5,ffffffe000200a7c <schedule+0x1d8>
ffffffe000200a74:	fe843503          	ld	a0,-24(s0)
ffffffe000200a78:	d09ff0ef          	jal	ra,ffffffe000200780 <switch_to>
}
ffffffe000200a7c:	00000013          	nop
ffffffe000200a80:	02813083          	ld	ra,40(sp)
ffffffe000200a84:	02013403          	ld	s0,32(sp)
ffffffe000200a88:	03010113          	addi	sp,sp,48
ffffffe000200a8c:	00008067          	ret

ffffffe000200a90 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000200a90:	f8010113          	addi	sp,sp,-128
ffffffe000200a94:	06813c23          	sd	s0,120(sp)
ffffffe000200a98:	06913823          	sd	s1,112(sp)
ffffffe000200a9c:	07213423          	sd	s2,104(sp)
ffffffe000200aa0:	07313023          	sd	s3,96(sp)
ffffffe000200aa4:	08010413          	addi	s0,sp,128
ffffffe000200aa8:	faa43c23          	sd	a0,-72(s0)
ffffffe000200aac:	fab43823          	sd	a1,-80(s0)
ffffffe000200ab0:	fac43423          	sd	a2,-88(s0)
ffffffe000200ab4:	fad43023          	sd	a3,-96(s0)
ffffffe000200ab8:	f8e43c23          	sd	a4,-104(s0)
ffffffe000200abc:	f8f43823          	sd	a5,-112(s0)
ffffffe000200ac0:	f9043423          	sd	a6,-120(s0)
ffffffe000200ac4:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
ffffffe000200ac8:	fb843e03          	ld	t3,-72(s0)
ffffffe000200acc:	fb043e83          	ld	t4,-80(s0)
ffffffe000200ad0:	fa843f03          	ld	t5,-88(s0)
ffffffe000200ad4:	fa043f83          	ld	t6,-96(s0)
ffffffe000200ad8:	f9843283          	ld	t0,-104(s0)
ffffffe000200adc:	f9043483          	ld	s1,-112(s0)
ffffffe000200ae0:	f8843903          	ld	s2,-120(s0)
ffffffe000200ae4:	f8043983          	ld	s3,-128(s0)
ffffffe000200ae8:	000e0893          	mv	a7,t3
ffffffe000200aec:	000e8813          	mv	a6,t4
ffffffe000200af0:	000f0513          	mv	a0,t5
ffffffe000200af4:	000f8593          	mv	a1,t6
ffffffe000200af8:	00028613          	mv	a2,t0
ffffffe000200afc:	00048693          	mv	a3,s1
ffffffe000200b00:	00090713          	mv	a4,s2
ffffffe000200b04:	00098793          	mv	a5,s3
ffffffe000200b08:	00000073          	ecall
ffffffe000200b0c:	00050e93          	mv	t4,a0
ffffffe000200b10:	00058e13          	mv	t3,a1
ffffffe000200b14:	fdd43023          	sd	t4,-64(s0)
ffffffe000200b18:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
ffffffe000200b1c:	fc043783          	ld	a5,-64(s0)
ffffffe000200b20:	fcf43823          	sd	a5,-48(s0)
ffffffe000200b24:	fc843783          	ld	a5,-56(s0)
ffffffe000200b28:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200b2c:	00000713          	li	a4,0
ffffffe000200b30:	fd043703          	ld	a4,-48(s0)
ffffffe000200b34:	00000793          	li	a5,0
ffffffe000200b38:	fd843783          	ld	a5,-40(s0)
ffffffe000200b3c:	00070313          	mv	t1,a4
ffffffe000200b40:	00078393          	mv	t2,a5
ffffffe000200b44:	00030713          	mv	a4,t1
ffffffe000200b48:	00038793          	mv	a5,t2
}
ffffffe000200b4c:	00070513          	mv	a0,a4
ffffffe000200b50:	00078593          	mv	a1,a5
ffffffe000200b54:	07813403          	ld	s0,120(sp)
ffffffe000200b58:	07013483          	ld	s1,112(sp)
ffffffe000200b5c:	06813903          	ld	s2,104(sp)
ffffffe000200b60:	06013983          	ld	s3,96(sp)
ffffffe000200b64:	08010113          	addi	sp,sp,128
ffffffe000200b68:	00008067          	ret

ffffffe000200b6c <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe000200b6c:	fc010113          	addi	sp,sp,-64
ffffffe000200b70:	02113c23          	sd	ra,56(sp)
ffffffe000200b74:	02813823          	sd	s0,48(sp)
ffffffe000200b78:	03213423          	sd	s2,40(sp)
ffffffe000200b7c:	03313023          	sd	s3,32(sp)
ffffffe000200b80:	04010413          	addi	s0,sp,64
ffffffe000200b84:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
ffffffe000200b88:	00000893          	li	a7,0
ffffffe000200b8c:	00000813          	li	a6,0
ffffffe000200b90:	00000793          	li	a5,0
ffffffe000200b94:	00000713          	li	a4,0
ffffffe000200b98:	00000693          	li	a3,0
ffffffe000200b9c:	fc843603          	ld	a2,-56(s0)
ffffffe000200ba0:	00000593          	li	a1,0
ffffffe000200ba4:	54495537          	lui	a0,0x54495
ffffffe000200ba8:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000200bac:	ee5ff0ef          	jal	ra,ffffffe000200a90 <sbi_ecall>
ffffffe000200bb0:	00050713          	mv	a4,a0
ffffffe000200bb4:	00058793          	mv	a5,a1
ffffffe000200bb8:	fce43823          	sd	a4,-48(s0)
ffffffe000200bbc:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200bc0:	00000713          	li	a4,0
ffffffe000200bc4:	fd043703          	ld	a4,-48(s0)
ffffffe000200bc8:	00000793          	li	a5,0
ffffffe000200bcc:	fd843783          	ld	a5,-40(s0)
ffffffe000200bd0:	00070913          	mv	s2,a4
ffffffe000200bd4:	00078993          	mv	s3,a5
ffffffe000200bd8:	00090713          	mv	a4,s2
ffffffe000200bdc:	00098793          	mv	a5,s3
}
ffffffe000200be0:	00070513          	mv	a0,a4
ffffffe000200be4:	00078593          	mv	a1,a5
ffffffe000200be8:	03813083          	ld	ra,56(sp)
ffffffe000200bec:	03013403          	ld	s0,48(sp)
ffffffe000200bf0:	02813903          	ld	s2,40(sp)
ffffffe000200bf4:	02013983          	ld	s3,32(sp)
ffffffe000200bf8:	04010113          	addi	sp,sp,64
ffffffe000200bfc:	00008067          	ret

ffffffe000200c00 <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000200c00:	fc010113          	addi	sp,sp,-64
ffffffe000200c04:	02113c23          	sd	ra,56(sp)
ffffffe000200c08:	02813823          	sd	s0,48(sp)
ffffffe000200c0c:	03213423          	sd	s2,40(sp)
ffffffe000200c10:	03313023          	sd	s3,32(sp)
ffffffe000200c14:	04010413          	addi	s0,sp,64
ffffffe000200c18:	00050793          	mv	a5,a0
ffffffe000200c1c:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
ffffffe000200c20:	fcf44603          	lbu	a2,-49(s0)
ffffffe000200c24:	00000893          	li	a7,0
ffffffe000200c28:	00000813          	li	a6,0
ffffffe000200c2c:	00000793          	li	a5,0
ffffffe000200c30:	00000713          	li	a4,0
ffffffe000200c34:	00000693          	li	a3,0
ffffffe000200c38:	00200593          	li	a1,2
ffffffe000200c3c:	44424537          	lui	a0,0x44424
ffffffe000200c40:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000200c44:	e4dff0ef          	jal	ra,ffffffe000200a90 <sbi_ecall>
ffffffe000200c48:	00050713          	mv	a4,a0
ffffffe000200c4c:	00058793          	mv	a5,a1
ffffffe000200c50:	fce43823          	sd	a4,-48(s0)
ffffffe000200c54:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200c58:	00000713          	li	a4,0
ffffffe000200c5c:	fd043703          	ld	a4,-48(s0)
ffffffe000200c60:	00000793          	li	a5,0
ffffffe000200c64:	fd843783          	ld	a5,-40(s0)
ffffffe000200c68:	00070913          	mv	s2,a4
ffffffe000200c6c:	00078993          	mv	s3,a5
ffffffe000200c70:	00090713          	mv	a4,s2
ffffffe000200c74:	00098793          	mv	a5,s3
}
ffffffe000200c78:	00070513          	mv	a0,a4
ffffffe000200c7c:	00078593          	mv	a1,a5
ffffffe000200c80:	03813083          	ld	ra,56(sp)
ffffffe000200c84:	03013403          	ld	s0,48(sp)
ffffffe000200c88:	02813903          	ld	s2,40(sp)
ffffffe000200c8c:	02013983          	ld	s3,32(sp)
ffffffe000200c90:	04010113          	addi	sp,sp,64
ffffffe000200c94:	00008067          	ret

ffffffe000200c98 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000200c98:	fc010113          	addi	sp,sp,-64
ffffffe000200c9c:	02113c23          	sd	ra,56(sp)
ffffffe000200ca0:	02813823          	sd	s0,48(sp)
ffffffe000200ca4:	03213423          	sd	s2,40(sp)
ffffffe000200ca8:	03313023          	sd	s3,32(sp)
ffffffe000200cac:	04010413          	addi	s0,sp,64
ffffffe000200cb0:	00050793          	mv	a5,a0
ffffffe000200cb4:	00058713          	mv	a4,a1
ffffffe000200cb8:	fcf42623          	sw	a5,-52(s0)
ffffffe000200cbc:	00070793          	mv	a5,a4
ffffffe000200cc0:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
ffffffe000200cc4:	fcc46603          	lwu	a2,-52(s0)
ffffffe000200cc8:	fc846683          	lwu	a3,-56(s0)
ffffffe000200ccc:	00000893          	li	a7,0
ffffffe000200cd0:	00000813          	li	a6,0
ffffffe000200cd4:	00000793          	li	a5,0
ffffffe000200cd8:	00000713          	li	a4,0
ffffffe000200cdc:	00000593          	li	a1,0
ffffffe000200ce0:	53525537          	lui	a0,0x53525
ffffffe000200ce4:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000200ce8:	da9ff0ef          	jal	ra,ffffffe000200a90 <sbi_ecall>
ffffffe000200cec:	00050713          	mv	a4,a0
ffffffe000200cf0:	00058793          	mv	a5,a1
ffffffe000200cf4:	fce43823          	sd	a4,-48(s0)
ffffffe000200cf8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200cfc:	00000713          	li	a4,0
ffffffe000200d00:	fd043703          	ld	a4,-48(s0)
ffffffe000200d04:	00000793          	li	a5,0
ffffffe000200d08:	fd843783          	ld	a5,-40(s0)
ffffffe000200d0c:	00070913          	mv	s2,a4
ffffffe000200d10:	00078993          	mv	s3,a5
ffffffe000200d14:	00090713          	mv	a4,s2
ffffffe000200d18:	00098793          	mv	a5,s3
ffffffe000200d1c:	00070513          	mv	a0,a4
ffffffe000200d20:	00078593          	mv	a1,a5
ffffffe000200d24:	03813083          	ld	ra,56(sp)
ffffffe000200d28:	03013403          	ld	s0,48(sp)
ffffffe000200d2c:	02813903          	ld	s2,40(sp)
ffffffe000200d30:	02013983          	ld	s3,32(sp)
ffffffe000200d34:	04010113          	addi	sp,sp,64
ffffffe000200d38:	00008067          	ret

ffffffe000200d3c <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe000200d3c:	fd010113          	addi	sp,sp,-48
ffffffe000200d40:	02113423          	sd	ra,40(sp)
ffffffe000200d44:	02813023          	sd	s0,32(sp)
ffffffe000200d48:	03010413          	addi	s0,sp,48
ffffffe000200d4c:	fca43c23          	sd	a0,-40(s0)
ffffffe000200d50:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
ffffffe000200d54:	fd843783          	ld	a5,-40(s0)
ffffffe000200d58:	0407d263          	bgez	a5,ffffffe000200d9c <trap_handler+0x60>
        uint64_t interrupt_code = scause & ~(1UL << 63);
ffffffe000200d5c:	fd843703          	ld	a4,-40(s0)
ffffffe000200d60:	fff00793          	li	a5,-1
ffffffe000200d64:	0017d793          	srli	a5,a5,0x1
ffffffe000200d68:	00f777b3          	and	a5,a4,a5
ffffffe000200d6c:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
ffffffe000200d70:	fe043703          	ld	a4,-32(s0)
ffffffe000200d74:	00500793          	li	a5,5
ffffffe000200d78:	00f71863          	bne	a4,a5,ffffffe000200d88 <trap_handler+0x4c>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
ffffffe000200d7c:	d0cff0ef          	jal	ra,ffffffe000200288 <clock_set_next_event>
            do_timer();
ffffffe000200d80:	a99ff0ef          	jal	ra,ffffffe000200818 <do_timer>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
ffffffe000200d84:	0300006f          	j	ffffffe000200db4 <trap_handler+0x78>
            printk("other interrupt: %d\n", interrupt_code);
ffffffe000200d88:	fe043583          	ld	a1,-32(s0)
ffffffe000200d8c:	00002517          	auipc	a0,0x2
ffffffe000200d90:	34c50513          	addi	a0,a0,844 # ffffffe0002030d8 <_srodata+0xd8>
ffffffe000200d94:	3b8010ef          	jal	ra,ffffffe00020214c <printk>
ffffffe000200d98:	01c0006f          	j	ffffffe000200db4 <trap_handler+0x78>
        uint64_t exception_code = scause;
ffffffe000200d9c:	fd843783          	ld	a5,-40(s0)
ffffffe000200da0:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
ffffffe000200da4:	fe843583          	ld	a1,-24(s0)
ffffffe000200da8:	00002517          	auipc	a0,0x2
ffffffe000200dac:	34850513          	addi	a0,a0,840 # ffffffe0002030f0 <_srodata+0xf0>
ffffffe000200db0:	39c010ef          	jal	ra,ffffffe00020214c <printk>
ffffffe000200db4:	00000013          	nop
ffffffe000200db8:	02813083          	ld	ra,40(sp)
ffffffe000200dbc:	02013403          	ld	s0,32(sp)
ffffffe000200dc0:	03010113          	addi	sp,sp,48
ffffffe000200dc4:	00008067          	ret

ffffffe000200dc8 <setup_vm>:
extern char _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000200dc8:	fc010113          	addi	sp,sp,-64
ffffffe000200dcc:	02813c23          	sd	s0,56(sp)
ffffffe000200dd0:	04010413          	addi	s0,sp,64
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   uint64_t pa=0x80000000;
ffffffe000200dd4:	00100793          	li	a5,1
ffffffe000200dd8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200ddc:	fef43423          	sd	a5,-24(s0)
   uint64_t va_eq=pa;
ffffffe000200de0:	fe843783          	ld	a5,-24(s0)
ffffffe000200de4:	fef43023          	sd	a5,-32(s0)
   uint64_t va_direct=pa+PA2VA_OFFSET;
ffffffe000200de8:	fe843703          	ld	a4,-24(s0)
ffffffe000200dec:	fbf00793          	li	a5,-65
ffffffe000200df0:	01f79793          	slli	a5,a5,0x1f
ffffffe000200df4:	00f707b3          	add	a5,a4,a5
ffffffe000200df8:	fcf43c23          	sd	a5,-40(s0)
//    uint64_t size=0x40000000; // 1 GiB

   uint64_t perm = PTE_V|PTE_R|PTE_W|PTE_X; // V | R | W | X
ffffffe000200dfc:	00f00793          	li	a5,15
ffffffe000200e00:	fcf43823          	sd	a5,-48(s0)
    //中间 9 bit 作为 early_pgtbl 的 index
   uint64_t idx_eq=(va_eq>>30)&0x1ff; 
ffffffe000200e04:	fe043783          	ld	a5,-32(s0)
ffffffe000200e08:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200e0c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e10:	fcf43423          	sd	a5,-56(s0)
   uint64_t idx_direct=(va_direct>>30)&0x1ff;
ffffffe000200e14:	fd843783          	ld	a5,-40(s0)
ffffffe000200e18:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200e1c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e20:	fcf43023          	sd	a5,-64(s0)

    early_pgtbl[idx_eq]= (pa>>12)<<10 | perm;       //等值映射
ffffffe000200e24:	fe843783          	ld	a5,-24(s0)
ffffffe000200e28:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e2c:	00a79713          	slli	a4,a5,0xa
ffffffe000200e30:	fd043783          	ld	a5,-48(s0)
ffffffe000200e34:	00f76733          	or	a4,a4,a5
ffffffe000200e38:	00007697          	auipc	a3,0x7
ffffffe000200e3c:	1c868693          	addi	a3,a3,456 # ffffffe000208000 <early_pgtbl>
ffffffe000200e40:	fc843783          	ld	a5,-56(s0)
ffffffe000200e44:	00379793          	slli	a5,a5,0x3
ffffffe000200e48:	00f687b3          	add	a5,a3,a5
ffffffe000200e4c:	00e7b023          	sd	a4,0(a5)
    early_pgtbl[idx_direct]= (pa>>12)<<10 | perm;   //直接映射
ffffffe000200e50:	fe843783          	ld	a5,-24(s0)
ffffffe000200e54:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e58:	00a79713          	slli	a4,a5,0xa
ffffffe000200e5c:	fd043783          	ld	a5,-48(s0)
ffffffe000200e60:	00f76733          	or	a4,a4,a5
ffffffe000200e64:	00007697          	auipc	a3,0x7
ffffffe000200e68:	19c68693          	addi	a3,a3,412 # ffffffe000208000 <early_pgtbl>
ffffffe000200e6c:	fc043783          	ld	a5,-64(s0)
ffffffe000200e70:	00379793          	slli	a5,a5,0x3
ffffffe000200e74:	00f687b3          	add	a5,a3,a5
ffffffe000200e78:	00e7b023          	sd	a4,0(a5)
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //       pa, va_eq, idx_eq);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //        pa, va_direct, idx_direct);

}
ffffffe000200e7c:	00000013          	nop
ffffffe000200e80:	03813403          	ld	s0,56(sp)
ffffffe000200e84:	04010113          	addi	sp,sp,64
ffffffe000200e88:	00008067          	ret

ffffffe000200e8c <create_mapping>:

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000200e8c:	f5010113          	addi	sp,sp,-176
ffffffe000200e90:	0a113423          	sd	ra,168(sp)
ffffffe000200e94:	0a813023          	sd	s0,160(sp)
ffffffe000200e98:	0b010413          	addi	s0,sp,176
ffffffe000200e9c:	f6a43c23          	sd	a0,-136(s0)
ffffffe000200ea0:	f6b43823          	sd	a1,-144(s0)
ffffffe000200ea4:	f6c43423          	sd	a2,-152(s0)
ffffffe000200ea8:	f6d43023          	sd	a3,-160(s0)
ffffffe000200eac:	f4e43c23          	sd	a4,-168(s0)
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_curr=va;
ffffffe000200eb0:	f7043783          	ld	a5,-144(s0)
ffffffe000200eb4:	fef43423          	sd	a5,-24(s0)
    uint64_t pa_curr=pa;
ffffffe000200eb8:	f6843783          	ld	a5,-152(s0)
ffffffe000200ebc:	fef43023          	sd	a5,-32(s0)
    uint64_t va_end=va+sz;
ffffffe000200ec0:	f7043703          	ld	a4,-144(s0)
ffffffe000200ec4:	f6043783          	ld	a5,-160(s0)
ffffffe000200ec8:	00f707b3          	add	a5,a4,a5
ffffffe000200ecc:	fcf43c23          	sd	a5,-40(s0)

    while(va_curr<va_end){
ffffffe000200ed0:	1bc0006f          	j	ffffffe00020108c <create_mapping+0x200>
        uint64_t vpn2=(va_curr>>30)&0x1ff;  //VA[39:30]
ffffffe000200ed4:	fe843783          	ld	a5,-24(s0)
ffffffe000200ed8:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200edc:	1ff7f793          	andi	a5,a5,511
ffffffe000200ee0:	fcf43823          	sd	a5,-48(s0)
        uint64_t vpn1=(va_curr>>21)&0x1ff;  //VA[29:21]
ffffffe000200ee4:	fe843783          	ld	a5,-24(s0)
ffffffe000200ee8:	0157d793          	srli	a5,a5,0x15
ffffffe000200eec:	1ff7f793          	andi	a5,a5,511
ffffffe000200ef0:	fcf43423          	sd	a5,-56(s0)
        uint64_t vpn0=(va_curr>>12)&0x1ff;  //VA[20:12]
ffffffe000200ef4:	fe843783          	ld	a5,-24(s0)
ffffffe000200ef8:	00c7d793          	srli	a5,a5,0xc
ffffffe000200efc:	1ff7f793          	andi	a5,a5,511
ffffffe000200f00:	fcf43023          	sd	a5,-64(s0)

        
        if(!(pgtbl[vpn2]&PTE_V)){
ffffffe000200f04:	fd043783          	ld	a5,-48(s0)
ffffffe000200f08:	00379793          	slli	a5,a5,0x3
ffffffe000200f0c:	f7843703          	ld	a4,-136(s0)
ffffffe000200f10:	00f707b3          	add	a5,a4,a5
ffffffe000200f14:	0007b783          	ld	a5,0(a5)
ffffffe000200f18:	0017f793          	andi	a5,a5,1
ffffffe000200f1c:	04079a63          	bnez	a5,ffffffe000200f70 <create_mapping+0xe4>
            uint64_t *patbl2=(uint64_t *)kalloc();
ffffffe000200f20:	bb0ff0ef          	jal	ra,ffffffe0002002d0 <kalloc>
ffffffe000200f24:	faa43c23          	sd	a0,-72(s0)
            memset(patbl2,0,PGSIZE);
ffffffe000200f28:	00001637          	lui	a2,0x1
ffffffe000200f2c:	00000593          	li	a1,0
ffffffe000200f30:	fb843503          	ld	a0,-72(s0)
ffffffe000200f34:	338010ef          	jal	ra,ffffffe00020226c <memset>
            uint64_t patbl2_pa=(uint64_t)patbl2-PA2VA_OFFSET;
ffffffe000200f38:	fb843703          	ld	a4,-72(s0)
ffffffe000200f3c:	04100793          	li	a5,65
ffffffe000200f40:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f44:	00f707b3          	add	a5,a4,a5
ffffffe000200f48:	faf43823          	sd	a5,-80(s0)
            pgtbl[vpn2]=((uint64_t)patbl2_pa>>12)<<10|PTE_V;
ffffffe000200f4c:	fb043783          	ld	a5,-80(s0)
ffffffe000200f50:	00c7d793          	srli	a5,a5,0xc
ffffffe000200f54:	00a79713          	slli	a4,a5,0xa
ffffffe000200f58:	fd043783          	ld	a5,-48(s0)
ffffffe000200f5c:	00379793          	slli	a5,a5,0x3
ffffffe000200f60:	f7843683          	ld	a3,-136(s0)
ffffffe000200f64:	00f687b3          	add	a5,a3,a5
ffffffe000200f68:	00176713          	ori	a4,a4,1
ffffffe000200f6c:	00e7b023          	sd	a4,0(a5)
        }
        //二级页表物理地址
        uint64_t patbl2_pa=(uint64_t *)((pgtbl[vpn2]>>10)<<12); 
ffffffe000200f70:	fd043783          	ld	a5,-48(s0)
ffffffe000200f74:	00379793          	slli	a5,a5,0x3
ffffffe000200f78:	f7843703          	ld	a4,-136(s0)
ffffffe000200f7c:	00f707b3          	add	a5,a4,a5
ffffffe000200f80:	0007b783          	ld	a5,0(a5)
ffffffe000200f84:	00a7d793          	srli	a5,a5,0xa
ffffffe000200f88:	00c79793          	slli	a5,a5,0xc
ffffffe000200f8c:	faf43423          	sd	a5,-88(s0)
        uint64_t *patbl2=(uint64_t *)(patbl2_pa+PA2VA_OFFSET);              
ffffffe000200f90:	fa843703          	ld	a4,-88(s0)
ffffffe000200f94:	fbf00793          	li	a5,-65
ffffffe000200f98:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f9c:	00f707b3          	add	a5,a4,a5
ffffffe000200fa0:	faf43023          	sd	a5,-96(s0)

        if(!(patbl2[vpn1]&PTE_V)){
ffffffe000200fa4:	fc843783          	ld	a5,-56(s0)
ffffffe000200fa8:	00379793          	slli	a5,a5,0x3
ffffffe000200fac:	fa043703          	ld	a4,-96(s0)
ffffffe000200fb0:	00f707b3          	add	a5,a4,a5
ffffffe000200fb4:	0007b783          	ld	a5,0(a5)
ffffffe000200fb8:	0017f793          	andi	a5,a5,1
ffffffe000200fbc:	04079a63          	bnez	a5,ffffffe000201010 <create_mapping+0x184>
            uint64_t *patbl1=(uint64_t *)kalloc();
ffffffe000200fc0:	b10ff0ef          	jal	ra,ffffffe0002002d0 <kalloc>
ffffffe000200fc4:	f8a43c23          	sd	a0,-104(s0)
            memset(patbl1,0,PGSIZE);
ffffffe000200fc8:	00001637          	lui	a2,0x1
ffffffe000200fcc:	00000593          	li	a1,0
ffffffe000200fd0:	f9843503          	ld	a0,-104(s0)
ffffffe000200fd4:	298010ef          	jal	ra,ffffffe00020226c <memset>
            uint64_t patbl1_pa=(uint64_t)patbl1-PA2VA_OFFSET;
ffffffe000200fd8:	f9843703          	ld	a4,-104(s0)
ffffffe000200fdc:	04100793          	li	a5,65
ffffffe000200fe0:	01f79793          	slli	a5,a5,0x1f
ffffffe000200fe4:	00f707b3          	add	a5,a4,a5
ffffffe000200fe8:	f8f43823          	sd	a5,-112(s0)
            patbl2[vpn1]=((uint64_t)patbl1_pa>>12)<<10|PTE_V;
ffffffe000200fec:	f9043783          	ld	a5,-112(s0)
ffffffe000200ff0:	00c7d793          	srli	a5,a5,0xc
ffffffe000200ff4:	00a79713          	slli	a4,a5,0xa
ffffffe000200ff8:	fc843783          	ld	a5,-56(s0)
ffffffe000200ffc:	00379793          	slli	a5,a5,0x3
ffffffe000201000:	fa043683          	ld	a3,-96(s0)
ffffffe000201004:	00f687b3          	add	a5,a3,a5
ffffffe000201008:	00176713          	ori	a4,a4,1
ffffffe00020100c:	00e7b023          	sd	a4,0(a5)
        }
        //三级页表物理地址
        uint64_t patbl1_pa=(uint64_t *)((patbl2[vpn1]>>10)<<12); 
ffffffe000201010:	fc843783          	ld	a5,-56(s0)
ffffffe000201014:	00379793          	slli	a5,a5,0x3
ffffffe000201018:	fa043703          	ld	a4,-96(s0)
ffffffe00020101c:	00f707b3          	add	a5,a4,a5
ffffffe000201020:	0007b783          	ld	a5,0(a5)
ffffffe000201024:	00a7d793          	srli	a5,a5,0xa
ffffffe000201028:	00c79793          	slli	a5,a5,0xc
ffffffe00020102c:	f8f43423          	sd	a5,-120(s0)
        uint64_t *patbl1=(uint64_t *)(patbl1_pa+PA2VA_OFFSET);
ffffffe000201030:	f8843703          	ld	a4,-120(s0)
ffffffe000201034:	fbf00793          	li	a5,-65
ffffffe000201038:	01f79793          	slli	a5,a5,0x1f
ffffffe00020103c:	00f707b3          	add	a5,a4,a5
ffffffe000201040:	f8f43023          	sd	a5,-128(s0)
        //最终页表项
        patbl1[vpn0]=(pa_curr>>12)<<10|perm;
ffffffe000201044:	fe043783          	ld	a5,-32(s0)
ffffffe000201048:	00c7d793          	srli	a5,a5,0xc
ffffffe00020104c:	00a79693          	slli	a3,a5,0xa
ffffffe000201050:	fc043783          	ld	a5,-64(s0)
ffffffe000201054:	00379793          	slli	a5,a5,0x3
ffffffe000201058:	f8043703          	ld	a4,-128(s0)
ffffffe00020105c:	00f707b3          	add	a5,a4,a5
ffffffe000201060:	f5843703          	ld	a4,-168(s0)
ffffffe000201064:	00e6e733          	or	a4,a3,a4
ffffffe000201068:	00e7b023          	sd	a4,0(a5)

        va_curr+=PGSIZE;
ffffffe00020106c:	fe843703          	ld	a4,-24(s0)
ffffffe000201070:	000017b7          	lui	a5,0x1
ffffffe000201074:	00f707b3          	add	a5,a4,a5
ffffffe000201078:	fef43423          	sd	a5,-24(s0)
        pa_curr+=PGSIZE;
ffffffe00020107c:	fe043703          	ld	a4,-32(s0)
ffffffe000201080:	000017b7          	lui	a5,0x1
ffffffe000201084:	00f707b3          	add	a5,a4,a5
ffffffe000201088:	fef43023          	sd	a5,-32(s0)
    while(va_curr<va_end){
ffffffe00020108c:	fe843703          	ld	a4,-24(s0)
ffffffe000201090:	fd843783          	ld	a5,-40(s0)
ffffffe000201094:	e4f760e3          	bltu	a4,a5,ffffffe000200ed4 <create_mapping+0x48>
    }
}
ffffffe000201098:	00000013          	nop
ffffffe00020109c:	00000013          	nop
ffffffe0002010a0:	0a813083          	ld	ra,168(sp)
ffffffe0002010a4:	0a013403          	ld	s0,160(sp)
ffffffe0002010a8:	0b010113          	addi	sp,sp,176
ffffffe0002010ac:	00008067          	ret

ffffffe0002010b0 <setup_vm_final>:

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
ffffffe0002010b0:	fe010113          	addi	sp,sp,-32
ffffffe0002010b4:	00113c23          	sd	ra,24(sp)
ffffffe0002010b8:	00813823          	sd	s0,16(sp)
ffffffe0002010bc:	02010413          	addi	s0,sp,32
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe0002010c0:	00001637          	lui	a2,0x1
ffffffe0002010c4:	00000593          	li	a1,0
ffffffe0002010c8:	00006517          	auipc	a0,0x6
ffffffe0002010cc:	f3850513          	addi	a0,a0,-200 # ffffffe000207000 <swapper_pg_dir>
ffffffe0002010d0:	19c010ef          	jal	ra,ffffffe00020226c <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe0002010d4:	fffff597          	auipc	a1,0xfffff
ffffffe0002010d8:	f2c58593          	addi	a1,a1,-212 # ffffffe000200000 <_skernel>
ffffffe0002010dc:	fffff717          	auipc	a4,0xfffff
ffffffe0002010e0:	f2470713          	addi	a4,a4,-220 # ffffffe000200000 <_skernel>
ffffffe0002010e4:	04100793          	li	a5,65
ffffffe0002010e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002010ec:	00f707b3          	add	a5,a4,a5
ffffffe0002010f0:	00078613          	mv	a2,a5
                   (uint64_t)(_etext - _stext),PTE_X|PTE_R|PTE_V);
ffffffe0002010f4:	00001717          	auipc	a4,0x1
ffffffe0002010f8:	1e870713          	addi	a4,a4,488 # ffffffe0002022dc <_etext>
ffffffe0002010fc:	fffff797          	auipc	a5,0xfffff
ffffffe000201100:	f0478793          	addi	a5,a5,-252 # ffffffe000200000 <_skernel>
ffffffe000201104:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201108:	00b00713          	li	a4,11
ffffffe00020110c:	00078693          	mv	a3,a5
ffffffe000201110:	00006517          	auipc	a0,0x6
ffffffe000201114:	ef050513          	addi	a0,a0,-272 # ffffffe000207000 <swapper_pg_dir>
ffffffe000201118:	d75ff0ef          	jal	ra,ffffffe000200e8c <create_mapping>
    printk("setup_vm_final: mapping kernel text done!\n");
ffffffe00020111c:	00002517          	auipc	a0,0x2
ffffffe000201120:	fe450513          	addi	a0,a0,-28 # ffffffe000203100 <_srodata+0x100>
ffffffe000201124:	028010ef          	jal	ra,ffffffe00020214c <printk>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201128:	00002597          	auipc	a1,0x2
ffffffe00020112c:	ed858593          	addi	a1,a1,-296 # ffffffe000203000 <_srodata>
ffffffe000201130:	00002717          	auipc	a4,0x2
ffffffe000201134:	ed070713          	addi	a4,a4,-304 # ffffffe000203000 <_srodata>
ffffffe000201138:	04100793          	li	a5,65
ffffffe00020113c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201140:	00f707b3          	add	a5,a4,a5
ffffffe000201144:	00078613          	mv	a2,a5
                   (uint64_t)(_erodata - _srodata),PTE_R|PTE_V);
ffffffe000201148:	00002717          	auipc	a4,0x2
ffffffe00020114c:	0e870713          	addi	a4,a4,232 # ffffffe000203230 <_erodata>
ffffffe000201150:	00002797          	auipc	a5,0x2
ffffffe000201154:	eb078793          	addi	a5,a5,-336 # ffffffe000203000 <_srodata>
ffffffe000201158:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe00020115c:	00300713          	li	a4,3
ffffffe000201160:	00078693          	mv	a3,a5
ffffffe000201164:	00006517          	auipc	a0,0x6
ffffffe000201168:	e9c50513          	addi	a0,a0,-356 # ffffffe000207000 <swapper_pg_dir>
ffffffe00020116c:	d21ff0ef          	jal	ra,ffffffe000200e8c <create_mapping>
    printk("setup_vm_final: mapping kernel rodata done!\n");
ffffffe000201170:	00002517          	auipc	a0,0x2
ffffffe000201174:	fc050513          	addi	a0,a0,-64 # ffffffe000203130 <_srodata+0x130>
ffffffe000201178:	7d5000ef          	jal	ra,ffffffe00020214c <printk>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe00020117c:	00003597          	auipc	a1,0x3
ffffffe000201180:	e8458593          	addi	a1,a1,-380 # ffffffe000204000 <TIMECLOCK>
ffffffe000201184:	00003717          	auipc	a4,0x3
ffffffe000201188:	e7c70713          	addi	a4,a4,-388 # ffffffe000204000 <TIMECLOCK>
ffffffe00020118c:	04100793          	li	a5,65
ffffffe000201190:	01f79793          	slli	a5,a5,0x1f
ffffffe000201194:	00f707b3          	add	a5,a4,a5
ffffffe000201198:	00078613          	mv	a2,a5
                   (uint64_t)(PHY_END-((uint64_t)_sdata-PA2VA_OFFSET)),PTE_W|PTE_R|PTE_V);
ffffffe00020119c:	00003797          	auipc	a5,0x3
ffffffe0002011a0:	e6478793          	addi	a5,a5,-412 # ffffffe000204000 <TIMECLOCK>
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe0002011a4:	c0100713          	li	a4,-1023
ffffffe0002011a8:	01b71713          	slli	a4,a4,0x1b
ffffffe0002011ac:	40f707b3          	sub	a5,a4,a5
ffffffe0002011b0:	00700713          	li	a4,7
ffffffe0002011b4:	00078693          	mv	a3,a5
ffffffe0002011b8:	00006517          	auipc	a0,0x6
ffffffe0002011bc:	e4850513          	addi	a0,a0,-440 # ffffffe000207000 <swapper_pg_dir>
ffffffe0002011c0:	ccdff0ef          	jal	ra,ffffffe000200e8c <create_mapping>
    printk("setup_vm_final: mapping kernel data/bss/heap/stack done!\n");
ffffffe0002011c4:	00002517          	auipc	a0,0x2
ffffffe0002011c8:	f9c50513          	addi	a0,a0,-100 # ffffffe000203160 <_srodata+0x160>
ffffffe0002011cc:	781000ef          	jal	ra,ffffffe00020214c <printk>

    // set satp with swapper_pg_dir
    uint64_t satp_val=0;
ffffffe0002011d0:	fe043423          	sd	zero,-24(s0)
    satp_val|=(8ULL<<60);                          // MODE=8 Sv39
ffffffe0002011d4:	fe843703          	ld	a4,-24(s0)
ffffffe0002011d8:	fff00793          	li	a5,-1
ffffffe0002011dc:	03f79793          	slli	a5,a5,0x3f
ffffffe0002011e0:	00f767b3          	or	a5,a4,a5
ffffffe0002011e4:	fef43423          	sd	a5,-24(s0)
    satp_val|=(((uint64_t)swapper_pg_dir-PA2VA_OFFSET)>>12);   // PPN
ffffffe0002011e8:	00006717          	auipc	a4,0x6
ffffffe0002011ec:	e1870713          	addi	a4,a4,-488 # ffffffe000207000 <swapper_pg_dir>
ffffffe0002011f0:	04100793          	li	a5,65
ffffffe0002011f4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002011f8:	00f707b3          	add	a5,a4,a5
ffffffe0002011fc:	00c7d793          	srli	a5,a5,0xc
ffffffe000201200:	fe843703          	ld	a4,-24(s0)
ffffffe000201204:	00f767b3          	or	a5,a4,a5
ffffffe000201208:	fef43423          	sd	a5,-24(s0)
    csr_write(satp,satp_val);
ffffffe00020120c:	fe843783          	ld	a5,-24(s0)
ffffffe000201210:	fef43023          	sd	a5,-32(s0)
ffffffe000201214:	fe043783          	ld	a5,-32(s0)
ffffffe000201218:	18079073          	csrw	satp,a5

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe00020121c:	12000073          	sfence.vma
    return;
ffffffe000201220:	00000013          	nop
}
ffffffe000201224:	01813083          	ld	ra,24(sp)
ffffffe000201228:	01013403          	ld	s0,16(sp)
ffffffe00020122c:	02010113          	addi	sp,sp,32
ffffffe000201230:	00008067          	ret

ffffffe000201234 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
ffffffe000201234:	ff010113          	addi	sp,sp,-16
ffffffe000201238:	00113423          	sd	ra,8(sp)
ffffffe00020123c:	00813023          	sd	s0,0(sp)
ffffffe000201240:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201244:	00002517          	auipc	a0,0x2
ffffffe000201248:	f5c50513          	addi	a0,a0,-164 # ffffffe0002031a0 <_srodata+0x1a0>
ffffffe00020124c:	701000ef          	jal	ra,ffffffe00020214c <printk>
    printk(" ZJU Operating System\n");
ffffffe000201250:	00002517          	auipc	a0,0x2
ffffffe000201254:	f5850513          	addi	a0,a0,-168 # ffffffe0002031a8 <_srodata+0x1a8>
ffffffe000201258:	6f5000ef          	jal	ra,ffffffe00020214c <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
ffffffe00020125c:	01c000ef          	jal	ra,ffffffe000201278 <test>
    return 0;
ffffffe000201260:	00000793          	li	a5,0
}
ffffffe000201264:	00078513          	mv	a0,a5
ffffffe000201268:	00813083          	ld	ra,8(sp)
ffffffe00020126c:	00013403          	ld	s0,0(sp)
ffffffe000201270:	01010113          	addi	sp,sp,16
ffffffe000201274:	00008067          	ret

ffffffe000201278 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
ffffffe000201278:	fe010113          	addi	sp,sp,-32
ffffffe00020127c:	00113c23          	sd	ra,24(sp)
ffffffe000201280:	00813823          	sd	s0,16(sp)
ffffffe000201284:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
ffffffe000201288:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe00020128c:	fec42783          	lw	a5,-20(s0)
ffffffe000201290:	0017879b          	addiw	a5,a5,1
ffffffe000201294:	fef42623          	sw	a5,-20(s0)
ffffffe000201298:	fec42703          	lw	a4,-20(s0)
ffffffe00020129c:	05f5e7b7          	lui	a5,0x5f5e
ffffffe0002012a0:	1007879b          	addiw	a5,a5,256
ffffffe0002012a4:	02f767bb          	remw	a5,a4,a5
ffffffe0002012a8:	0007879b          	sext.w	a5,a5
ffffffe0002012ac:	fe0790e3          	bnez	a5,ffffffe00020128c <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
ffffffe0002012b0:	00002517          	auipc	a0,0x2
ffffffe0002012b4:	f1050513          	addi	a0,a0,-240 # ffffffe0002031c0 <_srodata+0x1c0>
ffffffe0002012b8:	695000ef          	jal	ra,ffffffe00020214c <printk>
            i = 0;
ffffffe0002012bc:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe0002012c0:	fcdff06f          	j	ffffffe00020128c <test+0x14>

ffffffe0002012c4 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe0002012c4:	fe010113          	addi	sp,sp,-32
ffffffe0002012c8:	00113c23          	sd	ra,24(sp)
ffffffe0002012cc:	00813823          	sd	s0,16(sp)
ffffffe0002012d0:	02010413          	addi	s0,sp,32
ffffffe0002012d4:	00050793          	mv	a5,a0
ffffffe0002012d8:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe0002012dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002012e0:	0ff7f793          	andi	a5,a5,255
ffffffe0002012e4:	00078513          	mv	a0,a5
ffffffe0002012e8:	919ff0ef          	jal	ra,ffffffe000200c00 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe0002012ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002012f0:	0ff7f793          	andi	a5,a5,255
ffffffe0002012f4:	0007879b          	sext.w	a5,a5
}
ffffffe0002012f8:	00078513          	mv	a0,a5
ffffffe0002012fc:	01813083          	ld	ra,24(sp)
ffffffe000201300:	01013403          	ld	s0,16(sp)
ffffffe000201304:	02010113          	addi	sp,sp,32
ffffffe000201308:	00008067          	ret

ffffffe00020130c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe00020130c:	fe010113          	addi	sp,sp,-32
ffffffe000201310:	00813c23          	sd	s0,24(sp)
ffffffe000201314:	02010413          	addi	s0,sp,32
ffffffe000201318:	00050793          	mv	a5,a0
ffffffe00020131c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201320:	fec42783          	lw	a5,-20(s0)
ffffffe000201324:	0007871b          	sext.w	a4,a5
ffffffe000201328:	02000793          	li	a5,32
ffffffe00020132c:	02f70263          	beq	a4,a5,ffffffe000201350 <isspace+0x44>
ffffffe000201330:	fec42783          	lw	a5,-20(s0)
ffffffe000201334:	0007871b          	sext.w	a4,a5
ffffffe000201338:	00800793          	li	a5,8
ffffffe00020133c:	00e7de63          	bge	a5,a4,ffffffe000201358 <isspace+0x4c>
ffffffe000201340:	fec42783          	lw	a5,-20(s0)
ffffffe000201344:	0007871b          	sext.w	a4,a5
ffffffe000201348:	00d00793          	li	a5,13
ffffffe00020134c:	00e7c663          	blt	a5,a4,ffffffe000201358 <isspace+0x4c>
ffffffe000201350:	00100793          	li	a5,1
ffffffe000201354:	0080006f          	j	ffffffe00020135c <isspace+0x50>
ffffffe000201358:	00000793          	li	a5,0
}
ffffffe00020135c:	00078513          	mv	a0,a5
ffffffe000201360:	01813403          	ld	s0,24(sp)
ffffffe000201364:	02010113          	addi	sp,sp,32
ffffffe000201368:	00008067          	ret

ffffffe00020136c <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe00020136c:	fb010113          	addi	sp,sp,-80
ffffffe000201370:	04113423          	sd	ra,72(sp)
ffffffe000201374:	04813023          	sd	s0,64(sp)
ffffffe000201378:	05010413          	addi	s0,sp,80
ffffffe00020137c:	fca43423          	sd	a0,-56(s0)
ffffffe000201380:	fcb43023          	sd	a1,-64(s0)
ffffffe000201384:	00060793          	mv	a5,a2
ffffffe000201388:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe00020138c:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000201390:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000201394:	fc843783          	ld	a5,-56(s0)
ffffffe000201398:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe00020139c:	0100006f          	j	ffffffe0002013ac <strtol+0x40>
        p++;
ffffffe0002013a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013a4:	00178793          	addi	a5,a5,1 # 5f5e001 <OPENSBI_SIZE+0x5d5e001>
ffffffe0002013a8:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002013ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002013b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002013b4:	0007879b          	sext.w	a5,a5
ffffffe0002013b8:	00078513          	mv	a0,a5
ffffffe0002013bc:	f51ff0ef          	jal	ra,ffffffe00020130c <isspace>
ffffffe0002013c0:	00050793          	mv	a5,a0
ffffffe0002013c4:	fc079ee3          	bnez	a5,ffffffe0002013a0 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002013c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002013d0:	00078713          	mv	a4,a5
ffffffe0002013d4:	02d00793          	li	a5,45
ffffffe0002013d8:	00f71e63          	bne	a4,a5,ffffffe0002013f4 <strtol+0x88>
        neg = true;
ffffffe0002013dc:	00100793          	li	a5,1
ffffffe0002013e0:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe0002013e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002013e8:	00178793          	addi	a5,a5,1
ffffffe0002013ec:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002013f0:	0240006f          	j	ffffffe000201414 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe0002013f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002013f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002013fc:	00078713          	mv	a4,a5
ffffffe000201400:	02b00793          	li	a5,43
ffffffe000201404:	00f71863          	bne	a4,a5,ffffffe000201414 <strtol+0xa8>
        p++;
ffffffe000201408:	fd843783          	ld	a5,-40(s0)
ffffffe00020140c:	00178793          	addi	a5,a5,1
ffffffe000201410:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201414:	fbc42783          	lw	a5,-68(s0)
ffffffe000201418:	0007879b          	sext.w	a5,a5
ffffffe00020141c:	06079c63          	bnez	a5,ffffffe000201494 <strtol+0x128>
        if (*p == '0') {
ffffffe000201420:	fd843783          	ld	a5,-40(s0)
ffffffe000201424:	0007c783          	lbu	a5,0(a5)
ffffffe000201428:	00078713          	mv	a4,a5
ffffffe00020142c:	03000793          	li	a5,48
ffffffe000201430:	04f71e63          	bne	a4,a5,ffffffe00020148c <strtol+0x120>
            p++;
ffffffe000201434:	fd843783          	ld	a5,-40(s0)
ffffffe000201438:	00178793          	addi	a5,a5,1
ffffffe00020143c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201440:	fd843783          	ld	a5,-40(s0)
ffffffe000201444:	0007c783          	lbu	a5,0(a5)
ffffffe000201448:	00078713          	mv	a4,a5
ffffffe00020144c:	07800793          	li	a5,120
ffffffe000201450:	00f70c63          	beq	a4,a5,ffffffe000201468 <strtol+0xfc>
ffffffe000201454:	fd843783          	ld	a5,-40(s0)
ffffffe000201458:	0007c783          	lbu	a5,0(a5)
ffffffe00020145c:	00078713          	mv	a4,a5
ffffffe000201460:	05800793          	li	a5,88
ffffffe000201464:	00f71e63          	bne	a4,a5,ffffffe000201480 <strtol+0x114>
                base = 16;
ffffffe000201468:	01000793          	li	a5,16
ffffffe00020146c:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000201470:	fd843783          	ld	a5,-40(s0)
ffffffe000201474:	00178793          	addi	a5,a5,1
ffffffe000201478:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020147c:	0180006f          	j	ffffffe000201494 <strtol+0x128>
            } else {
                base = 8;
ffffffe000201480:	00800793          	li	a5,8
ffffffe000201484:	faf42e23          	sw	a5,-68(s0)
ffffffe000201488:	00c0006f          	j	ffffffe000201494 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe00020148c:	00a00793          	li	a5,10
ffffffe000201490:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000201494:	fd843783          	ld	a5,-40(s0)
ffffffe000201498:	0007c783          	lbu	a5,0(a5)
ffffffe00020149c:	00078713          	mv	a4,a5
ffffffe0002014a0:	02f00793          	li	a5,47
ffffffe0002014a4:	02e7f863          	bgeu	a5,a4,ffffffe0002014d4 <strtol+0x168>
ffffffe0002014a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002014ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002014b0:	00078713          	mv	a4,a5
ffffffe0002014b4:	03900793          	li	a5,57
ffffffe0002014b8:	00e7ee63          	bltu	a5,a4,ffffffe0002014d4 <strtol+0x168>
            digit = *p - '0';
ffffffe0002014bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002014c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002014c4:	0007879b          	sext.w	a5,a5
ffffffe0002014c8:	fd07879b          	addiw	a5,a5,-48
ffffffe0002014cc:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002014d0:	0800006f          	j	ffffffe000201550 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002014d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002014d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002014dc:	00078713          	mv	a4,a5
ffffffe0002014e0:	06000793          	li	a5,96
ffffffe0002014e4:	02e7f863          	bgeu	a5,a4,ffffffe000201514 <strtol+0x1a8>
ffffffe0002014e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002014ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002014f0:	00078713          	mv	a4,a5
ffffffe0002014f4:	07a00793          	li	a5,122
ffffffe0002014f8:	00e7ee63          	bltu	a5,a4,ffffffe000201514 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe0002014fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201500:	0007c783          	lbu	a5,0(a5)
ffffffe000201504:	0007879b          	sext.w	a5,a5
ffffffe000201508:	fa97879b          	addiw	a5,a5,-87
ffffffe00020150c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201510:	0400006f          	j	ffffffe000201550 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201514:	fd843783          	ld	a5,-40(s0)
ffffffe000201518:	0007c783          	lbu	a5,0(a5)
ffffffe00020151c:	00078713          	mv	a4,a5
ffffffe000201520:	04000793          	li	a5,64
ffffffe000201524:	06e7f663          	bgeu	a5,a4,ffffffe000201590 <strtol+0x224>
ffffffe000201528:	fd843783          	ld	a5,-40(s0)
ffffffe00020152c:	0007c783          	lbu	a5,0(a5)
ffffffe000201530:	00078713          	mv	a4,a5
ffffffe000201534:	05a00793          	li	a5,90
ffffffe000201538:	04e7ec63          	bltu	a5,a4,ffffffe000201590 <strtol+0x224>
            digit = *p - ('A' - 10);
ffffffe00020153c:	fd843783          	ld	a5,-40(s0)
ffffffe000201540:	0007c783          	lbu	a5,0(a5)
ffffffe000201544:	0007879b          	sext.w	a5,a5
ffffffe000201548:	fc97879b          	addiw	a5,a5,-55
ffffffe00020154c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201550:	fd442703          	lw	a4,-44(s0)
ffffffe000201554:	fbc42783          	lw	a5,-68(s0)
ffffffe000201558:	0007071b          	sext.w	a4,a4
ffffffe00020155c:	0007879b          	sext.w	a5,a5
ffffffe000201560:	02f75663          	bge	a4,a5,ffffffe00020158c <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
ffffffe000201564:	fbc42703          	lw	a4,-68(s0)
ffffffe000201568:	fe843783          	ld	a5,-24(s0)
ffffffe00020156c:	02f70733          	mul	a4,a4,a5
ffffffe000201570:	fd442783          	lw	a5,-44(s0)
ffffffe000201574:	00f707b3          	add	a5,a4,a5
ffffffe000201578:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe00020157c:	fd843783          	ld	a5,-40(s0)
ffffffe000201580:	00178793          	addi	a5,a5,1
ffffffe000201584:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000201588:	f0dff06f          	j	ffffffe000201494 <strtol+0x128>
            break;
ffffffe00020158c:	00000013          	nop
    }

    if (endptr) {
ffffffe000201590:	fc043783          	ld	a5,-64(s0)
ffffffe000201594:	00078863          	beqz	a5,ffffffe0002015a4 <strtol+0x238>
        *endptr = (char *)p;
ffffffe000201598:	fc043783          	ld	a5,-64(s0)
ffffffe00020159c:	fd843703          	ld	a4,-40(s0)
ffffffe0002015a0:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe0002015a4:	fe744783          	lbu	a5,-25(s0)
ffffffe0002015a8:	0ff7f793          	andi	a5,a5,255
ffffffe0002015ac:	00078863          	beqz	a5,ffffffe0002015bc <strtol+0x250>
ffffffe0002015b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002015b4:	40f007b3          	neg	a5,a5
ffffffe0002015b8:	0080006f          	j	ffffffe0002015c0 <strtol+0x254>
ffffffe0002015bc:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002015c0:	00078513          	mv	a0,a5
ffffffe0002015c4:	04813083          	ld	ra,72(sp)
ffffffe0002015c8:	04013403          	ld	s0,64(sp)
ffffffe0002015cc:	05010113          	addi	sp,sp,80
ffffffe0002015d0:	00008067          	ret

ffffffe0002015d4 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe0002015d4:	fd010113          	addi	sp,sp,-48
ffffffe0002015d8:	02113423          	sd	ra,40(sp)
ffffffe0002015dc:	02813023          	sd	s0,32(sp)
ffffffe0002015e0:	03010413          	addi	s0,sp,48
ffffffe0002015e4:	fca43c23          	sd	a0,-40(s0)
ffffffe0002015e8:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002015ec:	fd043783          	ld	a5,-48(s0)
ffffffe0002015f0:	00079863          	bnez	a5,ffffffe000201600 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002015f4:	00002797          	auipc	a5,0x2
ffffffe0002015f8:	be478793          	addi	a5,a5,-1052 # ffffffe0002031d8 <_srodata+0x1d8>
ffffffe0002015fc:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000201600:	fd043783          	ld	a5,-48(s0)
ffffffe000201604:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201608:	0240006f          	j	ffffffe00020162c <puts_wo_nl+0x58>
        putch(*p++);
ffffffe00020160c:	fe843783          	ld	a5,-24(s0)
ffffffe000201610:	00178713          	addi	a4,a5,1
ffffffe000201614:	fee43423          	sd	a4,-24(s0)
ffffffe000201618:	0007c783          	lbu	a5,0(a5)
ffffffe00020161c:	0007879b          	sext.w	a5,a5
ffffffe000201620:	fd843703          	ld	a4,-40(s0)
ffffffe000201624:	00078513          	mv	a0,a5
ffffffe000201628:	000700e7          	jalr	a4
    while (*p) {
ffffffe00020162c:	fe843783          	ld	a5,-24(s0)
ffffffe000201630:	0007c783          	lbu	a5,0(a5)
ffffffe000201634:	fc079ce3          	bnez	a5,ffffffe00020160c <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201638:	fe843703          	ld	a4,-24(s0)
ffffffe00020163c:	fd043783          	ld	a5,-48(s0)
ffffffe000201640:	40f707b3          	sub	a5,a4,a5
ffffffe000201644:	0007879b          	sext.w	a5,a5
}
ffffffe000201648:	00078513          	mv	a0,a5
ffffffe00020164c:	02813083          	ld	ra,40(sp)
ffffffe000201650:	02013403          	ld	s0,32(sp)
ffffffe000201654:	03010113          	addi	sp,sp,48
ffffffe000201658:	00008067          	ret

ffffffe00020165c <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe00020165c:	f9010113          	addi	sp,sp,-112
ffffffe000201660:	06113423          	sd	ra,104(sp)
ffffffe000201664:	06813023          	sd	s0,96(sp)
ffffffe000201668:	07010413          	addi	s0,sp,112
ffffffe00020166c:	faa43423          	sd	a0,-88(s0)
ffffffe000201670:	fab43023          	sd	a1,-96(s0)
ffffffe000201674:	00060793          	mv	a5,a2
ffffffe000201678:	f8d43823          	sd	a3,-112(s0)
ffffffe00020167c:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000201680:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201684:	0ff7f793          	andi	a5,a5,255
ffffffe000201688:	02078663          	beqz	a5,ffffffe0002016b4 <print_dec_int+0x58>
ffffffe00020168c:	fa043703          	ld	a4,-96(s0)
ffffffe000201690:	fff00793          	li	a5,-1
ffffffe000201694:	03f79793          	slli	a5,a5,0x3f
ffffffe000201698:	00f71e63          	bne	a4,a5,ffffffe0002016b4 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe00020169c:	00002597          	auipc	a1,0x2
ffffffe0002016a0:	b4458593          	addi	a1,a1,-1212 # ffffffe0002031e0 <_srodata+0x1e0>
ffffffe0002016a4:	fa843503          	ld	a0,-88(s0)
ffffffe0002016a8:	f2dff0ef          	jal	ra,ffffffe0002015d4 <puts_wo_nl>
ffffffe0002016ac:	00050793          	mv	a5,a0
ffffffe0002016b0:	2980006f          	j	ffffffe000201948 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe0002016b4:	f9043783          	ld	a5,-112(s0)
ffffffe0002016b8:	00c7a783          	lw	a5,12(a5)
ffffffe0002016bc:	00079a63          	bnez	a5,ffffffe0002016d0 <print_dec_int+0x74>
ffffffe0002016c0:	fa043783          	ld	a5,-96(s0)
ffffffe0002016c4:	00079663          	bnez	a5,ffffffe0002016d0 <print_dec_int+0x74>
        return 0;
ffffffe0002016c8:	00000793          	li	a5,0
ffffffe0002016cc:	27c0006f          	j	ffffffe000201948 <print_dec_int+0x2ec>
    }

    bool neg = false;
ffffffe0002016d0:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe0002016d4:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002016d8:	0ff7f793          	andi	a5,a5,255
ffffffe0002016dc:	02078063          	beqz	a5,ffffffe0002016fc <print_dec_int+0xa0>
ffffffe0002016e0:	fa043783          	ld	a5,-96(s0)
ffffffe0002016e4:	0007dc63          	bgez	a5,ffffffe0002016fc <print_dec_int+0xa0>
        neg = true;
ffffffe0002016e8:	00100793          	li	a5,1
ffffffe0002016ec:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe0002016f0:	fa043783          	ld	a5,-96(s0)
ffffffe0002016f4:	40f007b3          	neg	a5,a5
ffffffe0002016f8:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe0002016fc:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000201700:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201704:	0ff7f793          	andi	a5,a5,255
ffffffe000201708:	02078863          	beqz	a5,ffffffe000201738 <print_dec_int+0xdc>
ffffffe00020170c:	fef44783          	lbu	a5,-17(s0)
ffffffe000201710:	0ff7f793          	andi	a5,a5,255
ffffffe000201714:	00079e63          	bnez	a5,ffffffe000201730 <print_dec_int+0xd4>
ffffffe000201718:	f9043783          	ld	a5,-112(s0)
ffffffe00020171c:	0057c783          	lbu	a5,5(a5)
ffffffe000201720:	00079863          	bnez	a5,ffffffe000201730 <print_dec_int+0xd4>
ffffffe000201724:	f9043783          	ld	a5,-112(s0)
ffffffe000201728:	0047c783          	lbu	a5,4(a5)
ffffffe00020172c:	00078663          	beqz	a5,ffffffe000201738 <print_dec_int+0xdc>
ffffffe000201730:	00100793          	li	a5,1
ffffffe000201734:	0080006f          	j	ffffffe00020173c <print_dec_int+0xe0>
ffffffe000201738:	00000793          	li	a5,0
ffffffe00020173c:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000201740:	fd744783          	lbu	a5,-41(s0)
ffffffe000201744:	0017f793          	andi	a5,a5,1
ffffffe000201748:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe00020174c:	fa043703          	ld	a4,-96(s0)
ffffffe000201750:	00a00793          	li	a5,10
ffffffe000201754:	02f777b3          	remu	a5,a4,a5
ffffffe000201758:	0ff7f713          	andi	a4,a5,255
ffffffe00020175c:	fe842783          	lw	a5,-24(s0)
ffffffe000201760:	0017869b          	addiw	a3,a5,1
ffffffe000201764:	fed42423          	sw	a3,-24(s0)
ffffffe000201768:	0307071b          	addiw	a4,a4,48
ffffffe00020176c:	0ff77713          	andi	a4,a4,255
ffffffe000201770:	ff040693          	addi	a3,s0,-16
ffffffe000201774:	00f687b3          	add	a5,a3,a5
ffffffe000201778:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe00020177c:	fa043703          	ld	a4,-96(s0)
ffffffe000201780:	00a00793          	li	a5,10
ffffffe000201784:	02f757b3          	divu	a5,a4,a5
ffffffe000201788:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe00020178c:	fa043783          	ld	a5,-96(s0)
ffffffe000201790:	fa079ee3          	bnez	a5,ffffffe00020174c <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000201794:	f9043783          	ld	a5,-112(s0)
ffffffe000201798:	00c7a783          	lw	a5,12(a5)
ffffffe00020179c:	00078713          	mv	a4,a5
ffffffe0002017a0:	fff00793          	li	a5,-1
ffffffe0002017a4:	02f71063          	bne	a4,a5,ffffffe0002017c4 <print_dec_int+0x168>
ffffffe0002017a8:	f9043783          	ld	a5,-112(s0)
ffffffe0002017ac:	0037c783          	lbu	a5,3(a5)
ffffffe0002017b0:	00078a63          	beqz	a5,ffffffe0002017c4 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe0002017b4:	f9043783          	ld	a5,-112(s0)
ffffffe0002017b8:	0087a703          	lw	a4,8(a5)
ffffffe0002017bc:	f9043783          	ld	a5,-112(s0)
ffffffe0002017c0:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002017c4:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002017c8:	f9043783          	ld	a5,-112(s0)
ffffffe0002017cc:	0087a703          	lw	a4,8(a5)
ffffffe0002017d0:	fe842783          	lw	a5,-24(s0)
ffffffe0002017d4:	fcf42823          	sw	a5,-48(s0)
ffffffe0002017d8:	f9043783          	ld	a5,-112(s0)
ffffffe0002017dc:	00c7a783          	lw	a5,12(a5)
ffffffe0002017e0:	fcf42623          	sw	a5,-52(s0)
ffffffe0002017e4:	fd042583          	lw	a1,-48(s0)
ffffffe0002017e8:	fcc42783          	lw	a5,-52(s0)
ffffffe0002017ec:	0007861b          	sext.w	a2,a5
ffffffe0002017f0:	0005869b          	sext.w	a3,a1
ffffffe0002017f4:	00d65463          	bge	a2,a3,ffffffe0002017fc <print_dec_int+0x1a0>
ffffffe0002017f8:	00058793          	mv	a5,a1
ffffffe0002017fc:	0007879b          	sext.w	a5,a5
ffffffe000201800:	40f707bb          	subw	a5,a4,a5
ffffffe000201804:	0007871b          	sext.w	a4,a5
ffffffe000201808:	fd744783          	lbu	a5,-41(s0)
ffffffe00020180c:	0007879b          	sext.w	a5,a5
ffffffe000201810:	40f707bb          	subw	a5,a4,a5
ffffffe000201814:	fef42023          	sw	a5,-32(s0)
ffffffe000201818:	0280006f          	j	ffffffe000201840 <print_dec_int+0x1e4>
        putch(' ');
ffffffe00020181c:	fa843783          	ld	a5,-88(s0)
ffffffe000201820:	02000513          	li	a0,32
ffffffe000201824:	000780e7          	jalr	a5
        ++written;
ffffffe000201828:	fe442783          	lw	a5,-28(s0)
ffffffe00020182c:	0017879b          	addiw	a5,a5,1
ffffffe000201830:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201834:	fe042783          	lw	a5,-32(s0)
ffffffe000201838:	fff7879b          	addiw	a5,a5,-1
ffffffe00020183c:	fef42023          	sw	a5,-32(s0)
ffffffe000201840:	fe042783          	lw	a5,-32(s0)
ffffffe000201844:	0007879b          	sext.w	a5,a5
ffffffe000201848:	fcf04ae3          	bgtz	a5,ffffffe00020181c <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
ffffffe00020184c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201850:	0ff7f793          	andi	a5,a5,255
ffffffe000201854:	04078463          	beqz	a5,ffffffe00020189c <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000201858:	fef44783          	lbu	a5,-17(s0)
ffffffe00020185c:	0ff7f793          	andi	a5,a5,255
ffffffe000201860:	00078663          	beqz	a5,ffffffe00020186c <print_dec_int+0x210>
ffffffe000201864:	02d00793          	li	a5,45
ffffffe000201868:	01c0006f          	j	ffffffe000201884 <print_dec_int+0x228>
ffffffe00020186c:	f9043783          	ld	a5,-112(s0)
ffffffe000201870:	0057c783          	lbu	a5,5(a5)
ffffffe000201874:	00078663          	beqz	a5,ffffffe000201880 <print_dec_int+0x224>
ffffffe000201878:	02b00793          	li	a5,43
ffffffe00020187c:	0080006f          	j	ffffffe000201884 <print_dec_int+0x228>
ffffffe000201880:	02000793          	li	a5,32
ffffffe000201884:	fa843703          	ld	a4,-88(s0)
ffffffe000201888:	00078513          	mv	a0,a5
ffffffe00020188c:	000700e7          	jalr	a4
        ++written;
ffffffe000201890:	fe442783          	lw	a5,-28(s0)
ffffffe000201894:	0017879b          	addiw	a5,a5,1
ffffffe000201898:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe00020189c:	fe842783          	lw	a5,-24(s0)
ffffffe0002018a0:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002018a4:	0280006f          	j	ffffffe0002018cc <print_dec_int+0x270>
        putch('0');
ffffffe0002018a8:	fa843783          	ld	a5,-88(s0)
ffffffe0002018ac:	03000513          	li	a0,48
ffffffe0002018b0:	000780e7          	jalr	a5
        ++written;
ffffffe0002018b4:	fe442783          	lw	a5,-28(s0)
ffffffe0002018b8:	0017879b          	addiw	a5,a5,1
ffffffe0002018bc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002018c0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002018c4:	0017879b          	addiw	a5,a5,1
ffffffe0002018c8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002018cc:	f9043783          	ld	a5,-112(s0)
ffffffe0002018d0:	00c7a703          	lw	a4,12(a5)
ffffffe0002018d4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002018d8:	0007879b          	sext.w	a5,a5
ffffffe0002018dc:	40f707bb          	subw	a5,a4,a5
ffffffe0002018e0:	0007871b          	sext.w	a4,a5
ffffffe0002018e4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002018e8:	0007879b          	sext.w	a5,a5
ffffffe0002018ec:	fae7cee3          	blt	a5,a4,ffffffe0002018a8 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002018f0:	fe842783          	lw	a5,-24(s0)
ffffffe0002018f4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002018f8:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002018fc:	03c0006f          	j	ffffffe000201938 <print_dec_int+0x2dc>
        putch(buf[i]);
ffffffe000201900:	fd842783          	lw	a5,-40(s0)
ffffffe000201904:	ff040713          	addi	a4,s0,-16
ffffffe000201908:	00f707b3          	add	a5,a4,a5
ffffffe00020190c:	fc87c783          	lbu	a5,-56(a5)
ffffffe000201910:	0007879b          	sext.w	a5,a5
ffffffe000201914:	fa843703          	ld	a4,-88(s0)
ffffffe000201918:	00078513          	mv	a0,a5
ffffffe00020191c:	000700e7          	jalr	a4
        ++written;
ffffffe000201920:	fe442783          	lw	a5,-28(s0)
ffffffe000201924:	0017879b          	addiw	a5,a5,1
ffffffe000201928:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe00020192c:	fd842783          	lw	a5,-40(s0)
ffffffe000201930:	fff7879b          	addiw	a5,a5,-1
ffffffe000201934:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201938:	fd842783          	lw	a5,-40(s0)
ffffffe00020193c:	0007879b          	sext.w	a5,a5
ffffffe000201940:	fc07d0e3          	bgez	a5,ffffffe000201900 <print_dec_int+0x2a4>
    }

    return written;
ffffffe000201944:	fe442783          	lw	a5,-28(s0)
}
ffffffe000201948:	00078513          	mv	a0,a5
ffffffe00020194c:	06813083          	ld	ra,104(sp)
ffffffe000201950:	06013403          	ld	s0,96(sp)
ffffffe000201954:	07010113          	addi	sp,sp,112
ffffffe000201958:	00008067          	ret

ffffffe00020195c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe00020195c:	f4010113          	addi	sp,sp,-192
ffffffe000201960:	0a113c23          	sd	ra,184(sp)
ffffffe000201964:	0a813823          	sd	s0,176(sp)
ffffffe000201968:	0c010413          	addi	s0,sp,192
ffffffe00020196c:	f4a43c23          	sd	a0,-168(s0)
ffffffe000201970:	f4b43823          	sd	a1,-176(s0)
ffffffe000201974:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000201978:	f8043023          	sd	zero,-128(s0)
ffffffe00020197c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000201980:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000201984:	7a40006f          	j	ffffffe000202128 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000201988:	f8044783          	lbu	a5,-128(s0)
ffffffe00020198c:	72078e63          	beqz	a5,ffffffe0002020c8 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000201990:	f5043783          	ld	a5,-176(s0)
ffffffe000201994:	0007c783          	lbu	a5,0(a5)
ffffffe000201998:	00078713          	mv	a4,a5
ffffffe00020199c:	02300793          	li	a5,35
ffffffe0002019a0:	00f71863          	bne	a4,a5,ffffffe0002019b0 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe0002019a4:	00100793          	li	a5,1
ffffffe0002019a8:	f8f40123          	sb	a5,-126(s0)
ffffffe0002019ac:	7700006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe0002019b0:	f5043783          	ld	a5,-176(s0)
ffffffe0002019b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002019b8:	00078713          	mv	a4,a5
ffffffe0002019bc:	03000793          	li	a5,48
ffffffe0002019c0:	00f71863          	bne	a4,a5,ffffffe0002019d0 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002019c4:	00100793          	li	a5,1
ffffffe0002019c8:	f8f401a3          	sb	a5,-125(s0)
ffffffe0002019cc:	7500006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe0002019d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002019d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002019d8:	00078713          	mv	a4,a5
ffffffe0002019dc:	06c00793          	li	a5,108
ffffffe0002019e0:	04f70063          	beq	a4,a5,ffffffe000201a20 <vprintfmt+0xc4>
ffffffe0002019e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002019e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002019ec:	00078713          	mv	a4,a5
ffffffe0002019f0:	07a00793          	li	a5,122
ffffffe0002019f4:	02f70663          	beq	a4,a5,ffffffe000201a20 <vprintfmt+0xc4>
ffffffe0002019f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002019fc:	0007c783          	lbu	a5,0(a5)
ffffffe000201a00:	00078713          	mv	a4,a5
ffffffe000201a04:	07400793          	li	a5,116
ffffffe000201a08:	00f70c63          	beq	a4,a5,ffffffe000201a20 <vprintfmt+0xc4>
ffffffe000201a0c:	f5043783          	ld	a5,-176(s0)
ffffffe000201a10:	0007c783          	lbu	a5,0(a5)
ffffffe000201a14:	00078713          	mv	a4,a5
ffffffe000201a18:	06a00793          	li	a5,106
ffffffe000201a1c:	00f71863          	bne	a4,a5,ffffffe000201a2c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000201a20:	00100793          	li	a5,1
ffffffe000201a24:	f8f400a3          	sb	a5,-127(s0)
ffffffe000201a28:	6f40006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000201a2c:	f5043783          	ld	a5,-176(s0)
ffffffe000201a30:	0007c783          	lbu	a5,0(a5)
ffffffe000201a34:	00078713          	mv	a4,a5
ffffffe000201a38:	02b00793          	li	a5,43
ffffffe000201a3c:	00f71863          	bne	a4,a5,ffffffe000201a4c <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000201a40:	00100793          	li	a5,1
ffffffe000201a44:	f8f402a3          	sb	a5,-123(s0)
ffffffe000201a48:	6d40006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000201a4c:	f5043783          	ld	a5,-176(s0)
ffffffe000201a50:	0007c783          	lbu	a5,0(a5)
ffffffe000201a54:	00078713          	mv	a4,a5
ffffffe000201a58:	02000793          	li	a5,32
ffffffe000201a5c:	00f71863          	bne	a4,a5,ffffffe000201a6c <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000201a60:	00100793          	li	a5,1
ffffffe000201a64:	f8f40223          	sb	a5,-124(s0)
ffffffe000201a68:	6b40006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000201a6c:	f5043783          	ld	a5,-176(s0)
ffffffe000201a70:	0007c783          	lbu	a5,0(a5)
ffffffe000201a74:	00078713          	mv	a4,a5
ffffffe000201a78:	02a00793          	li	a5,42
ffffffe000201a7c:	00f71e63          	bne	a4,a5,ffffffe000201a98 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000201a80:	f4843783          	ld	a5,-184(s0)
ffffffe000201a84:	00878713          	addi	a4,a5,8
ffffffe000201a88:	f4e43423          	sd	a4,-184(s0)
ffffffe000201a8c:	0007a783          	lw	a5,0(a5)
ffffffe000201a90:	f8f42423          	sw	a5,-120(s0)
ffffffe000201a94:	6880006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000201a98:	f5043783          	ld	a5,-176(s0)
ffffffe000201a9c:	0007c783          	lbu	a5,0(a5)
ffffffe000201aa0:	00078713          	mv	a4,a5
ffffffe000201aa4:	03000793          	li	a5,48
ffffffe000201aa8:	04e7f663          	bgeu	a5,a4,ffffffe000201af4 <vprintfmt+0x198>
ffffffe000201aac:	f5043783          	ld	a5,-176(s0)
ffffffe000201ab0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ab4:	00078713          	mv	a4,a5
ffffffe000201ab8:	03900793          	li	a5,57
ffffffe000201abc:	02e7ec63          	bltu	a5,a4,ffffffe000201af4 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000201ac0:	f5043783          	ld	a5,-176(s0)
ffffffe000201ac4:	f5040713          	addi	a4,s0,-176
ffffffe000201ac8:	00a00613          	li	a2,10
ffffffe000201acc:	00070593          	mv	a1,a4
ffffffe000201ad0:	00078513          	mv	a0,a5
ffffffe000201ad4:	899ff0ef          	jal	ra,ffffffe00020136c <strtol>
ffffffe000201ad8:	00050793          	mv	a5,a0
ffffffe000201adc:	0007879b          	sext.w	a5,a5
ffffffe000201ae0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000201ae4:	f5043783          	ld	a5,-176(s0)
ffffffe000201ae8:	fff78793          	addi	a5,a5,-1
ffffffe000201aec:	f4f43823          	sd	a5,-176(s0)
ffffffe000201af0:	62c0006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000201af4:	f5043783          	ld	a5,-176(s0)
ffffffe000201af8:	0007c783          	lbu	a5,0(a5)
ffffffe000201afc:	00078713          	mv	a4,a5
ffffffe000201b00:	02e00793          	li	a5,46
ffffffe000201b04:	06f71863          	bne	a4,a5,ffffffe000201b74 <vprintfmt+0x218>
                fmt++;
ffffffe000201b08:	f5043783          	ld	a5,-176(s0)
ffffffe000201b0c:	00178793          	addi	a5,a5,1
ffffffe000201b10:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000201b14:	f5043783          	ld	a5,-176(s0)
ffffffe000201b18:	0007c783          	lbu	a5,0(a5)
ffffffe000201b1c:	00078713          	mv	a4,a5
ffffffe000201b20:	02a00793          	li	a5,42
ffffffe000201b24:	00f71e63          	bne	a4,a5,ffffffe000201b40 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000201b28:	f4843783          	ld	a5,-184(s0)
ffffffe000201b2c:	00878713          	addi	a4,a5,8
ffffffe000201b30:	f4e43423          	sd	a4,-184(s0)
ffffffe000201b34:	0007a783          	lw	a5,0(a5)
ffffffe000201b38:	f8f42623          	sw	a5,-116(s0)
ffffffe000201b3c:	5e00006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000201b40:	f5043783          	ld	a5,-176(s0)
ffffffe000201b44:	f5040713          	addi	a4,s0,-176
ffffffe000201b48:	00a00613          	li	a2,10
ffffffe000201b4c:	00070593          	mv	a1,a4
ffffffe000201b50:	00078513          	mv	a0,a5
ffffffe000201b54:	819ff0ef          	jal	ra,ffffffe00020136c <strtol>
ffffffe000201b58:	00050793          	mv	a5,a0
ffffffe000201b5c:	0007879b          	sext.w	a5,a5
ffffffe000201b60:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000201b64:	f5043783          	ld	a5,-176(s0)
ffffffe000201b68:	fff78793          	addi	a5,a5,-1
ffffffe000201b6c:	f4f43823          	sd	a5,-176(s0)
ffffffe000201b70:	5ac0006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201b74:	f5043783          	ld	a5,-176(s0)
ffffffe000201b78:	0007c783          	lbu	a5,0(a5)
ffffffe000201b7c:	00078713          	mv	a4,a5
ffffffe000201b80:	07800793          	li	a5,120
ffffffe000201b84:	02f70663          	beq	a4,a5,ffffffe000201bb0 <vprintfmt+0x254>
ffffffe000201b88:	f5043783          	ld	a5,-176(s0)
ffffffe000201b8c:	0007c783          	lbu	a5,0(a5)
ffffffe000201b90:	00078713          	mv	a4,a5
ffffffe000201b94:	05800793          	li	a5,88
ffffffe000201b98:	00f70c63          	beq	a4,a5,ffffffe000201bb0 <vprintfmt+0x254>
ffffffe000201b9c:	f5043783          	ld	a5,-176(s0)
ffffffe000201ba0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ba4:	00078713          	mv	a4,a5
ffffffe000201ba8:	07000793          	li	a5,112
ffffffe000201bac:	2ef71e63          	bne	a4,a5,ffffffe000201ea8 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000201bb0:	f5043783          	ld	a5,-176(s0)
ffffffe000201bb4:	0007c783          	lbu	a5,0(a5)
ffffffe000201bb8:	00078713          	mv	a4,a5
ffffffe000201bbc:	07000793          	li	a5,112
ffffffe000201bc0:	00f70663          	beq	a4,a5,ffffffe000201bcc <vprintfmt+0x270>
ffffffe000201bc4:	f8144783          	lbu	a5,-127(s0)
ffffffe000201bc8:	00078663          	beqz	a5,ffffffe000201bd4 <vprintfmt+0x278>
ffffffe000201bcc:	00100793          	li	a5,1
ffffffe000201bd0:	0080006f          	j	ffffffe000201bd8 <vprintfmt+0x27c>
ffffffe000201bd4:	00000793          	li	a5,0
ffffffe000201bd8:	faf403a3          	sb	a5,-89(s0)
ffffffe000201bdc:	fa744783          	lbu	a5,-89(s0)
ffffffe000201be0:	0017f793          	andi	a5,a5,1
ffffffe000201be4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000201be8:	fa744783          	lbu	a5,-89(s0)
ffffffe000201bec:	0ff7f793          	andi	a5,a5,255
ffffffe000201bf0:	00078c63          	beqz	a5,ffffffe000201c08 <vprintfmt+0x2ac>
ffffffe000201bf4:	f4843783          	ld	a5,-184(s0)
ffffffe000201bf8:	00878713          	addi	a4,a5,8
ffffffe000201bfc:	f4e43423          	sd	a4,-184(s0)
ffffffe000201c00:	0007b783          	ld	a5,0(a5)
ffffffe000201c04:	01c0006f          	j	ffffffe000201c20 <vprintfmt+0x2c4>
ffffffe000201c08:	f4843783          	ld	a5,-184(s0)
ffffffe000201c0c:	00878713          	addi	a4,a5,8
ffffffe000201c10:	f4e43423          	sd	a4,-184(s0)
ffffffe000201c14:	0007a783          	lw	a5,0(a5)
ffffffe000201c18:	02079793          	slli	a5,a5,0x20
ffffffe000201c1c:	0207d793          	srli	a5,a5,0x20
ffffffe000201c20:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000201c24:	f8c42783          	lw	a5,-116(s0)
ffffffe000201c28:	02079463          	bnez	a5,ffffffe000201c50 <vprintfmt+0x2f4>
ffffffe000201c2c:	fe043783          	ld	a5,-32(s0)
ffffffe000201c30:	02079063          	bnez	a5,ffffffe000201c50 <vprintfmt+0x2f4>
ffffffe000201c34:	f5043783          	ld	a5,-176(s0)
ffffffe000201c38:	0007c783          	lbu	a5,0(a5)
ffffffe000201c3c:	00078713          	mv	a4,a5
ffffffe000201c40:	07000793          	li	a5,112
ffffffe000201c44:	00f70663          	beq	a4,a5,ffffffe000201c50 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000201c48:	f8040023          	sb	zero,-128(s0)
ffffffe000201c4c:	4d00006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000201c50:	f5043783          	ld	a5,-176(s0)
ffffffe000201c54:	0007c783          	lbu	a5,0(a5)
ffffffe000201c58:	00078713          	mv	a4,a5
ffffffe000201c5c:	07000793          	li	a5,112
ffffffe000201c60:	00f70a63          	beq	a4,a5,ffffffe000201c74 <vprintfmt+0x318>
ffffffe000201c64:	f8244783          	lbu	a5,-126(s0)
ffffffe000201c68:	00078a63          	beqz	a5,ffffffe000201c7c <vprintfmt+0x320>
ffffffe000201c6c:	fe043783          	ld	a5,-32(s0)
ffffffe000201c70:	00078663          	beqz	a5,ffffffe000201c7c <vprintfmt+0x320>
ffffffe000201c74:	00100793          	li	a5,1
ffffffe000201c78:	0080006f          	j	ffffffe000201c80 <vprintfmt+0x324>
ffffffe000201c7c:	00000793          	li	a5,0
ffffffe000201c80:	faf40323          	sb	a5,-90(s0)
ffffffe000201c84:	fa644783          	lbu	a5,-90(s0)
ffffffe000201c88:	0017f793          	andi	a5,a5,1
ffffffe000201c8c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000201c90:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000201c94:	f5043783          	ld	a5,-176(s0)
ffffffe000201c98:	0007c783          	lbu	a5,0(a5)
ffffffe000201c9c:	00078713          	mv	a4,a5
ffffffe000201ca0:	05800793          	li	a5,88
ffffffe000201ca4:	00f71863          	bne	a4,a5,ffffffe000201cb4 <vprintfmt+0x358>
ffffffe000201ca8:	00001797          	auipc	a5,0x1
ffffffe000201cac:	55078793          	addi	a5,a5,1360 # ffffffe0002031f8 <upperxdigits.1101>
ffffffe000201cb0:	00c0006f          	j	ffffffe000201cbc <vprintfmt+0x360>
ffffffe000201cb4:	00001797          	auipc	a5,0x1
ffffffe000201cb8:	55c78793          	addi	a5,a5,1372 # ffffffe000203210 <lowerxdigits.1100>
ffffffe000201cbc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000201cc0:	fe043783          	ld	a5,-32(s0)
ffffffe000201cc4:	00f7f793          	andi	a5,a5,15
ffffffe000201cc8:	f9843703          	ld	a4,-104(s0)
ffffffe000201ccc:	00f70733          	add	a4,a4,a5
ffffffe000201cd0:	fdc42783          	lw	a5,-36(s0)
ffffffe000201cd4:	0017869b          	addiw	a3,a5,1
ffffffe000201cd8:	fcd42e23          	sw	a3,-36(s0)
ffffffe000201cdc:	00074703          	lbu	a4,0(a4)
ffffffe000201ce0:	ff040693          	addi	a3,s0,-16
ffffffe000201ce4:	00f687b3          	add	a5,a3,a5
ffffffe000201ce8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000201cec:	fe043783          	ld	a5,-32(s0)
ffffffe000201cf0:	0047d793          	srli	a5,a5,0x4
ffffffe000201cf4:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000201cf8:	fe043783          	ld	a5,-32(s0)
ffffffe000201cfc:	fc0792e3          	bnez	a5,ffffffe000201cc0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000201d00:	f8c42783          	lw	a5,-116(s0)
ffffffe000201d04:	00078713          	mv	a4,a5
ffffffe000201d08:	fff00793          	li	a5,-1
ffffffe000201d0c:	02f71663          	bne	a4,a5,ffffffe000201d38 <vprintfmt+0x3dc>
ffffffe000201d10:	f8344783          	lbu	a5,-125(s0)
ffffffe000201d14:	02078263          	beqz	a5,ffffffe000201d38 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000201d18:	f8842703          	lw	a4,-120(s0)
ffffffe000201d1c:	fa644783          	lbu	a5,-90(s0)
ffffffe000201d20:	0007879b          	sext.w	a5,a5
ffffffe000201d24:	0017979b          	slliw	a5,a5,0x1
ffffffe000201d28:	0007879b          	sext.w	a5,a5
ffffffe000201d2c:	40f707bb          	subw	a5,a4,a5
ffffffe000201d30:	0007879b          	sext.w	a5,a5
ffffffe000201d34:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201d38:	f8842703          	lw	a4,-120(s0)
ffffffe000201d3c:	fa644783          	lbu	a5,-90(s0)
ffffffe000201d40:	0007879b          	sext.w	a5,a5
ffffffe000201d44:	0017979b          	slliw	a5,a5,0x1
ffffffe000201d48:	0007879b          	sext.w	a5,a5
ffffffe000201d4c:	40f707bb          	subw	a5,a4,a5
ffffffe000201d50:	0007871b          	sext.w	a4,a5
ffffffe000201d54:	fdc42783          	lw	a5,-36(s0)
ffffffe000201d58:	f8f42a23          	sw	a5,-108(s0)
ffffffe000201d5c:	f8c42783          	lw	a5,-116(s0)
ffffffe000201d60:	f8f42823          	sw	a5,-112(s0)
ffffffe000201d64:	f9442583          	lw	a1,-108(s0)
ffffffe000201d68:	f9042783          	lw	a5,-112(s0)
ffffffe000201d6c:	0007861b          	sext.w	a2,a5
ffffffe000201d70:	0005869b          	sext.w	a3,a1
ffffffe000201d74:	00d65463          	bge	a2,a3,ffffffe000201d7c <vprintfmt+0x420>
ffffffe000201d78:	00058793          	mv	a5,a1
ffffffe000201d7c:	0007879b          	sext.w	a5,a5
ffffffe000201d80:	40f707bb          	subw	a5,a4,a5
ffffffe000201d84:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201d88:	0280006f          	j	ffffffe000201db0 <vprintfmt+0x454>
                    putch(' ');
ffffffe000201d8c:	f5843783          	ld	a5,-168(s0)
ffffffe000201d90:	02000513          	li	a0,32
ffffffe000201d94:	000780e7          	jalr	a5
                    ++written;
ffffffe000201d98:	fec42783          	lw	a5,-20(s0)
ffffffe000201d9c:	0017879b          	addiw	a5,a5,1
ffffffe000201da0:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000201da4:	fd842783          	lw	a5,-40(s0)
ffffffe000201da8:	fff7879b          	addiw	a5,a5,-1
ffffffe000201dac:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201db0:	fd842783          	lw	a5,-40(s0)
ffffffe000201db4:	0007879b          	sext.w	a5,a5
ffffffe000201db8:	fcf04ae3          	bgtz	a5,ffffffe000201d8c <vprintfmt+0x430>
                }

                if (prefix) {
ffffffe000201dbc:	fa644783          	lbu	a5,-90(s0)
ffffffe000201dc0:	0ff7f793          	andi	a5,a5,255
ffffffe000201dc4:	04078463          	beqz	a5,ffffffe000201e0c <vprintfmt+0x4b0>
                    putch('0');
ffffffe000201dc8:	f5843783          	ld	a5,-168(s0)
ffffffe000201dcc:	03000513          	li	a0,48
ffffffe000201dd0:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000201dd4:	f5043783          	ld	a5,-176(s0)
ffffffe000201dd8:	0007c783          	lbu	a5,0(a5)
ffffffe000201ddc:	00078713          	mv	a4,a5
ffffffe000201de0:	05800793          	li	a5,88
ffffffe000201de4:	00f71663          	bne	a4,a5,ffffffe000201df0 <vprintfmt+0x494>
ffffffe000201de8:	05800793          	li	a5,88
ffffffe000201dec:	0080006f          	j	ffffffe000201df4 <vprintfmt+0x498>
ffffffe000201df0:	07800793          	li	a5,120
ffffffe000201df4:	f5843703          	ld	a4,-168(s0)
ffffffe000201df8:	00078513          	mv	a0,a5
ffffffe000201dfc:	000700e7          	jalr	a4
                    written += 2;
ffffffe000201e00:	fec42783          	lw	a5,-20(s0)
ffffffe000201e04:	0027879b          	addiw	a5,a5,2
ffffffe000201e08:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201e0c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201e10:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201e14:	0280006f          	j	ffffffe000201e3c <vprintfmt+0x4e0>
                    putch('0');
ffffffe000201e18:	f5843783          	ld	a5,-168(s0)
ffffffe000201e1c:	03000513          	li	a0,48
ffffffe000201e20:	000780e7          	jalr	a5
                    ++written;
ffffffe000201e24:	fec42783          	lw	a5,-20(s0)
ffffffe000201e28:	0017879b          	addiw	a5,a5,1
ffffffe000201e2c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000201e30:	fd442783          	lw	a5,-44(s0)
ffffffe000201e34:	0017879b          	addiw	a5,a5,1
ffffffe000201e38:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201e3c:	f8c42703          	lw	a4,-116(s0)
ffffffe000201e40:	fd442783          	lw	a5,-44(s0)
ffffffe000201e44:	0007879b          	sext.w	a5,a5
ffffffe000201e48:	fce7c8e3          	blt	a5,a4,ffffffe000201e18 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201e4c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201e50:	fff7879b          	addiw	a5,a5,-1
ffffffe000201e54:	fcf42823          	sw	a5,-48(s0)
ffffffe000201e58:	03c0006f          	j	ffffffe000201e94 <vprintfmt+0x538>
                    putch(buf[i]);
ffffffe000201e5c:	fd042783          	lw	a5,-48(s0)
ffffffe000201e60:	ff040713          	addi	a4,s0,-16
ffffffe000201e64:	00f707b3          	add	a5,a4,a5
ffffffe000201e68:	f807c783          	lbu	a5,-128(a5)
ffffffe000201e6c:	0007879b          	sext.w	a5,a5
ffffffe000201e70:	f5843703          	ld	a4,-168(s0)
ffffffe000201e74:	00078513          	mv	a0,a5
ffffffe000201e78:	000700e7          	jalr	a4
                    ++written;
ffffffe000201e7c:	fec42783          	lw	a5,-20(s0)
ffffffe000201e80:	0017879b          	addiw	a5,a5,1
ffffffe000201e84:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000201e88:	fd042783          	lw	a5,-48(s0)
ffffffe000201e8c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201e90:	fcf42823          	sw	a5,-48(s0)
ffffffe000201e94:	fd042783          	lw	a5,-48(s0)
ffffffe000201e98:	0007879b          	sext.w	a5,a5
ffffffe000201e9c:	fc07d0e3          	bgez	a5,ffffffe000201e5c <vprintfmt+0x500>
                }

                flags.in_format = false;
ffffffe000201ea0:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201ea4:	2780006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000201ea8:	f5043783          	ld	a5,-176(s0)
ffffffe000201eac:	0007c783          	lbu	a5,0(a5)
ffffffe000201eb0:	00078713          	mv	a4,a5
ffffffe000201eb4:	06400793          	li	a5,100
ffffffe000201eb8:	02f70663          	beq	a4,a5,ffffffe000201ee4 <vprintfmt+0x588>
ffffffe000201ebc:	f5043783          	ld	a5,-176(s0)
ffffffe000201ec0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ec4:	00078713          	mv	a4,a5
ffffffe000201ec8:	06900793          	li	a5,105
ffffffe000201ecc:	00f70c63          	beq	a4,a5,ffffffe000201ee4 <vprintfmt+0x588>
ffffffe000201ed0:	f5043783          	ld	a5,-176(s0)
ffffffe000201ed4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ed8:	00078713          	mv	a4,a5
ffffffe000201edc:	07500793          	li	a5,117
ffffffe000201ee0:	08f71263          	bne	a4,a5,ffffffe000201f64 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201ee4:	f8144783          	lbu	a5,-127(s0)
ffffffe000201ee8:	00078c63          	beqz	a5,ffffffe000201f00 <vprintfmt+0x5a4>
ffffffe000201eec:	f4843783          	ld	a5,-184(s0)
ffffffe000201ef0:	00878713          	addi	a4,a5,8
ffffffe000201ef4:	f4e43423          	sd	a4,-184(s0)
ffffffe000201ef8:	0007b783          	ld	a5,0(a5)
ffffffe000201efc:	0140006f          	j	ffffffe000201f10 <vprintfmt+0x5b4>
ffffffe000201f00:	f4843783          	ld	a5,-184(s0)
ffffffe000201f04:	00878713          	addi	a4,a5,8
ffffffe000201f08:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f0c:	0007a783          	lw	a5,0(a5)
ffffffe000201f10:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000201f14:	fa843583          	ld	a1,-88(s0)
ffffffe000201f18:	f5043783          	ld	a5,-176(s0)
ffffffe000201f1c:	0007c783          	lbu	a5,0(a5)
ffffffe000201f20:	0007871b          	sext.w	a4,a5
ffffffe000201f24:	07500793          	li	a5,117
ffffffe000201f28:	40f707b3          	sub	a5,a4,a5
ffffffe000201f2c:	00f037b3          	snez	a5,a5
ffffffe000201f30:	0ff7f793          	andi	a5,a5,255
ffffffe000201f34:	f8040713          	addi	a4,s0,-128
ffffffe000201f38:	00070693          	mv	a3,a4
ffffffe000201f3c:	00078613          	mv	a2,a5
ffffffe000201f40:	f5843503          	ld	a0,-168(s0)
ffffffe000201f44:	f18ff0ef          	jal	ra,ffffffe00020165c <print_dec_int>
ffffffe000201f48:	00050793          	mv	a5,a0
ffffffe000201f4c:	00078713          	mv	a4,a5
ffffffe000201f50:	fec42783          	lw	a5,-20(s0)
ffffffe000201f54:	00e787bb          	addw	a5,a5,a4
ffffffe000201f58:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000201f5c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000201f60:	1bc0006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000201f64:	f5043783          	ld	a5,-176(s0)
ffffffe000201f68:	0007c783          	lbu	a5,0(a5)
ffffffe000201f6c:	00078713          	mv	a4,a5
ffffffe000201f70:	06e00793          	li	a5,110
ffffffe000201f74:	04f71c63          	bne	a4,a5,ffffffe000201fcc <vprintfmt+0x670>
                if (flags.longflag) {
ffffffe000201f78:	f8144783          	lbu	a5,-127(s0)
ffffffe000201f7c:	02078463          	beqz	a5,ffffffe000201fa4 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
ffffffe000201f80:	f4843783          	ld	a5,-184(s0)
ffffffe000201f84:	00878713          	addi	a4,a5,8
ffffffe000201f88:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f8c:	0007b783          	ld	a5,0(a5)
ffffffe000201f90:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000201f94:	fec42703          	lw	a4,-20(s0)
ffffffe000201f98:	fb043783          	ld	a5,-80(s0)
ffffffe000201f9c:	00e7b023          	sd	a4,0(a5)
ffffffe000201fa0:	0240006f          	j	ffffffe000201fc4 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000201fa4:	f4843783          	ld	a5,-184(s0)
ffffffe000201fa8:	00878713          	addi	a4,a5,8
ffffffe000201fac:	f4e43423          	sd	a4,-184(s0)
ffffffe000201fb0:	0007b783          	ld	a5,0(a5)
ffffffe000201fb4:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000201fb8:	fb843783          	ld	a5,-72(s0)
ffffffe000201fbc:	fec42703          	lw	a4,-20(s0)
ffffffe000201fc0:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000201fc4:	f8040023          	sb	zero,-128(s0)
ffffffe000201fc8:	1540006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000201fcc:	f5043783          	ld	a5,-176(s0)
ffffffe000201fd0:	0007c783          	lbu	a5,0(a5)
ffffffe000201fd4:	00078713          	mv	a4,a5
ffffffe000201fd8:	07300793          	li	a5,115
ffffffe000201fdc:	04f71063          	bne	a4,a5,ffffffe00020201c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000201fe0:	f4843783          	ld	a5,-184(s0)
ffffffe000201fe4:	00878713          	addi	a4,a5,8
ffffffe000201fe8:	f4e43423          	sd	a4,-184(s0)
ffffffe000201fec:	0007b783          	ld	a5,0(a5)
ffffffe000201ff0:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000201ff4:	fc043583          	ld	a1,-64(s0)
ffffffe000201ff8:	f5843503          	ld	a0,-168(s0)
ffffffe000201ffc:	dd8ff0ef          	jal	ra,ffffffe0002015d4 <puts_wo_nl>
ffffffe000202000:	00050793          	mv	a5,a0
ffffffe000202004:	00078713          	mv	a4,a5
ffffffe000202008:	fec42783          	lw	a5,-20(s0)
ffffffe00020200c:	00e787bb          	addw	a5,a5,a4
ffffffe000202010:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202014:	f8040023          	sb	zero,-128(s0)
ffffffe000202018:	1040006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe00020201c:	f5043783          	ld	a5,-176(s0)
ffffffe000202020:	0007c783          	lbu	a5,0(a5)
ffffffe000202024:	00078713          	mv	a4,a5
ffffffe000202028:	06300793          	li	a5,99
ffffffe00020202c:	02f71e63          	bne	a4,a5,ffffffe000202068 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202030:	f4843783          	ld	a5,-184(s0)
ffffffe000202034:	00878713          	addi	a4,a5,8
ffffffe000202038:	f4e43423          	sd	a4,-184(s0)
ffffffe00020203c:	0007a783          	lw	a5,0(a5)
ffffffe000202040:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202044:	fcc42783          	lw	a5,-52(s0)
ffffffe000202048:	f5843703          	ld	a4,-168(s0)
ffffffe00020204c:	00078513          	mv	a0,a5
ffffffe000202050:	000700e7          	jalr	a4
                ++written;
ffffffe000202054:	fec42783          	lw	a5,-20(s0)
ffffffe000202058:	0017879b          	addiw	a5,a5,1
ffffffe00020205c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202060:	f8040023          	sb	zero,-128(s0)
ffffffe000202064:	0b80006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202068:	f5043783          	ld	a5,-176(s0)
ffffffe00020206c:	0007c783          	lbu	a5,0(a5)
ffffffe000202070:	00078713          	mv	a4,a5
ffffffe000202074:	02500793          	li	a5,37
ffffffe000202078:	02f71263          	bne	a4,a5,ffffffe00020209c <vprintfmt+0x740>
                putch('%');
ffffffe00020207c:	f5843783          	ld	a5,-168(s0)
ffffffe000202080:	02500513          	li	a0,37
ffffffe000202084:	000780e7          	jalr	a5
                ++written;
ffffffe000202088:	fec42783          	lw	a5,-20(s0)
ffffffe00020208c:	0017879b          	addiw	a5,a5,1
ffffffe000202090:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202094:	f8040023          	sb	zero,-128(s0)
ffffffe000202098:	0840006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe00020209c:	f5043783          	ld	a5,-176(s0)
ffffffe0002020a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002020a4:	0007879b          	sext.w	a5,a5
ffffffe0002020a8:	f5843703          	ld	a4,-168(s0)
ffffffe0002020ac:	00078513          	mv	a0,a5
ffffffe0002020b0:	000700e7          	jalr	a4
                ++written;
ffffffe0002020b4:	fec42783          	lw	a5,-20(s0)
ffffffe0002020b8:	0017879b          	addiw	a5,a5,1
ffffffe0002020bc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002020c0:	f8040023          	sb	zero,-128(s0)
ffffffe0002020c4:	0580006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe0002020c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002020cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002020d0:	00078713          	mv	a4,a5
ffffffe0002020d4:	02500793          	li	a5,37
ffffffe0002020d8:	02f71063          	bne	a4,a5,ffffffe0002020f8 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe0002020dc:	f8043023          	sd	zero,-128(s0)
ffffffe0002020e0:	f8043423          	sd	zero,-120(s0)
ffffffe0002020e4:	00100793          	li	a5,1
ffffffe0002020e8:	f8f40023          	sb	a5,-128(s0)
ffffffe0002020ec:	fff00793          	li	a5,-1
ffffffe0002020f0:	f8f42623          	sw	a5,-116(s0)
ffffffe0002020f4:	0280006f          	j	ffffffe00020211c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe0002020f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002020fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202100:	0007879b          	sext.w	a5,a5
ffffffe000202104:	f5843703          	ld	a4,-168(s0)
ffffffe000202108:	00078513          	mv	a0,a5
ffffffe00020210c:	000700e7          	jalr	a4
            ++written;
ffffffe000202110:	fec42783          	lw	a5,-20(s0)
ffffffe000202114:	0017879b          	addiw	a5,a5,1
ffffffe000202118:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe00020211c:	f5043783          	ld	a5,-176(s0)
ffffffe000202120:	00178793          	addi	a5,a5,1
ffffffe000202124:	f4f43823          	sd	a5,-176(s0)
ffffffe000202128:	f5043783          	ld	a5,-176(s0)
ffffffe00020212c:	0007c783          	lbu	a5,0(a5)
ffffffe000202130:	84079ce3          	bnez	a5,ffffffe000201988 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202134:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202138:	00078513          	mv	a0,a5
ffffffe00020213c:	0b813083          	ld	ra,184(sp)
ffffffe000202140:	0b013403          	ld	s0,176(sp)
ffffffe000202144:	0c010113          	addi	sp,sp,192
ffffffe000202148:	00008067          	ret

ffffffe00020214c <printk>:

int printk(const char* s, ...) {
ffffffe00020214c:	f9010113          	addi	sp,sp,-112
ffffffe000202150:	02113423          	sd	ra,40(sp)
ffffffe000202154:	02813023          	sd	s0,32(sp)
ffffffe000202158:	03010413          	addi	s0,sp,48
ffffffe00020215c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202160:	00b43423          	sd	a1,8(s0)
ffffffe000202164:	00c43823          	sd	a2,16(s0)
ffffffe000202168:	00d43c23          	sd	a3,24(s0)
ffffffe00020216c:	02e43023          	sd	a4,32(s0)
ffffffe000202170:	02f43423          	sd	a5,40(s0)
ffffffe000202174:	03043823          	sd	a6,48(s0)
ffffffe000202178:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe00020217c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000202180:	04040793          	addi	a5,s0,64
ffffffe000202184:	fcf43823          	sd	a5,-48(s0)
ffffffe000202188:	fd043783          	ld	a5,-48(s0)
ffffffe00020218c:	fc878793          	addi	a5,a5,-56
ffffffe000202190:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000202194:	fe043783          	ld	a5,-32(s0)
ffffffe000202198:	00078613          	mv	a2,a5
ffffffe00020219c:	fd843583          	ld	a1,-40(s0)
ffffffe0002021a0:	fffff517          	auipc	a0,0xfffff
ffffffe0002021a4:	12450513          	addi	a0,a0,292 # ffffffe0002012c4 <putc>
ffffffe0002021a8:	fb4ff0ef          	jal	ra,ffffffe00020195c <vprintfmt>
ffffffe0002021ac:	00050793          	mv	a5,a0
ffffffe0002021b0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe0002021b4:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002021b8:	00078513          	mv	a0,a5
ffffffe0002021bc:	02813083          	ld	ra,40(sp)
ffffffe0002021c0:	02013403          	ld	s0,32(sp)
ffffffe0002021c4:	07010113          	addi	sp,sp,112
ffffffe0002021c8:	00008067          	ret

ffffffe0002021cc <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe0002021cc:	fe010113          	addi	sp,sp,-32
ffffffe0002021d0:	00813c23          	sd	s0,24(sp)
ffffffe0002021d4:	02010413          	addi	s0,sp,32
ffffffe0002021d8:	00050793          	mv	a5,a0
ffffffe0002021dc:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe0002021e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002021e4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002021e8:	0007879b          	sext.w	a5,a5
ffffffe0002021ec:	02079713          	slli	a4,a5,0x20
ffffffe0002021f0:	02075713          	srli	a4,a4,0x20
ffffffe0002021f4:	00004797          	auipc	a5,0x4
ffffffe0002021f8:	e0c78793          	addi	a5,a5,-500 # ffffffe000206000 <seed>
ffffffe0002021fc:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202200:	00000013          	nop
ffffffe000202204:	01813403          	ld	s0,24(sp)
ffffffe000202208:	02010113          	addi	sp,sp,32
ffffffe00020220c:	00008067          	ret

ffffffe000202210 <rand>:

int rand(void) {
ffffffe000202210:	ff010113          	addi	sp,sp,-16
ffffffe000202214:	00813423          	sd	s0,8(sp)
ffffffe000202218:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe00020221c:	00004797          	auipc	a5,0x4
ffffffe000202220:	de478793          	addi	a5,a5,-540 # ffffffe000206000 <seed>
ffffffe000202224:	0007b703          	ld	a4,0(a5)
ffffffe000202228:	00001797          	auipc	a5,0x1
ffffffe00020222c:	00078793          	mv	a5,a5
ffffffe000202230:	0007b783          	ld	a5,0(a5) # ffffffe000203228 <lowerxdigits.1100+0x18>
ffffffe000202234:	02f707b3          	mul	a5,a4,a5
ffffffe000202238:	00178713          	addi	a4,a5,1
ffffffe00020223c:	00004797          	auipc	a5,0x4
ffffffe000202240:	dc478793          	addi	a5,a5,-572 # ffffffe000206000 <seed>
ffffffe000202244:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202248:	00004797          	auipc	a5,0x4
ffffffe00020224c:	db878793          	addi	a5,a5,-584 # ffffffe000206000 <seed>
ffffffe000202250:	0007b783          	ld	a5,0(a5)
ffffffe000202254:	0217d793          	srli	a5,a5,0x21
ffffffe000202258:	0007879b          	sext.w	a5,a5
}
ffffffe00020225c:	00078513          	mv	a0,a5
ffffffe000202260:	00813403          	ld	s0,8(sp)
ffffffe000202264:	01010113          	addi	sp,sp,16
ffffffe000202268:	00008067          	ret

ffffffe00020226c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe00020226c:	fc010113          	addi	sp,sp,-64
ffffffe000202270:	02813c23          	sd	s0,56(sp)
ffffffe000202274:	04010413          	addi	s0,sp,64
ffffffe000202278:	fca43c23          	sd	a0,-40(s0)
ffffffe00020227c:	00058793          	mv	a5,a1
ffffffe000202280:	fcc43423          	sd	a2,-56(s0)
ffffffe000202284:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000202288:	fd843783          	ld	a5,-40(s0)
ffffffe00020228c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202290:	fe043423          	sd	zero,-24(s0)
ffffffe000202294:	0280006f          	j	ffffffe0002022bc <memset+0x50>
        s[i] = c;
ffffffe000202298:	fe043703          	ld	a4,-32(s0)
ffffffe00020229c:	fe843783          	ld	a5,-24(s0)
ffffffe0002022a0:	00f707b3          	add	a5,a4,a5
ffffffe0002022a4:	fd442703          	lw	a4,-44(s0)
ffffffe0002022a8:	0ff77713          	andi	a4,a4,255
ffffffe0002022ac:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002022b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002022b4:	00178793          	addi	a5,a5,1
ffffffe0002022b8:	fef43423          	sd	a5,-24(s0)
ffffffe0002022bc:	fe843703          	ld	a4,-24(s0)
ffffffe0002022c0:	fc843783          	ld	a5,-56(s0)
ffffffe0002022c4:	fcf76ae3          	bltu	a4,a5,ffffffe000202298 <memset+0x2c>
    }
    return dest;
ffffffe0002022c8:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002022cc:	00078513          	mv	a0,a5
ffffffe0002022d0:	03813403          	ld	s0,56(sp)
ffffffe0002022d4:	04010113          	addi	sp,sp,64
ffffffe0002022d8:	00008067          	ret
