
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern mm_init
    .extern task_init
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶
    80200000:	00003117          	auipc	sp,0x3
    80200004:	03013103          	ld	sp,48(sp) # 80203030 <_GLOBAL_OFFSET_TABLE_+0x28>

    call mm_init #初始化内存管理系统
    80200008:	3cc000ef          	jal	ra,802003d4 <mm_init>
    call task_init #初始化线程数据结构
    8020000c:	40c000ef          	jal	ra,80200418 <task_init>
    
    # set stvec = _traps
    la t0,_traps
    80200010:	00003297          	auipc	t0,0x3
    80200014:	0402b283          	ld	t0,64(t0) # 80203050 <_GLOBAL_OFFSET_TABLE_+0x48>
    csrw stvec,t0
    80200018:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
    8020001c:	02000293          	li	t0,32
    csrs sie,t0
    80200020:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
    80200024:	1e8000ef          	jal	ra,8020020c <get_cycles>
    li t0,10000000
    80200028:	009892b7          	lui	t0,0x989
    8020002c:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
    80200030:	00550533          	add	a0,a0,t0
    call sbi_set_timer
    80200034:	2b5000ef          	jal	ra,80200ae8 <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
    80200038:	00200293          	li	t0,2
    csrs sstatus,t0
    8020003c:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
    80200040:	5050006f          	j	80200d44 <start_kernel>

0000000080200044 <_traps>:
    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    addi sp,sp,-33*8   # 开辟栈空间
    80200044:	ef810113          	addi	sp,sp,-264
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
    80200048:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)
    8020004c:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)
    80200050:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)
    80200054:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)
    80200058:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)
    8020005c:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
    80200060:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
    80200064:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)
    80200068:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)
    8020006c:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)
    80200070:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
    80200074:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
    80200078:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
    8020007c:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
    80200080:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
    80200084:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
    80200088:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
    8020008c:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)
    80200090:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
    80200094:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
    80200098:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
    8020009c:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
    802000a0:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
    802000a4:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
    802000a8:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
    802000ac:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
    802000b0:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
    802000b4:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)
    802000b8:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
    802000bc:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
    802000c0:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
    802000c4:	0ff13c23          	sd	t6,248(sp)
    csrr t0,sepc
    802000c8:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
    802000cc:	10513023          	sd	t0,256(sp)

    # call trap_handler
    csrr a0,scause
    802000d0:	14202573          	csrr	a0,scause
    csrr a1,sepc
    802000d4:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000d8:	3e1000ef          	jal	ra,80200cb8 <trap_handler>

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
    802000dc:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
    802000e0:	14129073          	csrw	sepc,t0

    ld x31,31*8(sp)
    802000e4:	0f813f83          	ld	t6,248(sp)
    ld x30,30*8(sp)
    802000e8:	0f013f03          	ld	t5,240(sp)
    ld x29,29*8(sp)
    802000ec:	0e813e83          	ld	t4,232(sp)
    ld x28,28*8(sp)
    802000f0:	0e013e03          	ld	t3,224(sp)
    ld x27,27*8(sp)
    802000f4:	0d813d83          	ld	s11,216(sp)
    ld x26,26*8(sp)
    802000f8:	0d013d03          	ld	s10,208(sp)
    ld x25,25*8(sp)
    802000fc:	0c813c83          	ld	s9,200(sp)
    ld x24,24*8(sp)
    80200100:	0c013c03          	ld	s8,192(sp)
    ld x23,23*8(sp)
    80200104:	0b813b83          	ld	s7,184(sp)
    ld x22,22*8(sp)
    80200108:	0b013b03          	ld	s6,176(sp)
    ld x21,21*8(sp)
    8020010c:	0a813a83          	ld	s5,168(sp)
    ld x20,20*8(sp)
    80200110:	0a013a03          	ld	s4,160(sp)
    ld x19,19*8(sp)
    80200114:	09813983          	ld	s3,152(sp)
    ld x18,18*8(sp)
    80200118:	09013903          	ld	s2,144(sp)
    ld x17,17*8(sp)
    8020011c:	08813883          	ld	a7,136(sp)
    ld x16,16*8(sp)
    80200120:	08013803          	ld	a6,128(sp)
    ld x15,15*8(sp)
    80200124:	07813783          	ld	a5,120(sp)
    ld x14,14*8(sp)
    80200128:	07013703          	ld	a4,112(sp)
    ld x13,13*8(sp)
    8020012c:	06813683          	ld	a3,104(sp)
    ld x12,12*8(sp)
    80200130:	06013603          	ld	a2,96(sp)
    ld x11,11*8(sp)
    80200134:	05813583          	ld	a1,88(sp)
    ld x10,10*8(sp)
    80200138:	05013503          	ld	a0,80(sp)
    ld x9,9*8(sp)
    8020013c:	04813483          	ld	s1,72(sp)
    ld x8,8*8(sp)
    80200140:	04013403          	ld	s0,64(sp)
    ld x7,7*8(sp)
    80200144:	03813383          	ld	t2,56(sp)
    ld x6,6*8(sp)
    80200148:	03013303          	ld	t1,48(sp)
    ld x5,5*8(sp)
    8020014c:	02813283          	ld	t0,40(sp)
    ld x4,4*8(sp)
    80200150:	02013203          	ld	tp,32(sp)
    ld x3,3*8(sp)
    80200154:	01813183          	ld	gp,24(sp)
    ld x1,1*8(sp)
    80200158:	00813083          	ld	ra,8(sp)
    ld x0,0*8(sp)
    8020015c:	00013003          	ld	zero,0(sp)
    ld x2,2*8(sp)
    80200160:	01013103          	ld	sp,16(sp)
    addi sp,sp,33*8   # 释放栈空间
    80200164:	10810113          	addi	sp,sp,264

    # return from trap
    sret
    80200168:	10200073          	sret

000000008020016c <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    la t0,dummy
    8020016c:	00003297          	auipc	t0,0x3
    80200170:	edc2b283          	ld	t0,-292(t0) # 80203048 <_GLOBAL_OFFSET_TABLE_+0x40>
    csrw sepc,t0
    80200174:	14129073          	csrw	sepc,t0
    sret
    80200178:	10200073          	sret

000000008020017c <__switch_to>:

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
    8020017c:	02153023          	sd	ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
    80200180:	02253423          	sd	sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
    80200184:	02853823          	sd	s0,48(a0)
    sd s1,56(a0)
    80200188:	02953c23          	sd	s1,56(a0)
    sd s2,64(a0)
    8020018c:	05253023          	sd	s2,64(a0)
    sd s3,72(a0)
    80200190:	05353423          	sd	s3,72(a0)
    sd s4,80(a0)
    80200194:	05453823          	sd	s4,80(a0)
    sd s5,88(a0)
    80200198:	05553c23          	sd	s5,88(a0)
    sd s6,96(a0)
    8020019c:	07653023          	sd	s6,96(a0)
    sd s7,104(a0)
    802001a0:	07753423          	sd	s7,104(a0)
    sd s8,112(a0)
    802001a4:	07853823          	sd	s8,112(a0)
    sd s9,120(a0)
    802001a8:	07953c23          	sd	s9,120(a0)
    sd s10,128(a0)
    802001ac:	09a53023          	sd	s10,128(a0)
    sd s11,136(a0)
    802001b0:	09b53423          	sd	s11,136(a0)

    #next是否为第一次调度
    ld t0,8(a1)
    802001b4:	0085b283          	ld	t0,8(a1)
    ld t1,16(a1)
    802001b8:	0105b303          	ld	t1,16(a1)
    beq t0,t1,first_schedule
    802001bc:	04628063          	beq	t0,t1,802001fc <first_schedule>
    #恢复下一个进程上下文

    ld ra,32(a1)
    802001c0:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
    802001c4:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
    802001c8:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
    802001cc:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
    802001d0:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
    802001d4:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
    802001d8:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
    802001dc:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
    802001e0:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
    802001e4:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
    802001e8:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
    802001ec:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
    802001f0:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
    802001f4:	0885bd83          	ld	s11,136(a1)
    j switch_done
    802001f8:	0100006f          	j	80200208 <switch_done>

00000000802001fc <first_schedule>:

first_schedule:
    ld ra,32(a1)
    802001fc:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
    80200200:	0285b103          	ld	sp,40(a1)
    j switch_done
    80200204:	0040006f          	j	80200208 <switch_done>

0000000080200208 <switch_done>:

switch_done:
    ret
    80200208:	00008067          	ret

000000008020020c <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020020c:	fe010113          	addi	sp,sp,-32
    80200210:	00813c23          	sd	s0,24(sp)
    80200214:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
    80200218:	c01027f3          	rdtime	a5
    8020021c:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
    80200220:	fe843783          	ld	a5,-24(s0)
}
    80200224:	00078513          	mv	a0,a5
    80200228:	01813403          	ld	s0,24(sp)
    8020022c:	02010113          	addi	sp,sp,32
    80200230:	00008067          	ret

0000000080200234 <clock_set_next_event>:

void clock_set_next_event() {
    80200234:	fe010113          	addi	sp,sp,-32
    80200238:	00113c23          	sd	ra,24(sp)
    8020023c:	00813823          	sd	s0,16(sp)
    80200240:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200244:	fc9ff0ef          	jal	ra,8020020c <get_cycles>
    80200248:	00050713          	mv	a4,a0
    8020024c:	00003797          	auipc	a5,0x3
    80200250:	db478793          	addi	a5,a5,-588 # 80203000 <TIMECLOCK>
    80200254:	0007b783          	ld	a5,0(a5)
    80200258:	00f707b3          	add	a5,a4,a5
    8020025c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
    80200260:	fe843503          	ld	a0,-24(s0)
    80200264:	085000ef          	jal	ra,80200ae8 <sbi_set_timer>
    80200268:	00000013          	nop
    8020026c:	01813083          	ld	ra,24(sp)
    80200270:	01013403          	ld	s0,16(sp)
    80200274:	02010113          	addi	sp,sp,32
    80200278:	00008067          	ret

000000008020027c <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    8020027c:	fe010113          	addi	sp,sp,-32
    80200280:	00113c23          	sd	ra,24(sp)
    80200284:	00813823          	sd	s0,16(sp)
    80200288:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    8020028c:	00003797          	auipc	a5,0x3
    80200290:	d847b783          	ld	a5,-636(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200294:	0007b783          	ld	a5,0(a5)
    80200298:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    8020029c:	fe843783          	ld	a5,-24(s0)
    802002a0:	0007b703          	ld	a4,0(a5)
    802002a4:	00003797          	auipc	a5,0x3
    802002a8:	d6c7b783          	ld	a5,-660(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    802002ac:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    802002b0:	00001637          	lui	a2,0x1
    802002b4:	00000593          	li	a1,0
    802002b8:	fe843503          	ld	a0,-24(s0)
    802002bc:	2c1010ef          	jal	ra,80201d7c <memset>
    return (void *)r;
    802002c0:	fe843783          	ld	a5,-24(s0)
}
    802002c4:	00078513          	mv	a0,a5
    802002c8:	01813083          	ld	ra,24(sp)
    802002cc:	01013403          	ld	s0,16(sp)
    802002d0:	02010113          	addi	sp,sp,32
    802002d4:	00008067          	ret

00000000802002d8 <kfree>:

void kfree(void *addr) {
    802002d8:	fd010113          	addi	sp,sp,-48
    802002dc:	02113423          	sd	ra,40(sp)
    802002e0:	02813023          	sd	s0,32(sp)
    802002e4:	03010413          	addi	s0,sp,48
    802002e8:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002ec:	fd843783          	ld	a5,-40(s0)
    802002f0:	00078693          	mv	a3,a5
    802002f4:	fd840793          	addi	a5,s0,-40
    802002f8:	fffff737          	lui	a4,0xfffff
    802002fc:	00e6f733          	and	a4,a3,a4
    80200300:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    80200304:	fd843783          	ld	a5,-40(s0)
    80200308:	00001637          	lui	a2,0x1
    8020030c:	00000593          	li	a1,0
    80200310:	00078513          	mv	a0,a5
    80200314:	269010ef          	jal	ra,80201d7c <memset>

    r = (struct run *)addr;
    80200318:	fd843783          	ld	a5,-40(s0)
    8020031c:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    80200320:	00003797          	auipc	a5,0x3
    80200324:	cf07b783          	ld	a5,-784(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200328:	0007b703          	ld	a4,0(a5)
    8020032c:	fe843783          	ld	a5,-24(s0)
    80200330:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200334:	00003797          	auipc	a5,0x3
    80200338:	cdc7b783          	ld	a5,-804(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    8020033c:	fe843703          	ld	a4,-24(s0)
    80200340:	00e7b023          	sd	a4,0(a5)

    return;
    80200344:	00000013          	nop
}
    80200348:	02813083          	ld	ra,40(sp)
    8020034c:	02013403          	ld	s0,32(sp)
    80200350:	03010113          	addi	sp,sp,48
    80200354:	00008067          	ret

0000000080200358 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200358:	fd010113          	addi	sp,sp,-48
    8020035c:	02113423          	sd	ra,40(sp)
    80200360:	02813023          	sd	s0,32(sp)
    80200364:	03010413          	addi	s0,sp,48
    80200368:	fca43c23          	sd	a0,-40(s0)
    8020036c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    80200370:	fd843703          	ld	a4,-40(s0)
    80200374:	000017b7          	lui	a5,0x1
    80200378:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    8020037c:	00f70733          	add	a4,a4,a5
    80200380:	fffff7b7          	lui	a5,0xfffff
    80200384:	00f777b3          	and	a5,a4,a5
    80200388:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    8020038c:	01c0006f          	j	802003a8 <kfreerange+0x50>
        kfree((void *)addr);
    80200390:	fe843503          	ld	a0,-24(s0)
    80200394:	f45ff0ef          	jal	ra,802002d8 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200398:	fe843703          	ld	a4,-24(s0)
    8020039c:	000017b7          	lui	a5,0x1
    802003a0:	00f707b3          	add	a5,a4,a5
    802003a4:	fef43423          	sd	a5,-24(s0)
    802003a8:	fe843703          	ld	a4,-24(s0)
    802003ac:	000017b7          	lui	a5,0x1
    802003b0:	00f70733          	add	a4,a4,a5
    802003b4:	fd043783          	ld	a5,-48(s0)
    802003b8:	fce7fce3          	bgeu	a5,a4,80200390 <kfreerange+0x38>
    }
}
    802003bc:	00000013          	nop
    802003c0:	00000013          	nop
    802003c4:	02813083          	ld	ra,40(sp)
    802003c8:	02013403          	ld	s0,32(sp)
    802003cc:	03010113          	addi	sp,sp,48
    802003d0:	00008067          	ret

00000000802003d4 <mm_init>:

void mm_init(void) {
    802003d4:	ff010113          	addi	sp,sp,-16
    802003d8:	00113423          	sd	ra,8(sp)
    802003dc:	00813023          	sd	s0,0(sp)
    802003e0:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003e4:	01100793          	li	a5,17
    802003e8:	01b79593          	slli	a1,a5,0x1b
    802003ec:	00003517          	auipc	a0,0x3
    802003f0:	c2c53503          	ld	a0,-980(a0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    802003f4:	f65ff0ef          	jal	ra,80200358 <kfreerange>
    printk("...mm_init done!\n");
    802003f8:	00002517          	auipc	a0,0x2
    802003fc:	c0850513          	addi	a0,a0,-1016 # 80202000 <_srodata>
    80200400:	05d010ef          	jal	ra,80201c5c <printk>
}
    80200404:	00000013          	nop
    80200408:	00813083          	ld	ra,8(sp)
    8020040c:	00013403          	ld	s0,0(sp)
    80200410:	01010113          	addi	sp,sp,16
    80200414:	00008067          	ret

0000000080200418 <task_init>:
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

extern void __dummy();

void task_init() {
    80200418:	fe010113          	addi	sp,sp,-32
    8020041c:	00113c23          	sd	ra,24(sp)
    80200420:	00813823          	sd	s0,16(sp)
    80200424:	02010413          	addi	s0,sp,32
    srand(2024);
    80200428:	7e800513          	li	a0,2024
    8020042c:	0b1010ef          	jal	ra,80201cdc <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
    80200430:	e4dff0ef          	jal	ra,8020027c <kalloc>
    80200434:	00050713          	mv	a4,a0
    80200438:	00003797          	auipc	a5,0x3
    8020043c:	bf07b783          	ld	a5,-1040(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200440:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    80200444:	00003797          	auipc	a5,0x3
    80200448:	be47b783          	ld	a5,-1052(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020044c:	0007b783          	ld	a5,0(a5)
    80200450:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
    80200454:	00003797          	auipc	a5,0x3
    80200458:	bd47b783          	ld	a5,-1068(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020045c:	0007b783          	ld	a5,0(a5)
    80200460:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
    80200464:	00003797          	auipc	a5,0x3
    80200468:	bc47b783          	ld	a5,-1084(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020046c:	0007b783          	ld	a5,0(a5)
    80200470:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
    80200474:	00003797          	auipc	a5,0x3
    80200478:	bb47b783          	ld	a5,-1100(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020047c:	0007b783          	ld	a5,0(a5)
    80200480:	0007bc23          	sd	zero,24(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    80200484:	00003797          	auipc	a5,0x3
    80200488:	ba47b783          	ld	a5,-1116(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020048c:	0007b703          	ld	a4,0(a5)
    80200490:	00003797          	auipc	a5,0x3
    80200494:	ba87b783          	ld	a5,-1112(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    80200498:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
    8020049c:	00003797          	auipc	a5,0x3
    802004a0:	b8c7b783          	ld	a5,-1140(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    802004a4:	0007b703          	ld	a4,0(a5)
    802004a8:	00003797          	auipc	a5,0x3
    802004ac:	b987b783          	ld	a5,-1128(a5) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802004b0:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    for(int i=1;i<NR_TASKS;i++){
    802004b4:	00100793          	li	a5,1
    802004b8:	fef42623          	sw	a5,-20(s0)
    802004bc:	12c0006f          	j	802005e8 <task_init+0x1d0>
        task[i]=(struct task_struct *)kalloc();
    802004c0:	dbdff0ef          	jal	ra,8020027c <kalloc>
    802004c4:	00050693          	mv	a3,a0
    802004c8:	00003717          	auipc	a4,0x3
    802004cc:	b7873703          	ld	a4,-1160(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802004d0:	fec42783          	lw	a5,-20(s0)
    802004d4:	00379793          	slli	a5,a5,0x3
    802004d8:	00f707b3          	add	a5,a4,a5
    802004dc:	00d7b023          	sd	a3,0(a5)
        task[i]->state=TASK_RUNNING;
    802004e0:	00003717          	auipc	a4,0x3
    802004e4:	b6073703          	ld	a4,-1184(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802004e8:	fec42783          	lw	a5,-20(s0)
    802004ec:	00379793          	slli	a5,a5,0x3
    802004f0:	00f707b3          	add	a5,a4,a5
    802004f4:	0007b783          	ld	a5,0(a5)
    802004f8:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
    802004fc:	00003717          	auipc	a4,0x3
    80200500:	b4473703          	ld	a4,-1212(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200504:	fec42783          	lw	a5,-20(s0)
    80200508:	00379793          	slli	a5,a5,0x3
    8020050c:	00f707b3          	add	a5,a4,a5
    80200510:	0007b783          	ld	a5,0(a5)
    80200514:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
    80200518:	009010ef          	jal	ra,80201d20 <rand>
    8020051c:	00050793          	mv	a5,a0
    80200520:	00078713          	mv	a4,a5
    80200524:	00a00793          	li	a5,10
    80200528:	02f767bb          	remw	a5,a4,a5
    8020052c:	0007879b          	sext.w	a5,a5
    80200530:	0017879b          	addiw	a5,a5,1
    80200534:	0007869b          	sext.w	a3,a5
    80200538:	00003717          	auipc	a4,0x3
    8020053c:	b0873703          	ld	a4,-1272(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200540:	fec42783          	lw	a5,-20(s0)
    80200544:	00379793          	slli	a5,a5,0x3
    80200548:	00f707b3          	add	a5,a4,a5
    8020054c:	0007b783          	ld	a5,0(a5)
    80200550:	00068713          	mv	a4,a3
    80200554:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
    80200558:	00003717          	auipc	a4,0x3
    8020055c:	ae873703          	ld	a4,-1304(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200560:	fec42783          	lw	a5,-20(s0)
    80200564:	00379793          	slli	a5,a5,0x3
    80200568:	00f707b3          	add	a5,a4,a5
    8020056c:	0007b783          	ld	a5,0(a5)
    80200570:	fec42703          	lw	a4,-20(s0)
    80200574:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
    80200578:	00003717          	auipc	a4,0x3
    8020057c:	ac873703          	ld	a4,-1336(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200580:	fec42783          	lw	a5,-20(s0)
    80200584:	00379793          	slli	a5,a5,0x3
    80200588:	00f707b3          	add	a5,a4,a5
    8020058c:	0007b783          	ld	a5,0(a5)
    80200590:	00003717          	auipc	a4,0x3
    80200594:	a9073703          	ld	a4,-1392(a4) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>
    80200598:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
    8020059c:	00003717          	auipc	a4,0x3
    802005a0:	aa473703          	ld	a4,-1372(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802005a4:	fec42783          	lw	a5,-20(s0)
    802005a8:	00379793          	slli	a5,a5,0x3
    802005ac:	00f707b3          	add	a5,a4,a5
    802005b0:	0007b783          	ld	a5,0(a5)
    802005b4:	00078693          	mv	a3,a5
    802005b8:	00003717          	auipc	a4,0x3
    802005bc:	a8873703          	ld	a4,-1400(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802005c0:	fec42783          	lw	a5,-20(s0)
    802005c4:	00379793          	slli	a5,a5,0x3
    802005c8:	00f707b3          	add	a5,a4,a5
    802005cc:	0007b783          	ld	a5,0(a5)
    802005d0:	00001737          	lui	a4,0x1
    802005d4:	00e68733          	add	a4,a3,a4
    802005d8:	02e7b423          	sd	a4,40(a5)
    for(int i=1;i<NR_TASKS;i++){
    802005dc:	fec42783          	lw	a5,-20(s0)
    802005e0:	0017879b          	addiw	a5,a5,1
    802005e4:	fef42623          	sw	a5,-20(s0)
    802005e8:	fec42783          	lw	a5,-20(s0)
    802005ec:	0007871b          	sext.w	a4,a5
    802005f0:	01f00793          	li	a5,31
    802005f4:	ece7d6e3          	bge	a5,a4,802004c0 <task_init+0xa8>
       
    }

    printk("...task_init done!\n");
    802005f8:	00002517          	auipc	a0,0x2
    802005fc:	a2050513          	addi	a0,a0,-1504 # 80202018 <_srodata+0x18>
    80200600:	65c010ef          	jal	ra,80201c5c <printk>
}
    80200604:	00000013          	nop
    80200608:	01813083          	ld	ra,24(sp)
    8020060c:	01013403          	ld	s0,16(sp)
    80200610:	02010113          	addi	sp,sp,32
    80200614:	00008067          	ret

0000000080200618 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    80200618:	fd010113          	addi	sp,sp,-48
    8020061c:	02113423          	sd	ra,40(sp)
    80200620:	02813023          	sd	s0,32(sp)
    80200624:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    80200628:	3b9ad7b7          	lui	a5,0x3b9ad
    8020062c:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    80200630:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200634:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    80200638:	fff00793          	li	a5,-1
    8020063c:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200640:	fe442783          	lw	a5,-28(s0)
    80200644:	0007871b          	sext.w	a4,a5
    80200648:	fff00793          	li	a5,-1
    8020064c:	00f70e63          	beq	a4,a5,80200668 <dummy+0x50>
    80200650:	00003797          	auipc	a5,0x3
    80200654:	9e87b783          	ld	a5,-1560(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    80200658:	0007b783          	ld	a5,0(a5)
    8020065c:	0087b703          	ld	a4,8(a5)
    80200660:	fe442783          	lw	a5,-28(s0)
    80200664:	fcf70ee3          	beq	a4,a5,80200640 <dummy+0x28>
    80200668:	00003797          	auipc	a5,0x3
    8020066c:	9d07b783          	ld	a5,-1584(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    80200670:	0007b783          	ld	a5,0(a5)
    80200674:	0087b783          	ld	a5,8(a5)
    80200678:	fc0784e3          	beqz	a5,80200640 <dummy+0x28>
            if (current->counter == 1) {
    8020067c:	00003797          	auipc	a5,0x3
    80200680:	9bc7b783          	ld	a5,-1604(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    80200684:	0007b783          	ld	a5,0(a5)
    80200688:	0087b703          	ld	a4,8(a5)
    8020068c:	00100793          	li	a5,1
    80200690:	00f71e63          	bne	a4,a5,802006ac <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    80200694:	00003797          	auipc	a5,0x3
    80200698:	9a47b783          	ld	a5,-1628(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    8020069c:	0007b783          	ld	a5,0(a5)
    802006a0:	0087b703          	ld	a4,8(a5)
    802006a4:	fff70713          	addi	a4,a4,-1 # fff <_skernel-0x801ff001>
    802006a8:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    802006ac:	00003797          	auipc	a5,0x3
    802006b0:	98c7b783          	ld	a5,-1652(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802006b4:	0007b783          	ld	a5,0(a5)
    802006b8:	0087b783          	ld	a5,8(a5)
    802006bc:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    802006c0:	fe843783          	ld	a5,-24(s0)
    802006c4:	00178713          	addi	a4,a5,1
    802006c8:	fd843783          	ld	a5,-40(s0)
    802006cc:	02f777b3          	remu	a5,a4,a5
    802006d0:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    802006d4:	00003797          	auipc	a5,0x3
    802006d8:	9647b783          	ld	a5,-1692(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802006dc:	0007b783          	ld	a5,0(a5)
    802006e0:	0187b783          	ld	a5,24(a5)
    802006e4:	fe843603          	ld	a2,-24(s0)
    802006e8:	00078593          	mv	a1,a5
    802006ec:	00002517          	auipc	a0,0x2
    802006f0:	94450513          	addi	a0,a0,-1724 # 80202030 <_srodata+0x30>
    802006f4:	568010ef          	jal	ra,80201c5c <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    802006f8:	f49ff06f          	j	80200640 <dummy+0x28>

00000000802006fc <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
    802006fc:	fd010113          	addi	sp,sp,-48
    80200700:	02113423          	sd	ra,40(sp)
    80200704:	02813023          	sd	s0,32(sp)
    80200708:	03010413          	addi	s0,sp,48
    8020070c:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
    80200710:	00003797          	auipc	a5,0x3
    80200714:	9287b783          	ld	a5,-1752(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    80200718:	0007b783          	ld	a5,0(a5)
    8020071c:	fd843703          	ld	a4,-40(s0)
    80200720:	06f70063          	beq	a4,a5,80200780 <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
    80200724:	00003797          	auipc	a5,0x3
    80200728:	9147b783          	ld	a5,-1772(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    8020072c:	0007b783          	ld	a5,0(a5)
    80200730:	fef43423          	sd	a5,-24(s0)
    current=next;
    80200734:	00003797          	auipc	a5,0x3
    80200738:	9047b783          	ld	a5,-1788(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    8020073c:	fd843703          	ld	a4,-40(s0)
    80200740:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
    80200744:	fd843783          	ld	a5,-40(s0)
    80200748:	0187b703          	ld	a4,24(a5)
    8020074c:	fd843783          	ld	a5,-40(s0)
    80200750:	0107b603          	ld	a2,16(a5)
    80200754:	fd843783          	ld	a5,-40(s0)
    80200758:	0087b783          	ld	a5,8(a5)
    8020075c:	00078693          	mv	a3,a5
    80200760:	00070593          	mv	a1,a4
    80200764:	00002517          	auipc	a0,0x2
    80200768:	8fc50513          	addi	a0,a0,-1796 # 80202060 <_srodata+0x60>
    8020076c:	4f0010ef          	jal	ra,80201c5c <printk>
    __switch_to(prev,next);
    80200770:	fd843583          	ld	a1,-40(s0)
    80200774:	fe843503          	ld	a0,-24(s0)
    80200778:	a05ff0ef          	jal	ra,8020017c <__switch_to>
    8020077c:	0080006f          	j	80200784 <switch_to+0x88>
        return;
    80200780:	00000013          	nop
    
}
    80200784:	02813083          	ld	ra,40(sp)
    80200788:	02013403          	ld	s0,32(sp)
    8020078c:	03010113          	addi	sp,sp,48
    80200790:	00008067          	ret

0000000080200794 <do_timer>:

void do_timer(){
    80200794:	ff010113          	addi	sp,sp,-16
    80200798:	00113423          	sd	ra,8(sp)
    8020079c:	00813023          	sd	s0,0(sp)
    802007a0:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
    802007a4:	00003797          	auipc	a5,0x3
    802007a8:	8947b783          	ld	a5,-1900(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802007ac:	0007b703          	ld	a4,0(a5)
    802007b0:	00003797          	auipc	a5,0x3
    802007b4:	8787b783          	ld	a5,-1928(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    802007b8:	0007b783          	ld	a5,0(a5)
    802007bc:	00f70c63          	beq	a4,a5,802007d4 <do_timer+0x40>
    802007c0:	00003797          	auipc	a5,0x3
    802007c4:	8787b783          	ld	a5,-1928(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802007c8:	0007b783          	ld	a5,0(a5)
    802007cc:	0087b783          	ld	a5,8(a5)
    802007d0:	00079663          	bnez	a5,802007dc <do_timer+0x48>
        schedule();
    802007d4:	04c000ef          	jal	ra,80200820 <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
    802007d8:	0340006f          	j	8020080c <do_timer+0x78>
        current->counter--;
    802007dc:	00003797          	auipc	a5,0x3
    802007e0:	85c7b783          	ld	a5,-1956(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802007e4:	0007b783          	ld	a5,0(a5)
    802007e8:	0087b703          	ld	a4,8(a5)
    802007ec:	fff70713          	addi	a4,a4,-1
    802007f0:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
    802007f4:	00003797          	auipc	a5,0x3
    802007f8:	8447b783          	ld	a5,-1980(a5) # 80203038 <_GLOBAL_OFFSET_TABLE_+0x30>
    802007fc:	0007b783          	ld	a5,0(a5)
    80200800:	0087b783          	ld	a5,8(a5)
    80200804:	00079463          	bnez	a5,8020080c <do_timer+0x78>
            schedule();
    80200808:	018000ef          	jal	ra,80200820 <schedule>
}
    8020080c:	00000013          	nop
    80200810:	00813083          	ld	ra,8(sp)
    80200814:	00013403          	ld	s0,0(sp)
    80200818:	01010113          	addi	sp,sp,16
    8020081c:	00008067          	ret

0000000080200820 <schedule>:

void schedule(){
    80200820:	fd010113          	addi	sp,sp,-48
    80200824:	02113423          	sd	ra,40(sp)
    80200828:	02813023          	sd	s0,32(sp)
    8020082c:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
    80200830:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
    80200834:	fe043023          	sd	zero,-32(s0)
    for(int i=0;i<NR_TASKS;i++){
    80200838:	fc042e23          	sw	zero,-36(s0)
    8020083c:	0700006f          	j	802008ac <schedule+0x8c>
        if(task[i]->counter>max_counter){
    80200840:	00003717          	auipc	a4,0x3
    80200844:	80073703          	ld	a4,-2048(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200848:	fdc42783          	lw	a5,-36(s0)
    8020084c:	00379793          	slli	a5,a5,0x3
    80200850:	00f707b3          	add	a5,a4,a5
    80200854:	0007b783          	ld	a5,0(a5)
    80200858:	0087b783          	ld	a5,8(a5)
    8020085c:	fe043703          	ld	a4,-32(s0)
    80200860:	04f77063          	bgeu	a4,a5,802008a0 <schedule+0x80>
            max_counter=task[i]->counter;
    80200864:	00002717          	auipc	a4,0x2
    80200868:	7dc73703          	ld	a4,2012(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020086c:	fdc42783          	lw	a5,-36(s0)
    80200870:	00379793          	slli	a5,a5,0x3
    80200874:	00f707b3          	add	a5,a4,a5
    80200878:	0007b783          	ld	a5,0(a5)
    8020087c:	0087b783          	ld	a5,8(a5)
    80200880:	fef43023          	sd	a5,-32(s0)
            next=task[i];
    80200884:	00002717          	auipc	a4,0x2
    80200888:	7bc73703          	ld	a4,1980(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020088c:	fdc42783          	lw	a5,-36(s0)
    80200890:	00379793          	slli	a5,a5,0x3
    80200894:	00f707b3          	add	a5,a4,a5
    80200898:	0007b783          	ld	a5,0(a5)
    8020089c:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
    802008a0:	fdc42783          	lw	a5,-36(s0)
    802008a4:	0017879b          	addiw	a5,a5,1
    802008a8:	fcf42e23          	sw	a5,-36(s0)
    802008ac:	fdc42783          	lw	a5,-36(s0)
    802008b0:	0007871b          	sext.w	a4,a5
    802008b4:	01f00793          	li	a5,31
    802008b8:	f8e7d4e3          	bge	a5,a4,80200840 <schedule+0x20>
        }
    }
    if(max_counter==0){
    802008bc:	fe043783          	ld	a5,-32(s0)
    802008c0:	12079463          	bnez	a5,802009e8 <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
    802008c4:	00100793          	li	a5,1
    802008c8:	fcf42c23          	sw	a5,-40(s0)
    802008cc:	10c0006f          	j	802009d8 <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
    802008d0:	00002717          	auipc	a4,0x2
    802008d4:	77073703          	ld	a4,1904(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802008d8:	fd842783          	lw	a5,-40(s0)
    802008dc:	00379793          	slli	a5,a5,0x3
    802008e0:	00f707b3          	add	a5,a4,a5
    802008e4:	0007b703          	ld	a4,0(a5)
    802008e8:	00002697          	auipc	a3,0x2
    802008ec:	7586b683          	ld	a3,1880(a3) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802008f0:	fd842783          	lw	a5,-40(s0)
    802008f4:	00379793          	slli	a5,a5,0x3
    802008f8:	00f687b3          	add	a5,a3,a5
    802008fc:	0007b783          	ld	a5,0(a5)
    80200900:	01073703          	ld	a4,16(a4)
    80200904:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
    80200908:	00002717          	auipc	a4,0x2
    8020090c:	73873703          	ld	a4,1848(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200910:	fd842783          	lw	a5,-40(s0)
    80200914:	00379793          	slli	a5,a5,0x3
    80200918:	00f707b3          	add	a5,a4,a5
    8020091c:	0007b783          	ld	a5,0(a5)
    80200920:	0187b583          	ld	a1,24(a5)
    80200924:	00002717          	auipc	a4,0x2
    80200928:	71c73703          	ld	a4,1820(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020092c:	fd842783          	lw	a5,-40(s0)
    80200930:	00379793          	slli	a5,a5,0x3
    80200934:	00f707b3          	add	a5,a4,a5
    80200938:	0007b783          	ld	a5,0(a5)
    8020093c:	0107b603          	ld	a2,16(a5)
    80200940:	00002717          	auipc	a4,0x2
    80200944:	70073703          	ld	a4,1792(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200948:	fd842783          	lw	a5,-40(s0)
    8020094c:	00379793          	slli	a5,a5,0x3
    80200950:	00f707b3          	add	a5,a4,a5
    80200954:	0007b783          	ld	a5,0(a5)
    80200958:	0087b783          	ld	a5,8(a5)
    8020095c:	00078693          	mv	a3,a5
    80200960:	00001517          	auipc	a0,0x1
    80200964:	74050513          	addi	a0,a0,1856 # 802020a0 <_srodata+0xa0>
    80200968:	2f4010ef          	jal	ra,80201c5c <printk>
            if(task[i]->counter>max_counter){
    8020096c:	00002717          	auipc	a4,0x2
    80200970:	6d473703          	ld	a4,1748(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200974:	fd842783          	lw	a5,-40(s0)
    80200978:	00379793          	slli	a5,a5,0x3
    8020097c:	00f707b3          	add	a5,a4,a5
    80200980:	0007b783          	ld	a5,0(a5)
    80200984:	0087b783          	ld	a5,8(a5)
    80200988:	fe043703          	ld	a4,-32(s0)
    8020098c:	04f77063          	bgeu	a4,a5,802009cc <schedule+0x1ac>
                max_counter=task[i]->counter;
    80200990:	00002717          	auipc	a4,0x2
    80200994:	6b073703          	ld	a4,1712(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200998:	fd842783          	lw	a5,-40(s0)
    8020099c:	00379793          	slli	a5,a5,0x3
    802009a0:	00f707b3          	add	a5,a4,a5
    802009a4:	0007b783          	ld	a5,0(a5)
    802009a8:	0087b783          	ld	a5,8(a5)
    802009ac:	fef43023          	sd	a5,-32(s0)
                next=task[i];
    802009b0:	00002717          	auipc	a4,0x2
    802009b4:	69073703          	ld	a4,1680(a4) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x38>
    802009b8:	fd842783          	lw	a5,-40(s0)
    802009bc:	00379793          	slli	a5,a5,0x3
    802009c0:	00f707b3          	add	a5,a4,a5
    802009c4:	0007b783          	ld	a5,0(a5)
    802009c8:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
    802009cc:	fd842783          	lw	a5,-40(s0)
    802009d0:	0017879b          	addiw	a5,a5,1
    802009d4:	fcf42c23          	sw	a5,-40(s0)
    802009d8:	fd842783          	lw	a5,-40(s0)
    802009dc:	0007871b          	sext.w	a4,a5
    802009e0:	01f00793          	li	a5,31
    802009e4:	eee7d6e3          	bge	a5,a4,802008d0 <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
    802009e8:	fe843783          	ld	a5,-24(s0)
    802009ec:	00078663          	beqz	a5,802009f8 <schedule+0x1d8>
    802009f0:	fe843503          	ld	a0,-24(s0)
    802009f4:	d09ff0ef          	jal	ra,802006fc <switch_to>
}
    802009f8:	00000013          	nop
    802009fc:	02813083          	ld	ra,40(sp)
    80200a00:	02013403          	ld	s0,32(sp)
    80200a04:	03010113          	addi	sp,sp,48
    80200a08:	00008067          	ret

0000000080200a0c <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    80200a0c:	f8010113          	addi	sp,sp,-128
    80200a10:	06813c23          	sd	s0,120(sp)
    80200a14:	06913823          	sd	s1,112(sp)
    80200a18:	07213423          	sd	s2,104(sp)
    80200a1c:	07313023          	sd	s3,96(sp)
    80200a20:	08010413          	addi	s0,sp,128
    80200a24:	faa43c23          	sd	a0,-72(s0)
    80200a28:	fab43823          	sd	a1,-80(s0)
    80200a2c:	fac43423          	sd	a2,-88(s0)
    80200a30:	fad43023          	sd	a3,-96(s0)
    80200a34:	f8e43c23          	sd	a4,-104(s0)
    80200a38:	f8f43823          	sd	a5,-112(s0)
    80200a3c:	f9043423          	sd	a6,-120(s0)
    80200a40:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
    80200a44:	fb843e03          	ld	t3,-72(s0)
    80200a48:	fb043e83          	ld	t4,-80(s0)
    80200a4c:	fa843f03          	ld	t5,-88(s0)
    80200a50:	fa043f83          	ld	t6,-96(s0)
    80200a54:	f9843283          	ld	t0,-104(s0)
    80200a58:	f9043483          	ld	s1,-112(s0)
    80200a5c:	f8843903          	ld	s2,-120(s0)
    80200a60:	f8043983          	ld	s3,-128(s0)
    80200a64:	000e0893          	mv	a7,t3
    80200a68:	000e8813          	mv	a6,t4
    80200a6c:	000f0513          	mv	a0,t5
    80200a70:	000f8593          	mv	a1,t6
    80200a74:	00028613          	mv	a2,t0
    80200a78:	00048693          	mv	a3,s1
    80200a7c:	00090713          	mv	a4,s2
    80200a80:	00098793          	mv	a5,s3
    80200a84:	00000073          	ecall
    80200a88:	00050e93          	mv	t4,a0
    80200a8c:	00058e13          	mv	t3,a1
    80200a90:	fdd43023          	sd	t4,-64(s0)
    80200a94:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
    80200a98:	fc043783          	ld	a5,-64(s0)
    80200a9c:	fcf43823          	sd	a5,-48(s0)
    80200aa0:	fc843783          	ld	a5,-56(s0)
    80200aa4:	fcf43c23          	sd	a5,-40(s0)
    80200aa8:	00000713          	li	a4,0
    80200aac:	fd043703          	ld	a4,-48(s0)
    80200ab0:	00000793          	li	a5,0
    80200ab4:	fd843783          	ld	a5,-40(s0)
    80200ab8:	00070313          	mv	t1,a4
    80200abc:	00078393          	mv	t2,a5
    80200ac0:	00030713          	mv	a4,t1
    80200ac4:	00038793          	mv	a5,t2
}
    80200ac8:	00070513          	mv	a0,a4
    80200acc:	00078593          	mv	a1,a5
    80200ad0:	07813403          	ld	s0,120(sp)
    80200ad4:	07013483          	ld	s1,112(sp)
    80200ad8:	06813903          	ld	s2,104(sp)
    80200adc:	06013983          	ld	s3,96(sp)
    80200ae0:	08010113          	addi	sp,sp,128
    80200ae4:	00008067          	ret

0000000080200ae8 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    80200ae8:	fc010113          	addi	sp,sp,-64
    80200aec:	02113c23          	sd	ra,56(sp)
    80200af0:	02813823          	sd	s0,48(sp)
    80200af4:	03213423          	sd	s2,40(sp)
    80200af8:	03313023          	sd	s3,32(sp)
    80200afc:	04010413          	addi	s0,sp,64
    80200b00:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
    80200b04:	00000893          	li	a7,0
    80200b08:	00000813          	li	a6,0
    80200b0c:	00000793          	li	a5,0
    80200b10:	00000713          	li	a4,0
    80200b14:	00000693          	li	a3,0
    80200b18:	fc843603          	ld	a2,-56(s0)
    80200b1c:	00000593          	li	a1,0
    80200b20:	54495537          	lui	a0,0x54495
    80200b24:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200b28:	ee5ff0ef          	jal	ra,80200a0c <sbi_ecall>
    80200b2c:	00050713          	mv	a4,a0
    80200b30:	00058793          	mv	a5,a1
    80200b34:	fce43823          	sd	a4,-48(s0)
    80200b38:	fcf43c23          	sd	a5,-40(s0)
    80200b3c:	00000713          	li	a4,0
    80200b40:	fd043703          	ld	a4,-48(s0)
    80200b44:	00000793          	li	a5,0
    80200b48:	fd843783          	ld	a5,-40(s0)
    80200b4c:	00070913          	mv	s2,a4
    80200b50:	00078993          	mv	s3,a5
    80200b54:	00090713          	mv	a4,s2
    80200b58:	00098793          	mv	a5,s3
}
    80200b5c:	00070513          	mv	a0,a4
    80200b60:	00078593          	mv	a1,a5
    80200b64:	03813083          	ld	ra,56(sp)
    80200b68:	03013403          	ld	s0,48(sp)
    80200b6c:	02813903          	ld	s2,40(sp)
    80200b70:	02013983          	ld	s3,32(sp)
    80200b74:	04010113          	addi	sp,sp,64
    80200b78:	00008067          	ret

0000000080200b7c <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200b7c:	fc010113          	addi	sp,sp,-64
    80200b80:	02113c23          	sd	ra,56(sp)
    80200b84:	02813823          	sd	s0,48(sp)
    80200b88:	03213423          	sd	s2,40(sp)
    80200b8c:	03313023          	sd	s3,32(sp)
    80200b90:	04010413          	addi	s0,sp,64
    80200b94:	00050793          	mv	a5,a0
    80200b98:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
    80200b9c:	fcf44603          	lbu	a2,-49(s0)
    80200ba0:	00000893          	li	a7,0
    80200ba4:	00000813          	li	a6,0
    80200ba8:	00000793          	li	a5,0
    80200bac:	00000713          	li	a4,0
    80200bb0:	00000693          	li	a3,0
    80200bb4:	00200593          	li	a1,2
    80200bb8:	44424537          	lui	a0,0x44424
    80200bbc:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200bc0:	e4dff0ef          	jal	ra,80200a0c <sbi_ecall>
    80200bc4:	00050713          	mv	a4,a0
    80200bc8:	00058793          	mv	a5,a1
    80200bcc:	fce43823          	sd	a4,-48(s0)
    80200bd0:	fcf43c23          	sd	a5,-40(s0)
    80200bd4:	00000713          	li	a4,0
    80200bd8:	fd043703          	ld	a4,-48(s0)
    80200bdc:	00000793          	li	a5,0
    80200be0:	fd843783          	ld	a5,-40(s0)
    80200be4:	00070913          	mv	s2,a4
    80200be8:	00078993          	mv	s3,a5
    80200bec:	00090713          	mv	a4,s2
    80200bf0:	00098793          	mv	a5,s3
}
    80200bf4:	00070513          	mv	a0,a4
    80200bf8:	00078593          	mv	a1,a5
    80200bfc:	03813083          	ld	ra,56(sp)
    80200c00:	03013403          	ld	s0,48(sp)
    80200c04:	02813903          	ld	s2,40(sp)
    80200c08:	02013983          	ld	s3,32(sp)
    80200c0c:	04010113          	addi	sp,sp,64
    80200c10:	00008067          	ret

0000000080200c14 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200c14:	fc010113          	addi	sp,sp,-64
    80200c18:	02113c23          	sd	ra,56(sp)
    80200c1c:	02813823          	sd	s0,48(sp)
    80200c20:	03213423          	sd	s2,40(sp)
    80200c24:	03313023          	sd	s3,32(sp)
    80200c28:	04010413          	addi	s0,sp,64
    80200c2c:	00050793          	mv	a5,a0
    80200c30:	00058713          	mv	a4,a1
    80200c34:	fcf42623          	sw	a5,-52(s0)
    80200c38:	00070793          	mv	a5,a4
    80200c3c:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
    80200c40:	fcc46603          	lwu	a2,-52(s0)
    80200c44:	fc846683          	lwu	a3,-56(s0)
    80200c48:	00000893          	li	a7,0
    80200c4c:	00000813          	li	a6,0
    80200c50:	00000793          	li	a5,0
    80200c54:	00000713          	li	a4,0
    80200c58:	00000593          	li	a1,0
    80200c5c:	53525537          	lui	a0,0x53525
    80200c60:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200c64:	da9ff0ef          	jal	ra,80200a0c <sbi_ecall>
    80200c68:	00050713          	mv	a4,a0
    80200c6c:	00058793          	mv	a5,a1
    80200c70:	fce43823          	sd	a4,-48(s0)
    80200c74:	fcf43c23          	sd	a5,-40(s0)
    80200c78:	00000713          	li	a4,0
    80200c7c:	fd043703          	ld	a4,-48(s0)
    80200c80:	00000793          	li	a5,0
    80200c84:	fd843783          	ld	a5,-40(s0)
    80200c88:	00070913          	mv	s2,a4
    80200c8c:	00078993          	mv	s3,a5
    80200c90:	00090713          	mv	a4,s2
    80200c94:	00098793          	mv	a5,s3
    80200c98:	00070513          	mv	a0,a4
    80200c9c:	00078593          	mv	a1,a5
    80200ca0:	03813083          	ld	ra,56(sp)
    80200ca4:	03013403          	ld	s0,48(sp)
    80200ca8:	02813903          	ld	s2,40(sp)
    80200cac:	02013983          	ld	s3,32(sp)
    80200cb0:	04010113          	addi	sp,sp,64
    80200cb4:	00008067          	ret

0000000080200cb8 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200cb8:	fd010113          	addi	sp,sp,-48
    80200cbc:	02113423          	sd	ra,40(sp)
    80200cc0:	02813023          	sd	s0,32(sp)
    80200cc4:	03010413          	addi	s0,sp,48
    80200cc8:	fca43c23          	sd	a0,-40(s0)
    80200ccc:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
    80200cd0:	fd843783          	ld	a5,-40(s0)
    80200cd4:	0407d263          	bgez	a5,80200d18 <trap_handler+0x60>
        uint64_t interrupt_code = scause & ~(1UL << 63);
    80200cd8:	fd843703          	ld	a4,-40(s0)
    80200cdc:	fff00793          	li	a5,-1
    80200ce0:	0017d793          	srli	a5,a5,0x1
    80200ce4:	00f777b3          	and	a5,a4,a5
    80200ce8:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
    80200cec:	fe043703          	ld	a4,-32(s0)
    80200cf0:	00500793          	li	a5,5
    80200cf4:	00f71863          	bne	a4,a5,80200d04 <trap_handler+0x4c>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
    80200cf8:	d3cff0ef          	jal	ra,80200234 <clock_set_next_event>
            do_timer();
    80200cfc:	a99ff0ef          	jal	ra,80200794 <do_timer>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
    80200d00:	0300006f          	j	80200d30 <trap_handler+0x78>
            printk("other interrupt: %d\n", interrupt_code);
    80200d04:	fe043583          	ld	a1,-32(s0)
    80200d08:	00001517          	auipc	a0,0x1
    80200d0c:	3d050513          	addi	a0,a0,976 # 802020d8 <_srodata+0xd8>
    80200d10:	74d000ef          	jal	ra,80201c5c <printk>
    80200d14:	01c0006f          	j	80200d30 <trap_handler+0x78>
        uint64_t exception_code = scause;
    80200d18:	fd843783          	ld	a5,-40(s0)
    80200d1c:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
    80200d20:	fe843583          	ld	a1,-24(s0)
    80200d24:	00001517          	auipc	a0,0x1
    80200d28:	3cc50513          	addi	a0,a0,972 # 802020f0 <_srodata+0xf0>
    80200d2c:	731000ef          	jal	ra,80201c5c <printk>
    80200d30:	00000013          	nop
    80200d34:	02813083          	ld	ra,40(sp)
    80200d38:	02013403          	ld	s0,32(sp)
    80200d3c:	03010113          	addi	sp,sp,48
    80200d40:	00008067          	ret

0000000080200d44 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    80200d44:	ff010113          	addi	sp,sp,-16
    80200d48:	00113423          	sd	ra,8(sp)
    80200d4c:	00813023          	sd	s0,0(sp)
    80200d50:	01010413          	addi	s0,sp,16
    printk("2024");
    80200d54:	00001517          	auipc	a0,0x1
    80200d58:	3ac50513          	addi	a0,a0,940 # 80202100 <_srodata+0x100>
    80200d5c:	701000ef          	jal	ra,80201c5c <printk>
    printk(" ZJU Operating System\n");
    80200d60:	00001517          	auipc	a0,0x1
    80200d64:	3a850513          	addi	a0,a0,936 # 80202108 <_srodata+0x108>
    80200d68:	6f5000ef          	jal	ra,80201c5c <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
    80200d6c:	01c000ef          	jal	ra,80200d88 <test>
    return 0;
    80200d70:	00000793          	li	a5,0
}
    80200d74:	00078513          	mv	a0,a5
    80200d78:	00813083          	ld	ra,8(sp)
    80200d7c:	00013403          	ld	s0,0(sp)
    80200d80:	01010113          	addi	sp,sp,16
    80200d84:	00008067          	ret

0000000080200d88 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
    80200d88:	fe010113          	addi	sp,sp,-32
    80200d8c:	00113c23          	sd	ra,24(sp)
    80200d90:	00813823          	sd	s0,16(sp)
    80200d94:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
    80200d98:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200d9c:	fec42783          	lw	a5,-20(s0)
    80200da0:	0017879b          	addiw	a5,a5,1
    80200da4:	fef42623          	sw	a5,-20(s0)
    80200da8:	fec42703          	lw	a4,-20(s0)
    80200dac:	05f5e7b7          	lui	a5,0x5f5e
    80200db0:	1007879b          	addiw	a5,a5,256
    80200db4:	02f767bb          	remw	a5,a4,a5
    80200db8:	0007879b          	sext.w	a5,a5
    80200dbc:	fe0790e3          	bnez	a5,80200d9c <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
    80200dc0:	00001517          	auipc	a0,0x1
    80200dc4:	36050513          	addi	a0,a0,864 # 80202120 <_srodata+0x120>
    80200dc8:	695000ef          	jal	ra,80201c5c <printk>
            i = 0;
    80200dcc:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200dd0:	fcdff06f          	j	80200d9c <test+0x14>

0000000080200dd4 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200dd4:	fe010113          	addi	sp,sp,-32
    80200dd8:	00113c23          	sd	ra,24(sp)
    80200ddc:	00813823          	sd	s0,16(sp)
    80200de0:	02010413          	addi	s0,sp,32
    80200de4:	00050793          	mv	a5,a0
    80200de8:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200dec:	fec42783          	lw	a5,-20(s0)
    80200df0:	0ff7f793          	andi	a5,a5,255
    80200df4:	00078513          	mv	a0,a5
    80200df8:	d85ff0ef          	jal	ra,80200b7c <sbi_debug_console_write_byte>
    return (char)c;
    80200dfc:	fec42783          	lw	a5,-20(s0)
    80200e00:	0ff7f793          	andi	a5,a5,255
    80200e04:	0007879b          	sext.w	a5,a5
}
    80200e08:	00078513          	mv	a0,a5
    80200e0c:	01813083          	ld	ra,24(sp)
    80200e10:	01013403          	ld	s0,16(sp)
    80200e14:	02010113          	addi	sp,sp,32
    80200e18:	00008067          	ret

0000000080200e1c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200e1c:	fe010113          	addi	sp,sp,-32
    80200e20:	00813c23          	sd	s0,24(sp)
    80200e24:	02010413          	addi	s0,sp,32
    80200e28:	00050793          	mv	a5,a0
    80200e2c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200e30:	fec42783          	lw	a5,-20(s0)
    80200e34:	0007871b          	sext.w	a4,a5
    80200e38:	02000793          	li	a5,32
    80200e3c:	02f70263          	beq	a4,a5,80200e60 <isspace+0x44>
    80200e40:	fec42783          	lw	a5,-20(s0)
    80200e44:	0007871b          	sext.w	a4,a5
    80200e48:	00800793          	li	a5,8
    80200e4c:	00e7de63          	bge	a5,a4,80200e68 <isspace+0x4c>
    80200e50:	fec42783          	lw	a5,-20(s0)
    80200e54:	0007871b          	sext.w	a4,a5
    80200e58:	00d00793          	li	a5,13
    80200e5c:	00e7c663          	blt	a5,a4,80200e68 <isspace+0x4c>
    80200e60:	00100793          	li	a5,1
    80200e64:	0080006f          	j	80200e6c <isspace+0x50>
    80200e68:	00000793          	li	a5,0
}
    80200e6c:	00078513          	mv	a0,a5
    80200e70:	01813403          	ld	s0,24(sp)
    80200e74:	02010113          	addi	sp,sp,32
    80200e78:	00008067          	ret

0000000080200e7c <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200e7c:	fb010113          	addi	sp,sp,-80
    80200e80:	04113423          	sd	ra,72(sp)
    80200e84:	04813023          	sd	s0,64(sp)
    80200e88:	05010413          	addi	s0,sp,80
    80200e8c:	fca43423          	sd	a0,-56(s0)
    80200e90:	fcb43023          	sd	a1,-64(s0)
    80200e94:	00060793          	mv	a5,a2
    80200e98:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200e9c:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200ea0:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200ea4:	fc843783          	ld	a5,-56(s0)
    80200ea8:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200eac:	0100006f          	j	80200ebc <strtol+0x40>
        p++;
    80200eb0:	fd843783          	ld	a5,-40(s0)
    80200eb4:	00178793          	addi	a5,a5,1 # 5f5e001 <_skernel-0x7a2a1fff>
    80200eb8:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200ebc:	fd843783          	ld	a5,-40(s0)
    80200ec0:	0007c783          	lbu	a5,0(a5)
    80200ec4:	0007879b          	sext.w	a5,a5
    80200ec8:	00078513          	mv	a0,a5
    80200ecc:	f51ff0ef          	jal	ra,80200e1c <isspace>
    80200ed0:	00050793          	mv	a5,a0
    80200ed4:	fc079ee3          	bnez	a5,80200eb0 <strtol+0x34>
    }

    if (*p == '-') {
    80200ed8:	fd843783          	ld	a5,-40(s0)
    80200edc:	0007c783          	lbu	a5,0(a5)
    80200ee0:	00078713          	mv	a4,a5
    80200ee4:	02d00793          	li	a5,45
    80200ee8:	00f71e63          	bne	a4,a5,80200f04 <strtol+0x88>
        neg = true;
    80200eec:	00100793          	li	a5,1
    80200ef0:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200ef4:	fd843783          	ld	a5,-40(s0)
    80200ef8:	00178793          	addi	a5,a5,1
    80200efc:	fcf43c23          	sd	a5,-40(s0)
    80200f00:	0240006f          	j	80200f24 <strtol+0xa8>
    } else if (*p == '+') {
    80200f04:	fd843783          	ld	a5,-40(s0)
    80200f08:	0007c783          	lbu	a5,0(a5)
    80200f0c:	00078713          	mv	a4,a5
    80200f10:	02b00793          	li	a5,43
    80200f14:	00f71863          	bne	a4,a5,80200f24 <strtol+0xa8>
        p++;
    80200f18:	fd843783          	ld	a5,-40(s0)
    80200f1c:	00178793          	addi	a5,a5,1
    80200f20:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200f24:	fbc42783          	lw	a5,-68(s0)
    80200f28:	0007879b          	sext.w	a5,a5
    80200f2c:	06079c63          	bnez	a5,80200fa4 <strtol+0x128>
        if (*p == '0') {
    80200f30:	fd843783          	ld	a5,-40(s0)
    80200f34:	0007c783          	lbu	a5,0(a5)
    80200f38:	00078713          	mv	a4,a5
    80200f3c:	03000793          	li	a5,48
    80200f40:	04f71e63          	bne	a4,a5,80200f9c <strtol+0x120>
            p++;
    80200f44:	fd843783          	ld	a5,-40(s0)
    80200f48:	00178793          	addi	a5,a5,1
    80200f4c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200f50:	fd843783          	ld	a5,-40(s0)
    80200f54:	0007c783          	lbu	a5,0(a5)
    80200f58:	00078713          	mv	a4,a5
    80200f5c:	07800793          	li	a5,120
    80200f60:	00f70c63          	beq	a4,a5,80200f78 <strtol+0xfc>
    80200f64:	fd843783          	ld	a5,-40(s0)
    80200f68:	0007c783          	lbu	a5,0(a5)
    80200f6c:	00078713          	mv	a4,a5
    80200f70:	05800793          	li	a5,88
    80200f74:	00f71e63          	bne	a4,a5,80200f90 <strtol+0x114>
                base = 16;
    80200f78:	01000793          	li	a5,16
    80200f7c:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200f80:	fd843783          	ld	a5,-40(s0)
    80200f84:	00178793          	addi	a5,a5,1
    80200f88:	fcf43c23          	sd	a5,-40(s0)
    80200f8c:	0180006f          	j	80200fa4 <strtol+0x128>
            } else {
                base = 8;
    80200f90:	00800793          	li	a5,8
    80200f94:	faf42e23          	sw	a5,-68(s0)
    80200f98:	00c0006f          	j	80200fa4 <strtol+0x128>
            }
        } else {
            base = 10;
    80200f9c:	00a00793          	li	a5,10
    80200fa0:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200fa4:	fd843783          	ld	a5,-40(s0)
    80200fa8:	0007c783          	lbu	a5,0(a5)
    80200fac:	00078713          	mv	a4,a5
    80200fb0:	02f00793          	li	a5,47
    80200fb4:	02e7f863          	bgeu	a5,a4,80200fe4 <strtol+0x168>
    80200fb8:	fd843783          	ld	a5,-40(s0)
    80200fbc:	0007c783          	lbu	a5,0(a5)
    80200fc0:	00078713          	mv	a4,a5
    80200fc4:	03900793          	li	a5,57
    80200fc8:	00e7ee63          	bltu	a5,a4,80200fe4 <strtol+0x168>
            digit = *p - '0';
    80200fcc:	fd843783          	ld	a5,-40(s0)
    80200fd0:	0007c783          	lbu	a5,0(a5)
    80200fd4:	0007879b          	sext.w	a5,a5
    80200fd8:	fd07879b          	addiw	a5,a5,-48
    80200fdc:	fcf42a23          	sw	a5,-44(s0)
    80200fe0:	0800006f          	j	80201060 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200fe4:	fd843783          	ld	a5,-40(s0)
    80200fe8:	0007c783          	lbu	a5,0(a5)
    80200fec:	00078713          	mv	a4,a5
    80200ff0:	06000793          	li	a5,96
    80200ff4:	02e7f863          	bgeu	a5,a4,80201024 <strtol+0x1a8>
    80200ff8:	fd843783          	ld	a5,-40(s0)
    80200ffc:	0007c783          	lbu	a5,0(a5)
    80201000:	00078713          	mv	a4,a5
    80201004:	07a00793          	li	a5,122
    80201008:	00e7ee63          	bltu	a5,a4,80201024 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    8020100c:	fd843783          	ld	a5,-40(s0)
    80201010:	0007c783          	lbu	a5,0(a5)
    80201014:	0007879b          	sext.w	a5,a5
    80201018:	fa97879b          	addiw	a5,a5,-87
    8020101c:	fcf42a23          	sw	a5,-44(s0)
    80201020:	0400006f          	j	80201060 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80201024:	fd843783          	ld	a5,-40(s0)
    80201028:	0007c783          	lbu	a5,0(a5)
    8020102c:	00078713          	mv	a4,a5
    80201030:	04000793          	li	a5,64
    80201034:	06e7f663          	bgeu	a5,a4,802010a0 <strtol+0x224>
    80201038:	fd843783          	ld	a5,-40(s0)
    8020103c:	0007c783          	lbu	a5,0(a5)
    80201040:	00078713          	mv	a4,a5
    80201044:	05a00793          	li	a5,90
    80201048:	04e7ec63          	bltu	a5,a4,802010a0 <strtol+0x224>
            digit = *p - ('A' - 10);
    8020104c:	fd843783          	ld	a5,-40(s0)
    80201050:	0007c783          	lbu	a5,0(a5)
    80201054:	0007879b          	sext.w	a5,a5
    80201058:	fc97879b          	addiw	a5,a5,-55
    8020105c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80201060:	fd442703          	lw	a4,-44(s0)
    80201064:	fbc42783          	lw	a5,-68(s0)
    80201068:	0007071b          	sext.w	a4,a4
    8020106c:	0007879b          	sext.w	a5,a5
    80201070:	02f75663          	bge	a4,a5,8020109c <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
    80201074:	fbc42703          	lw	a4,-68(s0)
    80201078:	fe843783          	ld	a5,-24(s0)
    8020107c:	02f70733          	mul	a4,a4,a5
    80201080:	fd442783          	lw	a5,-44(s0)
    80201084:	00f707b3          	add	a5,a4,a5
    80201088:	fef43423          	sd	a5,-24(s0)
        p++;
    8020108c:	fd843783          	ld	a5,-40(s0)
    80201090:	00178793          	addi	a5,a5,1
    80201094:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80201098:	f0dff06f          	j	80200fa4 <strtol+0x128>
            break;
    8020109c:	00000013          	nop
    }

    if (endptr) {
    802010a0:	fc043783          	ld	a5,-64(s0)
    802010a4:	00078863          	beqz	a5,802010b4 <strtol+0x238>
        *endptr = (char *)p;
    802010a8:	fc043783          	ld	a5,-64(s0)
    802010ac:	fd843703          	ld	a4,-40(s0)
    802010b0:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    802010b4:	fe744783          	lbu	a5,-25(s0)
    802010b8:	0ff7f793          	andi	a5,a5,255
    802010bc:	00078863          	beqz	a5,802010cc <strtol+0x250>
    802010c0:	fe843783          	ld	a5,-24(s0)
    802010c4:	40f007b3          	neg	a5,a5
    802010c8:	0080006f          	j	802010d0 <strtol+0x254>
    802010cc:	fe843783          	ld	a5,-24(s0)
}
    802010d0:	00078513          	mv	a0,a5
    802010d4:	04813083          	ld	ra,72(sp)
    802010d8:	04013403          	ld	s0,64(sp)
    802010dc:	05010113          	addi	sp,sp,80
    802010e0:	00008067          	ret

00000000802010e4 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    802010e4:	fd010113          	addi	sp,sp,-48
    802010e8:	02113423          	sd	ra,40(sp)
    802010ec:	02813023          	sd	s0,32(sp)
    802010f0:	03010413          	addi	s0,sp,48
    802010f4:	fca43c23          	sd	a0,-40(s0)
    802010f8:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    802010fc:	fd043783          	ld	a5,-48(s0)
    80201100:	00079863          	bnez	a5,80201110 <puts_wo_nl+0x2c>
        s = "(null)";
    80201104:	00001797          	auipc	a5,0x1
    80201108:	03478793          	addi	a5,a5,52 # 80202138 <_srodata+0x138>
    8020110c:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80201110:	fd043783          	ld	a5,-48(s0)
    80201114:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80201118:	0240006f          	j	8020113c <puts_wo_nl+0x58>
        putch(*p++);
    8020111c:	fe843783          	ld	a5,-24(s0)
    80201120:	00178713          	addi	a4,a5,1
    80201124:	fee43423          	sd	a4,-24(s0)
    80201128:	0007c783          	lbu	a5,0(a5)
    8020112c:	0007879b          	sext.w	a5,a5
    80201130:	fd843703          	ld	a4,-40(s0)
    80201134:	00078513          	mv	a0,a5
    80201138:	000700e7          	jalr	a4
    while (*p) {
    8020113c:	fe843783          	ld	a5,-24(s0)
    80201140:	0007c783          	lbu	a5,0(a5)
    80201144:	fc079ce3          	bnez	a5,8020111c <puts_wo_nl+0x38>
    }
    return p - s;
    80201148:	fe843703          	ld	a4,-24(s0)
    8020114c:	fd043783          	ld	a5,-48(s0)
    80201150:	40f707b3          	sub	a5,a4,a5
    80201154:	0007879b          	sext.w	a5,a5
}
    80201158:	00078513          	mv	a0,a5
    8020115c:	02813083          	ld	ra,40(sp)
    80201160:	02013403          	ld	s0,32(sp)
    80201164:	03010113          	addi	sp,sp,48
    80201168:	00008067          	ret

000000008020116c <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    8020116c:	f9010113          	addi	sp,sp,-112
    80201170:	06113423          	sd	ra,104(sp)
    80201174:	06813023          	sd	s0,96(sp)
    80201178:	07010413          	addi	s0,sp,112
    8020117c:	faa43423          	sd	a0,-88(s0)
    80201180:	fab43023          	sd	a1,-96(s0)
    80201184:	00060793          	mv	a5,a2
    80201188:	f8d43823          	sd	a3,-112(s0)
    8020118c:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80201190:	f9f44783          	lbu	a5,-97(s0)
    80201194:	0ff7f793          	andi	a5,a5,255
    80201198:	02078663          	beqz	a5,802011c4 <print_dec_int+0x58>
    8020119c:	fa043703          	ld	a4,-96(s0)
    802011a0:	fff00793          	li	a5,-1
    802011a4:	03f79793          	slli	a5,a5,0x3f
    802011a8:	00f71e63          	bne	a4,a5,802011c4 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802011ac:	00001597          	auipc	a1,0x1
    802011b0:	f9458593          	addi	a1,a1,-108 # 80202140 <_srodata+0x140>
    802011b4:	fa843503          	ld	a0,-88(s0)
    802011b8:	f2dff0ef          	jal	ra,802010e4 <puts_wo_nl>
    802011bc:	00050793          	mv	a5,a0
    802011c0:	2980006f          	j	80201458 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
    802011c4:	f9043783          	ld	a5,-112(s0)
    802011c8:	00c7a783          	lw	a5,12(a5)
    802011cc:	00079a63          	bnez	a5,802011e0 <print_dec_int+0x74>
    802011d0:	fa043783          	ld	a5,-96(s0)
    802011d4:	00079663          	bnez	a5,802011e0 <print_dec_int+0x74>
        return 0;
    802011d8:	00000793          	li	a5,0
    802011dc:	27c0006f          	j	80201458 <print_dec_int+0x2ec>
    }

    bool neg = false;
    802011e0:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    802011e4:	f9f44783          	lbu	a5,-97(s0)
    802011e8:	0ff7f793          	andi	a5,a5,255
    802011ec:	02078063          	beqz	a5,8020120c <print_dec_int+0xa0>
    802011f0:	fa043783          	ld	a5,-96(s0)
    802011f4:	0007dc63          	bgez	a5,8020120c <print_dec_int+0xa0>
        neg = true;
    802011f8:	00100793          	li	a5,1
    802011fc:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80201200:	fa043783          	ld	a5,-96(s0)
    80201204:	40f007b3          	neg	a5,a5
    80201208:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    8020120c:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80201210:	f9f44783          	lbu	a5,-97(s0)
    80201214:	0ff7f793          	andi	a5,a5,255
    80201218:	02078863          	beqz	a5,80201248 <print_dec_int+0xdc>
    8020121c:	fef44783          	lbu	a5,-17(s0)
    80201220:	0ff7f793          	andi	a5,a5,255
    80201224:	00079e63          	bnez	a5,80201240 <print_dec_int+0xd4>
    80201228:	f9043783          	ld	a5,-112(s0)
    8020122c:	0057c783          	lbu	a5,5(a5)
    80201230:	00079863          	bnez	a5,80201240 <print_dec_int+0xd4>
    80201234:	f9043783          	ld	a5,-112(s0)
    80201238:	0047c783          	lbu	a5,4(a5)
    8020123c:	00078663          	beqz	a5,80201248 <print_dec_int+0xdc>
    80201240:	00100793          	li	a5,1
    80201244:	0080006f          	j	8020124c <print_dec_int+0xe0>
    80201248:	00000793          	li	a5,0
    8020124c:	fcf40ba3          	sb	a5,-41(s0)
    80201250:	fd744783          	lbu	a5,-41(s0)
    80201254:	0017f793          	andi	a5,a5,1
    80201258:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    8020125c:	fa043703          	ld	a4,-96(s0)
    80201260:	00a00793          	li	a5,10
    80201264:	02f777b3          	remu	a5,a4,a5
    80201268:	0ff7f713          	andi	a4,a5,255
    8020126c:	fe842783          	lw	a5,-24(s0)
    80201270:	0017869b          	addiw	a3,a5,1
    80201274:	fed42423          	sw	a3,-24(s0)
    80201278:	0307071b          	addiw	a4,a4,48
    8020127c:	0ff77713          	andi	a4,a4,255
    80201280:	ff040693          	addi	a3,s0,-16
    80201284:	00f687b3          	add	a5,a3,a5
    80201288:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    8020128c:	fa043703          	ld	a4,-96(s0)
    80201290:	00a00793          	li	a5,10
    80201294:	02f757b3          	divu	a5,a4,a5
    80201298:	faf43023          	sd	a5,-96(s0)
    } while (num);
    8020129c:	fa043783          	ld	a5,-96(s0)
    802012a0:	fa079ee3          	bnez	a5,8020125c <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    802012a4:	f9043783          	ld	a5,-112(s0)
    802012a8:	00c7a783          	lw	a5,12(a5)
    802012ac:	00078713          	mv	a4,a5
    802012b0:	fff00793          	li	a5,-1
    802012b4:	02f71063          	bne	a4,a5,802012d4 <print_dec_int+0x168>
    802012b8:	f9043783          	ld	a5,-112(s0)
    802012bc:	0037c783          	lbu	a5,3(a5)
    802012c0:	00078a63          	beqz	a5,802012d4 <print_dec_int+0x168>
        flags->prec = flags->width;
    802012c4:	f9043783          	ld	a5,-112(s0)
    802012c8:	0087a703          	lw	a4,8(a5)
    802012cc:	f9043783          	ld	a5,-112(s0)
    802012d0:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    802012d4:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    802012d8:	f9043783          	ld	a5,-112(s0)
    802012dc:	0087a703          	lw	a4,8(a5)
    802012e0:	fe842783          	lw	a5,-24(s0)
    802012e4:	fcf42823          	sw	a5,-48(s0)
    802012e8:	f9043783          	ld	a5,-112(s0)
    802012ec:	00c7a783          	lw	a5,12(a5)
    802012f0:	fcf42623          	sw	a5,-52(s0)
    802012f4:	fd042583          	lw	a1,-48(s0)
    802012f8:	fcc42783          	lw	a5,-52(s0)
    802012fc:	0007861b          	sext.w	a2,a5
    80201300:	0005869b          	sext.w	a3,a1
    80201304:	00d65463          	bge	a2,a3,8020130c <print_dec_int+0x1a0>
    80201308:	00058793          	mv	a5,a1
    8020130c:	0007879b          	sext.w	a5,a5
    80201310:	40f707bb          	subw	a5,a4,a5
    80201314:	0007871b          	sext.w	a4,a5
    80201318:	fd744783          	lbu	a5,-41(s0)
    8020131c:	0007879b          	sext.w	a5,a5
    80201320:	40f707bb          	subw	a5,a4,a5
    80201324:	fef42023          	sw	a5,-32(s0)
    80201328:	0280006f          	j	80201350 <print_dec_int+0x1e4>
        putch(' ');
    8020132c:	fa843783          	ld	a5,-88(s0)
    80201330:	02000513          	li	a0,32
    80201334:	000780e7          	jalr	a5
        ++written;
    80201338:	fe442783          	lw	a5,-28(s0)
    8020133c:	0017879b          	addiw	a5,a5,1
    80201340:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201344:	fe042783          	lw	a5,-32(s0)
    80201348:	fff7879b          	addiw	a5,a5,-1
    8020134c:	fef42023          	sw	a5,-32(s0)
    80201350:	fe042783          	lw	a5,-32(s0)
    80201354:	0007879b          	sext.w	a5,a5
    80201358:	fcf04ae3          	bgtz	a5,8020132c <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
    8020135c:	fd744783          	lbu	a5,-41(s0)
    80201360:	0ff7f793          	andi	a5,a5,255
    80201364:	04078463          	beqz	a5,802013ac <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80201368:	fef44783          	lbu	a5,-17(s0)
    8020136c:	0ff7f793          	andi	a5,a5,255
    80201370:	00078663          	beqz	a5,8020137c <print_dec_int+0x210>
    80201374:	02d00793          	li	a5,45
    80201378:	01c0006f          	j	80201394 <print_dec_int+0x228>
    8020137c:	f9043783          	ld	a5,-112(s0)
    80201380:	0057c783          	lbu	a5,5(a5)
    80201384:	00078663          	beqz	a5,80201390 <print_dec_int+0x224>
    80201388:	02b00793          	li	a5,43
    8020138c:	0080006f          	j	80201394 <print_dec_int+0x228>
    80201390:	02000793          	li	a5,32
    80201394:	fa843703          	ld	a4,-88(s0)
    80201398:	00078513          	mv	a0,a5
    8020139c:	000700e7          	jalr	a4
        ++written;
    802013a0:	fe442783          	lw	a5,-28(s0)
    802013a4:	0017879b          	addiw	a5,a5,1
    802013a8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802013ac:	fe842783          	lw	a5,-24(s0)
    802013b0:	fcf42e23          	sw	a5,-36(s0)
    802013b4:	0280006f          	j	802013dc <print_dec_int+0x270>
        putch('0');
    802013b8:	fa843783          	ld	a5,-88(s0)
    802013bc:	03000513          	li	a0,48
    802013c0:	000780e7          	jalr	a5
        ++written;
    802013c4:	fe442783          	lw	a5,-28(s0)
    802013c8:	0017879b          	addiw	a5,a5,1
    802013cc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802013d0:	fdc42783          	lw	a5,-36(s0)
    802013d4:	0017879b          	addiw	a5,a5,1
    802013d8:	fcf42e23          	sw	a5,-36(s0)
    802013dc:	f9043783          	ld	a5,-112(s0)
    802013e0:	00c7a703          	lw	a4,12(a5)
    802013e4:	fd744783          	lbu	a5,-41(s0)
    802013e8:	0007879b          	sext.w	a5,a5
    802013ec:	40f707bb          	subw	a5,a4,a5
    802013f0:	0007871b          	sext.w	a4,a5
    802013f4:	fdc42783          	lw	a5,-36(s0)
    802013f8:	0007879b          	sext.w	a5,a5
    802013fc:	fae7cee3          	blt	a5,a4,802013b8 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201400:	fe842783          	lw	a5,-24(s0)
    80201404:	fff7879b          	addiw	a5,a5,-1
    80201408:	fcf42c23          	sw	a5,-40(s0)
    8020140c:	03c0006f          	j	80201448 <print_dec_int+0x2dc>
        putch(buf[i]);
    80201410:	fd842783          	lw	a5,-40(s0)
    80201414:	ff040713          	addi	a4,s0,-16
    80201418:	00f707b3          	add	a5,a4,a5
    8020141c:	fc87c783          	lbu	a5,-56(a5)
    80201420:	0007879b          	sext.w	a5,a5
    80201424:	fa843703          	ld	a4,-88(s0)
    80201428:	00078513          	mv	a0,a5
    8020142c:	000700e7          	jalr	a4
        ++written;
    80201430:	fe442783          	lw	a5,-28(s0)
    80201434:	0017879b          	addiw	a5,a5,1
    80201438:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    8020143c:	fd842783          	lw	a5,-40(s0)
    80201440:	fff7879b          	addiw	a5,a5,-1
    80201444:	fcf42c23          	sw	a5,-40(s0)
    80201448:	fd842783          	lw	a5,-40(s0)
    8020144c:	0007879b          	sext.w	a5,a5
    80201450:	fc07d0e3          	bgez	a5,80201410 <print_dec_int+0x2a4>
    }

    return written;
    80201454:	fe442783          	lw	a5,-28(s0)
}
    80201458:	00078513          	mv	a0,a5
    8020145c:	06813083          	ld	ra,104(sp)
    80201460:	06013403          	ld	s0,96(sp)
    80201464:	07010113          	addi	sp,sp,112
    80201468:	00008067          	ret

000000008020146c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    8020146c:	f4010113          	addi	sp,sp,-192
    80201470:	0a113c23          	sd	ra,184(sp)
    80201474:	0a813823          	sd	s0,176(sp)
    80201478:	0c010413          	addi	s0,sp,192
    8020147c:	f4a43c23          	sd	a0,-168(s0)
    80201480:	f4b43823          	sd	a1,-176(s0)
    80201484:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80201488:	f8043023          	sd	zero,-128(s0)
    8020148c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80201490:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80201494:	7a40006f          	j	80201c38 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80201498:	f8044783          	lbu	a5,-128(s0)
    8020149c:	72078e63          	beqz	a5,80201bd8 <vprintfmt+0x76c>
            if (*fmt == '#') {
    802014a0:	f5043783          	ld	a5,-176(s0)
    802014a4:	0007c783          	lbu	a5,0(a5)
    802014a8:	00078713          	mv	a4,a5
    802014ac:	02300793          	li	a5,35
    802014b0:	00f71863          	bne	a4,a5,802014c0 <vprintfmt+0x54>
                flags.sharpflag = true;
    802014b4:	00100793          	li	a5,1
    802014b8:	f8f40123          	sb	a5,-126(s0)
    802014bc:	7700006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    802014c0:	f5043783          	ld	a5,-176(s0)
    802014c4:	0007c783          	lbu	a5,0(a5)
    802014c8:	00078713          	mv	a4,a5
    802014cc:	03000793          	li	a5,48
    802014d0:	00f71863          	bne	a4,a5,802014e0 <vprintfmt+0x74>
                flags.zeroflag = true;
    802014d4:	00100793          	li	a5,1
    802014d8:	f8f401a3          	sb	a5,-125(s0)
    802014dc:	7500006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    802014e0:	f5043783          	ld	a5,-176(s0)
    802014e4:	0007c783          	lbu	a5,0(a5)
    802014e8:	00078713          	mv	a4,a5
    802014ec:	06c00793          	li	a5,108
    802014f0:	04f70063          	beq	a4,a5,80201530 <vprintfmt+0xc4>
    802014f4:	f5043783          	ld	a5,-176(s0)
    802014f8:	0007c783          	lbu	a5,0(a5)
    802014fc:	00078713          	mv	a4,a5
    80201500:	07a00793          	li	a5,122
    80201504:	02f70663          	beq	a4,a5,80201530 <vprintfmt+0xc4>
    80201508:	f5043783          	ld	a5,-176(s0)
    8020150c:	0007c783          	lbu	a5,0(a5)
    80201510:	00078713          	mv	a4,a5
    80201514:	07400793          	li	a5,116
    80201518:	00f70c63          	beq	a4,a5,80201530 <vprintfmt+0xc4>
    8020151c:	f5043783          	ld	a5,-176(s0)
    80201520:	0007c783          	lbu	a5,0(a5)
    80201524:	00078713          	mv	a4,a5
    80201528:	06a00793          	li	a5,106
    8020152c:	00f71863          	bne	a4,a5,8020153c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201530:	00100793          	li	a5,1
    80201534:	f8f400a3          	sb	a5,-127(s0)
    80201538:	6f40006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    8020153c:	f5043783          	ld	a5,-176(s0)
    80201540:	0007c783          	lbu	a5,0(a5)
    80201544:	00078713          	mv	a4,a5
    80201548:	02b00793          	li	a5,43
    8020154c:	00f71863          	bne	a4,a5,8020155c <vprintfmt+0xf0>
                flags.sign = true;
    80201550:	00100793          	li	a5,1
    80201554:	f8f402a3          	sb	a5,-123(s0)
    80201558:	6d40006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    8020155c:	f5043783          	ld	a5,-176(s0)
    80201560:	0007c783          	lbu	a5,0(a5)
    80201564:	00078713          	mv	a4,a5
    80201568:	02000793          	li	a5,32
    8020156c:	00f71863          	bne	a4,a5,8020157c <vprintfmt+0x110>
                flags.spaceflag = true;
    80201570:	00100793          	li	a5,1
    80201574:	f8f40223          	sb	a5,-124(s0)
    80201578:	6b40006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    8020157c:	f5043783          	ld	a5,-176(s0)
    80201580:	0007c783          	lbu	a5,0(a5)
    80201584:	00078713          	mv	a4,a5
    80201588:	02a00793          	li	a5,42
    8020158c:	00f71e63          	bne	a4,a5,802015a8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80201590:	f4843783          	ld	a5,-184(s0)
    80201594:	00878713          	addi	a4,a5,8
    80201598:	f4e43423          	sd	a4,-184(s0)
    8020159c:	0007a783          	lw	a5,0(a5)
    802015a0:	f8f42423          	sw	a5,-120(s0)
    802015a4:	6880006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    802015a8:	f5043783          	ld	a5,-176(s0)
    802015ac:	0007c783          	lbu	a5,0(a5)
    802015b0:	00078713          	mv	a4,a5
    802015b4:	03000793          	li	a5,48
    802015b8:	04e7f663          	bgeu	a5,a4,80201604 <vprintfmt+0x198>
    802015bc:	f5043783          	ld	a5,-176(s0)
    802015c0:	0007c783          	lbu	a5,0(a5)
    802015c4:	00078713          	mv	a4,a5
    802015c8:	03900793          	li	a5,57
    802015cc:	02e7ec63          	bltu	a5,a4,80201604 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    802015d0:	f5043783          	ld	a5,-176(s0)
    802015d4:	f5040713          	addi	a4,s0,-176
    802015d8:	00a00613          	li	a2,10
    802015dc:	00070593          	mv	a1,a4
    802015e0:	00078513          	mv	a0,a5
    802015e4:	899ff0ef          	jal	ra,80200e7c <strtol>
    802015e8:	00050793          	mv	a5,a0
    802015ec:	0007879b          	sext.w	a5,a5
    802015f0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    802015f4:	f5043783          	ld	a5,-176(s0)
    802015f8:	fff78793          	addi	a5,a5,-1
    802015fc:	f4f43823          	sd	a5,-176(s0)
    80201600:	62c0006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201604:	f5043783          	ld	a5,-176(s0)
    80201608:	0007c783          	lbu	a5,0(a5)
    8020160c:	00078713          	mv	a4,a5
    80201610:	02e00793          	li	a5,46
    80201614:	06f71863          	bne	a4,a5,80201684 <vprintfmt+0x218>
                fmt++;
    80201618:	f5043783          	ld	a5,-176(s0)
    8020161c:	00178793          	addi	a5,a5,1
    80201620:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201624:	f5043783          	ld	a5,-176(s0)
    80201628:	0007c783          	lbu	a5,0(a5)
    8020162c:	00078713          	mv	a4,a5
    80201630:	02a00793          	li	a5,42
    80201634:	00f71e63          	bne	a4,a5,80201650 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80201638:	f4843783          	ld	a5,-184(s0)
    8020163c:	00878713          	addi	a4,a5,8
    80201640:	f4e43423          	sd	a4,-184(s0)
    80201644:	0007a783          	lw	a5,0(a5)
    80201648:	f8f42623          	sw	a5,-116(s0)
    8020164c:	5e00006f          	j	80201c2c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80201650:	f5043783          	ld	a5,-176(s0)
    80201654:	f5040713          	addi	a4,s0,-176
    80201658:	00a00613          	li	a2,10
    8020165c:	00070593          	mv	a1,a4
    80201660:	00078513          	mv	a0,a5
    80201664:	819ff0ef          	jal	ra,80200e7c <strtol>
    80201668:	00050793          	mv	a5,a0
    8020166c:	0007879b          	sext.w	a5,a5
    80201670:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80201674:	f5043783          	ld	a5,-176(s0)
    80201678:	fff78793          	addi	a5,a5,-1
    8020167c:	f4f43823          	sd	a5,-176(s0)
    80201680:	5ac0006f          	j	80201c2c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201684:	f5043783          	ld	a5,-176(s0)
    80201688:	0007c783          	lbu	a5,0(a5)
    8020168c:	00078713          	mv	a4,a5
    80201690:	07800793          	li	a5,120
    80201694:	02f70663          	beq	a4,a5,802016c0 <vprintfmt+0x254>
    80201698:	f5043783          	ld	a5,-176(s0)
    8020169c:	0007c783          	lbu	a5,0(a5)
    802016a0:	00078713          	mv	a4,a5
    802016a4:	05800793          	li	a5,88
    802016a8:	00f70c63          	beq	a4,a5,802016c0 <vprintfmt+0x254>
    802016ac:	f5043783          	ld	a5,-176(s0)
    802016b0:	0007c783          	lbu	a5,0(a5)
    802016b4:	00078713          	mv	a4,a5
    802016b8:	07000793          	li	a5,112
    802016bc:	2ef71e63          	bne	a4,a5,802019b8 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
    802016c0:	f5043783          	ld	a5,-176(s0)
    802016c4:	0007c783          	lbu	a5,0(a5)
    802016c8:	00078713          	mv	a4,a5
    802016cc:	07000793          	li	a5,112
    802016d0:	00f70663          	beq	a4,a5,802016dc <vprintfmt+0x270>
    802016d4:	f8144783          	lbu	a5,-127(s0)
    802016d8:	00078663          	beqz	a5,802016e4 <vprintfmt+0x278>
    802016dc:	00100793          	li	a5,1
    802016e0:	0080006f          	j	802016e8 <vprintfmt+0x27c>
    802016e4:	00000793          	li	a5,0
    802016e8:	faf403a3          	sb	a5,-89(s0)
    802016ec:	fa744783          	lbu	a5,-89(s0)
    802016f0:	0017f793          	andi	a5,a5,1
    802016f4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    802016f8:	fa744783          	lbu	a5,-89(s0)
    802016fc:	0ff7f793          	andi	a5,a5,255
    80201700:	00078c63          	beqz	a5,80201718 <vprintfmt+0x2ac>
    80201704:	f4843783          	ld	a5,-184(s0)
    80201708:	00878713          	addi	a4,a5,8
    8020170c:	f4e43423          	sd	a4,-184(s0)
    80201710:	0007b783          	ld	a5,0(a5)
    80201714:	01c0006f          	j	80201730 <vprintfmt+0x2c4>
    80201718:	f4843783          	ld	a5,-184(s0)
    8020171c:	00878713          	addi	a4,a5,8
    80201720:	f4e43423          	sd	a4,-184(s0)
    80201724:	0007a783          	lw	a5,0(a5)
    80201728:	02079793          	slli	a5,a5,0x20
    8020172c:	0207d793          	srli	a5,a5,0x20
    80201730:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201734:	f8c42783          	lw	a5,-116(s0)
    80201738:	02079463          	bnez	a5,80201760 <vprintfmt+0x2f4>
    8020173c:	fe043783          	ld	a5,-32(s0)
    80201740:	02079063          	bnez	a5,80201760 <vprintfmt+0x2f4>
    80201744:	f5043783          	ld	a5,-176(s0)
    80201748:	0007c783          	lbu	a5,0(a5)
    8020174c:	00078713          	mv	a4,a5
    80201750:	07000793          	li	a5,112
    80201754:	00f70663          	beq	a4,a5,80201760 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80201758:	f8040023          	sb	zero,-128(s0)
    8020175c:	4d00006f          	j	80201c2c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80201760:	f5043783          	ld	a5,-176(s0)
    80201764:	0007c783          	lbu	a5,0(a5)
    80201768:	00078713          	mv	a4,a5
    8020176c:	07000793          	li	a5,112
    80201770:	00f70a63          	beq	a4,a5,80201784 <vprintfmt+0x318>
    80201774:	f8244783          	lbu	a5,-126(s0)
    80201778:	00078a63          	beqz	a5,8020178c <vprintfmt+0x320>
    8020177c:	fe043783          	ld	a5,-32(s0)
    80201780:	00078663          	beqz	a5,8020178c <vprintfmt+0x320>
    80201784:	00100793          	li	a5,1
    80201788:	0080006f          	j	80201790 <vprintfmt+0x324>
    8020178c:	00000793          	li	a5,0
    80201790:	faf40323          	sb	a5,-90(s0)
    80201794:	fa644783          	lbu	a5,-90(s0)
    80201798:	0017f793          	andi	a5,a5,1
    8020179c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    802017a0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    802017a4:	f5043783          	ld	a5,-176(s0)
    802017a8:	0007c783          	lbu	a5,0(a5)
    802017ac:	00078713          	mv	a4,a5
    802017b0:	05800793          	li	a5,88
    802017b4:	00f71863          	bne	a4,a5,802017c4 <vprintfmt+0x358>
    802017b8:	00001797          	auipc	a5,0x1
    802017bc:	9a078793          	addi	a5,a5,-1632 # 80202158 <upperxdigits.1101>
    802017c0:	00c0006f          	j	802017cc <vprintfmt+0x360>
    802017c4:	00001797          	auipc	a5,0x1
    802017c8:	9ac78793          	addi	a5,a5,-1620 # 80202170 <lowerxdigits.1100>
    802017cc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    802017d0:	fe043783          	ld	a5,-32(s0)
    802017d4:	00f7f793          	andi	a5,a5,15
    802017d8:	f9843703          	ld	a4,-104(s0)
    802017dc:	00f70733          	add	a4,a4,a5
    802017e0:	fdc42783          	lw	a5,-36(s0)
    802017e4:	0017869b          	addiw	a3,a5,1
    802017e8:	fcd42e23          	sw	a3,-36(s0)
    802017ec:	00074703          	lbu	a4,0(a4)
    802017f0:	ff040693          	addi	a3,s0,-16
    802017f4:	00f687b3          	add	a5,a3,a5
    802017f8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    802017fc:	fe043783          	ld	a5,-32(s0)
    80201800:	0047d793          	srli	a5,a5,0x4
    80201804:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201808:	fe043783          	ld	a5,-32(s0)
    8020180c:	fc0792e3          	bnez	a5,802017d0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201810:	f8c42783          	lw	a5,-116(s0)
    80201814:	00078713          	mv	a4,a5
    80201818:	fff00793          	li	a5,-1
    8020181c:	02f71663          	bne	a4,a5,80201848 <vprintfmt+0x3dc>
    80201820:	f8344783          	lbu	a5,-125(s0)
    80201824:	02078263          	beqz	a5,80201848 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201828:	f8842703          	lw	a4,-120(s0)
    8020182c:	fa644783          	lbu	a5,-90(s0)
    80201830:	0007879b          	sext.w	a5,a5
    80201834:	0017979b          	slliw	a5,a5,0x1
    80201838:	0007879b          	sext.w	a5,a5
    8020183c:	40f707bb          	subw	a5,a4,a5
    80201840:	0007879b          	sext.w	a5,a5
    80201844:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201848:	f8842703          	lw	a4,-120(s0)
    8020184c:	fa644783          	lbu	a5,-90(s0)
    80201850:	0007879b          	sext.w	a5,a5
    80201854:	0017979b          	slliw	a5,a5,0x1
    80201858:	0007879b          	sext.w	a5,a5
    8020185c:	40f707bb          	subw	a5,a4,a5
    80201860:	0007871b          	sext.w	a4,a5
    80201864:	fdc42783          	lw	a5,-36(s0)
    80201868:	f8f42a23          	sw	a5,-108(s0)
    8020186c:	f8c42783          	lw	a5,-116(s0)
    80201870:	f8f42823          	sw	a5,-112(s0)
    80201874:	f9442583          	lw	a1,-108(s0)
    80201878:	f9042783          	lw	a5,-112(s0)
    8020187c:	0007861b          	sext.w	a2,a5
    80201880:	0005869b          	sext.w	a3,a1
    80201884:	00d65463          	bge	a2,a3,8020188c <vprintfmt+0x420>
    80201888:	00058793          	mv	a5,a1
    8020188c:	0007879b          	sext.w	a5,a5
    80201890:	40f707bb          	subw	a5,a4,a5
    80201894:	fcf42c23          	sw	a5,-40(s0)
    80201898:	0280006f          	j	802018c0 <vprintfmt+0x454>
                    putch(' ');
    8020189c:	f5843783          	ld	a5,-168(s0)
    802018a0:	02000513          	li	a0,32
    802018a4:	000780e7          	jalr	a5
                    ++written;
    802018a8:	fec42783          	lw	a5,-20(s0)
    802018ac:	0017879b          	addiw	a5,a5,1
    802018b0:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802018b4:	fd842783          	lw	a5,-40(s0)
    802018b8:	fff7879b          	addiw	a5,a5,-1
    802018bc:	fcf42c23          	sw	a5,-40(s0)
    802018c0:	fd842783          	lw	a5,-40(s0)
    802018c4:	0007879b          	sext.w	a5,a5
    802018c8:	fcf04ae3          	bgtz	a5,8020189c <vprintfmt+0x430>
                }

                if (prefix) {
    802018cc:	fa644783          	lbu	a5,-90(s0)
    802018d0:	0ff7f793          	andi	a5,a5,255
    802018d4:	04078463          	beqz	a5,8020191c <vprintfmt+0x4b0>
                    putch('0');
    802018d8:	f5843783          	ld	a5,-168(s0)
    802018dc:	03000513          	li	a0,48
    802018e0:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    802018e4:	f5043783          	ld	a5,-176(s0)
    802018e8:	0007c783          	lbu	a5,0(a5)
    802018ec:	00078713          	mv	a4,a5
    802018f0:	05800793          	li	a5,88
    802018f4:	00f71663          	bne	a4,a5,80201900 <vprintfmt+0x494>
    802018f8:	05800793          	li	a5,88
    802018fc:	0080006f          	j	80201904 <vprintfmt+0x498>
    80201900:	07800793          	li	a5,120
    80201904:	f5843703          	ld	a4,-168(s0)
    80201908:	00078513          	mv	a0,a5
    8020190c:	000700e7          	jalr	a4
                    written += 2;
    80201910:	fec42783          	lw	a5,-20(s0)
    80201914:	0027879b          	addiw	a5,a5,2
    80201918:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    8020191c:	fdc42783          	lw	a5,-36(s0)
    80201920:	fcf42a23          	sw	a5,-44(s0)
    80201924:	0280006f          	j	8020194c <vprintfmt+0x4e0>
                    putch('0');
    80201928:	f5843783          	ld	a5,-168(s0)
    8020192c:	03000513          	li	a0,48
    80201930:	000780e7          	jalr	a5
                    ++written;
    80201934:	fec42783          	lw	a5,-20(s0)
    80201938:	0017879b          	addiw	a5,a5,1
    8020193c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201940:	fd442783          	lw	a5,-44(s0)
    80201944:	0017879b          	addiw	a5,a5,1
    80201948:	fcf42a23          	sw	a5,-44(s0)
    8020194c:	f8c42703          	lw	a4,-116(s0)
    80201950:	fd442783          	lw	a5,-44(s0)
    80201954:	0007879b          	sext.w	a5,a5
    80201958:	fce7c8e3          	blt	a5,a4,80201928 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    8020195c:	fdc42783          	lw	a5,-36(s0)
    80201960:	fff7879b          	addiw	a5,a5,-1
    80201964:	fcf42823          	sw	a5,-48(s0)
    80201968:	03c0006f          	j	802019a4 <vprintfmt+0x538>
                    putch(buf[i]);
    8020196c:	fd042783          	lw	a5,-48(s0)
    80201970:	ff040713          	addi	a4,s0,-16
    80201974:	00f707b3          	add	a5,a4,a5
    80201978:	f807c783          	lbu	a5,-128(a5)
    8020197c:	0007879b          	sext.w	a5,a5
    80201980:	f5843703          	ld	a4,-168(s0)
    80201984:	00078513          	mv	a0,a5
    80201988:	000700e7          	jalr	a4
                    ++written;
    8020198c:	fec42783          	lw	a5,-20(s0)
    80201990:	0017879b          	addiw	a5,a5,1
    80201994:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201998:	fd042783          	lw	a5,-48(s0)
    8020199c:	fff7879b          	addiw	a5,a5,-1
    802019a0:	fcf42823          	sw	a5,-48(s0)
    802019a4:	fd042783          	lw	a5,-48(s0)
    802019a8:	0007879b          	sext.w	a5,a5
    802019ac:	fc07d0e3          	bgez	a5,8020196c <vprintfmt+0x500>
                }

                flags.in_format = false;
    802019b0:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802019b4:	2780006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802019b8:	f5043783          	ld	a5,-176(s0)
    802019bc:	0007c783          	lbu	a5,0(a5)
    802019c0:	00078713          	mv	a4,a5
    802019c4:	06400793          	li	a5,100
    802019c8:	02f70663          	beq	a4,a5,802019f4 <vprintfmt+0x588>
    802019cc:	f5043783          	ld	a5,-176(s0)
    802019d0:	0007c783          	lbu	a5,0(a5)
    802019d4:	00078713          	mv	a4,a5
    802019d8:	06900793          	li	a5,105
    802019dc:	00f70c63          	beq	a4,a5,802019f4 <vprintfmt+0x588>
    802019e0:	f5043783          	ld	a5,-176(s0)
    802019e4:	0007c783          	lbu	a5,0(a5)
    802019e8:	00078713          	mv	a4,a5
    802019ec:	07500793          	li	a5,117
    802019f0:	08f71263          	bne	a4,a5,80201a74 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802019f4:	f8144783          	lbu	a5,-127(s0)
    802019f8:	00078c63          	beqz	a5,80201a10 <vprintfmt+0x5a4>
    802019fc:	f4843783          	ld	a5,-184(s0)
    80201a00:	00878713          	addi	a4,a5,8
    80201a04:	f4e43423          	sd	a4,-184(s0)
    80201a08:	0007b783          	ld	a5,0(a5)
    80201a0c:	0140006f          	j	80201a20 <vprintfmt+0x5b4>
    80201a10:	f4843783          	ld	a5,-184(s0)
    80201a14:	00878713          	addi	a4,a5,8
    80201a18:	f4e43423          	sd	a4,-184(s0)
    80201a1c:	0007a783          	lw	a5,0(a5)
    80201a20:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201a24:	fa843583          	ld	a1,-88(s0)
    80201a28:	f5043783          	ld	a5,-176(s0)
    80201a2c:	0007c783          	lbu	a5,0(a5)
    80201a30:	0007871b          	sext.w	a4,a5
    80201a34:	07500793          	li	a5,117
    80201a38:	40f707b3          	sub	a5,a4,a5
    80201a3c:	00f037b3          	snez	a5,a5
    80201a40:	0ff7f793          	andi	a5,a5,255
    80201a44:	f8040713          	addi	a4,s0,-128
    80201a48:	00070693          	mv	a3,a4
    80201a4c:	00078613          	mv	a2,a5
    80201a50:	f5843503          	ld	a0,-168(s0)
    80201a54:	f18ff0ef          	jal	ra,8020116c <print_dec_int>
    80201a58:	00050793          	mv	a5,a0
    80201a5c:	00078713          	mv	a4,a5
    80201a60:	fec42783          	lw	a5,-20(s0)
    80201a64:	00e787bb          	addw	a5,a5,a4
    80201a68:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201a6c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201a70:	1bc0006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201a74:	f5043783          	ld	a5,-176(s0)
    80201a78:	0007c783          	lbu	a5,0(a5)
    80201a7c:	00078713          	mv	a4,a5
    80201a80:	06e00793          	li	a5,110
    80201a84:	04f71c63          	bne	a4,a5,80201adc <vprintfmt+0x670>
                if (flags.longflag) {
    80201a88:	f8144783          	lbu	a5,-127(s0)
    80201a8c:	02078463          	beqz	a5,80201ab4 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
    80201a90:	f4843783          	ld	a5,-184(s0)
    80201a94:	00878713          	addi	a4,a5,8
    80201a98:	f4e43423          	sd	a4,-184(s0)
    80201a9c:	0007b783          	ld	a5,0(a5)
    80201aa0:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201aa4:	fec42703          	lw	a4,-20(s0)
    80201aa8:	fb043783          	ld	a5,-80(s0)
    80201aac:	00e7b023          	sd	a4,0(a5)
    80201ab0:	0240006f          	j	80201ad4 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
    80201ab4:	f4843783          	ld	a5,-184(s0)
    80201ab8:	00878713          	addi	a4,a5,8
    80201abc:	f4e43423          	sd	a4,-184(s0)
    80201ac0:	0007b783          	ld	a5,0(a5)
    80201ac4:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201ac8:	fb843783          	ld	a5,-72(s0)
    80201acc:	fec42703          	lw	a4,-20(s0)
    80201ad0:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201ad4:	f8040023          	sb	zero,-128(s0)
    80201ad8:	1540006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201adc:	f5043783          	ld	a5,-176(s0)
    80201ae0:	0007c783          	lbu	a5,0(a5)
    80201ae4:	00078713          	mv	a4,a5
    80201ae8:	07300793          	li	a5,115
    80201aec:	04f71063          	bne	a4,a5,80201b2c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201af0:	f4843783          	ld	a5,-184(s0)
    80201af4:	00878713          	addi	a4,a5,8
    80201af8:	f4e43423          	sd	a4,-184(s0)
    80201afc:	0007b783          	ld	a5,0(a5)
    80201b00:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201b04:	fc043583          	ld	a1,-64(s0)
    80201b08:	f5843503          	ld	a0,-168(s0)
    80201b0c:	dd8ff0ef          	jal	ra,802010e4 <puts_wo_nl>
    80201b10:	00050793          	mv	a5,a0
    80201b14:	00078713          	mv	a4,a5
    80201b18:	fec42783          	lw	a5,-20(s0)
    80201b1c:	00e787bb          	addw	a5,a5,a4
    80201b20:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201b24:	f8040023          	sb	zero,-128(s0)
    80201b28:	1040006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201b2c:	f5043783          	ld	a5,-176(s0)
    80201b30:	0007c783          	lbu	a5,0(a5)
    80201b34:	00078713          	mv	a4,a5
    80201b38:	06300793          	li	a5,99
    80201b3c:	02f71e63          	bne	a4,a5,80201b78 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201b40:	f4843783          	ld	a5,-184(s0)
    80201b44:	00878713          	addi	a4,a5,8
    80201b48:	f4e43423          	sd	a4,-184(s0)
    80201b4c:	0007a783          	lw	a5,0(a5)
    80201b50:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201b54:	fcc42783          	lw	a5,-52(s0)
    80201b58:	f5843703          	ld	a4,-168(s0)
    80201b5c:	00078513          	mv	a0,a5
    80201b60:	000700e7          	jalr	a4
                ++written;
    80201b64:	fec42783          	lw	a5,-20(s0)
    80201b68:	0017879b          	addiw	a5,a5,1
    80201b6c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201b70:	f8040023          	sb	zero,-128(s0)
    80201b74:	0b80006f          	j	80201c2c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201b78:	f5043783          	ld	a5,-176(s0)
    80201b7c:	0007c783          	lbu	a5,0(a5)
    80201b80:	00078713          	mv	a4,a5
    80201b84:	02500793          	li	a5,37
    80201b88:	02f71263          	bne	a4,a5,80201bac <vprintfmt+0x740>
                putch('%');
    80201b8c:	f5843783          	ld	a5,-168(s0)
    80201b90:	02500513          	li	a0,37
    80201b94:	000780e7          	jalr	a5
                ++written;
    80201b98:	fec42783          	lw	a5,-20(s0)
    80201b9c:	0017879b          	addiw	a5,a5,1
    80201ba0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201ba4:	f8040023          	sb	zero,-128(s0)
    80201ba8:	0840006f          	j	80201c2c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201bac:	f5043783          	ld	a5,-176(s0)
    80201bb0:	0007c783          	lbu	a5,0(a5)
    80201bb4:	0007879b          	sext.w	a5,a5
    80201bb8:	f5843703          	ld	a4,-168(s0)
    80201bbc:	00078513          	mv	a0,a5
    80201bc0:	000700e7          	jalr	a4
                ++written;
    80201bc4:	fec42783          	lw	a5,-20(s0)
    80201bc8:	0017879b          	addiw	a5,a5,1
    80201bcc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201bd0:	f8040023          	sb	zero,-128(s0)
    80201bd4:	0580006f          	j	80201c2c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201bd8:	f5043783          	ld	a5,-176(s0)
    80201bdc:	0007c783          	lbu	a5,0(a5)
    80201be0:	00078713          	mv	a4,a5
    80201be4:	02500793          	li	a5,37
    80201be8:	02f71063          	bne	a4,a5,80201c08 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201bec:	f8043023          	sd	zero,-128(s0)
    80201bf0:	f8043423          	sd	zero,-120(s0)
    80201bf4:	00100793          	li	a5,1
    80201bf8:	f8f40023          	sb	a5,-128(s0)
    80201bfc:	fff00793          	li	a5,-1
    80201c00:	f8f42623          	sw	a5,-116(s0)
    80201c04:	0280006f          	j	80201c2c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201c08:	f5043783          	ld	a5,-176(s0)
    80201c0c:	0007c783          	lbu	a5,0(a5)
    80201c10:	0007879b          	sext.w	a5,a5
    80201c14:	f5843703          	ld	a4,-168(s0)
    80201c18:	00078513          	mv	a0,a5
    80201c1c:	000700e7          	jalr	a4
            ++written;
    80201c20:	fec42783          	lw	a5,-20(s0)
    80201c24:	0017879b          	addiw	a5,a5,1
    80201c28:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201c2c:	f5043783          	ld	a5,-176(s0)
    80201c30:	00178793          	addi	a5,a5,1
    80201c34:	f4f43823          	sd	a5,-176(s0)
    80201c38:	f5043783          	ld	a5,-176(s0)
    80201c3c:	0007c783          	lbu	a5,0(a5)
    80201c40:	84079ce3          	bnez	a5,80201498 <vprintfmt+0x2c>
        }
    }

    return written;
    80201c44:	fec42783          	lw	a5,-20(s0)
}
    80201c48:	00078513          	mv	a0,a5
    80201c4c:	0b813083          	ld	ra,184(sp)
    80201c50:	0b013403          	ld	s0,176(sp)
    80201c54:	0c010113          	addi	sp,sp,192
    80201c58:	00008067          	ret

0000000080201c5c <printk>:

int printk(const char* s, ...) {
    80201c5c:	f9010113          	addi	sp,sp,-112
    80201c60:	02113423          	sd	ra,40(sp)
    80201c64:	02813023          	sd	s0,32(sp)
    80201c68:	03010413          	addi	s0,sp,48
    80201c6c:	fca43c23          	sd	a0,-40(s0)
    80201c70:	00b43423          	sd	a1,8(s0)
    80201c74:	00c43823          	sd	a2,16(s0)
    80201c78:	00d43c23          	sd	a3,24(s0)
    80201c7c:	02e43023          	sd	a4,32(s0)
    80201c80:	02f43423          	sd	a5,40(s0)
    80201c84:	03043823          	sd	a6,48(s0)
    80201c88:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201c8c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201c90:	04040793          	addi	a5,s0,64
    80201c94:	fcf43823          	sd	a5,-48(s0)
    80201c98:	fd043783          	ld	a5,-48(s0)
    80201c9c:	fc878793          	addi	a5,a5,-56
    80201ca0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201ca4:	fe043783          	ld	a5,-32(s0)
    80201ca8:	00078613          	mv	a2,a5
    80201cac:	fd843583          	ld	a1,-40(s0)
    80201cb0:	fffff517          	auipc	a0,0xfffff
    80201cb4:	12450513          	addi	a0,a0,292 # 80200dd4 <putc>
    80201cb8:	fb4ff0ef          	jal	ra,8020146c <vprintfmt>
    80201cbc:	00050793          	mv	a5,a0
    80201cc0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201cc4:	fec42783          	lw	a5,-20(s0)
}
    80201cc8:	00078513          	mv	a0,a5
    80201ccc:	02813083          	ld	ra,40(sp)
    80201cd0:	02013403          	ld	s0,32(sp)
    80201cd4:	07010113          	addi	sp,sp,112
    80201cd8:	00008067          	ret

0000000080201cdc <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201cdc:	fe010113          	addi	sp,sp,-32
    80201ce0:	00813c23          	sd	s0,24(sp)
    80201ce4:	02010413          	addi	s0,sp,32
    80201ce8:	00050793          	mv	a5,a0
    80201cec:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201cf0:	fec42783          	lw	a5,-20(s0)
    80201cf4:	fff7879b          	addiw	a5,a5,-1
    80201cf8:	0007879b          	sext.w	a5,a5
    80201cfc:	02079713          	slli	a4,a5,0x20
    80201d00:	02075713          	srli	a4,a4,0x20
    80201d04:	00003797          	auipc	a5,0x3
    80201d08:	2fc78793          	addi	a5,a5,764 # 80205000 <seed>
    80201d0c:	00e7b023          	sd	a4,0(a5)
}
    80201d10:	00000013          	nop
    80201d14:	01813403          	ld	s0,24(sp)
    80201d18:	02010113          	addi	sp,sp,32
    80201d1c:	00008067          	ret

0000000080201d20 <rand>:

int rand(void) {
    80201d20:	ff010113          	addi	sp,sp,-16
    80201d24:	00813423          	sd	s0,8(sp)
    80201d28:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201d2c:	00003797          	auipc	a5,0x3
    80201d30:	2d478793          	addi	a5,a5,724 # 80205000 <seed>
    80201d34:	0007b703          	ld	a4,0(a5)
    80201d38:	00000797          	auipc	a5,0x0
    80201d3c:	45078793          	addi	a5,a5,1104 # 80202188 <lowerxdigits.1100+0x18>
    80201d40:	0007b783          	ld	a5,0(a5)
    80201d44:	02f707b3          	mul	a5,a4,a5
    80201d48:	00178713          	addi	a4,a5,1
    80201d4c:	00003797          	auipc	a5,0x3
    80201d50:	2b478793          	addi	a5,a5,692 # 80205000 <seed>
    80201d54:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201d58:	00003797          	auipc	a5,0x3
    80201d5c:	2a878793          	addi	a5,a5,680 # 80205000 <seed>
    80201d60:	0007b783          	ld	a5,0(a5)
    80201d64:	0217d793          	srli	a5,a5,0x21
    80201d68:	0007879b          	sext.w	a5,a5
}
    80201d6c:	00078513          	mv	a0,a5
    80201d70:	00813403          	ld	s0,8(sp)
    80201d74:	01010113          	addi	sp,sp,16
    80201d78:	00008067          	ret

0000000080201d7c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201d7c:	fc010113          	addi	sp,sp,-64
    80201d80:	02813c23          	sd	s0,56(sp)
    80201d84:	04010413          	addi	s0,sp,64
    80201d88:	fca43c23          	sd	a0,-40(s0)
    80201d8c:	00058793          	mv	a5,a1
    80201d90:	fcc43423          	sd	a2,-56(s0)
    80201d94:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201d98:	fd843783          	ld	a5,-40(s0)
    80201d9c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201da0:	fe043423          	sd	zero,-24(s0)
    80201da4:	0280006f          	j	80201dcc <memset+0x50>
        s[i] = c;
    80201da8:	fe043703          	ld	a4,-32(s0)
    80201dac:	fe843783          	ld	a5,-24(s0)
    80201db0:	00f707b3          	add	a5,a4,a5
    80201db4:	fd442703          	lw	a4,-44(s0)
    80201db8:	0ff77713          	andi	a4,a4,255
    80201dbc:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201dc0:	fe843783          	ld	a5,-24(s0)
    80201dc4:	00178793          	addi	a5,a5,1
    80201dc8:	fef43423          	sd	a5,-24(s0)
    80201dcc:	fe843703          	ld	a4,-24(s0)
    80201dd0:	fc843783          	ld	a5,-56(s0)
    80201dd4:	fcf76ae3          	bltu	a4,a5,80201da8 <memset+0x2c>
    }
    return dest;
    80201dd8:	fd843783          	ld	a5,-40(s0)
}
    80201ddc:	00078513          	mv	a0,a5
    80201de0:	03813403          	ld	s0,56(sp)
    80201de4:	04010113          	addi	sp,sp,64
    80201de8:	00008067          	ret
