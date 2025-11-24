
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm_final
    .extern PA2VA_OFFSET
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶
ffffffe000200000:	00007117          	auipc	sp,0x7
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm  #映射
ffffffe000200008:	6d0010ef          	jal	ra,ffffffe0002016d8 <setup_vm>
    call relocate
ffffffe00020000c:	044000ef          	jal	ra,ffffffe000200050 <relocate>
    call mm_init #初始化内存管理系统
ffffffe000200010:	2c1000ef          	jal	ra,ffffffe000200ad0 <mm_init>
    call task_init #初始化线程数据结构 
ffffffe000200014:	36d000ef          	jal	ra,ffffffe000200b80 <task_init>
    call setup_vm_final
ffffffe000200018:	1c5010ef          	jal	ra,ffffffe0002019dc <setup_vm_final>
    
    # set stvec = _traps
    la t0,_traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	0ac28293          	addi	t0,t0,172 # ffffffe0002000c8 <_traps>
    csrw stvec,t0
ffffffe000200024:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
ffffffe000200028:	02000293          	li	t0,32
    csrs sie,t0
ffffffe00020002c:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
ffffffe000200030:	2c8000ef          	jal	ra,ffffffe0002002f8 <get_cycles>
    li t0,10000000
ffffffe000200034:	009892b7          	lui	t0,0x989
ffffffe000200038:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
ffffffe00020003c:	00550533          	add	a0,a0,t0
    call sbi_set_timer
ffffffe000200040:	43c010ef          	jal	ra,ffffffe00020147c <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
ffffffe000200044:	00200293          	li	t0,2
    csrs sstatus,t0
ffffffe000200048:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
ffffffe00020004c:	3a50106f          	j	ffffffe000201bf0 <start_kernel>

ffffffe000200050 <relocate>:

    .globl relocate
relocate:
    # PA2VA_OFFSET=0xffffffdf80000000
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

    # need a fence to ensure the new translations are in use
    sfence.vma zero,zero      
ffffffe000200074:	12000073          	sfence.vma

    # set satp
    la t0,early_pgtbl
ffffffe000200078:	0000a297          	auipc	t0,0xa
ffffffe00020007c:	f8828293          	addi	t0,t0,-120 # ffffffe00020a000 <early_pgtbl>
    srli t0,t0,12
ffffffe000200080:	00c2d293          	srli	t0,t0,0xc
    li t1,(8<<60)    # MODE=8 Sv39
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

ffffffe00020009c <set_trap>:

    .globl set_trap
set_trap:
     # PA2VA_OFFSET=0xffffffdf80000000
    li t2,0x80000000
ffffffe00020009c:	0010039b          	addiw	t2,zero,1
ffffffe0002000a0:	01f39393          	slli	t2,t2,0x1f
    li t3,0xffffffdf
ffffffe0002000a4:	00100e1b          	addiw	t3,zero,1
ffffffe0002000a8:	020e1e13          	slli	t3,t3,0x20
ffffffe0002000ac:	fdfe0e13          	addi	t3,t3,-33
    slli t3,t3,32
ffffffe0002000b0:	020e1e13          	slli	t3,t3,0x20
    or t2,t2,t3
ffffffe0002000b4:	01c3e3b3          	or	t2,t2,t3

    csrr t3,sepc
ffffffe0002000b8:	14102e73          	csrr	t3,sepc
    add t3,t3,t2
ffffffe0002000bc:	007e0e33          	add	t3,t3,t2
    csrw sepc,t3
ffffffe0002000c0:	141e1073          	csrw	sepc,t3

    sret
ffffffe0002000c4:	10200073          	sret

ffffffe0002000c8 <_traps>:
    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    addi sp,sp,-33*8   # 开辟栈空间
ffffffe0002000c8:	ef810113          	addi	sp,sp,-264 # ffffffe000206ef8 <_sbss+0xef8>
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
ffffffe0002000cc:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)
ffffffe0002000d0:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)
ffffffe0002000d4:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)
ffffffe0002000d8:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)
ffffffe0002000dc:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)
ffffffe0002000e0:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
ffffffe0002000e4:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
ffffffe0002000e8:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)
ffffffe0002000ec:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)
ffffffe0002000f0:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)
ffffffe0002000f4:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
ffffffe0002000f8:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
ffffffe0002000fc:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
ffffffe000200100:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
ffffffe000200104:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
ffffffe000200108:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
ffffffe00020010c:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
ffffffe000200110:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)
ffffffe000200114:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
ffffffe000200118:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
ffffffe00020011c:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
ffffffe000200120:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
ffffffe000200124:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
ffffffe000200128:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
ffffffe00020012c:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
ffffffe000200130:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
ffffffe000200134:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
ffffffe000200138:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)
ffffffe00020013c:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
ffffffe000200140:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
ffffffe000200144:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
ffffffe000200148:	0ff13c23          	sd	t6,248(sp)
    csrr t0,sepc
ffffffe00020014c:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
ffffffe000200150:	10513023          	sd	t0,256(sp)

    # call trap_handler
    csrr a0,scause
ffffffe000200154:	14202573          	csrr	a0,scause
    csrr a1,sepc
ffffffe000200158:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe00020015c:	4f0010ef          	jal	ra,ffffffe00020164c <trap_handler>

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
ffffffe000200160:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
ffffffe000200164:	14129073          	csrw	sepc,t0

    ld x31,31*8(sp)
ffffffe000200168:	0f813f83          	ld	t6,248(sp)
    ld x30,30*8(sp)
ffffffe00020016c:	0f013f03          	ld	t5,240(sp)
    ld x29,29*8(sp)
ffffffe000200170:	0e813e83          	ld	t4,232(sp)
    ld x28,28*8(sp)
ffffffe000200174:	0e013e03          	ld	t3,224(sp)
    ld x27,27*8(sp)
ffffffe000200178:	0d813d83          	ld	s11,216(sp)
    ld x26,26*8(sp)
ffffffe00020017c:	0d013d03          	ld	s10,208(sp)
    ld x25,25*8(sp)
ffffffe000200180:	0c813c83          	ld	s9,200(sp)
    ld x24,24*8(sp)
ffffffe000200184:	0c013c03          	ld	s8,192(sp)
    ld x23,23*8(sp)
ffffffe000200188:	0b813b83          	ld	s7,184(sp)
    ld x22,22*8(sp)
ffffffe00020018c:	0b013b03          	ld	s6,176(sp)
    ld x21,21*8(sp)
ffffffe000200190:	0a813a83          	ld	s5,168(sp)
    ld x20,20*8(sp)
ffffffe000200194:	0a013a03          	ld	s4,160(sp)
    ld x19,19*8(sp)
ffffffe000200198:	09813983          	ld	s3,152(sp)
    ld x18,18*8(sp)
ffffffe00020019c:	09013903          	ld	s2,144(sp)
    ld x17,17*8(sp)
ffffffe0002001a0:	08813883          	ld	a7,136(sp)
    ld x16,16*8(sp)
ffffffe0002001a4:	08013803          	ld	a6,128(sp)
    ld x15,15*8(sp)
ffffffe0002001a8:	07813783          	ld	a5,120(sp)
    ld x14,14*8(sp)
ffffffe0002001ac:	07013703          	ld	a4,112(sp)
    ld x13,13*8(sp)
ffffffe0002001b0:	06813683          	ld	a3,104(sp)
    ld x12,12*8(sp)
ffffffe0002001b4:	06013603          	ld	a2,96(sp)
    ld x11,11*8(sp)
ffffffe0002001b8:	05813583          	ld	a1,88(sp)
    ld x10,10*8(sp)
ffffffe0002001bc:	05013503          	ld	a0,80(sp)
    ld x9,9*8(sp)
ffffffe0002001c0:	04813483          	ld	s1,72(sp)
    ld x8,8*8(sp)
ffffffe0002001c4:	04013403          	ld	s0,64(sp)
    ld x7,7*8(sp)
ffffffe0002001c8:	03813383          	ld	t2,56(sp)
    ld x6,6*8(sp)
ffffffe0002001cc:	03013303          	ld	t1,48(sp)
    ld x5,5*8(sp)
ffffffe0002001d0:	02813283          	ld	t0,40(sp)
    ld x4,4*8(sp)
ffffffe0002001d4:	02013203          	ld	tp,32(sp)
    ld x3,3*8(sp)
ffffffe0002001d8:	01813183          	ld	gp,24(sp)
    ld x1,1*8(sp)
ffffffe0002001dc:	00813083          	ld	ra,8(sp)
    ld x0,0*8(sp)
ffffffe0002001e0:	00013003          	ld	zero,0(sp)
    ld x2,2*8(sp)
ffffffe0002001e4:	01013103          	ld	sp,16(sp)
    addi sp,sp,33*8   # 释放栈空间
ffffffe0002001e8:	10810113          	addi	sp,sp,264

    # return from trap
    sret
ffffffe0002001ec:	10200073          	sret

ffffffe0002001f0 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    la t0,dummy
ffffffe0002001f0:	00001297          	auipc	t0,0x1
ffffffe0002001f4:	dbc28293          	addi	t0,t0,-580 # ffffffe000200fac <dummy>
    csrw sepc,t0
ffffffe0002001f8:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001fc:	10200073          	sret

ffffffe000200200 <__switch_to>:

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
ffffffe000200200:	02153023          	sd	ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
ffffffe000200204:	02253423          	sd	sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
ffffffe000200208:	02853823          	sd	s0,48(a0)
    sd s1,56(a0)
ffffffe00020020c:	02953c23          	sd	s1,56(a0)
    sd s2,64(a0)
ffffffe000200210:	05253023          	sd	s2,64(a0)
    sd s3,72(a0)
ffffffe000200214:	05353423          	sd	s3,72(a0)
    sd s4,80(a0)
ffffffe000200218:	05453823          	sd	s4,80(a0)
    sd s5,88(a0)
ffffffe00020021c:	05553c23          	sd	s5,88(a0)
    sd s6,96(a0)
ffffffe000200220:	07653023          	sd	s6,96(a0)
    sd s7,104(a0)
ffffffe000200224:	07753423          	sd	s7,104(a0)
    sd s8,112(a0)
ffffffe000200228:	07853823          	sd	s8,112(a0)
    sd s9,120(a0)
ffffffe00020022c:	07953c23          	sd	s9,120(a0)
    sd s10,128(a0)
ffffffe000200230:	09a53023          	sd	s10,128(a0)
    sd s11,136(a0)
ffffffe000200234:	09b53423          	sd	s11,136(a0)

    # 保存 sepc ,sstatus,sscratch
    csrr t0,sepc
ffffffe000200238:	141022f3          	csrr	t0,sepc
    sd t0,152(a0)
ffffffe00020023c:	08553c23          	sd	t0,152(a0)
    csrr t0,sstatus
ffffffe000200240:	100022f3          	csrr	t0,sstatus
    sd t0,160(a0)
ffffffe000200244:	0a553023          	sd	t0,160(a0)
    csrr t0,sscratch
ffffffe000200248:	140022f3          	csrr	t0,sscratch
    sd t0,168(a0)
ffffffe00020024c:	0a553423          	sd	t0,168(a0)

    # 切换页表
    li t0,0x80000000
ffffffe000200250:	0010029b          	addiw	t0,zero,1
ffffffe000200254:	01f29293          	slli	t0,t0,0x1f
    li t1,0xffffffdf
ffffffe000200258:	0010031b          	addiw	t1,zero,1
ffffffe00020025c:	02031313          	slli	t1,t1,0x20
ffffffe000200260:	fdf30313          	addi	t1,t1,-33
    slli t1,t1,32
ffffffe000200264:	02031313          	slli	t1,t1,0x20
    or t0,t0,t1         # PA2VA_OFFSET=0xffffffdf80000000
ffffffe000200268:	0062e2b3          	or	t0,t0,t1
    ld t1,176(a1)       # next->pgd
ffffffe00020026c:	0b05b303          	ld	t1,176(a1)
    sub t1,t1,t0        # 物理地址
ffffffe000200270:	40530333          	sub	t1,t1,t0
    srli t1,t1,12       # PPN
ffffffe000200274:	00c35313          	srli	t1,t1,0xc
    li t0,(8<<60)       # MOOD=8 SV39
ffffffe000200278:	fff0029b          	addiw	t0,zero,-1
ffffffe00020027c:	03f29293          	slli	t0,t0,0x3f
    or t0,t0,t1
ffffffe000200280:	0062e2b3          	or	t0,t0,t1
    csrw satp,t0
ffffffe000200284:	18029073          	csrw	satp,t0
    sfence.vma zero, zero
ffffffe000200288:	12000073          	sfence.vma

    # 恢复下一个进程 sepc,sstatus,sscratch
    ld t0,152(a0)
ffffffe00020028c:	09853283          	ld	t0,152(a0)
    csrw sepc,t0
ffffffe000200290:	14129073          	csrw	sepc,t0
    ld t0,160(a0)
ffffffe000200294:	0a053283          	ld	t0,160(a0)
    csrw sstatus,t0
ffffffe000200298:	10029073          	csrw	sstatus,t0
    ld t0,168(a0)
ffffffe00020029c:	0a853283          	ld	t0,168(a0)
    csrw sscratch,t0
ffffffe0002002a0:	14029073          	csrw	sscratch,t0


    #next是否为第一次调度
    ld t0,144(a1)
ffffffe0002002a4:	0905b283          	ld	t0,144(a1)
    beqz t0,first_schedule
ffffffe0002002a8:	04028063          	beqz	t0,ffffffe0002002e8 <first_schedule>

    #恢复下一个进程上下文
    ld ra,32(a1)
ffffffe0002002ac:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe0002002b0:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
ffffffe0002002b4:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
ffffffe0002002b8:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
ffffffe0002002bc:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
ffffffe0002002c0:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
ffffffe0002002c4:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
ffffffe0002002c8:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
ffffffe0002002cc:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
ffffffe0002002d0:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
ffffffe0002002d4:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
ffffffe0002002d8:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
ffffffe0002002dc:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
ffffffe0002002e0:	0885bd83          	ld	s11,136(a1)


    j switch_done
ffffffe0002002e4:	0100006f          	j	ffffffe0002002f4 <switch_done>

ffffffe0002002e8 <first_schedule>:

first_schedule:
    ld ra,32(a1)
ffffffe0002002e8:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe0002002ec:	0285b103          	ld	sp,40(a1)
    j switch_done
ffffffe0002002f0:	0040006f          	j	ffffffe0002002f4 <switch_done>

ffffffe0002002f4 <switch_done>:

switch_done:
    ret
ffffffe0002002f4:	00008067          	ret

ffffffe0002002f8 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe0002002f8:	fe010113          	addi	sp,sp,-32
ffffffe0002002fc:	00813c23          	sd	s0,24(sp)
ffffffe000200300:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
ffffffe000200304:	c01027f3          	rdtime	a5
ffffffe000200308:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
ffffffe00020030c:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200310:	00078513          	mv	a0,a5
ffffffe000200314:	01813403          	ld	s0,24(sp)
ffffffe000200318:	02010113          	addi	sp,sp,32
ffffffe00020031c:	00008067          	ret

ffffffe000200320 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200320:	fe010113          	addi	sp,sp,-32
ffffffe000200324:	00113c23          	sd	ra,24(sp)
ffffffe000200328:	00813823          	sd	s0,16(sp)
ffffffe00020032c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200330:	fc9ff0ef          	jal	ra,ffffffe0002002f8 <get_cycles>
ffffffe000200334:	00050713          	mv	a4,a0
ffffffe000200338:	00004797          	auipc	a5,0x4
ffffffe00020033c:	cc878793          	addi	a5,a5,-824 # ffffffe000204000 <TIMECLOCK>
ffffffe000200340:	0007b783          	ld	a5,0(a5)
ffffffe000200344:	00f707b3          	add	a5,a4,a5
ffffffe000200348:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
ffffffe00020034c:	fe843503          	ld	a0,-24(s0)
ffffffe000200350:	12c010ef          	jal	ra,ffffffe00020147c <sbi_set_timer>
ffffffe000200354:	00000013          	nop
ffffffe000200358:	01813083          	ld	ra,24(sp)
ffffffe00020035c:	01013403          	ld	s0,16(sp)
ffffffe000200360:	02010113          	addi	sp,sp,32
ffffffe000200364:	00008067          	ret

ffffffe000200368 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200368:	fe010113          	addi	sp,sp,-32
ffffffe00020036c:	00813c23          	sd	s0,24(sp)
ffffffe000200370:	02010413          	addi	s0,sp,32
ffffffe000200374:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe000200378:	fe843783          	ld	a5,-24(s0)
ffffffe00020037c:	fff78793          	addi	a5,a5,-1
ffffffe000200380:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe000200384:	fe843783          	ld	a5,-24(s0)
ffffffe000200388:	0017d793          	srli	a5,a5,0x1
ffffffe00020038c:	fe843703          	ld	a4,-24(s0)
ffffffe000200390:	00f767b3          	or	a5,a4,a5
ffffffe000200394:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe000200398:	fe843783          	ld	a5,-24(s0)
ffffffe00020039c:	0027d793          	srli	a5,a5,0x2
ffffffe0002003a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003a4:	00f767b3          	or	a5,a4,a5
ffffffe0002003a8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe0002003ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b0:	0047d793          	srli	a5,a5,0x4
ffffffe0002003b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003b8:	00f767b3          	or	a5,a4,a5
ffffffe0002003bc:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe0002003c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003c4:	0087d793          	srli	a5,a5,0x8
ffffffe0002003c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002003cc:	00f767b3          	or	a5,a4,a5
ffffffe0002003d0:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe0002003d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003d8:	0107d793          	srli	a5,a5,0x10
ffffffe0002003dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e0:	00f767b3          	or	a5,a4,a5
ffffffe0002003e4:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe0002003e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003ec:	0207d793          	srli	a5,a5,0x20
ffffffe0002003f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f4:	00f767b3          	or	a5,a4,a5
ffffffe0002003f8:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe0002003fc:	fe843783          	ld	a5,-24(s0)
ffffffe000200400:	00178793          	addi	a5,a5,1
}
ffffffe000200404:	00078513          	mv	a0,a5
ffffffe000200408:	01813403          	ld	s0,24(sp)
ffffffe00020040c:	02010113          	addi	sp,sp,32
ffffffe000200410:	00008067          	ret

ffffffe000200414 <buddy_init>:

void buddy_init() {
ffffffe000200414:	fd010113          	addi	sp,sp,-48
ffffffe000200418:	02113423          	sd	ra,40(sp)
ffffffe00020041c:	02813023          	sd	s0,32(sp)
ffffffe000200420:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe000200424:	000087b7          	lui	a5,0x8
ffffffe000200428:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe00020042c:	fe843783          	ld	a5,-24(s0)
ffffffe000200430:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe000200434:	fe843783          	ld	a5,-24(s0)
ffffffe000200438:	00f777b3          	and	a5,a4,a5
ffffffe00020043c:	00078863          	beqz	a5,ffffffe00020044c <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe000200440:	fe843503          	ld	a0,-24(s0)
ffffffe000200444:	f25ff0ef          	jal	ra,ffffffe000200368 <fixsize>
ffffffe000200448:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe00020044c:	00007797          	auipc	a5,0x7
ffffffe000200450:	bc478793          	addi	a5,a5,-1084 # ffffffe000207010 <buddy>
ffffffe000200454:	fe843703          	ld	a4,-24(s0)
ffffffe000200458:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe00020045c:	00004797          	auipc	a5,0x4
ffffffe000200460:	bac78793          	addi	a5,a5,-1108 # ffffffe000204008 <free_page_start>
ffffffe000200464:	0007b703          	ld	a4,0(a5)
ffffffe000200468:	00007797          	auipc	a5,0x7
ffffffe00020046c:	ba878793          	addi	a5,a5,-1112 # ffffffe000207010 <buddy>
ffffffe000200470:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe000200474:	00004797          	auipc	a5,0x4
ffffffe000200478:	b9478793          	addi	a5,a5,-1132 # ffffffe000204008 <free_page_start>
ffffffe00020047c:	0007b703          	ld	a4,0(a5)
ffffffe000200480:	00007797          	auipc	a5,0x7
ffffffe000200484:	b9078793          	addi	a5,a5,-1136 # ffffffe000207010 <buddy>
ffffffe000200488:	0007b783          	ld	a5,0(a5)
ffffffe00020048c:	00479793          	slli	a5,a5,0x4
ffffffe000200490:	00f70733          	add	a4,a4,a5
ffffffe000200494:	00004797          	auipc	a5,0x4
ffffffe000200498:	b7478793          	addi	a5,a5,-1164 # ffffffe000204008 <free_page_start>
ffffffe00020049c:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe0002004a0:	00007797          	auipc	a5,0x7
ffffffe0002004a4:	b7078793          	addi	a5,a5,-1168 # ffffffe000207010 <buddy>
ffffffe0002004a8:	0087b703          	ld	a4,8(a5)
ffffffe0002004ac:	00007797          	auipc	a5,0x7
ffffffe0002004b0:	b6478793          	addi	a5,a5,-1180 # ffffffe000207010 <buddy>
ffffffe0002004b4:	0007b783          	ld	a5,0(a5)
ffffffe0002004b8:	00479793          	slli	a5,a5,0x4
ffffffe0002004bc:	00078613          	mv	a2,a5
ffffffe0002004c0:	00000593          	li	a1,0
ffffffe0002004c4:	00070513          	mv	a0,a4
ffffffe0002004c8:	760020ef          	jal	ra,ffffffe000202c28 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe0002004cc:	00007797          	auipc	a5,0x7
ffffffe0002004d0:	b4478793          	addi	a5,a5,-1212 # ffffffe000207010 <buddy>
ffffffe0002004d4:	0007b783          	ld	a5,0(a5)
ffffffe0002004d8:	00179793          	slli	a5,a5,0x1
ffffffe0002004dc:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004e0:	fc043c23          	sd	zero,-40(s0)
ffffffe0002004e4:	0500006f          	j	ffffffe000200534 <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe0002004e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002004ec:	00178713          	addi	a4,a5,1
ffffffe0002004f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002004f4:	00f777b3          	and	a5,a4,a5
ffffffe0002004f8:	00079863          	bnez	a5,ffffffe000200508 <buddy_init+0xf4>
            node_size /= 2;
ffffffe0002004fc:	fe043783          	ld	a5,-32(s0)
ffffffe000200500:	0017d793          	srli	a5,a5,0x1
ffffffe000200504:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe000200508:	00007797          	auipc	a5,0x7
ffffffe00020050c:	b0878793          	addi	a5,a5,-1272 # ffffffe000207010 <buddy>
ffffffe000200510:	0087b703          	ld	a4,8(a5)
ffffffe000200514:	fd843783          	ld	a5,-40(s0)
ffffffe000200518:	00379793          	slli	a5,a5,0x3
ffffffe00020051c:	00f707b3          	add	a5,a4,a5
ffffffe000200520:	fe043703          	ld	a4,-32(s0)
ffffffe000200524:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200528:	fd843783          	ld	a5,-40(s0)
ffffffe00020052c:	00178793          	addi	a5,a5,1
ffffffe000200530:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200534:	00007797          	auipc	a5,0x7
ffffffe000200538:	adc78793          	addi	a5,a5,-1316 # ffffffe000207010 <buddy>
ffffffe00020053c:	0007b783          	ld	a5,0(a5)
ffffffe000200540:	00179793          	slli	a5,a5,0x1
ffffffe000200544:	fff78793          	addi	a5,a5,-1
ffffffe000200548:	fd843703          	ld	a4,-40(s0)
ffffffe00020054c:	f8f76ee3          	bltu	a4,a5,ffffffe0002004e8 <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200550:	fc043823          	sd	zero,-48(s0)
ffffffe000200554:	0180006f          	j	ffffffe00020056c <buddy_init+0x158>
        buddy_alloc(1);
ffffffe000200558:	00100513          	li	a0,1
ffffffe00020055c:	1fc000ef          	jal	ra,ffffffe000200758 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200560:	fd043783          	ld	a5,-48(s0)
ffffffe000200564:	00178793          	addi	a5,a5,1
ffffffe000200568:	fcf43823          	sd	a5,-48(s0)
ffffffe00020056c:	fd043783          	ld	a5,-48(s0)
ffffffe000200570:	00c79713          	slli	a4,a5,0xc
ffffffe000200574:	00100793          	li	a5,1
ffffffe000200578:	01f79793          	slli	a5,a5,0x1f
ffffffe00020057c:	00f70733          	add	a4,a4,a5
ffffffe000200580:	00004797          	auipc	a5,0x4
ffffffe000200584:	a8878793          	addi	a5,a5,-1400 # ffffffe000204008 <free_page_start>
ffffffe000200588:	0007b783          	ld	a5,0(a5)
ffffffe00020058c:	00078693          	mv	a3,a5
ffffffe000200590:	04100793          	li	a5,65
ffffffe000200594:	01f79793          	slli	a5,a5,0x1f
ffffffe000200598:	00f687b3          	add	a5,a3,a5
ffffffe00020059c:	faf76ee3          	bltu	a4,a5,ffffffe000200558 <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe0002005a0:	00003517          	auipc	a0,0x3
ffffffe0002005a4:	a6050513          	addi	a0,a0,-1440 # ffffffe000203000 <_srodata>
ffffffe0002005a8:	560020ef          	jal	ra,ffffffe000202b08 <printk>
    return;
ffffffe0002005ac:	00000013          	nop
}
ffffffe0002005b0:	02813083          	ld	ra,40(sp)
ffffffe0002005b4:	02013403          	ld	s0,32(sp)
ffffffe0002005b8:	03010113          	addi	sp,sp,48
ffffffe0002005bc:	00008067          	ret

ffffffe0002005c0 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe0002005c0:	fc010113          	addi	sp,sp,-64
ffffffe0002005c4:	02813c23          	sd	s0,56(sp)
ffffffe0002005c8:	04010413          	addi	s0,sp,64
ffffffe0002005cc:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe0002005d0:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe0002005d4:	00100793          	li	a5,1
ffffffe0002005d8:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe0002005dc:	00007797          	auipc	a5,0x7
ffffffe0002005e0:	a3478793          	addi	a5,a5,-1484 # ffffffe000207010 <buddy>
ffffffe0002005e4:	0007b703          	ld	a4,0(a5)
ffffffe0002005e8:	fc843783          	ld	a5,-56(s0)
ffffffe0002005ec:	00f707b3          	add	a5,a4,a5
ffffffe0002005f0:	fff78793          	addi	a5,a5,-1
ffffffe0002005f4:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005f8:	02c0006f          	j	ffffffe000200624 <buddy_free+0x64>
        node_size *= 2;
ffffffe0002005fc:	fe843783          	ld	a5,-24(s0)
ffffffe000200600:	00179793          	slli	a5,a5,0x1
ffffffe000200604:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe000200608:	fe043783          	ld	a5,-32(s0)
ffffffe00020060c:	02078e63          	beqz	a5,ffffffe000200648 <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200610:	fe043783          	ld	a5,-32(s0)
ffffffe000200614:	00178793          	addi	a5,a5,1
ffffffe000200618:	0017d793          	srli	a5,a5,0x1
ffffffe00020061c:	fff78793          	addi	a5,a5,-1
ffffffe000200620:	fef43023          	sd	a5,-32(s0)
ffffffe000200624:	00007797          	auipc	a5,0x7
ffffffe000200628:	9ec78793          	addi	a5,a5,-1556 # ffffffe000207010 <buddy>
ffffffe00020062c:	0087b703          	ld	a4,8(a5)
ffffffe000200630:	fe043783          	ld	a5,-32(s0)
ffffffe000200634:	00379793          	slli	a5,a5,0x3
ffffffe000200638:	00f707b3          	add	a5,a4,a5
ffffffe00020063c:	0007b783          	ld	a5,0(a5)
ffffffe000200640:	fa079ee3          	bnez	a5,ffffffe0002005fc <buddy_free+0x3c>
ffffffe000200644:	0080006f          	j	ffffffe00020064c <buddy_free+0x8c>
            break;
ffffffe000200648:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe00020064c:	00007797          	auipc	a5,0x7
ffffffe000200650:	9c478793          	addi	a5,a5,-1596 # ffffffe000207010 <buddy>
ffffffe000200654:	0087b703          	ld	a4,8(a5)
ffffffe000200658:	fe043783          	ld	a5,-32(s0)
ffffffe00020065c:	00379793          	slli	a5,a5,0x3
ffffffe000200660:	00f707b3          	add	a5,a4,a5
ffffffe000200664:	fe843703          	ld	a4,-24(s0)
ffffffe000200668:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe00020066c:	0d00006f          	j	ffffffe00020073c <buddy_free+0x17c>
        index = PARENT(index);
ffffffe000200670:	fe043783          	ld	a5,-32(s0)
ffffffe000200674:	00178793          	addi	a5,a5,1
ffffffe000200678:	0017d793          	srli	a5,a5,0x1
ffffffe00020067c:	fff78793          	addi	a5,a5,-1
ffffffe000200680:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe000200684:	fe843783          	ld	a5,-24(s0)
ffffffe000200688:	00179793          	slli	a5,a5,0x1
ffffffe00020068c:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe000200690:	00007797          	auipc	a5,0x7
ffffffe000200694:	98078793          	addi	a5,a5,-1664 # ffffffe000207010 <buddy>
ffffffe000200698:	0087b703          	ld	a4,8(a5)
ffffffe00020069c:	fe043783          	ld	a5,-32(s0)
ffffffe0002006a0:	00479793          	slli	a5,a5,0x4
ffffffe0002006a4:	00878793          	addi	a5,a5,8
ffffffe0002006a8:	00f707b3          	add	a5,a4,a5
ffffffe0002006ac:	0007b783          	ld	a5,0(a5)
ffffffe0002006b0:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe0002006b4:	00007797          	auipc	a5,0x7
ffffffe0002006b8:	95c78793          	addi	a5,a5,-1700 # ffffffe000207010 <buddy>
ffffffe0002006bc:	0087b703          	ld	a4,8(a5)
ffffffe0002006c0:	fe043783          	ld	a5,-32(s0)
ffffffe0002006c4:	00178793          	addi	a5,a5,1
ffffffe0002006c8:	00479793          	slli	a5,a5,0x4
ffffffe0002006cc:	00f707b3          	add	a5,a4,a5
ffffffe0002006d0:	0007b783          	ld	a5,0(a5)
ffffffe0002006d4:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe0002006d8:	fd843703          	ld	a4,-40(s0)
ffffffe0002006dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002006e0:	00f707b3          	add	a5,a4,a5
ffffffe0002006e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002006e8:	02f71463          	bne	a4,a5,ffffffe000200710 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe0002006ec:	00007797          	auipc	a5,0x7
ffffffe0002006f0:	92478793          	addi	a5,a5,-1756 # ffffffe000207010 <buddy>
ffffffe0002006f4:	0087b703          	ld	a4,8(a5)
ffffffe0002006f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002006fc:	00379793          	slli	a5,a5,0x3
ffffffe000200700:	00f707b3          	add	a5,a4,a5
ffffffe000200704:	fe843703          	ld	a4,-24(s0)
ffffffe000200708:	00e7b023          	sd	a4,0(a5)
ffffffe00020070c:	0300006f          	j	ffffffe00020073c <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200710:	00007797          	auipc	a5,0x7
ffffffe000200714:	90078793          	addi	a5,a5,-1792 # ffffffe000207010 <buddy>
ffffffe000200718:	0087b703          	ld	a4,8(a5)
ffffffe00020071c:	fe043783          	ld	a5,-32(s0)
ffffffe000200720:	00379793          	slli	a5,a5,0x3
ffffffe000200724:	00f706b3          	add	a3,a4,a5
ffffffe000200728:	fd843703          	ld	a4,-40(s0)
ffffffe00020072c:	fd043783          	ld	a5,-48(s0)
ffffffe000200730:	00e7f463          	bgeu	a5,a4,ffffffe000200738 <buddy_free+0x178>
ffffffe000200734:	00070793          	mv	a5,a4
ffffffe000200738:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe00020073c:	fe043783          	ld	a5,-32(s0)
ffffffe000200740:	f20798e3          	bnez	a5,ffffffe000200670 <buddy_free+0xb0>
    }
}
ffffffe000200744:	00000013          	nop
ffffffe000200748:	00000013          	nop
ffffffe00020074c:	03813403          	ld	s0,56(sp)
ffffffe000200750:	04010113          	addi	sp,sp,64
ffffffe000200754:	00008067          	ret

ffffffe000200758 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe000200758:	fc010113          	addi	sp,sp,-64
ffffffe00020075c:	02113c23          	sd	ra,56(sp)
ffffffe000200760:	02813823          	sd	s0,48(sp)
ffffffe000200764:	04010413          	addi	s0,sp,64
ffffffe000200768:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe00020076c:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200770:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe000200774:	fc843783          	ld	a5,-56(s0)
ffffffe000200778:	00079863          	bnez	a5,ffffffe000200788 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe00020077c:	00100793          	li	a5,1
ffffffe000200780:	fcf43423          	sd	a5,-56(s0)
ffffffe000200784:	0240006f          	j	ffffffe0002007a8 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe000200788:	fc843783          	ld	a5,-56(s0)
ffffffe00020078c:	fff78713          	addi	a4,a5,-1
ffffffe000200790:	fc843783          	ld	a5,-56(s0)
ffffffe000200794:	00f777b3          	and	a5,a4,a5
ffffffe000200798:	00078863          	beqz	a5,ffffffe0002007a8 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe00020079c:	fc843503          	ld	a0,-56(s0)
ffffffe0002007a0:	bc9ff0ef          	jal	ra,ffffffe000200368 <fixsize>
ffffffe0002007a4:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe0002007a8:	00007797          	auipc	a5,0x7
ffffffe0002007ac:	86878793          	addi	a5,a5,-1944 # ffffffe000207010 <buddy>
ffffffe0002007b0:	0087b703          	ld	a4,8(a5)
ffffffe0002007b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002007b8:	00379793          	slli	a5,a5,0x3
ffffffe0002007bc:	00f707b3          	add	a5,a4,a5
ffffffe0002007c0:	0007b783          	ld	a5,0(a5)
ffffffe0002007c4:	fc843703          	ld	a4,-56(s0)
ffffffe0002007c8:	00e7f663          	bgeu	a5,a4,ffffffe0002007d4 <buddy_alloc+0x7c>
        return 0;
ffffffe0002007cc:	00000793          	li	a5,0
ffffffe0002007d0:	1480006f          	j	ffffffe000200918 <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002007d4:	00007797          	auipc	a5,0x7
ffffffe0002007d8:	83c78793          	addi	a5,a5,-1988 # ffffffe000207010 <buddy>
ffffffe0002007dc:	0007b783          	ld	a5,0(a5)
ffffffe0002007e0:	fef43023          	sd	a5,-32(s0)
ffffffe0002007e4:	05c0006f          	j	ffffffe000200840 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe0002007e8:	00007797          	auipc	a5,0x7
ffffffe0002007ec:	82878793          	addi	a5,a5,-2008 # ffffffe000207010 <buddy>
ffffffe0002007f0:	0087b703          	ld	a4,8(a5)
ffffffe0002007f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002007f8:	00479793          	slli	a5,a5,0x4
ffffffe0002007fc:	00878793          	addi	a5,a5,8
ffffffe000200800:	00f707b3          	add	a5,a4,a5
ffffffe000200804:	0007b783          	ld	a5,0(a5)
ffffffe000200808:	fc843703          	ld	a4,-56(s0)
ffffffe00020080c:	00e7ec63          	bltu	a5,a4,ffffffe000200824 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200810:	fe843783          	ld	a5,-24(s0)
ffffffe000200814:	00179793          	slli	a5,a5,0x1
ffffffe000200818:	00178793          	addi	a5,a5,1
ffffffe00020081c:	fef43423          	sd	a5,-24(s0)
ffffffe000200820:	0140006f          	j	ffffffe000200834 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe000200824:	fe843783          	ld	a5,-24(s0)
ffffffe000200828:	00178793          	addi	a5,a5,1
ffffffe00020082c:	00179793          	slli	a5,a5,0x1
ffffffe000200830:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200834:	fe043783          	ld	a5,-32(s0)
ffffffe000200838:	0017d793          	srli	a5,a5,0x1
ffffffe00020083c:	fef43023          	sd	a5,-32(s0)
ffffffe000200840:	fe043703          	ld	a4,-32(s0)
ffffffe000200844:	fc843783          	ld	a5,-56(s0)
ffffffe000200848:	faf710e3          	bne	a4,a5,ffffffe0002007e8 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe00020084c:	00006797          	auipc	a5,0x6
ffffffe000200850:	7c478793          	addi	a5,a5,1988 # ffffffe000207010 <buddy>
ffffffe000200854:	0087b703          	ld	a4,8(a5)
ffffffe000200858:	fe843783          	ld	a5,-24(s0)
ffffffe00020085c:	00379793          	slli	a5,a5,0x3
ffffffe000200860:	00f707b3          	add	a5,a4,a5
ffffffe000200864:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200868:	fe843783          	ld	a5,-24(s0)
ffffffe00020086c:	00178713          	addi	a4,a5,1
ffffffe000200870:	fe043783          	ld	a5,-32(s0)
ffffffe000200874:	02f70733          	mul	a4,a4,a5
ffffffe000200878:	00006797          	auipc	a5,0x6
ffffffe00020087c:	79878793          	addi	a5,a5,1944 # ffffffe000207010 <buddy>
ffffffe000200880:	0007b783          	ld	a5,0(a5)
ffffffe000200884:	40f707b3          	sub	a5,a4,a5
ffffffe000200888:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe00020088c:	0800006f          	j	ffffffe00020090c <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe000200890:	fe843783          	ld	a5,-24(s0)
ffffffe000200894:	00178793          	addi	a5,a5,1
ffffffe000200898:	0017d793          	srli	a5,a5,0x1
ffffffe00020089c:	fff78793          	addi	a5,a5,-1
ffffffe0002008a0:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008a4:	00006797          	auipc	a5,0x6
ffffffe0002008a8:	76c78793          	addi	a5,a5,1900 # ffffffe000207010 <buddy>
ffffffe0002008ac:	0087b703          	ld	a4,8(a5)
ffffffe0002008b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008b4:	00178793          	addi	a5,a5,1
ffffffe0002008b8:	00479793          	slli	a5,a5,0x4
ffffffe0002008bc:	00f707b3          	add	a5,a4,a5
ffffffe0002008c0:	0007b603          	ld	a2,0(a5)
ffffffe0002008c4:	00006797          	auipc	a5,0x6
ffffffe0002008c8:	74c78793          	addi	a5,a5,1868 # ffffffe000207010 <buddy>
ffffffe0002008cc:	0087b703          	ld	a4,8(a5)
ffffffe0002008d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008d4:	00479793          	slli	a5,a5,0x4
ffffffe0002008d8:	00878793          	addi	a5,a5,8
ffffffe0002008dc:	00f707b3          	add	a5,a4,a5
ffffffe0002008e0:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe0002008e4:	00006797          	auipc	a5,0x6
ffffffe0002008e8:	72c78793          	addi	a5,a5,1836 # ffffffe000207010 <buddy>
ffffffe0002008ec:	0087b683          	ld	a3,8(a5)
ffffffe0002008f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008f4:	00379793          	slli	a5,a5,0x3
ffffffe0002008f8:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008fc:	00060793          	mv	a5,a2
ffffffe000200900:	00e7f463          	bgeu	a5,a4,ffffffe000200908 <buddy_alloc+0x1b0>
ffffffe000200904:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200908:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe00020090c:	fe843783          	ld	a5,-24(s0)
ffffffe000200910:	f80790e3          	bnez	a5,ffffffe000200890 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe000200914:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200918:	00078513          	mv	a0,a5
ffffffe00020091c:	03813083          	ld	ra,56(sp)
ffffffe000200920:	03013403          	ld	s0,48(sp)
ffffffe000200924:	04010113          	addi	sp,sp,64
ffffffe000200928:	00008067          	ret

ffffffe00020092c <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe00020092c:	fd010113          	addi	sp,sp,-48
ffffffe000200930:	02113423          	sd	ra,40(sp)
ffffffe000200934:	02813023          	sd	s0,32(sp)
ffffffe000200938:	03010413          	addi	s0,sp,48
ffffffe00020093c:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200940:	fd843503          	ld	a0,-40(s0)
ffffffe000200944:	e15ff0ef          	jal	ra,ffffffe000200758 <buddy_alloc>
ffffffe000200948:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe00020094c:	fe843783          	ld	a5,-24(s0)
ffffffe000200950:	00079663          	bnez	a5,ffffffe00020095c <alloc_pages+0x30>
        return 0;
ffffffe000200954:	00000793          	li	a5,0
ffffffe000200958:	0180006f          	j	ffffffe000200970 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe00020095c:	fe843783          	ld	a5,-24(s0)
ffffffe000200960:	00c79713          	slli	a4,a5,0xc
ffffffe000200964:	fff00793          	li	a5,-1
ffffffe000200968:	02579793          	slli	a5,a5,0x25
ffffffe00020096c:	00f707b3          	add	a5,a4,a5
}
ffffffe000200970:	00078513          	mv	a0,a5
ffffffe000200974:	02813083          	ld	ra,40(sp)
ffffffe000200978:	02013403          	ld	s0,32(sp)
ffffffe00020097c:	03010113          	addi	sp,sp,48
ffffffe000200980:	00008067          	ret

ffffffe000200984 <alloc_page>:

void *alloc_page() {
ffffffe000200984:	ff010113          	addi	sp,sp,-16
ffffffe000200988:	00113423          	sd	ra,8(sp)
ffffffe00020098c:	00813023          	sd	s0,0(sp)
ffffffe000200990:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200994:	00100513          	li	a0,1
ffffffe000200998:	f95ff0ef          	jal	ra,ffffffe00020092c <alloc_pages>
ffffffe00020099c:	00050793          	mv	a5,a0
}
ffffffe0002009a0:	00078513          	mv	a0,a5
ffffffe0002009a4:	00813083          	ld	ra,8(sp)
ffffffe0002009a8:	00013403          	ld	s0,0(sp)
ffffffe0002009ac:	01010113          	addi	sp,sp,16
ffffffe0002009b0:	00008067          	ret

ffffffe0002009b4 <free_pages>:

void free_pages(void *va) {
ffffffe0002009b4:	fe010113          	addi	sp,sp,-32
ffffffe0002009b8:	00113c23          	sd	ra,24(sp)
ffffffe0002009bc:	00813823          	sd	s0,16(sp)
ffffffe0002009c0:	02010413          	addi	s0,sp,32
ffffffe0002009c4:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe0002009c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002009cc:	00100793          	li	a5,1
ffffffe0002009d0:	02579793          	slli	a5,a5,0x25
ffffffe0002009d4:	00f707b3          	add	a5,a4,a5
ffffffe0002009d8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002009dc:	00078513          	mv	a0,a5
ffffffe0002009e0:	be1ff0ef          	jal	ra,ffffffe0002005c0 <buddy_free>
}
ffffffe0002009e4:	00000013          	nop
ffffffe0002009e8:	01813083          	ld	ra,24(sp)
ffffffe0002009ec:	01013403          	ld	s0,16(sp)
ffffffe0002009f0:	02010113          	addi	sp,sp,32
ffffffe0002009f4:	00008067          	ret

ffffffe0002009f8 <kalloc>:

void *kalloc() {
ffffffe0002009f8:	ff010113          	addi	sp,sp,-16
ffffffe0002009fc:	00113423          	sd	ra,8(sp)
ffffffe000200a00:	00813023          	sd	s0,0(sp)
ffffffe000200a04:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200a08:	f7dff0ef          	jal	ra,ffffffe000200984 <alloc_page>
ffffffe000200a0c:	00050793          	mv	a5,a0
}
ffffffe000200a10:	00078513          	mv	a0,a5
ffffffe000200a14:	00813083          	ld	ra,8(sp)
ffffffe000200a18:	00013403          	ld	s0,0(sp)
ffffffe000200a1c:	01010113          	addi	sp,sp,16
ffffffe000200a20:	00008067          	ret

ffffffe000200a24 <kfree>:

void kfree(void *addr) {
ffffffe000200a24:	fe010113          	addi	sp,sp,-32
ffffffe000200a28:	00113c23          	sd	ra,24(sp)
ffffffe000200a2c:	00813823          	sd	s0,16(sp)
ffffffe000200a30:	02010413          	addi	s0,sp,32
ffffffe000200a34:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200a38:	fe843503          	ld	a0,-24(s0)
ffffffe000200a3c:	f79ff0ef          	jal	ra,ffffffe0002009b4 <free_pages>

    return;
ffffffe000200a40:	00000013          	nop
}
ffffffe000200a44:	01813083          	ld	ra,24(sp)
ffffffe000200a48:	01013403          	ld	s0,16(sp)
ffffffe000200a4c:	02010113          	addi	sp,sp,32
ffffffe000200a50:	00008067          	ret

ffffffe000200a54 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200a54:	fd010113          	addi	sp,sp,-48
ffffffe000200a58:	02113423          	sd	ra,40(sp)
ffffffe000200a5c:	02813023          	sd	s0,32(sp)
ffffffe000200a60:	03010413          	addi	s0,sp,48
ffffffe000200a64:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a68:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a6c:	fd843703          	ld	a4,-40(s0)
ffffffe000200a70:	000017b7          	lui	a5,0x1
ffffffe000200a74:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200a78:	00f70733          	add	a4,a4,a5
ffffffe000200a7c:	fffff7b7          	lui	a5,0xfffff
ffffffe000200a80:	00f777b3          	and	a5,a4,a5
ffffffe000200a84:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a88:	01c0006f          	j	ffffffe000200aa4 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200a8c:	fe843503          	ld	a0,-24(s0)
ffffffe000200a90:	f95ff0ef          	jal	ra,ffffffe000200a24 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a94:	fe843703          	ld	a4,-24(s0)
ffffffe000200a98:	000017b7          	lui	a5,0x1
ffffffe000200a9c:	00f707b3          	add	a5,a4,a5
ffffffe000200aa0:	fef43423          	sd	a5,-24(s0)
ffffffe000200aa4:	fe843703          	ld	a4,-24(s0)
ffffffe000200aa8:	000017b7          	lui	a5,0x1
ffffffe000200aac:	00f70733          	add	a4,a4,a5
ffffffe000200ab0:	fd043783          	ld	a5,-48(s0)
ffffffe000200ab4:	fce7fce3          	bgeu	a5,a4,ffffffe000200a8c <kfreerange+0x38>
    }
}
ffffffe000200ab8:	00000013          	nop
ffffffe000200abc:	00000013          	nop
ffffffe000200ac0:	02813083          	ld	ra,40(sp)
ffffffe000200ac4:	02013403          	ld	s0,32(sp)
ffffffe000200ac8:	03010113          	addi	sp,sp,48
ffffffe000200acc:	00008067          	ret

ffffffe000200ad0 <mm_init>:

void mm_init(void) {
ffffffe000200ad0:	ff010113          	addi	sp,sp,-16
ffffffe000200ad4:	00113423          	sd	ra,8(sp)
ffffffe000200ad8:	00813023          	sd	s0,0(sp)
ffffffe000200adc:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200ae0:	935ff0ef          	jal	ra,ffffffe000200414 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200ae4:	00002517          	auipc	a0,0x2
ffffffe000200ae8:	53450513          	addi	a0,a0,1332 # ffffffe000203018 <_srodata+0x18>
ffffffe000200aec:	01c020ef          	jal	ra,ffffffe000202b08 <printk>
}
ffffffe000200af0:	00000013          	nop
ffffffe000200af4:	00813083          	ld	ra,8(sp)
ffffffe000200af8:	00013403          	ld	s0,0(sp)
ffffffe000200afc:	01010113          	addi	sp,sp,16
ffffffe000200b00:	00008067          	ret

ffffffe000200b04 <memcpy>:

// upaa 起始结束地址
extern char _sramdisk[];
extern char _eramdisk[];

void memcpy(void *dest,void *src, size_t n) {
ffffffe000200b04:	fb010113          	addi	sp,sp,-80
ffffffe000200b08:	04813423          	sd	s0,72(sp)
ffffffe000200b0c:	05010413          	addi	s0,sp,80
ffffffe000200b10:	fca43423          	sd	a0,-56(s0)
ffffffe000200b14:	fcb43023          	sd	a1,-64(s0)
ffffffe000200b18:	fac43c23          	sd	a2,-72(s0)
    char *d = (char *)dest;
ffffffe000200b1c:	fc843783          	ld	a5,-56(s0)
ffffffe000200b20:	fef43023          	sd	a5,-32(s0)
    char *s = (char *)src;
ffffffe000200b24:	fc043783          	ld	a5,-64(s0)
ffffffe000200b28:	fcf43c23          	sd	a5,-40(s0)
    for (size_t i = 0; i < n; i++) {
ffffffe000200b2c:	fe043423          	sd	zero,-24(s0)
ffffffe000200b30:	0300006f          	j	ffffffe000200b60 <memcpy+0x5c>
        d[i] = s[i];
ffffffe000200b34:	fd843703          	ld	a4,-40(s0)
ffffffe000200b38:	fe843783          	ld	a5,-24(s0)
ffffffe000200b3c:	00f70733          	add	a4,a4,a5
ffffffe000200b40:	fe043683          	ld	a3,-32(s0)
ffffffe000200b44:	fe843783          	ld	a5,-24(s0)
ffffffe000200b48:	00f687b3          	add	a5,a3,a5
ffffffe000200b4c:	00074703          	lbu	a4,0(a4)
ffffffe000200b50:	00e78023          	sb	a4,0(a5) # 1000 <PGSIZE>
    for (size_t i = 0; i < n; i++) {
ffffffe000200b54:	fe843783          	ld	a5,-24(s0)
ffffffe000200b58:	00178793          	addi	a5,a5,1
ffffffe000200b5c:	fef43423          	sd	a5,-24(s0)
ffffffe000200b60:	fe843703          	ld	a4,-24(s0)
ffffffe000200b64:	fb843783          	ld	a5,-72(s0)
ffffffe000200b68:	fcf766e3          	bltu	a4,a5,ffffffe000200b34 <memcpy+0x30>
    }
}
ffffffe000200b6c:	00000013          	nop
ffffffe000200b70:	00000013          	nop
ffffffe000200b74:	04813403          	ld	s0,72(sp)
ffffffe000200b78:	05010113          	addi	sp,sp,80
ffffffe000200b7c:	00008067          	ret

ffffffe000200b80 <task_init>:

void task_init() {
ffffffe000200b80:	fc010113          	addi	sp,sp,-64
ffffffe000200b84:	02113c23          	sd	ra,56(sp)
ffffffe000200b88:	02813823          	sd	s0,48(sp)
ffffffe000200b8c:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe000200b90:	7e800513          	li	a0,2024
ffffffe000200b94:	7f5010ef          	jal	ra,ffffffe000202b88 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
ffffffe000200b98:	e61ff0ef          	jal	ra,ffffffe0002009f8 <kalloc>
ffffffe000200b9c:	00050713          	mv	a4,a0
ffffffe000200ba0:	00008797          	auipc	a5,0x8
ffffffe000200ba4:	46078793          	addi	a5,a5,1120 # ffffffe000209000 <idle>
ffffffe000200ba8:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200bac:	00008797          	auipc	a5,0x8
ffffffe000200bb0:	45478793          	addi	a5,a5,1108 # ffffffe000209000 <idle>
ffffffe000200bb4:	0007b783          	ld	a5,0(a5)
ffffffe000200bb8:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200bbc:	00008797          	auipc	a5,0x8
ffffffe000200bc0:	44478793          	addi	a5,a5,1092 # ffffffe000209000 <idle>
ffffffe000200bc4:	0007b783          	ld	a5,0(a5)
ffffffe000200bc8:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200bcc:	00008797          	auipc	a5,0x8
ffffffe000200bd0:	43478793          	addi	a5,a5,1076 # ffffffe000209000 <idle>
ffffffe000200bd4:	0007b783          	ld	a5,0(a5)
ffffffe000200bd8:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200bdc:	00008797          	auipc	a5,0x8
ffffffe000200be0:	42478793          	addi	a5,a5,1060 # ffffffe000209000 <idle>
ffffffe000200be4:	0007b783          	ld	a5,0(a5)
ffffffe000200be8:	0007bc23          	sd	zero,24(a5)
    idle->thread.first_schedule=0;
ffffffe000200bec:	00008797          	auipc	a5,0x8
ffffffe000200bf0:	41478793          	addi	a5,a5,1044 # ffffffe000209000 <idle>
ffffffe000200bf4:	0007b783          	ld	a5,0(a5)
ffffffe000200bf8:	0807b823          	sd	zero,144(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200bfc:	00008797          	auipc	a5,0x8
ffffffe000200c00:	40478793          	addi	a5,a5,1028 # ffffffe000209000 <idle>
ffffffe000200c04:	0007b703          	ld	a4,0(a5)
ffffffe000200c08:	00008797          	auipc	a5,0x8
ffffffe000200c0c:	40078793          	addi	a5,a5,1024 # ffffffe000209008 <current>
ffffffe000200c10:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200c14:	00008797          	auipc	a5,0x8
ffffffe000200c18:	3ec78793          	addi	a5,a5,1004 # ffffffe000209000 <idle>
ffffffe000200c1c:	0007b703          	ld	a4,0(a5)
ffffffe000200c20:	00008797          	auipc	a5,0x8
ffffffe000200c24:	3f078793          	addi	a5,a5,1008 # ffffffe000209010 <task>
ffffffe000200c28:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    size_t uapp_size=(size_t)(_eramdisk-_sramdisk); // uapp 大小
ffffffe000200c2c:	00004717          	auipc	a4,0x4
ffffffe000200c30:	3f870713          	addi	a4,a4,1016 # ffffffe000205024 <_eramdisk>
ffffffe000200c34:	00004797          	auipc	a5,0x4
ffffffe000200c38:	3cc78793          	addi	a5,a5,972 # ffffffe000205000 <_sramdisk>
ffffffe000200c3c:	40f707b3          	sub	a5,a4,a5
ffffffe000200c40:	fef43023          	sd	a5,-32(s0)
    size_t num_pages=(uapp_size+PGSIZE-1)/PGSIZE; // uapp 占用页数
ffffffe000200c44:	fe043703          	ld	a4,-32(s0)
ffffffe000200c48:	000017b7          	lui	a5,0x1
ffffffe000200c4c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200c50:	00f707b3          	add	a5,a4,a5
ffffffe000200c54:	00c7d793          	srli	a5,a5,0xc
ffffffe000200c58:	fcf43c23          	sd	a5,-40(s0)

    for(int i=1;i<NR_TASKS;i++){
ffffffe000200c5c:	00100793          	li	a5,1
ffffffe000200c60:	fef42623          	sw	a5,-20(s0)
ffffffe000200c64:	3180006f          	j	ffffffe000200f7c <task_init+0x3fc>
        task[i]=(struct task_struct *)kalloc();
ffffffe000200c68:	d91ff0ef          	jal	ra,ffffffe0002009f8 <kalloc>
ffffffe000200c6c:	00050693          	mv	a3,a0
ffffffe000200c70:	00008717          	auipc	a4,0x8
ffffffe000200c74:	3a070713          	addi	a4,a4,928 # ffffffe000209010 <task>
ffffffe000200c78:	fec42783          	lw	a5,-20(s0)
ffffffe000200c7c:	00379793          	slli	a5,a5,0x3
ffffffe000200c80:	00f707b3          	add	a5,a4,a5
ffffffe000200c84:	00d7b023          	sd	a3,0(a5)
        task[i]->state=TASK_RUNNING;
ffffffe000200c88:	00008717          	auipc	a4,0x8
ffffffe000200c8c:	38870713          	addi	a4,a4,904 # ffffffe000209010 <task>
ffffffe000200c90:	fec42783          	lw	a5,-20(s0)
ffffffe000200c94:	00379793          	slli	a5,a5,0x3
ffffffe000200c98:	00f707b3          	add	a5,a4,a5
ffffffe000200c9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ca0:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe000200ca4:	00008717          	auipc	a4,0x8
ffffffe000200ca8:	36c70713          	addi	a4,a4,876 # ffffffe000209010 <task>
ffffffe000200cac:	fec42783          	lw	a5,-20(s0)
ffffffe000200cb0:	00379793          	slli	a5,a5,0x3
ffffffe000200cb4:	00f707b3          	add	a5,a4,a5
ffffffe000200cb8:	0007b783          	ld	a5,0(a5)
ffffffe000200cbc:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
ffffffe000200cc0:	70d010ef          	jal	ra,ffffffe000202bcc <rand>
ffffffe000200cc4:	00050793          	mv	a5,a0
ffffffe000200cc8:	00078713          	mv	a4,a5
ffffffe000200ccc:	00a00793          	li	a5,10
ffffffe000200cd0:	02f767bb          	remw	a5,a4,a5
ffffffe000200cd4:	0007879b          	sext.w	a5,a5
ffffffe000200cd8:	0017879b          	addiw	a5,a5,1
ffffffe000200cdc:	0007869b          	sext.w	a3,a5
ffffffe000200ce0:	00008717          	auipc	a4,0x8
ffffffe000200ce4:	33070713          	addi	a4,a4,816 # ffffffe000209010 <task>
ffffffe000200ce8:	fec42783          	lw	a5,-20(s0)
ffffffe000200cec:	00379793          	slli	a5,a5,0x3
ffffffe000200cf0:	00f707b3          	add	a5,a4,a5
ffffffe000200cf4:	0007b783          	ld	a5,0(a5)
ffffffe000200cf8:	00068713          	mv	a4,a3
ffffffe000200cfc:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe000200d00:	00008717          	auipc	a4,0x8
ffffffe000200d04:	31070713          	addi	a4,a4,784 # ffffffe000209010 <task>
ffffffe000200d08:	fec42783          	lw	a5,-20(s0)
ffffffe000200d0c:	00379793          	slli	a5,a5,0x3
ffffffe000200d10:	00f707b3          	add	a5,a4,a5
ffffffe000200d14:	0007b783          	ld	a5,0(a5)
ffffffe000200d18:	fec42703          	lw	a4,-20(s0)
ffffffe000200d1c:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
ffffffe000200d20:	00008717          	auipc	a4,0x8
ffffffe000200d24:	2f070713          	addi	a4,a4,752 # ffffffe000209010 <task>
ffffffe000200d28:	fec42783          	lw	a5,-20(s0)
ffffffe000200d2c:	00379793          	slli	a5,a5,0x3
ffffffe000200d30:	00f707b3          	add	a5,a4,a5
ffffffe000200d34:	0007b783          	ld	a5,0(a5)
ffffffe000200d38:	fffff717          	auipc	a4,0xfffff
ffffffe000200d3c:	4b870713          	addi	a4,a4,1208 # ffffffe0002001f0 <__dummy>
ffffffe000200d40:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe000200d44:	00008717          	auipc	a4,0x8
ffffffe000200d48:	2cc70713          	addi	a4,a4,716 # ffffffe000209010 <task>
ffffffe000200d4c:	fec42783          	lw	a5,-20(s0)
ffffffe000200d50:	00379793          	slli	a5,a5,0x3
ffffffe000200d54:	00f707b3          	add	a5,a4,a5
ffffffe000200d58:	0007b783          	ld	a5,0(a5)
ffffffe000200d5c:	00078693          	mv	a3,a5
ffffffe000200d60:	00008717          	auipc	a4,0x8
ffffffe000200d64:	2b070713          	addi	a4,a4,688 # ffffffe000209010 <task>
ffffffe000200d68:	fec42783          	lw	a5,-20(s0)
ffffffe000200d6c:	00379793          	slli	a5,a5,0x3
ffffffe000200d70:	00f707b3          	add	a5,a4,a5
ffffffe000200d74:	0007b783          	ld	a5,0(a5)
ffffffe000200d78:	00001737          	lui	a4,0x1
ffffffe000200d7c:	00e68733          	add	a4,a3,a4
ffffffe000200d80:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.first_schedule=1;
ffffffe000200d84:	00008717          	auipc	a4,0x8
ffffffe000200d88:	28c70713          	addi	a4,a4,652 # ffffffe000209010 <task>
ffffffe000200d8c:	fec42783          	lw	a5,-20(s0)
ffffffe000200d90:	00379793          	slli	a5,a5,0x3
ffffffe000200d94:	00f707b3          	add	a5,a4,a5
ffffffe000200d98:	0007b783          	ld	a5,0(a5)
ffffffe000200d9c:	00100713          	li	a4,1
ffffffe000200da0:	08e7b823          	sd	a4,144(a5)
        task[i]->thread.sepc=(uint64_t)USER_START;   //将 sepc 设置为 USER_START
ffffffe000200da4:	00008717          	auipc	a4,0x8
ffffffe000200da8:	26c70713          	addi	a4,a4,620 # ffffffe000209010 <task>
ffffffe000200dac:	fec42783          	lw	a5,-20(s0)
ffffffe000200db0:	00379793          	slli	a5,a5,0x3
ffffffe000200db4:	00f707b3          	add	a5,a4,a5
ffffffe000200db8:	0007b783          	ld	a5,0(a5)
ffffffe000200dbc:	0807bc23          	sd	zero,152(a5)
        task[i]->thread.sstatus&=~(1UL<<8);         //将 SPP 位置 0，使得 sret 返回至 U-Mode
ffffffe000200dc0:	00008717          	auipc	a4,0x8
ffffffe000200dc4:	25070713          	addi	a4,a4,592 # ffffffe000209010 <task>
ffffffe000200dc8:	fec42783          	lw	a5,-20(s0)
ffffffe000200dcc:	00379793          	slli	a5,a5,0x3
ffffffe000200dd0:	00f707b3          	add	a5,a4,a5
ffffffe000200dd4:	0007b783          	ld	a5,0(a5)
ffffffe000200dd8:	0a07b703          	ld	a4,160(a5)
ffffffe000200ddc:	00008697          	auipc	a3,0x8
ffffffe000200de0:	23468693          	addi	a3,a3,564 # ffffffe000209010 <task>
ffffffe000200de4:	fec42783          	lw	a5,-20(s0)
ffffffe000200de8:	00379793          	slli	a5,a5,0x3
ffffffe000200dec:	00f687b3          	add	a5,a3,a5
ffffffe000200df0:	0007b783          	ld	a5,0(a5)
ffffffe000200df4:	eff77713          	andi	a4,a4,-257
ffffffe000200df8:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sstatus&=~(1UL<<18);        //将 SUM 位置 1， S-Mode 可以访问 User 页表
ffffffe000200dfc:	00008717          	auipc	a4,0x8
ffffffe000200e00:	21470713          	addi	a4,a4,532 # ffffffe000209010 <task>
ffffffe000200e04:	fec42783          	lw	a5,-20(s0)
ffffffe000200e08:	00379793          	slli	a5,a5,0x3
ffffffe000200e0c:	00f707b3          	add	a5,a4,a5
ffffffe000200e10:	0007b783          	ld	a5,0(a5)
ffffffe000200e14:	0a07b683          	ld	a3,160(a5)
ffffffe000200e18:	00008717          	auipc	a4,0x8
ffffffe000200e1c:	1f870713          	addi	a4,a4,504 # ffffffe000209010 <task>
ffffffe000200e20:	fec42783          	lw	a5,-20(s0)
ffffffe000200e24:	00379793          	slli	a5,a5,0x3
ffffffe000200e28:	00f707b3          	add	a5,a4,a5
ffffffe000200e2c:	0007b783          	ld	a5,0(a5)
ffffffe000200e30:	fffc0737          	lui	a4,0xfffc0
ffffffe000200e34:	fff70713          	addi	a4,a4,-1 # fffffffffffbffff <VM_END+0xfffbffff>
ffffffe000200e38:	00e6f733          	and	a4,a3,a4
ffffffe000200e3c:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sscratch = (uint64_t)USER_END;//将 sscratch 设置为 U-Mode 的 sp
ffffffe000200e40:	00008717          	auipc	a4,0x8
ffffffe000200e44:	1d070713          	addi	a4,a4,464 # ffffffe000209010 <task>
ffffffe000200e48:	fec42783          	lw	a5,-20(s0)
ffffffe000200e4c:	00379793          	slli	a5,a5,0x3
ffffffe000200e50:	00f707b3          	add	a5,a4,a5
ffffffe000200e54:	0007b783          	ld	a5,0(a5)
ffffffe000200e58:	00100713          	li	a4,1
ffffffe000200e5c:	02671713          	slli	a4,a4,0x26
ffffffe000200e60:	0ae7b423          	sd	a4,168(a5)

        // 创建属于它自己的页表：
        task[i]->pgd=(uint64_t *)kalloc;
ffffffe000200e64:	00008717          	auipc	a4,0x8
ffffffe000200e68:	1ac70713          	addi	a4,a4,428 # ffffffe000209010 <task>
ffffffe000200e6c:	fec42783          	lw	a5,-20(s0)
ffffffe000200e70:	00379793          	slli	a5,a5,0x3
ffffffe000200e74:	00f707b3          	add	a5,a4,a5
ffffffe000200e78:	0007b783          	ld	a5,0(a5)
ffffffe000200e7c:	00000717          	auipc	a4,0x0
ffffffe000200e80:	b7c70713          	addi	a4,a4,-1156 # ffffffe0002009f8 <kalloc>
ffffffe000200e84:	0ae7b823          	sd	a4,176(a5)
        //将内核页表 swapper_pg_dir 复制到进程的页表中
        memcpy(task[i]->pgd,swapper_pg_dir,PGSIZE);
ffffffe000200e88:	00008717          	auipc	a4,0x8
ffffffe000200e8c:	18870713          	addi	a4,a4,392 # ffffffe000209010 <task>
ffffffe000200e90:	fec42783          	lw	a5,-20(s0)
ffffffe000200e94:	00379793          	slli	a5,a5,0x3
ffffffe000200e98:	00f707b3          	add	a5,a4,a5
ffffffe000200e9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ea0:	0b07b783          	ld	a5,176(a5)
ffffffe000200ea4:	00001637          	lui	a2,0x1
ffffffe000200ea8:	00007597          	auipc	a1,0x7
ffffffe000200eac:	15858593          	addi	a1,a1,344 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200eb0:	00078513          	mv	a0,a5
ffffffe000200eb4:	c51ff0ef          	jal	ra,ffffffe000200b04 <memcpy>
        void *uapp_mem=alloc_pages(num_pages);  //分配内存
ffffffe000200eb8:	fd843503          	ld	a0,-40(s0)
ffffffe000200ebc:	a71ff0ef          	jal	ra,ffffffe00020092c <alloc_pages>
ffffffe000200ec0:	fca43823          	sd	a0,-48(s0)
        //将 uapp 复制到分配的内存中
        memcpy(uapp_mem,_sramdisk,uapp_size);
ffffffe000200ec4:	fe043603          	ld	a2,-32(s0)
ffffffe000200ec8:	00004597          	auipc	a1,0x4
ffffffe000200ecc:	13858593          	addi	a1,a1,312 # ffffffe000205000 <_sramdisk>
ffffffe000200ed0:	fd043503          	ld	a0,-48(s0)
ffffffe000200ed4:	c31ff0ef          	jal	ra,ffffffe000200b04 <memcpy>
        //将 uapp 所在的页面映射到进程的页表中
        create_mapping(task[i]->pgd,(uint64_t)USER_START,VA2PA((uint64_t)uapp_mem),uapp_size,PTE_V|PTE_R|PTE_W|PTE_X|PTE_U);
ffffffe000200ed8:	00008717          	auipc	a4,0x8
ffffffe000200edc:	13870713          	addi	a4,a4,312 # ffffffe000209010 <task>
ffffffe000200ee0:	fec42783          	lw	a5,-20(s0)
ffffffe000200ee4:	00379793          	slli	a5,a5,0x3
ffffffe000200ee8:	00f707b3          	add	a5,a4,a5
ffffffe000200eec:	0007b783          	ld	a5,0(a5)
ffffffe000200ef0:	0b07b503          	ld	a0,176(a5)
ffffffe000200ef4:	fd043703          	ld	a4,-48(s0)
ffffffe000200ef8:	04100793          	li	a5,65
ffffffe000200efc:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f00:	00f707b3          	add	a5,a4,a5
ffffffe000200f04:	01f00713          	li	a4,31
ffffffe000200f08:	fe043683          	ld	a3,-32(s0)
ffffffe000200f0c:	00078613          	mv	a2,a5
ffffffe000200f10:	00000593          	li	a1,0
ffffffe000200f14:	0a5000ef          	jal	ra,ffffffe0002017b8 <create_mapping>

        //设置用户态栈
        void *user_stack=kalloc();
ffffffe000200f18:	ae1ff0ef          	jal	ra,ffffffe0002009f8 <kalloc>
ffffffe000200f1c:	fca43423          	sd	a0,-56(s0)
        uint64_t stack_va=USER_END-PGSIZE; //用户栈顶虚拟地址
ffffffe000200f20:	040007b7          	lui	a5,0x4000
ffffffe000200f24:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000200f28:	00c79793          	slli	a5,a5,0xc
ffffffe000200f2c:	fcf43023          	sd	a5,-64(s0)
        create_mapping(task[i]->pgd,stack_va,VA2PA((uint64_t)user_stack),PGSIZE,PTE_V|PTE_R|PTE_W|PTE_U);
ffffffe000200f30:	00008717          	auipc	a4,0x8
ffffffe000200f34:	0e070713          	addi	a4,a4,224 # ffffffe000209010 <task>
ffffffe000200f38:	fec42783          	lw	a5,-20(s0)
ffffffe000200f3c:	00379793          	slli	a5,a5,0x3
ffffffe000200f40:	00f707b3          	add	a5,a4,a5
ffffffe000200f44:	0007b783          	ld	a5,0(a5)
ffffffe000200f48:	0b07b503          	ld	a0,176(a5)
ffffffe000200f4c:	fc843703          	ld	a4,-56(s0)
ffffffe000200f50:	04100793          	li	a5,65
ffffffe000200f54:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f58:	00f707b3          	add	a5,a4,a5
ffffffe000200f5c:	01700713          	li	a4,23
ffffffe000200f60:	000016b7          	lui	a3,0x1
ffffffe000200f64:	00078613          	mv	a2,a5
ffffffe000200f68:	fc043583          	ld	a1,-64(s0)
ffffffe000200f6c:	04d000ef          	jal	ra,ffffffe0002017b8 <create_mapping>
    for(int i=1;i<NR_TASKS;i++){
ffffffe000200f70:	fec42783          	lw	a5,-20(s0)
ffffffe000200f74:	0017879b          	addiw	a5,a5,1
ffffffe000200f78:	fef42623          	sw	a5,-20(s0)
ffffffe000200f7c:	fec42783          	lw	a5,-20(s0)
ffffffe000200f80:	0007871b          	sext.w	a4,a5
ffffffe000200f84:	00400793          	li	a5,4
ffffffe000200f88:	cee7d0e3          	bge	a5,a4,ffffffe000200c68 <task_init+0xe8>
                                            

    }

    printk("...task_init done!\n");
ffffffe000200f8c:	00002517          	auipc	a0,0x2
ffffffe000200f90:	0a450513          	addi	a0,a0,164 # ffffffe000203030 <_srodata+0x30>
ffffffe000200f94:	375010ef          	jal	ra,ffffffe000202b08 <printk>
}
ffffffe000200f98:	00000013          	nop
ffffffe000200f9c:	03813083          	ld	ra,56(sp)
ffffffe000200fa0:	03013403          	ld	s0,48(sp)
ffffffe000200fa4:	04010113          	addi	sp,sp,64
ffffffe000200fa8:	00008067          	ret

ffffffe000200fac <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000200fac:	fd010113          	addi	sp,sp,-48
ffffffe000200fb0:	02113423          	sd	ra,40(sp)
ffffffe000200fb4:	02813023          	sd	s0,32(sp)
ffffffe000200fb8:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe000200fbc:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200fc0:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200fc4:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200fc8:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000200fcc:	fff00793          	li	a5,-1
ffffffe000200fd0:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200fd4:	fe442783          	lw	a5,-28(s0)
ffffffe000200fd8:	0007871b          	sext.w	a4,a5
ffffffe000200fdc:	fff00793          	li	a5,-1
ffffffe000200fe0:	00f70e63          	beq	a4,a5,ffffffe000200ffc <dummy+0x50>
ffffffe000200fe4:	00008797          	auipc	a5,0x8
ffffffe000200fe8:	02478793          	addi	a5,a5,36 # ffffffe000209008 <current>
ffffffe000200fec:	0007b783          	ld	a5,0(a5)
ffffffe000200ff0:	0087b703          	ld	a4,8(a5)
ffffffe000200ff4:	fe442783          	lw	a5,-28(s0)
ffffffe000200ff8:	fcf70ee3          	beq	a4,a5,ffffffe000200fd4 <dummy+0x28>
ffffffe000200ffc:	00008797          	auipc	a5,0x8
ffffffe000201000:	00c78793          	addi	a5,a5,12 # ffffffe000209008 <current>
ffffffe000201004:	0007b783          	ld	a5,0(a5)
ffffffe000201008:	0087b783          	ld	a5,8(a5)
ffffffe00020100c:	fc0784e3          	beqz	a5,ffffffe000200fd4 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000201010:	00008797          	auipc	a5,0x8
ffffffe000201014:	ff878793          	addi	a5,a5,-8 # ffffffe000209008 <current>
ffffffe000201018:	0007b783          	ld	a5,0(a5)
ffffffe00020101c:	0087b703          	ld	a4,8(a5)
ffffffe000201020:	00100793          	li	a5,1
ffffffe000201024:	00f71e63          	bne	a4,a5,ffffffe000201040 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000201028:	00008797          	auipc	a5,0x8
ffffffe00020102c:	fe078793          	addi	a5,a5,-32 # ffffffe000209008 <current>
ffffffe000201030:	0007b783          	ld	a5,0(a5)
ffffffe000201034:	0087b703          	ld	a4,8(a5)
ffffffe000201038:	fff70713          	addi	a4,a4,-1
ffffffe00020103c:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000201040:	00008797          	auipc	a5,0x8
ffffffe000201044:	fc878793          	addi	a5,a5,-56 # ffffffe000209008 <current>
ffffffe000201048:	0007b783          	ld	a5,0(a5)
ffffffe00020104c:	0087b783          	ld	a5,8(a5)
ffffffe000201050:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000201054:	fe843783          	ld	a5,-24(s0)
ffffffe000201058:	00178713          	addi	a4,a5,1
ffffffe00020105c:	fd843783          	ld	a5,-40(s0)
ffffffe000201060:	02f777b3          	remu	a5,a4,a5
ffffffe000201064:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe000201068:	00008797          	auipc	a5,0x8
ffffffe00020106c:	fa078793          	addi	a5,a5,-96 # ffffffe000209008 <current>
ffffffe000201070:	0007b783          	ld	a5,0(a5)
ffffffe000201074:	0187b783          	ld	a5,24(a5)
ffffffe000201078:	fe843603          	ld	a2,-24(s0)
ffffffe00020107c:	00078593          	mv	a1,a5
ffffffe000201080:	00002517          	auipc	a0,0x2
ffffffe000201084:	fc850513          	addi	a0,a0,-56 # ffffffe000203048 <_srodata+0x48>
ffffffe000201088:	281010ef          	jal	ra,ffffffe000202b08 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020108c:	f49ff06f          	j	ffffffe000200fd4 <dummy+0x28>

ffffffe000201090 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
ffffffe000201090:	fd010113          	addi	sp,sp,-48
ffffffe000201094:	02113423          	sd	ra,40(sp)
ffffffe000201098:	02813023          	sd	s0,32(sp)
ffffffe00020109c:	03010413          	addi	s0,sp,48
ffffffe0002010a0:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
ffffffe0002010a4:	00008797          	auipc	a5,0x8
ffffffe0002010a8:	f6478793          	addi	a5,a5,-156 # ffffffe000209008 <current>
ffffffe0002010ac:	0007b783          	ld	a5,0(a5)
ffffffe0002010b0:	fd843703          	ld	a4,-40(s0)
ffffffe0002010b4:	06f70063          	beq	a4,a5,ffffffe000201114 <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
ffffffe0002010b8:	00008797          	auipc	a5,0x8
ffffffe0002010bc:	f5078793          	addi	a5,a5,-176 # ffffffe000209008 <current>
ffffffe0002010c0:	0007b783          	ld	a5,0(a5)
ffffffe0002010c4:	fef43423          	sd	a5,-24(s0)
    current=next;
ffffffe0002010c8:	00008797          	auipc	a5,0x8
ffffffe0002010cc:	f4078793          	addi	a5,a5,-192 # ffffffe000209008 <current>
ffffffe0002010d0:	fd843703          	ld	a4,-40(s0)
ffffffe0002010d4:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
ffffffe0002010d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002010dc:	0187b703          	ld	a4,24(a5)
ffffffe0002010e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002010e4:	0107b603          	ld	a2,16(a5)
ffffffe0002010e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002010ec:	0087b783          	ld	a5,8(a5)
ffffffe0002010f0:	00078693          	mv	a3,a5
ffffffe0002010f4:	00070593          	mv	a1,a4
ffffffe0002010f8:	00002517          	auipc	a0,0x2
ffffffe0002010fc:	f8050513          	addi	a0,a0,-128 # ffffffe000203078 <_srodata+0x78>
ffffffe000201100:	209010ef          	jal	ra,ffffffe000202b08 <printk>
    __switch_to(prev,next);
ffffffe000201104:	fd843583          	ld	a1,-40(s0)
ffffffe000201108:	fe843503          	ld	a0,-24(s0)
ffffffe00020110c:	8f4ff0ef          	jal	ra,ffffffe000200200 <__switch_to>
ffffffe000201110:	0080006f          	j	ffffffe000201118 <switch_to+0x88>
        return;
ffffffe000201114:	00000013          	nop
    
}
ffffffe000201118:	02813083          	ld	ra,40(sp)
ffffffe00020111c:	02013403          	ld	s0,32(sp)
ffffffe000201120:	03010113          	addi	sp,sp,48
ffffffe000201124:	00008067          	ret

ffffffe000201128 <do_timer>:

void do_timer(){
ffffffe000201128:	ff010113          	addi	sp,sp,-16
ffffffe00020112c:	00113423          	sd	ra,8(sp)
ffffffe000201130:	00813023          	sd	s0,0(sp)
ffffffe000201134:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
ffffffe000201138:	00008797          	auipc	a5,0x8
ffffffe00020113c:	ed078793          	addi	a5,a5,-304 # ffffffe000209008 <current>
ffffffe000201140:	0007b703          	ld	a4,0(a5)
ffffffe000201144:	00008797          	auipc	a5,0x8
ffffffe000201148:	ebc78793          	addi	a5,a5,-324 # ffffffe000209000 <idle>
ffffffe00020114c:	0007b783          	ld	a5,0(a5)
ffffffe000201150:	00f70c63          	beq	a4,a5,ffffffe000201168 <do_timer+0x40>
ffffffe000201154:	00008797          	auipc	a5,0x8
ffffffe000201158:	eb478793          	addi	a5,a5,-332 # ffffffe000209008 <current>
ffffffe00020115c:	0007b783          	ld	a5,0(a5)
ffffffe000201160:	0087b783          	ld	a5,8(a5)
ffffffe000201164:	00079663          	bnez	a5,ffffffe000201170 <do_timer+0x48>
        schedule();
ffffffe000201168:	04c000ef          	jal	ra,ffffffe0002011b4 <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
ffffffe00020116c:	0340006f          	j	ffffffe0002011a0 <do_timer+0x78>
        current->counter--;
ffffffe000201170:	00008797          	auipc	a5,0x8
ffffffe000201174:	e9878793          	addi	a5,a5,-360 # ffffffe000209008 <current>
ffffffe000201178:	0007b783          	ld	a5,0(a5)
ffffffe00020117c:	0087b703          	ld	a4,8(a5)
ffffffe000201180:	fff70713          	addi	a4,a4,-1
ffffffe000201184:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
ffffffe000201188:	00008797          	auipc	a5,0x8
ffffffe00020118c:	e8078793          	addi	a5,a5,-384 # ffffffe000209008 <current>
ffffffe000201190:	0007b783          	ld	a5,0(a5)
ffffffe000201194:	0087b783          	ld	a5,8(a5)
ffffffe000201198:	00079463          	bnez	a5,ffffffe0002011a0 <do_timer+0x78>
            schedule();
ffffffe00020119c:	018000ef          	jal	ra,ffffffe0002011b4 <schedule>
}
ffffffe0002011a0:	00000013          	nop
ffffffe0002011a4:	00813083          	ld	ra,8(sp)
ffffffe0002011a8:	00013403          	ld	s0,0(sp)
ffffffe0002011ac:	01010113          	addi	sp,sp,16
ffffffe0002011b0:	00008067          	ret

ffffffe0002011b4 <schedule>:

void schedule(){
ffffffe0002011b4:	fd010113          	addi	sp,sp,-48
ffffffe0002011b8:	02113423          	sd	ra,40(sp)
ffffffe0002011bc:	02813023          	sd	s0,32(sp)
ffffffe0002011c0:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
ffffffe0002011c4:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
ffffffe0002011c8:	fe043023          	sd	zero,-32(s0)
    //找到 counter 最大的线程
    for(int i=0;i<NR_TASKS;i++){
ffffffe0002011cc:	fc042e23          	sw	zero,-36(s0)
ffffffe0002011d0:	0700006f          	j	ffffffe000201240 <schedule+0x8c>
        if(task[i]->counter>max_counter){
ffffffe0002011d4:	00008717          	auipc	a4,0x8
ffffffe0002011d8:	e3c70713          	addi	a4,a4,-452 # ffffffe000209010 <task>
ffffffe0002011dc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002011e0:	00379793          	slli	a5,a5,0x3
ffffffe0002011e4:	00f707b3          	add	a5,a4,a5
ffffffe0002011e8:	0007b783          	ld	a5,0(a5)
ffffffe0002011ec:	0087b783          	ld	a5,8(a5)
ffffffe0002011f0:	fe043703          	ld	a4,-32(s0)
ffffffe0002011f4:	04f77063          	bgeu	a4,a5,ffffffe000201234 <schedule+0x80>
            max_counter=task[i]->counter;
ffffffe0002011f8:	00008717          	auipc	a4,0x8
ffffffe0002011fc:	e1870713          	addi	a4,a4,-488 # ffffffe000209010 <task>
ffffffe000201200:	fdc42783          	lw	a5,-36(s0)
ffffffe000201204:	00379793          	slli	a5,a5,0x3
ffffffe000201208:	00f707b3          	add	a5,a4,a5
ffffffe00020120c:	0007b783          	ld	a5,0(a5)
ffffffe000201210:	0087b783          	ld	a5,8(a5)
ffffffe000201214:	fef43023          	sd	a5,-32(s0)
            next=task[i];
ffffffe000201218:	00008717          	auipc	a4,0x8
ffffffe00020121c:	df870713          	addi	a4,a4,-520 # ffffffe000209010 <task>
ffffffe000201220:	fdc42783          	lw	a5,-36(s0)
ffffffe000201224:	00379793          	slli	a5,a5,0x3
ffffffe000201228:	00f707b3          	add	a5,a4,a5
ffffffe00020122c:	0007b783          	ld	a5,0(a5)
ffffffe000201230:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
ffffffe000201234:	fdc42783          	lw	a5,-36(s0)
ffffffe000201238:	0017879b          	addiw	a5,a5,1
ffffffe00020123c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201240:	fdc42783          	lw	a5,-36(s0)
ffffffe000201244:	0007871b          	sext.w	a4,a5
ffffffe000201248:	00400793          	li	a5,4
ffffffe00020124c:	f8e7d4e3          	bge	a5,a4,ffffffe0002011d4 <schedule+0x20>
        }
    }
    //如果所有线程的 counter 都为 0，则重新为每个线程分配时间片，分配策略为将线程的 priority 赋值给 counter
    if(max_counter==0){
ffffffe000201250:	fe043783          	ld	a5,-32(s0)
ffffffe000201254:	12079463          	bnez	a5,ffffffe00020137c <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
ffffffe000201258:	00100793          	li	a5,1
ffffffe00020125c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201260:	10c0006f          	j	ffffffe00020136c <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
ffffffe000201264:	00008717          	auipc	a4,0x8
ffffffe000201268:	dac70713          	addi	a4,a4,-596 # ffffffe000209010 <task>
ffffffe00020126c:	fd842783          	lw	a5,-40(s0)
ffffffe000201270:	00379793          	slli	a5,a5,0x3
ffffffe000201274:	00f707b3          	add	a5,a4,a5
ffffffe000201278:	0007b703          	ld	a4,0(a5)
ffffffe00020127c:	00008697          	auipc	a3,0x8
ffffffe000201280:	d9468693          	addi	a3,a3,-620 # ffffffe000209010 <task>
ffffffe000201284:	fd842783          	lw	a5,-40(s0)
ffffffe000201288:	00379793          	slli	a5,a5,0x3
ffffffe00020128c:	00f687b3          	add	a5,a3,a5
ffffffe000201290:	0007b783          	ld	a5,0(a5)
ffffffe000201294:	01073703          	ld	a4,16(a4)
ffffffe000201298:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
ffffffe00020129c:	00008717          	auipc	a4,0x8
ffffffe0002012a0:	d7470713          	addi	a4,a4,-652 # ffffffe000209010 <task>
ffffffe0002012a4:	fd842783          	lw	a5,-40(s0)
ffffffe0002012a8:	00379793          	slli	a5,a5,0x3
ffffffe0002012ac:	00f707b3          	add	a5,a4,a5
ffffffe0002012b0:	0007b783          	ld	a5,0(a5)
ffffffe0002012b4:	0187b583          	ld	a1,24(a5)
ffffffe0002012b8:	00008717          	auipc	a4,0x8
ffffffe0002012bc:	d5870713          	addi	a4,a4,-680 # ffffffe000209010 <task>
ffffffe0002012c0:	fd842783          	lw	a5,-40(s0)
ffffffe0002012c4:	00379793          	slli	a5,a5,0x3
ffffffe0002012c8:	00f707b3          	add	a5,a4,a5
ffffffe0002012cc:	0007b783          	ld	a5,0(a5)
ffffffe0002012d0:	0107b603          	ld	a2,16(a5)
ffffffe0002012d4:	00008717          	auipc	a4,0x8
ffffffe0002012d8:	d3c70713          	addi	a4,a4,-708 # ffffffe000209010 <task>
ffffffe0002012dc:	fd842783          	lw	a5,-40(s0)
ffffffe0002012e0:	00379793          	slli	a5,a5,0x3
ffffffe0002012e4:	00f707b3          	add	a5,a4,a5
ffffffe0002012e8:	0007b783          	ld	a5,0(a5)
ffffffe0002012ec:	0087b783          	ld	a5,8(a5)
ffffffe0002012f0:	00078693          	mv	a3,a5
ffffffe0002012f4:	00002517          	auipc	a0,0x2
ffffffe0002012f8:	dc450513          	addi	a0,a0,-572 # ffffffe0002030b8 <_srodata+0xb8>
ffffffe0002012fc:	00d010ef          	jal	ra,ffffffe000202b08 <printk>
            if(task[i]->counter>max_counter){
ffffffe000201300:	00008717          	auipc	a4,0x8
ffffffe000201304:	d1070713          	addi	a4,a4,-752 # ffffffe000209010 <task>
ffffffe000201308:	fd842783          	lw	a5,-40(s0)
ffffffe00020130c:	00379793          	slli	a5,a5,0x3
ffffffe000201310:	00f707b3          	add	a5,a4,a5
ffffffe000201314:	0007b783          	ld	a5,0(a5)
ffffffe000201318:	0087b783          	ld	a5,8(a5)
ffffffe00020131c:	fe043703          	ld	a4,-32(s0)
ffffffe000201320:	04f77063          	bgeu	a4,a5,ffffffe000201360 <schedule+0x1ac>
                max_counter=task[i]->counter;
ffffffe000201324:	00008717          	auipc	a4,0x8
ffffffe000201328:	cec70713          	addi	a4,a4,-788 # ffffffe000209010 <task>
ffffffe00020132c:	fd842783          	lw	a5,-40(s0)
ffffffe000201330:	00379793          	slli	a5,a5,0x3
ffffffe000201334:	00f707b3          	add	a5,a4,a5
ffffffe000201338:	0007b783          	ld	a5,0(a5)
ffffffe00020133c:	0087b783          	ld	a5,8(a5)
ffffffe000201340:	fef43023          	sd	a5,-32(s0)
                next=task[i];
ffffffe000201344:	00008717          	auipc	a4,0x8
ffffffe000201348:	ccc70713          	addi	a4,a4,-820 # ffffffe000209010 <task>
ffffffe00020134c:	fd842783          	lw	a5,-40(s0)
ffffffe000201350:	00379793          	slli	a5,a5,0x3
ffffffe000201354:	00f707b3          	add	a5,a4,a5
ffffffe000201358:	0007b783          	ld	a5,0(a5)
ffffffe00020135c:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
ffffffe000201360:	fd842783          	lw	a5,-40(s0)
ffffffe000201364:	0017879b          	addiw	a5,a5,1
ffffffe000201368:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020136c:	fd842783          	lw	a5,-40(s0)
ffffffe000201370:	0007871b          	sext.w	a4,a5
ffffffe000201374:	00400793          	li	a5,4
ffffffe000201378:	eee7d6e3          	bge	a5,a4,ffffffe000201264 <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
ffffffe00020137c:	fe843783          	ld	a5,-24(s0)
ffffffe000201380:	00078663          	beqz	a5,ffffffe00020138c <schedule+0x1d8>
ffffffe000201384:	fe843503          	ld	a0,-24(s0)
ffffffe000201388:	d09ff0ef          	jal	ra,ffffffe000201090 <switch_to>
}
ffffffe00020138c:	00000013          	nop
ffffffe000201390:	02813083          	ld	ra,40(sp)
ffffffe000201394:	02013403          	ld	s0,32(sp)
ffffffe000201398:	03010113          	addi	sp,sp,48
ffffffe00020139c:	00008067          	ret

ffffffe0002013a0 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe0002013a0:	f8010113          	addi	sp,sp,-128
ffffffe0002013a4:	06813c23          	sd	s0,120(sp)
ffffffe0002013a8:	06913823          	sd	s1,112(sp)
ffffffe0002013ac:	07213423          	sd	s2,104(sp)
ffffffe0002013b0:	07313023          	sd	s3,96(sp)
ffffffe0002013b4:	08010413          	addi	s0,sp,128
ffffffe0002013b8:	faa43c23          	sd	a0,-72(s0)
ffffffe0002013bc:	fab43823          	sd	a1,-80(s0)
ffffffe0002013c0:	fac43423          	sd	a2,-88(s0)
ffffffe0002013c4:	fad43023          	sd	a3,-96(s0)
ffffffe0002013c8:	f8e43c23          	sd	a4,-104(s0)
ffffffe0002013cc:	f8f43823          	sd	a5,-112(s0)
ffffffe0002013d0:	f9043423          	sd	a6,-120(s0)
ffffffe0002013d4:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
ffffffe0002013d8:	fb843e03          	ld	t3,-72(s0)
ffffffe0002013dc:	fb043e83          	ld	t4,-80(s0)
ffffffe0002013e0:	fa843f03          	ld	t5,-88(s0)
ffffffe0002013e4:	fa043f83          	ld	t6,-96(s0)
ffffffe0002013e8:	f9843283          	ld	t0,-104(s0)
ffffffe0002013ec:	f9043483          	ld	s1,-112(s0)
ffffffe0002013f0:	f8843903          	ld	s2,-120(s0)
ffffffe0002013f4:	f8043983          	ld	s3,-128(s0)
ffffffe0002013f8:	000e0893          	mv	a7,t3
ffffffe0002013fc:	000e8813          	mv	a6,t4
ffffffe000201400:	000f0513          	mv	a0,t5
ffffffe000201404:	000f8593          	mv	a1,t6
ffffffe000201408:	00028613          	mv	a2,t0
ffffffe00020140c:	00048693          	mv	a3,s1
ffffffe000201410:	00090713          	mv	a4,s2
ffffffe000201414:	00098793          	mv	a5,s3
ffffffe000201418:	00000073          	ecall
ffffffe00020141c:	00050e93          	mv	t4,a0
ffffffe000201420:	00058e13          	mv	t3,a1
ffffffe000201424:	fdd43023          	sd	t4,-64(s0)
ffffffe000201428:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
ffffffe00020142c:	fc043783          	ld	a5,-64(s0)
ffffffe000201430:	fcf43823          	sd	a5,-48(s0)
ffffffe000201434:	fc843783          	ld	a5,-56(s0)
ffffffe000201438:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020143c:	00000713          	li	a4,0
ffffffe000201440:	fd043703          	ld	a4,-48(s0)
ffffffe000201444:	00000793          	li	a5,0
ffffffe000201448:	fd843783          	ld	a5,-40(s0)
ffffffe00020144c:	00070313          	mv	t1,a4
ffffffe000201450:	00078393          	mv	t2,a5
ffffffe000201454:	00030713          	mv	a4,t1
ffffffe000201458:	00038793          	mv	a5,t2
}
ffffffe00020145c:	00070513          	mv	a0,a4
ffffffe000201460:	00078593          	mv	a1,a5
ffffffe000201464:	07813403          	ld	s0,120(sp)
ffffffe000201468:	07013483          	ld	s1,112(sp)
ffffffe00020146c:	06813903          	ld	s2,104(sp)
ffffffe000201470:	06013983          	ld	s3,96(sp)
ffffffe000201474:	08010113          	addi	sp,sp,128
ffffffe000201478:	00008067          	ret

ffffffe00020147c <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe00020147c:	fc010113          	addi	sp,sp,-64
ffffffe000201480:	02113c23          	sd	ra,56(sp)
ffffffe000201484:	02813823          	sd	s0,48(sp)
ffffffe000201488:	03213423          	sd	s2,40(sp)
ffffffe00020148c:	03313023          	sd	s3,32(sp)
ffffffe000201490:	04010413          	addi	s0,sp,64
ffffffe000201494:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
ffffffe000201498:	00000893          	li	a7,0
ffffffe00020149c:	00000813          	li	a6,0
ffffffe0002014a0:	00000793          	li	a5,0
ffffffe0002014a4:	00000713          	li	a4,0
ffffffe0002014a8:	00000693          	li	a3,0
ffffffe0002014ac:	fc843603          	ld	a2,-56(s0)
ffffffe0002014b0:	00000593          	li	a1,0
ffffffe0002014b4:	54495537          	lui	a0,0x54495
ffffffe0002014b8:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002014bc:	ee5ff0ef          	jal	ra,ffffffe0002013a0 <sbi_ecall>
ffffffe0002014c0:	00050713          	mv	a4,a0
ffffffe0002014c4:	00058793          	mv	a5,a1
ffffffe0002014c8:	fce43823          	sd	a4,-48(s0)
ffffffe0002014cc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002014d0:	00000713          	li	a4,0
ffffffe0002014d4:	fd043703          	ld	a4,-48(s0)
ffffffe0002014d8:	00000793          	li	a5,0
ffffffe0002014dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002014e0:	00070913          	mv	s2,a4
ffffffe0002014e4:	00078993          	mv	s3,a5
ffffffe0002014e8:	00090713          	mv	a4,s2
ffffffe0002014ec:	00098793          	mv	a5,s3
}
ffffffe0002014f0:	00070513          	mv	a0,a4
ffffffe0002014f4:	00078593          	mv	a1,a5
ffffffe0002014f8:	03813083          	ld	ra,56(sp)
ffffffe0002014fc:	03013403          	ld	s0,48(sp)
ffffffe000201500:	02813903          	ld	s2,40(sp)
ffffffe000201504:	02013983          	ld	s3,32(sp)
ffffffe000201508:	04010113          	addi	sp,sp,64
ffffffe00020150c:	00008067          	ret

ffffffe000201510 <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201510:	fc010113          	addi	sp,sp,-64
ffffffe000201514:	02113c23          	sd	ra,56(sp)
ffffffe000201518:	02813823          	sd	s0,48(sp)
ffffffe00020151c:	03213423          	sd	s2,40(sp)
ffffffe000201520:	03313023          	sd	s3,32(sp)
ffffffe000201524:	04010413          	addi	s0,sp,64
ffffffe000201528:	00050793          	mv	a5,a0
ffffffe00020152c:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
ffffffe000201530:	fcf44603          	lbu	a2,-49(s0)
ffffffe000201534:	00000893          	li	a7,0
ffffffe000201538:	00000813          	li	a6,0
ffffffe00020153c:	00000793          	li	a5,0
ffffffe000201540:	00000713          	li	a4,0
ffffffe000201544:	00000693          	li	a3,0
ffffffe000201548:	00200593          	li	a1,2
ffffffe00020154c:	44424537          	lui	a0,0x44424
ffffffe000201550:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201554:	e4dff0ef          	jal	ra,ffffffe0002013a0 <sbi_ecall>
ffffffe000201558:	00050713          	mv	a4,a0
ffffffe00020155c:	00058793          	mv	a5,a1
ffffffe000201560:	fce43823          	sd	a4,-48(s0)
ffffffe000201564:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201568:	00000713          	li	a4,0
ffffffe00020156c:	fd043703          	ld	a4,-48(s0)
ffffffe000201570:	00000793          	li	a5,0
ffffffe000201574:	fd843783          	ld	a5,-40(s0)
ffffffe000201578:	00070913          	mv	s2,a4
ffffffe00020157c:	00078993          	mv	s3,a5
ffffffe000201580:	00090713          	mv	a4,s2
ffffffe000201584:	00098793          	mv	a5,s3
}
ffffffe000201588:	00070513          	mv	a0,a4
ffffffe00020158c:	00078593          	mv	a1,a5
ffffffe000201590:	03813083          	ld	ra,56(sp)
ffffffe000201594:	03013403          	ld	s0,48(sp)
ffffffe000201598:	02813903          	ld	s2,40(sp)
ffffffe00020159c:	02013983          	ld	s3,32(sp)
ffffffe0002015a0:	04010113          	addi	sp,sp,64
ffffffe0002015a4:	00008067          	ret

ffffffe0002015a8 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe0002015a8:	fc010113          	addi	sp,sp,-64
ffffffe0002015ac:	02113c23          	sd	ra,56(sp)
ffffffe0002015b0:	02813823          	sd	s0,48(sp)
ffffffe0002015b4:	03213423          	sd	s2,40(sp)
ffffffe0002015b8:	03313023          	sd	s3,32(sp)
ffffffe0002015bc:	04010413          	addi	s0,sp,64
ffffffe0002015c0:	00050793          	mv	a5,a0
ffffffe0002015c4:	00058713          	mv	a4,a1
ffffffe0002015c8:	fcf42623          	sw	a5,-52(s0)
ffffffe0002015cc:	00070793          	mv	a5,a4
ffffffe0002015d0:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
ffffffe0002015d4:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002015d8:	fc846683          	lwu	a3,-56(s0)
ffffffe0002015dc:	00000893          	li	a7,0
ffffffe0002015e0:	00000813          	li	a6,0
ffffffe0002015e4:	00000793          	li	a5,0
ffffffe0002015e8:	00000713          	li	a4,0
ffffffe0002015ec:	00000593          	li	a1,0
ffffffe0002015f0:	53525537          	lui	a0,0x53525
ffffffe0002015f4:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002015f8:	da9ff0ef          	jal	ra,ffffffe0002013a0 <sbi_ecall>
ffffffe0002015fc:	00050713          	mv	a4,a0
ffffffe000201600:	00058793          	mv	a5,a1
ffffffe000201604:	fce43823          	sd	a4,-48(s0)
ffffffe000201608:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020160c:	00000713          	li	a4,0
ffffffe000201610:	fd043703          	ld	a4,-48(s0)
ffffffe000201614:	00000793          	li	a5,0
ffffffe000201618:	fd843783          	ld	a5,-40(s0)
ffffffe00020161c:	00070913          	mv	s2,a4
ffffffe000201620:	00078993          	mv	s3,a5
ffffffe000201624:	00090713          	mv	a4,s2
ffffffe000201628:	00098793          	mv	a5,s3
ffffffe00020162c:	00070513          	mv	a0,a4
ffffffe000201630:	00078593          	mv	a1,a5
ffffffe000201634:	03813083          	ld	ra,56(sp)
ffffffe000201638:	03013403          	ld	s0,48(sp)
ffffffe00020163c:	02813903          	ld	s2,40(sp)
ffffffe000201640:	02013983          	ld	s3,32(sp)
ffffffe000201644:	04010113          	addi	sp,sp,64
ffffffe000201648:	00008067          	ret

ffffffe00020164c <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe00020164c:	fd010113          	addi	sp,sp,-48
ffffffe000201650:	02113423          	sd	ra,40(sp)
ffffffe000201654:	02813023          	sd	s0,32(sp)
ffffffe000201658:	03010413          	addi	s0,sp,48
ffffffe00020165c:	fca43c23          	sd	a0,-40(s0)
ffffffe000201660:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
ffffffe000201664:	fd843783          	ld	a5,-40(s0)
ffffffe000201668:	0407d263          	bgez	a5,ffffffe0002016ac <trap_handler+0x60>
        uint64_t interrupt_code = scause & ~(1UL << 63);
ffffffe00020166c:	fd843703          	ld	a4,-40(s0)
ffffffe000201670:	fff00793          	li	a5,-1
ffffffe000201674:	0017d793          	srli	a5,a5,0x1
ffffffe000201678:	00f777b3          	and	a5,a4,a5
ffffffe00020167c:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
ffffffe000201680:	fe043703          	ld	a4,-32(s0)
ffffffe000201684:	00500793          	li	a5,5
ffffffe000201688:	00f71863          	bne	a4,a5,ffffffe000201698 <trap_handler+0x4c>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
ffffffe00020168c:	c95fe0ef          	jal	ra,ffffffe000200320 <clock_set_next_event>
            do_timer();
ffffffe000201690:	a99ff0ef          	jal	ra,ffffffe000201128 <do_timer>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
ffffffe000201694:	0300006f          	j	ffffffe0002016c4 <trap_handler+0x78>
            printk("other interrupt: %d\n", interrupt_code);
ffffffe000201698:	fe043583          	ld	a1,-32(s0)
ffffffe00020169c:	00002517          	auipc	a0,0x2
ffffffe0002016a0:	a5450513          	addi	a0,a0,-1452 # ffffffe0002030f0 <_srodata+0xf0>
ffffffe0002016a4:	464010ef          	jal	ra,ffffffe000202b08 <printk>
ffffffe0002016a8:	01c0006f          	j	ffffffe0002016c4 <trap_handler+0x78>
        uint64_t exception_code = scause;
ffffffe0002016ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002016b0:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
ffffffe0002016b4:	fe843583          	ld	a1,-24(s0)
ffffffe0002016b8:	00002517          	auipc	a0,0x2
ffffffe0002016bc:	a5050513          	addi	a0,a0,-1456 # ffffffe000203108 <_srodata+0x108>
ffffffe0002016c0:	448010ef          	jal	ra,ffffffe000202b08 <printk>
ffffffe0002016c4:	00000013          	nop
ffffffe0002016c8:	02813083          	ld	ra,40(sp)
ffffffe0002016cc:	02013403          	ld	s0,32(sp)
ffffffe0002016d0:	03010113          	addi	sp,sp,48
ffffffe0002016d4:	00008067          	ret

ffffffe0002016d8 <setup_vm>:
extern char _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe0002016d8:	fc010113          	addi	sp,sp,-64
ffffffe0002016dc:	02813c23          	sd	s0,56(sp)
ffffffe0002016e0:	04010413          	addi	s0,sp,64
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   uint64_t pa=0x80000000;
ffffffe0002016e4:	00100793          	li	a5,1
ffffffe0002016e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002016ec:	fef43423          	sd	a5,-24(s0)
   uint64_t va_eq=pa;
ffffffe0002016f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002016f4:	fef43023          	sd	a5,-32(s0)
   uint64_t va_direct=pa+PA2VA_OFFSET;
ffffffe0002016f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002016fc:	fbf00793          	li	a5,-65
ffffffe000201700:	01f79793          	slli	a5,a5,0x1f
ffffffe000201704:	00f707b3          	add	a5,a4,a5
ffffffe000201708:	fcf43c23          	sd	a5,-40(s0)

   uint64_t perm = PTE_V|PTE_R|PTE_W|PTE_X; // V | R | W | X
ffffffe00020170c:	00f00793          	li	a5,15
ffffffe000201710:	fcf43823          	sd	a5,-48(s0)
    //中间 9 bit 作为 early_pgtbl 的 index
   uint64_t idx_eq=(va_eq>>30)&0x1ff; 
ffffffe000201714:	fe043783          	ld	a5,-32(s0)
ffffffe000201718:	01e7d793          	srli	a5,a5,0x1e
ffffffe00020171c:	1ff7f793          	andi	a5,a5,511
ffffffe000201720:	fcf43423          	sd	a5,-56(s0)
   uint64_t idx_direct=(va_direct>>30)&0x1ff;
ffffffe000201724:	fd843783          	ld	a5,-40(s0)
ffffffe000201728:	01e7d793          	srli	a5,a5,0x1e
ffffffe00020172c:	1ff7f793          	andi	a5,a5,511
ffffffe000201730:	fcf43023          	sd	a5,-64(s0)

    early_pgtbl[idx_eq]= (pa>>12)<<10 | perm;       //等值映射
ffffffe000201734:	fe843783          	ld	a5,-24(s0)
ffffffe000201738:	00c7d793          	srli	a5,a5,0xc
ffffffe00020173c:	00a79713          	slli	a4,a5,0xa
ffffffe000201740:	fd043783          	ld	a5,-48(s0)
ffffffe000201744:	00f76733          	or	a4,a4,a5
ffffffe000201748:	00009697          	auipc	a3,0x9
ffffffe00020174c:	8b868693          	addi	a3,a3,-1864 # ffffffe00020a000 <early_pgtbl>
ffffffe000201750:	fc843783          	ld	a5,-56(s0)
ffffffe000201754:	00379793          	slli	a5,a5,0x3
ffffffe000201758:	00f687b3          	add	a5,a3,a5
ffffffe00020175c:	00e7b023          	sd	a4,0(a5)
    early_pgtbl[idx_direct]= (pa>>12)<<10 | perm;   //直接映射
ffffffe000201760:	fe843783          	ld	a5,-24(s0)
ffffffe000201764:	00c7d793          	srli	a5,a5,0xc
ffffffe000201768:	00a79713          	slli	a4,a5,0xa
ffffffe00020176c:	fd043783          	ld	a5,-48(s0)
ffffffe000201770:	00f76733          	or	a4,a4,a5
ffffffe000201774:	00009697          	auipc	a3,0x9
ffffffe000201778:	88c68693          	addi	a3,a3,-1908 # ffffffe00020a000 <early_pgtbl>
ffffffe00020177c:	fc043783          	ld	a5,-64(s0)
ffffffe000201780:	00379793          	slli	a5,a5,0x3
ffffffe000201784:	00f687b3          	add	a5,a3,a5
ffffffe000201788:	00e7b023          	sd	a4,0(a5)
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //       pa, va_eq, idx_eq);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //        pa, va_direct, idx_direct);

}
ffffffe00020178c:	00000013          	nop
ffffffe000201790:	03813403          	ld	s0,56(sp)
ffffffe000201794:	04010113          	addi	sp,sp,64
ffffffe000201798:	00008067          	ret

ffffffe00020179c <setup_vm_neq>:

void setup_vm_neq(){
ffffffe00020179c:	ff010113          	addi	sp,sp,-16
ffffffe0002017a0:	00813423          	sd	s0,8(sp)
ffffffe0002017a4:	01010413          	addi	s0,sp,16

}
ffffffe0002017a8:	00000013          	nop
ffffffe0002017ac:	00813403          	ld	s0,8(sp)
ffffffe0002017b0:	01010113          	addi	sp,sp,16
ffffffe0002017b4:	00008067          	ret

ffffffe0002017b8 <create_mapping>:

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe0002017b8:	f5010113          	addi	sp,sp,-176
ffffffe0002017bc:	0a113423          	sd	ra,168(sp)
ffffffe0002017c0:	0a813023          	sd	s0,160(sp)
ffffffe0002017c4:	0b010413          	addi	s0,sp,176
ffffffe0002017c8:	f6a43c23          	sd	a0,-136(s0)
ffffffe0002017cc:	f6b43823          	sd	a1,-144(s0)
ffffffe0002017d0:	f6c43423          	sd	a2,-152(s0)
ffffffe0002017d4:	f6d43023          	sd	a3,-160(s0)
ffffffe0002017d8:	f4e43c23          	sd	a4,-168(s0)
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_curr=va;
ffffffe0002017dc:	f7043783          	ld	a5,-144(s0)
ffffffe0002017e0:	fef43423          	sd	a5,-24(s0)
    uint64_t pa_curr=pa;
ffffffe0002017e4:	f6843783          	ld	a5,-152(s0)
ffffffe0002017e8:	fef43023          	sd	a5,-32(s0)
    uint64_t va_end=va+sz;
ffffffe0002017ec:	f7043703          	ld	a4,-144(s0)
ffffffe0002017f0:	f6043783          	ld	a5,-160(s0)
ffffffe0002017f4:	00f707b3          	add	a5,a4,a5
ffffffe0002017f8:	fcf43c23          	sd	a5,-40(s0)

    while(va_curr<va_end){
ffffffe0002017fc:	1bc0006f          	j	ffffffe0002019b8 <create_mapping+0x200>
        uint64_t vpn2=(va_curr>>30)&0x1ff;  //VA[39:30]
ffffffe000201800:	fe843783          	ld	a5,-24(s0)
ffffffe000201804:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201808:	1ff7f793          	andi	a5,a5,511
ffffffe00020180c:	fcf43823          	sd	a5,-48(s0)
        uint64_t vpn1=(va_curr>>21)&0x1ff;  //VA[29:21]
ffffffe000201810:	fe843783          	ld	a5,-24(s0)
ffffffe000201814:	0157d793          	srli	a5,a5,0x15
ffffffe000201818:	1ff7f793          	andi	a5,a5,511
ffffffe00020181c:	fcf43423          	sd	a5,-56(s0)
        uint64_t vpn0=(va_curr>>12)&0x1ff;  //VA[20:12]
ffffffe000201820:	fe843783          	ld	a5,-24(s0)
ffffffe000201824:	00c7d793          	srli	a5,a5,0xc
ffffffe000201828:	1ff7f793          	andi	a5,a5,511
ffffffe00020182c:	fcf43023          	sd	a5,-64(s0)

        
        if(!(pgtbl[vpn2]&PTE_V)){
ffffffe000201830:	fd043783          	ld	a5,-48(s0)
ffffffe000201834:	00379793          	slli	a5,a5,0x3
ffffffe000201838:	f7843703          	ld	a4,-136(s0)
ffffffe00020183c:	00f707b3          	add	a5,a4,a5
ffffffe000201840:	0007b783          	ld	a5,0(a5)
ffffffe000201844:	0017f793          	andi	a5,a5,1
ffffffe000201848:	04079a63          	bnez	a5,ffffffe00020189c <create_mapping+0xe4>
            //分配新的二级页表
            uint64_t *patbl2=(uint64_t *)kalloc();
ffffffe00020184c:	9acff0ef          	jal	ra,ffffffe0002009f8 <kalloc>
ffffffe000201850:	faa43c23          	sd	a0,-72(s0)
            memset(patbl2,0,PGSIZE);
ffffffe000201854:	00001637          	lui	a2,0x1
ffffffe000201858:	00000593          	li	a1,0
ffffffe00020185c:	fb843503          	ld	a0,-72(s0)
ffffffe000201860:	3c8010ef          	jal	ra,ffffffe000202c28 <memset>
            //转化物理地址
            uint64_t patbl2_pa=(uint64_t)patbl2-PA2VA_OFFSET;
ffffffe000201864:	fb843703          	ld	a4,-72(s0)
ffffffe000201868:	04100793          	li	a5,65
ffffffe00020186c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201870:	00f707b3          	add	a5,a4,a5
ffffffe000201874:	faf43823          	sd	a5,-80(s0)
            pgtbl[vpn2]=((uint64_t)patbl2_pa>>12)<<10|PTE_V;
ffffffe000201878:	fb043783          	ld	a5,-80(s0)
ffffffe00020187c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201880:	00a79713          	slli	a4,a5,0xa
ffffffe000201884:	fd043783          	ld	a5,-48(s0)
ffffffe000201888:	00379793          	slli	a5,a5,0x3
ffffffe00020188c:	f7843683          	ld	a3,-136(s0)
ffffffe000201890:	00f687b3          	add	a5,a3,a5
ffffffe000201894:	00176713          	ori	a4,a4,1
ffffffe000201898:	00e7b023          	sd	a4,0(a5)
        }
        //二级页表物理地址
        uint64_t patbl2_pa=(uint64_t *)((pgtbl[vpn2]>>10)<<12); 
ffffffe00020189c:	fd043783          	ld	a5,-48(s0)
ffffffe0002018a0:	00379793          	slli	a5,a5,0x3
ffffffe0002018a4:	f7843703          	ld	a4,-136(s0)
ffffffe0002018a8:	00f707b3          	add	a5,a4,a5
ffffffe0002018ac:	0007b783          	ld	a5,0(a5)
ffffffe0002018b0:	00a7d793          	srli	a5,a5,0xa
ffffffe0002018b4:	00c79793          	slli	a5,a5,0xc
ffffffe0002018b8:	faf43423          	sd	a5,-88(s0)
        uint64_t *patbl2=(uint64_t *)(patbl2_pa+PA2VA_OFFSET);              
ffffffe0002018bc:	fa843703          	ld	a4,-88(s0)
ffffffe0002018c0:	fbf00793          	li	a5,-65
ffffffe0002018c4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002018c8:	00f707b3          	add	a5,a4,a5
ffffffe0002018cc:	faf43023          	sd	a5,-96(s0)

        if(!(patbl2[vpn1]&PTE_V)){
ffffffe0002018d0:	fc843783          	ld	a5,-56(s0)
ffffffe0002018d4:	00379793          	slli	a5,a5,0x3
ffffffe0002018d8:	fa043703          	ld	a4,-96(s0)
ffffffe0002018dc:	00f707b3          	add	a5,a4,a5
ffffffe0002018e0:	0007b783          	ld	a5,0(a5)
ffffffe0002018e4:	0017f793          	andi	a5,a5,1
ffffffe0002018e8:	04079a63          	bnez	a5,ffffffe00020193c <create_mapping+0x184>
            uint64_t *patbl1=(uint64_t *)kalloc();
ffffffe0002018ec:	90cff0ef          	jal	ra,ffffffe0002009f8 <kalloc>
ffffffe0002018f0:	f8a43c23          	sd	a0,-104(s0)
            memset(patbl1,0,PGSIZE);
ffffffe0002018f4:	00001637          	lui	a2,0x1
ffffffe0002018f8:	00000593          	li	a1,0
ffffffe0002018fc:	f9843503          	ld	a0,-104(s0)
ffffffe000201900:	328010ef          	jal	ra,ffffffe000202c28 <memset>
            uint64_t patbl1_pa=(uint64_t)patbl1-PA2VA_OFFSET;
ffffffe000201904:	f9843703          	ld	a4,-104(s0)
ffffffe000201908:	04100793          	li	a5,65
ffffffe00020190c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201910:	00f707b3          	add	a5,a4,a5
ffffffe000201914:	f8f43823          	sd	a5,-112(s0)
            patbl2[vpn1]=((uint64_t)patbl1_pa>>12)<<10|PTE_V;
ffffffe000201918:	f9043783          	ld	a5,-112(s0)
ffffffe00020191c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201920:	00a79713          	slli	a4,a5,0xa
ffffffe000201924:	fc843783          	ld	a5,-56(s0)
ffffffe000201928:	00379793          	slli	a5,a5,0x3
ffffffe00020192c:	fa043683          	ld	a3,-96(s0)
ffffffe000201930:	00f687b3          	add	a5,a3,a5
ffffffe000201934:	00176713          	ori	a4,a4,1
ffffffe000201938:	00e7b023          	sd	a4,0(a5)
        }
        //三级页表物理地址
        uint64_t patbl1_pa=(uint64_t *)((patbl2[vpn1]>>10)<<12); 
ffffffe00020193c:	fc843783          	ld	a5,-56(s0)
ffffffe000201940:	00379793          	slli	a5,a5,0x3
ffffffe000201944:	fa043703          	ld	a4,-96(s0)
ffffffe000201948:	00f707b3          	add	a5,a4,a5
ffffffe00020194c:	0007b783          	ld	a5,0(a5)
ffffffe000201950:	00a7d793          	srli	a5,a5,0xa
ffffffe000201954:	00c79793          	slli	a5,a5,0xc
ffffffe000201958:	f8f43423          	sd	a5,-120(s0)
        uint64_t *patbl1=(uint64_t *)(patbl1_pa+PA2VA_OFFSET);
ffffffe00020195c:	f8843703          	ld	a4,-120(s0)
ffffffe000201960:	fbf00793          	li	a5,-65
ffffffe000201964:	01f79793          	slli	a5,a5,0x1f
ffffffe000201968:	00f707b3          	add	a5,a4,a5
ffffffe00020196c:	f8f43023          	sd	a5,-128(s0)
        //最终页表项
        patbl1[vpn0]=(pa_curr>>12)<<10|perm;
ffffffe000201970:	fe043783          	ld	a5,-32(s0)
ffffffe000201974:	00c7d793          	srli	a5,a5,0xc
ffffffe000201978:	00a79693          	slli	a3,a5,0xa
ffffffe00020197c:	fc043783          	ld	a5,-64(s0)
ffffffe000201980:	00379793          	slli	a5,a5,0x3
ffffffe000201984:	f8043703          	ld	a4,-128(s0)
ffffffe000201988:	00f707b3          	add	a5,a4,a5
ffffffe00020198c:	f5843703          	ld	a4,-168(s0)
ffffffe000201990:	00e6e733          	or	a4,a3,a4
ffffffe000201994:	00e7b023          	sd	a4,0(a5)

        va_curr+=PGSIZE;
ffffffe000201998:	fe843703          	ld	a4,-24(s0)
ffffffe00020199c:	000017b7          	lui	a5,0x1
ffffffe0002019a0:	00f707b3          	add	a5,a4,a5
ffffffe0002019a4:	fef43423          	sd	a5,-24(s0)
        pa_curr+=PGSIZE;
ffffffe0002019a8:	fe043703          	ld	a4,-32(s0)
ffffffe0002019ac:	000017b7          	lui	a5,0x1
ffffffe0002019b0:	00f707b3          	add	a5,a4,a5
ffffffe0002019b4:	fef43023          	sd	a5,-32(s0)
    while(va_curr<va_end){
ffffffe0002019b8:	fe843703          	ld	a4,-24(s0)
ffffffe0002019bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002019c0:	e4f760e3          	bltu	a4,a5,ffffffe000201800 <create_mapping+0x48>
    }
}
ffffffe0002019c4:	00000013          	nop
ffffffe0002019c8:	00000013          	nop
ffffffe0002019cc:	0a813083          	ld	ra,168(sp)
ffffffe0002019d0:	0a013403          	ld	s0,160(sp)
ffffffe0002019d4:	0b010113          	addi	sp,sp,176
ffffffe0002019d8:	00008067          	ret

ffffffe0002019dc <setup_vm_final>:

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
ffffffe0002019dc:	fe010113          	addi	sp,sp,-32
ffffffe0002019e0:	00113c23          	sd	ra,24(sp)
ffffffe0002019e4:	00813823          	sd	s0,16(sp)
ffffffe0002019e8:	02010413          	addi	s0,sp,32
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe0002019ec:	00001637          	lui	a2,0x1
ffffffe0002019f0:	00000593          	li	a1,0
ffffffe0002019f4:	00006517          	auipc	a0,0x6
ffffffe0002019f8:	60c50513          	addi	a0,a0,1548 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002019fc:	22c010ef          	jal	ra,ffffffe000202c28 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201a00:	ffffe597          	auipc	a1,0xffffe
ffffffe000201a04:	60058593          	addi	a1,a1,1536 # ffffffe000200000 <_skernel>
ffffffe000201a08:	ffffe717          	auipc	a4,0xffffe
ffffffe000201a0c:	5f870713          	addi	a4,a4,1528 # ffffffe000200000 <_skernel>
ffffffe000201a10:	04100793          	li	a5,65
ffffffe000201a14:	01f79793          	slli	a5,a5,0x1f
ffffffe000201a18:	00f707b3          	add	a5,a4,a5
ffffffe000201a1c:	00078613          	mv	a2,a5
                   (uint64_t)(_etext - _stext),PTE_X|PTE_R|PTE_V);
ffffffe000201a20:	00001717          	auipc	a4,0x1
ffffffe000201a24:	27870713          	addi	a4,a4,632 # ffffffe000202c98 <_etext>
ffffffe000201a28:	ffffe797          	auipc	a5,0xffffe
ffffffe000201a2c:	5d878793          	addi	a5,a5,1496 # ffffffe000200000 <_skernel>
ffffffe000201a30:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201a34:	00b00713          	li	a4,11
ffffffe000201a38:	00078693          	mv	a3,a5
ffffffe000201a3c:	00006517          	auipc	a0,0x6
ffffffe000201a40:	5c450513          	addi	a0,a0,1476 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201a44:	d75ff0ef          	jal	ra,ffffffe0002017b8 <create_mapping>
    printk("setup_vm_final: mapping kernel text done!\n");
ffffffe000201a48:	00001517          	auipc	a0,0x1
ffffffe000201a4c:	6d050513          	addi	a0,a0,1744 # ffffffe000203118 <_srodata+0x118>
ffffffe000201a50:	0b8010ef          	jal	ra,ffffffe000202b08 <printk>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201a54:	00001597          	auipc	a1,0x1
ffffffe000201a58:	5ac58593          	addi	a1,a1,1452 # ffffffe000203000 <_srodata>
ffffffe000201a5c:	00001717          	auipc	a4,0x1
ffffffe000201a60:	5a470713          	addi	a4,a4,1444 # ffffffe000203000 <_srodata>
ffffffe000201a64:	04100793          	li	a5,65
ffffffe000201a68:	01f79793          	slli	a5,a5,0x1f
ffffffe000201a6c:	00f707b3          	add	a5,a4,a5
ffffffe000201a70:	00078613          	mv	a2,a5
                   (uint64_t)(_erodata - _srodata),PTE_R|PTE_V);
ffffffe000201a74:	00002717          	auipc	a4,0x2
ffffffe000201a78:	80470713          	addi	a4,a4,-2044 # ffffffe000203278 <_erodata>
ffffffe000201a7c:	00001797          	auipc	a5,0x1
ffffffe000201a80:	58478793          	addi	a5,a5,1412 # ffffffe000203000 <_srodata>
ffffffe000201a84:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201a88:	00300713          	li	a4,3
ffffffe000201a8c:	00078693          	mv	a3,a5
ffffffe000201a90:	00006517          	auipc	a0,0x6
ffffffe000201a94:	57050513          	addi	a0,a0,1392 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201a98:	d21ff0ef          	jal	ra,ffffffe0002017b8 <create_mapping>
    printk("setup_vm_final: mapping kernel rodata done!\n");
ffffffe000201a9c:	00001517          	auipc	a0,0x1
ffffffe000201aa0:	6ac50513          	addi	a0,a0,1708 # ffffffe000203148 <_srodata+0x148>
ffffffe000201aa4:	064010ef          	jal	ra,ffffffe000202b08 <printk>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201aa8:	00002597          	auipc	a1,0x2
ffffffe000201aac:	55858593          	addi	a1,a1,1368 # ffffffe000204000 <TIMECLOCK>
ffffffe000201ab0:	00002717          	auipc	a4,0x2
ffffffe000201ab4:	55070713          	addi	a4,a4,1360 # ffffffe000204000 <TIMECLOCK>
ffffffe000201ab8:	04100793          	li	a5,65
ffffffe000201abc:	01f79793          	slli	a5,a5,0x1f
ffffffe000201ac0:	00f707b3          	add	a5,a4,a5
ffffffe000201ac4:	00078613          	mv	a2,a5
                   (uint64_t)(PHY_END-((uint64_t)_sdata-PA2VA_OFFSET)),PTE_W|PTE_R|PTE_V);
ffffffe000201ac8:	00002797          	auipc	a5,0x2
ffffffe000201acc:	53878793          	addi	a5,a5,1336 # ffffffe000204000 <TIMECLOCK>
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201ad0:	c0100713          	li	a4,-1023
ffffffe000201ad4:	01b71713          	slli	a4,a4,0x1b
ffffffe000201ad8:	40f707b3          	sub	a5,a4,a5
ffffffe000201adc:	00700713          	li	a4,7
ffffffe000201ae0:	00078693          	mv	a3,a5
ffffffe000201ae4:	00006517          	auipc	a0,0x6
ffffffe000201ae8:	51c50513          	addi	a0,a0,1308 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201aec:	ccdff0ef          	jal	ra,ffffffe0002017b8 <create_mapping>
    printk("setup_vm_final: mapping other memory done!\n");
ffffffe000201af0:	00001517          	auipc	a0,0x1
ffffffe000201af4:	68850513          	addi	a0,a0,1672 # ffffffe000203178 <_srodata+0x178>
ffffffe000201af8:	010010ef          	jal	ra,ffffffe000202b08 <printk>

    // set satp with swapper_pg_dir
    uint64_t satp_val=0;
ffffffe000201afc:	fe043423          	sd	zero,-24(s0)
    satp_val|=(8ULL<<60);                          // MODE=8 Sv39
ffffffe000201b00:	fe843703          	ld	a4,-24(s0)
ffffffe000201b04:	fff00793          	li	a5,-1
ffffffe000201b08:	03f79793          	slli	a5,a5,0x3f
ffffffe000201b0c:	00f767b3          	or	a5,a4,a5
ffffffe000201b10:	fef43423          	sd	a5,-24(s0)
    satp_val|=(((uint64_t)swapper_pg_dir-PA2VA_OFFSET)>>12);   // PPN
ffffffe000201b14:	00006717          	auipc	a4,0x6
ffffffe000201b18:	4ec70713          	addi	a4,a4,1260 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201b1c:	04100793          	li	a5,65
ffffffe000201b20:	01f79793          	slli	a5,a5,0x1f
ffffffe000201b24:	00f707b3          	add	a5,a4,a5
ffffffe000201b28:	00c7d793          	srli	a5,a5,0xc
ffffffe000201b2c:	fe843703          	ld	a4,-24(s0)
ffffffe000201b30:	00f767b3          	or	a5,a4,a5
ffffffe000201b34:	fef43423          	sd	a5,-24(s0)
    csr_write(satp,satp_val);
ffffffe000201b38:	fe843783          	ld	a5,-24(s0)
ffffffe000201b3c:	fef43023          	sd	a5,-32(s0)
ffffffe000201b40:	fe043783          	ld	a5,-32(s0)
ffffffe000201b44:	18079073          	csrw	satp,a5

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201b48:	12000073          	sfence.vma
    return;
ffffffe000201b4c:	00000013          	nop
}
ffffffe000201b50:	01813083          	ld	ra,24(sp)
ffffffe000201b54:	01013403          	ld	s0,16(sp)
ffffffe000201b58:	02010113          	addi	sp,sp,32
ffffffe000201b5c:	00008067          	ret

ffffffe000201b60 <test_rw>:
extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];

void test_rw(){
ffffffe000201b60:	ff010113          	addi	sp,sp,-16
ffffffe000201b64:	00113423          	sd	ra,8(sp)
ffffffe000201b68:	00813023          	sd	s0,0(sp)
ffffffe000201b6c:	01010413          	addi	s0,sp,16
    printk("stext read:%lx\n",&_stext);
ffffffe000201b70:	ffffe597          	auipc	a1,0xffffe
ffffffe000201b74:	49058593          	addi	a1,a1,1168 # ffffffe000200000 <_skernel>
ffffffe000201b78:	00001517          	auipc	a0,0x1
ffffffe000201b7c:	63050513          	addi	a0,a0,1584 # ffffffe0002031a8 <_srodata+0x1a8>
ffffffe000201b80:	789000ef          	jal	ra,ffffffe000202b08 <printk>
    printk("srodata read:%lx\n",&_srodata);
ffffffe000201b84:	00001597          	auipc	a1,0x1
ffffffe000201b88:	47c58593          	addi	a1,a1,1148 # ffffffe000203000 <_srodata>
ffffffe000201b8c:	00001517          	auipc	a0,0x1
ffffffe000201b90:	62c50513          	addi	a0,a0,1580 # ffffffe0002031b8 <_srodata+0x1b8>
ffffffe000201b94:	775000ef          	jal	ra,ffffffe000202b08 <printk>
    // }
    // *_srodata=0x1;
    // if(*_srodata==0x1){
    //     printk("srodata write: success\n");
    // }
}
ffffffe000201b98:	00000013          	nop
ffffffe000201b9c:	00813083          	ld	ra,8(sp)
ffffffe000201ba0:	00013403          	ld	s0,0(sp)
ffffffe000201ba4:	01010113          	addi	sp,sp,16
ffffffe000201ba8:	00008067          	ret

ffffffe000201bac <test_exe>:

void test_exe(){
ffffffe000201bac:	fe010113          	addi	sp,sp,-32
ffffffe000201bb0:	00113c23          	sd	ra,24(sp)
ffffffe000201bb4:	00813823          	sd	s0,16(sp)
ffffffe000201bb8:	02010413          	addi	s0,sp,32
    typedef void (*func_ptr)(void);

    func_ptr func = (func_ptr)_srodata;
ffffffe000201bbc:	00001797          	auipc	a5,0x1
ffffffe000201bc0:	44478793          	addi	a5,a5,1092 # ffffffe000203000 <_srodata>
ffffffe000201bc4:	fef43423          	sd	a5,-24(s0)
    func();
ffffffe000201bc8:	fe843783          	ld	a5,-24(s0)
ffffffe000201bcc:	000780e7          	jalr	a5
    printk("execute stext success\n");
ffffffe000201bd0:	00001517          	auipc	a0,0x1
ffffffe000201bd4:	60050513          	addi	a0,a0,1536 # ffffffe0002031d0 <_srodata+0x1d0>
ffffffe000201bd8:	731000ef          	jal	ra,ffffffe000202b08 <printk>

}
ffffffe000201bdc:	00000013          	nop
ffffffe000201be0:	01813083          	ld	ra,24(sp)
ffffffe000201be4:	01013403          	ld	s0,16(sp)
ffffffe000201be8:	02010113          	addi	sp,sp,32
ffffffe000201bec:	00008067          	ret

ffffffe000201bf0 <start_kernel>:

int start_kernel() {
ffffffe000201bf0:	ff010113          	addi	sp,sp,-16
ffffffe000201bf4:	00113423          	sd	ra,8(sp)
ffffffe000201bf8:	00813023          	sd	s0,0(sp)
ffffffe000201bfc:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201c00:	00001517          	auipc	a0,0x1
ffffffe000201c04:	5e850513          	addi	a0,a0,1512 # ffffffe0002031e8 <_srodata+0x1e8>
ffffffe000201c08:	701000ef          	jal	ra,ffffffe000202b08 <printk>
    printk(" ZJU Operating System\n");
ffffffe000201c0c:	00001517          	auipc	a0,0x1
ffffffe000201c10:	5e450513          	addi	a0,a0,1508 # ffffffe0002031f0 <_srodata+0x1f0>
ffffffe000201c14:	6f5000ef          	jal	ra,ffffffe000202b08 <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
ffffffe000201c18:	01c000ef          	jal	ra,ffffffe000201c34 <test>
    return 0;
ffffffe000201c1c:	00000793          	li	a5,0
}
ffffffe000201c20:	00078513          	mv	a0,a5
ffffffe000201c24:	00813083          	ld	ra,8(sp)
ffffffe000201c28:	00013403          	ld	s0,0(sp)
ffffffe000201c2c:	01010113          	addi	sp,sp,16
ffffffe000201c30:	00008067          	ret

ffffffe000201c34 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
ffffffe000201c34:	fe010113          	addi	sp,sp,-32
ffffffe000201c38:	00113c23          	sd	ra,24(sp)
ffffffe000201c3c:	00813823          	sd	s0,16(sp)
ffffffe000201c40:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
ffffffe000201c44:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000201c48:	fec42783          	lw	a5,-20(s0)
ffffffe000201c4c:	0017879b          	addiw	a5,a5,1
ffffffe000201c50:	fef42623          	sw	a5,-20(s0)
ffffffe000201c54:	fec42703          	lw	a4,-20(s0)
ffffffe000201c58:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000201c5c:	1007879b          	addiw	a5,a5,256
ffffffe000201c60:	02f767bb          	remw	a5,a4,a5
ffffffe000201c64:	0007879b          	sext.w	a5,a5
ffffffe000201c68:	fe0790e3          	bnez	a5,ffffffe000201c48 <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
ffffffe000201c6c:	00001517          	auipc	a0,0x1
ffffffe000201c70:	59c50513          	addi	a0,a0,1436 # ffffffe000203208 <_srodata+0x208>
ffffffe000201c74:	695000ef          	jal	ra,ffffffe000202b08 <printk>
            i = 0;
ffffffe000201c78:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000201c7c:	fcdff06f          	j	ffffffe000201c48 <test+0x14>

ffffffe000201c80 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000201c80:	fe010113          	addi	sp,sp,-32
ffffffe000201c84:	00113c23          	sd	ra,24(sp)
ffffffe000201c88:	00813823          	sd	s0,16(sp)
ffffffe000201c8c:	02010413          	addi	s0,sp,32
ffffffe000201c90:	00050793          	mv	a5,a0
ffffffe000201c94:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000201c98:	fec42783          	lw	a5,-20(s0)
ffffffe000201c9c:	0ff7f793          	andi	a5,a5,255
ffffffe000201ca0:	00078513          	mv	a0,a5
ffffffe000201ca4:	86dff0ef          	jal	ra,ffffffe000201510 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201ca8:	fec42783          	lw	a5,-20(s0)
ffffffe000201cac:	0ff7f793          	andi	a5,a5,255
ffffffe000201cb0:	0007879b          	sext.w	a5,a5
}
ffffffe000201cb4:	00078513          	mv	a0,a5
ffffffe000201cb8:	01813083          	ld	ra,24(sp)
ffffffe000201cbc:	01013403          	ld	s0,16(sp)
ffffffe000201cc0:	02010113          	addi	sp,sp,32
ffffffe000201cc4:	00008067          	ret

ffffffe000201cc8 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201cc8:	fe010113          	addi	sp,sp,-32
ffffffe000201ccc:	00813c23          	sd	s0,24(sp)
ffffffe000201cd0:	02010413          	addi	s0,sp,32
ffffffe000201cd4:	00050793          	mv	a5,a0
ffffffe000201cd8:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201cdc:	fec42783          	lw	a5,-20(s0)
ffffffe000201ce0:	0007871b          	sext.w	a4,a5
ffffffe000201ce4:	02000793          	li	a5,32
ffffffe000201ce8:	02f70263          	beq	a4,a5,ffffffe000201d0c <isspace+0x44>
ffffffe000201cec:	fec42783          	lw	a5,-20(s0)
ffffffe000201cf0:	0007871b          	sext.w	a4,a5
ffffffe000201cf4:	00800793          	li	a5,8
ffffffe000201cf8:	00e7de63          	bge	a5,a4,ffffffe000201d14 <isspace+0x4c>
ffffffe000201cfc:	fec42783          	lw	a5,-20(s0)
ffffffe000201d00:	0007871b          	sext.w	a4,a5
ffffffe000201d04:	00d00793          	li	a5,13
ffffffe000201d08:	00e7c663          	blt	a5,a4,ffffffe000201d14 <isspace+0x4c>
ffffffe000201d0c:	00100793          	li	a5,1
ffffffe000201d10:	0080006f          	j	ffffffe000201d18 <isspace+0x50>
ffffffe000201d14:	00000793          	li	a5,0
}
ffffffe000201d18:	00078513          	mv	a0,a5
ffffffe000201d1c:	01813403          	ld	s0,24(sp)
ffffffe000201d20:	02010113          	addi	sp,sp,32
ffffffe000201d24:	00008067          	ret

ffffffe000201d28 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000201d28:	fb010113          	addi	sp,sp,-80
ffffffe000201d2c:	04113423          	sd	ra,72(sp)
ffffffe000201d30:	04813023          	sd	s0,64(sp)
ffffffe000201d34:	05010413          	addi	s0,sp,80
ffffffe000201d38:	fca43423          	sd	a0,-56(s0)
ffffffe000201d3c:	fcb43023          	sd	a1,-64(s0)
ffffffe000201d40:	00060793          	mv	a5,a2
ffffffe000201d44:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000201d48:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000201d4c:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000201d50:	fc843783          	ld	a5,-56(s0)
ffffffe000201d54:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000201d58:	0100006f          	j	ffffffe000201d68 <strtol+0x40>
        p++;
ffffffe000201d5c:	fd843783          	ld	a5,-40(s0)
ffffffe000201d60:	00178793          	addi	a5,a5,1 # 5f5e001 <OPENSBI_SIZE+0x5d5e001>
ffffffe000201d64:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000201d68:	fd843783          	ld	a5,-40(s0)
ffffffe000201d6c:	0007c783          	lbu	a5,0(a5)
ffffffe000201d70:	0007879b          	sext.w	a5,a5
ffffffe000201d74:	00078513          	mv	a0,a5
ffffffe000201d78:	f51ff0ef          	jal	ra,ffffffe000201cc8 <isspace>
ffffffe000201d7c:	00050793          	mv	a5,a0
ffffffe000201d80:	fc079ee3          	bnez	a5,ffffffe000201d5c <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000201d84:	fd843783          	ld	a5,-40(s0)
ffffffe000201d88:	0007c783          	lbu	a5,0(a5)
ffffffe000201d8c:	00078713          	mv	a4,a5
ffffffe000201d90:	02d00793          	li	a5,45
ffffffe000201d94:	00f71e63          	bne	a4,a5,ffffffe000201db0 <strtol+0x88>
        neg = true;
ffffffe000201d98:	00100793          	li	a5,1
ffffffe000201d9c:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000201da0:	fd843783          	ld	a5,-40(s0)
ffffffe000201da4:	00178793          	addi	a5,a5,1
ffffffe000201da8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201dac:	0240006f          	j	ffffffe000201dd0 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000201db0:	fd843783          	ld	a5,-40(s0)
ffffffe000201db4:	0007c783          	lbu	a5,0(a5)
ffffffe000201db8:	00078713          	mv	a4,a5
ffffffe000201dbc:	02b00793          	li	a5,43
ffffffe000201dc0:	00f71863          	bne	a4,a5,ffffffe000201dd0 <strtol+0xa8>
        p++;
ffffffe000201dc4:	fd843783          	ld	a5,-40(s0)
ffffffe000201dc8:	00178793          	addi	a5,a5,1
ffffffe000201dcc:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201dd0:	fbc42783          	lw	a5,-68(s0)
ffffffe000201dd4:	0007879b          	sext.w	a5,a5
ffffffe000201dd8:	06079c63          	bnez	a5,ffffffe000201e50 <strtol+0x128>
        if (*p == '0') {
ffffffe000201ddc:	fd843783          	ld	a5,-40(s0)
ffffffe000201de0:	0007c783          	lbu	a5,0(a5)
ffffffe000201de4:	00078713          	mv	a4,a5
ffffffe000201de8:	03000793          	li	a5,48
ffffffe000201dec:	04f71e63          	bne	a4,a5,ffffffe000201e48 <strtol+0x120>
            p++;
ffffffe000201df0:	fd843783          	ld	a5,-40(s0)
ffffffe000201df4:	00178793          	addi	a5,a5,1
ffffffe000201df8:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201dfc:	fd843783          	ld	a5,-40(s0)
ffffffe000201e00:	0007c783          	lbu	a5,0(a5)
ffffffe000201e04:	00078713          	mv	a4,a5
ffffffe000201e08:	07800793          	li	a5,120
ffffffe000201e0c:	00f70c63          	beq	a4,a5,ffffffe000201e24 <strtol+0xfc>
ffffffe000201e10:	fd843783          	ld	a5,-40(s0)
ffffffe000201e14:	0007c783          	lbu	a5,0(a5)
ffffffe000201e18:	00078713          	mv	a4,a5
ffffffe000201e1c:	05800793          	li	a5,88
ffffffe000201e20:	00f71e63          	bne	a4,a5,ffffffe000201e3c <strtol+0x114>
                base = 16;
ffffffe000201e24:	01000793          	li	a5,16
ffffffe000201e28:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000201e2c:	fd843783          	ld	a5,-40(s0)
ffffffe000201e30:	00178793          	addi	a5,a5,1
ffffffe000201e34:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201e38:	0180006f          	j	ffffffe000201e50 <strtol+0x128>
            } else {
                base = 8;
ffffffe000201e3c:	00800793          	li	a5,8
ffffffe000201e40:	faf42e23          	sw	a5,-68(s0)
ffffffe000201e44:	00c0006f          	j	ffffffe000201e50 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000201e48:	00a00793          	li	a5,10
ffffffe000201e4c:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000201e50:	fd843783          	ld	a5,-40(s0)
ffffffe000201e54:	0007c783          	lbu	a5,0(a5)
ffffffe000201e58:	00078713          	mv	a4,a5
ffffffe000201e5c:	02f00793          	li	a5,47
ffffffe000201e60:	02e7f863          	bgeu	a5,a4,ffffffe000201e90 <strtol+0x168>
ffffffe000201e64:	fd843783          	ld	a5,-40(s0)
ffffffe000201e68:	0007c783          	lbu	a5,0(a5)
ffffffe000201e6c:	00078713          	mv	a4,a5
ffffffe000201e70:	03900793          	li	a5,57
ffffffe000201e74:	00e7ee63          	bltu	a5,a4,ffffffe000201e90 <strtol+0x168>
            digit = *p - '0';
ffffffe000201e78:	fd843783          	ld	a5,-40(s0)
ffffffe000201e7c:	0007c783          	lbu	a5,0(a5)
ffffffe000201e80:	0007879b          	sext.w	a5,a5
ffffffe000201e84:	fd07879b          	addiw	a5,a5,-48
ffffffe000201e88:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201e8c:	0800006f          	j	ffffffe000201f0c <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000201e90:	fd843783          	ld	a5,-40(s0)
ffffffe000201e94:	0007c783          	lbu	a5,0(a5)
ffffffe000201e98:	00078713          	mv	a4,a5
ffffffe000201e9c:	06000793          	li	a5,96
ffffffe000201ea0:	02e7f863          	bgeu	a5,a4,ffffffe000201ed0 <strtol+0x1a8>
ffffffe000201ea4:	fd843783          	ld	a5,-40(s0)
ffffffe000201ea8:	0007c783          	lbu	a5,0(a5)
ffffffe000201eac:	00078713          	mv	a4,a5
ffffffe000201eb0:	07a00793          	li	a5,122
ffffffe000201eb4:	00e7ee63          	bltu	a5,a4,ffffffe000201ed0 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000201eb8:	fd843783          	ld	a5,-40(s0)
ffffffe000201ebc:	0007c783          	lbu	a5,0(a5)
ffffffe000201ec0:	0007879b          	sext.w	a5,a5
ffffffe000201ec4:	fa97879b          	addiw	a5,a5,-87
ffffffe000201ec8:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201ecc:	0400006f          	j	ffffffe000201f0c <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201ed0:	fd843783          	ld	a5,-40(s0)
ffffffe000201ed4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ed8:	00078713          	mv	a4,a5
ffffffe000201edc:	04000793          	li	a5,64
ffffffe000201ee0:	06e7f663          	bgeu	a5,a4,ffffffe000201f4c <strtol+0x224>
ffffffe000201ee4:	fd843783          	ld	a5,-40(s0)
ffffffe000201ee8:	0007c783          	lbu	a5,0(a5)
ffffffe000201eec:	00078713          	mv	a4,a5
ffffffe000201ef0:	05a00793          	li	a5,90
ffffffe000201ef4:	04e7ec63          	bltu	a5,a4,ffffffe000201f4c <strtol+0x224>
            digit = *p - ('A' - 10);
ffffffe000201ef8:	fd843783          	ld	a5,-40(s0)
ffffffe000201efc:	0007c783          	lbu	a5,0(a5)
ffffffe000201f00:	0007879b          	sext.w	a5,a5
ffffffe000201f04:	fc97879b          	addiw	a5,a5,-55
ffffffe000201f08:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201f0c:	fd442703          	lw	a4,-44(s0)
ffffffe000201f10:	fbc42783          	lw	a5,-68(s0)
ffffffe000201f14:	0007071b          	sext.w	a4,a4
ffffffe000201f18:	0007879b          	sext.w	a5,a5
ffffffe000201f1c:	02f75663          	bge	a4,a5,ffffffe000201f48 <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
ffffffe000201f20:	fbc42703          	lw	a4,-68(s0)
ffffffe000201f24:	fe843783          	ld	a5,-24(s0)
ffffffe000201f28:	02f70733          	mul	a4,a4,a5
ffffffe000201f2c:	fd442783          	lw	a5,-44(s0)
ffffffe000201f30:	00f707b3          	add	a5,a4,a5
ffffffe000201f34:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000201f38:	fd843783          	ld	a5,-40(s0)
ffffffe000201f3c:	00178793          	addi	a5,a5,1
ffffffe000201f40:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000201f44:	f0dff06f          	j	ffffffe000201e50 <strtol+0x128>
            break;
ffffffe000201f48:	00000013          	nop
    }

    if (endptr) {
ffffffe000201f4c:	fc043783          	ld	a5,-64(s0)
ffffffe000201f50:	00078863          	beqz	a5,ffffffe000201f60 <strtol+0x238>
        *endptr = (char *)p;
ffffffe000201f54:	fc043783          	ld	a5,-64(s0)
ffffffe000201f58:	fd843703          	ld	a4,-40(s0)
ffffffe000201f5c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000201f60:	fe744783          	lbu	a5,-25(s0)
ffffffe000201f64:	0ff7f793          	andi	a5,a5,255
ffffffe000201f68:	00078863          	beqz	a5,ffffffe000201f78 <strtol+0x250>
ffffffe000201f6c:	fe843783          	ld	a5,-24(s0)
ffffffe000201f70:	40f007b3          	neg	a5,a5
ffffffe000201f74:	0080006f          	j	ffffffe000201f7c <strtol+0x254>
ffffffe000201f78:	fe843783          	ld	a5,-24(s0)
}
ffffffe000201f7c:	00078513          	mv	a0,a5
ffffffe000201f80:	04813083          	ld	ra,72(sp)
ffffffe000201f84:	04013403          	ld	s0,64(sp)
ffffffe000201f88:	05010113          	addi	sp,sp,80
ffffffe000201f8c:	00008067          	ret

ffffffe000201f90 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000201f90:	fd010113          	addi	sp,sp,-48
ffffffe000201f94:	02113423          	sd	ra,40(sp)
ffffffe000201f98:	02813023          	sd	s0,32(sp)
ffffffe000201f9c:	03010413          	addi	s0,sp,48
ffffffe000201fa0:	fca43c23          	sd	a0,-40(s0)
ffffffe000201fa4:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000201fa8:	fd043783          	ld	a5,-48(s0)
ffffffe000201fac:	00079863          	bnez	a5,ffffffe000201fbc <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000201fb0:	00001797          	auipc	a5,0x1
ffffffe000201fb4:	27078793          	addi	a5,a5,624 # ffffffe000203220 <_srodata+0x220>
ffffffe000201fb8:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000201fbc:	fd043783          	ld	a5,-48(s0)
ffffffe000201fc0:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201fc4:	0240006f          	j	ffffffe000201fe8 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000201fc8:	fe843783          	ld	a5,-24(s0)
ffffffe000201fcc:	00178713          	addi	a4,a5,1
ffffffe000201fd0:	fee43423          	sd	a4,-24(s0)
ffffffe000201fd4:	0007c783          	lbu	a5,0(a5)
ffffffe000201fd8:	0007879b          	sext.w	a5,a5
ffffffe000201fdc:	fd843703          	ld	a4,-40(s0)
ffffffe000201fe0:	00078513          	mv	a0,a5
ffffffe000201fe4:	000700e7          	jalr	a4
    while (*p) {
ffffffe000201fe8:	fe843783          	ld	a5,-24(s0)
ffffffe000201fec:	0007c783          	lbu	a5,0(a5)
ffffffe000201ff0:	fc079ce3          	bnez	a5,ffffffe000201fc8 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201ff4:	fe843703          	ld	a4,-24(s0)
ffffffe000201ff8:	fd043783          	ld	a5,-48(s0)
ffffffe000201ffc:	40f707b3          	sub	a5,a4,a5
ffffffe000202000:	0007879b          	sext.w	a5,a5
}
ffffffe000202004:	00078513          	mv	a0,a5
ffffffe000202008:	02813083          	ld	ra,40(sp)
ffffffe00020200c:	02013403          	ld	s0,32(sp)
ffffffe000202010:	03010113          	addi	sp,sp,48
ffffffe000202014:	00008067          	ret

ffffffe000202018 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202018:	f9010113          	addi	sp,sp,-112
ffffffe00020201c:	06113423          	sd	ra,104(sp)
ffffffe000202020:	06813023          	sd	s0,96(sp)
ffffffe000202024:	07010413          	addi	s0,sp,112
ffffffe000202028:	faa43423          	sd	a0,-88(s0)
ffffffe00020202c:	fab43023          	sd	a1,-96(s0)
ffffffe000202030:	00060793          	mv	a5,a2
ffffffe000202034:	f8d43823          	sd	a3,-112(s0)
ffffffe000202038:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe00020203c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202040:	0ff7f793          	andi	a5,a5,255
ffffffe000202044:	02078663          	beqz	a5,ffffffe000202070 <print_dec_int+0x58>
ffffffe000202048:	fa043703          	ld	a4,-96(s0)
ffffffe00020204c:	fff00793          	li	a5,-1
ffffffe000202050:	03f79793          	slli	a5,a5,0x3f
ffffffe000202054:	00f71e63          	bne	a4,a5,ffffffe000202070 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202058:	00001597          	auipc	a1,0x1
ffffffe00020205c:	1d058593          	addi	a1,a1,464 # ffffffe000203228 <_srodata+0x228>
ffffffe000202060:	fa843503          	ld	a0,-88(s0)
ffffffe000202064:	f2dff0ef          	jal	ra,ffffffe000201f90 <puts_wo_nl>
ffffffe000202068:	00050793          	mv	a5,a0
ffffffe00020206c:	2980006f          	j	ffffffe000202304 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202070:	f9043783          	ld	a5,-112(s0)
ffffffe000202074:	00c7a783          	lw	a5,12(a5)
ffffffe000202078:	00079a63          	bnez	a5,ffffffe00020208c <print_dec_int+0x74>
ffffffe00020207c:	fa043783          	ld	a5,-96(s0)
ffffffe000202080:	00079663          	bnez	a5,ffffffe00020208c <print_dec_int+0x74>
        return 0;
ffffffe000202084:	00000793          	li	a5,0
ffffffe000202088:	27c0006f          	j	ffffffe000202304 <print_dec_int+0x2ec>
    }

    bool neg = false;
ffffffe00020208c:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000202090:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202094:	0ff7f793          	andi	a5,a5,255
ffffffe000202098:	02078063          	beqz	a5,ffffffe0002020b8 <print_dec_int+0xa0>
ffffffe00020209c:	fa043783          	ld	a5,-96(s0)
ffffffe0002020a0:	0007dc63          	bgez	a5,ffffffe0002020b8 <print_dec_int+0xa0>
        neg = true;
ffffffe0002020a4:	00100793          	li	a5,1
ffffffe0002020a8:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe0002020ac:	fa043783          	ld	a5,-96(s0)
ffffffe0002020b0:	40f007b3          	neg	a5,a5
ffffffe0002020b4:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe0002020b8:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe0002020bc:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002020c0:	0ff7f793          	andi	a5,a5,255
ffffffe0002020c4:	02078863          	beqz	a5,ffffffe0002020f4 <print_dec_int+0xdc>
ffffffe0002020c8:	fef44783          	lbu	a5,-17(s0)
ffffffe0002020cc:	0ff7f793          	andi	a5,a5,255
ffffffe0002020d0:	00079e63          	bnez	a5,ffffffe0002020ec <print_dec_int+0xd4>
ffffffe0002020d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002020d8:	0057c783          	lbu	a5,5(a5)
ffffffe0002020dc:	00079863          	bnez	a5,ffffffe0002020ec <print_dec_int+0xd4>
ffffffe0002020e0:	f9043783          	ld	a5,-112(s0)
ffffffe0002020e4:	0047c783          	lbu	a5,4(a5)
ffffffe0002020e8:	00078663          	beqz	a5,ffffffe0002020f4 <print_dec_int+0xdc>
ffffffe0002020ec:	00100793          	li	a5,1
ffffffe0002020f0:	0080006f          	j	ffffffe0002020f8 <print_dec_int+0xe0>
ffffffe0002020f4:	00000793          	li	a5,0
ffffffe0002020f8:	fcf40ba3          	sb	a5,-41(s0)
ffffffe0002020fc:	fd744783          	lbu	a5,-41(s0)
ffffffe000202100:	0017f793          	andi	a5,a5,1
ffffffe000202104:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000202108:	fa043703          	ld	a4,-96(s0)
ffffffe00020210c:	00a00793          	li	a5,10
ffffffe000202110:	02f777b3          	remu	a5,a4,a5
ffffffe000202114:	0ff7f713          	andi	a4,a5,255
ffffffe000202118:	fe842783          	lw	a5,-24(s0)
ffffffe00020211c:	0017869b          	addiw	a3,a5,1
ffffffe000202120:	fed42423          	sw	a3,-24(s0)
ffffffe000202124:	0307071b          	addiw	a4,a4,48
ffffffe000202128:	0ff77713          	andi	a4,a4,255
ffffffe00020212c:	ff040693          	addi	a3,s0,-16
ffffffe000202130:	00f687b3          	add	a5,a3,a5
ffffffe000202134:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000202138:	fa043703          	ld	a4,-96(s0)
ffffffe00020213c:	00a00793          	li	a5,10
ffffffe000202140:	02f757b3          	divu	a5,a4,a5
ffffffe000202144:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000202148:	fa043783          	ld	a5,-96(s0)
ffffffe00020214c:	fa079ee3          	bnez	a5,ffffffe000202108 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000202150:	f9043783          	ld	a5,-112(s0)
ffffffe000202154:	00c7a783          	lw	a5,12(a5)
ffffffe000202158:	00078713          	mv	a4,a5
ffffffe00020215c:	fff00793          	li	a5,-1
ffffffe000202160:	02f71063          	bne	a4,a5,ffffffe000202180 <print_dec_int+0x168>
ffffffe000202164:	f9043783          	ld	a5,-112(s0)
ffffffe000202168:	0037c783          	lbu	a5,3(a5)
ffffffe00020216c:	00078a63          	beqz	a5,ffffffe000202180 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000202170:	f9043783          	ld	a5,-112(s0)
ffffffe000202174:	0087a703          	lw	a4,8(a5)
ffffffe000202178:	f9043783          	ld	a5,-112(s0)
ffffffe00020217c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000202180:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000202184:	f9043783          	ld	a5,-112(s0)
ffffffe000202188:	0087a703          	lw	a4,8(a5)
ffffffe00020218c:	fe842783          	lw	a5,-24(s0)
ffffffe000202190:	fcf42823          	sw	a5,-48(s0)
ffffffe000202194:	f9043783          	ld	a5,-112(s0)
ffffffe000202198:	00c7a783          	lw	a5,12(a5)
ffffffe00020219c:	fcf42623          	sw	a5,-52(s0)
ffffffe0002021a0:	fd042583          	lw	a1,-48(s0)
ffffffe0002021a4:	fcc42783          	lw	a5,-52(s0)
ffffffe0002021a8:	0007861b          	sext.w	a2,a5
ffffffe0002021ac:	0005869b          	sext.w	a3,a1
ffffffe0002021b0:	00d65463          	bge	a2,a3,ffffffe0002021b8 <print_dec_int+0x1a0>
ffffffe0002021b4:	00058793          	mv	a5,a1
ffffffe0002021b8:	0007879b          	sext.w	a5,a5
ffffffe0002021bc:	40f707bb          	subw	a5,a4,a5
ffffffe0002021c0:	0007871b          	sext.w	a4,a5
ffffffe0002021c4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002021c8:	0007879b          	sext.w	a5,a5
ffffffe0002021cc:	40f707bb          	subw	a5,a4,a5
ffffffe0002021d0:	fef42023          	sw	a5,-32(s0)
ffffffe0002021d4:	0280006f          	j	ffffffe0002021fc <print_dec_int+0x1e4>
        putch(' ');
ffffffe0002021d8:	fa843783          	ld	a5,-88(s0)
ffffffe0002021dc:	02000513          	li	a0,32
ffffffe0002021e0:	000780e7          	jalr	a5
        ++written;
ffffffe0002021e4:	fe442783          	lw	a5,-28(s0)
ffffffe0002021e8:	0017879b          	addiw	a5,a5,1
ffffffe0002021ec:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002021f0:	fe042783          	lw	a5,-32(s0)
ffffffe0002021f4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002021f8:	fef42023          	sw	a5,-32(s0)
ffffffe0002021fc:	fe042783          	lw	a5,-32(s0)
ffffffe000202200:	0007879b          	sext.w	a5,a5
ffffffe000202204:	fcf04ae3          	bgtz	a5,ffffffe0002021d8 <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
ffffffe000202208:	fd744783          	lbu	a5,-41(s0)
ffffffe00020220c:	0ff7f793          	andi	a5,a5,255
ffffffe000202210:	04078463          	beqz	a5,ffffffe000202258 <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000202214:	fef44783          	lbu	a5,-17(s0)
ffffffe000202218:	0ff7f793          	andi	a5,a5,255
ffffffe00020221c:	00078663          	beqz	a5,ffffffe000202228 <print_dec_int+0x210>
ffffffe000202220:	02d00793          	li	a5,45
ffffffe000202224:	01c0006f          	j	ffffffe000202240 <print_dec_int+0x228>
ffffffe000202228:	f9043783          	ld	a5,-112(s0)
ffffffe00020222c:	0057c783          	lbu	a5,5(a5)
ffffffe000202230:	00078663          	beqz	a5,ffffffe00020223c <print_dec_int+0x224>
ffffffe000202234:	02b00793          	li	a5,43
ffffffe000202238:	0080006f          	j	ffffffe000202240 <print_dec_int+0x228>
ffffffe00020223c:	02000793          	li	a5,32
ffffffe000202240:	fa843703          	ld	a4,-88(s0)
ffffffe000202244:	00078513          	mv	a0,a5
ffffffe000202248:	000700e7          	jalr	a4
        ++written;
ffffffe00020224c:	fe442783          	lw	a5,-28(s0)
ffffffe000202250:	0017879b          	addiw	a5,a5,1
ffffffe000202254:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202258:	fe842783          	lw	a5,-24(s0)
ffffffe00020225c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202260:	0280006f          	j	ffffffe000202288 <print_dec_int+0x270>
        putch('0');
ffffffe000202264:	fa843783          	ld	a5,-88(s0)
ffffffe000202268:	03000513          	li	a0,48
ffffffe00020226c:	000780e7          	jalr	a5
        ++written;
ffffffe000202270:	fe442783          	lw	a5,-28(s0)
ffffffe000202274:	0017879b          	addiw	a5,a5,1
ffffffe000202278:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe00020227c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202280:	0017879b          	addiw	a5,a5,1
ffffffe000202284:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202288:	f9043783          	ld	a5,-112(s0)
ffffffe00020228c:	00c7a703          	lw	a4,12(a5)
ffffffe000202290:	fd744783          	lbu	a5,-41(s0)
ffffffe000202294:	0007879b          	sext.w	a5,a5
ffffffe000202298:	40f707bb          	subw	a5,a4,a5
ffffffe00020229c:	0007871b          	sext.w	a4,a5
ffffffe0002022a0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002022a4:	0007879b          	sext.w	a5,a5
ffffffe0002022a8:	fae7cee3          	blt	a5,a4,ffffffe000202264 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002022ac:	fe842783          	lw	a5,-24(s0)
ffffffe0002022b0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002022b4:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002022b8:	03c0006f          	j	ffffffe0002022f4 <print_dec_int+0x2dc>
        putch(buf[i]);
ffffffe0002022bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002022c0:	ff040713          	addi	a4,s0,-16
ffffffe0002022c4:	00f707b3          	add	a5,a4,a5
ffffffe0002022c8:	fc87c783          	lbu	a5,-56(a5)
ffffffe0002022cc:	0007879b          	sext.w	a5,a5
ffffffe0002022d0:	fa843703          	ld	a4,-88(s0)
ffffffe0002022d4:	00078513          	mv	a0,a5
ffffffe0002022d8:	000700e7          	jalr	a4
        ++written;
ffffffe0002022dc:	fe442783          	lw	a5,-28(s0)
ffffffe0002022e0:	0017879b          	addiw	a5,a5,1
ffffffe0002022e4:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002022e8:	fd842783          	lw	a5,-40(s0)
ffffffe0002022ec:	fff7879b          	addiw	a5,a5,-1
ffffffe0002022f0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002022f4:	fd842783          	lw	a5,-40(s0)
ffffffe0002022f8:	0007879b          	sext.w	a5,a5
ffffffe0002022fc:	fc07d0e3          	bgez	a5,ffffffe0002022bc <print_dec_int+0x2a4>
    }

    return written;
ffffffe000202300:	fe442783          	lw	a5,-28(s0)
}
ffffffe000202304:	00078513          	mv	a0,a5
ffffffe000202308:	06813083          	ld	ra,104(sp)
ffffffe00020230c:	06013403          	ld	s0,96(sp)
ffffffe000202310:	07010113          	addi	sp,sp,112
ffffffe000202314:	00008067          	ret

ffffffe000202318 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000202318:	f4010113          	addi	sp,sp,-192
ffffffe00020231c:	0a113c23          	sd	ra,184(sp)
ffffffe000202320:	0a813823          	sd	s0,176(sp)
ffffffe000202324:	0c010413          	addi	s0,sp,192
ffffffe000202328:	f4a43c23          	sd	a0,-168(s0)
ffffffe00020232c:	f4b43823          	sd	a1,-176(s0)
ffffffe000202330:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000202334:	f8043023          	sd	zero,-128(s0)
ffffffe000202338:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe00020233c:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000202340:	7a40006f          	j	ffffffe000202ae4 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000202344:	f8044783          	lbu	a5,-128(s0)
ffffffe000202348:	72078e63          	beqz	a5,ffffffe000202a84 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe00020234c:	f5043783          	ld	a5,-176(s0)
ffffffe000202350:	0007c783          	lbu	a5,0(a5)
ffffffe000202354:	00078713          	mv	a4,a5
ffffffe000202358:	02300793          	li	a5,35
ffffffe00020235c:	00f71863          	bne	a4,a5,ffffffe00020236c <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000202360:	00100793          	li	a5,1
ffffffe000202364:	f8f40123          	sb	a5,-126(s0)
ffffffe000202368:	7700006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe00020236c:	f5043783          	ld	a5,-176(s0)
ffffffe000202370:	0007c783          	lbu	a5,0(a5)
ffffffe000202374:	00078713          	mv	a4,a5
ffffffe000202378:	03000793          	li	a5,48
ffffffe00020237c:	00f71863          	bne	a4,a5,ffffffe00020238c <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000202380:	00100793          	li	a5,1
ffffffe000202384:	f8f401a3          	sb	a5,-125(s0)
ffffffe000202388:	7500006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe00020238c:	f5043783          	ld	a5,-176(s0)
ffffffe000202390:	0007c783          	lbu	a5,0(a5)
ffffffe000202394:	00078713          	mv	a4,a5
ffffffe000202398:	06c00793          	li	a5,108
ffffffe00020239c:	04f70063          	beq	a4,a5,ffffffe0002023dc <vprintfmt+0xc4>
ffffffe0002023a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002023a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002023a8:	00078713          	mv	a4,a5
ffffffe0002023ac:	07a00793          	li	a5,122
ffffffe0002023b0:	02f70663          	beq	a4,a5,ffffffe0002023dc <vprintfmt+0xc4>
ffffffe0002023b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002023b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002023bc:	00078713          	mv	a4,a5
ffffffe0002023c0:	07400793          	li	a5,116
ffffffe0002023c4:	00f70c63          	beq	a4,a5,ffffffe0002023dc <vprintfmt+0xc4>
ffffffe0002023c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002023cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002023d0:	00078713          	mv	a4,a5
ffffffe0002023d4:	06a00793          	li	a5,106
ffffffe0002023d8:	00f71863          	bne	a4,a5,ffffffe0002023e8 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe0002023dc:	00100793          	li	a5,1
ffffffe0002023e0:	f8f400a3          	sb	a5,-127(s0)
ffffffe0002023e4:	6f40006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe0002023e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002023ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002023f0:	00078713          	mv	a4,a5
ffffffe0002023f4:	02b00793          	li	a5,43
ffffffe0002023f8:	00f71863          	bne	a4,a5,ffffffe000202408 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe0002023fc:	00100793          	li	a5,1
ffffffe000202400:	f8f402a3          	sb	a5,-123(s0)
ffffffe000202404:	6d40006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000202408:	f5043783          	ld	a5,-176(s0)
ffffffe00020240c:	0007c783          	lbu	a5,0(a5)
ffffffe000202410:	00078713          	mv	a4,a5
ffffffe000202414:	02000793          	li	a5,32
ffffffe000202418:	00f71863          	bne	a4,a5,ffffffe000202428 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe00020241c:	00100793          	li	a5,1
ffffffe000202420:	f8f40223          	sb	a5,-124(s0)
ffffffe000202424:	6b40006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000202428:	f5043783          	ld	a5,-176(s0)
ffffffe00020242c:	0007c783          	lbu	a5,0(a5)
ffffffe000202430:	00078713          	mv	a4,a5
ffffffe000202434:	02a00793          	li	a5,42
ffffffe000202438:	00f71e63          	bne	a4,a5,ffffffe000202454 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe00020243c:	f4843783          	ld	a5,-184(s0)
ffffffe000202440:	00878713          	addi	a4,a5,8
ffffffe000202444:	f4e43423          	sd	a4,-184(s0)
ffffffe000202448:	0007a783          	lw	a5,0(a5)
ffffffe00020244c:	f8f42423          	sw	a5,-120(s0)
ffffffe000202450:	6880006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000202454:	f5043783          	ld	a5,-176(s0)
ffffffe000202458:	0007c783          	lbu	a5,0(a5)
ffffffe00020245c:	00078713          	mv	a4,a5
ffffffe000202460:	03000793          	li	a5,48
ffffffe000202464:	04e7f663          	bgeu	a5,a4,ffffffe0002024b0 <vprintfmt+0x198>
ffffffe000202468:	f5043783          	ld	a5,-176(s0)
ffffffe00020246c:	0007c783          	lbu	a5,0(a5)
ffffffe000202470:	00078713          	mv	a4,a5
ffffffe000202474:	03900793          	li	a5,57
ffffffe000202478:	02e7ec63          	bltu	a5,a4,ffffffe0002024b0 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe00020247c:	f5043783          	ld	a5,-176(s0)
ffffffe000202480:	f5040713          	addi	a4,s0,-176
ffffffe000202484:	00a00613          	li	a2,10
ffffffe000202488:	00070593          	mv	a1,a4
ffffffe00020248c:	00078513          	mv	a0,a5
ffffffe000202490:	899ff0ef          	jal	ra,ffffffe000201d28 <strtol>
ffffffe000202494:	00050793          	mv	a5,a0
ffffffe000202498:	0007879b          	sext.w	a5,a5
ffffffe00020249c:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe0002024a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002024a4:	fff78793          	addi	a5,a5,-1
ffffffe0002024a8:	f4f43823          	sd	a5,-176(s0)
ffffffe0002024ac:	62c0006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe0002024b0:	f5043783          	ld	a5,-176(s0)
ffffffe0002024b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002024b8:	00078713          	mv	a4,a5
ffffffe0002024bc:	02e00793          	li	a5,46
ffffffe0002024c0:	06f71863          	bne	a4,a5,ffffffe000202530 <vprintfmt+0x218>
                fmt++;
ffffffe0002024c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002024c8:	00178793          	addi	a5,a5,1
ffffffe0002024cc:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe0002024d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002024d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002024d8:	00078713          	mv	a4,a5
ffffffe0002024dc:	02a00793          	li	a5,42
ffffffe0002024e0:	00f71e63          	bne	a4,a5,ffffffe0002024fc <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe0002024e4:	f4843783          	ld	a5,-184(s0)
ffffffe0002024e8:	00878713          	addi	a4,a5,8
ffffffe0002024ec:	f4e43423          	sd	a4,-184(s0)
ffffffe0002024f0:	0007a783          	lw	a5,0(a5)
ffffffe0002024f4:	f8f42623          	sw	a5,-116(s0)
ffffffe0002024f8:	5e00006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe0002024fc:	f5043783          	ld	a5,-176(s0)
ffffffe000202500:	f5040713          	addi	a4,s0,-176
ffffffe000202504:	00a00613          	li	a2,10
ffffffe000202508:	00070593          	mv	a1,a4
ffffffe00020250c:	00078513          	mv	a0,a5
ffffffe000202510:	819ff0ef          	jal	ra,ffffffe000201d28 <strtol>
ffffffe000202514:	00050793          	mv	a5,a0
ffffffe000202518:	0007879b          	sext.w	a5,a5
ffffffe00020251c:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000202520:	f5043783          	ld	a5,-176(s0)
ffffffe000202524:	fff78793          	addi	a5,a5,-1
ffffffe000202528:	f4f43823          	sd	a5,-176(s0)
ffffffe00020252c:	5ac0006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202530:	f5043783          	ld	a5,-176(s0)
ffffffe000202534:	0007c783          	lbu	a5,0(a5)
ffffffe000202538:	00078713          	mv	a4,a5
ffffffe00020253c:	07800793          	li	a5,120
ffffffe000202540:	02f70663          	beq	a4,a5,ffffffe00020256c <vprintfmt+0x254>
ffffffe000202544:	f5043783          	ld	a5,-176(s0)
ffffffe000202548:	0007c783          	lbu	a5,0(a5)
ffffffe00020254c:	00078713          	mv	a4,a5
ffffffe000202550:	05800793          	li	a5,88
ffffffe000202554:	00f70c63          	beq	a4,a5,ffffffe00020256c <vprintfmt+0x254>
ffffffe000202558:	f5043783          	ld	a5,-176(s0)
ffffffe00020255c:	0007c783          	lbu	a5,0(a5)
ffffffe000202560:	00078713          	mv	a4,a5
ffffffe000202564:	07000793          	li	a5,112
ffffffe000202568:	2ef71e63          	bne	a4,a5,ffffffe000202864 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe00020256c:	f5043783          	ld	a5,-176(s0)
ffffffe000202570:	0007c783          	lbu	a5,0(a5)
ffffffe000202574:	00078713          	mv	a4,a5
ffffffe000202578:	07000793          	li	a5,112
ffffffe00020257c:	00f70663          	beq	a4,a5,ffffffe000202588 <vprintfmt+0x270>
ffffffe000202580:	f8144783          	lbu	a5,-127(s0)
ffffffe000202584:	00078663          	beqz	a5,ffffffe000202590 <vprintfmt+0x278>
ffffffe000202588:	00100793          	li	a5,1
ffffffe00020258c:	0080006f          	j	ffffffe000202594 <vprintfmt+0x27c>
ffffffe000202590:	00000793          	li	a5,0
ffffffe000202594:	faf403a3          	sb	a5,-89(s0)
ffffffe000202598:	fa744783          	lbu	a5,-89(s0)
ffffffe00020259c:	0017f793          	andi	a5,a5,1
ffffffe0002025a0:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe0002025a4:	fa744783          	lbu	a5,-89(s0)
ffffffe0002025a8:	0ff7f793          	andi	a5,a5,255
ffffffe0002025ac:	00078c63          	beqz	a5,ffffffe0002025c4 <vprintfmt+0x2ac>
ffffffe0002025b0:	f4843783          	ld	a5,-184(s0)
ffffffe0002025b4:	00878713          	addi	a4,a5,8
ffffffe0002025b8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002025bc:	0007b783          	ld	a5,0(a5)
ffffffe0002025c0:	01c0006f          	j	ffffffe0002025dc <vprintfmt+0x2c4>
ffffffe0002025c4:	f4843783          	ld	a5,-184(s0)
ffffffe0002025c8:	00878713          	addi	a4,a5,8
ffffffe0002025cc:	f4e43423          	sd	a4,-184(s0)
ffffffe0002025d0:	0007a783          	lw	a5,0(a5)
ffffffe0002025d4:	02079793          	slli	a5,a5,0x20
ffffffe0002025d8:	0207d793          	srli	a5,a5,0x20
ffffffe0002025dc:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe0002025e0:	f8c42783          	lw	a5,-116(s0)
ffffffe0002025e4:	02079463          	bnez	a5,ffffffe00020260c <vprintfmt+0x2f4>
ffffffe0002025e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002025ec:	02079063          	bnez	a5,ffffffe00020260c <vprintfmt+0x2f4>
ffffffe0002025f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002025f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002025f8:	00078713          	mv	a4,a5
ffffffe0002025fc:	07000793          	li	a5,112
ffffffe000202600:	00f70663          	beq	a4,a5,ffffffe00020260c <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000202604:	f8040023          	sb	zero,-128(s0)
ffffffe000202608:	4d00006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe00020260c:	f5043783          	ld	a5,-176(s0)
ffffffe000202610:	0007c783          	lbu	a5,0(a5)
ffffffe000202614:	00078713          	mv	a4,a5
ffffffe000202618:	07000793          	li	a5,112
ffffffe00020261c:	00f70a63          	beq	a4,a5,ffffffe000202630 <vprintfmt+0x318>
ffffffe000202620:	f8244783          	lbu	a5,-126(s0)
ffffffe000202624:	00078a63          	beqz	a5,ffffffe000202638 <vprintfmt+0x320>
ffffffe000202628:	fe043783          	ld	a5,-32(s0)
ffffffe00020262c:	00078663          	beqz	a5,ffffffe000202638 <vprintfmt+0x320>
ffffffe000202630:	00100793          	li	a5,1
ffffffe000202634:	0080006f          	j	ffffffe00020263c <vprintfmt+0x324>
ffffffe000202638:	00000793          	li	a5,0
ffffffe00020263c:	faf40323          	sb	a5,-90(s0)
ffffffe000202640:	fa644783          	lbu	a5,-90(s0)
ffffffe000202644:	0017f793          	andi	a5,a5,1
ffffffe000202648:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe00020264c:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000202650:	f5043783          	ld	a5,-176(s0)
ffffffe000202654:	0007c783          	lbu	a5,0(a5)
ffffffe000202658:	00078713          	mv	a4,a5
ffffffe00020265c:	05800793          	li	a5,88
ffffffe000202660:	00f71863          	bne	a4,a5,ffffffe000202670 <vprintfmt+0x358>
ffffffe000202664:	00001797          	auipc	a5,0x1
ffffffe000202668:	bdc78793          	addi	a5,a5,-1060 # ffffffe000203240 <upperxdigits.1101>
ffffffe00020266c:	00c0006f          	j	ffffffe000202678 <vprintfmt+0x360>
ffffffe000202670:	00001797          	auipc	a5,0x1
ffffffe000202674:	be878793          	addi	a5,a5,-1048 # ffffffe000203258 <lowerxdigits.1100>
ffffffe000202678:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe00020267c:	fe043783          	ld	a5,-32(s0)
ffffffe000202680:	00f7f793          	andi	a5,a5,15
ffffffe000202684:	f9843703          	ld	a4,-104(s0)
ffffffe000202688:	00f70733          	add	a4,a4,a5
ffffffe00020268c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202690:	0017869b          	addiw	a3,a5,1
ffffffe000202694:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202698:	00074703          	lbu	a4,0(a4)
ffffffe00020269c:	ff040693          	addi	a3,s0,-16
ffffffe0002026a0:	00f687b3          	add	a5,a3,a5
ffffffe0002026a4:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002026a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002026ac:	0047d793          	srli	a5,a5,0x4
ffffffe0002026b0:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe0002026b4:	fe043783          	ld	a5,-32(s0)
ffffffe0002026b8:	fc0792e3          	bnez	a5,ffffffe00020267c <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe0002026bc:	f8c42783          	lw	a5,-116(s0)
ffffffe0002026c0:	00078713          	mv	a4,a5
ffffffe0002026c4:	fff00793          	li	a5,-1
ffffffe0002026c8:	02f71663          	bne	a4,a5,ffffffe0002026f4 <vprintfmt+0x3dc>
ffffffe0002026cc:	f8344783          	lbu	a5,-125(s0)
ffffffe0002026d0:	02078263          	beqz	a5,ffffffe0002026f4 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe0002026d4:	f8842703          	lw	a4,-120(s0)
ffffffe0002026d8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002026dc:	0007879b          	sext.w	a5,a5
ffffffe0002026e0:	0017979b          	slliw	a5,a5,0x1
ffffffe0002026e4:	0007879b          	sext.w	a5,a5
ffffffe0002026e8:	40f707bb          	subw	a5,a4,a5
ffffffe0002026ec:	0007879b          	sext.w	a5,a5
ffffffe0002026f0:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002026f4:	f8842703          	lw	a4,-120(s0)
ffffffe0002026f8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002026fc:	0007879b          	sext.w	a5,a5
ffffffe000202700:	0017979b          	slliw	a5,a5,0x1
ffffffe000202704:	0007879b          	sext.w	a5,a5
ffffffe000202708:	40f707bb          	subw	a5,a4,a5
ffffffe00020270c:	0007871b          	sext.w	a4,a5
ffffffe000202710:	fdc42783          	lw	a5,-36(s0)
ffffffe000202714:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202718:	f8c42783          	lw	a5,-116(s0)
ffffffe00020271c:	f8f42823          	sw	a5,-112(s0)
ffffffe000202720:	f9442583          	lw	a1,-108(s0)
ffffffe000202724:	f9042783          	lw	a5,-112(s0)
ffffffe000202728:	0007861b          	sext.w	a2,a5
ffffffe00020272c:	0005869b          	sext.w	a3,a1
ffffffe000202730:	00d65463          	bge	a2,a3,ffffffe000202738 <vprintfmt+0x420>
ffffffe000202734:	00058793          	mv	a5,a1
ffffffe000202738:	0007879b          	sext.w	a5,a5
ffffffe00020273c:	40f707bb          	subw	a5,a4,a5
ffffffe000202740:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202744:	0280006f          	j	ffffffe00020276c <vprintfmt+0x454>
                    putch(' ');
ffffffe000202748:	f5843783          	ld	a5,-168(s0)
ffffffe00020274c:	02000513          	li	a0,32
ffffffe000202750:	000780e7          	jalr	a5
                    ++written;
ffffffe000202754:	fec42783          	lw	a5,-20(s0)
ffffffe000202758:	0017879b          	addiw	a5,a5,1
ffffffe00020275c:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202760:	fd842783          	lw	a5,-40(s0)
ffffffe000202764:	fff7879b          	addiw	a5,a5,-1
ffffffe000202768:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020276c:	fd842783          	lw	a5,-40(s0)
ffffffe000202770:	0007879b          	sext.w	a5,a5
ffffffe000202774:	fcf04ae3          	bgtz	a5,ffffffe000202748 <vprintfmt+0x430>
                }

                if (prefix) {
ffffffe000202778:	fa644783          	lbu	a5,-90(s0)
ffffffe00020277c:	0ff7f793          	andi	a5,a5,255
ffffffe000202780:	04078463          	beqz	a5,ffffffe0002027c8 <vprintfmt+0x4b0>
                    putch('0');
ffffffe000202784:	f5843783          	ld	a5,-168(s0)
ffffffe000202788:	03000513          	li	a0,48
ffffffe00020278c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202790:	f5043783          	ld	a5,-176(s0)
ffffffe000202794:	0007c783          	lbu	a5,0(a5)
ffffffe000202798:	00078713          	mv	a4,a5
ffffffe00020279c:	05800793          	li	a5,88
ffffffe0002027a0:	00f71663          	bne	a4,a5,ffffffe0002027ac <vprintfmt+0x494>
ffffffe0002027a4:	05800793          	li	a5,88
ffffffe0002027a8:	0080006f          	j	ffffffe0002027b0 <vprintfmt+0x498>
ffffffe0002027ac:	07800793          	li	a5,120
ffffffe0002027b0:	f5843703          	ld	a4,-168(s0)
ffffffe0002027b4:	00078513          	mv	a0,a5
ffffffe0002027b8:	000700e7          	jalr	a4
                    written += 2;
ffffffe0002027bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002027c0:	0027879b          	addiw	a5,a5,2
ffffffe0002027c4:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002027c8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002027cc:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002027d0:	0280006f          	j	ffffffe0002027f8 <vprintfmt+0x4e0>
                    putch('0');
ffffffe0002027d4:	f5843783          	ld	a5,-168(s0)
ffffffe0002027d8:	03000513          	li	a0,48
ffffffe0002027dc:	000780e7          	jalr	a5
                    ++written;
ffffffe0002027e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002027e4:	0017879b          	addiw	a5,a5,1
ffffffe0002027e8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002027ec:	fd442783          	lw	a5,-44(s0)
ffffffe0002027f0:	0017879b          	addiw	a5,a5,1
ffffffe0002027f4:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002027f8:	f8c42703          	lw	a4,-116(s0)
ffffffe0002027fc:	fd442783          	lw	a5,-44(s0)
ffffffe000202800:	0007879b          	sext.w	a5,a5
ffffffe000202804:	fce7c8e3          	blt	a5,a4,ffffffe0002027d4 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202808:	fdc42783          	lw	a5,-36(s0)
ffffffe00020280c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202810:	fcf42823          	sw	a5,-48(s0)
ffffffe000202814:	03c0006f          	j	ffffffe000202850 <vprintfmt+0x538>
                    putch(buf[i]);
ffffffe000202818:	fd042783          	lw	a5,-48(s0)
ffffffe00020281c:	ff040713          	addi	a4,s0,-16
ffffffe000202820:	00f707b3          	add	a5,a4,a5
ffffffe000202824:	f807c783          	lbu	a5,-128(a5)
ffffffe000202828:	0007879b          	sext.w	a5,a5
ffffffe00020282c:	f5843703          	ld	a4,-168(s0)
ffffffe000202830:	00078513          	mv	a0,a5
ffffffe000202834:	000700e7          	jalr	a4
                    ++written;
ffffffe000202838:	fec42783          	lw	a5,-20(s0)
ffffffe00020283c:	0017879b          	addiw	a5,a5,1
ffffffe000202840:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202844:	fd042783          	lw	a5,-48(s0)
ffffffe000202848:	fff7879b          	addiw	a5,a5,-1
ffffffe00020284c:	fcf42823          	sw	a5,-48(s0)
ffffffe000202850:	fd042783          	lw	a5,-48(s0)
ffffffe000202854:	0007879b          	sext.w	a5,a5
ffffffe000202858:	fc07d0e3          	bgez	a5,ffffffe000202818 <vprintfmt+0x500>
                }

                flags.in_format = false;
ffffffe00020285c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202860:	2780006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202864:	f5043783          	ld	a5,-176(s0)
ffffffe000202868:	0007c783          	lbu	a5,0(a5)
ffffffe00020286c:	00078713          	mv	a4,a5
ffffffe000202870:	06400793          	li	a5,100
ffffffe000202874:	02f70663          	beq	a4,a5,ffffffe0002028a0 <vprintfmt+0x588>
ffffffe000202878:	f5043783          	ld	a5,-176(s0)
ffffffe00020287c:	0007c783          	lbu	a5,0(a5)
ffffffe000202880:	00078713          	mv	a4,a5
ffffffe000202884:	06900793          	li	a5,105
ffffffe000202888:	00f70c63          	beq	a4,a5,ffffffe0002028a0 <vprintfmt+0x588>
ffffffe00020288c:	f5043783          	ld	a5,-176(s0)
ffffffe000202890:	0007c783          	lbu	a5,0(a5)
ffffffe000202894:	00078713          	mv	a4,a5
ffffffe000202898:	07500793          	li	a5,117
ffffffe00020289c:	08f71263          	bne	a4,a5,ffffffe000202920 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002028a0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002028a4:	00078c63          	beqz	a5,ffffffe0002028bc <vprintfmt+0x5a4>
ffffffe0002028a8:	f4843783          	ld	a5,-184(s0)
ffffffe0002028ac:	00878713          	addi	a4,a5,8
ffffffe0002028b0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002028b4:	0007b783          	ld	a5,0(a5)
ffffffe0002028b8:	0140006f          	j	ffffffe0002028cc <vprintfmt+0x5b4>
ffffffe0002028bc:	f4843783          	ld	a5,-184(s0)
ffffffe0002028c0:	00878713          	addi	a4,a5,8
ffffffe0002028c4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002028c8:	0007a783          	lw	a5,0(a5)
ffffffe0002028cc:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe0002028d0:	fa843583          	ld	a1,-88(s0)
ffffffe0002028d4:	f5043783          	ld	a5,-176(s0)
ffffffe0002028d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002028dc:	0007871b          	sext.w	a4,a5
ffffffe0002028e0:	07500793          	li	a5,117
ffffffe0002028e4:	40f707b3          	sub	a5,a4,a5
ffffffe0002028e8:	00f037b3          	snez	a5,a5
ffffffe0002028ec:	0ff7f793          	andi	a5,a5,255
ffffffe0002028f0:	f8040713          	addi	a4,s0,-128
ffffffe0002028f4:	00070693          	mv	a3,a4
ffffffe0002028f8:	00078613          	mv	a2,a5
ffffffe0002028fc:	f5843503          	ld	a0,-168(s0)
ffffffe000202900:	f18ff0ef          	jal	ra,ffffffe000202018 <print_dec_int>
ffffffe000202904:	00050793          	mv	a5,a0
ffffffe000202908:	00078713          	mv	a4,a5
ffffffe00020290c:	fec42783          	lw	a5,-20(s0)
ffffffe000202910:	00e787bb          	addw	a5,a5,a4
ffffffe000202914:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202918:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe00020291c:	1bc0006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000202920:	f5043783          	ld	a5,-176(s0)
ffffffe000202924:	0007c783          	lbu	a5,0(a5)
ffffffe000202928:	00078713          	mv	a4,a5
ffffffe00020292c:	06e00793          	li	a5,110
ffffffe000202930:	04f71c63          	bne	a4,a5,ffffffe000202988 <vprintfmt+0x670>
                if (flags.longflag) {
ffffffe000202934:	f8144783          	lbu	a5,-127(s0)
ffffffe000202938:	02078463          	beqz	a5,ffffffe000202960 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
ffffffe00020293c:	f4843783          	ld	a5,-184(s0)
ffffffe000202940:	00878713          	addi	a4,a5,8
ffffffe000202944:	f4e43423          	sd	a4,-184(s0)
ffffffe000202948:	0007b783          	ld	a5,0(a5)
ffffffe00020294c:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000202950:	fec42703          	lw	a4,-20(s0)
ffffffe000202954:	fb043783          	ld	a5,-80(s0)
ffffffe000202958:	00e7b023          	sd	a4,0(a5)
ffffffe00020295c:	0240006f          	j	ffffffe000202980 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202960:	f4843783          	ld	a5,-184(s0)
ffffffe000202964:	00878713          	addi	a4,a5,8
ffffffe000202968:	f4e43423          	sd	a4,-184(s0)
ffffffe00020296c:	0007b783          	ld	a5,0(a5)
ffffffe000202970:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202974:	fb843783          	ld	a5,-72(s0)
ffffffe000202978:	fec42703          	lw	a4,-20(s0)
ffffffe00020297c:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202980:	f8040023          	sb	zero,-128(s0)
ffffffe000202984:	1540006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202988:	f5043783          	ld	a5,-176(s0)
ffffffe00020298c:	0007c783          	lbu	a5,0(a5)
ffffffe000202990:	00078713          	mv	a4,a5
ffffffe000202994:	07300793          	li	a5,115
ffffffe000202998:	04f71063          	bne	a4,a5,ffffffe0002029d8 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe00020299c:	f4843783          	ld	a5,-184(s0)
ffffffe0002029a0:	00878713          	addi	a4,a5,8
ffffffe0002029a4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002029a8:	0007b783          	ld	a5,0(a5)
ffffffe0002029ac:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe0002029b0:	fc043583          	ld	a1,-64(s0)
ffffffe0002029b4:	f5843503          	ld	a0,-168(s0)
ffffffe0002029b8:	dd8ff0ef          	jal	ra,ffffffe000201f90 <puts_wo_nl>
ffffffe0002029bc:	00050793          	mv	a5,a0
ffffffe0002029c0:	00078713          	mv	a4,a5
ffffffe0002029c4:	fec42783          	lw	a5,-20(s0)
ffffffe0002029c8:	00e787bb          	addw	a5,a5,a4
ffffffe0002029cc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002029d0:	f8040023          	sb	zero,-128(s0)
ffffffe0002029d4:	1040006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe0002029d8:	f5043783          	ld	a5,-176(s0)
ffffffe0002029dc:	0007c783          	lbu	a5,0(a5)
ffffffe0002029e0:	00078713          	mv	a4,a5
ffffffe0002029e4:	06300793          	li	a5,99
ffffffe0002029e8:	02f71e63          	bne	a4,a5,ffffffe000202a24 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe0002029ec:	f4843783          	ld	a5,-184(s0)
ffffffe0002029f0:	00878713          	addi	a4,a5,8
ffffffe0002029f4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002029f8:	0007a783          	lw	a5,0(a5)
ffffffe0002029fc:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202a00:	fcc42783          	lw	a5,-52(s0)
ffffffe000202a04:	f5843703          	ld	a4,-168(s0)
ffffffe000202a08:	00078513          	mv	a0,a5
ffffffe000202a0c:	000700e7          	jalr	a4
                ++written;
ffffffe000202a10:	fec42783          	lw	a5,-20(s0)
ffffffe000202a14:	0017879b          	addiw	a5,a5,1
ffffffe000202a18:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202a1c:	f8040023          	sb	zero,-128(s0)
ffffffe000202a20:	0b80006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202a24:	f5043783          	ld	a5,-176(s0)
ffffffe000202a28:	0007c783          	lbu	a5,0(a5)
ffffffe000202a2c:	00078713          	mv	a4,a5
ffffffe000202a30:	02500793          	li	a5,37
ffffffe000202a34:	02f71263          	bne	a4,a5,ffffffe000202a58 <vprintfmt+0x740>
                putch('%');
ffffffe000202a38:	f5843783          	ld	a5,-168(s0)
ffffffe000202a3c:	02500513          	li	a0,37
ffffffe000202a40:	000780e7          	jalr	a5
                ++written;
ffffffe000202a44:	fec42783          	lw	a5,-20(s0)
ffffffe000202a48:	0017879b          	addiw	a5,a5,1
ffffffe000202a4c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202a50:	f8040023          	sb	zero,-128(s0)
ffffffe000202a54:	0840006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000202a58:	f5043783          	ld	a5,-176(s0)
ffffffe000202a5c:	0007c783          	lbu	a5,0(a5)
ffffffe000202a60:	0007879b          	sext.w	a5,a5
ffffffe000202a64:	f5843703          	ld	a4,-168(s0)
ffffffe000202a68:	00078513          	mv	a0,a5
ffffffe000202a6c:	000700e7          	jalr	a4
                ++written;
ffffffe000202a70:	fec42783          	lw	a5,-20(s0)
ffffffe000202a74:	0017879b          	addiw	a5,a5,1
ffffffe000202a78:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202a7c:	f8040023          	sb	zero,-128(s0)
ffffffe000202a80:	0580006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202a84:	f5043783          	ld	a5,-176(s0)
ffffffe000202a88:	0007c783          	lbu	a5,0(a5)
ffffffe000202a8c:	00078713          	mv	a4,a5
ffffffe000202a90:	02500793          	li	a5,37
ffffffe000202a94:	02f71063          	bne	a4,a5,ffffffe000202ab4 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202a98:	f8043023          	sd	zero,-128(s0)
ffffffe000202a9c:	f8043423          	sd	zero,-120(s0)
ffffffe000202aa0:	00100793          	li	a5,1
ffffffe000202aa4:	f8f40023          	sb	a5,-128(s0)
ffffffe000202aa8:	fff00793          	li	a5,-1
ffffffe000202aac:	f8f42623          	sw	a5,-116(s0)
ffffffe000202ab0:	0280006f          	j	ffffffe000202ad8 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202ab4:	f5043783          	ld	a5,-176(s0)
ffffffe000202ab8:	0007c783          	lbu	a5,0(a5)
ffffffe000202abc:	0007879b          	sext.w	a5,a5
ffffffe000202ac0:	f5843703          	ld	a4,-168(s0)
ffffffe000202ac4:	00078513          	mv	a0,a5
ffffffe000202ac8:	000700e7          	jalr	a4
            ++written;
ffffffe000202acc:	fec42783          	lw	a5,-20(s0)
ffffffe000202ad0:	0017879b          	addiw	a5,a5,1
ffffffe000202ad4:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202ad8:	f5043783          	ld	a5,-176(s0)
ffffffe000202adc:	00178793          	addi	a5,a5,1
ffffffe000202ae0:	f4f43823          	sd	a5,-176(s0)
ffffffe000202ae4:	f5043783          	ld	a5,-176(s0)
ffffffe000202ae8:	0007c783          	lbu	a5,0(a5)
ffffffe000202aec:	84079ce3          	bnez	a5,ffffffe000202344 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202af0:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202af4:	00078513          	mv	a0,a5
ffffffe000202af8:	0b813083          	ld	ra,184(sp)
ffffffe000202afc:	0b013403          	ld	s0,176(sp)
ffffffe000202b00:	0c010113          	addi	sp,sp,192
ffffffe000202b04:	00008067          	ret

ffffffe000202b08 <printk>:

int printk(const char* s, ...) {
ffffffe000202b08:	f9010113          	addi	sp,sp,-112
ffffffe000202b0c:	02113423          	sd	ra,40(sp)
ffffffe000202b10:	02813023          	sd	s0,32(sp)
ffffffe000202b14:	03010413          	addi	s0,sp,48
ffffffe000202b18:	fca43c23          	sd	a0,-40(s0)
ffffffe000202b1c:	00b43423          	sd	a1,8(s0)
ffffffe000202b20:	00c43823          	sd	a2,16(s0)
ffffffe000202b24:	00d43c23          	sd	a3,24(s0)
ffffffe000202b28:	02e43023          	sd	a4,32(s0)
ffffffe000202b2c:	02f43423          	sd	a5,40(s0)
ffffffe000202b30:	03043823          	sd	a6,48(s0)
ffffffe000202b34:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000202b38:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000202b3c:	04040793          	addi	a5,s0,64
ffffffe000202b40:	fcf43823          	sd	a5,-48(s0)
ffffffe000202b44:	fd043783          	ld	a5,-48(s0)
ffffffe000202b48:	fc878793          	addi	a5,a5,-56
ffffffe000202b4c:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000202b50:	fe043783          	ld	a5,-32(s0)
ffffffe000202b54:	00078613          	mv	a2,a5
ffffffe000202b58:	fd843583          	ld	a1,-40(s0)
ffffffe000202b5c:	fffff517          	auipc	a0,0xfffff
ffffffe000202b60:	12450513          	addi	a0,a0,292 # ffffffe000201c80 <putc>
ffffffe000202b64:	fb4ff0ef          	jal	ra,ffffffe000202318 <vprintfmt>
ffffffe000202b68:	00050793          	mv	a5,a0
ffffffe000202b6c:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202b70:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202b74:	00078513          	mv	a0,a5
ffffffe000202b78:	02813083          	ld	ra,40(sp)
ffffffe000202b7c:	02013403          	ld	s0,32(sp)
ffffffe000202b80:	07010113          	addi	sp,sp,112
ffffffe000202b84:	00008067          	ret

ffffffe000202b88 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202b88:	fe010113          	addi	sp,sp,-32
ffffffe000202b8c:	00813c23          	sd	s0,24(sp)
ffffffe000202b90:	02010413          	addi	s0,sp,32
ffffffe000202b94:	00050793          	mv	a5,a0
ffffffe000202b98:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202b9c:	fec42783          	lw	a5,-20(s0)
ffffffe000202ba0:	fff7879b          	addiw	a5,a5,-1
ffffffe000202ba4:	0007879b          	sext.w	a5,a5
ffffffe000202ba8:	02079713          	slli	a4,a5,0x20
ffffffe000202bac:	02075713          	srli	a4,a4,0x20
ffffffe000202bb0:	00004797          	auipc	a5,0x4
ffffffe000202bb4:	45078793          	addi	a5,a5,1104 # ffffffe000207000 <seed>
ffffffe000202bb8:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202bbc:	00000013          	nop
ffffffe000202bc0:	01813403          	ld	s0,24(sp)
ffffffe000202bc4:	02010113          	addi	sp,sp,32
ffffffe000202bc8:	00008067          	ret

ffffffe000202bcc <rand>:

int rand(void) {
ffffffe000202bcc:	ff010113          	addi	sp,sp,-16
ffffffe000202bd0:	00813423          	sd	s0,8(sp)
ffffffe000202bd4:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202bd8:	00004797          	auipc	a5,0x4
ffffffe000202bdc:	42878793          	addi	a5,a5,1064 # ffffffe000207000 <seed>
ffffffe000202be0:	0007b703          	ld	a4,0(a5)
ffffffe000202be4:	00000797          	auipc	a5,0x0
ffffffe000202be8:	68c78793          	addi	a5,a5,1676 # ffffffe000203270 <lowerxdigits.1100+0x18>
ffffffe000202bec:	0007b783          	ld	a5,0(a5)
ffffffe000202bf0:	02f707b3          	mul	a5,a4,a5
ffffffe000202bf4:	00178713          	addi	a4,a5,1
ffffffe000202bf8:	00004797          	auipc	a5,0x4
ffffffe000202bfc:	40878793          	addi	a5,a5,1032 # ffffffe000207000 <seed>
ffffffe000202c00:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202c04:	00004797          	auipc	a5,0x4
ffffffe000202c08:	3fc78793          	addi	a5,a5,1020 # ffffffe000207000 <seed>
ffffffe000202c0c:	0007b783          	ld	a5,0(a5)
ffffffe000202c10:	0217d793          	srli	a5,a5,0x21
ffffffe000202c14:	0007879b          	sext.w	a5,a5
}
ffffffe000202c18:	00078513          	mv	a0,a5
ffffffe000202c1c:	00813403          	ld	s0,8(sp)
ffffffe000202c20:	01010113          	addi	sp,sp,16
ffffffe000202c24:	00008067          	ret

ffffffe000202c28 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000202c28:	fc010113          	addi	sp,sp,-64
ffffffe000202c2c:	02813c23          	sd	s0,56(sp)
ffffffe000202c30:	04010413          	addi	s0,sp,64
ffffffe000202c34:	fca43c23          	sd	a0,-40(s0)
ffffffe000202c38:	00058793          	mv	a5,a1
ffffffe000202c3c:	fcc43423          	sd	a2,-56(s0)
ffffffe000202c40:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000202c44:	fd843783          	ld	a5,-40(s0)
ffffffe000202c48:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202c4c:	fe043423          	sd	zero,-24(s0)
ffffffe000202c50:	0280006f          	j	ffffffe000202c78 <memset+0x50>
        s[i] = c;
ffffffe000202c54:	fe043703          	ld	a4,-32(s0)
ffffffe000202c58:	fe843783          	ld	a5,-24(s0)
ffffffe000202c5c:	00f707b3          	add	a5,a4,a5
ffffffe000202c60:	fd442703          	lw	a4,-44(s0)
ffffffe000202c64:	0ff77713          	andi	a4,a4,255
ffffffe000202c68:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202c6c:	fe843783          	ld	a5,-24(s0)
ffffffe000202c70:	00178793          	addi	a5,a5,1
ffffffe000202c74:	fef43423          	sd	a5,-24(s0)
ffffffe000202c78:	fe843703          	ld	a4,-24(s0)
ffffffe000202c7c:	fc843783          	ld	a5,-56(s0)
ffffffe000202c80:	fcf76ae3          	bltu	a4,a5,ffffffe000202c54 <memset+0x2c>
    }
    return dest;
ffffffe000202c84:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202c88:	00078513          	mv	a0,a5
ffffffe000202c8c:	03813403          	ld	s0,56(sp)
ffffffe000202c90:	04010113          	addi	sp,sp,64
ffffffe000202c94:	00008067          	ret
