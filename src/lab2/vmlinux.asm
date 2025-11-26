
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
    80200004:	06813103          	ld	sp,104(sp) # 80203068 <_GLOBAL_OFFSET_TABLE_+0x30>

    call mm_init #初始化内存管理系统
    80200008:	3c8000ef          	jal	ra,802003d0 <mm_init>
    call task_init #初始化线程数据结构
    8020000c:	408000ef          	jal	ra,80200414 <task_init>
    
    # set stvec = _traps
    la t0,_traps
    80200010:	00003297          	auipc	t0,0x3
    80200014:	0782b283          	ld	t0,120(t0) # 80203088 <_GLOBAL_OFFSET_TABLE_+0x50>
    csrw stvec,t0
    80200018:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
    8020001c:	02000293          	li	t0,32
    csrs sie,t0
    80200020:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
    80200024:	1e4000ef          	jal	ra,80200208 <get_cycles>
    li t0,10000000
    80200028:	009892b7          	lui	t0,0x989
    8020002c:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
    80200030:	00550533          	add	a0,a0,t0
    call sbi_set_timer
    80200034:	405000ef          	jal	ra,80200c38 <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
    80200038:	00200293          	li	t0,2
    csrs sstatus,t0
    8020003c:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
    80200040:	6550006f          	j	80200e94 <start_kernel>

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
    802000d8:	531000ef          	jal	ra,80200e08 <trap_handler>

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
    80200170:	f142b283          	ld	t0,-236(t0) # 80203080 <_GLOBAL_OFFSET_TABLE_+0x48>
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
    ld t0,144(a1)
    802001b4:	0905b283          	ld	t0,144(a1)
    beqz t0,first_schedule
    802001b8:	04028063          	beqz	t0,802001f8 <first_schedule>
    #恢复下一个进程上下文

    ld ra,32(a1)
    802001bc:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
    802001c0:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
    802001c4:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
    802001c8:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
    802001cc:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
    802001d0:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
    802001d4:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
    802001d8:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
    802001dc:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
    802001e0:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
    802001e4:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
    802001e8:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
    802001ec:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
    802001f0:	0885bd83          	ld	s11,136(a1)
    j switch_done
    802001f4:	0100006f          	j	80200204 <switch_done>

00000000802001f8 <first_schedule>:

first_schedule:
    ld ra,32(a1)
    802001f8:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
    802001fc:	0285b103          	ld	sp,40(a1)
    j switch_done
    80200200:	0040006f          	j	80200204 <switch_done>

0000000080200204 <switch_done>:

switch_done:
    ret
    80200204:	00008067          	ret

0000000080200208 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200208:	fe010113          	addi	sp,sp,-32
    8020020c:	00813c23          	sd	s0,24(sp)
    80200210:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
    80200214:	c01027f3          	rdtime	a5
    80200218:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
    8020021c:	fe843783          	ld	a5,-24(s0)
}
    80200220:	00078513          	mv	a0,a5
    80200224:	01813403          	ld	s0,24(sp)
    80200228:	02010113          	addi	sp,sp,32
    8020022c:	00008067          	ret

0000000080200230 <clock_set_next_event>:

void clock_set_next_event() {
    80200230:	fe010113          	addi	sp,sp,-32
    80200234:	00113c23          	sd	ra,24(sp)
    80200238:	00813823          	sd	s0,16(sp)
    8020023c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200240:	fc9ff0ef          	jal	ra,80200208 <get_cycles>
    80200244:	00050713          	mv	a4,a0
    80200248:	00003797          	auipc	a5,0x3
    8020024c:	db878793          	addi	a5,a5,-584 # 80203000 <TIMECLOCK>
    80200250:	0007b783          	ld	a5,0(a5)
    80200254:	00f707b3          	add	a5,a4,a5
    80200258:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
    8020025c:	fe843503          	ld	a0,-24(s0)
    80200260:	1d9000ef          	jal	ra,80200c38 <sbi_set_timer>
    80200264:	00000013          	nop
    80200268:	01813083          	ld	ra,24(sp)
    8020026c:	01013403          	ld	s0,16(sp)
    80200270:	02010113          	addi	sp,sp,32
    80200274:	00008067          	ret

0000000080200278 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    80200278:	fe010113          	addi	sp,sp,-32
    8020027c:	00113c23          	sd	ra,24(sp)
    80200280:	00813823          	sd	s0,16(sp)
    80200284:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    80200288:	00003797          	auipc	a5,0x3
    8020028c:	db87b783          	ld	a5,-584(a5) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200290:	0007b783          	ld	a5,0(a5)
    80200294:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    80200298:	fe843783          	ld	a5,-24(s0)
    8020029c:	0007b703          	ld	a4,0(a5)
    802002a0:	00003797          	auipc	a5,0x3
    802002a4:	da07b783          	ld	a5,-608(a5) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x8>
    802002a8:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    802002ac:	00001637          	lui	a2,0x1
    802002b0:	00000593          	li	a1,0
    802002b4:	fe843503          	ld	a0,-24(s0)
    802002b8:	415010ef          	jal	ra,80201ecc <memset>
    return (void *)r;
    802002bc:	fe843783          	ld	a5,-24(s0)
}
    802002c0:	00078513          	mv	a0,a5
    802002c4:	01813083          	ld	ra,24(sp)
    802002c8:	01013403          	ld	s0,16(sp)
    802002cc:	02010113          	addi	sp,sp,32
    802002d0:	00008067          	ret

00000000802002d4 <kfree>:

void kfree(void *addr) {
    802002d4:	fd010113          	addi	sp,sp,-48
    802002d8:	02113423          	sd	ra,40(sp)
    802002dc:	02813023          	sd	s0,32(sp)
    802002e0:	03010413          	addi	s0,sp,48
    802002e4:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002e8:	fd843783          	ld	a5,-40(s0)
    802002ec:	00078693          	mv	a3,a5
    802002f0:	fd840793          	addi	a5,s0,-40
    802002f4:	fffff737          	lui	a4,0xfffff
    802002f8:	00e6f733          	and	a4,a3,a4
    802002fc:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    80200300:	fd843783          	ld	a5,-40(s0)
    80200304:	00001637          	lui	a2,0x1
    80200308:	00000593          	li	a1,0
    8020030c:	00078513          	mv	a0,a5
    80200310:	3bd010ef          	jal	ra,80201ecc <memset>

    r = (struct run *)addr;
    80200314:	fd843783          	ld	a5,-40(s0)
    80200318:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    8020031c:	00003797          	auipc	a5,0x3
    80200320:	d247b783          	ld	a5,-732(a5) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200324:	0007b703          	ld	a4,0(a5)
    80200328:	fe843783          	ld	a5,-24(s0)
    8020032c:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200330:	00003797          	auipc	a5,0x3
    80200334:	d107b783          	ld	a5,-752(a5) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200338:	fe843703          	ld	a4,-24(s0)
    8020033c:	00e7b023          	sd	a4,0(a5)

    return;
    80200340:	00000013          	nop
}
    80200344:	02813083          	ld	ra,40(sp)
    80200348:	02013403          	ld	s0,32(sp)
    8020034c:	03010113          	addi	sp,sp,48
    80200350:	00008067          	ret

0000000080200354 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200354:	fd010113          	addi	sp,sp,-48
    80200358:	02113423          	sd	ra,40(sp)
    8020035c:	02813023          	sd	s0,32(sp)
    80200360:	03010413          	addi	s0,sp,48
    80200364:	fca43c23          	sd	a0,-40(s0)
    80200368:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    8020036c:	fd843703          	ld	a4,-40(s0)
    80200370:	000017b7          	lui	a5,0x1
    80200374:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    80200378:	00f70733          	add	a4,a4,a5
    8020037c:	fffff7b7          	lui	a5,0xfffff
    80200380:	00f777b3          	and	a5,a4,a5
    80200384:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200388:	01c0006f          	j	802003a4 <kfreerange+0x50>
        kfree((void *)addr);
    8020038c:	fe843503          	ld	a0,-24(s0)
    80200390:	f45ff0ef          	jal	ra,802002d4 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200394:	fe843703          	ld	a4,-24(s0)
    80200398:	000017b7          	lui	a5,0x1
    8020039c:	00f707b3          	add	a5,a4,a5
    802003a0:	fef43423          	sd	a5,-24(s0)
    802003a4:	fe843703          	ld	a4,-24(s0)
    802003a8:	000017b7          	lui	a5,0x1
    802003ac:	00f70733          	add	a4,a4,a5
    802003b0:	fd043783          	ld	a5,-48(s0)
    802003b4:	fce7fce3          	bgeu	a5,a4,8020038c <kfreerange+0x38>
    }
}
    802003b8:	00000013          	nop
    802003bc:	00000013          	nop
    802003c0:	02813083          	ld	ra,40(sp)
    802003c4:	02013403          	ld	s0,32(sp)
    802003c8:	03010113          	addi	sp,sp,48
    802003cc:	00008067          	ret

00000000802003d0 <mm_init>:

void mm_init(void) {
    802003d0:	ff010113          	addi	sp,sp,-16
    802003d4:	00113423          	sd	ra,8(sp)
    802003d8:	00813023          	sd	s0,0(sp)
    802003dc:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003e0:	01100793          	li	a5,17
    802003e4:	01b79593          	slli	a1,a5,0x1b
    802003e8:	00003517          	auipc	a0,0x3
    802003ec:	c6053503          	ld	a0,-928(a0) # 80203048 <_GLOBAL_OFFSET_TABLE_+0x10>
    802003f0:	f65ff0ef          	jal	ra,80200354 <kfreerange>
    printk("...mm_init done!\n");
    802003f4:	00002517          	auipc	a0,0x2
    802003f8:	c0c50513          	addi	a0,a0,-1012 # 80202000 <_srodata>
    802003fc:	1b1010ef          	jal	ra,80201dac <printk>
}
    80200400:	00000013          	nop
    80200404:	00813083          	ld	ra,8(sp)
    80200408:	00013403          	ld	s0,0(sp)
    8020040c:	01010113          	addi	sp,sp,16
    80200410:	00008067          	ret

0000000080200414 <task_init>:
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

extern void __dummy();

void task_init() {
    80200414:	fe010113          	addi	sp,sp,-32
    80200418:	00113c23          	sd	ra,24(sp)
    8020041c:	00813823          	sd	s0,16(sp)
    80200420:	02010413          	addi	s0,sp,32
    srand(2024);
    80200424:	7e800513          	li	a0,2024
    80200428:	205010ef          	jal	ra,80201e2c <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
    8020042c:	e4dff0ef          	jal	ra,80200278 <kalloc>
    80200430:	00050713          	mv	a4,a0
    80200434:	00003797          	auipc	a5,0x3
    80200438:	c2c7b783          	ld	a5,-980(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    8020043c:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    80200440:	00003797          	auipc	a5,0x3
    80200444:	c207b783          	ld	a5,-992(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200448:	0007b783          	ld	a5,0(a5)
    8020044c:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
    80200450:	00003797          	auipc	a5,0x3
    80200454:	c107b783          	ld	a5,-1008(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200458:	0007b783          	ld	a5,0(a5)
    8020045c:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
    80200460:	00003797          	auipc	a5,0x3
    80200464:	c007b783          	ld	a5,-1024(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200468:	0007b783          	ld	a5,0(a5)
    8020046c:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
    80200470:	00003797          	auipc	a5,0x3
    80200474:	bf07b783          	ld	a5,-1040(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200478:	0007b783          	ld	a5,0(a5)
    8020047c:	0007bc23          	sd	zero,24(a5)
    idle->thread.first_schedule=0;
    80200480:	00003797          	auipc	a5,0x3
    80200484:	be07b783          	ld	a5,-1056(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200488:	0007b783          	ld	a5,0(a5)
    8020048c:	0807b823          	sd	zero,144(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    80200490:	00003797          	auipc	a5,0x3
    80200494:	bd07b783          	ld	a5,-1072(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200498:	0007b703          	ld	a4,0(a5)
    8020049c:	00003797          	auipc	a5,0x3
    802004a0:	bd47b783          	ld	a5,-1068(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    802004a4:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
    802004a8:	00003797          	auipc	a5,0x3
    802004ac:	bb87b783          	ld	a5,-1096(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    802004b0:	0007b703          	ld	a4,0(a5)
    802004b4:	00003797          	auipc	a5,0x3
    802004b8:	bc47b783          	ld	a5,-1084(a5) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802004bc:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    for(int i=1;i<NR_TASKS;i++){
    802004c0:	00100793          	li	a5,1
    802004c4:	fef42623          	sw	a5,-20(s0)
    802004c8:	14c0006f          	j	80200614 <task_init+0x200>
        task[i]=(struct task_struct *)kalloc();
    802004cc:	dadff0ef          	jal	ra,80200278 <kalloc>
    802004d0:	00050693          	mv	a3,a0
    802004d4:	00003717          	auipc	a4,0x3
    802004d8:	ba473703          	ld	a4,-1116(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802004dc:	fec42783          	lw	a5,-20(s0)
    802004e0:	00379793          	slli	a5,a5,0x3
    802004e4:	00f707b3          	add	a5,a4,a5
    802004e8:	00d7b023          	sd	a3,0(a5)
        task[i]->state=TASK_RUNNING;
    802004ec:	00003717          	auipc	a4,0x3
    802004f0:	b8c73703          	ld	a4,-1140(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802004f4:	fec42783          	lw	a5,-20(s0)
    802004f8:	00379793          	slli	a5,a5,0x3
    802004fc:	00f707b3          	add	a5,a4,a5
    80200500:	0007b783          	ld	a5,0(a5)
    80200504:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
    80200508:	00003717          	auipc	a4,0x3
    8020050c:	b7073703          	ld	a4,-1168(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200510:	fec42783          	lw	a5,-20(s0)
    80200514:	00379793          	slli	a5,a5,0x3
    80200518:	00f707b3          	add	a5,a4,a5
    8020051c:	0007b783          	ld	a5,0(a5)
    80200520:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
    80200524:	14d010ef          	jal	ra,80201e70 <rand>
    80200528:	00050793          	mv	a5,a0
    8020052c:	00078713          	mv	a4,a5
    80200530:	00a00793          	li	a5,10
    80200534:	02f767bb          	remw	a5,a4,a5
    80200538:	0007879b          	sext.w	a5,a5
    8020053c:	0017879b          	addiw	a5,a5,1
    80200540:	0007869b          	sext.w	a3,a5
    80200544:	00003717          	auipc	a4,0x3
    80200548:	b3473703          	ld	a4,-1228(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    8020054c:	fec42783          	lw	a5,-20(s0)
    80200550:	00379793          	slli	a5,a5,0x3
    80200554:	00f707b3          	add	a5,a4,a5
    80200558:	0007b783          	ld	a5,0(a5)
    8020055c:	00068713          	mv	a4,a3
    80200560:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
    80200564:	00003717          	auipc	a4,0x3
    80200568:	b1473703          	ld	a4,-1260(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    8020056c:	fec42783          	lw	a5,-20(s0)
    80200570:	00379793          	slli	a5,a5,0x3
    80200574:	00f707b3          	add	a5,a4,a5
    80200578:	0007b783          	ld	a5,0(a5)
    8020057c:	fec42703          	lw	a4,-20(s0)
    80200580:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
    80200584:	00003717          	auipc	a4,0x3
    80200588:	af473703          	ld	a4,-1292(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    8020058c:	fec42783          	lw	a5,-20(s0)
    80200590:	00379793          	slli	a5,a5,0x3
    80200594:	00f707b3          	add	a5,a4,a5
    80200598:	0007b783          	ld	a5,0(a5)
    8020059c:	00003717          	auipc	a4,0x3
    802005a0:	ab473703          	ld	a4,-1356(a4) # 80203050 <_GLOBAL_OFFSET_TABLE_+0x18>
    802005a4:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
    802005a8:	00003717          	auipc	a4,0x3
    802005ac:	ad073703          	ld	a4,-1328(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802005b0:	fec42783          	lw	a5,-20(s0)
    802005b4:	00379793          	slli	a5,a5,0x3
    802005b8:	00f707b3          	add	a5,a4,a5
    802005bc:	0007b783          	ld	a5,0(a5)
    802005c0:	00078693          	mv	a3,a5
    802005c4:	00003717          	auipc	a4,0x3
    802005c8:	ab473703          	ld	a4,-1356(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802005cc:	fec42783          	lw	a5,-20(s0)
    802005d0:	00379793          	slli	a5,a5,0x3
    802005d4:	00f707b3          	add	a5,a4,a5
    802005d8:	0007b783          	ld	a5,0(a5)
    802005dc:	00001737          	lui	a4,0x1
    802005e0:	00e68733          	add	a4,a3,a4
    802005e4:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.first_schedule=1;
    802005e8:	00003717          	auipc	a4,0x3
    802005ec:	a9073703          	ld	a4,-1392(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802005f0:	fec42783          	lw	a5,-20(s0)
    802005f4:	00379793          	slli	a5,a5,0x3
    802005f8:	00f707b3          	add	a5,a4,a5
    802005fc:	0007b783          	ld	a5,0(a5)
    80200600:	00100713          	li	a4,1
    80200604:	08e7b823          	sd	a4,144(a5)
    for(int i=1;i<NR_TASKS;i++){
    80200608:	fec42783          	lw	a5,-20(s0)
    8020060c:	0017879b          	addiw	a5,a5,1
    80200610:	fef42623          	sw	a5,-20(s0)
    80200614:	fec42783          	lw	a5,-20(s0)
    80200618:	0007871b          	sext.w	a4,a5
    8020061c:	00400793          	li	a5,4
    80200620:	eae7d6e3          	bge	a5,a4,802004cc <task_init+0xb8>
    }

    printk("...task_init done!\n");
    80200624:	00002517          	auipc	a0,0x2
    80200628:	9f450513          	addi	a0,a0,-1548 # 80202018 <_srodata+0x18>
    8020062c:	780010ef          	jal	ra,80201dac <printk>
}
    80200630:	00000013          	nop
    80200634:	01813083          	ld	ra,24(sp)
    80200638:	01013403          	ld	s0,16(sp)
    8020063c:	02010113          	addi	sp,sp,32
    80200640:	00008067          	ret

0000000080200644 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    80200644:	fd010113          	addi	sp,sp,-48
    80200648:	02113423          	sd	ra,40(sp)
    8020064c:	02813023          	sd	s0,32(sp)
    80200650:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    80200654:	3b9ad7b7          	lui	a5,0x3b9ad
    80200658:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    8020065c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200660:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    80200664:	fff00793          	li	a5,-1
    80200668:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    8020066c:	fe442783          	lw	a5,-28(s0)
    80200670:	0007871b          	sext.w	a4,a5
    80200674:	fff00793          	li	a5,-1
    80200678:	00f70e63          	beq	a4,a5,80200694 <dummy+0x50>
    8020067c:	00003797          	auipc	a5,0x3
    80200680:	9f47b783          	ld	a5,-1548(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200684:	0007b783          	ld	a5,0(a5)
    80200688:	0087b703          	ld	a4,8(a5)
    8020068c:	fe442783          	lw	a5,-28(s0)
    80200690:	fcf70ee3          	beq	a4,a5,8020066c <dummy+0x28>
    80200694:	00003797          	auipc	a5,0x3
    80200698:	9dc7b783          	ld	a5,-1572(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020069c:	0007b783          	ld	a5,0(a5)
    802006a0:	0087b783          	ld	a5,8(a5)
    802006a4:	fc0784e3          	beqz	a5,8020066c <dummy+0x28>
            if (current->counter == 1) {
    802006a8:	00003797          	auipc	a5,0x3
    802006ac:	9c87b783          	ld	a5,-1592(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    802006b0:	0007b783          	ld	a5,0(a5)
    802006b4:	0087b703          	ld	a4,8(a5)
    802006b8:	00100793          	li	a5,1
    802006bc:	00f71e63          	bne	a4,a5,802006d8 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    802006c0:	00003797          	auipc	a5,0x3
    802006c4:	9b07b783          	ld	a5,-1616(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    802006c8:	0007b783          	ld	a5,0(a5)
    802006cc:	0087b703          	ld	a4,8(a5)
    802006d0:	fff70713          	addi	a4,a4,-1
    802006d4:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    802006d8:	00003797          	auipc	a5,0x3
    802006dc:	9987b783          	ld	a5,-1640(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    802006e0:	0007b783          	ld	a5,0(a5)
    802006e4:	0087b783          	ld	a5,8(a5)
    802006e8:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    802006ec:	fe843783          	ld	a5,-24(s0)
    802006f0:	00178713          	addi	a4,a5,1
    802006f4:	fd843783          	ld	a5,-40(s0)
    802006f8:	02f777b3          	remu	a5,a4,a5
    802006fc:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    80200700:	00003797          	auipc	a5,0x3
    80200704:	9707b783          	ld	a5,-1680(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200708:	0007b783          	ld	a5,0(a5)
    8020070c:	0187b783          	ld	a5,24(a5)
    80200710:	fe843603          	ld	a2,-24(s0)
    80200714:	00078593          	mv	a1,a5
    80200718:	00002517          	auipc	a0,0x2
    8020071c:	91850513          	addi	a0,a0,-1768 # 80202030 <_srodata+0x30>
    80200720:	68c010ef          	jal	ra,80201dac <printk>
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
    80200724:	00003797          	auipc	a5,0x3
    80200728:	94c7b783          	ld	a5,-1716(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020072c:	0007b783          	ld	a5,0(a5)
    80200730:	0187b783          	ld	a5,24(a5)
    80200734:	0ff7f713          	andi	a4,a5,255
    80200738:	00005797          	auipc	a5,0x5
    8020073c:	8c878793          	addi	a5,a5,-1848 # 80205000 <tasks_output_index>
    80200740:	0007a783          	lw	a5,0(a5)
    80200744:	0017869b          	addiw	a3,a5,1
    80200748:	0006861b          	sext.w	a2,a3
    8020074c:	00005697          	auipc	a3,0x5
    80200750:	8b468693          	addi	a3,a3,-1868 # 80205000 <tasks_output_index>
    80200754:	00c6a023          	sw	a2,0(a3)
    80200758:	0307071b          	addiw	a4,a4,48
    8020075c:	0ff77713          	andi	a4,a4,255
    80200760:	00003697          	auipc	a3,0x3
    80200764:	8f86b683          	ld	a3,-1800(a3) # 80203058 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200768:	00f687b3          	add	a5,a3,a5
    8020076c:	00e78023          	sb	a4,0(a5)
            if (tasks_output_index == MAX_OUTPUT) {
    80200770:	00005797          	auipc	a5,0x5
    80200774:	89078793          	addi	a5,a5,-1904 # 80205000 <tasks_output_index>
    80200778:	0007a783          	lw	a5,0(a5)
    8020077c:	00078713          	mv	a4,a5
    80200780:	02800793          	li	a5,40
    80200784:	eef714e3          	bne	a4,a5,8020066c <dummy+0x28>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
    80200788:	fe042023          	sw	zero,-32(s0)
    8020078c:	0800006f          	j	8020080c <dummy+0x1c8>
                    if (tasks_output[i] != expected_output[i]) {
    80200790:	00003717          	auipc	a4,0x3
    80200794:	8c873703          	ld	a4,-1848(a4) # 80203058 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200798:	fe042783          	lw	a5,-32(s0)
    8020079c:	00f707b3          	add	a5,a4,a5
    802007a0:	0007c683          	lbu	a3,0(a5)
    802007a4:	00003717          	auipc	a4,0x3
    802007a8:	86470713          	addi	a4,a4,-1948 # 80203008 <expected_output>
    802007ac:	fe042783          	lw	a5,-32(s0)
    802007b0:	00f707b3          	add	a5,a4,a5
    802007b4:	0007c783          	lbu	a5,0(a5)
    802007b8:	00068713          	mv	a4,a3
    802007bc:	04f70263          	beq	a4,a5,80200800 <dummy+0x1bc>
                        printk("\033[31mTest failed!\033[0m\n");
    802007c0:	00002517          	auipc	a0,0x2
    802007c4:	8a050513          	addi	a0,a0,-1888 # 80202060 <_srodata+0x60>
    802007c8:	5e4010ef          	jal	ra,80201dac <printk>
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
    802007cc:	00003597          	auipc	a1,0x3
    802007d0:	83c58593          	addi	a1,a1,-1988 # 80203008 <expected_output>
    802007d4:	00002517          	auipc	a0,0x2
    802007d8:	8a450513          	addi	a0,a0,-1884 # 80202078 <_srodata+0x78>
    802007dc:	5d0010ef          	jal	ra,80201dac <printk>
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
    802007e0:	00003597          	auipc	a1,0x3
    802007e4:	8785b583          	ld	a1,-1928(a1) # 80203058 <_GLOBAL_OFFSET_TABLE_+0x20>
    802007e8:	00002517          	auipc	a0,0x2
    802007ec:	8b050513          	addi	a0,a0,-1872 # 80202098 <_srodata+0x98>
    802007f0:	5bc010ef          	jal	ra,80201dac <printk>
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    802007f4:	00000593          	li	a1,0
    802007f8:	00000513          	li	a0,0
    802007fc:	568000ef          	jal	ra,80200d64 <sbi_system_reset>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
    80200800:	fe042783          	lw	a5,-32(s0)
    80200804:	0017879b          	addiw	a5,a5,1
    80200808:	fef42023          	sw	a5,-32(s0)
    8020080c:	fe042783          	lw	a5,-32(s0)
    80200810:	0007871b          	sext.w	a4,a5
    80200814:	02700793          	li	a5,39
    80200818:	f6e7dce3          	bge	a5,a4,80200790 <dummy+0x14c>
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
    8020081c:	00002517          	auipc	a0,0x2
    80200820:	89c50513          	addi	a0,a0,-1892 # 802020b8 <_srodata+0xb8>
    80200824:	588010ef          	jal	ra,80201dac <printk>
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
    80200828:	00002597          	auipc	a1,0x2
    8020082c:	7e058593          	addi	a1,a1,2016 # 80203008 <expected_output>
    80200830:	00002517          	auipc	a0,0x2
    80200834:	8a050513          	addi	a0,a0,-1888 # 802020d0 <_srodata+0xd0>
    80200838:	574010ef          	jal	ra,80201dac <printk>
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    8020083c:	00000593          	li	a1,0
    80200840:	00000513          	li	a0,0
    80200844:	520000ef          	jal	ra,80200d64 <sbi_system_reset>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200848:	e25ff06f          	j	8020066c <dummy+0x28>

000000008020084c <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
    8020084c:	fd010113          	addi	sp,sp,-48
    80200850:	02113423          	sd	ra,40(sp)
    80200854:	02813023          	sd	s0,32(sp)
    80200858:	03010413          	addi	s0,sp,48
    8020085c:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
    80200860:	00003797          	auipc	a5,0x3
    80200864:	8107b783          	ld	a5,-2032(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200868:	0007b783          	ld	a5,0(a5)
    8020086c:	fd843703          	ld	a4,-40(s0)
    80200870:	06f70063          	beq	a4,a5,802008d0 <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
    80200874:	00002797          	auipc	a5,0x2
    80200878:	7fc7b783          	ld	a5,2044(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020087c:	0007b783          	ld	a5,0(a5)
    80200880:	fef43423          	sd	a5,-24(s0)
    current=next;
    80200884:	00002797          	auipc	a5,0x2
    80200888:	7ec7b783          	ld	a5,2028(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020088c:	fd843703          	ld	a4,-40(s0)
    80200890:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
    80200894:	fd843783          	ld	a5,-40(s0)
    80200898:	0187b703          	ld	a4,24(a5)
    8020089c:	fd843783          	ld	a5,-40(s0)
    802008a0:	0107b603          	ld	a2,16(a5)
    802008a4:	fd843783          	ld	a5,-40(s0)
    802008a8:	0087b783          	ld	a5,8(a5)
    802008ac:	00078693          	mv	a3,a5
    802008b0:	00070593          	mv	a1,a4
    802008b4:	00002517          	auipc	a0,0x2
    802008b8:	83c50513          	addi	a0,a0,-1988 # 802020f0 <_srodata+0xf0>
    802008bc:	4f0010ef          	jal	ra,80201dac <printk>
    __switch_to(prev,next);
    802008c0:	fd843583          	ld	a1,-40(s0)
    802008c4:	fe843503          	ld	a0,-24(s0)
    802008c8:	8b5ff0ef          	jal	ra,8020017c <__switch_to>
    802008cc:	0080006f          	j	802008d4 <switch_to+0x88>
        return;
    802008d0:	00000013          	nop
    
}
    802008d4:	02813083          	ld	ra,40(sp)
    802008d8:	02013403          	ld	s0,32(sp)
    802008dc:	03010113          	addi	sp,sp,48
    802008e0:	00008067          	ret

00000000802008e4 <do_timer>:

void do_timer(){
    802008e4:	ff010113          	addi	sp,sp,-16
    802008e8:	00113423          	sd	ra,8(sp)
    802008ec:	00813023          	sd	s0,0(sp)
    802008f0:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
    802008f4:	00002797          	auipc	a5,0x2
    802008f8:	77c7b783          	ld	a5,1916(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    802008fc:	0007b703          	ld	a4,0(a5)
    80200900:	00002797          	auipc	a5,0x2
    80200904:	7607b783          	ld	a5,1888(a5) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    80200908:	0007b783          	ld	a5,0(a5)
    8020090c:	00f70c63          	beq	a4,a5,80200924 <do_timer+0x40>
    80200910:	00002797          	auipc	a5,0x2
    80200914:	7607b783          	ld	a5,1888(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200918:	0007b783          	ld	a5,0(a5)
    8020091c:	0087b783          	ld	a5,8(a5)
    80200920:	00079663          	bnez	a5,8020092c <do_timer+0x48>
        schedule();
    80200924:	04c000ef          	jal	ra,80200970 <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
    80200928:	0340006f          	j	8020095c <do_timer+0x78>
        current->counter--;
    8020092c:	00002797          	auipc	a5,0x2
    80200930:	7447b783          	ld	a5,1860(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    80200934:	0007b783          	ld	a5,0(a5)
    80200938:	0087b703          	ld	a4,8(a5)
    8020093c:	fff70713          	addi	a4,a4,-1
    80200940:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
    80200944:	00002797          	auipc	a5,0x2
    80200948:	72c7b783          	ld	a5,1836(a5) # 80203070 <_GLOBAL_OFFSET_TABLE_+0x38>
    8020094c:	0007b783          	ld	a5,0(a5)
    80200950:	0087b783          	ld	a5,8(a5)
    80200954:	00079463          	bnez	a5,8020095c <do_timer+0x78>
            schedule();
    80200958:	018000ef          	jal	ra,80200970 <schedule>
}
    8020095c:	00000013          	nop
    80200960:	00813083          	ld	ra,8(sp)
    80200964:	00013403          	ld	s0,0(sp)
    80200968:	01010113          	addi	sp,sp,16
    8020096c:	00008067          	ret

0000000080200970 <schedule>:

void schedule(){
    80200970:	fd010113          	addi	sp,sp,-48
    80200974:	02113423          	sd	ra,40(sp)
    80200978:	02813023          	sd	s0,32(sp)
    8020097c:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
    80200980:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
    80200984:	fe043023          	sd	zero,-32(s0)
    //找到 counter 最大的线程
    for(int i=0;i<NR_TASKS;i++){
    80200988:	fc042e23          	sw	zero,-36(s0)
    8020098c:	0700006f          	j	802009fc <schedule+0x8c>
        if(task[i]->counter>max_counter){
    80200990:	00002717          	auipc	a4,0x2
    80200994:	6e873703          	ld	a4,1768(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200998:	fdc42783          	lw	a5,-36(s0)
    8020099c:	00379793          	slli	a5,a5,0x3
    802009a0:	00f707b3          	add	a5,a4,a5
    802009a4:	0007b783          	ld	a5,0(a5)
    802009a8:	0087b783          	ld	a5,8(a5)
    802009ac:	fe043703          	ld	a4,-32(s0)
    802009b0:	04f77063          	bgeu	a4,a5,802009f0 <schedule+0x80>
            max_counter=task[i]->counter;
    802009b4:	00002717          	auipc	a4,0x2
    802009b8:	6c473703          	ld	a4,1732(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802009bc:	fdc42783          	lw	a5,-36(s0)
    802009c0:	00379793          	slli	a5,a5,0x3
    802009c4:	00f707b3          	add	a5,a4,a5
    802009c8:	0007b783          	ld	a5,0(a5)
    802009cc:	0087b783          	ld	a5,8(a5)
    802009d0:	fef43023          	sd	a5,-32(s0)
            next=task[i];
    802009d4:	00002717          	auipc	a4,0x2
    802009d8:	6a473703          	ld	a4,1700(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    802009dc:	fdc42783          	lw	a5,-36(s0)
    802009e0:	00379793          	slli	a5,a5,0x3
    802009e4:	00f707b3          	add	a5,a4,a5
    802009e8:	0007b783          	ld	a5,0(a5)
    802009ec:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
    802009f0:	fdc42783          	lw	a5,-36(s0)
    802009f4:	0017879b          	addiw	a5,a5,1
    802009f8:	fcf42e23          	sw	a5,-36(s0)
    802009fc:	fdc42783          	lw	a5,-36(s0)
    80200a00:	0007871b          	sext.w	a4,a5
    80200a04:	00400793          	li	a5,4
    80200a08:	f8e7d4e3          	bge	a5,a4,80200990 <schedule+0x20>
        }
    }
    //如果所有线程的 counter 都为 0，则重新为每个线程分配时间片，分配策略为将线程的 priority 赋值给 counter
    if(max_counter==0){
    80200a0c:	fe043783          	ld	a5,-32(s0)
    80200a10:	12079463          	bnez	a5,80200b38 <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
    80200a14:	00100793          	li	a5,1
    80200a18:	fcf42c23          	sw	a5,-40(s0)
    80200a1c:	10c0006f          	j	80200b28 <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
    80200a20:	00002717          	auipc	a4,0x2
    80200a24:	65873703          	ld	a4,1624(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200a28:	fd842783          	lw	a5,-40(s0)
    80200a2c:	00379793          	slli	a5,a5,0x3
    80200a30:	00f707b3          	add	a5,a4,a5
    80200a34:	0007b703          	ld	a4,0(a5)
    80200a38:	00002697          	auipc	a3,0x2
    80200a3c:	6406b683          	ld	a3,1600(a3) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200a40:	fd842783          	lw	a5,-40(s0)
    80200a44:	00379793          	slli	a5,a5,0x3
    80200a48:	00f687b3          	add	a5,a3,a5
    80200a4c:	0007b783          	ld	a5,0(a5)
    80200a50:	01073703          	ld	a4,16(a4)
    80200a54:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
    80200a58:	00002717          	auipc	a4,0x2
    80200a5c:	62073703          	ld	a4,1568(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200a60:	fd842783          	lw	a5,-40(s0)
    80200a64:	00379793          	slli	a5,a5,0x3
    80200a68:	00f707b3          	add	a5,a4,a5
    80200a6c:	0007b783          	ld	a5,0(a5)
    80200a70:	0187b583          	ld	a1,24(a5)
    80200a74:	00002717          	auipc	a4,0x2
    80200a78:	60473703          	ld	a4,1540(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200a7c:	fd842783          	lw	a5,-40(s0)
    80200a80:	00379793          	slli	a5,a5,0x3
    80200a84:	00f707b3          	add	a5,a4,a5
    80200a88:	0007b783          	ld	a5,0(a5)
    80200a8c:	0107b603          	ld	a2,16(a5)
    80200a90:	00002717          	auipc	a4,0x2
    80200a94:	5e873703          	ld	a4,1512(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200a98:	fd842783          	lw	a5,-40(s0)
    80200a9c:	00379793          	slli	a5,a5,0x3
    80200aa0:	00f707b3          	add	a5,a4,a5
    80200aa4:	0007b783          	ld	a5,0(a5)
    80200aa8:	0087b783          	ld	a5,8(a5)
    80200aac:	00078693          	mv	a3,a5
    80200ab0:	00001517          	auipc	a0,0x1
    80200ab4:	68050513          	addi	a0,a0,1664 # 80202130 <_srodata+0x130>
    80200ab8:	2f4010ef          	jal	ra,80201dac <printk>
            if(task[i]->counter>max_counter){
    80200abc:	00002717          	auipc	a4,0x2
    80200ac0:	5bc73703          	ld	a4,1468(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200ac4:	fd842783          	lw	a5,-40(s0)
    80200ac8:	00379793          	slli	a5,a5,0x3
    80200acc:	00f707b3          	add	a5,a4,a5
    80200ad0:	0007b783          	ld	a5,0(a5)
    80200ad4:	0087b783          	ld	a5,8(a5)
    80200ad8:	fe043703          	ld	a4,-32(s0)
    80200adc:	04f77063          	bgeu	a4,a5,80200b1c <schedule+0x1ac>
                max_counter=task[i]->counter;
    80200ae0:	00002717          	auipc	a4,0x2
    80200ae4:	59873703          	ld	a4,1432(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200ae8:	fd842783          	lw	a5,-40(s0)
    80200aec:	00379793          	slli	a5,a5,0x3
    80200af0:	00f707b3          	add	a5,a4,a5
    80200af4:	0007b783          	ld	a5,0(a5)
    80200af8:	0087b783          	ld	a5,8(a5)
    80200afc:	fef43023          	sd	a5,-32(s0)
                next=task[i];
    80200b00:	00002717          	auipc	a4,0x2
    80200b04:	57873703          	ld	a4,1400(a4) # 80203078 <_GLOBAL_OFFSET_TABLE_+0x40>
    80200b08:	fd842783          	lw	a5,-40(s0)
    80200b0c:	00379793          	slli	a5,a5,0x3
    80200b10:	00f707b3          	add	a5,a4,a5
    80200b14:	0007b783          	ld	a5,0(a5)
    80200b18:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
    80200b1c:	fd842783          	lw	a5,-40(s0)
    80200b20:	0017879b          	addiw	a5,a5,1
    80200b24:	fcf42c23          	sw	a5,-40(s0)
    80200b28:	fd842783          	lw	a5,-40(s0)
    80200b2c:	0007871b          	sext.w	a4,a5
    80200b30:	00400793          	li	a5,4
    80200b34:	eee7d6e3          	bge	a5,a4,80200a20 <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
    80200b38:	fe843783          	ld	a5,-24(s0)
    80200b3c:	00078663          	beqz	a5,80200b48 <schedule+0x1d8>
    80200b40:	fe843503          	ld	a0,-24(s0)
    80200b44:	d09ff0ef          	jal	ra,8020084c <switch_to>
}
    80200b48:	00000013          	nop
    80200b4c:	02813083          	ld	ra,40(sp)
    80200b50:	02013403          	ld	s0,32(sp)
    80200b54:	03010113          	addi	sp,sp,48
    80200b58:	00008067          	ret

0000000080200b5c <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    80200b5c:	f8010113          	addi	sp,sp,-128
    80200b60:	06813c23          	sd	s0,120(sp)
    80200b64:	06913823          	sd	s1,112(sp)
    80200b68:	07213423          	sd	s2,104(sp)
    80200b6c:	07313023          	sd	s3,96(sp)
    80200b70:	08010413          	addi	s0,sp,128
    80200b74:	faa43c23          	sd	a0,-72(s0)
    80200b78:	fab43823          	sd	a1,-80(s0)
    80200b7c:	fac43423          	sd	a2,-88(s0)
    80200b80:	fad43023          	sd	a3,-96(s0)
    80200b84:	f8e43c23          	sd	a4,-104(s0)
    80200b88:	f8f43823          	sd	a5,-112(s0)
    80200b8c:	f9043423          	sd	a6,-120(s0)
    80200b90:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
    80200b94:	fb843e03          	ld	t3,-72(s0)
    80200b98:	fb043e83          	ld	t4,-80(s0)
    80200b9c:	fa843f03          	ld	t5,-88(s0)
    80200ba0:	fa043f83          	ld	t6,-96(s0)
    80200ba4:	f9843283          	ld	t0,-104(s0)
    80200ba8:	f9043483          	ld	s1,-112(s0)
    80200bac:	f8843903          	ld	s2,-120(s0)
    80200bb0:	f8043983          	ld	s3,-128(s0)
    80200bb4:	000e0893          	mv	a7,t3
    80200bb8:	000e8813          	mv	a6,t4
    80200bbc:	000f0513          	mv	a0,t5
    80200bc0:	000f8593          	mv	a1,t6
    80200bc4:	00028613          	mv	a2,t0
    80200bc8:	00048693          	mv	a3,s1
    80200bcc:	00090713          	mv	a4,s2
    80200bd0:	00098793          	mv	a5,s3
    80200bd4:	00000073          	ecall
    80200bd8:	00050e93          	mv	t4,a0
    80200bdc:	00058e13          	mv	t3,a1
    80200be0:	fdd43023          	sd	t4,-64(s0)
    80200be4:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
    80200be8:	fc043783          	ld	a5,-64(s0)
    80200bec:	fcf43823          	sd	a5,-48(s0)
    80200bf0:	fc843783          	ld	a5,-56(s0)
    80200bf4:	fcf43c23          	sd	a5,-40(s0)
    80200bf8:	00000713          	li	a4,0
    80200bfc:	fd043703          	ld	a4,-48(s0)
    80200c00:	00000793          	li	a5,0
    80200c04:	fd843783          	ld	a5,-40(s0)
    80200c08:	00070313          	mv	t1,a4
    80200c0c:	00078393          	mv	t2,a5
    80200c10:	00030713          	mv	a4,t1
    80200c14:	00038793          	mv	a5,t2
}
    80200c18:	00070513          	mv	a0,a4
    80200c1c:	00078593          	mv	a1,a5
    80200c20:	07813403          	ld	s0,120(sp)
    80200c24:	07013483          	ld	s1,112(sp)
    80200c28:	06813903          	ld	s2,104(sp)
    80200c2c:	06013983          	ld	s3,96(sp)
    80200c30:	08010113          	addi	sp,sp,128
    80200c34:	00008067          	ret

0000000080200c38 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    80200c38:	fc010113          	addi	sp,sp,-64
    80200c3c:	02113c23          	sd	ra,56(sp)
    80200c40:	02813823          	sd	s0,48(sp)
    80200c44:	03213423          	sd	s2,40(sp)
    80200c48:	03313023          	sd	s3,32(sp)
    80200c4c:	04010413          	addi	s0,sp,64
    80200c50:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
    80200c54:	00000893          	li	a7,0
    80200c58:	00000813          	li	a6,0
    80200c5c:	00000793          	li	a5,0
    80200c60:	00000713          	li	a4,0
    80200c64:	00000693          	li	a3,0
    80200c68:	fc843603          	ld	a2,-56(s0)
    80200c6c:	00000593          	li	a1,0
    80200c70:	54495537          	lui	a0,0x54495
    80200c74:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200c78:	ee5ff0ef          	jal	ra,80200b5c <sbi_ecall>
    80200c7c:	00050713          	mv	a4,a0
    80200c80:	00058793          	mv	a5,a1
    80200c84:	fce43823          	sd	a4,-48(s0)
    80200c88:	fcf43c23          	sd	a5,-40(s0)
    80200c8c:	00000713          	li	a4,0
    80200c90:	fd043703          	ld	a4,-48(s0)
    80200c94:	00000793          	li	a5,0
    80200c98:	fd843783          	ld	a5,-40(s0)
    80200c9c:	00070913          	mv	s2,a4
    80200ca0:	00078993          	mv	s3,a5
    80200ca4:	00090713          	mv	a4,s2
    80200ca8:	00098793          	mv	a5,s3
}
    80200cac:	00070513          	mv	a0,a4
    80200cb0:	00078593          	mv	a1,a5
    80200cb4:	03813083          	ld	ra,56(sp)
    80200cb8:	03013403          	ld	s0,48(sp)
    80200cbc:	02813903          	ld	s2,40(sp)
    80200cc0:	02013983          	ld	s3,32(sp)
    80200cc4:	04010113          	addi	sp,sp,64
    80200cc8:	00008067          	ret

0000000080200ccc <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200ccc:	fc010113          	addi	sp,sp,-64
    80200cd0:	02113c23          	sd	ra,56(sp)
    80200cd4:	02813823          	sd	s0,48(sp)
    80200cd8:	03213423          	sd	s2,40(sp)
    80200cdc:	03313023          	sd	s3,32(sp)
    80200ce0:	04010413          	addi	s0,sp,64
    80200ce4:	00050793          	mv	a5,a0
    80200ce8:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
    80200cec:	fcf44603          	lbu	a2,-49(s0)
    80200cf0:	00000893          	li	a7,0
    80200cf4:	00000813          	li	a6,0
    80200cf8:	00000793          	li	a5,0
    80200cfc:	00000713          	li	a4,0
    80200d00:	00000693          	li	a3,0
    80200d04:	00200593          	li	a1,2
    80200d08:	44424537          	lui	a0,0x44424
    80200d0c:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200d10:	e4dff0ef          	jal	ra,80200b5c <sbi_ecall>
    80200d14:	00050713          	mv	a4,a0
    80200d18:	00058793          	mv	a5,a1
    80200d1c:	fce43823          	sd	a4,-48(s0)
    80200d20:	fcf43c23          	sd	a5,-40(s0)
    80200d24:	00000713          	li	a4,0
    80200d28:	fd043703          	ld	a4,-48(s0)
    80200d2c:	00000793          	li	a5,0
    80200d30:	fd843783          	ld	a5,-40(s0)
    80200d34:	00070913          	mv	s2,a4
    80200d38:	00078993          	mv	s3,a5
    80200d3c:	00090713          	mv	a4,s2
    80200d40:	00098793          	mv	a5,s3
}
    80200d44:	00070513          	mv	a0,a4
    80200d48:	00078593          	mv	a1,a5
    80200d4c:	03813083          	ld	ra,56(sp)
    80200d50:	03013403          	ld	s0,48(sp)
    80200d54:	02813903          	ld	s2,40(sp)
    80200d58:	02013983          	ld	s3,32(sp)
    80200d5c:	04010113          	addi	sp,sp,64
    80200d60:	00008067          	ret

0000000080200d64 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200d64:	fc010113          	addi	sp,sp,-64
    80200d68:	02113c23          	sd	ra,56(sp)
    80200d6c:	02813823          	sd	s0,48(sp)
    80200d70:	03213423          	sd	s2,40(sp)
    80200d74:	03313023          	sd	s3,32(sp)
    80200d78:	04010413          	addi	s0,sp,64
    80200d7c:	00050793          	mv	a5,a0
    80200d80:	00058713          	mv	a4,a1
    80200d84:	fcf42623          	sw	a5,-52(s0)
    80200d88:	00070793          	mv	a5,a4
    80200d8c:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
    80200d90:	fcc46603          	lwu	a2,-52(s0)
    80200d94:	fc846683          	lwu	a3,-56(s0)
    80200d98:	00000893          	li	a7,0
    80200d9c:	00000813          	li	a6,0
    80200da0:	00000793          	li	a5,0
    80200da4:	00000713          	li	a4,0
    80200da8:	00000593          	li	a1,0
    80200dac:	53525537          	lui	a0,0x53525
    80200db0:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200db4:	da9ff0ef          	jal	ra,80200b5c <sbi_ecall>
    80200db8:	00050713          	mv	a4,a0
    80200dbc:	00058793          	mv	a5,a1
    80200dc0:	fce43823          	sd	a4,-48(s0)
    80200dc4:	fcf43c23          	sd	a5,-40(s0)
    80200dc8:	00000713          	li	a4,0
    80200dcc:	fd043703          	ld	a4,-48(s0)
    80200dd0:	00000793          	li	a5,0
    80200dd4:	fd843783          	ld	a5,-40(s0)
    80200dd8:	00070913          	mv	s2,a4
    80200ddc:	00078993          	mv	s3,a5
    80200de0:	00090713          	mv	a4,s2
    80200de4:	00098793          	mv	a5,s3
    80200de8:	00070513          	mv	a0,a4
    80200dec:	00078593          	mv	a1,a5
    80200df0:	03813083          	ld	ra,56(sp)
    80200df4:	03013403          	ld	s0,48(sp)
    80200df8:	02813903          	ld	s2,40(sp)
    80200dfc:	02013983          	ld	s3,32(sp)
    80200e00:	04010113          	addi	sp,sp,64
    80200e04:	00008067          	ret

0000000080200e08 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200e08:	fd010113          	addi	sp,sp,-48
    80200e0c:	02113423          	sd	ra,40(sp)
    80200e10:	02813023          	sd	s0,32(sp)
    80200e14:	03010413          	addi	s0,sp,48
    80200e18:	fca43c23          	sd	a0,-40(s0)
    80200e1c:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
    80200e20:	fd843783          	ld	a5,-40(s0)
    80200e24:	0407d263          	bgez	a5,80200e68 <trap_handler+0x60>
        uint64_t interrupt_code = scause & ~(1UL << 63);
    80200e28:	fd843703          	ld	a4,-40(s0)
    80200e2c:	fff00793          	li	a5,-1
    80200e30:	0017d793          	srli	a5,a5,0x1
    80200e34:	00f777b3          	and	a5,a4,a5
    80200e38:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
    80200e3c:	fe043703          	ld	a4,-32(s0)
    80200e40:	00500793          	li	a5,5
    80200e44:	00f71863          	bne	a4,a5,80200e54 <trap_handler+0x4c>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
    80200e48:	be8ff0ef          	jal	ra,80200230 <clock_set_next_event>
            do_timer();
    80200e4c:	a99ff0ef          	jal	ra,802008e4 <do_timer>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
    80200e50:	0300006f          	j	80200e80 <trap_handler+0x78>
            printk("other interrupt: %d\n", interrupt_code);
    80200e54:	fe043583          	ld	a1,-32(s0)
    80200e58:	00001517          	auipc	a0,0x1
    80200e5c:	31050513          	addi	a0,a0,784 # 80202168 <_srodata+0x168>
    80200e60:	74d000ef          	jal	ra,80201dac <printk>
    80200e64:	01c0006f          	j	80200e80 <trap_handler+0x78>
        uint64_t exception_code = scause;
    80200e68:	fd843783          	ld	a5,-40(s0)
    80200e6c:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
    80200e70:	fe843583          	ld	a1,-24(s0)
    80200e74:	00001517          	auipc	a0,0x1
    80200e78:	30c50513          	addi	a0,a0,780 # 80202180 <_srodata+0x180>
    80200e7c:	731000ef          	jal	ra,80201dac <printk>
    80200e80:	00000013          	nop
    80200e84:	02813083          	ld	ra,40(sp)
    80200e88:	02013403          	ld	s0,32(sp)
    80200e8c:	03010113          	addi	sp,sp,48
    80200e90:	00008067          	ret

0000000080200e94 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    80200e94:	ff010113          	addi	sp,sp,-16
    80200e98:	00113423          	sd	ra,8(sp)
    80200e9c:	00813023          	sd	s0,0(sp)
    80200ea0:	01010413          	addi	s0,sp,16
    printk("2024");
    80200ea4:	00001517          	auipc	a0,0x1
    80200ea8:	2ec50513          	addi	a0,a0,748 # 80202190 <_srodata+0x190>
    80200eac:	701000ef          	jal	ra,80201dac <printk>
    printk(" ZJU Operating System\n");
    80200eb0:	00001517          	auipc	a0,0x1
    80200eb4:	2e850513          	addi	a0,a0,744 # 80202198 <_srodata+0x198>
    80200eb8:	6f5000ef          	jal	ra,80201dac <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
    80200ebc:	01c000ef          	jal	ra,80200ed8 <test>
    return 0;
    80200ec0:	00000793          	li	a5,0
}
    80200ec4:	00078513          	mv	a0,a5
    80200ec8:	00813083          	ld	ra,8(sp)
    80200ecc:	00013403          	ld	s0,0(sp)
    80200ed0:	01010113          	addi	sp,sp,16
    80200ed4:	00008067          	ret

0000000080200ed8 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
    80200ed8:	fe010113          	addi	sp,sp,-32
    80200edc:	00113c23          	sd	ra,24(sp)
    80200ee0:	00813823          	sd	s0,16(sp)
    80200ee4:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
    80200ee8:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200eec:	fec42783          	lw	a5,-20(s0)
    80200ef0:	0017879b          	addiw	a5,a5,1
    80200ef4:	fef42623          	sw	a5,-20(s0)
    80200ef8:	fec42703          	lw	a4,-20(s0)
    80200efc:	05f5e7b7          	lui	a5,0x5f5e
    80200f00:	1007879b          	addiw	a5,a5,256
    80200f04:	02f767bb          	remw	a5,a4,a5
    80200f08:	0007879b          	sext.w	a5,a5
    80200f0c:	fe0790e3          	bnez	a5,80200eec <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
    80200f10:	00001517          	auipc	a0,0x1
    80200f14:	2a050513          	addi	a0,a0,672 # 802021b0 <_srodata+0x1b0>
    80200f18:	695000ef          	jal	ra,80201dac <printk>
            i = 0;
    80200f1c:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200f20:	fcdff06f          	j	80200eec <test+0x14>

0000000080200f24 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200f24:	fe010113          	addi	sp,sp,-32
    80200f28:	00113c23          	sd	ra,24(sp)
    80200f2c:	00813823          	sd	s0,16(sp)
    80200f30:	02010413          	addi	s0,sp,32
    80200f34:	00050793          	mv	a5,a0
    80200f38:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200f3c:	fec42783          	lw	a5,-20(s0)
    80200f40:	0ff7f793          	andi	a5,a5,255
    80200f44:	00078513          	mv	a0,a5
    80200f48:	d85ff0ef          	jal	ra,80200ccc <sbi_debug_console_write_byte>
    return (char)c;
    80200f4c:	fec42783          	lw	a5,-20(s0)
    80200f50:	0ff7f793          	andi	a5,a5,255
    80200f54:	0007879b          	sext.w	a5,a5
}
    80200f58:	00078513          	mv	a0,a5
    80200f5c:	01813083          	ld	ra,24(sp)
    80200f60:	01013403          	ld	s0,16(sp)
    80200f64:	02010113          	addi	sp,sp,32
    80200f68:	00008067          	ret

0000000080200f6c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200f6c:	fe010113          	addi	sp,sp,-32
    80200f70:	00813c23          	sd	s0,24(sp)
    80200f74:	02010413          	addi	s0,sp,32
    80200f78:	00050793          	mv	a5,a0
    80200f7c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200f80:	fec42783          	lw	a5,-20(s0)
    80200f84:	0007871b          	sext.w	a4,a5
    80200f88:	02000793          	li	a5,32
    80200f8c:	02f70263          	beq	a4,a5,80200fb0 <isspace+0x44>
    80200f90:	fec42783          	lw	a5,-20(s0)
    80200f94:	0007871b          	sext.w	a4,a5
    80200f98:	00800793          	li	a5,8
    80200f9c:	00e7de63          	bge	a5,a4,80200fb8 <isspace+0x4c>
    80200fa0:	fec42783          	lw	a5,-20(s0)
    80200fa4:	0007871b          	sext.w	a4,a5
    80200fa8:	00d00793          	li	a5,13
    80200fac:	00e7c663          	blt	a5,a4,80200fb8 <isspace+0x4c>
    80200fb0:	00100793          	li	a5,1
    80200fb4:	0080006f          	j	80200fbc <isspace+0x50>
    80200fb8:	00000793          	li	a5,0
}
    80200fbc:	00078513          	mv	a0,a5
    80200fc0:	01813403          	ld	s0,24(sp)
    80200fc4:	02010113          	addi	sp,sp,32
    80200fc8:	00008067          	ret

0000000080200fcc <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200fcc:	fb010113          	addi	sp,sp,-80
    80200fd0:	04113423          	sd	ra,72(sp)
    80200fd4:	04813023          	sd	s0,64(sp)
    80200fd8:	05010413          	addi	s0,sp,80
    80200fdc:	fca43423          	sd	a0,-56(s0)
    80200fe0:	fcb43023          	sd	a1,-64(s0)
    80200fe4:	00060793          	mv	a5,a2
    80200fe8:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200fec:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200ff0:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200ff4:	fc843783          	ld	a5,-56(s0)
    80200ff8:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200ffc:	0100006f          	j	8020100c <strtol+0x40>
        p++;
    80201000:	fd843783          	ld	a5,-40(s0)
    80201004:	00178793          	addi	a5,a5,1 # 5f5e001 <_skernel-0x7a2a1fff>
    80201008:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    8020100c:	fd843783          	ld	a5,-40(s0)
    80201010:	0007c783          	lbu	a5,0(a5)
    80201014:	0007879b          	sext.w	a5,a5
    80201018:	00078513          	mv	a0,a5
    8020101c:	f51ff0ef          	jal	ra,80200f6c <isspace>
    80201020:	00050793          	mv	a5,a0
    80201024:	fc079ee3          	bnez	a5,80201000 <strtol+0x34>
    }

    if (*p == '-') {
    80201028:	fd843783          	ld	a5,-40(s0)
    8020102c:	0007c783          	lbu	a5,0(a5)
    80201030:	00078713          	mv	a4,a5
    80201034:	02d00793          	li	a5,45
    80201038:	00f71e63          	bne	a4,a5,80201054 <strtol+0x88>
        neg = true;
    8020103c:	00100793          	li	a5,1
    80201040:	fef403a3          	sb	a5,-25(s0)
        p++;
    80201044:	fd843783          	ld	a5,-40(s0)
    80201048:	00178793          	addi	a5,a5,1
    8020104c:	fcf43c23          	sd	a5,-40(s0)
    80201050:	0240006f          	j	80201074 <strtol+0xa8>
    } else if (*p == '+') {
    80201054:	fd843783          	ld	a5,-40(s0)
    80201058:	0007c783          	lbu	a5,0(a5)
    8020105c:	00078713          	mv	a4,a5
    80201060:	02b00793          	li	a5,43
    80201064:	00f71863          	bne	a4,a5,80201074 <strtol+0xa8>
        p++;
    80201068:	fd843783          	ld	a5,-40(s0)
    8020106c:	00178793          	addi	a5,a5,1
    80201070:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80201074:	fbc42783          	lw	a5,-68(s0)
    80201078:	0007879b          	sext.w	a5,a5
    8020107c:	06079c63          	bnez	a5,802010f4 <strtol+0x128>
        if (*p == '0') {
    80201080:	fd843783          	ld	a5,-40(s0)
    80201084:	0007c783          	lbu	a5,0(a5)
    80201088:	00078713          	mv	a4,a5
    8020108c:	03000793          	li	a5,48
    80201090:	04f71e63          	bne	a4,a5,802010ec <strtol+0x120>
            p++;
    80201094:	fd843783          	ld	a5,-40(s0)
    80201098:	00178793          	addi	a5,a5,1
    8020109c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802010a0:	fd843783          	ld	a5,-40(s0)
    802010a4:	0007c783          	lbu	a5,0(a5)
    802010a8:	00078713          	mv	a4,a5
    802010ac:	07800793          	li	a5,120
    802010b0:	00f70c63          	beq	a4,a5,802010c8 <strtol+0xfc>
    802010b4:	fd843783          	ld	a5,-40(s0)
    802010b8:	0007c783          	lbu	a5,0(a5)
    802010bc:	00078713          	mv	a4,a5
    802010c0:	05800793          	li	a5,88
    802010c4:	00f71e63          	bne	a4,a5,802010e0 <strtol+0x114>
                base = 16;
    802010c8:	01000793          	li	a5,16
    802010cc:	faf42e23          	sw	a5,-68(s0)
                p++;
    802010d0:	fd843783          	ld	a5,-40(s0)
    802010d4:	00178793          	addi	a5,a5,1
    802010d8:	fcf43c23          	sd	a5,-40(s0)
    802010dc:	0180006f          	j	802010f4 <strtol+0x128>
            } else {
                base = 8;
    802010e0:	00800793          	li	a5,8
    802010e4:	faf42e23          	sw	a5,-68(s0)
    802010e8:	00c0006f          	j	802010f4 <strtol+0x128>
            }
        } else {
            base = 10;
    802010ec:	00a00793          	li	a5,10
    802010f0:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802010f4:	fd843783          	ld	a5,-40(s0)
    802010f8:	0007c783          	lbu	a5,0(a5)
    802010fc:	00078713          	mv	a4,a5
    80201100:	02f00793          	li	a5,47
    80201104:	02e7f863          	bgeu	a5,a4,80201134 <strtol+0x168>
    80201108:	fd843783          	ld	a5,-40(s0)
    8020110c:	0007c783          	lbu	a5,0(a5)
    80201110:	00078713          	mv	a4,a5
    80201114:	03900793          	li	a5,57
    80201118:	00e7ee63          	bltu	a5,a4,80201134 <strtol+0x168>
            digit = *p - '0';
    8020111c:	fd843783          	ld	a5,-40(s0)
    80201120:	0007c783          	lbu	a5,0(a5)
    80201124:	0007879b          	sext.w	a5,a5
    80201128:	fd07879b          	addiw	a5,a5,-48
    8020112c:	fcf42a23          	sw	a5,-44(s0)
    80201130:	0800006f          	j	802011b0 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80201134:	fd843783          	ld	a5,-40(s0)
    80201138:	0007c783          	lbu	a5,0(a5)
    8020113c:	00078713          	mv	a4,a5
    80201140:	06000793          	li	a5,96
    80201144:	02e7f863          	bgeu	a5,a4,80201174 <strtol+0x1a8>
    80201148:	fd843783          	ld	a5,-40(s0)
    8020114c:	0007c783          	lbu	a5,0(a5)
    80201150:	00078713          	mv	a4,a5
    80201154:	07a00793          	li	a5,122
    80201158:	00e7ee63          	bltu	a5,a4,80201174 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    8020115c:	fd843783          	ld	a5,-40(s0)
    80201160:	0007c783          	lbu	a5,0(a5)
    80201164:	0007879b          	sext.w	a5,a5
    80201168:	fa97879b          	addiw	a5,a5,-87
    8020116c:	fcf42a23          	sw	a5,-44(s0)
    80201170:	0400006f          	j	802011b0 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80201174:	fd843783          	ld	a5,-40(s0)
    80201178:	0007c783          	lbu	a5,0(a5)
    8020117c:	00078713          	mv	a4,a5
    80201180:	04000793          	li	a5,64
    80201184:	06e7f663          	bgeu	a5,a4,802011f0 <strtol+0x224>
    80201188:	fd843783          	ld	a5,-40(s0)
    8020118c:	0007c783          	lbu	a5,0(a5)
    80201190:	00078713          	mv	a4,a5
    80201194:	05a00793          	li	a5,90
    80201198:	04e7ec63          	bltu	a5,a4,802011f0 <strtol+0x224>
            digit = *p - ('A' - 10);
    8020119c:	fd843783          	ld	a5,-40(s0)
    802011a0:	0007c783          	lbu	a5,0(a5)
    802011a4:	0007879b          	sext.w	a5,a5
    802011a8:	fc97879b          	addiw	a5,a5,-55
    802011ac:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    802011b0:	fd442703          	lw	a4,-44(s0)
    802011b4:	fbc42783          	lw	a5,-68(s0)
    802011b8:	0007071b          	sext.w	a4,a4
    802011bc:	0007879b          	sext.w	a5,a5
    802011c0:	02f75663          	bge	a4,a5,802011ec <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
    802011c4:	fbc42703          	lw	a4,-68(s0)
    802011c8:	fe843783          	ld	a5,-24(s0)
    802011cc:	02f70733          	mul	a4,a4,a5
    802011d0:	fd442783          	lw	a5,-44(s0)
    802011d4:	00f707b3          	add	a5,a4,a5
    802011d8:	fef43423          	sd	a5,-24(s0)
        p++;
    802011dc:	fd843783          	ld	a5,-40(s0)
    802011e0:	00178793          	addi	a5,a5,1
    802011e4:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802011e8:	f0dff06f          	j	802010f4 <strtol+0x128>
            break;
    802011ec:	00000013          	nop
    }

    if (endptr) {
    802011f0:	fc043783          	ld	a5,-64(s0)
    802011f4:	00078863          	beqz	a5,80201204 <strtol+0x238>
        *endptr = (char *)p;
    802011f8:	fc043783          	ld	a5,-64(s0)
    802011fc:	fd843703          	ld	a4,-40(s0)
    80201200:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80201204:	fe744783          	lbu	a5,-25(s0)
    80201208:	0ff7f793          	andi	a5,a5,255
    8020120c:	00078863          	beqz	a5,8020121c <strtol+0x250>
    80201210:	fe843783          	ld	a5,-24(s0)
    80201214:	40f007b3          	neg	a5,a5
    80201218:	0080006f          	j	80201220 <strtol+0x254>
    8020121c:	fe843783          	ld	a5,-24(s0)
}
    80201220:	00078513          	mv	a0,a5
    80201224:	04813083          	ld	ra,72(sp)
    80201228:	04013403          	ld	s0,64(sp)
    8020122c:	05010113          	addi	sp,sp,80
    80201230:	00008067          	ret

0000000080201234 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80201234:	fd010113          	addi	sp,sp,-48
    80201238:	02113423          	sd	ra,40(sp)
    8020123c:	02813023          	sd	s0,32(sp)
    80201240:	03010413          	addi	s0,sp,48
    80201244:	fca43c23          	sd	a0,-40(s0)
    80201248:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    8020124c:	fd043783          	ld	a5,-48(s0)
    80201250:	00079863          	bnez	a5,80201260 <puts_wo_nl+0x2c>
        s = "(null)";
    80201254:	00001797          	auipc	a5,0x1
    80201258:	f7478793          	addi	a5,a5,-140 # 802021c8 <_srodata+0x1c8>
    8020125c:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80201260:	fd043783          	ld	a5,-48(s0)
    80201264:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80201268:	0240006f          	j	8020128c <puts_wo_nl+0x58>
        putch(*p++);
    8020126c:	fe843783          	ld	a5,-24(s0)
    80201270:	00178713          	addi	a4,a5,1
    80201274:	fee43423          	sd	a4,-24(s0)
    80201278:	0007c783          	lbu	a5,0(a5)
    8020127c:	0007879b          	sext.w	a5,a5
    80201280:	fd843703          	ld	a4,-40(s0)
    80201284:	00078513          	mv	a0,a5
    80201288:	000700e7          	jalr	a4
    while (*p) {
    8020128c:	fe843783          	ld	a5,-24(s0)
    80201290:	0007c783          	lbu	a5,0(a5)
    80201294:	fc079ce3          	bnez	a5,8020126c <puts_wo_nl+0x38>
    }
    return p - s;
    80201298:	fe843703          	ld	a4,-24(s0)
    8020129c:	fd043783          	ld	a5,-48(s0)
    802012a0:	40f707b3          	sub	a5,a4,a5
    802012a4:	0007879b          	sext.w	a5,a5
}
    802012a8:	00078513          	mv	a0,a5
    802012ac:	02813083          	ld	ra,40(sp)
    802012b0:	02013403          	ld	s0,32(sp)
    802012b4:	03010113          	addi	sp,sp,48
    802012b8:	00008067          	ret

00000000802012bc <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    802012bc:	f9010113          	addi	sp,sp,-112
    802012c0:	06113423          	sd	ra,104(sp)
    802012c4:	06813023          	sd	s0,96(sp)
    802012c8:	07010413          	addi	s0,sp,112
    802012cc:	faa43423          	sd	a0,-88(s0)
    802012d0:	fab43023          	sd	a1,-96(s0)
    802012d4:	00060793          	mv	a5,a2
    802012d8:	f8d43823          	sd	a3,-112(s0)
    802012dc:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802012e0:	f9f44783          	lbu	a5,-97(s0)
    802012e4:	0ff7f793          	andi	a5,a5,255
    802012e8:	02078663          	beqz	a5,80201314 <print_dec_int+0x58>
    802012ec:	fa043703          	ld	a4,-96(s0)
    802012f0:	fff00793          	li	a5,-1
    802012f4:	03f79793          	slli	a5,a5,0x3f
    802012f8:	00f71e63          	bne	a4,a5,80201314 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802012fc:	00001597          	auipc	a1,0x1
    80201300:	ed458593          	addi	a1,a1,-300 # 802021d0 <_srodata+0x1d0>
    80201304:	fa843503          	ld	a0,-88(s0)
    80201308:	f2dff0ef          	jal	ra,80201234 <puts_wo_nl>
    8020130c:	00050793          	mv	a5,a0
    80201310:	2980006f          	j	802015a8 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
    80201314:	f9043783          	ld	a5,-112(s0)
    80201318:	00c7a783          	lw	a5,12(a5)
    8020131c:	00079a63          	bnez	a5,80201330 <print_dec_int+0x74>
    80201320:	fa043783          	ld	a5,-96(s0)
    80201324:	00079663          	bnez	a5,80201330 <print_dec_int+0x74>
        return 0;
    80201328:	00000793          	li	a5,0
    8020132c:	27c0006f          	j	802015a8 <print_dec_int+0x2ec>
    }

    bool neg = false;
    80201330:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80201334:	f9f44783          	lbu	a5,-97(s0)
    80201338:	0ff7f793          	andi	a5,a5,255
    8020133c:	02078063          	beqz	a5,8020135c <print_dec_int+0xa0>
    80201340:	fa043783          	ld	a5,-96(s0)
    80201344:	0007dc63          	bgez	a5,8020135c <print_dec_int+0xa0>
        neg = true;
    80201348:	00100793          	li	a5,1
    8020134c:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80201350:	fa043783          	ld	a5,-96(s0)
    80201354:	40f007b3          	neg	a5,a5
    80201358:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    8020135c:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80201360:	f9f44783          	lbu	a5,-97(s0)
    80201364:	0ff7f793          	andi	a5,a5,255
    80201368:	02078863          	beqz	a5,80201398 <print_dec_int+0xdc>
    8020136c:	fef44783          	lbu	a5,-17(s0)
    80201370:	0ff7f793          	andi	a5,a5,255
    80201374:	00079e63          	bnez	a5,80201390 <print_dec_int+0xd4>
    80201378:	f9043783          	ld	a5,-112(s0)
    8020137c:	0057c783          	lbu	a5,5(a5)
    80201380:	00079863          	bnez	a5,80201390 <print_dec_int+0xd4>
    80201384:	f9043783          	ld	a5,-112(s0)
    80201388:	0047c783          	lbu	a5,4(a5)
    8020138c:	00078663          	beqz	a5,80201398 <print_dec_int+0xdc>
    80201390:	00100793          	li	a5,1
    80201394:	0080006f          	j	8020139c <print_dec_int+0xe0>
    80201398:	00000793          	li	a5,0
    8020139c:	fcf40ba3          	sb	a5,-41(s0)
    802013a0:	fd744783          	lbu	a5,-41(s0)
    802013a4:	0017f793          	andi	a5,a5,1
    802013a8:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    802013ac:	fa043703          	ld	a4,-96(s0)
    802013b0:	00a00793          	li	a5,10
    802013b4:	02f777b3          	remu	a5,a4,a5
    802013b8:	0ff7f713          	andi	a4,a5,255
    802013bc:	fe842783          	lw	a5,-24(s0)
    802013c0:	0017869b          	addiw	a3,a5,1
    802013c4:	fed42423          	sw	a3,-24(s0)
    802013c8:	0307071b          	addiw	a4,a4,48
    802013cc:	0ff77713          	andi	a4,a4,255
    802013d0:	ff040693          	addi	a3,s0,-16
    802013d4:	00f687b3          	add	a5,a3,a5
    802013d8:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    802013dc:	fa043703          	ld	a4,-96(s0)
    802013e0:	00a00793          	li	a5,10
    802013e4:	02f757b3          	divu	a5,a4,a5
    802013e8:	faf43023          	sd	a5,-96(s0)
    } while (num);
    802013ec:	fa043783          	ld	a5,-96(s0)
    802013f0:	fa079ee3          	bnez	a5,802013ac <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    802013f4:	f9043783          	ld	a5,-112(s0)
    802013f8:	00c7a783          	lw	a5,12(a5)
    802013fc:	00078713          	mv	a4,a5
    80201400:	fff00793          	li	a5,-1
    80201404:	02f71063          	bne	a4,a5,80201424 <print_dec_int+0x168>
    80201408:	f9043783          	ld	a5,-112(s0)
    8020140c:	0037c783          	lbu	a5,3(a5)
    80201410:	00078a63          	beqz	a5,80201424 <print_dec_int+0x168>
        flags->prec = flags->width;
    80201414:	f9043783          	ld	a5,-112(s0)
    80201418:	0087a703          	lw	a4,8(a5)
    8020141c:	f9043783          	ld	a5,-112(s0)
    80201420:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80201424:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201428:	f9043783          	ld	a5,-112(s0)
    8020142c:	0087a703          	lw	a4,8(a5)
    80201430:	fe842783          	lw	a5,-24(s0)
    80201434:	fcf42823          	sw	a5,-48(s0)
    80201438:	f9043783          	ld	a5,-112(s0)
    8020143c:	00c7a783          	lw	a5,12(a5)
    80201440:	fcf42623          	sw	a5,-52(s0)
    80201444:	fd042583          	lw	a1,-48(s0)
    80201448:	fcc42783          	lw	a5,-52(s0)
    8020144c:	0007861b          	sext.w	a2,a5
    80201450:	0005869b          	sext.w	a3,a1
    80201454:	00d65463          	bge	a2,a3,8020145c <print_dec_int+0x1a0>
    80201458:	00058793          	mv	a5,a1
    8020145c:	0007879b          	sext.w	a5,a5
    80201460:	40f707bb          	subw	a5,a4,a5
    80201464:	0007871b          	sext.w	a4,a5
    80201468:	fd744783          	lbu	a5,-41(s0)
    8020146c:	0007879b          	sext.w	a5,a5
    80201470:	40f707bb          	subw	a5,a4,a5
    80201474:	fef42023          	sw	a5,-32(s0)
    80201478:	0280006f          	j	802014a0 <print_dec_int+0x1e4>
        putch(' ');
    8020147c:	fa843783          	ld	a5,-88(s0)
    80201480:	02000513          	li	a0,32
    80201484:	000780e7          	jalr	a5
        ++written;
    80201488:	fe442783          	lw	a5,-28(s0)
    8020148c:	0017879b          	addiw	a5,a5,1
    80201490:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201494:	fe042783          	lw	a5,-32(s0)
    80201498:	fff7879b          	addiw	a5,a5,-1
    8020149c:	fef42023          	sw	a5,-32(s0)
    802014a0:	fe042783          	lw	a5,-32(s0)
    802014a4:	0007879b          	sext.w	a5,a5
    802014a8:	fcf04ae3          	bgtz	a5,8020147c <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
    802014ac:	fd744783          	lbu	a5,-41(s0)
    802014b0:	0ff7f793          	andi	a5,a5,255
    802014b4:	04078463          	beqz	a5,802014fc <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    802014b8:	fef44783          	lbu	a5,-17(s0)
    802014bc:	0ff7f793          	andi	a5,a5,255
    802014c0:	00078663          	beqz	a5,802014cc <print_dec_int+0x210>
    802014c4:	02d00793          	li	a5,45
    802014c8:	01c0006f          	j	802014e4 <print_dec_int+0x228>
    802014cc:	f9043783          	ld	a5,-112(s0)
    802014d0:	0057c783          	lbu	a5,5(a5)
    802014d4:	00078663          	beqz	a5,802014e0 <print_dec_int+0x224>
    802014d8:	02b00793          	li	a5,43
    802014dc:	0080006f          	j	802014e4 <print_dec_int+0x228>
    802014e0:	02000793          	li	a5,32
    802014e4:	fa843703          	ld	a4,-88(s0)
    802014e8:	00078513          	mv	a0,a5
    802014ec:	000700e7          	jalr	a4
        ++written;
    802014f0:	fe442783          	lw	a5,-28(s0)
    802014f4:	0017879b          	addiw	a5,a5,1
    802014f8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802014fc:	fe842783          	lw	a5,-24(s0)
    80201500:	fcf42e23          	sw	a5,-36(s0)
    80201504:	0280006f          	j	8020152c <print_dec_int+0x270>
        putch('0');
    80201508:	fa843783          	ld	a5,-88(s0)
    8020150c:	03000513          	li	a0,48
    80201510:	000780e7          	jalr	a5
        ++written;
    80201514:	fe442783          	lw	a5,-28(s0)
    80201518:	0017879b          	addiw	a5,a5,1
    8020151c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80201520:	fdc42783          	lw	a5,-36(s0)
    80201524:	0017879b          	addiw	a5,a5,1
    80201528:	fcf42e23          	sw	a5,-36(s0)
    8020152c:	f9043783          	ld	a5,-112(s0)
    80201530:	00c7a703          	lw	a4,12(a5)
    80201534:	fd744783          	lbu	a5,-41(s0)
    80201538:	0007879b          	sext.w	a5,a5
    8020153c:	40f707bb          	subw	a5,a4,a5
    80201540:	0007871b          	sext.w	a4,a5
    80201544:	fdc42783          	lw	a5,-36(s0)
    80201548:	0007879b          	sext.w	a5,a5
    8020154c:	fae7cee3          	blt	a5,a4,80201508 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201550:	fe842783          	lw	a5,-24(s0)
    80201554:	fff7879b          	addiw	a5,a5,-1
    80201558:	fcf42c23          	sw	a5,-40(s0)
    8020155c:	03c0006f          	j	80201598 <print_dec_int+0x2dc>
        putch(buf[i]);
    80201560:	fd842783          	lw	a5,-40(s0)
    80201564:	ff040713          	addi	a4,s0,-16
    80201568:	00f707b3          	add	a5,a4,a5
    8020156c:	fc87c783          	lbu	a5,-56(a5)
    80201570:	0007879b          	sext.w	a5,a5
    80201574:	fa843703          	ld	a4,-88(s0)
    80201578:	00078513          	mv	a0,a5
    8020157c:	000700e7          	jalr	a4
        ++written;
    80201580:	fe442783          	lw	a5,-28(s0)
    80201584:	0017879b          	addiw	a5,a5,1
    80201588:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    8020158c:	fd842783          	lw	a5,-40(s0)
    80201590:	fff7879b          	addiw	a5,a5,-1
    80201594:	fcf42c23          	sw	a5,-40(s0)
    80201598:	fd842783          	lw	a5,-40(s0)
    8020159c:	0007879b          	sext.w	a5,a5
    802015a0:	fc07d0e3          	bgez	a5,80201560 <print_dec_int+0x2a4>
    }

    return written;
    802015a4:	fe442783          	lw	a5,-28(s0)
}
    802015a8:	00078513          	mv	a0,a5
    802015ac:	06813083          	ld	ra,104(sp)
    802015b0:	06013403          	ld	s0,96(sp)
    802015b4:	07010113          	addi	sp,sp,112
    802015b8:	00008067          	ret

00000000802015bc <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    802015bc:	f4010113          	addi	sp,sp,-192
    802015c0:	0a113c23          	sd	ra,184(sp)
    802015c4:	0a813823          	sd	s0,176(sp)
    802015c8:	0c010413          	addi	s0,sp,192
    802015cc:	f4a43c23          	sd	a0,-168(s0)
    802015d0:	f4b43823          	sd	a1,-176(s0)
    802015d4:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    802015d8:	f8043023          	sd	zero,-128(s0)
    802015dc:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    802015e0:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    802015e4:	7a40006f          	j	80201d88 <vprintfmt+0x7cc>
        if (flags.in_format) {
    802015e8:	f8044783          	lbu	a5,-128(s0)
    802015ec:	72078e63          	beqz	a5,80201d28 <vprintfmt+0x76c>
            if (*fmt == '#') {
    802015f0:	f5043783          	ld	a5,-176(s0)
    802015f4:	0007c783          	lbu	a5,0(a5)
    802015f8:	00078713          	mv	a4,a5
    802015fc:	02300793          	li	a5,35
    80201600:	00f71863          	bne	a4,a5,80201610 <vprintfmt+0x54>
                flags.sharpflag = true;
    80201604:	00100793          	li	a5,1
    80201608:	f8f40123          	sb	a5,-126(s0)
    8020160c:	7700006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80201610:	f5043783          	ld	a5,-176(s0)
    80201614:	0007c783          	lbu	a5,0(a5)
    80201618:	00078713          	mv	a4,a5
    8020161c:	03000793          	li	a5,48
    80201620:	00f71863          	bne	a4,a5,80201630 <vprintfmt+0x74>
                flags.zeroflag = true;
    80201624:	00100793          	li	a5,1
    80201628:	f8f401a3          	sb	a5,-125(s0)
    8020162c:	7500006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80201630:	f5043783          	ld	a5,-176(s0)
    80201634:	0007c783          	lbu	a5,0(a5)
    80201638:	00078713          	mv	a4,a5
    8020163c:	06c00793          	li	a5,108
    80201640:	04f70063          	beq	a4,a5,80201680 <vprintfmt+0xc4>
    80201644:	f5043783          	ld	a5,-176(s0)
    80201648:	0007c783          	lbu	a5,0(a5)
    8020164c:	00078713          	mv	a4,a5
    80201650:	07a00793          	li	a5,122
    80201654:	02f70663          	beq	a4,a5,80201680 <vprintfmt+0xc4>
    80201658:	f5043783          	ld	a5,-176(s0)
    8020165c:	0007c783          	lbu	a5,0(a5)
    80201660:	00078713          	mv	a4,a5
    80201664:	07400793          	li	a5,116
    80201668:	00f70c63          	beq	a4,a5,80201680 <vprintfmt+0xc4>
    8020166c:	f5043783          	ld	a5,-176(s0)
    80201670:	0007c783          	lbu	a5,0(a5)
    80201674:	00078713          	mv	a4,a5
    80201678:	06a00793          	li	a5,106
    8020167c:	00f71863          	bne	a4,a5,8020168c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201680:	00100793          	li	a5,1
    80201684:	f8f400a3          	sb	a5,-127(s0)
    80201688:	6f40006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    8020168c:	f5043783          	ld	a5,-176(s0)
    80201690:	0007c783          	lbu	a5,0(a5)
    80201694:	00078713          	mv	a4,a5
    80201698:	02b00793          	li	a5,43
    8020169c:	00f71863          	bne	a4,a5,802016ac <vprintfmt+0xf0>
                flags.sign = true;
    802016a0:	00100793          	li	a5,1
    802016a4:	f8f402a3          	sb	a5,-123(s0)
    802016a8:	6d40006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    802016ac:	f5043783          	ld	a5,-176(s0)
    802016b0:	0007c783          	lbu	a5,0(a5)
    802016b4:	00078713          	mv	a4,a5
    802016b8:	02000793          	li	a5,32
    802016bc:	00f71863          	bne	a4,a5,802016cc <vprintfmt+0x110>
                flags.spaceflag = true;
    802016c0:	00100793          	li	a5,1
    802016c4:	f8f40223          	sb	a5,-124(s0)
    802016c8:	6b40006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    802016cc:	f5043783          	ld	a5,-176(s0)
    802016d0:	0007c783          	lbu	a5,0(a5)
    802016d4:	00078713          	mv	a4,a5
    802016d8:	02a00793          	li	a5,42
    802016dc:	00f71e63          	bne	a4,a5,802016f8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    802016e0:	f4843783          	ld	a5,-184(s0)
    802016e4:	00878713          	addi	a4,a5,8
    802016e8:	f4e43423          	sd	a4,-184(s0)
    802016ec:	0007a783          	lw	a5,0(a5)
    802016f0:	f8f42423          	sw	a5,-120(s0)
    802016f4:	6880006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    802016f8:	f5043783          	ld	a5,-176(s0)
    802016fc:	0007c783          	lbu	a5,0(a5)
    80201700:	00078713          	mv	a4,a5
    80201704:	03000793          	li	a5,48
    80201708:	04e7f663          	bgeu	a5,a4,80201754 <vprintfmt+0x198>
    8020170c:	f5043783          	ld	a5,-176(s0)
    80201710:	0007c783          	lbu	a5,0(a5)
    80201714:	00078713          	mv	a4,a5
    80201718:	03900793          	li	a5,57
    8020171c:	02e7ec63          	bltu	a5,a4,80201754 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80201720:	f5043783          	ld	a5,-176(s0)
    80201724:	f5040713          	addi	a4,s0,-176
    80201728:	00a00613          	li	a2,10
    8020172c:	00070593          	mv	a1,a4
    80201730:	00078513          	mv	a0,a5
    80201734:	899ff0ef          	jal	ra,80200fcc <strtol>
    80201738:	00050793          	mv	a5,a0
    8020173c:	0007879b          	sext.w	a5,a5
    80201740:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80201744:	f5043783          	ld	a5,-176(s0)
    80201748:	fff78793          	addi	a5,a5,-1
    8020174c:	f4f43823          	sd	a5,-176(s0)
    80201750:	62c0006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201754:	f5043783          	ld	a5,-176(s0)
    80201758:	0007c783          	lbu	a5,0(a5)
    8020175c:	00078713          	mv	a4,a5
    80201760:	02e00793          	li	a5,46
    80201764:	06f71863          	bne	a4,a5,802017d4 <vprintfmt+0x218>
                fmt++;
    80201768:	f5043783          	ld	a5,-176(s0)
    8020176c:	00178793          	addi	a5,a5,1
    80201770:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201774:	f5043783          	ld	a5,-176(s0)
    80201778:	0007c783          	lbu	a5,0(a5)
    8020177c:	00078713          	mv	a4,a5
    80201780:	02a00793          	li	a5,42
    80201784:	00f71e63          	bne	a4,a5,802017a0 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80201788:	f4843783          	ld	a5,-184(s0)
    8020178c:	00878713          	addi	a4,a5,8
    80201790:	f4e43423          	sd	a4,-184(s0)
    80201794:	0007a783          	lw	a5,0(a5)
    80201798:	f8f42623          	sw	a5,-116(s0)
    8020179c:	5e00006f          	j	80201d7c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    802017a0:	f5043783          	ld	a5,-176(s0)
    802017a4:	f5040713          	addi	a4,s0,-176
    802017a8:	00a00613          	li	a2,10
    802017ac:	00070593          	mv	a1,a4
    802017b0:	00078513          	mv	a0,a5
    802017b4:	819ff0ef          	jal	ra,80200fcc <strtol>
    802017b8:	00050793          	mv	a5,a0
    802017bc:	0007879b          	sext.w	a5,a5
    802017c0:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    802017c4:	f5043783          	ld	a5,-176(s0)
    802017c8:	fff78793          	addi	a5,a5,-1
    802017cc:	f4f43823          	sd	a5,-176(s0)
    802017d0:	5ac0006f          	j	80201d7c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802017d4:	f5043783          	ld	a5,-176(s0)
    802017d8:	0007c783          	lbu	a5,0(a5)
    802017dc:	00078713          	mv	a4,a5
    802017e0:	07800793          	li	a5,120
    802017e4:	02f70663          	beq	a4,a5,80201810 <vprintfmt+0x254>
    802017e8:	f5043783          	ld	a5,-176(s0)
    802017ec:	0007c783          	lbu	a5,0(a5)
    802017f0:	00078713          	mv	a4,a5
    802017f4:	05800793          	li	a5,88
    802017f8:	00f70c63          	beq	a4,a5,80201810 <vprintfmt+0x254>
    802017fc:	f5043783          	ld	a5,-176(s0)
    80201800:	0007c783          	lbu	a5,0(a5)
    80201804:	00078713          	mv	a4,a5
    80201808:	07000793          	li	a5,112
    8020180c:	2ef71e63          	bne	a4,a5,80201b08 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
    80201810:	f5043783          	ld	a5,-176(s0)
    80201814:	0007c783          	lbu	a5,0(a5)
    80201818:	00078713          	mv	a4,a5
    8020181c:	07000793          	li	a5,112
    80201820:	00f70663          	beq	a4,a5,8020182c <vprintfmt+0x270>
    80201824:	f8144783          	lbu	a5,-127(s0)
    80201828:	00078663          	beqz	a5,80201834 <vprintfmt+0x278>
    8020182c:	00100793          	li	a5,1
    80201830:	0080006f          	j	80201838 <vprintfmt+0x27c>
    80201834:	00000793          	li	a5,0
    80201838:	faf403a3          	sb	a5,-89(s0)
    8020183c:	fa744783          	lbu	a5,-89(s0)
    80201840:	0017f793          	andi	a5,a5,1
    80201844:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80201848:	fa744783          	lbu	a5,-89(s0)
    8020184c:	0ff7f793          	andi	a5,a5,255
    80201850:	00078c63          	beqz	a5,80201868 <vprintfmt+0x2ac>
    80201854:	f4843783          	ld	a5,-184(s0)
    80201858:	00878713          	addi	a4,a5,8
    8020185c:	f4e43423          	sd	a4,-184(s0)
    80201860:	0007b783          	ld	a5,0(a5)
    80201864:	01c0006f          	j	80201880 <vprintfmt+0x2c4>
    80201868:	f4843783          	ld	a5,-184(s0)
    8020186c:	00878713          	addi	a4,a5,8
    80201870:	f4e43423          	sd	a4,-184(s0)
    80201874:	0007a783          	lw	a5,0(a5)
    80201878:	02079793          	slli	a5,a5,0x20
    8020187c:	0207d793          	srli	a5,a5,0x20
    80201880:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201884:	f8c42783          	lw	a5,-116(s0)
    80201888:	02079463          	bnez	a5,802018b0 <vprintfmt+0x2f4>
    8020188c:	fe043783          	ld	a5,-32(s0)
    80201890:	02079063          	bnez	a5,802018b0 <vprintfmt+0x2f4>
    80201894:	f5043783          	ld	a5,-176(s0)
    80201898:	0007c783          	lbu	a5,0(a5)
    8020189c:	00078713          	mv	a4,a5
    802018a0:	07000793          	li	a5,112
    802018a4:	00f70663          	beq	a4,a5,802018b0 <vprintfmt+0x2f4>
                    flags.in_format = false;
    802018a8:	f8040023          	sb	zero,-128(s0)
    802018ac:	4d00006f          	j	80201d7c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    802018b0:	f5043783          	ld	a5,-176(s0)
    802018b4:	0007c783          	lbu	a5,0(a5)
    802018b8:	00078713          	mv	a4,a5
    802018bc:	07000793          	li	a5,112
    802018c0:	00f70a63          	beq	a4,a5,802018d4 <vprintfmt+0x318>
    802018c4:	f8244783          	lbu	a5,-126(s0)
    802018c8:	00078a63          	beqz	a5,802018dc <vprintfmt+0x320>
    802018cc:	fe043783          	ld	a5,-32(s0)
    802018d0:	00078663          	beqz	a5,802018dc <vprintfmt+0x320>
    802018d4:	00100793          	li	a5,1
    802018d8:	0080006f          	j	802018e0 <vprintfmt+0x324>
    802018dc:	00000793          	li	a5,0
    802018e0:	faf40323          	sb	a5,-90(s0)
    802018e4:	fa644783          	lbu	a5,-90(s0)
    802018e8:	0017f793          	andi	a5,a5,1
    802018ec:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    802018f0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    802018f4:	f5043783          	ld	a5,-176(s0)
    802018f8:	0007c783          	lbu	a5,0(a5)
    802018fc:	00078713          	mv	a4,a5
    80201900:	05800793          	li	a5,88
    80201904:	00f71863          	bne	a4,a5,80201914 <vprintfmt+0x358>
    80201908:	00001797          	auipc	a5,0x1
    8020190c:	8e078793          	addi	a5,a5,-1824 # 802021e8 <upperxdigits.1101>
    80201910:	00c0006f          	j	8020191c <vprintfmt+0x360>
    80201914:	00001797          	auipc	a5,0x1
    80201918:	8ec78793          	addi	a5,a5,-1812 # 80202200 <lowerxdigits.1100>
    8020191c:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201920:	fe043783          	ld	a5,-32(s0)
    80201924:	00f7f793          	andi	a5,a5,15
    80201928:	f9843703          	ld	a4,-104(s0)
    8020192c:	00f70733          	add	a4,a4,a5
    80201930:	fdc42783          	lw	a5,-36(s0)
    80201934:	0017869b          	addiw	a3,a5,1
    80201938:	fcd42e23          	sw	a3,-36(s0)
    8020193c:	00074703          	lbu	a4,0(a4)
    80201940:	ff040693          	addi	a3,s0,-16
    80201944:	00f687b3          	add	a5,a3,a5
    80201948:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    8020194c:	fe043783          	ld	a5,-32(s0)
    80201950:	0047d793          	srli	a5,a5,0x4
    80201954:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201958:	fe043783          	ld	a5,-32(s0)
    8020195c:	fc0792e3          	bnez	a5,80201920 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201960:	f8c42783          	lw	a5,-116(s0)
    80201964:	00078713          	mv	a4,a5
    80201968:	fff00793          	li	a5,-1
    8020196c:	02f71663          	bne	a4,a5,80201998 <vprintfmt+0x3dc>
    80201970:	f8344783          	lbu	a5,-125(s0)
    80201974:	02078263          	beqz	a5,80201998 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201978:	f8842703          	lw	a4,-120(s0)
    8020197c:	fa644783          	lbu	a5,-90(s0)
    80201980:	0007879b          	sext.w	a5,a5
    80201984:	0017979b          	slliw	a5,a5,0x1
    80201988:	0007879b          	sext.w	a5,a5
    8020198c:	40f707bb          	subw	a5,a4,a5
    80201990:	0007879b          	sext.w	a5,a5
    80201994:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201998:	f8842703          	lw	a4,-120(s0)
    8020199c:	fa644783          	lbu	a5,-90(s0)
    802019a0:	0007879b          	sext.w	a5,a5
    802019a4:	0017979b          	slliw	a5,a5,0x1
    802019a8:	0007879b          	sext.w	a5,a5
    802019ac:	40f707bb          	subw	a5,a4,a5
    802019b0:	0007871b          	sext.w	a4,a5
    802019b4:	fdc42783          	lw	a5,-36(s0)
    802019b8:	f8f42a23          	sw	a5,-108(s0)
    802019bc:	f8c42783          	lw	a5,-116(s0)
    802019c0:	f8f42823          	sw	a5,-112(s0)
    802019c4:	f9442583          	lw	a1,-108(s0)
    802019c8:	f9042783          	lw	a5,-112(s0)
    802019cc:	0007861b          	sext.w	a2,a5
    802019d0:	0005869b          	sext.w	a3,a1
    802019d4:	00d65463          	bge	a2,a3,802019dc <vprintfmt+0x420>
    802019d8:	00058793          	mv	a5,a1
    802019dc:	0007879b          	sext.w	a5,a5
    802019e0:	40f707bb          	subw	a5,a4,a5
    802019e4:	fcf42c23          	sw	a5,-40(s0)
    802019e8:	0280006f          	j	80201a10 <vprintfmt+0x454>
                    putch(' ');
    802019ec:	f5843783          	ld	a5,-168(s0)
    802019f0:	02000513          	li	a0,32
    802019f4:	000780e7          	jalr	a5
                    ++written;
    802019f8:	fec42783          	lw	a5,-20(s0)
    802019fc:	0017879b          	addiw	a5,a5,1
    80201a00:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201a04:	fd842783          	lw	a5,-40(s0)
    80201a08:	fff7879b          	addiw	a5,a5,-1
    80201a0c:	fcf42c23          	sw	a5,-40(s0)
    80201a10:	fd842783          	lw	a5,-40(s0)
    80201a14:	0007879b          	sext.w	a5,a5
    80201a18:	fcf04ae3          	bgtz	a5,802019ec <vprintfmt+0x430>
                }

                if (prefix) {
    80201a1c:	fa644783          	lbu	a5,-90(s0)
    80201a20:	0ff7f793          	andi	a5,a5,255
    80201a24:	04078463          	beqz	a5,80201a6c <vprintfmt+0x4b0>
                    putch('0');
    80201a28:	f5843783          	ld	a5,-168(s0)
    80201a2c:	03000513          	li	a0,48
    80201a30:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201a34:	f5043783          	ld	a5,-176(s0)
    80201a38:	0007c783          	lbu	a5,0(a5)
    80201a3c:	00078713          	mv	a4,a5
    80201a40:	05800793          	li	a5,88
    80201a44:	00f71663          	bne	a4,a5,80201a50 <vprintfmt+0x494>
    80201a48:	05800793          	li	a5,88
    80201a4c:	0080006f          	j	80201a54 <vprintfmt+0x498>
    80201a50:	07800793          	li	a5,120
    80201a54:	f5843703          	ld	a4,-168(s0)
    80201a58:	00078513          	mv	a0,a5
    80201a5c:	000700e7          	jalr	a4
                    written += 2;
    80201a60:	fec42783          	lw	a5,-20(s0)
    80201a64:	0027879b          	addiw	a5,a5,2
    80201a68:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201a6c:	fdc42783          	lw	a5,-36(s0)
    80201a70:	fcf42a23          	sw	a5,-44(s0)
    80201a74:	0280006f          	j	80201a9c <vprintfmt+0x4e0>
                    putch('0');
    80201a78:	f5843783          	ld	a5,-168(s0)
    80201a7c:	03000513          	li	a0,48
    80201a80:	000780e7          	jalr	a5
                    ++written;
    80201a84:	fec42783          	lw	a5,-20(s0)
    80201a88:	0017879b          	addiw	a5,a5,1
    80201a8c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201a90:	fd442783          	lw	a5,-44(s0)
    80201a94:	0017879b          	addiw	a5,a5,1
    80201a98:	fcf42a23          	sw	a5,-44(s0)
    80201a9c:	f8c42703          	lw	a4,-116(s0)
    80201aa0:	fd442783          	lw	a5,-44(s0)
    80201aa4:	0007879b          	sext.w	a5,a5
    80201aa8:	fce7c8e3          	blt	a5,a4,80201a78 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201aac:	fdc42783          	lw	a5,-36(s0)
    80201ab0:	fff7879b          	addiw	a5,a5,-1
    80201ab4:	fcf42823          	sw	a5,-48(s0)
    80201ab8:	03c0006f          	j	80201af4 <vprintfmt+0x538>
                    putch(buf[i]);
    80201abc:	fd042783          	lw	a5,-48(s0)
    80201ac0:	ff040713          	addi	a4,s0,-16
    80201ac4:	00f707b3          	add	a5,a4,a5
    80201ac8:	f807c783          	lbu	a5,-128(a5)
    80201acc:	0007879b          	sext.w	a5,a5
    80201ad0:	f5843703          	ld	a4,-168(s0)
    80201ad4:	00078513          	mv	a0,a5
    80201ad8:	000700e7          	jalr	a4
                    ++written;
    80201adc:	fec42783          	lw	a5,-20(s0)
    80201ae0:	0017879b          	addiw	a5,a5,1
    80201ae4:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201ae8:	fd042783          	lw	a5,-48(s0)
    80201aec:	fff7879b          	addiw	a5,a5,-1
    80201af0:	fcf42823          	sw	a5,-48(s0)
    80201af4:	fd042783          	lw	a5,-48(s0)
    80201af8:	0007879b          	sext.w	a5,a5
    80201afc:	fc07d0e3          	bgez	a5,80201abc <vprintfmt+0x500>
                }

                flags.in_format = false;
    80201b00:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201b04:	2780006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201b08:	f5043783          	ld	a5,-176(s0)
    80201b0c:	0007c783          	lbu	a5,0(a5)
    80201b10:	00078713          	mv	a4,a5
    80201b14:	06400793          	li	a5,100
    80201b18:	02f70663          	beq	a4,a5,80201b44 <vprintfmt+0x588>
    80201b1c:	f5043783          	ld	a5,-176(s0)
    80201b20:	0007c783          	lbu	a5,0(a5)
    80201b24:	00078713          	mv	a4,a5
    80201b28:	06900793          	li	a5,105
    80201b2c:	00f70c63          	beq	a4,a5,80201b44 <vprintfmt+0x588>
    80201b30:	f5043783          	ld	a5,-176(s0)
    80201b34:	0007c783          	lbu	a5,0(a5)
    80201b38:	00078713          	mv	a4,a5
    80201b3c:	07500793          	li	a5,117
    80201b40:	08f71263          	bne	a4,a5,80201bc4 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201b44:	f8144783          	lbu	a5,-127(s0)
    80201b48:	00078c63          	beqz	a5,80201b60 <vprintfmt+0x5a4>
    80201b4c:	f4843783          	ld	a5,-184(s0)
    80201b50:	00878713          	addi	a4,a5,8
    80201b54:	f4e43423          	sd	a4,-184(s0)
    80201b58:	0007b783          	ld	a5,0(a5)
    80201b5c:	0140006f          	j	80201b70 <vprintfmt+0x5b4>
    80201b60:	f4843783          	ld	a5,-184(s0)
    80201b64:	00878713          	addi	a4,a5,8
    80201b68:	f4e43423          	sd	a4,-184(s0)
    80201b6c:	0007a783          	lw	a5,0(a5)
    80201b70:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201b74:	fa843583          	ld	a1,-88(s0)
    80201b78:	f5043783          	ld	a5,-176(s0)
    80201b7c:	0007c783          	lbu	a5,0(a5)
    80201b80:	0007871b          	sext.w	a4,a5
    80201b84:	07500793          	li	a5,117
    80201b88:	40f707b3          	sub	a5,a4,a5
    80201b8c:	00f037b3          	snez	a5,a5
    80201b90:	0ff7f793          	andi	a5,a5,255
    80201b94:	f8040713          	addi	a4,s0,-128
    80201b98:	00070693          	mv	a3,a4
    80201b9c:	00078613          	mv	a2,a5
    80201ba0:	f5843503          	ld	a0,-168(s0)
    80201ba4:	f18ff0ef          	jal	ra,802012bc <print_dec_int>
    80201ba8:	00050793          	mv	a5,a0
    80201bac:	00078713          	mv	a4,a5
    80201bb0:	fec42783          	lw	a5,-20(s0)
    80201bb4:	00e787bb          	addw	a5,a5,a4
    80201bb8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201bbc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201bc0:	1bc0006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201bc4:	f5043783          	ld	a5,-176(s0)
    80201bc8:	0007c783          	lbu	a5,0(a5)
    80201bcc:	00078713          	mv	a4,a5
    80201bd0:	06e00793          	li	a5,110
    80201bd4:	04f71c63          	bne	a4,a5,80201c2c <vprintfmt+0x670>
                if (flags.longflag) {
    80201bd8:	f8144783          	lbu	a5,-127(s0)
    80201bdc:	02078463          	beqz	a5,80201c04 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
    80201be0:	f4843783          	ld	a5,-184(s0)
    80201be4:	00878713          	addi	a4,a5,8
    80201be8:	f4e43423          	sd	a4,-184(s0)
    80201bec:	0007b783          	ld	a5,0(a5)
    80201bf0:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201bf4:	fec42703          	lw	a4,-20(s0)
    80201bf8:	fb043783          	ld	a5,-80(s0)
    80201bfc:	00e7b023          	sd	a4,0(a5)
    80201c00:	0240006f          	j	80201c24 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
    80201c04:	f4843783          	ld	a5,-184(s0)
    80201c08:	00878713          	addi	a4,a5,8
    80201c0c:	f4e43423          	sd	a4,-184(s0)
    80201c10:	0007b783          	ld	a5,0(a5)
    80201c14:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201c18:	fb843783          	ld	a5,-72(s0)
    80201c1c:	fec42703          	lw	a4,-20(s0)
    80201c20:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201c24:	f8040023          	sb	zero,-128(s0)
    80201c28:	1540006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201c2c:	f5043783          	ld	a5,-176(s0)
    80201c30:	0007c783          	lbu	a5,0(a5)
    80201c34:	00078713          	mv	a4,a5
    80201c38:	07300793          	li	a5,115
    80201c3c:	04f71063          	bne	a4,a5,80201c7c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201c40:	f4843783          	ld	a5,-184(s0)
    80201c44:	00878713          	addi	a4,a5,8
    80201c48:	f4e43423          	sd	a4,-184(s0)
    80201c4c:	0007b783          	ld	a5,0(a5)
    80201c50:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201c54:	fc043583          	ld	a1,-64(s0)
    80201c58:	f5843503          	ld	a0,-168(s0)
    80201c5c:	dd8ff0ef          	jal	ra,80201234 <puts_wo_nl>
    80201c60:	00050793          	mv	a5,a0
    80201c64:	00078713          	mv	a4,a5
    80201c68:	fec42783          	lw	a5,-20(s0)
    80201c6c:	00e787bb          	addw	a5,a5,a4
    80201c70:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201c74:	f8040023          	sb	zero,-128(s0)
    80201c78:	1040006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201c7c:	f5043783          	ld	a5,-176(s0)
    80201c80:	0007c783          	lbu	a5,0(a5)
    80201c84:	00078713          	mv	a4,a5
    80201c88:	06300793          	li	a5,99
    80201c8c:	02f71e63          	bne	a4,a5,80201cc8 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201c90:	f4843783          	ld	a5,-184(s0)
    80201c94:	00878713          	addi	a4,a5,8
    80201c98:	f4e43423          	sd	a4,-184(s0)
    80201c9c:	0007a783          	lw	a5,0(a5)
    80201ca0:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201ca4:	fcc42783          	lw	a5,-52(s0)
    80201ca8:	f5843703          	ld	a4,-168(s0)
    80201cac:	00078513          	mv	a0,a5
    80201cb0:	000700e7          	jalr	a4
                ++written;
    80201cb4:	fec42783          	lw	a5,-20(s0)
    80201cb8:	0017879b          	addiw	a5,a5,1
    80201cbc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201cc0:	f8040023          	sb	zero,-128(s0)
    80201cc4:	0b80006f          	j	80201d7c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201cc8:	f5043783          	ld	a5,-176(s0)
    80201ccc:	0007c783          	lbu	a5,0(a5)
    80201cd0:	00078713          	mv	a4,a5
    80201cd4:	02500793          	li	a5,37
    80201cd8:	02f71263          	bne	a4,a5,80201cfc <vprintfmt+0x740>
                putch('%');
    80201cdc:	f5843783          	ld	a5,-168(s0)
    80201ce0:	02500513          	li	a0,37
    80201ce4:	000780e7          	jalr	a5
                ++written;
    80201ce8:	fec42783          	lw	a5,-20(s0)
    80201cec:	0017879b          	addiw	a5,a5,1
    80201cf0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201cf4:	f8040023          	sb	zero,-128(s0)
    80201cf8:	0840006f          	j	80201d7c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201cfc:	f5043783          	ld	a5,-176(s0)
    80201d00:	0007c783          	lbu	a5,0(a5)
    80201d04:	0007879b          	sext.w	a5,a5
    80201d08:	f5843703          	ld	a4,-168(s0)
    80201d0c:	00078513          	mv	a0,a5
    80201d10:	000700e7          	jalr	a4
                ++written;
    80201d14:	fec42783          	lw	a5,-20(s0)
    80201d18:	0017879b          	addiw	a5,a5,1
    80201d1c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201d20:	f8040023          	sb	zero,-128(s0)
    80201d24:	0580006f          	j	80201d7c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201d28:	f5043783          	ld	a5,-176(s0)
    80201d2c:	0007c783          	lbu	a5,0(a5)
    80201d30:	00078713          	mv	a4,a5
    80201d34:	02500793          	li	a5,37
    80201d38:	02f71063          	bne	a4,a5,80201d58 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201d3c:	f8043023          	sd	zero,-128(s0)
    80201d40:	f8043423          	sd	zero,-120(s0)
    80201d44:	00100793          	li	a5,1
    80201d48:	f8f40023          	sb	a5,-128(s0)
    80201d4c:	fff00793          	li	a5,-1
    80201d50:	f8f42623          	sw	a5,-116(s0)
    80201d54:	0280006f          	j	80201d7c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201d58:	f5043783          	ld	a5,-176(s0)
    80201d5c:	0007c783          	lbu	a5,0(a5)
    80201d60:	0007879b          	sext.w	a5,a5
    80201d64:	f5843703          	ld	a4,-168(s0)
    80201d68:	00078513          	mv	a0,a5
    80201d6c:	000700e7          	jalr	a4
            ++written;
    80201d70:	fec42783          	lw	a5,-20(s0)
    80201d74:	0017879b          	addiw	a5,a5,1
    80201d78:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201d7c:	f5043783          	ld	a5,-176(s0)
    80201d80:	00178793          	addi	a5,a5,1
    80201d84:	f4f43823          	sd	a5,-176(s0)
    80201d88:	f5043783          	ld	a5,-176(s0)
    80201d8c:	0007c783          	lbu	a5,0(a5)
    80201d90:	84079ce3          	bnez	a5,802015e8 <vprintfmt+0x2c>
        }
    }

    return written;
    80201d94:	fec42783          	lw	a5,-20(s0)
}
    80201d98:	00078513          	mv	a0,a5
    80201d9c:	0b813083          	ld	ra,184(sp)
    80201da0:	0b013403          	ld	s0,176(sp)
    80201da4:	0c010113          	addi	sp,sp,192
    80201da8:	00008067          	ret

0000000080201dac <printk>:

int printk(const char* s, ...) {
    80201dac:	f9010113          	addi	sp,sp,-112
    80201db0:	02113423          	sd	ra,40(sp)
    80201db4:	02813023          	sd	s0,32(sp)
    80201db8:	03010413          	addi	s0,sp,48
    80201dbc:	fca43c23          	sd	a0,-40(s0)
    80201dc0:	00b43423          	sd	a1,8(s0)
    80201dc4:	00c43823          	sd	a2,16(s0)
    80201dc8:	00d43c23          	sd	a3,24(s0)
    80201dcc:	02e43023          	sd	a4,32(s0)
    80201dd0:	02f43423          	sd	a5,40(s0)
    80201dd4:	03043823          	sd	a6,48(s0)
    80201dd8:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201ddc:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201de0:	04040793          	addi	a5,s0,64
    80201de4:	fcf43823          	sd	a5,-48(s0)
    80201de8:	fd043783          	ld	a5,-48(s0)
    80201dec:	fc878793          	addi	a5,a5,-56
    80201df0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201df4:	fe043783          	ld	a5,-32(s0)
    80201df8:	00078613          	mv	a2,a5
    80201dfc:	fd843583          	ld	a1,-40(s0)
    80201e00:	fffff517          	auipc	a0,0xfffff
    80201e04:	12450513          	addi	a0,a0,292 # 80200f24 <putc>
    80201e08:	fb4ff0ef          	jal	ra,802015bc <vprintfmt>
    80201e0c:	00050793          	mv	a5,a0
    80201e10:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201e14:	fec42783          	lw	a5,-20(s0)
}
    80201e18:	00078513          	mv	a0,a5
    80201e1c:	02813083          	ld	ra,40(sp)
    80201e20:	02013403          	ld	s0,32(sp)
    80201e24:	07010113          	addi	sp,sp,112
    80201e28:	00008067          	ret

0000000080201e2c <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201e2c:	fe010113          	addi	sp,sp,-32
    80201e30:	00813c23          	sd	s0,24(sp)
    80201e34:	02010413          	addi	s0,sp,32
    80201e38:	00050793          	mv	a5,a0
    80201e3c:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201e40:	fec42783          	lw	a5,-20(s0)
    80201e44:	fff7879b          	addiw	a5,a5,-1
    80201e48:	0007879b          	sext.w	a5,a5
    80201e4c:	02079713          	slli	a4,a5,0x20
    80201e50:	02075713          	srli	a4,a4,0x20
    80201e54:	00003797          	auipc	a5,0x3
    80201e58:	1b478793          	addi	a5,a5,436 # 80205008 <seed>
    80201e5c:	00e7b023          	sd	a4,0(a5)
}
    80201e60:	00000013          	nop
    80201e64:	01813403          	ld	s0,24(sp)
    80201e68:	02010113          	addi	sp,sp,32
    80201e6c:	00008067          	ret

0000000080201e70 <rand>:

int rand(void) {
    80201e70:	ff010113          	addi	sp,sp,-16
    80201e74:	00813423          	sd	s0,8(sp)
    80201e78:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201e7c:	00003797          	auipc	a5,0x3
    80201e80:	18c78793          	addi	a5,a5,396 # 80205008 <seed>
    80201e84:	0007b703          	ld	a4,0(a5)
    80201e88:	00000797          	auipc	a5,0x0
    80201e8c:	39078793          	addi	a5,a5,912 # 80202218 <lowerxdigits.1100+0x18>
    80201e90:	0007b783          	ld	a5,0(a5)
    80201e94:	02f707b3          	mul	a5,a4,a5
    80201e98:	00178713          	addi	a4,a5,1
    80201e9c:	00003797          	auipc	a5,0x3
    80201ea0:	16c78793          	addi	a5,a5,364 # 80205008 <seed>
    80201ea4:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201ea8:	00003797          	auipc	a5,0x3
    80201eac:	16078793          	addi	a5,a5,352 # 80205008 <seed>
    80201eb0:	0007b783          	ld	a5,0(a5)
    80201eb4:	0217d793          	srli	a5,a5,0x21
    80201eb8:	0007879b          	sext.w	a5,a5
}
    80201ebc:	00078513          	mv	a0,a5
    80201ec0:	00813403          	ld	s0,8(sp)
    80201ec4:	01010113          	addi	sp,sp,16
    80201ec8:	00008067          	ret

0000000080201ecc <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201ecc:	fc010113          	addi	sp,sp,-64
    80201ed0:	02813c23          	sd	s0,56(sp)
    80201ed4:	04010413          	addi	s0,sp,64
    80201ed8:	fca43c23          	sd	a0,-40(s0)
    80201edc:	00058793          	mv	a5,a1
    80201ee0:	fcc43423          	sd	a2,-56(s0)
    80201ee4:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201ee8:	fd843783          	ld	a5,-40(s0)
    80201eec:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201ef0:	fe043423          	sd	zero,-24(s0)
    80201ef4:	0280006f          	j	80201f1c <memset+0x50>
        s[i] = c;
    80201ef8:	fe043703          	ld	a4,-32(s0)
    80201efc:	fe843783          	ld	a5,-24(s0)
    80201f00:	00f707b3          	add	a5,a4,a5
    80201f04:	fd442703          	lw	a4,-44(s0)
    80201f08:	0ff77713          	andi	a4,a4,255
    80201f0c:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201f10:	fe843783          	ld	a5,-24(s0)
    80201f14:	00178793          	addi	a5,a5,1
    80201f18:	fef43423          	sd	a5,-24(s0)
    80201f1c:	fe843703          	ld	a4,-24(s0)
    80201f20:	fc843783          	ld	a5,-56(s0)
    80201f24:	fcf76ae3          	bltu	a4,a5,80201ef8 <memset+0x2c>
    }
    return dest;
    80201f28:	fd843783          	ld	a5,-40(s0)
}
    80201f2c:	00078513          	mv	a0,a5
    80201f30:	03813403          	ld	s0,56(sp)
    80201f34:	04010113          	addi	sp,sp,64
    80201f38:	00008067          	ret
