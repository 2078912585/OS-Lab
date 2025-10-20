
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern sbi_set_timer
    .extern get_cycles
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶
    80200000:	00003117          	auipc	sp,0x3
    80200004:	02013103          	ld	sp,32(sp) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>
    
    # set stvec = _traps
    la t0,_traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0282b283          	ld	t0,40(t0) # 80203030 <_GLOBAL_OFFSET_TABLE_+0x28>
    csrw stvec,t0
    80200010:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
    80200014:	02000293          	li	t0,32
    csrs sie,t0
    80200018:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
    8020001c:	148000ef          	jal	ra,80200164 <get_cycles>
    li t0,10000000
    80200020:	009892b7          	lui	t0,0x989
    80200024:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
    80200028:	00550533          	add	a0,a0,t0
    call sbi_set_timer
    8020002c:	53c000ef          	jal	ra,80200568 <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
    80200030:	00200293          	li	t0,2
    csrs sstatus,t0
    80200034:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
    80200038:	7940006f          	j	802007cc <start_kernel>

000000008020003c <_traps>:
    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    addi sp,sp,-33*8   # 开辟栈空间
    8020003c:	ef810113          	addi	sp,sp,-264
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
    80200040:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)
    80200044:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)
    80200048:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)
    8020004c:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)
    80200050:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)
    80200054:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
    80200058:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
    8020005c:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)
    80200060:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)
    80200064:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)
    80200068:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
    8020006c:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
    80200070:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
    80200074:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
    80200078:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
    8020007c:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
    80200080:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
    80200084:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)
    80200088:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
    8020008c:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
    80200090:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
    80200094:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
    80200098:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
    8020009c:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
    802000a0:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
    802000a4:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
    802000a8:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
    802000ac:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)
    802000b0:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
    802000b4:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
    802000b8:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
    802000bc:	0ff13c23          	sd	t6,248(sp)
    csrr t0,sepc
    802000c0:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
    802000c4:	10513023          	sd	t0,256(sp)

    # call trap_handler
    csrr a0,scause
    802000c8:	14202573          	csrr	a0,scause
    csrr a1,sepc
    802000cc:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000d0:	668000ef          	jal	ra,80200738 <trap_handler>

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
    802000d4:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
    802000d8:	14129073          	csrw	sepc,t0

    ld x31,31*8(sp)
    802000dc:	0f813f83          	ld	t6,248(sp)
    ld x30,30*8(sp)
    802000e0:	0f013f03          	ld	t5,240(sp)
    ld x29,29*8(sp)
    802000e4:	0e813e83          	ld	t4,232(sp)
    ld x28,28*8(sp)
    802000e8:	0e013e03          	ld	t3,224(sp)
    ld x27,27*8(sp)
    802000ec:	0d813d83          	ld	s11,216(sp)
    ld x26,26*8(sp)
    802000f0:	0d013d03          	ld	s10,208(sp)
    ld x25,25*8(sp)
    802000f4:	0c813c83          	ld	s9,200(sp)
    ld x24,24*8(sp)
    802000f8:	0c013c03          	ld	s8,192(sp)
    ld x23,23*8(sp)
    802000fc:	0b813b83          	ld	s7,184(sp)
    ld x22,22*8(sp)
    80200100:	0b013b03          	ld	s6,176(sp)
    ld x21,21*8(sp)
    80200104:	0a813a83          	ld	s5,168(sp)
    ld x20,20*8(sp)
    80200108:	0a013a03          	ld	s4,160(sp)
    ld x19,19*8(sp)
    8020010c:	09813983          	ld	s3,152(sp)
    ld x18,18*8(sp)
    80200110:	09013903          	ld	s2,144(sp)
    ld x17,17*8(sp)
    80200114:	08813883          	ld	a7,136(sp)
    ld x16,16*8(sp)
    80200118:	08013803          	ld	a6,128(sp)
    ld x15,15*8(sp)
    8020011c:	07813783          	ld	a5,120(sp)
    ld x14,14*8(sp)
    80200120:	07013703          	ld	a4,112(sp)
    ld x13,13*8(sp)
    80200124:	06813683          	ld	a3,104(sp)
    ld x12,12*8(sp)
    80200128:	06013603          	ld	a2,96(sp)
    ld x11,11*8(sp)
    8020012c:	05813583          	ld	a1,88(sp)
    ld x10,10*8(sp)
    80200130:	05013503          	ld	a0,80(sp)
    ld x9,9*8(sp)
    80200134:	04813483          	ld	s1,72(sp)
    ld x8,8*8(sp)
    80200138:	04013403          	ld	s0,64(sp)
    ld x7,7*8(sp)
    8020013c:	03813383          	ld	t2,56(sp)
    ld x6,6*8(sp)
    80200140:	03013303          	ld	t1,48(sp)
    ld x5,5*8(sp)
    80200144:	02813283          	ld	t0,40(sp)
    ld x4,4*8(sp)
    80200148:	02013203          	ld	tp,32(sp)
    ld x3,3*8(sp)
    8020014c:	01813183          	ld	gp,24(sp)
    ld x1,1*8(sp)
    80200150:	00813083          	ld	ra,8(sp)
    ld x0,0*8(sp)
    80200154:	00013003          	ld	zero,0(sp)
    ld x2,2*8(sp)
    80200158:	01013103          	ld	sp,16(sp)
    addi sp,sp,33*8   # 释放栈空间
    8020015c:	10810113          	addi	sp,sp,264

    # return from trap
    80200160:	10200073          	sret

0000000080200164 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200164:	fe010113          	addi	sp,sp,-32
    80200168:	00813c23          	sd	s0,24(sp)
    8020016c:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
    80200170:	c01027f3          	rdtime	a5
    80200174:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
    80200178:	fe843783          	ld	a5,-24(s0)
}
    8020017c:	00078513          	mv	a0,a5
    80200180:	01813403          	ld	s0,24(sp)
    80200184:	02010113          	addi	sp,sp,32
    80200188:	00008067          	ret

000000008020018c <clock_set_next_event>:

void clock_set_next_event() {
    8020018c:	fe010113          	addi	sp,sp,-32
    80200190:	00113c23          	sd	ra,24(sp)
    80200194:	00813823          	sd	s0,16(sp)
    80200198:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    8020019c:	fc9ff0ef          	jal	ra,80200164 <get_cycles>
    802001a0:	00050713          	mv	a4,a0
    802001a4:	00003797          	auipc	a5,0x3
    802001a8:	e5c78793          	addi	a5,a5,-420 # 80203000 <TIMECLOCK>
    802001ac:	0007b783          	ld	a5,0(a5)
    802001b0:	00f707b3          	add	a5,a4,a5
    802001b4:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
    802001b8:	fe843503          	ld	a0,-24(s0)
    802001bc:	3ac000ef          	jal	ra,80200568 <sbi_set_timer>
    802001c0:	00000013          	nop
    802001c4:	01813083          	ld	ra,24(sp)
    802001c8:	01013403          	ld	s0,16(sp)
    802001cc:	02010113          	addi	sp,sp,32
    802001d0:	00008067          	ret

00000000802001d4 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    802001d4:	fe010113          	addi	sp,sp,-32
    802001d8:	00113c23          	sd	ra,24(sp)
    802001dc:	00813823          	sd	s0,16(sp)
    802001e0:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    802001e4:	00003797          	auipc	a5,0x3
    802001e8:	e2c7b783          	ld	a5,-468(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    802001ec:	0007b783          	ld	a5,0(a5)
    802001f0:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    802001f4:	fe843783          	ld	a5,-24(s0)
    802001f8:	0007b703          	ld	a4,0(a5)
    802001fc:	00003797          	auipc	a5,0x3
    80200200:	e147b783          	ld	a5,-492(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200204:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    80200208:	00001637          	lui	a2,0x1
    8020020c:	00000593          	li	a1,0
    80200210:	fe843503          	ld	a0,-24(s0)
    80200214:	5f0010ef          	jal	ra,80201804 <memset>
    return (void *)r;
    80200218:	fe843783          	ld	a5,-24(s0)
}
    8020021c:	00078513          	mv	a0,a5
    80200220:	01813083          	ld	ra,24(sp)
    80200224:	01013403          	ld	s0,16(sp)
    80200228:	02010113          	addi	sp,sp,32
    8020022c:	00008067          	ret

0000000080200230 <kfree>:

void kfree(void *addr) {
    80200230:	fd010113          	addi	sp,sp,-48
    80200234:	02113423          	sd	ra,40(sp)
    80200238:	02813023          	sd	s0,32(sp)
    8020023c:	03010413          	addi	s0,sp,48
    80200240:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    80200244:	fd843783          	ld	a5,-40(s0)
    80200248:	00078693          	mv	a3,a5
    8020024c:	fd840793          	addi	a5,s0,-40
    80200250:	fffff737          	lui	a4,0xfffff
    80200254:	00e6f733          	and	a4,a3,a4
    80200258:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    8020025c:	fd843783          	ld	a5,-40(s0)
    80200260:	00001637          	lui	a2,0x1
    80200264:	00000593          	li	a1,0
    80200268:	00078513          	mv	a0,a5
    8020026c:	598010ef          	jal	ra,80201804 <memset>

    r = (struct run *)addr;
    80200270:	fd843783          	ld	a5,-40(s0)
    80200274:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    80200278:	00003797          	auipc	a5,0x3
    8020027c:	d987b783          	ld	a5,-616(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200280:	0007b703          	ld	a4,0(a5)
    80200284:	fe843783          	ld	a5,-24(s0)
    80200288:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    8020028c:	00003797          	auipc	a5,0x3
    80200290:	d847b783          	ld	a5,-636(a5) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    80200294:	fe843703          	ld	a4,-24(s0)
    80200298:	00e7b023          	sd	a4,0(a5)

    return;
    8020029c:	00000013          	nop
}
    802002a0:	02813083          	ld	ra,40(sp)
    802002a4:	02013403          	ld	s0,32(sp)
    802002a8:	03010113          	addi	sp,sp,48
    802002ac:	00008067          	ret

00000000802002b0 <kfreerange>:

void kfreerange(char *start, char *end) {
    802002b0:	fd010113          	addi	sp,sp,-48
    802002b4:	02113423          	sd	ra,40(sp)
    802002b8:	02813023          	sd	s0,32(sp)
    802002bc:	03010413          	addi	s0,sp,48
    802002c0:	fca43c23          	sd	a0,-40(s0)
    802002c4:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    802002c8:	fd843703          	ld	a4,-40(s0)
    802002cc:	000017b7          	lui	a5,0x1
    802002d0:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    802002d4:	00f70733          	add	a4,a4,a5
    802002d8:	fffff7b7          	lui	a5,0xfffff
    802002dc:	00f777b3          	and	a5,a4,a5
    802002e0:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    802002e4:	01c0006f          	j	80200300 <kfreerange+0x50>
        kfree((void *)addr);
    802002e8:	fe843503          	ld	a0,-24(s0)
    802002ec:	f45ff0ef          	jal	ra,80200230 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    802002f0:	fe843703          	ld	a4,-24(s0)
    802002f4:	000017b7          	lui	a5,0x1
    802002f8:	00f707b3          	add	a5,a4,a5
    802002fc:	fef43423          	sd	a5,-24(s0)
    80200300:	fe843703          	ld	a4,-24(s0)
    80200304:	000017b7          	lui	a5,0x1
    80200308:	00f70733          	add	a4,a4,a5
    8020030c:	fd043783          	ld	a5,-48(s0)
    80200310:	fce7fce3          	bgeu	a5,a4,802002e8 <kfreerange+0x38>
    }
}
    80200314:	00000013          	nop
    80200318:	00000013          	nop
    8020031c:	02813083          	ld	ra,40(sp)
    80200320:	02013403          	ld	s0,32(sp)
    80200324:	03010113          	addi	sp,sp,48
    80200328:	00008067          	ret

000000008020032c <mm_init>:

void mm_init(void) {
    8020032c:	ff010113          	addi	sp,sp,-16
    80200330:	00113423          	sd	ra,8(sp)
    80200334:	00813023          	sd	s0,0(sp)
    80200338:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    8020033c:	01100793          	li	a5,17
    80200340:	01b79593          	slli	a1,a5,0x1b
    80200344:	00003517          	auipc	a0,0x3
    80200348:	cd453503          	ld	a0,-812(a0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    8020034c:	f65ff0ef          	jal	ra,802002b0 <kfreerange>
    printk("...mm_init done!\n");
    80200350:	00002517          	auipc	a0,0x2
    80200354:	cb050513          	addi	a0,a0,-848 # 80202000 <_srodata>
    80200358:	38c010ef          	jal	ra,802016e4 <printk>
}
    8020035c:	00000013          	nop
    80200360:	00813083          	ld	ra,8(sp)
    80200364:	00013403          	ld	s0,0(sp)
    80200368:	01010113          	addi	sp,sp,16
    8020036c:	00008067          	ret

0000000080200370 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
    80200370:	ff010113          	addi	sp,sp,-16
    80200374:	00113423          	sd	ra,8(sp)
    80200378:	00813023          	sd	s0,0(sp)
    8020037c:	01010413          	addi	s0,sp,16
    srand(2024);
    80200380:	7e800513          	li	a0,2024
    80200384:	3e0010ef          	jal	ra,80201764 <srand>
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */

    printk("...task_init done!\n");
    80200388:	00002517          	auipc	a0,0x2
    8020038c:	c9050513          	addi	a0,a0,-880 # 80202018 <_srodata+0x18>
    80200390:	354010ef          	jal	ra,802016e4 <printk>
}
    80200394:	00000013          	nop
    80200398:	00813083          	ld	ra,8(sp)
    8020039c:	00013403          	ld	s0,0(sp)
    802003a0:	01010113          	addi	sp,sp,16
    802003a4:	00008067          	ret

00000000802003a8 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    802003a8:	fd010113          	addi	sp,sp,-48
    802003ac:	02113423          	sd	ra,40(sp)
    802003b0:	02813023          	sd	s0,32(sp)
    802003b4:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    802003b8:	3b9ad7b7          	lui	a5,0x3b9ad
    802003bc:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    802003c0:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    802003c4:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    802003c8:	fff00793          	li	a5,-1
    802003cc:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    802003d0:	fe442783          	lw	a5,-28(s0)
    802003d4:	0007871b          	sext.w	a4,a5
    802003d8:	fff00793          	li	a5,-1
    802003dc:	00f70e63          	beq	a4,a5,802003f8 <dummy+0x50>
    802003e0:	00003797          	auipc	a5,0x3
    802003e4:	c487b783          	ld	a5,-952(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    802003e8:	0007b783          	ld	a5,0(a5)
    802003ec:	0087b703          	ld	a4,8(a5)
    802003f0:	fe442783          	lw	a5,-28(s0)
    802003f4:	fcf70ee3          	beq	a4,a5,802003d0 <dummy+0x28>
    802003f8:	00003797          	auipc	a5,0x3
    802003fc:	c307b783          	ld	a5,-976(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200400:	0007b783          	ld	a5,0(a5)
    80200404:	0087b783          	ld	a5,8(a5)
    80200408:	fc0784e3          	beqz	a5,802003d0 <dummy+0x28>
            if (current->counter == 1) {
    8020040c:	00003797          	auipc	a5,0x3
    80200410:	c1c7b783          	ld	a5,-996(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200414:	0007b783          	ld	a5,0(a5)
    80200418:	0087b703          	ld	a4,8(a5)
    8020041c:	00100793          	li	a5,1
    80200420:	00f71e63          	bne	a4,a5,8020043c <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    80200424:	00003797          	auipc	a5,0x3
    80200428:	c047b783          	ld	a5,-1020(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020042c:	0007b783          	ld	a5,0(a5)
    80200430:	0087b703          	ld	a4,8(a5)
    80200434:	fff70713          	addi	a4,a4,-1 # ffffffffffffefff <_ekernel+0xffffffff7fdf9edf>
    80200438:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    8020043c:	00003797          	auipc	a5,0x3
    80200440:	bec7b783          	ld	a5,-1044(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    80200444:	0007b783          	ld	a5,0(a5)
    80200448:	0087b783          	ld	a5,8(a5)
    8020044c:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    80200450:	fe843783          	ld	a5,-24(s0)
    80200454:	00178713          	addi	a4,a5,1
    80200458:	fd843783          	ld	a5,-40(s0)
    8020045c:	02f777b3          	remu	a5,a4,a5
    80200460:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    80200464:	00003797          	auipc	a5,0x3
    80200468:	bc47b783          	ld	a5,-1084(a5) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    8020046c:	0007b783          	ld	a5,0(a5)
    80200470:	0187b783          	ld	a5,24(a5)
    80200474:	fe843603          	ld	a2,-24(s0)
    80200478:	00078593          	mv	a1,a5
    8020047c:	00002517          	auipc	a0,0x2
    80200480:	bb450513          	addi	a0,a0,-1100 # 80202030 <_srodata+0x30>
    80200484:	260010ef          	jal	ra,802016e4 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200488:	f49ff06f          	j	802003d0 <dummy+0x28>

000000008020048c <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    8020048c:	f8010113          	addi	sp,sp,-128
    80200490:	06813c23          	sd	s0,120(sp)
    80200494:	06913823          	sd	s1,112(sp)
    80200498:	07213423          	sd	s2,104(sp)
    8020049c:	07313023          	sd	s3,96(sp)
    802004a0:	08010413          	addi	s0,sp,128
    802004a4:	faa43c23          	sd	a0,-72(s0)
    802004a8:	fab43823          	sd	a1,-80(s0)
    802004ac:	fac43423          	sd	a2,-88(s0)
    802004b0:	fad43023          	sd	a3,-96(s0)
    802004b4:	f8e43c23          	sd	a4,-104(s0)
    802004b8:	f8f43823          	sd	a5,-112(s0)
    802004bc:	f9043423          	sd	a6,-120(s0)
    802004c0:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
    802004c4:	fb843e03          	ld	t3,-72(s0)
    802004c8:	fb043e83          	ld	t4,-80(s0)
    802004cc:	fa843f03          	ld	t5,-88(s0)
    802004d0:	fa043f83          	ld	t6,-96(s0)
    802004d4:	f9843283          	ld	t0,-104(s0)
    802004d8:	f9043483          	ld	s1,-112(s0)
    802004dc:	f8843903          	ld	s2,-120(s0)
    802004e0:	f8043983          	ld	s3,-128(s0)
    802004e4:	000e0893          	mv	a7,t3
    802004e8:	000e8813          	mv	a6,t4
    802004ec:	000f0513          	mv	a0,t5
    802004f0:	000f8593          	mv	a1,t6
    802004f4:	00028613          	mv	a2,t0
    802004f8:	00048693          	mv	a3,s1
    802004fc:	00090713          	mv	a4,s2
    80200500:	00098793          	mv	a5,s3
    80200504:	00000073          	ecall
    80200508:	00050e93          	mv	t4,a0
    8020050c:	00058e13          	mv	t3,a1
    80200510:	fdd43023          	sd	t4,-64(s0)
    80200514:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
    80200518:	fc043783          	ld	a5,-64(s0)
    8020051c:	fcf43823          	sd	a5,-48(s0)
    80200520:	fc843783          	ld	a5,-56(s0)
    80200524:	fcf43c23          	sd	a5,-40(s0)
    80200528:	00000713          	li	a4,0
    8020052c:	fd043703          	ld	a4,-48(s0)
    80200530:	00000793          	li	a5,0
    80200534:	fd843783          	ld	a5,-40(s0)
    80200538:	00070313          	mv	t1,a4
    8020053c:	00078393          	mv	t2,a5
    80200540:	00030713          	mv	a4,t1
    80200544:	00038793          	mv	a5,t2
}
    80200548:	00070513          	mv	a0,a4
    8020054c:	00078593          	mv	a1,a5
    80200550:	07813403          	ld	s0,120(sp)
    80200554:	07013483          	ld	s1,112(sp)
    80200558:	06813903          	ld	s2,104(sp)
    8020055c:	06013983          	ld	s3,96(sp)
    80200560:	08010113          	addi	sp,sp,128
    80200564:	00008067          	ret

0000000080200568 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    80200568:	fc010113          	addi	sp,sp,-64
    8020056c:	02113c23          	sd	ra,56(sp)
    80200570:	02813823          	sd	s0,48(sp)
    80200574:	03213423          	sd	s2,40(sp)
    80200578:	03313023          	sd	s3,32(sp)
    8020057c:	04010413          	addi	s0,sp,64
    80200580:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
    80200584:	00000893          	li	a7,0
    80200588:	00000813          	li	a6,0
    8020058c:	00000793          	li	a5,0
    80200590:	00000713          	li	a4,0
    80200594:	00000693          	li	a3,0
    80200598:	fc843603          	ld	a2,-56(s0)
    8020059c:	00000593          	li	a1,0
    802005a0:	54495537          	lui	a0,0x54495
    802005a4:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    802005a8:	ee5ff0ef          	jal	ra,8020048c <sbi_ecall>
    802005ac:	00050713          	mv	a4,a0
    802005b0:	00058793          	mv	a5,a1
    802005b4:	fce43823          	sd	a4,-48(s0)
    802005b8:	fcf43c23          	sd	a5,-40(s0)
    802005bc:	00000713          	li	a4,0
    802005c0:	fd043703          	ld	a4,-48(s0)
    802005c4:	00000793          	li	a5,0
    802005c8:	fd843783          	ld	a5,-40(s0)
    802005cc:	00070913          	mv	s2,a4
    802005d0:	00078993          	mv	s3,a5
    802005d4:	00090713          	mv	a4,s2
    802005d8:	00098793          	mv	a5,s3
}
    802005dc:	00070513          	mv	a0,a4
    802005e0:	00078593          	mv	a1,a5
    802005e4:	03813083          	ld	ra,56(sp)
    802005e8:	03013403          	ld	s0,48(sp)
    802005ec:	02813903          	ld	s2,40(sp)
    802005f0:	02013983          	ld	s3,32(sp)
    802005f4:	04010113          	addi	sp,sp,64
    802005f8:	00008067          	ret

00000000802005fc <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    802005fc:	fc010113          	addi	sp,sp,-64
    80200600:	02113c23          	sd	ra,56(sp)
    80200604:	02813823          	sd	s0,48(sp)
    80200608:	03213423          	sd	s2,40(sp)
    8020060c:	03313023          	sd	s3,32(sp)
    80200610:	04010413          	addi	s0,sp,64
    80200614:	00050793          	mv	a5,a0
    80200618:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
    8020061c:	fcf44603          	lbu	a2,-49(s0)
    80200620:	00000893          	li	a7,0
    80200624:	00000813          	li	a6,0
    80200628:	00000793          	li	a5,0
    8020062c:	00000713          	li	a4,0
    80200630:	00000693          	li	a3,0
    80200634:	00200593          	li	a1,2
    80200638:	44424537          	lui	a0,0x44424
    8020063c:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200640:	e4dff0ef          	jal	ra,8020048c <sbi_ecall>
    80200644:	00050713          	mv	a4,a0
    80200648:	00058793          	mv	a5,a1
    8020064c:	fce43823          	sd	a4,-48(s0)
    80200650:	fcf43c23          	sd	a5,-40(s0)
    80200654:	00000713          	li	a4,0
    80200658:	fd043703          	ld	a4,-48(s0)
    8020065c:	00000793          	li	a5,0
    80200660:	fd843783          	ld	a5,-40(s0)
    80200664:	00070913          	mv	s2,a4
    80200668:	00078993          	mv	s3,a5
    8020066c:	00090713          	mv	a4,s2
    80200670:	00098793          	mv	a5,s3
}
    80200674:	00070513          	mv	a0,a4
    80200678:	00078593          	mv	a1,a5
    8020067c:	03813083          	ld	ra,56(sp)
    80200680:	03013403          	ld	s0,48(sp)
    80200684:	02813903          	ld	s2,40(sp)
    80200688:	02013983          	ld	s3,32(sp)
    8020068c:	04010113          	addi	sp,sp,64
    80200690:	00008067          	ret

0000000080200694 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200694:	fc010113          	addi	sp,sp,-64
    80200698:	02113c23          	sd	ra,56(sp)
    8020069c:	02813823          	sd	s0,48(sp)
    802006a0:	03213423          	sd	s2,40(sp)
    802006a4:	03313023          	sd	s3,32(sp)
    802006a8:	04010413          	addi	s0,sp,64
    802006ac:	00050793          	mv	a5,a0
    802006b0:	00058713          	mv	a4,a1
    802006b4:	fcf42623          	sw	a5,-52(s0)
    802006b8:	00070793          	mv	a5,a4
    802006bc:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
    802006c0:	fcc46603          	lwu	a2,-52(s0)
    802006c4:	fc846683          	lwu	a3,-56(s0)
    802006c8:	00000893          	li	a7,0
    802006cc:	00000813          	li	a6,0
    802006d0:	00000793          	li	a5,0
    802006d4:	00000713          	li	a4,0
    802006d8:	00000593          	li	a1,0
    802006dc:	53525537          	lui	a0,0x53525
    802006e0:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    802006e4:	da9ff0ef          	jal	ra,8020048c <sbi_ecall>
    802006e8:	00050713          	mv	a4,a0
    802006ec:	00058793          	mv	a5,a1
    802006f0:	fce43823          	sd	a4,-48(s0)
    802006f4:	fcf43c23          	sd	a5,-40(s0)
    802006f8:	00000713          	li	a4,0
    802006fc:	fd043703          	ld	a4,-48(s0)
    80200700:	00000793          	li	a5,0
    80200704:	fd843783          	ld	a5,-40(s0)
    80200708:	00070913          	mv	s2,a4
    8020070c:	00078993          	mv	s3,a5
    80200710:	00090713          	mv	a4,s2
    80200714:	00098793          	mv	a5,s3
    80200718:	00070513          	mv	a0,a4
    8020071c:	00078593          	mv	a1,a5
    80200720:	03813083          	ld	ra,56(sp)
    80200724:	03013403          	ld	s0,48(sp)
    80200728:	02813903          	ld	s2,40(sp)
    8020072c:	02013983          	ld	s3,32(sp)
    80200730:	04010113          	addi	sp,sp,64
    80200734:	00008067          	ret

0000000080200738 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200738:	fd010113          	addi	sp,sp,-48
    8020073c:	02113423          	sd	ra,40(sp)
    80200740:	02813023          	sd	s0,32(sp)
    80200744:	03010413          	addi	s0,sp,48
    80200748:	fca43c23          	sd	a0,-40(s0)
    8020074c:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
    80200750:	fd843783          	ld	a5,-40(s0)
    80200754:	0407d663          	bgez	a5,802007a0 <trap_handler+0x68>
        uint64_t interrupt_code = scause & ~(1UL << 63);
    80200758:	fd843703          	ld	a4,-40(s0)
    8020075c:	fff00793          	li	a5,-1
    80200760:	0017d793          	srli	a5,a5,0x1
    80200764:	00f777b3          	and	a5,a4,a5
    80200768:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
    8020076c:	fe043703          	ld	a4,-32(s0)
    80200770:	00500793          	li	a5,5
    80200774:	00f71c63          	bne	a4,a5,8020078c <trap_handler+0x54>
            printk("[S] Supervisor Mode TImer Interrupt\n");
    80200778:	00002517          	auipc	a0,0x2
    8020077c:	8e850513          	addi	a0,a0,-1816 # 80202060 <_srodata+0x60>
    80200780:	765000ef          	jal	ra,802016e4 <printk>
            clock_set_next_event();
    80200784:	a09ff0ef          	jal	ra,8020018c <clock_set_next_event>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
    80200788:	0300006f          	j	802007b8 <trap_handler+0x80>
            printk("other interrupt: %d\n", interrupt_code);
    8020078c:	fe043583          	ld	a1,-32(s0)
    80200790:	00002517          	auipc	a0,0x2
    80200794:	8f850513          	addi	a0,a0,-1800 # 80202088 <_srodata+0x88>
    80200798:	74d000ef          	jal	ra,802016e4 <printk>
    8020079c:	01c0006f          	j	802007b8 <trap_handler+0x80>
        uint64_t exception_code = scause;
    802007a0:	fd843783          	ld	a5,-40(s0)
    802007a4:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
    802007a8:	fe843583          	ld	a1,-24(s0)
    802007ac:	00002517          	auipc	a0,0x2
    802007b0:	8f450513          	addi	a0,a0,-1804 # 802020a0 <_srodata+0xa0>
    802007b4:	731000ef          	jal	ra,802016e4 <printk>
    802007b8:	00000013          	nop
    802007bc:	02813083          	ld	ra,40(sp)
    802007c0:	02013403          	ld	s0,32(sp)
    802007c4:	03010113          	addi	sp,sp,48
    802007c8:	00008067          	ret

00000000802007cc <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    802007cc:	ff010113          	addi	sp,sp,-16
    802007d0:	00113423          	sd	ra,8(sp)
    802007d4:	00813023          	sd	s0,0(sp)
    802007d8:	01010413          	addi	s0,sp,16
    printk("2024");
    802007dc:	00002517          	auipc	a0,0x2
    802007e0:	8d450513          	addi	a0,a0,-1836 # 802020b0 <_srodata+0xb0>
    802007e4:	701000ef          	jal	ra,802016e4 <printk>
    printk(" ZJU Operating System\n");
    802007e8:	00002517          	auipc	a0,0x2
    802007ec:	8d050513          	addi	a0,a0,-1840 # 802020b8 <_srodata+0xb8>
    802007f0:	6f5000ef          	jal	ra,802016e4 <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
    802007f4:	01c000ef          	jal	ra,80200810 <test>
    return 0;
    802007f8:	00000793          	li	a5,0
}
    802007fc:	00078513          	mv	a0,a5
    80200800:	00813083          	ld	ra,8(sp)
    80200804:	00013403          	ld	s0,0(sp)
    80200808:	01010113          	addi	sp,sp,16
    8020080c:	00008067          	ret

0000000080200810 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
    80200810:	fe010113          	addi	sp,sp,-32
    80200814:	00113c23          	sd	ra,24(sp)
    80200818:	00813823          	sd	s0,16(sp)
    8020081c:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
    80200820:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200824:	fec42783          	lw	a5,-20(s0)
    80200828:	0017879b          	addiw	a5,a5,1
    8020082c:	fef42623          	sw	a5,-20(s0)
    80200830:	fec42703          	lw	a4,-20(s0)
    80200834:	05f5e7b7          	lui	a5,0x5f5e
    80200838:	1007879b          	addiw	a5,a5,256
    8020083c:	02f767bb          	remw	a5,a4,a5
    80200840:	0007879b          	sext.w	a5,a5
    80200844:	fe0790e3          	bnez	a5,80200824 <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
    80200848:	00002517          	auipc	a0,0x2
    8020084c:	88850513          	addi	a0,a0,-1912 # 802020d0 <_srodata+0xd0>
    80200850:	695000ef          	jal	ra,802016e4 <printk>
            i = 0;
    80200854:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200858:	fcdff06f          	j	80200824 <test+0x14>

000000008020085c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    8020085c:	fe010113          	addi	sp,sp,-32
    80200860:	00113c23          	sd	ra,24(sp)
    80200864:	00813823          	sd	s0,16(sp)
    80200868:	02010413          	addi	s0,sp,32
    8020086c:	00050793          	mv	a5,a0
    80200870:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200874:	fec42783          	lw	a5,-20(s0)
    80200878:	0ff7f793          	andi	a5,a5,255
    8020087c:	00078513          	mv	a0,a5
    80200880:	d7dff0ef          	jal	ra,802005fc <sbi_debug_console_write_byte>
    return (char)c;
    80200884:	fec42783          	lw	a5,-20(s0)
    80200888:	0ff7f793          	andi	a5,a5,255
    8020088c:	0007879b          	sext.w	a5,a5
}
    80200890:	00078513          	mv	a0,a5
    80200894:	01813083          	ld	ra,24(sp)
    80200898:	01013403          	ld	s0,16(sp)
    8020089c:	02010113          	addi	sp,sp,32
    802008a0:	00008067          	ret

00000000802008a4 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    802008a4:	fe010113          	addi	sp,sp,-32
    802008a8:	00813c23          	sd	s0,24(sp)
    802008ac:	02010413          	addi	s0,sp,32
    802008b0:	00050793          	mv	a5,a0
    802008b4:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    802008b8:	fec42783          	lw	a5,-20(s0)
    802008bc:	0007871b          	sext.w	a4,a5
    802008c0:	02000793          	li	a5,32
    802008c4:	02f70263          	beq	a4,a5,802008e8 <isspace+0x44>
    802008c8:	fec42783          	lw	a5,-20(s0)
    802008cc:	0007871b          	sext.w	a4,a5
    802008d0:	00800793          	li	a5,8
    802008d4:	00e7de63          	bge	a5,a4,802008f0 <isspace+0x4c>
    802008d8:	fec42783          	lw	a5,-20(s0)
    802008dc:	0007871b          	sext.w	a4,a5
    802008e0:	00d00793          	li	a5,13
    802008e4:	00e7c663          	blt	a5,a4,802008f0 <isspace+0x4c>
    802008e8:	00100793          	li	a5,1
    802008ec:	0080006f          	j	802008f4 <isspace+0x50>
    802008f0:	00000793          	li	a5,0
}
    802008f4:	00078513          	mv	a0,a5
    802008f8:	01813403          	ld	s0,24(sp)
    802008fc:	02010113          	addi	sp,sp,32
    80200900:	00008067          	ret

0000000080200904 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200904:	fb010113          	addi	sp,sp,-80
    80200908:	04113423          	sd	ra,72(sp)
    8020090c:	04813023          	sd	s0,64(sp)
    80200910:	05010413          	addi	s0,sp,80
    80200914:	fca43423          	sd	a0,-56(s0)
    80200918:	fcb43023          	sd	a1,-64(s0)
    8020091c:	00060793          	mv	a5,a2
    80200920:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200924:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200928:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    8020092c:	fc843783          	ld	a5,-56(s0)
    80200930:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200934:	0100006f          	j	80200944 <strtol+0x40>
        p++;
    80200938:	fd843783          	ld	a5,-40(s0)
    8020093c:	00178793          	addi	a5,a5,1 # 5f5e001 <_skernel-0x7a2a1fff>
    80200940:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200944:	fd843783          	ld	a5,-40(s0)
    80200948:	0007c783          	lbu	a5,0(a5)
    8020094c:	0007879b          	sext.w	a5,a5
    80200950:	00078513          	mv	a0,a5
    80200954:	f51ff0ef          	jal	ra,802008a4 <isspace>
    80200958:	00050793          	mv	a5,a0
    8020095c:	fc079ee3          	bnez	a5,80200938 <strtol+0x34>
    }

    if (*p == '-') {
    80200960:	fd843783          	ld	a5,-40(s0)
    80200964:	0007c783          	lbu	a5,0(a5)
    80200968:	00078713          	mv	a4,a5
    8020096c:	02d00793          	li	a5,45
    80200970:	00f71e63          	bne	a4,a5,8020098c <strtol+0x88>
        neg = true;
    80200974:	00100793          	li	a5,1
    80200978:	fef403a3          	sb	a5,-25(s0)
        p++;
    8020097c:	fd843783          	ld	a5,-40(s0)
    80200980:	00178793          	addi	a5,a5,1
    80200984:	fcf43c23          	sd	a5,-40(s0)
    80200988:	0240006f          	j	802009ac <strtol+0xa8>
    } else if (*p == '+') {
    8020098c:	fd843783          	ld	a5,-40(s0)
    80200990:	0007c783          	lbu	a5,0(a5)
    80200994:	00078713          	mv	a4,a5
    80200998:	02b00793          	li	a5,43
    8020099c:	00f71863          	bne	a4,a5,802009ac <strtol+0xa8>
        p++;
    802009a0:	fd843783          	ld	a5,-40(s0)
    802009a4:	00178793          	addi	a5,a5,1
    802009a8:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    802009ac:	fbc42783          	lw	a5,-68(s0)
    802009b0:	0007879b          	sext.w	a5,a5
    802009b4:	06079c63          	bnez	a5,80200a2c <strtol+0x128>
        if (*p == '0') {
    802009b8:	fd843783          	ld	a5,-40(s0)
    802009bc:	0007c783          	lbu	a5,0(a5)
    802009c0:	00078713          	mv	a4,a5
    802009c4:	03000793          	li	a5,48
    802009c8:	04f71e63          	bne	a4,a5,80200a24 <strtol+0x120>
            p++;
    802009cc:	fd843783          	ld	a5,-40(s0)
    802009d0:	00178793          	addi	a5,a5,1
    802009d4:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802009d8:	fd843783          	ld	a5,-40(s0)
    802009dc:	0007c783          	lbu	a5,0(a5)
    802009e0:	00078713          	mv	a4,a5
    802009e4:	07800793          	li	a5,120
    802009e8:	00f70c63          	beq	a4,a5,80200a00 <strtol+0xfc>
    802009ec:	fd843783          	ld	a5,-40(s0)
    802009f0:	0007c783          	lbu	a5,0(a5)
    802009f4:	00078713          	mv	a4,a5
    802009f8:	05800793          	li	a5,88
    802009fc:	00f71e63          	bne	a4,a5,80200a18 <strtol+0x114>
                base = 16;
    80200a00:	01000793          	li	a5,16
    80200a04:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200a08:	fd843783          	ld	a5,-40(s0)
    80200a0c:	00178793          	addi	a5,a5,1
    80200a10:	fcf43c23          	sd	a5,-40(s0)
    80200a14:	0180006f          	j	80200a2c <strtol+0x128>
            } else {
                base = 8;
    80200a18:	00800793          	li	a5,8
    80200a1c:	faf42e23          	sw	a5,-68(s0)
    80200a20:	00c0006f          	j	80200a2c <strtol+0x128>
            }
        } else {
            base = 10;
    80200a24:	00a00793          	li	a5,10
    80200a28:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200a2c:	fd843783          	ld	a5,-40(s0)
    80200a30:	0007c783          	lbu	a5,0(a5)
    80200a34:	00078713          	mv	a4,a5
    80200a38:	02f00793          	li	a5,47
    80200a3c:	02e7f863          	bgeu	a5,a4,80200a6c <strtol+0x168>
    80200a40:	fd843783          	ld	a5,-40(s0)
    80200a44:	0007c783          	lbu	a5,0(a5)
    80200a48:	00078713          	mv	a4,a5
    80200a4c:	03900793          	li	a5,57
    80200a50:	00e7ee63          	bltu	a5,a4,80200a6c <strtol+0x168>
            digit = *p - '0';
    80200a54:	fd843783          	ld	a5,-40(s0)
    80200a58:	0007c783          	lbu	a5,0(a5)
    80200a5c:	0007879b          	sext.w	a5,a5
    80200a60:	fd07879b          	addiw	a5,a5,-48
    80200a64:	fcf42a23          	sw	a5,-44(s0)
    80200a68:	0800006f          	j	80200ae8 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200a6c:	fd843783          	ld	a5,-40(s0)
    80200a70:	0007c783          	lbu	a5,0(a5)
    80200a74:	00078713          	mv	a4,a5
    80200a78:	06000793          	li	a5,96
    80200a7c:	02e7f863          	bgeu	a5,a4,80200aac <strtol+0x1a8>
    80200a80:	fd843783          	ld	a5,-40(s0)
    80200a84:	0007c783          	lbu	a5,0(a5)
    80200a88:	00078713          	mv	a4,a5
    80200a8c:	07a00793          	li	a5,122
    80200a90:	00e7ee63          	bltu	a5,a4,80200aac <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200a94:	fd843783          	ld	a5,-40(s0)
    80200a98:	0007c783          	lbu	a5,0(a5)
    80200a9c:	0007879b          	sext.w	a5,a5
    80200aa0:	fa97879b          	addiw	a5,a5,-87
    80200aa4:	fcf42a23          	sw	a5,-44(s0)
    80200aa8:	0400006f          	j	80200ae8 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200aac:	fd843783          	ld	a5,-40(s0)
    80200ab0:	0007c783          	lbu	a5,0(a5)
    80200ab4:	00078713          	mv	a4,a5
    80200ab8:	04000793          	li	a5,64
    80200abc:	06e7f663          	bgeu	a5,a4,80200b28 <strtol+0x224>
    80200ac0:	fd843783          	ld	a5,-40(s0)
    80200ac4:	0007c783          	lbu	a5,0(a5)
    80200ac8:	00078713          	mv	a4,a5
    80200acc:	05a00793          	li	a5,90
    80200ad0:	04e7ec63          	bltu	a5,a4,80200b28 <strtol+0x224>
            digit = *p - ('A' - 10);
    80200ad4:	fd843783          	ld	a5,-40(s0)
    80200ad8:	0007c783          	lbu	a5,0(a5)
    80200adc:	0007879b          	sext.w	a5,a5
    80200ae0:	fc97879b          	addiw	a5,a5,-55
    80200ae4:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200ae8:	fd442703          	lw	a4,-44(s0)
    80200aec:	fbc42783          	lw	a5,-68(s0)
    80200af0:	0007071b          	sext.w	a4,a4
    80200af4:	0007879b          	sext.w	a5,a5
    80200af8:	02f75663          	bge	a4,a5,80200b24 <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
    80200afc:	fbc42703          	lw	a4,-68(s0)
    80200b00:	fe843783          	ld	a5,-24(s0)
    80200b04:	02f70733          	mul	a4,a4,a5
    80200b08:	fd442783          	lw	a5,-44(s0)
    80200b0c:	00f707b3          	add	a5,a4,a5
    80200b10:	fef43423          	sd	a5,-24(s0)
        p++;
    80200b14:	fd843783          	ld	a5,-40(s0)
    80200b18:	00178793          	addi	a5,a5,1
    80200b1c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200b20:	f0dff06f          	j	80200a2c <strtol+0x128>
            break;
    80200b24:	00000013          	nop
    }

    if (endptr) {
    80200b28:	fc043783          	ld	a5,-64(s0)
    80200b2c:	00078863          	beqz	a5,80200b3c <strtol+0x238>
        *endptr = (char *)p;
    80200b30:	fc043783          	ld	a5,-64(s0)
    80200b34:	fd843703          	ld	a4,-40(s0)
    80200b38:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200b3c:	fe744783          	lbu	a5,-25(s0)
    80200b40:	0ff7f793          	andi	a5,a5,255
    80200b44:	00078863          	beqz	a5,80200b54 <strtol+0x250>
    80200b48:	fe843783          	ld	a5,-24(s0)
    80200b4c:	40f007b3          	neg	a5,a5
    80200b50:	0080006f          	j	80200b58 <strtol+0x254>
    80200b54:	fe843783          	ld	a5,-24(s0)
}
    80200b58:	00078513          	mv	a0,a5
    80200b5c:	04813083          	ld	ra,72(sp)
    80200b60:	04013403          	ld	s0,64(sp)
    80200b64:	05010113          	addi	sp,sp,80
    80200b68:	00008067          	ret

0000000080200b6c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200b6c:	fd010113          	addi	sp,sp,-48
    80200b70:	02113423          	sd	ra,40(sp)
    80200b74:	02813023          	sd	s0,32(sp)
    80200b78:	03010413          	addi	s0,sp,48
    80200b7c:	fca43c23          	sd	a0,-40(s0)
    80200b80:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200b84:	fd043783          	ld	a5,-48(s0)
    80200b88:	00079863          	bnez	a5,80200b98 <puts_wo_nl+0x2c>
        s = "(null)";
    80200b8c:	00001797          	auipc	a5,0x1
    80200b90:	55c78793          	addi	a5,a5,1372 # 802020e8 <_srodata+0xe8>
    80200b94:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200b98:	fd043783          	ld	a5,-48(s0)
    80200b9c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200ba0:	0240006f          	j	80200bc4 <puts_wo_nl+0x58>
        putch(*p++);
    80200ba4:	fe843783          	ld	a5,-24(s0)
    80200ba8:	00178713          	addi	a4,a5,1
    80200bac:	fee43423          	sd	a4,-24(s0)
    80200bb0:	0007c783          	lbu	a5,0(a5)
    80200bb4:	0007879b          	sext.w	a5,a5
    80200bb8:	fd843703          	ld	a4,-40(s0)
    80200bbc:	00078513          	mv	a0,a5
    80200bc0:	000700e7          	jalr	a4
    while (*p) {
    80200bc4:	fe843783          	ld	a5,-24(s0)
    80200bc8:	0007c783          	lbu	a5,0(a5)
    80200bcc:	fc079ce3          	bnez	a5,80200ba4 <puts_wo_nl+0x38>
    }
    return p - s;
    80200bd0:	fe843703          	ld	a4,-24(s0)
    80200bd4:	fd043783          	ld	a5,-48(s0)
    80200bd8:	40f707b3          	sub	a5,a4,a5
    80200bdc:	0007879b          	sext.w	a5,a5
}
    80200be0:	00078513          	mv	a0,a5
    80200be4:	02813083          	ld	ra,40(sp)
    80200be8:	02013403          	ld	s0,32(sp)
    80200bec:	03010113          	addi	sp,sp,48
    80200bf0:	00008067          	ret

0000000080200bf4 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200bf4:	f9010113          	addi	sp,sp,-112
    80200bf8:	06113423          	sd	ra,104(sp)
    80200bfc:	06813023          	sd	s0,96(sp)
    80200c00:	07010413          	addi	s0,sp,112
    80200c04:	faa43423          	sd	a0,-88(s0)
    80200c08:	fab43023          	sd	a1,-96(s0)
    80200c0c:	00060793          	mv	a5,a2
    80200c10:	f8d43823          	sd	a3,-112(s0)
    80200c14:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200c18:	f9f44783          	lbu	a5,-97(s0)
    80200c1c:	0ff7f793          	andi	a5,a5,255
    80200c20:	02078663          	beqz	a5,80200c4c <print_dec_int+0x58>
    80200c24:	fa043703          	ld	a4,-96(s0)
    80200c28:	fff00793          	li	a5,-1
    80200c2c:	03f79793          	slli	a5,a5,0x3f
    80200c30:	00f71e63          	bne	a4,a5,80200c4c <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200c34:	00001597          	auipc	a1,0x1
    80200c38:	4bc58593          	addi	a1,a1,1212 # 802020f0 <_srodata+0xf0>
    80200c3c:	fa843503          	ld	a0,-88(s0)
    80200c40:	f2dff0ef          	jal	ra,80200b6c <puts_wo_nl>
    80200c44:	00050793          	mv	a5,a0
    80200c48:	2980006f          	j	80200ee0 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
    80200c4c:	f9043783          	ld	a5,-112(s0)
    80200c50:	00c7a783          	lw	a5,12(a5)
    80200c54:	00079a63          	bnez	a5,80200c68 <print_dec_int+0x74>
    80200c58:	fa043783          	ld	a5,-96(s0)
    80200c5c:	00079663          	bnez	a5,80200c68 <print_dec_int+0x74>
        return 0;
    80200c60:	00000793          	li	a5,0
    80200c64:	27c0006f          	j	80200ee0 <print_dec_int+0x2ec>
    }

    bool neg = false;
    80200c68:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200c6c:	f9f44783          	lbu	a5,-97(s0)
    80200c70:	0ff7f793          	andi	a5,a5,255
    80200c74:	02078063          	beqz	a5,80200c94 <print_dec_int+0xa0>
    80200c78:	fa043783          	ld	a5,-96(s0)
    80200c7c:	0007dc63          	bgez	a5,80200c94 <print_dec_int+0xa0>
        neg = true;
    80200c80:	00100793          	li	a5,1
    80200c84:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200c88:	fa043783          	ld	a5,-96(s0)
    80200c8c:	40f007b3          	neg	a5,a5
    80200c90:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200c94:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200c98:	f9f44783          	lbu	a5,-97(s0)
    80200c9c:	0ff7f793          	andi	a5,a5,255
    80200ca0:	02078863          	beqz	a5,80200cd0 <print_dec_int+0xdc>
    80200ca4:	fef44783          	lbu	a5,-17(s0)
    80200ca8:	0ff7f793          	andi	a5,a5,255
    80200cac:	00079e63          	bnez	a5,80200cc8 <print_dec_int+0xd4>
    80200cb0:	f9043783          	ld	a5,-112(s0)
    80200cb4:	0057c783          	lbu	a5,5(a5)
    80200cb8:	00079863          	bnez	a5,80200cc8 <print_dec_int+0xd4>
    80200cbc:	f9043783          	ld	a5,-112(s0)
    80200cc0:	0047c783          	lbu	a5,4(a5)
    80200cc4:	00078663          	beqz	a5,80200cd0 <print_dec_int+0xdc>
    80200cc8:	00100793          	li	a5,1
    80200ccc:	0080006f          	j	80200cd4 <print_dec_int+0xe0>
    80200cd0:	00000793          	li	a5,0
    80200cd4:	fcf40ba3          	sb	a5,-41(s0)
    80200cd8:	fd744783          	lbu	a5,-41(s0)
    80200cdc:	0017f793          	andi	a5,a5,1
    80200ce0:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200ce4:	fa043703          	ld	a4,-96(s0)
    80200ce8:	00a00793          	li	a5,10
    80200cec:	02f777b3          	remu	a5,a4,a5
    80200cf0:	0ff7f713          	andi	a4,a5,255
    80200cf4:	fe842783          	lw	a5,-24(s0)
    80200cf8:	0017869b          	addiw	a3,a5,1
    80200cfc:	fed42423          	sw	a3,-24(s0)
    80200d00:	0307071b          	addiw	a4,a4,48
    80200d04:	0ff77713          	andi	a4,a4,255
    80200d08:	ff040693          	addi	a3,s0,-16
    80200d0c:	00f687b3          	add	a5,a3,a5
    80200d10:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200d14:	fa043703          	ld	a4,-96(s0)
    80200d18:	00a00793          	li	a5,10
    80200d1c:	02f757b3          	divu	a5,a4,a5
    80200d20:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200d24:	fa043783          	ld	a5,-96(s0)
    80200d28:	fa079ee3          	bnez	a5,80200ce4 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200d2c:	f9043783          	ld	a5,-112(s0)
    80200d30:	00c7a783          	lw	a5,12(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	fff00793          	li	a5,-1
    80200d3c:	02f71063          	bne	a4,a5,80200d5c <print_dec_int+0x168>
    80200d40:	f9043783          	ld	a5,-112(s0)
    80200d44:	0037c783          	lbu	a5,3(a5)
    80200d48:	00078a63          	beqz	a5,80200d5c <print_dec_int+0x168>
        flags->prec = flags->width;
    80200d4c:	f9043783          	ld	a5,-112(s0)
    80200d50:	0087a703          	lw	a4,8(a5)
    80200d54:	f9043783          	ld	a5,-112(s0)
    80200d58:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200d5c:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200d60:	f9043783          	ld	a5,-112(s0)
    80200d64:	0087a703          	lw	a4,8(a5)
    80200d68:	fe842783          	lw	a5,-24(s0)
    80200d6c:	fcf42823          	sw	a5,-48(s0)
    80200d70:	f9043783          	ld	a5,-112(s0)
    80200d74:	00c7a783          	lw	a5,12(a5)
    80200d78:	fcf42623          	sw	a5,-52(s0)
    80200d7c:	fd042583          	lw	a1,-48(s0)
    80200d80:	fcc42783          	lw	a5,-52(s0)
    80200d84:	0007861b          	sext.w	a2,a5
    80200d88:	0005869b          	sext.w	a3,a1
    80200d8c:	00d65463          	bge	a2,a3,80200d94 <print_dec_int+0x1a0>
    80200d90:	00058793          	mv	a5,a1
    80200d94:	0007879b          	sext.w	a5,a5
    80200d98:	40f707bb          	subw	a5,a4,a5
    80200d9c:	0007871b          	sext.w	a4,a5
    80200da0:	fd744783          	lbu	a5,-41(s0)
    80200da4:	0007879b          	sext.w	a5,a5
    80200da8:	40f707bb          	subw	a5,a4,a5
    80200dac:	fef42023          	sw	a5,-32(s0)
    80200db0:	0280006f          	j	80200dd8 <print_dec_int+0x1e4>
        putch(' ');
    80200db4:	fa843783          	ld	a5,-88(s0)
    80200db8:	02000513          	li	a0,32
    80200dbc:	000780e7          	jalr	a5
        ++written;
    80200dc0:	fe442783          	lw	a5,-28(s0)
    80200dc4:	0017879b          	addiw	a5,a5,1
    80200dc8:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200dcc:	fe042783          	lw	a5,-32(s0)
    80200dd0:	fff7879b          	addiw	a5,a5,-1
    80200dd4:	fef42023          	sw	a5,-32(s0)
    80200dd8:	fe042783          	lw	a5,-32(s0)
    80200ddc:	0007879b          	sext.w	a5,a5
    80200de0:	fcf04ae3          	bgtz	a5,80200db4 <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
    80200de4:	fd744783          	lbu	a5,-41(s0)
    80200de8:	0ff7f793          	andi	a5,a5,255
    80200dec:	04078463          	beqz	a5,80200e34 <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200df0:	fef44783          	lbu	a5,-17(s0)
    80200df4:	0ff7f793          	andi	a5,a5,255
    80200df8:	00078663          	beqz	a5,80200e04 <print_dec_int+0x210>
    80200dfc:	02d00793          	li	a5,45
    80200e00:	01c0006f          	j	80200e1c <print_dec_int+0x228>
    80200e04:	f9043783          	ld	a5,-112(s0)
    80200e08:	0057c783          	lbu	a5,5(a5)
    80200e0c:	00078663          	beqz	a5,80200e18 <print_dec_int+0x224>
    80200e10:	02b00793          	li	a5,43
    80200e14:	0080006f          	j	80200e1c <print_dec_int+0x228>
    80200e18:	02000793          	li	a5,32
    80200e1c:	fa843703          	ld	a4,-88(s0)
    80200e20:	00078513          	mv	a0,a5
    80200e24:	000700e7          	jalr	a4
        ++written;
    80200e28:	fe442783          	lw	a5,-28(s0)
    80200e2c:	0017879b          	addiw	a5,a5,1
    80200e30:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200e34:	fe842783          	lw	a5,-24(s0)
    80200e38:	fcf42e23          	sw	a5,-36(s0)
    80200e3c:	0280006f          	j	80200e64 <print_dec_int+0x270>
        putch('0');
    80200e40:	fa843783          	ld	a5,-88(s0)
    80200e44:	03000513          	li	a0,48
    80200e48:	000780e7          	jalr	a5
        ++written;
    80200e4c:	fe442783          	lw	a5,-28(s0)
    80200e50:	0017879b          	addiw	a5,a5,1
    80200e54:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200e58:	fdc42783          	lw	a5,-36(s0)
    80200e5c:	0017879b          	addiw	a5,a5,1
    80200e60:	fcf42e23          	sw	a5,-36(s0)
    80200e64:	f9043783          	ld	a5,-112(s0)
    80200e68:	00c7a703          	lw	a4,12(a5)
    80200e6c:	fd744783          	lbu	a5,-41(s0)
    80200e70:	0007879b          	sext.w	a5,a5
    80200e74:	40f707bb          	subw	a5,a4,a5
    80200e78:	0007871b          	sext.w	a4,a5
    80200e7c:	fdc42783          	lw	a5,-36(s0)
    80200e80:	0007879b          	sext.w	a5,a5
    80200e84:	fae7cee3          	blt	a5,a4,80200e40 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200e88:	fe842783          	lw	a5,-24(s0)
    80200e8c:	fff7879b          	addiw	a5,a5,-1
    80200e90:	fcf42c23          	sw	a5,-40(s0)
    80200e94:	03c0006f          	j	80200ed0 <print_dec_int+0x2dc>
        putch(buf[i]);
    80200e98:	fd842783          	lw	a5,-40(s0)
    80200e9c:	ff040713          	addi	a4,s0,-16
    80200ea0:	00f707b3          	add	a5,a4,a5
    80200ea4:	fc87c783          	lbu	a5,-56(a5)
    80200ea8:	0007879b          	sext.w	a5,a5
    80200eac:	fa843703          	ld	a4,-88(s0)
    80200eb0:	00078513          	mv	a0,a5
    80200eb4:	000700e7          	jalr	a4
        ++written;
    80200eb8:	fe442783          	lw	a5,-28(s0)
    80200ebc:	0017879b          	addiw	a5,a5,1
    80200ec0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200ec4:	fd842783          	lw	a5,-40(s0)
    80200ec8:	fff7879b          	addiw	a5,a5,-1
    80200ecc:	fcf42c23          	sw	a5,-40(s0)
    80200ed0:	fd842783          	lw	a5,-40(s0)
    80200ed4:	0007879b          	sext.w	a5,a5
    80200ed8:	fc07d0e3          	bgez	a5,80200e98 <print_dec_int+0x2a4>
    }

    return written;
    80200edc:	fe442783          	lw	a5,-28(s0)
}
    80200ee0:	00078513          	mv	a0,a5
    80200ee4:	06813083          	ld	ra,104(sp)
    80200ee8:	06013403          	ld	s0,96(sp)
    80200eec:	07010113          	addi	sp,sp,112
    80200ef0:	00008067          	ret

0000000080200ef4 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200ef4:	f4010113          	addi	sp,sp,-192
    80200ef8:	0a113c23          	sd	ra,184(sp)
    80200efc:	0a813823          	sd	s0,176(sp)
    80200f00:	0c010413          	addi	s0,sp,192
    80200f04:	f4a43c23          	sd	a0,-168(s0)
    80200f08:	f4b43823          	sd	a1,-176(s0)
    80200f0c:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200f10:	f8043023          	sd	zero,-128(s0)
    80200f14:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200f18:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200f1c:	7a40006f          	j	802016c0 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200f20:	f8044783          	lbu	a5,-128(s0)
    80200f24:	72078e63          	beqz	a5,80201660 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200f28:	f5043783          	ld	a5,-176(s0)
    80200f2c:	0007c783          	lbu	a5,0(a5)
    80200f30:	00078713          	mv	a4,a5
    80200f34:	02300793          	li	a5,35
    80200f38:	00f71863          	bne	a4,a5,80200f48 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200f3c:	00100793          	li	a5,1
    80200f40:	f8f40123          	sb	a5,-126(s0)
    80200f44:	7700006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200f48:	f5043783          	ld	a5,-176(s0)
    80200f4c:	0007c783          	lbu	a5,0(a5)
    80200f50:	00078713          	mv	a4,a5
    80200f54:	03000793          	li	a5,48
    80200f58:	00f71863          	bne	a4,a5,80200f68 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200f5c:	00100793          	li	a5,1
    80200f60:	f8f401a3          	sb	a5,-125(s0)
    80200f64:	7500006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200f68:	f5043783          	ld	a5,-176(s0)
    80200f6c:	0007c783          	lbu	a5,0(a5)
    80200f70:	00078713          	mv	a4,a5
    80200f74:	06c00793          	li	a5,108
    80200f78:	04f70063          	beq	a4,a5,80200fb8 <vprintfmt+0xc4>
    80200f7c:	f5043783          	ld	a5,-176(s0)
    80200f80:	0007c783          	lbu	a5,0(a5)
    80200f84:	00078713          	mv	a4,a5
    80200f88:	07a00793          	li	a5,122
    80200f8c:	02f70663          	beq	a4,a5,80200fb8 <vprintfmt+0xc4>
    80200f90:	f5043783          	ld	a5,-176(s0)
    80200f94:	0007c783          	lbu	a5,0(a5)
    80200f98:	00078713          	mv	a4,a5
    80200f9c:	07400793          	li	a5,116
    80200fa0:	00f70c63          	beq	a4,a5,80200fb8 <vprintfmt+0xc4>
    80200fa4:	f5043783          	ld	a5,-176(s0)
    80200fa8:	0007c783          	lbu	a5,0(a5)
    80200fac:	00078713          	mv	a4,a5
    80200fb0:	06a00793          	li	a5,106
    80200fb4:	00f71863          	bne	a4,a5,80200fc4 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200fb8:	00100793          	li	a5,1
    80200fbc:	f8f400a3          	sb	a5,-127(s0)
    80200fc0:	6f40006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200fc4:	f5043783          	ld	a5,-176(s0)
    80200fc8:	0007c783          	lbu	a5,0(a5)
    80200fcc:	00078713          	mv	a4,a5
    80200fd0:	02b00793          	li	a5,43
    80200fd4:	00f71863          	bne	a4,a5,80200fe4 <vprintfmt+0xf0>
                flags.sign = true;
    80200fd8:	00100793          	li	a5,1
    80200fdc:	f8f402a3          	sb	a5,-123(s0)
    80200fe0:	6d40006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200fe4:	f5043783          	ld	a5,-176(s0)
    80200fe8:	0007c783          	lbu	a5,0(a5)
    80200fec:	00078713          	mv	a4,a5
    80200ff0:	02000793          	li	a5,32
    80200ff4:	00f71863          	bne	a4,a5,80201004 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200ff8:	00100793          	li	a5,1
    80200ffc:	f8f40223          	sb	a5,-124(s0)
    80201000:	6b40006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80201004:	f5043783          	ld	a5,-176(s0)
    80201008:	0007c783          	lbu	a5,0(a5)
    8020100c:	00078713          	mv	a4,a5
    80201010:	02a00793          	li	a5,42
    80201014:	00f71e63          	bne	a4,a5,80201030 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80201018:	f4843783          	ld	a5,-184(s0)
    8020101c:	00878713          	addi	a4,a5,8
    80201020:	f4e43423          	sd	a4,-184(s0)
    80201024:	0007a783          	lw	a5,0(a5)
    80201028:	f8f42423          	sw	a5,-120(s0)
    8020102c:	6880006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80201030:	f5043783          	ld	a5,-176(s0)
    80201034:	0007c783          	lbu	a5,0(a5)
    80201038:	00078713          	mv	a4,a5
    8020103c:	03000793          	li	a5,48
    80201040:	04e7f663          	bgeu	a5,a4,8020108c <vprintfmt+0x198>
    80201044:	f5043783          	ld	a5,-176(s0)
    80201048:	0007c783          	lbu	a5,0(a5)
    8020104c:	00078713          	mv	a4,a5
    80201050:	03900793          	li	a5,57
    80201054:	02e7ec63          	bltu	a5,a4,8020108c <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80201058:	f5043783          	ld	a5,-176(s0)
    8020105c:	f5040713          	addi	a4,s0,-176
    80201060:	00a00613          	li	a2,10
    80201064:	00070593          	mv	a1,a4
    80201068:	00078513          	mv	a0,a5
    8020106c:	899ff0ef          	jal	ra,80200904 <strtol>
    80201070:	00050793          	mv	a5,a0
    80201074:	0007879b          	sext.w	a5,a5
    80201078:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    8020107c:	f5043783          	ld	a5,-176(s0)
    80201080:	fff78793          	addi	a5,a5,-1
    80201084:	f4f43823          	sd	a5,-176(s0)
    80201088:	62c0006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    8020108c:	f5043783          	ld	a5,-176(s0)
    80201090:	0007c783          	lbu	a5,0(a5)
    80201094:	00078713          	mv	a4,a5
    80201098:	02e00793          	li	a5,46
    8020109c:	06f71863          	bne	a4,a5,8020110c <vprintfmt+0x218>
                fmt++;
    802010a0:	f5043783          	ld	a5,-176(s0)
    802010a4:	00178793          	addi	a5,a5,1
    802010a8:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    802010ac:	f5043783          	ld	a5,-176(s0)
    802010b0:	0007c783          	lbu	a5,0(a5)
    802010b4:	00078713          	mv	a4,a5
    802010b8:	02a00793          	li	a5,42
    802010bc:	00f71e63          	bne	a4,a5,802010d8 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    802010c0:	f4843783          	ld	a5,-184(s0)
    802010c4:	00878713          	addi	a4,a5,8
    802010c8:	f4e43423          	sd	a4,-184(s0)
    802010cc:	0007a783          	lw	a5,0(a5)
    802010d0:	f8f42623          	sw	a5,-116(s0)
    802010d4:	5e00006f          	j	802016b4 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    802010d8:	f5043783          	ld	a5,-176(s0)
    802010dc:	f5040713          	addi	a4,s0,-176
    802010e0:	00a00613          	li	a2,10
    802010e4:	00070593          	mv	a1,a4
    802010e8:	00078513          	mv	a0,a5
    802010ec:	819ff0ef          	jal	ra,80200904 <strtol>
    802010f0:	00050793          	mv	a5,a0
    802010f4:	0007879b          	sext.w	a5,a5
    802010f8:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    802010fc:	f5043783          	ld	a5,-176(s0)
    80201100:	fff78793          	addi	a5,a5,-1
    80201104:	f4f43823          	sd	a5,-176(s0)
    80201108:	5ac0006f          	j	802016b4 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    8020110c:	f5043783          	ld	a5,-176(s0)
    80201110:	0007c783          	lbu	a5,0(a5)
    80201114:	00078713          	mv	a4,a5
    80201118:	07800793          	li	a5,120
    8020111c:	02f70663          	beq	a4,a5,80201148 <vprintfmt+0x254>
    80201120:	f5043783          	ld	a5,-176(s0)
    80201124:	0007c783          	lbu	a5,0(a5)
    80201128:	00078713          	mv	a4,a5
    8020112c:	05800793          	li	a5,88
    80201130:	00f70c63          	beq	a4,a5,80201148 <vprintfmt+0x254>
    80201134:	f5043783          	ld	a5,-176(s0)
    80201138:	0007c783          	lbu	a5,0(a5)
    8020113c:	00078713          	mv	a4,a5
    80201140:	07000793          	li	a5,112
    80201144:	2ef71e63          	bne	a4,a5,80201440 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
    80201148:	f5043783          	ld	a5,-176(s0)
    8020114c:	0007c783          	lbu	a5,0(a5)
    80201150:	00078713          	mv	a4,a5
    80201154:	07000793          	li	a5,112
    80201158:	00f70663          	beq	a4,a5,80201164 <vprintfmt+0x270>
    8020115c:	f8144783          	lbu	a5,-127(s0)
    80201160:	00078663          	beqz	a5,8020116c <vprintfmt+0x278>
    80201164:	00100793          	li	a5,1
    80201168:	0080006f          	j	80201170 <vprintfmt+0x27c>
    8020116c:	00000793          	li	a5,0
    80201170:	faf403a3          	sb	a5,-89(s0)
    80201174:	fa744783          	lbu	a5,-89(s0)
    80201178:	0017f793          	andi	a5,a5,1
    8020117c:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80201180:	fa744783          	lbu	a5,-89(s0)
    80201184:	0ff7f793          	andi	a5,a5,255
    80201188:	00078c63          	beqz	a5,802011a0 <vprintfmt+0x2ac>
    8020118c:	f4843783          	ld	a5,-184(s0)
    80201190:	00878713          	addi	a4,a5,8
    80201194:	f4e43423          	sd	a4,-184(s0)
    80201198:	0007b783          	ld	a5,0(a5)
    8020119c:	01c0006f          	j	802011b8 <vprintfmt+0x2c4>
    802011a0:	f4843783          	ld	a5,-184(s0)
    802011a4:	00878713          	addi	a4,a5,8
    802011a8:	f4e43423          	sd	a4,-184(s0)
    802011ac:	0007a783          	lw	a5,0(a5)
    802011b0:	02079793          	slli	a5,a5,0x20
    802011b4:	0207d793          	srli	a5,a5,0x20
    802011b8:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    802011bc:	f8c42783          	lw	a5,-116(s0)
    802011c0:	02079463          	bnez	a5,802011e8 <vprintfmt+0x2f4>
    802011c4:	fe043783          	ld	a5,-32(s0)
    802011c8:	02079063          	bnez	a5,802011e8 <vprintfmt+0x2f4>
    802011cc:	f5043783          	ld	a5,-176(s0)
    802011d0:	0007c783          	lbu	a5,0(a5)
    802011d4:	00078713          	mv	a4,a5
    802011d8:	07000793          	li	a5,112
    802011dc:	00f70663          	beq	a4,a5,802011e8 <vprintfmt+0x2f4>
                    flags.in_format = false;
    802011e0:	f8040023          	sb	zero,-128(s0)
    802011e4:	4d00006f          	j	802016b4 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    802011e8:	f5043783          	ld	a5,-176(s0)
    802011ec:	0007c783          	lbu	a5,0(a5)
    802011f0:	00078713          	mv	a4,a5
    802011f4:	07000793          	li	a5,112
    802011f8:	00f70a63          	beq	a4,a5,8020120c <vprintfmt+0x318>
    802011fc:	f8244783          	lbu	a5,-126(s0)
    80201200:	00078a63          	beqz	a5,80201214 <vprintfmt+0x320>
    80201204:	fe043783          	ld	a5,-32(s0)
    80201208:	00078663          	beqz	a5,80201214 <vprintfmt+0x320>
    8020120c:	00100793          	li	a5,1
    80201210:	0080006f          	j	80201218 <vprintfmt+0x324>
    80201214:	00000793          	li	a5,0
    80201218:	faf40323          	sb	a5,-90(s0)
    8020121c:	fa644783          	lbu	a5,-90(s0)
    80201220:	0017f793          	andi	a5,a5,1
    80201224:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80201228:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    8020122c:	f5043783          	ld	a5,-176(s0)
    80201230:	0007c783          	lbu	a5,0(a5)
    80201234:	00078713          	mv	a4,a5
    80201238:	05800793          	li	a5,88
    8020123c:	00f71863          	bne	a4,a5,8020124c <vprintfmt+0x358>
    80201240:	00001797          	auipc	a5,0x1
    80201244:	ec878793          	addi	a5,a5,-312 # 80202108 <upperxdigits.1101>
    80201248:	00c0006f          	j	80201254 <vprintfmt+0x360>
    8020124c:	00001797          	auipc	a5,0x1
    80201250:	ed478793          	addi	a5,a5,-300 # 80202120 <lowerxdigits.1100>
    80201254:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201258:	fe043783          	ld	a5,-32(s0)
    8020125c:	00f7f793          	andi	a5,a5,15
    80201260:	f9843703          	ld	a4,-104(s0)
    80201264:	00f70733          	add	a4,a4,a5
    80201268:	fdc42783          	lw	a5,-36(s0)
    8020126c:	0017869b          	addiw	a3,a5,1
    80201270:	fcd42e23          	sw	a3,-36(s0)
    80201274:	00074703          	lbu	a4,0(a4)
    80201278:	ff040693          	addi	a3,s0,-16
    8020127c:	00f687b3          	add	a5,a3,a5
    80201280:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201284:	fe043783          	ld	a5,-32(s0)
    80201288:	0047d793          	srli	a5,a5,0x4
    8020128c:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201290:	fe043783          	ld	a5,-32(s0)
    80201294:	fc0792e3          	bnez	a5,80201258 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201298:	f8c42783          	lw	a5,-116(s0)
    8020129c:	00078713          	mv	a4,a5
    802012a0:	fff00793          	li	a5,-1
    802012a4:	02f71663          	bne	a4,a5,802012d0 <vprintfmt+0x3dc>
    802012a8:	f8344783          	lbu	a5,-125(s0)
    802012ac:	02078263          	beqz	a5,802012d0 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    802012b0:	f8842703          	lw	a4,-120(s0)
    802012b4:	fa644783          	lbu	a5,-90(s0)
    802012b8:	0007879b          	sext.w	a5,a5
    802012bc:	0017979b          	slliw	a5,a5,0x1
    802012c0:	0007879b          	sext.w	a5,a5
    802012c4:	40f707bb          	subw	a5,a4,a5
    802012c8:	0007879b          	sext.w	a5,a5
    802012cc:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802012d0:	f8842703          	lw	a4,-120(s0)
    802012d4:	fa644783          	lbu	a5,-90(s0)
    802012d8:	0007879b          	sext.w	a5,a5
    802012dc:	0017979b          	slliw	a5,a5,0x1
    802012e0:	0007879b          	sext.w	a5,a5
    802012e4:	40f707bb          	subw	a5,a4,a5
    802012e8:	0007871b          	sext.w	a4,a5
    802012ec:	fdc42783          	lw	a5,-36(s0)
    802012f0:	f8f42a23          	sw	a5,-108(s0)
    802012f4:	f8c42783          	lw	a5,-116(s0)
    802012f8:	f8f42823          	sw	a5,-112(s0)
    802012fc:	f9442583          	lw	a1,-108(s0)
    80201300:	f9042783          	lw	a5,-112(s0)
    80201304:	0007861b          	sext.w	a2,a5
    80201308:	0005869b          	sext.w	a3,a1
    8020130c:	00d65463          	bge	a2,a3,80201314 <vprintfmt+0x420>
    80201310:	00058793          	mv	a5,a1
    80201314:	0007879b          	sext.w	a5,a5
    80201318:	40f707bb          	subw	a5,a4,a5
    8020131c:	fcf42c23          	sw	a5,-40(s0)
    80201320:	0280006f          	j	80201348 <vprintfmt+0x454>
                    putch(' ');
    80201324:	f5843783          	ld	a5,-168(s0)
    80201328:	02000513          	li	a0,32
    8020132c:	000780e7          	jalr	a5
                    ++written;
    80201330:	fec42783          	lw	a5,-20(s0)
    80201334:	0017879b          	addiw	a5,a5,1
    80201338:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    8020133c:	fd842783          	lw	a5,-40(s0)
    80201340:	fff7879b          	addiw	a5,a5,-1
    80201344:	fcf42c23          	sw	a5,-40(s0)
    80201348:	fd842783          	lw	a5,-40(s0)
    8020134c:	0007879b          	sext.w	a5,a5
    80201350:	fcf04ae3          	bgtz	a5,80201324 <vprintfmt+0x430>
                }

                if (prefix) {
    80201354:	fa644783          	lbu	a5,-90(s0)
    80201358:	0ff7f793          	andi	a5,a5,255
    8020135c:	04078463          	beqz	a5,802013a4 <vprintfmt+0x4b0>
                    putch('0');
    80201360:	f5843783          	ld	a5,-168(s0)
    80201364:	03000513          	li	a0,48
    80201368:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    8020136c:	f5043783          	ld	a5,-176(s0)
    80201370:	0007c783          	lbu	a5,0(a5)
    80201374:	00078713          	mv	a4,a5
    80201378:	05800793          	li	a5,88
    8020137c:	00f71663          	bne	a4,a5,80201388 <vprintfmt+0x494>
    80201380:	05800793          	li	a5,88
    80201384:	0080006f          	j	8020138c <vprintfmt+0x498>
    80201388:	07800793          	li	a5,120
    8020138c:	f5843703          	ld	a4,-168(s0)
    80201390:	00078513          	mv	a0,a5
    80201394:	000700e7          	jalr	a4
                    written += 2;
    80201398:	fec42783          	lw	a5,-20(s0)
    8020139c:	0027879b          	addiw	a5,a5,2
    802013a0:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    802013a4:	fdc42783          	lw	a5,-36(s0)
    802013a8:	fcf42a23          	sw	a5,-44(s0)
    802013ac:	0280006f          	j	802013d4 <vprintfmt+0x4e0>
                    putch('0');
    802013b0:	f5843783          	ld	a5,-168(s0)
    802013b4:	03000513          	li	a0,48
    802013b8:	000780e7          	jalr	a5
                    ++written;
    802013bc:	fec42783          	lw	a5,-20(s0)
    802013c0:	0017879b          	addiw	a5,a5,1
    802013c4:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    802013c8:	fd442783          	lw	a5,-44(s0)
    802013cc:	0017879b          	addiw	a5,a5,1
    802013d0:	fcf42a23          	sw	a5,-44(s0)
    802013d4:	f8c42703          	lw	a4,-116(s0)
    802013d8:	fd442783          	lw	a5,-44(s0)
    802013dc:	0007879b          	sext.w	a5,a5
    802013e0:	fce7c8e3          	blt	a5,a4,802013b0 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    802013e4:	fdc42783          	lw	a5,-36(s0)
    802013e8:	fff7879b          	addiw	a5,a5,-1
    802013ec:	fcf42823          	sw	a5,-48(s0)
    802013f0:	03c0006f          	j	8020142c <vprintfmt+0x538>
                    putch(buf[i]);
    802013f4:	fd042783          	lw	a5,-48(s0)
    802013f8:	ff040713          	addi	a4,s0,-16
    802013fc:	00f707b3          	add	a5,a4,a5
    80201400:	f807c783          	lbu	a5,-128(a5)
    80201404:	0007879b          	sext.w	a5,a5
    80201408:	f5843703          	ld	a4,-168(s0)
    8020140c:	00078513          	mv	a0,a5
    80201410:	000700e7          	jalr	a4
                    ++written;
    80201414:	fec42783          	lw	a5,-20(s0)
    80201418:	0017879b          	addiw	a5,a5,1
    8020141c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201420:	fd042783          	lw	a5,-48(s0)
    80201424:	fff7879b          	addiw	a5,a5,-1
    80201428:	fcf42823          	sw	a5,-48(s0)
    8020142c:	fd042783          	lw	a5,-48(s0)
    80201430:	0007879b          	sext.w	a5,a5
    80201434:	fc07d0e3          	bgez	a5,802013f4 <vprintfmt+0x500>
                }

                flags.in_format = false;
    80201438:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    8020143c:	2780006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201440:	f5043783          	ld	a5,-176(s0)
    80201444:	0007c783          	lbu	a5,0(a5)
    80201448:	00078713          	mv	a4,a5
    8020144c:	06400793          	li	a5,100
    80201450:	02f70663          	beq	a4,a5,8020147c <vprintfmt+0x588>
    80201454:	f5043783          	ld	a5,-176(s0)
    80201458:	0007c783          	lbu	a5,0(a5)
    8020145c:	00078713          	mv	a4,a5
    80201460:	06900793          	li	a5,105
    80201464:	00f70c63          	beq	a4,a5,8020147c <vprintfmt+0x588>
    80201468:	f5043783          	ld	a5,-176(s0)
    8020146c:	0007c783          	lbu	a5,0(a5)
    80201470:	00078713          	mv	a4,a5
    80201474:	07500793          	li	a5,117
    80201478:	08f71263          	bne	a4,a5,802014fc <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    8020147c:	f8144783          	lbu	a5,-127(s0)
    80201480:	00078c63          	beqz	a5,80201498 <vprintfmt+0x5a4>
    80201484:	f4843783          	ld	a5,-184(s0)
    80201488:	00878713          	addi	a4,a5,8
    8020148c:	f4e43423          	sd	a4,-184(s0)
    80201490:	0007b783          	ld	a5,0(a5)
    80201494:	0140006f          	j	802014a8 <vprintfmt+0x5b4>
    80201498:	f4843783          	ld	a5,-184(s0)
    8020149c:	00878713          	addi	a4,a5,8
    802014a0:	f4e43423          	sd	a4,-184(s0)
    802014a4:	0007a783          	lw	a5,0(a5)
    802014a8:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    802014ac:	fa843583          	ld	a1,-88(s0)
    802014b0:	f5043783          	ld	a5,-176(s0)
    802014b4:	0007c783          	lbu	a5,0(a5)
    802014b8:	0007871b          	sext.w	a4,a5
    802014bc:	07500793          	li	a5,117
    802014c0:	40f707b3          	sub	a5,a4,a5
    802014c4:	00f037b3          	snez	a5,a5
    802014c8:	0ff7f793          	andi	a5,a5,255
    802014cc:	f8040713          	addi	a4,s0,-128
    802014d0:	00070693          	mv	a3,a4
    802014d4:	00078613          	mv	a2,a5
    802014d8:	f5843503          	ld	a0,-168(s0)
    802014dc:	f18ff0ef          	jal	ra,80200bf4 <print_dec_int>
    802014e0:	00050793          	mv	a5,a0
    802014e4:	00078713          	mv	a4,a5
    802014e8:	fec42783          	lw	a5,-20(s0)
    802014ec:	00e787bb          	addw	a5,a5,a4
    802014f0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802014f4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802014f8:	1bc0006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    802014fc:	f5043783          	ld	a5,-176(s0)
    80201500:	0007c783          	lbu	a5,0(a5)
    80201504:	00078713          	mv	a4,a5
    80201508:	06e00793          	li	a5,110
    8020150c:	04f71c63          	bne	a4,a5,80201564 <vprintfmt+0x670>
                if (flags.longflag) {
    80201510:	f8144783          	lbu	a5,-127(s0)
    80201514:	02078463          	beqz	a5,8020153c <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
    80201518:	f4843783          	ld	a5,-184(s0)
    8020151c:	00878713          	addi	a4,a5,8
    80201520:	f4e43423          	sd	a4,-184(s0)
    80201524:	0007b783          	ld	a5,0(a5)
    80201528:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    8020152c:	fec42703          	lw	a4,-20(s0)
    80201530:	fb043783          	ld	a5,-80(s0)
    80201534:	00e7b023          	sd	a4,0(a5)
    80201538:	0240006f          	j	8020155c <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
    8020153c:	f4843783          	ld	a5,-184(s0)
    80201540:	00878713          	addi	a4,a5,8
    80201544:	f4e43423          	sd	a4,-184(s0)
    80201548:	0007b783          	ld	a5,0(a5)
    8020154c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201550:	fb843783          	ld	a5,-72(s0)
    80201554:	fec42703          	lw	a4,-20(s0)
    80201558:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    8020155c:	f8040023          	sb	zero,-128(s0)
    80201560:	1540006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201564:	f5043783          	ld	a5,-176(s0)
    80201568:	0007c783          	lbu	a5,0(a5)
    8020156c:	00078713          	mv	a4,a5
    80201570:	07300793          	li	a5,115
    80201574:	04f71063          	bne	a4,a5,802015b4 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201578:	f4843783          	ld	a5,-184(s0)
    8020157c:	00878713          	addi	a4,a5,8
    80201580:	f4e43423          	sd	a4,-184(s0)
    80201584:	0007b783          	ld	a5,0(a5)
    80201588:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    8020158c:	fc043583          	ld	a1,-64(s0)
    80201590:	f5843503          	ld	a0,-168(s0)
    80201594:	dd8ff0ef          	jal	ra,80200b6c <puts_wo_nl>
    80201598:	00050793          	mv	a5,a0
    8020159c:	00078713          	mv	a4,a5
    802015a0:	fec42783          	lw	a5,-20(s0)
    802015a4:	00e787bb          	addw	a5,a5,a4
    802015a8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802015ac:	f8040023          	sb	zero,-128(s0)
    802015b0:	1040006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    802015b4:	f5043783          	ld	a5,-176(s0)
    802015b8:	0007c783          	lbu	a5,0(a5)
    802015bc:	00078713          	mv	a4,a5
    802015c0:	06300793          	li	a5,99
    802015c4:	02f71e63          	bne	a4,a5,80201600 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    802015c8:	f4843783          	ld	a5,-184(s0)
    802015cc:	00878713          	addi	a4,a5,8
    802015d0:	f4e43423          	sd	a4,-184(s0)
    802015d4:	0007a783          	lw	a5,0(a5)
    802015d8:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    802015dc:	fcc42783          	lw	a5,-52(s0)
    802015e0:	f5843703          	ld	a4,-168(s0)
    802015e4:	00078513          	mv	a0,a5
    802015e8:	000700e7          	jalr	a4
                ++written;
    802015ec:	fec42783          	lw	a5,-20(s0)
    802015f0:	0017879b          	addiw	a5,a5,1
    802015f4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802015f8:	f8040023          	sb	zero,-128(s0)
    802015fc:	0b80006f          	j	802016b4 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201600:	f5043783          	ld	a5,-176(s0)
    80201604:	0007c783          	lbu	a5,0(a5)
    80201608:	00078713          	mv	a4,a5
    8020160c:	02500793          	li	a5,37
    80201610:	02f71263          	bne	a4,a5,80201634 <vprintfmt+0x740>
                putch('%');
    80201614:	f5843783          	ld	a5,-168(s0)
    80201618:	02500513          	li	a0,37
    8020161c:	000780e7          	jalr	a5
                ++written;
    80201620:	fec42783          	lw	a5,-20(s0)
    80201624:	0017879b          	addiw	a5,a5,1
    80201628:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020162c:	f8040023          	sb	zero,-128(s0)
    80201630:	0840006f          	j	802016b4 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201634:	f5043783          	ld	a5,-176(s0)
    80201638:	0007c783          	lbu	a5,0(a5)
    8020163c:	0007879b          	sext.w	a5,a5
    80201640:	f5843703          	ld	a4,-168(s0)
    80201644:	00078513          	mv	a0,a5
    80201648:	000700e7          	jalr	a4
                ++written;
    8020164c:	fec42783          	lw	a5,-20(s0)
    80201650:	0017879b          	addiw	a5,a5,1
    80201654:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201658:	f8040023          	sb	zero,-128(s0)
    8020165c:	0580006f          	j	802016b4 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201660:	f5043783          	ld	a5,-176(s0)
    80201664:	0007c783          	lbu	a5,0(a5)
    80201668:	00078713          	mv	a4,a5
    8020166c:	02500793          	li	a5,37
    80201670:	02f71063          	bne	a4,a5,80201690 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201674:	f8043023          	sd	zero,-128(s0)
    80201678:	f8043423          	sd	zero,-120(s0)
    8020167c:	00100793          	li	a5,1
    80201680:	f8f40023          	sb	a5,-128(s0)
    80201684:	fff00793          	li	a5,-1
    80201688:	f8f42623          	sw	a5,-116(s0)
    8020168c:	0280006f          	j	802016b4 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201690:	f5043783          	ld	a5,-176(s0)
    80201694:	0007c783          	lbu	a5,0(a5)
    80201698:	0007879b          	sext.w	a5,a5
    8020169c:	f5843703          	ld	a4,-168(s0)
    802016a0:	00078513          	mv	a0,a5
    802016a4:	000700e7          	jalr	a4
            ++written;
    802016a8:	fec42783          	lw	a5,-20(s0)
    802016ac:	0017879b          	addiw	a5,a5,1
    802016b0:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    802016b4:	f5043783          	ld	a5,-176(s0)
    802016b8:	00178793          	addi	a5,a5,1
    802016bc:	f4f43823          	sd	a5,-176(s0)
    802016c0:	f5043783          	ld	a5,-176(s0)
    802016c4:	0007c783          	lbu	a5,0(a5)
    802016c8:	84079ce3          	bnez	a5,80200f20 <vprintfmt+0x2c>
        }
    }

    return written;
    802016cc:	fec42783          	lw	a5,-20(s0)
}
    802016d0:	00078513          	mv	a0,a5
    802016d4:	0b813083          	ld	ra,184(sp)
    802016d8:	0b013403          	ld	s0,176(sp)
    802016dc:	0c010113          	addi	sp,sp,192
    802016e0:	00008067          	ret

00000000802016e4 <printk>:

int printk(const char* s, ...) {
    802016e4:	f9010113          	addi	sp,sp,-112
    802016e8:	02113423          	sd	ra,40(sp)
    802016ec:	02813023          	sd	s0,32(sp)
    802016f0:	03010413          	addi	s0,sp,48
    802016f4:	fca43c23          	sd	a0,-40(s0)
    802016f8:	00b43423          	sd	a1,8(s0)
    802016fc:	00c43823          	sd	a2,16(s0)
    80201700:	00d43c23          	sd	a3,24(s0)
    80201704:	02e43023          	sd	a4,32(s0)
    80201708:	02f43423          	sd	a5,40(s0)
    8020170c:	03043823          	sd	a6,48(s0)
    80201710:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201714:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201718:	04040793          	addi	a5,s0,64
    8020171c:	fcf43823          	sd	a5,-48(s0)
    80201720:	fd043783          	ld	a5,-48(s0)
    80201724:	fc878793          	addi	a5,a5,-56
    80201728:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    8020172c:	fe043783          	ld	a5,-32(s0)
    80201730:	00078613          	mv	a2,a5
    80201734:	fd843583          	ld	a1,-40(s0)
    80201738:	fffff517          	auipc	a0,0xfffff
    8020173c:	12450513          	addi	a0,a0,292 # 8020085c <putc>
    80201740:	fb4ff0ef          	jal	ra,80200ef4 <vprintfmt>
    80201744:	00050793          	mv	a5,a0
    80201748:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    8020174c:	fec42783          	lw	a5,-20(s0)
}
    80201750:	00078513          	mv	a0,a5
    80201754:	02813083          	ld	ra,40(sp)
    80201758:	02013403          	ld	s0,32(sp)
    8020175c:	07010113          	addi	sp,sp,112
    80201760:	00008067          	ret

0000000080201764 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201764:	fe010113          	addi	sp,sp,-32
    80201768:	00813c23          	sd	s0,24(sp)
    8020176c:	02010413          	addi	s0,sp,32
    80201770:	00050793          	mv	a5,a0
    80201774:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201778:	fec42783          	lw	a5,-20(s0)
    8020177c:	fff7879b          	addiw	a5,a5,-1
    80201780:	0007879b          	sext.w	a5,a5
    80201784:	02079713          	slli	a4,a5,0x20
    80201788:	02075713          	srli	a4,a4,0x20
    8020178c:	00004797          	auipc	a5,0x4
    80201790:	87478793          	addi	a5,a5,-1932 # 80205000 <seed>
    80201794:	00e7b023          	sd	a4,0(a5)
}
    80201798:	00000013          	nop
    8020179c:	01813403          	ld	s0,24(sp)
    802017a0:	02010113          	addi	sp,sp,32
    802017a4:	00008067          	ret

00000000802017a8 <rand>:

int rand(void) {
    802017a8:	ff010113          	addi	sp,sp,-16
    802017ac:	00813423          	sd	s0,8(sp)
    802017b0:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    802017b4:	00004797          	auipc	a5,0x4
    802017b8:	84c78793          	addi	a5,a5,-1972 # 80205000 <seed>
    802017bc:	0007b703          	ld	a4,0(a5)
    802017c0:	00001797          	auipc	a5,0x1
    802017c4:	97878793          	addi	a5,a5,-1672 # 80202138 <lowerxdigits.1100+0x18>
    802017c8:	0007b783          	ld	a5,0(a5)
    802017cc:	02f707b3          	mul	a5,a4,a5
    802017d0:	00178713          	addi	a4,a5,1
    802017d4:	00004797          	auipc	a5,0x4
    802017d8:	82c78793          	addi	a5,a5,-2004 # 80205000 <seed>
    802017dc:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    802017e0:	00004797          	auipc	a5,0x4
    802017e4:	82078793          	addi	a5,a5,-2016 # 80205000 <seed>
    802017e8:	0007b783          	ld	a5,0(a5)
    802017ec:	0217d793          	srli	a5,a5,0x21
    802017f0:	0007879b          	sext.w	a5,a5
}
    802017f4:	00078513          	mv	a0,a5
    802017f8:	00813403          	ld	s0,8(sp)
    802017fc:	01010113          	addi	sp,sp,16
    80201800:	00008067          	ret

0000000080201804 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201804:	fc010113          	addi	sp,sp,-64
    80201808:	02813c23          	sd	s0,56(sp)
    8020180c:	04010413          	addi	s0,sp,64
    80201810:	fca43c23          	sd	a0,-40(s0)
    80201814:	00058793          	mv	a5,a1
    80201818:	fcc43423          	sd	a2,-56(s0)
    8020181c:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201820:	fd843783          	ld	a5,-40(s0)
    80201824:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201828:	fe043423          	sd	zero,-24(s0)
    8020182c:	0280006f          	j	80201854 <memset+0x50>
        s[i] = c;
    80201830:	fe043703          	ld	a4,-32(s0)
    80201834:	fe843783          	ld	a5,-24(s0)
    80201838:	00f707b3          	add	a5,a4,a5
    8020183c:	fd442703          	lw	a4,-44(s0)
    80201840:	0ff77713          	andi	a4,a4,255
    80201844:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201848:	fe843783          	ld	a5,-24(s0)
    8020184c:	00178793          	addi	a5,a5,1
    80201850:	fef43423          	sd	a5,-24(s0)
    80201854:	fe843703          	ld	a4,-24(s0)
    80201858:	fc843783          	ld	a5,-56(s0)
    8020185c:	fcf76ae3          	bltu	a4,a5,80201830 <memset+0x2c>
    }
    return dest;
    80201860:	fd843783          	ld	a5,-40(s0)
}
    80201864:	00078513          	mv	a0,a5
    80201868:	03813403          	ld	s0,56(sp)
    8020186c:	04010113          	addi	sp,sp,64
    80201870:	00008067          	ret
