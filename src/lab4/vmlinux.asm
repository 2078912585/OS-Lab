
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm_final
    .extern PA2VA_OFFSET
    .section .text.init
    .globl _start
_start:
    la sp,boot_stack_top # 设置栈指针指向栈顶
ffffffe000200000:	00009117          	auipc	sp,0x9
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm  #映射
ffffffe000200008:	279010ef          	jal	ra,ffffffe000201a80 <setup_vm>
    call relocate
ffffffe00020000c:	03c000ef          	jal	ra,ffffffe000200048 <relocate>
    call mm_init #初始化内存管理系统
ffffffe000200010:	2e9000ef          	jal	ra,ffffffe000200af8 <mm_init>
    call setup_vm_final
ffffffe000200014:	571010ef          	jal	ra,ffffffe000201d84 <setup_vm_final>
    call task_init #初始化线程数据结构 
ffffffe000200018:	565000ef          	jal	ra,ffffffe000200d7c <task_init>
    
    # set stvec = _traps
    la t0,_traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	0a428293          	addi	t0,t0,164 # ffffffe0002000c0 <_traps>
    csrw stvec,t0
ffffffe000200024:	10529073          	csrw	stvec,t0

    # set sie[STIE]=1
    li t0,(1<<5)
ffffffe000200028:	02000293          	li	t0,32
    csrs sie,t0
ffffffe00020002c:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call get_cycles
ffffffe000200030:	2f0000ef          	jal	ra,ffffffe000200320 <get_cycles>
    li t0,10000000
ffffffe000200034:	009892b7          	lui	t0,0x989
ffffffe000200038:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
ffffffe00020003c:	00550533          	add	a0,a0,t0
    call sbi_set_timer
ffffffe000200040:	660010ef          	jal	ra,ffffffe0002016a0 <sbi_set_timer>

    # set sstatus[SIE]=1
    #li t0,(1<<1)
    #csrs sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
ffffffe000200044:	7550106f          	j	ffffffe000201f98 <start_kernel>

ffffffe000200048 <relocate>:

    .globl relocate
relocate:
    # PA2VA_OFFSET=0xffffffdf80000000
    li t0,0x80000000
ffffffe000200048:	0010029b          	addiw	t0,zero,1
ffffffe00020004c:	01f29293          	slli	t0,t0,0x1f
    li t1,0xffffffdf
ffffffe000200050:	0010031b          	addiw	t1,zero,1
ffffffe000200054:	02031313          	slli	t1,t1,0x20
ffffffe000200058:	fdf30313          	addi	t1,t1,-33
    slli t1,t1,32
ffffffe00020005c:	02031313          	slli	t1,t1,0x20
    or t0,t0,t1
ffffffe000200060:	0062e2b3          	or	t0,t0,t1

    add ra,ra,t0     # set ra = ra + PA2VA_OFFSET
ffffffe000200064:	005080b3          	add	ra,ra,t0
    add sp,sp,t0     # set sp = sp + PA2VA_OFFSET 
ffffffe000200068:	00510133          	add	sp,sp,t0

    # need a fence to ensure the new translations are in use
    sfence.vma zero,zero      
ffffffe00020006c:	12000073          	sfence.vma

    # set satp
    la t0,early_pgtbl
ffffffe000200070:	0000c297          	auipc	t0,0xc
ffffffe000200074:	f9028293          	addi	t0,t0,-112 # ffffffe00020c000 <early_pgtbl>
    srli t0,t0,12
ffffffe000200078:	00c2d293          	srli	t0,t0,0xc
    li t1,(8<<60)    # MODE=8 Sv39
ffffffe00020007c:	fff0031b          	addiw	t1,zero,-1
ffffffe000200080:	03f31313          	slli	t1,t1,0x3f
    or t0,t0,t1
ffffffe000200084:	0062e2b3          	or	t0,t0,t1
    csrw satp,t0
ffffffe000200088:	18029073          	csrw	satp,t0
    
    sfence.vma zero, zero
ffffffe00020008c:	12000073          	sfence.vma
    ret
ffffffe000200090:	00008067          	ret

ffffffe000200094 <set_trap>:

    .globl set_trap
set_trap:
     # PA2VA_OFFSET=0xffffffdf80000000
    li t2,0x80000000
ffffffe000200094:	0010039b          	addiw	t2,zero,1
ffffffe000200098:	01f39393          	slli	t2,t2,0x1f
    li t3,0xffffffdf
ffffffe00020009c:	00100e1b          	addiw	t3,zero,1
ffffffe0002000a0:	020e1e13          	slli	t3,t3,0x20
ffffffe0002000a4:	fdfe0e13          	addi	t3,t3,-33
    slli t3,t3,32
ffffffe0002000a8:	020e1e13          	slli	t3,t3,0x20
    or t2,t2,t3
ffffffe0002000ac:	01c3e3b3          	or	t2,t2,t3

    csrr t3,sepc
ffffffe0002000b0:	14102e73          	csrr	t3,sepc
    add t3,t3,t2
ffffffe0002000b4:	007e0e33          	add	t3,t3,t2
    csrw sepc,t3
ffffffe0002000b8:	141e1073          	csrw	sepc,t3

    sret
ffffffe0002000bc:	10200073          	sret

ffffffe0002000c0 <_traps>:
    .section .text.entry
    .align 2
    .globl _traps
_traps:
    # 判断是否来自用户态
    csrr t0,sscratch
ffffffe0002000c0:	140022f3          	csrr	t0,sscratch
    beqz t0,no_swap_first
ffffffe0002000c4:	00028663          	beqz	t0,ffffffe0002000d0 <no_swap_first>
    csrw sscratch,sp
ffffffe0002000c8:	14011073          	csrw	sscratch,sp
    mv sp,t0
ffffffe0002000cc:	00028113          	mv	sp,t0

ffffffe0002000d0 <no_swap_first>:

no_swap_first:
    addi sp,sp,-34*8   # 开辟栈空间
ffffffe0002000d0:	ef010113          	addi	sp,sp,-272 # ffffffe000208ef0 <_sbss+0xef0>
    # save 32 registers and sepc to stack
    sd x0,0*8(sp)
ffffffe0002000d4:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)
ffffffe0002000d8:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)
ffffffe0002000dc:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)
ffffffe0002000e0:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)
ffffffe0002000e4:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)
ffffffe0002000e8:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
ffffffe0002000ec:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
ffffffe0002000f0:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)
ffffffe0002000f4:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)
ffffffe0002000f8:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)
ffffffe0002000fc:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
ffffffe000200100:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
ffffffe000200104:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
ffffffe000200108:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
ffffffe00020010c:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
ffffffe000200110:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
ffffffe000200114:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
ffffffe000200118:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)
ffffffe00020011c:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
ffffffe000200120:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
ffffffe000200124:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
ffffffe000200128:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
ffffffe00020012c:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
ffffffe000200130:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
ffffffe000200134:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
ffffffe000200138:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
ffffffe00020013c:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
ffffffe000200140:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)
ffffffe000200144:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
ffffffe000200148:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
ffffffe00020014c:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
ffffffe000200150:	0ff13c23          	sd	t6,248(sp)
    csrr t0,sepc
ffffffe000200154:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
ffffffe000200158:	10513023          	sd	t0,256(sp)
    csrr t0,sstatus
ffffffe00020015c:	100022f3          	csrr	t0,sstatus
    sd t0,33*8(sp)
ffffffe000200160:	10513423          	sd	t0,264(sp)

    # call trap_handler
    csrr a0,scause
ffffffe000200164:	14202573          	csrr	a0,scause
    csrr a1,sepc
ffffffe000200168:	141025f3          	csrr	a1,sepc
    mv a2,sp
ffffffe00020016c:	00010613          	mv	a2,sp
    call trap_handler
ffffffe000200170:	7c4010ef          	jal	ra,ffffffe000201934 <trap_handler>

    # restore sepc and 32 register from stack
    ld t0,32*8(sp)
ffffffe000200174:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
ffffffe000200178:	14129073          	csrw	sepc,t0

    ld x31,31*8(sp)
ffffffe00020017c:	0f813f83          	ld	t6,248(sp)
    ld x30,30*8(sp)
ffffffe000200180:	0f013f03          	ld	t5,240(sp)
    ld x29,29*8(sp)
ffffffe000200184:	0e813e83          	ld	t4,232(sp)
    ld x28,28*8(sp)
ffffffe000200188:	0e013e03          	ld	t3,224(sp)
    ld x27,27*8(sp)
ffffffe00020018c:	0d813d83          	ld	s11,216(sp)
    ld x26,26*8(sp)
ffffffe000200190:	0d013d03          	ld	s10,208(sp)
    ld x25,25*8(sp)
ffffffe000200194:	0c813c83          	ld	s9,200(sp)
    ld x24,24*8(sp)
ffffffe000200198:	0c013c03          	ld	s8,192(sp)
    ld x23,23*8(sp)
ffffffe00020019c:	0b813b83          	ld	s7,184(sp)
    ld x22,22*8(sp)
ffffffe0002001a0:	0b013b03          	ld	s6,176(sp)
    ld x21,21*8(sp)
ffffffe0002001a4:	0a813a83          	ld	s5,168(sp)
    ld x20,20*8(sp)
ffffffe0002001a8:	0a013a03          	ld	s4,160(sp)
    ld x19,19*8(sp)
ffffffe0002001ac:	09813983          	ld	s3,152(sp)
    ld x18,18*8(sp)
ffffffe0002001b0:	09013903          	ld	s2,144(sp)
    ld x17,17*8(sp)
ffffffe0002001b4:	08813883          	ld	a7,136(sp)
    ld x16,16*8(sp)
ffffffe0002001b8:	08013803          	ld	a6,128(sp)
    ld x15,15*8(sp)
ffffffe0002001bc:	07813783          	ld	a5,120(sp)
    ld x14,14*8(sp)
ffffffe0002001c0:	07013703          	ld	a4,112(sp)
    ld x13,13*8(sp)
ffffffe0002001c4:	06813683          	ld	a3,104(sp)
    ld x12,12*8(sp)
ffffffe0002001c8:	06013603          	ld	a2,96(sp)
    ld x11,11*8(sp)
ffffffe0002001cc:	05813583          	ld	a1,88(sp)
    ld x10,10*8(sp)
ffffffe0002001d0:	05013503          	ld	a0,80(sp)
    ld x9,9*8(sp)
ffffffe0002001d4:	04813483          	ld	s1,72(sp)
    ld x8,8*8(sp)
ffffffe0002001d8:	04013403          	ld	s0,64(sp)
    ld x7,7*8(sp)
ffffffe0002001dc:	03813383          	ld	t2,56(sp)
    ld x6,6*8(sp)
ffffffe0002001e0:	03013303          	ld	t1,48(sp)
    ld x5,5*8(sp)
ffffffe0002001e4:	02813283          	ld	t0,40(sp)
    ld x4,4*8(sp)
ffffffe0002001e8:	02013203          	ld	tp,32(sp)
    ld x3,3*8(sp)
ffffffe0002001ec:	01813183          	ld	gp,24(sp)
    ld x1,1*8(sp)
ffffffe0002001f0:	00813083          	ld	ra,8(sp)
    ld x0,0*8(sp)
ffffffe0002001f4:	00013003          	ld	zero,0(sp)
    ld x2,2*8(sp)
ffffffe0002001f8:	01013103          	ld	sp,16(sp)
    addi sp,sp,34*8   # 释放栈空间
ffffffe0002001fc:	11010113          	addi	sp,sp,272

    # 如果为用户态（再次交换）
    csrr t0,sscratch
ffffffe000200200:	140022f3          	csrr	t0,sscratch
    beqz t0,no_swap_last
ffffffe000200204:	00028663          	beqz	t0,ffffffe000200210 <no_swap_last>
    csrw sscratch,sp
ffffffe000200208:	14011073          	csrw	sscratch,sp
    mv sp,t0
ffffffe00020020c:	00028113          	mv	sp,t0

ffffffe000200210 <no_swap_last>:

no_swap_last:
    # return from trap
    sret
ffffffe000200210:	10200073          	sret

ffffffe000200214 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    #r 交换寄存器值
    csrr t0,sscratch
ffffffe000200214:	140022f3          	csrr	t0,sscratch
    csrw sscratch,sp
ffffffe000200218:	14011073          	csrw	sscratch,sp
    mv sp,t0
ffffffe00020021c:	00028113          	mv	sp,t0

    #la t0,dummy
    #csrw sepc,t0
    sret
ffffffe000200220:	10200073          	sret

ffffffe000200224 <__switch_to>:

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
ffffffe000200224:	02153023          	sd	ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
ffffffe000200228:	02253423          	sd	sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
ffffffe00020022c:	02853823          	sd	s0,48(a0)
    sd s1,56(a0)
ffffffe000200230:	02953c23          	sd	s1,56(a0)
    sd s2,64(a0)
ffffffe000200234:	05253023          	sd	s2,64(a0)
    sd s3,72(a0)
ffffffe000200238:	05353423          	sd	s3,72(a0)
    sd s4,80(a0)
ffffffe00020023c:	05453823          	sd	s4,80(a0)
    sd s5,88(a0)
ffffffe000200240:	05553c23          	sd	s5,88(a0)
    sd s6,96(a0)
ffffffe000200244:	07653023          	sd	s6,96(a0)
    sd s7,104(a0)
ffffffe000200248:	07753423          	sd	s7,104(a0)
    sd s8,112(a0)
ffffffe00020024c:	07853823          	sd	s8,112(a0)
    sd s9,120(a0)
ffffffe000200250:	07953c23          	sd	s9,120(a0)
    sd s10,128(a0)
ffffffe000200254:	09a53023          	sd	s10,128(a0)
    sd s11,136(a0)
ffffffe000200258:	09b53423          	sd	s11,136(a0)

    # 保存 sepc ,sstatus,sscratch
    csrr t0,sepc
ffffffe00020025c:	141022f3          	csrr	t0,sepc
    sd t0,152(a0)
ffffffe000200260:	08553c23          	sd	t0,152(a0)
    csrr t0,sstatus
ffffffe000200264:	100022f3          	csrr	t0,sstatus
    sd t0,160(a0)
ffffffe000200268:	0a553023          	sd	t0,160(a0)
    csrr t0,sscratch
ffffffe00020026c:	140022f3          	csrr	t0,sscratch
    sd t0,168(a0)
ffffffe000200270:	0a553423          	sd	t0,168(a0)

    # 切换页表
    li t0,0x80000000
ffffffe000200274:	0010029b          	addiw	t0,zero,1
ffffffe000200278:	01f29293          	slli	t0,t0,0x1f
    li t1,0xffffffdf
ffffffe00020027c:	0010031b          	addiw	t1,zero,1
ffffffe000200280:	02031313          	slli	t1,t1,0x20
ffffffe000200284:	fdf30313          	addi	t1,t1,-33
    slli t1,t1,32
ffffffe000200288:	02031313          	slli	t1,t1,0x20
    or t0,t0,t1         # PA2VA_OFFSET=0xffffffdf80000000
ffffffe00020028c:	0062e2b3          	or	t0,t0,t1
    ld t1,176(a1)       # next->pgd
ffffffe000200290:	0b05b303          	ld	t1,176(a1)
    sub t1,t1,t0        # 物理地址
ffffffe000200294:	40530333          	sub	t1,t1,t0
    srli t1,t1,12       # PPN
ffffffe000200298:	00c35313          	srli	t1,t1,0xc
    li t0,(8<<60)       # MOOD=8 SV39
ffffffe00020029c:	fff0029b          	addiw	t0,zero,-1
ffffffe0002002a0:	03f29293          	slli	t0,t0,0x3f
    or t0,t0,t1
ffffffe0002002a4:	0062e2b3          	or	t0,t0,t1
    csrw satp,t0
ffffffe0002002a8:	18029073          	csrw	satp,t0
    sfence.vma zero, zero
ffffffe0002002ac:	12000073          	sfence.vma

    # 恢复下一个进程 sepc,sstatus,sscratch
    ld t0,152(a1)
ffffffe0002002b0:	0985b283          	ld	t0,152(a1)
    csrw sepc,t0
ffffffe0002002b4:	14129073          	csrw	sepc,t0
    ld t0,160(a1)
ffffffe0002002b8:	0a05b283          	ld	t0,160(a1)
    csrw sstatus,t0
ffffffe0002002bc:	10029073          	csrw	sstatus,t0
    ld t0,168(a1)
ffffffe0002002c0:	0a85b283          	ld	t0,168(a1)
    csrw sscratch,t0
ffffffe0002002c4:	14029073          	csrw	sscratch,t0


    #next是否为第一次调度
    ld t0,144(a1)
ffffffe0002002c8:	0905b283          	ld	t0,144(a1)
    bnez t0,first_schedule
ffffffe0002002cc:	04029063          	bnez	t0,ffffffe00020030c <first_schedule>

    #恢复下一个进程上下文
    ld ra,32(a1)
ffffffe0002002d0:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe0002002d4:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
ffffffe0002002d8:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
ffffffe0002002dc:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
ffffffe0002002e0:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
ffffffe0002002e4:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
ffffffe0002002e8:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
ffffffe0002002ec:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
ffffffe0002002f0:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
ffffffe0002002f4:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
ffffffe0002002f8:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
ffffffe0002002fc:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
ffffffe000200300:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
ffffffe000200304:	0885bd83          	ld	s11,136(a1)


    j switch_done
ffffffe000200308:	0140006f          	j	ffffffe00020031c <switch_done>

ffffffe00020030c <first_schedule>:

first_schedule:
    sd zero, 144(a1)  
ffffffe00020030c:	0805b823          	sd	zero,144(a1)
    ld ra,32(a1)
ffffffe000200310:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe000200314:	0285b103          	ld	sp,40(a1)
    j switch_done
ffffffe000200318:	0040006f          	j	ffffffe00020031c <switch_done>

ffffffe00020031c <switch_done>:

switch_done:
    ret
ffffffe00020031c:	00008067          	ret

ffffffe000200320 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200320:	fe010113          	addi	sp,sp,-32
ffffffe000200324:	00813c23          	sd	s0,24(sp)
ffffffe000200328:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
ffffffe00020032c:	c01027f3          	rdtime	a5
ffffffe000200330:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
ffffffe000200334:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200338:	00078513          	mv	a0,a5
ffffffe00020033c:	01813403          	ld	s0,24(sp)
ffffffe000200340:	02010113          	addi	sp,sp,32
ffffffe000200344:	00008067          	ret

ffffffe000200348 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200348:	fe010113          	addi	sp,sp,-32
ffffffe00020034c:	00113c23          	sd	ra,24(sp)
ffffffe000200350:	00813823          	sd	s0,16(sp)
ffffffe000200354:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200358:	fc9ff0ef          	jal	ra,ffffffe000200320 <get_cycles>
ffffffe00020035c:	00050713          	mv	a4,a0
ffffffe000200360:	00005797          	auipc	a5,0x5
ffffffe000200364:	ca078793          	addi	a5,a5,-864 # ffffffe000205000 <TIMECLOCK>
ffffffe000200368:	0007b783          	ld	a5,0(a5)
ffffffe00020036c:	00f707b3          	add	a5,a4,a5
ffffffe000200370:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
ffffffe000200374:	fe843503          	ld	a0,-24(s0)
ffffffe000200378:	328010ef          	jal	ra,ffffffe0002016a0 <sbi_set_timer>
ffffffe00020037c:	00000013          	nop
ffffffe000200380:	01813083          	ld	ra,24(sp)
ffffffe000200384:	01013403          	ld	s0,16(sp)
ffffffe000200388:	02010113          	addi	sp,sp,32
ffffffe00020038c:	00008067          	ret

ffffffe000200390 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200390:	fe010113          	addi	sp,sp,-32
ffffffe000200394:	00813c23          	sd	s0,24(sp)
ffffffe000200398:	02010413          	addi	s0,sp,32
ffffffe00020039c:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe0002003a0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003a4:	fff78793          	addi	a5,a5,-1
ffffffe0002003a8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe0002003ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b0:	0017d793          	srli	a5,a5,0x1
ffffffe0002003b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003b8:	00f767b3          	or	a5,a4,a5
ffffffe0002003bc:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe0002003c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003c4:	0027d793          	srli	a5,a5,0x2
ffffffe0002003c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002003cc:	00f767b3          	or	a5,a4,a5
ffffffe0002003d0:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe0002003d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003d8:	0047d793          	srli	a5,a5,0x4
ffffffe0002003dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e0:	00f767b3          	or	a5,a4,a5
ffffffe0002003e4:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe0002003e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003ec:	0087d793          	srli	a5,a5,0x8
ffffffe0002003f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f4:	00f767b3          	or	a5,a4,a5
ffffffe0002003f8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe0002003fc:	fe843783          	ld	a5,-24(s0)
ffffffe000200400:	0107d793          	srli	a5,a5,0x10
ffffffe000200404:	fe843703          	ld	a4,-24(s0)
ffffffe000200408:	00f767b3          	or	a5,a4,a5
ffffffe00020040c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe000200410:	fe843783          	ld	a5,-24(s0)
ffffffe000200414:	0207d793          	srli	a5,a5,0x20
ffffffe000200418:	fe843703          	ld	a4,-24(s0)
ffffffe00020041c:	00f767b3          	or	a5,a4,a5
ffffffe000200420:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe000200424:	fe843783          	ld	a5,-24(s0)
ffffffe000200428:	00178793          	addi	a5,a5,1
}
ffffffe00020042c:	00078513          	mv	a0,a5
ffffffe000200430:	01813403          	ld	s0,24(sp)
ffffffe000200434:	02010113          	addi	sp,sp,32
ffffffe000200438:	00008067          	ret

ffffffe00020043c <buddy_init>:

void buddy_init() {
ffffffe00020043c:	fd010113          	addi	sp,sp,-48
ffffffe000200440:	02113423          	sd	ra,40(sp)
ffffffe000200444:	02813023          	sd	s0,32(sp)
ffffffe000200448:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe00020044c:	000087b7          	lui	a5,0x8
ffffffe000200450:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe000200454:	fe843783          	ld	a5,-24(s0)
ffffffe000200458:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe00020045c:	fe843783          	ld	a5,-24(s0)
ffffffe000200460:	00f777b3          	and	a5,a4,a5
ffffffe000200464:	00078863          	beqz	a5,ffffffe000200474 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe000200468:	fe843503          	ld	a0,-24(s0)
ffffffe00020046c:	f25ff0ef          	jal	ra,ffffffe000200390 <fixsize>
ffffffe000200470:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe000200474:	00009797          	auipc	a5,0x9
ffffffe000200478:	b9c78793          	addi	a5,a5,-1124 # ffffffe000209010 <buddy>
ffffffe00020047c:	fe843703          	ld	a4,-24(s0)
ffffffe000200480:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200484:	00005797          	auipc	a5,0x5
ffffffe000200488:	b8478793          	addi	a5,a5,-1148 # ffffffe000205008 <free_page_start>
ffffffe00020048c:	0007b703          	ld	a4,0(a5)
ffffffe000200490:	00009797          	auipc	a5,0x9
ffffffe000200494:	b8078793          	addi	a5,a5,-1152 # ffffffe000209010 <buddy>
ffffffe000200498:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe00020049c:	00005797          	auipc	a5,0x5
ffffffe0002004a0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000205008 <free_page_start>
ffffffe0002004a4:	0007b703          	ld	a4,0(a5)
ffffffe0002004a8:	00009797          	auipc	a5,0x9
ffffffe0002004ac:	b6878793          	addi	a5,a5,-1176 # ffffffe000209010 <buddy>
ffffffe0002004b0:	0007b783          	ld	a5,0(a5)
ffffffe0002004b4:	00479793          	slli	a5,a5,0x4
ffffffe0002004b8:	00f70733          	add	a4,a4,a5
ffffffe0002004bc:	00005797          	auipc	a5,0x5
ffffffe0002004c0:	b4c78793          	addi	a5,a5,-1204 # ffffffe000205008 <free_page_start>
ffffffe0002004c4:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe0002004c8:	00009797          	auipc	a5,0x9
ffffffe0002004cc:	b4878793          	addi	a5,a5,-1208 # ffffffe000209010 <buddy>
ffffffe0002004d0:	0087b703          	ld	a4,8(a5)
ffffffe0002004d4:	00009797          	auipc	a5,0x9
ffffffe0002004d8:	b3c78793          	addi	a5,a5,-1220 # ffffffe000209010 <buddy>
ffffffe0002004dc:	0007b783          	ld	a5,0(a5)
ffffffe0002004e0:	00479793          	slli	a5,a5,0x4
ffffffe0002004e4:	00078613          	mv	a2,a5
ffffffe0002004e8:	00000593          	li	a1,0
ffffffe0002004ec:	00070513          	mv	a0,a4
ffffffe0002004f0:	2e5020ef          	jal	ra,ffffffe000202fd4 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe0002004f4:	00009797          	auipc	a5,0x9
ffffffe0002004f8:	b1c78793          	addi	a5,a5,-1252 # ffffffe000209010 <buddy>
ffffffe0002004fc:	0007b783          	ld	a5,0(a5)
ffffffe000200500:	00179793          	slli	a5,a5,0x1
ffffffe000200504:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200508:	fc043c23          	sd	zero,-40(s0)
ffffffe00020050c:	0500006f          	j	ffffffe00020055c <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe000200510:	fd843783          	ld	a5,-40(s0)
ffffffe000200514:	00178713          	addi	a4,a5,1
ffffffe000200518:	fd843783          	ld	a5,-40(s0)
ffffffe00020051c:	00f777b3          	and	a5,a4,a5
ffffffe000200520:	00079863          	bnez	a5,ffffffe000200530 <buddy_init+0xf4>
            node_size /= 2;
ffffffe000200524:	fe043783          	ld	a5,-32(s0)
ffffffe000200528:	0017d793          	srli	a5,a5,0x1
ffffffe00020052c:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe000200530:	00009797          	auipc	a5,0x9
ffffffe000200534:	ae078793          	addi	a5,a5,-1312 # ffffffe000209010 <buddy>
ffffffe000200538:	0087b703          	ld	a4,8(a5)
ffffffe00020053c:	fd843783          	ld	a5,-40(s0)
ffffffe000200540:	00379793          	slli	a5,a5,0x3
ffffffe000200544:	00f707b3          	add	a5,a4,a5
ffffffe000200548:	fe043703          	ld	a4,-32(s0)
ffffffe00020054c:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200550:	fd843783          	ld	a5,-40(s0)
ffffffe000200554:	00178793          	addi	a5,a5,1
ffffffe000200558:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020055c:	00009797          	auipc	a5,0x9
ffffffe000200560:	ab478793          	addi	a5,a5,-1356 # ffffffe000209010 <buddy>
ffffffe000200564:	0007b783          	ld	a5,0(a5)
ffffffe000200568:	00179793          	slli	a5,a5,0x1
ffffffe00020056c:	fff78793          	addi	a5,a5,-1
ffffffe000200570:	fd843703          	ld	a4,-40(s0)
ffffffe000200574:	f8f76ee3          	bltu	a4,a5,ffffffe000200510 <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200578:	fc043823          	sd	zero,-48(s0)
ffffffe00020057c:	0180006f          	j	ffffffe000200594 <buddy_init+0x158>
        buddy_alloc(1);
ffffffe000200580:	00100513          	li	a0,1
ffffffe000200584:	1fc000ef          	jal	ra,ffffffe000200780 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200588:	fd043783          	ld	a5,-48(s0)
ffffffe00020058c:	00178793          	addi	a5,a5,1
ffffffe000200590:	fcf43823          	sd	a5,-48(s0)
ffffffe000200594:	fd043783          	ld	a5,-48(s0)
ffffffe000200598:	00c79713          	slli	a4,a5,0xc
ffffffe00020059c:	00100793          	li	a5,1
ffffffe0002005a0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005a4:	00f70733          	add	a4,a4,a5
ffffffe0002005a8:	00005797          	auipc	a5,0x5
ffffffe0002005ac:	a6078793          	addi	a5,a5,-1440 # ffffffe000205008 <free_page_start>
ffffffe0002005b0:	0007b783          	ld	a5,0(a5)
ffffffe0002005b4:	00078693          	mv	a3,a5
ffffffe0002005b8:	04100793          	li	a5,65
ffffffe0002005bc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005c0:	00f687b3          	add	a5,a3,a5
ffffffe0002005c4:	faf76ee3          	bltu	a4,a5,ffffffe000200580 <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe0002005c8:	00004517          	auipc	a0,0x4
ffffffe0002005cc:	a3850513          	addi	a0,a0,-1480 # ffffffe000204000 <_srodata>
ffffffe0002005d0:	0e5020ef          	jal	ra,ffffffe000202eb4 <printk>
    return;
ffffffe0002005d4:	00000013          	nop
}
ffffffe0002005d8:	02813083          	ld	ra,40(sp)
ffffffe0002005dc:	02013403          	ld	s0,32(sp)
ffffffe0002005e0:	03010113          	addi	sp,sp,48
ffffffe0002005e4:	00008067          	ret

ffffffe0002005e8 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe0002005e8:	fc010113          	addi	sp,sp,-64
ffffffe0002005ec:	02813c23          	sd	s0,56(sp)
ffffffe0002005f0:	04010413          	addi	s0,sp,64
ffffffe0002005f4:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe0002005f8:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe0002005fc:	00100793          	li	a5,1
ffffffe000200600:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe000200604:	00009797          	auipc	a5,0x9
ffffffe000200608:	a0c78793          	addi	a5,a5,-1524 # ffffffe000209010 <buddy>
ffffffe00020060c:	0007b703          	ld	a4,0(a5)
ffffffe000200610:	fc843783          	ld	a5,-56(s0)
ffffffe000200614:	00f707b3          	add	a5,a4,a5
ffffffe000200618:	fff78793          	addi	a5,a5,-1
ffffffe00020061c:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200620:	02c0006f          	j	ffffffe00020064c <buddy_free+0x64>
        node_size *= 2;
ffffffe000200624:	fe843783          	ld	a5,-24(s0)
ffffffe000200628:	00179793          	slli	a5,a5,0x1
ffffffe00020062c:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe000200630:	fe043783          	ld	a5,-32(s0)
ffffffe000200634:	02078e63          	beqz	a5,ffffffe000200670 <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200638:	fe043783          	ld	a5,-32(s0)
ffffffe00020063c:	00178793          	addi	a5,a5,1
ffffffe000200640:	0017d793          	srli	a5,a5,0x1
ffffffe000200644:	fff78793          	addi	a5,a5,-1
ffffffe000200648:	fef43023          	sd	a5,-32(s0)
ffffffe00020064c:	00009797          	auipc	a5,0x9
ffffffe000200650:	9c478793          	addi	a5,a5,-1596 # ffffffe000209010 <buddy>
ffffffe000200654:	0087b703          	ld	a4,8(a5)
ffffffe000200658:	fe043783          	ld	a5,-32(s0)
ffffffe00020065c:	00379793          	slli	a5,a5,0x3
ffffffe000200660:	00f707b3          	add	a5,a4,a5
ffffffe000200664:	0007b783          	ld	a5,0(a5)
ffffffe000200668:	fa079ee3          	bnez	a5,ffffffe000200624 <buddy_free+0x3c>
ffffffe00020066c:	0080006f          	j	ffffffe000200674 <buddy_free+0x8c>
            break;
ffffffe000200670:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe000200674:	00009797          	auipc	a5,0x9
ffffffe000200678:	99c78793          	addi	a5,a5,-1636 # ffffffe000209010 <buddy>
ffffffe00020067c:	0087b703          	ld	a4,8(a5)
ffffffe000200680:	fe043783          	ld	a5,-32(s0)
ffffffe000200684:	00379793          	slli	a5,a5,0x3
ffffffe000200688:	00f707b3          	add	a5,a4,a5
ffffffe00020068c:	fe843703          	ld	a4,-24(s0)
ffffffe000200690:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200694:	0d00006f          	j	ffffffe000200764 <buddy_free+0x17c>
        index = PARENT(index);
ffffffe000200698:	fe043783          	ld	a5,-32(s0)
ffffffe00020069c:	00178793          	addi	a5,a5,1
ffffffe0002006a0:	0017d793          	srli	a5,a5,0x1
ffffffe0002006a4:	fff78793          	addi	a5,a5,-1
ffffffe0002006a8:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe0002006ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002006b0:	00179793          	slli	a5,a5,0x1
ffffffe0002006b4:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe0002006b8:	00009797          	auipc	a5,0x9
ffffffe0002006bc:	95878793          	addi	a5,a5,-1704 # ffffffe000209010 <buddy>
ffffffe0002006c0:	0087b703          	ld	a4,8(a5)
ffffffe0002006c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002006c8:	00479793          	slli	a5,a5,0x4
ffffffe0002006cc:	00878793          	addi	a5,a5,8
ffffffe0002006d0:	00f707b3          	add	a5,a4,a5
ffffffe0002006d4:	0007b783          	ld	a5,0(a5)
ffffffe0002006d8:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe0002006dc:	00009797          	auipc	a5,0x9
ffffffe0002006e0:	93478793          	addi	a5,a5,-1740 # ffffffe000209010 <buddy>
ffffffe0002006e4:	0087b703          	ld	a4,8(a5)
ffffffe0002006e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002006ec:	00178793          	addi	a5,a5,1
ffffffe0002006f0:	00479793          	slli	a5,a5,0x4
ffffffe0002006f4:	00f707b3          	add	a5,a4,a5
ffffffe0002006f8:	0007b783          	ld	a5,0(a5)
ffffffe0002006fc:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe000200700:	fd843703          	ld	a4,-40(s0)
ffffffe000200704:	fd043783          	ld	a5,-48(s0)
ffffffe000200708:	00f707b3          	add	a5,a4,a5
ffffffe00020070c:	fe843703          	ld	a4,-24(s0)
ffffffe000200710:	02f71463          	bne	a4,a5,ffffffe000200738 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe000200714:	00009797          	auipc	a5,0x9
ffffffe000200718:	8fc78793          	addi	a5,a5,-1796 # ffffffe000209010 <buddy>
ffffffe00020071c:	0087b703          	ld	a4,8(a5)
ffffffe000200720:	fe043783          	ld	a5,-32(s0)
ffffffe000200724:	00379793          	slli	a5,a5,0x3
ffffffe000200728:	00f707b3          	add	a5,a4,a5
ffffffe00020072c:	fe843703          	ld	a4,-24(s0)
ffffffe000200730:	00e7b023          	sd	a4,0(a5)
ffffffe000200734:	0300006f          	j	ffffffe000200764 <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200738:	00009797          	auipc	a5,0x9
ffffffe00020073c:	8d878793          	addi	a5,a5,-1832 # ffffffe000209010 <buddy>
ffffffe000200740:	0087b703          	ld	a4,8(a5)
ffffffe000200744:	fe043783          	ld	a5,-32(s0)
ffffffe000200748:	00379793          	slli	a5,a5,0x3
ffffffe00020074c:	00f706b3          	add	a3,a4,a5
ffffffe000200750:	fd843703          	ld	a4,-40(s0)
ffffffe000200754:	fd043783          	ld	a5,-48(s0)
ffffffe000200758:	00e7f463          	bgeu	a5,a4,ffffffe000200760 <buddy_free+0x178>
ffffffe00020075c:	00070793          	mv	a5,a4
ffffffe000200760:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200764:	fe043783          	ld	a5,-32(s0)
ffffffe000200768:	f20798e3          	bnez	a5,ffffffe000200698 <buddy_free+0xb0>
    }
}
ffffffe00020076c:	00000013          	nop
ffffffe000200770:	00000013          	nop
ffffffe000200774:	03813403          	ld	s0,56(sp)
ffffffe000200778:	04010113          	addi	sp,sp,64
ffffffe00020077c:	00008067          	ret

ffffffe000200780 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe000200780:	fc010113          	addi	sp,sp,-64
ffffffe000200784:	02113c23          	sd	ra,56(sp)
ffffffe000200788:	02813823          	sd	s0,48(sp)
ffffffe00020078c:	04010413          	addi	s0,sp,64
ffffffe000200790:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe000200794:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200798:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe00020079c:	fc843783          	ld	a5,-56(s0)
ffffffe0002007a0:	00079863          	bnez	a5,ffffffe0002007b0 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe0002007a4:	00100793          	li	a5,1
ffffffe0002007a8:	fcf43423          	sd	a5,-56(s0)
ffffffe0002007ac:	0240006f          	j	ffffffe0002007d0 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe0002007b0:	fc843783          	ld	a5,-56(s0)
ffffffe0002007b4:	fff78713          	addi	a4,a5,-1
ffffffe0002007b8:	fc843783          	ld	a5,-56(s0)
ffffffe0002007bc:	00f777b3          	and	a5,a4,a5
ffffffe0002007c0:	00078863          	beqz	a5,ffffffe0002007d0 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe0002007c4:	fc843503          	ld	a0,-56(s0)
ffffffe0002007c8:	bc9ff0ef          	jal	ra,ffffffe000200390 <fixsize>
ffffffe0002007cc:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe0002007d0:	00009797          	auipc	a5,0x9
ffffffe0002007d4:	84078793          	addi	a5,a5,-1984 # ffffffe000209010 <buddy>
ffffffe0002007d8:	0087b703          	ld	a4,8(a5)
ffffffe0002007dc:	fe843783          	ld	a5,-24(s0)
ffffffe0002007e0:	00379793          	slli	a5,a5,0x3
ffffffe0002007e4:	00f707b3          	add	a5,a4,a5
ffffffe0002007e8:	0007b783          	ld	a5,0(a5)
ffffffe0002007ec:	fc843703          	ld	a4,-56(s0)
ffffffe0002007f0:	00e7f663          	bgeu	a5,a4,ffffffe0002007fc <buddy_alloc+0x7c>
        return 0;
ffffffe0002007f4:	00000793          	li	a5,0
ffffffe0002007f8:	1480006f          	j	ffffffe000200940 <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002007fc:	00009797          	auipc	a5,0x9
ffffffe000200800:	81478793          	addi	a5,a5,-2028 # ffffffe000209010 <buddy>
ffffffe000200804:	0007b783          	ld	a5,0(a5)
ffffffe000200808:	fef43023          	sd	a5,-32(s0)
ffffffe00020080c:	05c0006f          	j	ffffffe000200868 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe000200810:	00009797          	auipc	a5,0x9
ffffffe000200814:	80078793          	addi	a5,a5,-2048 # ffffffe000209010 <buddy>
ffffffe000200818:	0087b703          	ld	a4,8(a5)
ffffffe00020081c:	fe843783          	ld	a5,-24(s0)
ffffffe000200820:	00479793          	slli	a5,a5,0x4
ffffffe000200824:	00878793          	addi	a5,a5,8
ffffffe000200828:	00f707b3          	add	a5,a4,a5
ffffffe00020082c:	0007b783          	ld	a5,0(a5)
ffffffe000200830:	fc843703          	ld	a4,-56(s0)
ffffffe000200834:	00e7ec63          	bltu	a5,a4,ffffffe00020084c <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200838:	fe843783          	ld	a5,-24(s0)
ffffffe00020083c:	00179793          	slli	a5,a5,0x1
ffffffe000200840:	00178793          	addi	a5,a5,1
ffffffe000200844:	fef43423          	sd	a5,-24(s0)
ffffffe000200848:	0140006f          	j	ffffffe00020085c <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe00020084c:	fe843783          	ld	a5,-24(s0)
ffffffe000200850:	00178793          	addi	a5,a5,1
ffffffe000200854:	00179793          	slli	a5,a5,0x1
ffffffe000200858:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe00020085c:	fe043783          	ld	a5,-32(s0)
ffffffe000200860:	0017d793          	srli	a5,a5,0x1
ffffffe000200864:	fef43023          	sd	a5,-32(s0)
ffffffe000200868:	fe043703          	ld	a4,-32(s0)
ffffffe00020086c:	fc843783          	ld	a5,-56(s0)
ffffffe000200870:	faf710e3          	bne	a4,a5,ffffffe000200810 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe000200874:	00008797          	auipc	a5,0x8
ffffffe000200878:	79c78793          	addi	a5,a5,1948 # ffffffe000209010 <buddy>
ffffffe00020087c:	0087b703          	ld	a4,8(a5)
ffffffe000200880:	fe843783          	ld	a5,-24(s0)
ffffffe000200884:	00379793          	slli	a5,a5,0x3
ffffffe000200888:	00f707b3          	add	a5,a4,a5
ffffffe00020088c:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200890:	fe843783          	ld	a5,-24(s0)
ffffffe000200894:	00178713          	addi	a4,a5,1
ffffffe000200898:	fe043783          	ld	a5,-32(s0)
ffffffe00020089c:	02f70733          	mul	a4,a4,a5
ffffffe0002008a0:	00008797          	auipc	a5,0x8
ffffffe0002008a4:	77078793          	addi	a5,a5,1904 # ffffffe000209010 <buddy>
ffffffe0002008a8:	0007b783          	ld	a5,0(a5)
ffffffe0002008ac:	40f707b3          	sub	a5,a4,a5
ffffffe0002008b0:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe0002008b4:	0800006f          	j	ffffffe000200934 <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe0002008b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002008bc:	00178793          	addi	a5,a5,1
ffffffe0002008c0:	0017d793          	srli	a5,a5,0x1
ffffffe0002008c4:	fff78793          	addi	a5,a5,-1
ffffffe0002008c8:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008cc:	00008797          	auipc	a5,0x8
ffffffe0002008d0:	74478793          	addi	a5,a5,1860 # ffffffe000209010 <buddy>
ffffffe0002008d4:	0087b703          	ld	a4,8(a5)
ffffffe0002008d8:	fe843783          	ld	a5,-24(s0)
ffffffe0002008dc:	00178793          	addi	a5,a5,1
ffffffe0002008e0:	00479793          	slli	a5,a5,0x4
ffffffe0002008e4:	00f707b3          	add	a5,a4,a5
ffffffe0002008e8:	0007b603          	ld	a2,0(a5)
ffffffe0002008ec:	00008797          	auipc	a5,0x8
ffffffe0002008f0:	72478793          	addi	a5,a5,1828 # ffffffe000209010 <buddy>
ffffffe0002008f4:	0087b703          	ld	a4,8(a5)
ffffffe0002008f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002008fc:	00479793          	slli	a5,a5,0x4
ffffffe000200900:	00878793          	addi	a5,a5,8
ffffffe000200904:	00f707b3          	add	a5,a4,a5
ffffffe000200908:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe00020090c:	00008797          	auipc	a5,0x8
ffffffe000200910:	70478793          	addi	a5,a5,1796 # ffffffe000209010 <buddy>
ffffffe000200914:	0087b683          	ld	a3,8(a5)
ffffffe000200918:	fe843783          	ld	a5,-24(s0)
ffffffe00020091c:	00379793          	slli	a5,a5,0x3
ffffffe000200920:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200924:	00060793          	mv	a5,a2
ffffffe000200928:	00e7f463          	bgeu	a5,a4,ffffffe000200930 <buddy_alloc+0x1b0>
ffffffe00020092c:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200930:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200934:	fe843783          	ld	a5,-24(s0)
ffffffe000200938:	f80790e3          	bnez	a5,ffffffe0002008b8 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe00020093c:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200940:	00078513          	mv	a0,a5
ffffffe000200944:	03813083          	ld	ra,56(sp)
ffffffe000200948:	03013403          	ld	s0,48(sp)
ffffffe00020094c:	04010113          	addi	sp,sp,64
ffffffe000200950:	00008067          	ret

ffffffe000200954 <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe000200954:	fd010113          	addi	sp,sp,-48
ffffffe000200958:	02113423          	sd	ra,40(sp)
ffffffe00020095c:	02813023          	sd	s0,32(sp)
ffffffe000200960:	03010413          	addi	s0,sp,48
ffffffe000200964:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200968:	fd843503          	ld	a0,-40(s0)
ffffffe00020096c:	e15ff0ef          	jal	ra,ffffffe000200780 <buddy_alloc>
ffffffe000200970:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200974:	fe843783          	ld	a5,-24(s0)
ffffffe000200978:	00079663          	bnez	a5,ffffffe000200984 <alloc_pages+0x30>
        return 0;
ffffffe00020097c:	00000793          	li	a5,0
ffffffe000200980:	0180006f          	j	ffffffe000200998 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200984:	fe843783          	ld	a5,-24(s0)
ffffffe000200988:	00c79713          	slli	a4,a5,0xc
ffffffe00020098c:	fff00793          	li	a5,-1
ffffffe000200990:	02579793          	slli	a5,a5,0x25
ffffffe000200994:	00f707b3          	add	a5,a4,a5
}
ffffffe000200998:	00078513          	mv	a0,a5
ffffffe00020099c:	02813083          	ld	ra,40(sp)
ffffffe0002009a0:	02013403          	ld	s0,32(sp)
ffffffe0002009a4:	03010113          	addi	sp,sp,48
ffffffe0002009a8:	00008067          	ret

ffffffe0002009ac <alloc_page>:

void *alloc_page() {
ffffffe0002009ac:	ff010113          	addi	sp,sp,-16
ffffffe0002009b0:	00113423          	sd	ra,8(sp)
ffffffe0002009b4:	00813023          	sd	s0,0(sp)
ffffffe0002009b8:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe0002009bc:	00100513          	li	a0,1
ffffffe0002009c0:	f95ff0ef          	jal	ra,ffffffe000200954 <alloc_pages>
ffffffe0002009c4:	00050793          	mv	a5,a0
}
ffffffe0002009c8:	00078513          	mv	a0,a5
ffffffe0002009cc:	00813083          	ld	ra,8(sp)
ffffffe0002009d0:	00013403          	ld	s0,0(sp)
ffffffe0002009d4:	01010113          	addi	sp,sp,16
ffffffe0002009d8:	00008067          	ret

ffffffe0002009dc <free_pages>:

void free_pages(void *va) {
ffffffe0002009dc:	fe010113          	addi	sp,sp,-32
ffffffe0002009e0:	00113c23          	sd	ra,24(sp)
ffffffe0002009e4:	00813823          	sd	s0,16(sp)
ffffffe0002009e8:	02010413          	addi	s0,sp,32
ffffffe0002009ec:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe0002009f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002009f4:	00100793          	li	a5,1
ffffffe0002009f8:	02579793          	slli	a5,a5,0x25
ffffffe0002009fc:	00f707b3          	add	a5,a4,a5
ffffffe000200a00:	00c7d793          	srli	a5,a5,0xc
ffffffe000200a04:	00078513          	mv	a0,a5
ffffffe000200a08:	be1ff0ef          	jal	ra,ffffffe0002005e8 <buddy_free>
}
ffffffe000200a0c:	00000013          	nop
ffffffe000200a10:	01813083          	ld	ra,24(sp)
ffffffe000200a14:	01013403          	ld	s0,16(sp)
ffffffe000200a18:	02010113          	addi	sp,sp,32
ffffffe000200a1c:	00008067          	ret

ffffffe000200a20 <kalloc>:

void *kalloc() {
ffffffe000200a20:	ff010113          	addi	sp,sp,-16
ffffffe000200a24:	00113423          	sd	ra,8(sp)
ffffffe000200a28:	00813023          	sd	s0,0(sp)
ffffffe000200a2c:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200a30:	f7dff0ef          	jal	ra,ffffffe0002009ac <alloc_page>
ffffffe000200a34:	00050793          	mv	a5,a0
}
ffffffe000200a38:	00078513          	mv	a0,a5
ffffffe000200a3c:	00813083          	ld	ra,8(sp)
ffffffe000200a40:	00013403          	ld	s0,0(sp)
ffffffe000200a44:	01010113          	addi	sp,sp,16
ffffffe000200a48:	00008067          	ret

ffffffe000200a4c <kfree>:

void kfree(void *addr) {
ffffffe000200a4c:	fe010113          	addi	sp,sp,-32
ffffffe000200a50:	00113c23          	sd	ra,24(sp)
ffffffe000200a54:	00813823          	sd	s0,16(sp)
ffffffe000200a58:	02010413          	addi	s0,sp,32
ffffffe000200a5c:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200a60:	fe843503          	ld	a0,-24(s0)
ffffffe000200a64:	f79ff0ef          	jal	ra,ffffffe0002009dc <free_pages>

    return;
ffffffe000200a68:	00000013          	nop
}
ffffffe000200a6c:	01813083          	ld	ra,24(sp)
ffffffe000200a70:	01013403          	ld	s0,16(sp)
ffffffe000200a74:	02010113          	addi	sp,sp,32
ffffffe000200a78:	00008067          	ret

ffffffe000200a7c <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200a7c:	fd010113          	addi	sp,sp,-48
ffffffe000200a80:	02113423          	sd	ra,40(sp)
ffffffe000200a84:	02813023          	sd	s0,32(sp)
ffffffe000200a88:	03010413          	addi	s0,sp,48
ffffffe000200a8c:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a90:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a94:	fd843703          	ld	a4,-40(s0)
ffffffe000200a98:	000017b7          	lui	a5,0x1
ffffffe000200a9c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200aa0:	00f70733          	add	a4,a4,a5
ffffffe000200aa4:	fffff7b7          	lui	a5,0xfffff
ffffffe000200aa8:	00f777b3          	and	a5,a4,a5
ffffffe000200aac:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200ab0:	01c0006f          	j	ffffffe000200acc <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200ab4:	fe843503          	ld	a0,-24(s0)
ffffffe000200ab8:	f95ff0ef          	jal	ra,ffffffe000200a4c <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200abc:	fe843703          	ld	a4,-24(s0)
ffffffe000200ac0:	000017b7          	lui	a5,0x1
ffffffe000200ac4:	00f707b3          	add	a5,a4,a5
ffffffe000200ac8:	fef43423          	sd	a5,-24(s0)
ffffffe000200acc:	fe843703          	ld	a4,-24(s0)
ffffffe000200ad0:	000017b7          	lui	a5,0x1
ffffffe000200ad4:	00f70733          	add	a4,a4,a5
ffffffe000200ad8:	fd043783          	ld	a5,-48(s0)
ffffffe000200adc:	fce7fce3          	bgeu	a5,a4,ffffffe000200ab4 <kfreerange+0x38>
    }
}
ffffffe000200ae0:	00000013          	nop
ffffffe000200ae4:	00000013          	nop
ffffffe000200ae8:	02813083          	ld	ra,40(sp)
ffffffe000200aec:	02013403          	ld	s0,32(sp)
ffffffe000200af0:	03010113          	addi	sp,sp,48
ffffffe000200af4:	00008067          	ret

ffffffe000200af8 <mm_init>:

void mm_init(void) {
ffffffe000200af8:	ff010113          	addi	sp,sp,-16
ffffffe000200afc:	00113423          	sd	ra,8(sp)
ffffffe000200b00:	00813023          	sd	s0,0(sp)
ffffffe000200b04:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200b08:	935ff0ef          	jal	ra,ffffffe00020043c <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200b0c:	00003517          	auipc	a0,0x3
ffffffe000200b10:	50c50513          	addi	a0,a0,1292 # ffffffe000204018 <_srodata+0x18>
ffffffe000200b14:	3a0020ef          	jal	ra,ffffffe000202eb4 <printk>
}
ffffffe000200b18:	00000013          	nop
ffffffe000200b1c:	00813083          	ld	ra,8(sp)
ffffffe000200b20:	00013403          	ld	s0,0(sp)
ffffffe000200b24:	01010113          	addi	sp,sp,16
ffffffe000200b28:	00008067          	ret

ffffffe000200b2c <memcpy>:

// upaa 起始结束地址
extern char _sramdisk[];
extern char _eramdisk[];

void memcpy(void *dest,void *src, size_t n) {
ffffffe000200b2c:	fb010113          	addi	sp,sp,-80
ffffffe000200b30:	04813423          	sd	s0,72(sp)
ffffffe000200b34:	05010413          	addi	s0,sp,80
ffffffe000200b38:	fca43423          	sd	a0,-56(s0)
ffffffe000200b3c:	fcb43023          	sd	a1,-64(s0)
ffffffe000200b40:	fac43c23          	sd	a2,-72(s0)
    char *d = (char *)dest;
ffffffe000200b44:	fc843783          	ld	a5,-56(s0)
ffffffe000200b48:	fef43023          	sd	a5,-32(s0)
    char *s = (char *)src;
ffffffe000200b4c:	fc043783          	ld	a5,-64(s0)
ffffffe000200b50:	fcf43c23          	sd	a5,-40(s0)
    for (size_t i = 0; i < n; i++) {
ffffffe000200b54:	fe043423          	sd	zero,-24(s0)
ffffffe000200b58:	0300006f          	j	ffffffe000200b88 <memcpy+0x5c>
        d[i] = s[i];
ffffffe000200b5c:	fd843703          	ld	a4,-40(s0)
ffffffe000200b60:	fe843783          	ld	a5,-24(s0)
ffffffe000200b64:	00f70733          	add	a4,a4,a5
ffffffe000200b68:	fe043683          	ld	a3,-32(s0)
ffffffe000200b6c:	fe843783          	ld	a5,-24(s0)
ffffffe000200b70:	00f687b3          	add	a5,a3,a5
ffffffe000200b74:	00074703          	lbu	a4,0(a4)
ffffffe000200b78:	00e78023          	sb	a4,0(a5) # 1000 <PGSIZE>
    for (size_t i = 0; i < n; i++) {
ffffffe000200b7c:	fe843783          	ld	a5,-24(s0)
ffffffe000200b80:	00178793          	addi	a5,a5,1
ffffffe000200b84:	fef43423          	sd	a5,-24(s0)
ffffffe000200b88:	fe843703          	ld	a4,-24(s0)
ffffffe000200b8c:	fb843783          	ld	a5,-72(s0)
ffffffe000200b90:	fcf766e3          	bltu	a4,a5,ffffffe000200b5c <memcpy+0x30>
    }
}
ffffffe000200b94:	00000013          	nop
ffffffe000200b98:	00000013          	nop
ffffffe000200b9c:	04813403          	ld	s0,72(sp)
ffffffe000200ba0:	05010113          	addi	sp,sp,80
ffffffe000200ba4:	00008067          	ret

ffffffe000200ba8 <load_program>:

void load_program(struct task_struct *task){
ffffffe000200ba8:	fa010113          	addi	sp,sp,-96
ffffffe000200bac:	04113c23          	sd	ra,88(sp)
ffffffe000200bb0:	04813823          	sd	s0,80(sp)
ffffffe000200bb4:	06010413          	addi	s0,sp,96
ffffffe000200bb8:	faa43423          	sd	a0,-88(s0)
    Elf64_Ehdr *ehdr=(Elf64_Ehdr *)_sramdisk;
ffffffe000200bbc:	00005797          	auipc	a5,0x5
ffffffe000200bc0:	44478793          	addi	a5,a5,1092 # ffffffe000206000 <_sramdisk>
ffffffe000200bc4:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs=(Elf64_Phdr *)(_sramdisk+ehdr->e_phoff);
ffffffe000200bc8:	fd843783          	ld	a5,-40(s0)
ffffffe000200bcc:	0207b703          	ld	a4,32(a5)
ffffffe000200bd0:	00005797          	auipc	a5,0x5
ffffffe000200bd4:	43078793          	addi	a5,a5,1072 # ffffffe000206000 <_sramdisk>
ffffffe000200bd8:	00f707b3          	add	a5,a4,a5
ffffffe000200bdc:	fcf43823          	sd	a5,-48(s0)
    //偏移
    uint64_t offset=ehdr->e_entry-(ehdr->e_entry & ~(PGSIZE - 1));
ffffffe000200be0:	fd843783          	ld	a5,-40(s0)
ffffffe000200be4:	0187b703          	ld	a4,24(a5)
ffffffe000200be8:	000017b7          	lui	a5,0x1
ffffffe000200bec:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200bf0:	00f777b3          	and	a5,a4,a5
ffffffe000200bf4:	fcf43423          	sd	a5,-56(s0)
    for(int i=0;i<ehdr->e_phnum;i++){
ffffffe000200bf8:	fe042623          	sw	zero,-20(s0)
ffffffe000200bfc:	1440006f          	j	ffffffe000200d40 <load_program+0x198>
        Elf64_Phdr *phdr=phdrs+i;
ffffffe000200c00:	fec42703          	lw	a4,-20(s0)
ffffffe000200c04:	00070793          	mv	a5,a4
ffffffe000200c08:	00379793          	slli	a5,a5,0x3
ffffffe000200c0c:	40e787b3          	sub	a5,a5,a4
ffffffe000200c10:	00379793          	slli	a5,a5,0x3
ffffffe000200c14:	00078713          	mv	a4,a5
ffffffe000200c18:	fd043783          	ld	a5,-48(s0)
ffffffe000200c1c:	00e787b3          	add	a5,a5,a4
ffffffe000200c20:	fcf43023          	sd	a5,-64(s0)
        if(phdr->p_type==PT_LOAD){//只关注 type 为 LOAD 的 segment
ffffffe000200c24:	fc043783          	ld	a5,-64(s0)
ffffffe000200c28:	0007a783          	lw	a5,0(a5)
ffffffe000200c2c:	00078713          	mv	a4,a5
ffffffe000200c30:	00100793          	li	a5,1
ffffffe000200c34:	10f71063          	bne	a4,a5,ffffffe000200d34 <load_program+0x18c>
             //分配内存
            size_t num_pages=(phdr->p_memsz+PGSIZE-1)/PGSIZE;
ffffffe000200c38:	fc043783          	ld	a5,-64(s0)
ffffffe000200c3c:	0287b703          	ld	a4,40(a5)
ffffffe000200c40:	000017b7          	lui	a5,0x1
ffffffe000200c44:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200c48:	00f707b3          	add	a5,a4,a5
ffffffe000200c4c:	00c7d793          	srli	a5,a5,0xc
ffffffe000200c50:	faf43c23          	sd	a5,-72(s0)
            void *pa_mem=alloc_pages(num_pages); 
ffffffe000200c54:	fb843503          	ld	a0,-72(s0)
ffffffe000200c58:	cfdff0ef          	jal	ra,ffffffe000200954 <alloc_pages>
ffffffe000200c5c:	faa43823          	sd	a0,-80(s0)
            //复制
            memcpy(pa_mem+offset,_sramdisk+phdr->p_offset,phdr->p_filesz);
ffffffe000200c60:	fb043703          	ld	a4,-80(s0)
ffffffe000200c64:	fc843783          	ld	a5,-56(s0)
ffffffe000200c68:	00f706b3          	add	a3,a4,a5
ffffffe000200c6c:	fc043783          	ld	a5,-64(s0)
ffffffe000200c70:	0087b703          	ld	a4,8(a5)
ffffffe000200c74:	00005797          	auipc	a5,0x5
ffffffe000200c78:	38c78793          	addi	a5,a5,908 # ffffffe000206000 <_sramdisk>
ffffffe000200c7c:	00f70733          	add	a4,a4,a5
ffffffe000200c80:	fc043783          	ld	a5,-64(s0)
ffffffe000200c84:	0207b783          	ld	a5,32(a5)
ffffffe000200c88:	00078613          	mv	a2,a5
ffffffe000200c8c:	00070593          	mv	a1,a4
ffffffe000200c90:	00068513          	mv	a0,a3
ffffffe000200c94:	e99ff0ef          	jal	ra,ffffffe000200b2c <memcpy>
            //映射
            uint64_t perm=PTE_V|PTE_U;//权限
ffffffe000200c98:	01100793          	li	a5,17
ffffffe000200c9c:	fef43023          	sd	a5,-32(s0)
            if(phdr->p_flags&PF_R) perm|=PTE_R;
ffffffe000200ca0:	fc043783          	ld	a5,-64(s0)
ffffffe000200ca4:	0047a783          	lw	a5,4(a5)
ffffffe000200ca8:	0047f793          	andi	a5,a5,4
ffffffe000200cac:	0007879b          	sext.w	a5,a5
ffffffe000200cb0:	00078863          	beqz	a5,ffffffe000200cc0 <load_program+0x118>
ffffffe000200cb4:	fe043783          	ld	a5,-32(s0)
ffffffe000200cb8:	0027e793          	ori	a5,a5,2
ffffffe000200cbc:	fef43023          	sd	a5,-32(s0)
            if(phdr->p_flags&PF_W) perm|=PTE_W;
ffffffe000200cc0:	fc043783          	ld	a5,-64(s0)
ffffffe000200cc4:	0047a783          	lw	a5,4(a5)
ffffffe000200cc8:	0027f793          	andi	a5,a5,2
ffffffe000200ccc:	0007879b          	sext.w	a5,a5
ffffffe000200cd0:	00078863          	beqz	a5,ffffffe000200ce0 <load_program+0x138>
ffffffe000200cd4:	fe043783          	ld	a5,-32(s0)
ffffffe000200cd8:	0047e793          	ori	a5,a5,4
ffffffe000200cdc:	fef43023          	sd	a5,-32(s0)
            if(phdr->p_flags&PF_X) perm|=PTE_X;
ffffffe000200ce0:	fc043783          	ld	a5,-64(s0)
ffffffe000200ce4:	0047a783          	lw	a5,4(a5)
ffffffe000200ce8:	0017f793          	andi	a5,a5,1
ffffffe000200cec:	0007879b          	sext.w	a5,a5
ffffffe000200cf0:	00078863          	beqz	a5,ffffffe000200d00 <load_program+0x158>
ffffffe000200cf4:	fe043783          	ld	a5,-32(s0)
ffffffe000200cf8:	0087e793          	ori	a5,a5,8
ffffffe000200cfc:	fef43023          	sd	a5,-32(s0)

            
            create_mapping(task->pgd,phdr->p_vaddr,VA2PA((uint64_t)pa_mem),num_pages*PGSIZE,perm);
ffffffe000200d00:	fa843783          	ld	a5,-88(s0)
ffffffe000200d04:	0b07b503          	ld	a0,176(a5)
ffffffe000200d08:	fc043783          	ld	a5,-64(s0)
ffffffe000200d0c:	0107b583          	ld	a1,16(a5)
ffffffe000200d10:	fb043703          	ld	a4,-80(s0)
ffffffe000200d14:	04100793          	li	a5,65
ffffffe000200d18:	01f79793          	slli	a5,a5,0x1f
ffffffe000200d1c:	00f70633          	add	a2,a4,a5
ffffffe000200d20:	fb843783          	ld	a5,-72(s0)
ffffffe000200d24:	00c79793          	slli	a5,a5,0xc
ffffffe000200d28:	fe043703          	ld	a4,-32(s0)
ffffffe000200d2c:	00078693          	mv	a3,a5
ffffffe000200d30:	631000ef          	jal	ra,ffffffe000201b60 <create_mapping>
    for(int i=0;i<ehdr->e_phnum;i++){
ffffffe000200d34:	fec42783          	lw	a5,-20(s0)
ffffffe000200d38:	0017879b          	addiw	a5,a5,1
ffffffe000200d3c:	fef42623          	sw	a5,-20(s0)
ffffffe000200d40:	fd843783          	ld	a5,-40(s0)
ffffffe000200d44:	0387d783          	lhu	a5,56(a5)
ffffffe000200d48:	0007871b          	sext.w	a4,a5
ffffffe000200d4c:	fec42783          	lw	a5,-20(s0)
ffffffe000200d50:	0007879b          	sext.w	a5,a5
ffffffe000200d54:	eae7c6e3          	blt	a5,a4,ffffffe000200c00 <load_program+0x58>
            
        }
    }
    task->thread.sepc=ehdr->e_entry;
ffffffe000200d58:	fd843783          	ld	a5,-40(s0)
ffffffe000200d5c:	0187b703          	ld	a4,24(a5)
ffffffe000200d60:	fa843783          	ld	a5,-88(s0)
ffffffe000200d64:	08e7bc23          	sd	a4,152(a5)
}
ffffffe000200d68:	00000013          	nop
ffffffe000200d6c:	05813083          	ld	ra,88(sp)
ffffffe000200d70:	05013403          	ld	s0,80(sp)
ffffffe000200d74:	06010113          	addi	sp,sp,96
ffffffe000200d78:	00008067          	ret

ffffffe000200d7c <task_init>:

void task_init() {
ffffffe000200d7c:	fb010113          	addi	sp,sp,-80
ffffffe000200d80:	04113423          	sd	ra,72(sp)
ffffffe000200d84:	04813023          	sd	s0,64(sp)
ffffffe000200d88:	02913c23          	sd	s1,56(sp)
ffffffe000200d8c:	05010413          	addi	s0,sp,80
    srand(2024);
ffffffe000200d90:	7e800513          	li	a0,2024
ffffffe000200d94:	1a0020ef          	jal	ra,ffffffe000202f34 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
ffffffe000200d98:	c89ff0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe000200d9c:	00050713          	mv	a4,a0
ffffffe000200da0:	0000a797          	auipc	a5,0xa
ffffffe000200da4:	26078793          	addi	a5,a5,608 # ffffffe00020b000 <idle>
ffffffe000200da8:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200dac:	0000a797          	auipc	a5,0xa
ffffffe000200db0:	25478793          	addi	a5,a5,596 # ffffffe00020b000 <idle>
ffffffe000200db4:	0007b783          	ld	a5,0(a5)
ffffffe000200db8:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200dbc:	0000a797          	auipc	a5,0xa
ffffffe000200dc0:	24478793          	addi	a5,a5,580 # ffffffe00020b000 <idle>
ffffffe000200dc4:	0007b783          	ld	a5,0(a5)
ffffffe000200dc8:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200dcc:	0000a797          	auipc	a5,0xa
ffffffe000200dd0:	23478793          	addi	a5,a5,564 # ffffffe00020b000 <idle>
ffffffe000200dd4:	0007b783          	ld	a5,0(a5)
ffffffe000200dd8:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200ddc:	0000a797          	auipc	a5,0xa
ffffffe000200de0:	22478793          	addi	a5,a5,548 # ffffffe00020b000 <idle>
ffffffe000200de4:	0007b783          	ld	a5,0(a5)
ffffffe000200de8:	0007bc23          	sd	zero,24(a5)
    idle->thread.first_schedule=0;
ffffffe000200dec:	0000a797          	auipc	a5,0xa
ffffffe000200df0:	21478793          	addi	a5,a5,532 # ffffffe00020b000 <idle>
ffffffe000200df4:	0007b783          	ld	a5,0(a5)
ffffffe000200df8:	0807b823          	sd	zero,144(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200dfc:	0000a797          	auipc	a5,0xa
ffffffe000200e00:	20478793          	addi	a5,a5,516 # ffffffe00020b000 <idle>
ffffffe000200e04:	0007b703          	ld	a4,0(a5)
ffffffe000200e08:	0000a797          	auipc	a5,0xa
ffffffe000200e0c:	20078793          	addi	a5,a5,512 # ffffffe00020b008 <current>
ffffffe000200e10:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200e14:	0000a797          	auipc	a5,0xa
ffffffe000200e18:	1ec78793          	addi	a5,a5,492 # ffffffe00020b000 <idle>
ffffffe000200e1c:	0007b703          	ld	a4,0(a5)
ffffffe000200e20:	0000a797          	auipc	a5,0xa
ffffffe000200e24:	1f078793          	addi	a5,a5,496 # ffffffe00020b010 <task>
ffffffe000200e28:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    size_t uapp_size=(size_t)(_eramdisk-_sramdisk); // uapp 大小
ffffffe000200e2c:	00007717          	auipc	a4,0x7
ffffffe000200e30:	99c70713          	addi	a4,a4,-1636 # ffffffe0002077c8 <_eramdisk>
ffffffe000200e34:	00005797          	auipc	a5,0x5
ffffffe000200e38:	1cc78793          	addi	a5,a5,460 # ffffffe000206000 <_sramdisk>
ffffffe000200e3c:	40f707b3          	sub	a5,a4,a5
ffffffe000200e40:	fcf43823          	sd	a5,-48(s0)
    size_t num_pages=(uapp_size+PGSIZE-1)/PGSIZE; // uapp 占用页数
ffffffe000200e44:	fd043703          	ld	a4,-48(s0)
ffffffe000200e48:	000017b7          	lui	a5,0x1
ffffffe000200e4c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200e50:	00f707b3          	add	a5,a4,a5
ffffffe000200e54:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e58:	fcf43423          	sd	a5,-56(s0)

    for(int i=1;i<NR_TASKS;i++){
ffffffe000200e5c:	00100793          	li	a5,1
ffffffe000200e60:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200e64:	3380006f          	j	ffffffe00020119c <task_init+0x420>
        task[i]=(struct task_struct *)kalloc();
ffffffe000200e68:	bb9ff0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe000200e6c:	00050693          	mv	a3,a0
ffffffe000200e70:	0000a717          	auipc	a4,0xa
ffffffe000200e74:	1a070713          	addi	a4,a4,416 # ffffffe00020b010 <task>
ffffffe000200e78:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e7c:	00379793          	slli	a5,a5,0x3
ffffffe000200e80:	00f707b3          	add	a5,a4,a5
ffffffe000200e84:	00d7b023          	sd	a3,0(a5)
        memset(task[i],0,sizeof(struct task_struct));
ffffffe000200e88:	0000a717          	auipc	a4,0xa
ffffffe000200e8c:	18870713          	addi	a4,a4,392 # ffffffe00020b010 <task>
ffffffe000200e90:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e94:	00379793          	slli	a5,a5,0x3
ffffffe000200e98:	00f707b3          	add	a5,a4,a5
ffffffe000200e9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ea0:	0b800613          	li	a2,184
ffffffe000200ea4:	00000593          	li	a1,0
ffffffe000200ea8:	00078513          	mv	a0,a5
ffffffe000200eac:	128020ef          	jal	ra,ffffffe000202fd4 <memset>
        task[i]->state=TASK_RUNNING;
ffffffe000200eb0:	0000a717          	auipc	a4,0xa
ffffffe000200eb4:	16070713          	addi	a4,a4,352 # ffffffe00020b010 <task>
ffffffe000200eb8:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ebc:	00379793          	slli	a5,a5,0x3
ffffffe000200ec0:	00f707b3          	add	a5,a4,a5
ffffffe000200ec4:	0007b783          	ld	a5,0(a5)
ffffffe000200ec8:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe000200ecc:	0000a717          	auipc	a4,0xa
ffffffe000200ed0:	14470713          	addi	a4,a4,324 # ffffffe00020b010 <task>
ffffffe000200ed4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ed8:	00379793          	slli	a5,a5,0x3
ffffffe000200edc:	00f707b3          	add	a5,a4,a5
ffffffe000200ee0:	0007b783          	ld	a5,0(a5)
ffffffe000200ee4:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
ffffffe000200ee8:	090020ef          	jal	ra,ffffffe000202f78 <rand>
ffffffe000200eec:	00050793          	mv	a5,a0
ffffffe000200ef0:	00078713          	mv	a4,a5
ffffffe000200ef4:	00a00793          	li	a5,10
ffffffe000200ef8:	02f767bb          	remw	a5,a4,a5
ffffffe000200efc:	0007879b          	sext.w	a5,a5
ffffffe000200f00:	0017879b          	addiw	a5,a5,1
ffffffe000200f04:	0007869b          	sext.w	a3,a5
ffffffe000200f08:	0000a717          	auipc	a4,0xa
ffffffe000200f0c:	10870713          	addi	a4,a4,264 # ffffffe00020b010 <task>
ffffffe000200f10:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f14:	00379793          	slli	a5,a5,0x3
ffffffe000200f18:	00f707b3          	add	a5,a4,a5
ffffffe000200f1c:	0007b783          	ld	a5,0(a5)
ffffffe000200f20:	00068713          	mv	a4,a3
ffffffe000200f24:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe000200f28:	0000a717          	auipc	a4,0xa
ffffffe000200f2c:	0e870713          	addi	a4,a4,232 # ffffffe00020b010 <task>
ffffffe000200f30:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f34:	00379793          	slli	a5,a5,0x3
ffffffe000200f38:	00f707b3          	add	a5,a4,a5
ffffffe000200f3c:	0007b783          	ld	a5,0(a5)
ffffffe000200f40:	fdc42703          	lw	a4,-36(s0)
ffffffe000200f44:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
ffffffe000200f48:	0000a717          	auipc	a4,0xa
ffffffe000200f4c:	0c870713          	addi	a4,a4,200 # ffffffe00020b010 <task>
ffffffe000200f50:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f54:	00379793          	slli	a5,a5,0x3
ffffffe000200f58:	00f707b3          	add	a5,a4,a5
ffffffe000200f5c:	0007b783          	ld	a5,0(a5)
ffffffe000200f60:	fffff717          	auipc	a4,0xfffff
ffffffe000200f64:	2b470713          	addi	a4,a4,692 # ffffffe000200214 <__dummy>
ffffffe000200f68:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe000200f6c:	0000a717          	auipc	a4,0xa
ffffffe000200f70:	0a470713          	addi	a4,a4,164 # ffffffe00020b010 <task>
ffffffe000200f74:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f78:	00379793          	slli	a5,a5,0x3
ffffffe000200f7c:	00f707b3          	add	a5,a4,a5
ffffffe000200f80:	0007b783          	ld	a5,0(a5)
ffffffe000200f84:	00078693          	mv	a3,a5
ffffffe000200f88:	0000a717          	auipc	a4,0xa
ffffffe000200f8c:	08870713          	addi	a4,a4,136 # ffffffe00020b010 <task>
ffffffe000200f90:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f94:	00379793          	slli	a5,a5,0x3
ffffffe000200f98:	00f707b3          	add	a5,a4,a5
ffffffe000200f9c:	0007b783          	ld	a5,0(a5)
ffffffe000200fa0:	00001737          	lui	a4,0x1
ffffffe000200fa4:	00e68733          	add	a4,a3,a4
ffffffe000200fa8:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.first_schedule=1;
ffffffe000200fac:	0000a717          	auipc	a4,0xa
ffffffe000200fb0:	06470713          	addi	a4,a4,100 # ffffffe00020b010 <task>
ffffffe000200fb4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200fb8:	00379793          	slli	a5,a5,0x3
ffffffe000200fbc:	00f707b3          	add	a5,a4,a5
ffffffe000200fc0:	0007b783          	ld	a5,0(a5)
ffffffe000200fc4:	00100713          	li	a4,1
ffffffe000200fc8:	08e7b823          	sd	a4,144(a5)
        // task[i]->thread.sepc=(uint64_t)USER_START;   //将 sepc 设置为 USER_START
        task[i]->thread.sstatus=0;
ffffffe000200fcc:	0000a717          	auipc	a4,0xa
ffffffe000200fd0:	04470713          	addi	a4,a4,68 # ffffffe00020b010 <task>
ffffffe000200fd4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200fd8:	00379793          	slli	a5,a5,0x3
ffffffe000200fdc:	00f707b3          	add	a5,a4,a5
ffffffe000200fe0:	0007b783          	ld	a5,0(a5)
ffffffe000200fe4:	0a07b023          	sd	zero,160(a5)
        task[i]->thread.sstatus&=~(1UL<<8);         //将 SPP 位置 0，使得 sret 返回至 U-Mode
ffffffe000200fe8:	0000a717          	auipc	a4,0xa
ffffffe000200fec:	02870713          	addi	a4,a4,40 # ffffffe00020b010 <task>
ffffffe000200ff0:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ff4:	00379793          	slli	a5,a5,0x3
ffffffe000200ff8:	00f707b3          	add	a5,a4,a5
ffffffe000200ffc:	0007b783          	ld	a5,0(a5)
ffffffe000201000:	0a07b703          	ld	a4,160(a5)
ffffffe000201004:	0000a697          	auipc	a3,0xa
ffffffe000201008:	00c68693          	addi	a3,a3,12 # ffffffe00020b010 <task>
ffffffe00020100c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201010:	00379793          	slli	a5,a5,0x3
ffffffe000201014:	00f687b3          	add	a5,a3,a5
ffffffe000201018:	0007b783          	ld	a5,0(a5)
ffffffe00020101c:	eff77713          	andi	a4,a4,-257
ffffffe000201020:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sstatus|=(1UL<<5);         //将 SPIE 位置 1
ffffffe000201024:	0000a717          	auipc	a4,0xa
ffffffe000201028:	fec70713          	addi	a4,a4,-20 # ffffffe00020b010 <task>
ffffffe00020102c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201030:	00379793          	slli	a5,a5,0x3
ffffffe000201034:	00f707b3          	add	a5,a4,a5
ffffffe000201038:	0007b783          	ld	a5,0(a5)
ffffffe00020103c:	0a07b703          	ld	a4,160(a5)
ffffffe000201040:	0000a697          	auipc	a3,0xa
ffffffe000201044:	fd068693          	addi	a3,a3,-48 # ffffffe00020b010 <task>
ffffffe000201048:	fdc42783          	lw	a5,-36(s0)
ffffffe00020104c:	00379793          	slli	a5,a5,0x3
ffffffe000201050:	00f687b3          	add	a5,a3,a5
ffffffe000201054:	0007b783          	ld	a5,0(a5)
ffffffe000201058:	02076713          	ori	a4,a4,32
ffffffe00020105c:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sstatus|=(1UL<<18);        //将 SUM 位置 1， S-Mode 可以访问 User 页表
ffffffe000201060:	0000a717          	auipc	a4,0xa
ffffffe000201064:	fb070713          	addi	a4,a4,-80 # ffffffe00020b010 <task>
ffffffe000201068:	fdc42783          	lw	a5,-36(s0)
ffffffe00020106c:	00379793          	slli	a5,a5,0x3
ffffffe000201070:	00f707b3          	add	a5,a4,a5
ffffffe000201074:	0007b783          	ld	a5,0(a5)
ffffffe000201078:	0a07b683          	ld	a3,160(a5)
ffffffe00020107c:	0000a717          	auipc	a4,0xa
ffffffe000201080:	f9470713          	addi	a4,a4,-108 # ffffffe00020b010 <task>
ffffffe000201084:	fdc42783          	lw	a5,-36(s0)
ffffffe000201088:	00379793          	slli	a5,a5,0x3
ffffffe00020108c:	00f707b3          	add	a5,a4,a5
ffffffe000201090:	0007b783          	ld	a5,0(a5)
ffffffe000201094:	00040737          	lui	a4,0x40
ffffffe000201098:	00e6e733          	or	a4,a3,a4
ffffffe00020109c:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sscratch = (uint64_t)USER_END;//将 sscratch 设置为 U-Mode 的 sp
ffffffe0002010a0:	0000a717          	auipc	a4,0xa
ffffffe0002010a4:	f7070713          	addi	a4,a4,-144 # ffffffe00020b010 <task>
ffffffe0002010a8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010ac:	00379793          	slli	a5,a5,0x3
ffffffe0002010b0:	00f707b3          	add	a5,a4,a5
ffffffe0002010b4:	0007b783          	ld	a5,0(a5)
ffffffe0002010b8:	00100713          	li	a4,1
ffffffe0002010bc:	02671713          	slli	a4,a4,0x26
ffffffe0002010c0:	0ae7b423          	sd	a4,168(a5)

        // 创建属于自己的页表：
        task[i]->pgd=(uint64_t *)kalloc();
ffffffe0002010c4:	0000a717          	auipc	a4,0xa
ffffffe0002010c8:	f4c70713          	addi	a4,a4,-180 # ffffffe00020b010 <task>
ffffffe0002010cc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010d0:	00379793          	slli	a5,a5,0x3
ffffffe0002010d4:	00f707b3          	add	a5,a4,a5
ffffffe0002010d8:	0007b483          	ld	s1,0(a5)
ffffffe0002010dc:	945ff0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe0002010e0:	00050793          	mv	a5,a0
ffffffe0002010e4:	0af4b823          	sd	a5,176(s1)
        //将内核页表 swapper_pg_dir 复制到进程的页表中
        memcpy(task[i]->pgd, swapper_pg_dir, PGSIZE);
ffffffe0002010e8:	0000a717          	auipc	a4,0xa
ffffffe0002010ec:	f2870713          	addi	a4,a4,-216 # ffffffe00020b010 <task>
ffffffe0002010f0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010f4:	00379793          	slli	a5,a5,0x3
ffffffe0002010f8:	00f707b3          	add	a5,a4,a5
ffffffe0002010fc:	0007b783          	ld	a5,0(a5)
ffffffe000201100:	0b07b783          	ld	a5,176(a5)
ffffffe000201104:	00001637          	lui	a2,0x1
ffffffe000201108:	00009597          	auipc	a1,0x9
ffffffe00020110c:	ef858593          	addi	a1,a1,-264 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201110:	00078513          	mv	a0,a5
ffffffe000201114:	a19ff0ef          	jal	ra,ffffffe000200b2c <memcpy>
        // memcpy(uapp_mem,_sramdisk,uapp_size);
        // 将 uapp 所在的页面映射到进程的页表中
        // create_mapping(task[i]->pgd,(uint64_t)USER_START,VA2PA((uint64_t)uapp_mem),num_pages*PGSIZE,PTE_V|PTE_R|PTE_W|PTE_X|PTE_U);

        //加载 ELF
        load_program(task[i]);
ffffffe000201118:	0000a717          	auipc	a4,0xa
ffffffe00020111c:	ef870713          	addi	a4,a4,-264 # ffffffe00020b010 <task>
ffffffe000201120:	fdc42783          	lw	a5,-36(s0)
ffffffe000201124:	00379793          	slli	a5,a5,0x3
ffffffe000201128:	00f707b3          	add	a5,a4,a5
ffffffe00020112c:	0007b783          	ld	a5,0(a5)
ffffffe000201130:	00078513          	mv	a0,a5
ffffffe000201134:	a75ff0ef          	jal	ra,ffffffe000200ba8 <load_program>

       
        //设置用户态栈
        void *user_stack=kalloc();
ffffffe000201138:	8e9ff0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe00020113c:	fca43023          	sd	a0,-64(s0)
        uint64_t stack_va=USER_END-PGSIZE; //用户栈顶虚拟地址
ffffffe000201140:	040007b7          	lui	a5,0x4000
ffffffe000201144:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201148:	00c79793          	slli	a5,a5,0xc
ffffffe00020114c:	faf43c23          	sd	a5,-72(s0)
        create_mapping(task[i]->pgd,stack_va,VA2PA((uint64_t)user_stack),PGSIZE,PTE_V|PTE_R|PTE_W|PTE_U);
ffffffe000201150:	0000a717          	auipc	a4,0xa
ffffffe000201154:	ec070713          	addi	a4,a4,-320 # ffffffe00020b010 <task>
ffffffe000201158:	fdc42783          	lw	a5,-36(s0)
ffffffe00020115c:	00379793          	slli	a5,a5,0x3
ffffffe000201160:	00f707b3          	add	a5,a4,a5
ffffffe000201164:	0007b783          	ld	a5,0(a5)
ffffffe000201168:	0b07b503          	ld	a0,176(a5)
ffffffe00020116c:	fc043703          	ld	a4,-64(s0)
ffffffe000201170:	04100793          	li	a5,65
ffffffe000201174:	01f79793          	slli	a5,a5,0x1f
ffffffe000201178:	00f707b3          	add	a5,a4,a5
ffffffe00020117c:	01700713          	li	a4,23
ffffffe000201180:	000016b7          	lui	a3,0x1
ffffffe000201184:	00078613          	mv	a2,a5
ffffffe000201188:	fb843583          	ld	a1,-72(s0)
ffffffe00020118c:	1d5000ef          	jal	ra,ffffffe000201b60 <create_mapping>
    for(int i=1;i<NR_TASKS;i++){
ffffffe000201190:	fdc42783          	lw	a5,-36(s0)
ffffffe000201194:	0017879b          	addiw	a5,a5,1
ffffffe000201198:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020119c:	fdc42783          	lw	a5,-36(s0)
ffffffe0002011a0:	0007871b          	sext.w	a4,a5
ffffffe0002011a4:	00400793          	li	a5,4
ffffffe0002011a8:	cce7d0e3          	bge	a5,a4,ffffffe000200e68 <task_init+0xec>
                                            

    }

    printk("...task_init done!\n");
ffffffe0002011ac:	00003517          	auipc	a0,0x3
ffffffe0002011b0:	e8450513          	addi	a0,a0,-380 # ffffffe000204030 <_srodata+0x30>
ffffffe0002011b4:	501010ef          	jal	ra,ffffffe000202eb4 <printk>
}
ffffffe0002011b8:	00000013          	nop
ffffffe0002011bc:	04813083          	ld	ra,72(sp)
ffffffe0002011c0:	04013403          	ld	s0,64(sp)
ffffffe0002011c4:	03813483          	ld	s1,56(sp)
ffffffe0002011c8:	05010113          	addi	sp,sp,80
ffffffe0002011cc:	00008067          	ret

ffffffe0002011d0 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe0002011d0:	fd010113          	addi	sp,sp,-48
ffffffe0002011d4:	02113423          	sd	ra,40(sp)
ffffffe0002011d8:	02813023          	sd	s0,32(sp)
ffffffe0002011dc:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe0002011e0:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe0002011e4:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe0002011e8:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe0002011ec:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe0002011f0:	fff00793          	li	a5,-1
ffffffe0002011f4:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002011f8:	fe442783          	lw	a5,-28(s0)
ffffffe0002011fc:	0007871b          	sext.w	a4,a5
ffffffe000201200:	fff00793          	li	a5,-1
ffffffe000201204:	00f70e63          	beq	a4,a5,ffffffe000201220 <dummy+0x50>
ffffffe000201208:	0000a797          	auipc	a5,0xa
ffffffe00020120c:	e0078793          	addi	a5,a5,-512 # ffffffe00020b008 <current>
ffffffe000201210:	0007b783          	ld	a5,0(a5)
ffffffe000201214:	0087b703          	ld	a4,8(a5)
ffffffe000201218:	fe442783          	lw	a5,-28(s0)
ffffffe00020121c:	fcf70ee3          	beq	a4,a5,ffffffe0002011f8 <dummy+0x28>
ffffffe000201220:	0000a797          	auipc	a5,0xa
ffffffe000201224:	de878793          	addi	a5,a5,-536 # ffffffe00020b008 <current>
ffffffe000201228:	0007b783          	ld	a5,0(a5)
ffffffe00020122c:	0087b783          	ld	a5,8(a5)
ffffffe000201230:	fc0784e3          	beqz	a5,ffffffe0002011f8 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000201234:	0000a797          	auipc	a5,0xa
ffffffe000201238:	dd478793          	addi	a5,a5,-556 # ffffffe00020b008 <current>
ffffffe00020123c:	0007b783          	ld	a5,0(a5)
ffffffe000201240:	0087b703          	ld	a4,8(a5)
ffffffe000201244:	00100793          	li	a5,1
ffffffe000201248:	00f71e63          	bne	a4,a5,ffffffe000201264 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe00020124c:	0000a797          	auipc	a5,0xa
ffffffe000201250:	dbc78793          	addi	a5,a5,-580 # ffffffe00020b008 <current>
ffffffe000201254:	0007b783          	ld	a5,0(a5)
ffffffe000201258:	0087b703          	ld	a4,8(a5)
ffffffe00020125c:	fff70713          	addi	a4,a4,-1
ffffffe000201260:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000201264:	0000a797          	auipc	a5,0xa
ffffffe000201268:	da478793          	addi	a5,a5,-604 # ffffffe00020b008 <current>
ffffffe00020126c:	0007b783          	ld	a5,0(a5)
ffffffe000201270:	0087b783          	ld	a5,8(a5)
ffffffe000201274:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000201278:	fe843783          	ld	a5,-24(s0)
ffffffe00020127c:	00178713          	addi	a4,a5,1
ffffffe000201280:	fd843783          	ld	a5,-40(s0)
ffffffe000201284:	02f777b3          	remu	a5,a4,a5
ffffffe000201288:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe00020128c:	0000a797          	auipc	a5,0xa
ffffffe000201290:	d7c78793          	addi	a5,a5,-644 # ffffffe00020b008 <current>
ffffffe000201294:	0007b783          	ld	a5,0(a5)
ffffffe000201298:	0187b783          	ld	a5,24(a5)
ffffffe00020129c:	fe843603          	ld	a2,-24(s0)
ffffffe0002012a0:	00078593          	mv	a1,a5
ffffffe0002012a4:	00003517          	auipc	a0,0x3
ffffffe0002012a8:	da450513          	addi	a0,a0,-604 # ffffffe000204048 <_srodata+0x48>
ffffffe0002012ac:	409010ef          	jal	ra,ffffffe000202eb4 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002012b0:	f49ff06f          	j	ffffffe0002011f8 <dummy+0x28>

ffffffe0002012b4 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
ffffffe0002012b4:	fd010113          	addi	sp,sp,-48
ffffffe0002012b8:	02113423          	sd	ra,40(sp)
ffffffe0002012bc:	02813023          	sd	s0,32(sp)
ffffffe0002012c0:	03010413          	addi	s0,sp,48
ffffffe0002012c4:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
ffffffe0002012c8:	0000a797          	auipc	a5,0xa
ffffffe0002012cc:	d4078793          	addi	a5,a5,-704 # ffffffe00020b008 <current>
ffffffe0002012d0:	0007b783          	ld	a5,0(a5)
ffffffe0002012d4:	fd843703          	ld	a4,-40(s0)
ffffffe0002012d8:	06f70063          	beq	a4,a5,ffffffe000201338 <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
ffffffe0002012dc:	0000a797          	auipc	a5,0xa
ffffffe0002012e0:	d2c78793          	addi	a5,a5,-724 # ffffffe00020b008 <current>
ffffffe0002012e4:	0007b783          	ld	a5,0(a5)
ffffffe0002012e8:	fef43423          	sd	a5,-24(s0)
    current=next;
ffffffe0002012ec:	0000a797          	auipc	a5,0xa
ffffffe0002012f0:	d1c78793          	addi	a5,a5,-740 # ffffffe00020b008 <current>
ffffffe0002012f4:	fd843703          	ld	a4,-40(s0)
ffffffe0002012f8:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
ffffffe0002012fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201300:	0187b703          	ld	a4,24(a5)
ffffffe000201304:	fd843783          	ld	a5,-40(s0)
ffffffe000201308:	0107b603          	ld	a2,16(a5)
ffffffe00020130c:	fd843783          	ld	a5,-40(s0)
ffffffe000201310:	0087b783          	ld	a5,8(a5)
ffffffe000201314:	00078693          	mv	a3,a5
ffffffe000201318:	00070593          	mv	a1,a4
ffffffe00020131c:	00003517          	auipc	a0,0x3
ffffffe000201320:	d5c50513          	addi	a0,a0,-676 # ffffffe000204078 <_srodata+0x78>
ffffffe000201324:	391010ef          	jal	ra,ffffffe000202eb4 <printk>
    __switch_to(prev,next);
ffffffe000201328:	fd843583          	ld	a1,-40(s0)
ffffffe00020132c:	fe843503          	ld	a0,-24(s0)
ffffffe000201330:	ef5fe0ef          	jal	ra,ffffffe000200224 <__switch_to>
ffffffe000201334:	0080006f          	j	ffffffe00020133c <switch_to+0x88>
        return;
ffffffe000201338:	00000013          	nop
    
}
ffffffe00020133c:	02813083          	ld	ra,40(sp)
ffffffe000201340:	02013403          	ld	s0,32(sp)
ffffffe000201344:	03010113          	addi	sp,sp,48
ffffffe000201348:	00008067          	ret

ffffffe00020134c <do_timer>:

void do_timer(){
ffffffe00020134c:	ff010113          	addi	sp,sp,-16
ffffffe000201350:	00113423          	sd	ra,8(sp)
ffffffe000201354:	00813023          	sd	s0,0(sp)
ffffffe000201358:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
ffffffe00020135c:	0000a797          	auipc	a5,0xa
ffffffe000201360:	cac78793          	addi	a5,a5,-852 # ffffffe00020b008 <current>
ffffffe000201364:	0007b703          	ld	a4,0(a5)
ffffffe000201368:	0000a797          	auipc	a5,0xa
ffffffe00020136c:	c9878793          	addi	a5,a5,-872 # ffffffe00020b000 <idle>
ffffffe000201370:	0007b783          	ld	a5,0(a5)
ffffffe000201374:	00f70c63          	beq	a4,a5,ffffffe00020138c <do_timer+0x40>
ffffffe000201378:	0000a797          	auipc	a5,0xa
ffffffe00020137c:	c9078793          	addi	a5,a5,-880 # ffffffe00020b008 <current>
ffffffe000201380:	0007b783          	ld	a5,0(a5)
ffffffe000201384:	0087b783          	ld	a5,8(a5)
ffffffe000201388:	00079663          	bnez	a5,ffffffe000201394 <do_timer+0x48>
        schedule();
ffffffe00020138c:	04c000ef          	jal	ra,ffffffe0002013d8 <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
ffffffe000201390:	0340006f          	j	ffffffe0002013c4 <do_timer+0x78>
        current->counter--;
ffffffe000201394:	0000a797          	auipc	a5,0xa
ffffffe000201398:	c7478793          	addi	a5,a5,-908 # ffffffe00020b008 <current>
ffffffe00020139c:	0007b783          	ld	a5,0(a5)
ffffffe0002013a0:	0087b703          	ld	a4,8(a5)
ffffffe0002013a4:	fff70713          	addi	a4,a4,-1
ffffffe0002013a8:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
ffffffe0002013ac:	0000a797          	auipc	a5,0xa
ffffffe0002013b0:	c5c78793          	addi	a5,a5,-932 # ffffffe00020b008 <current>
ffffffe0002013b4:	0007b783          	ld	a5,0(a5)
ffffffe0002013b8:	0087b783          	ld	a5,8(a5)
ffffffe0002013bc:	00079463          	bnez	a5,ffffffe0002013c4 <do_timer+0x78>
            schedule();
ffffffe0002013c0:	018000ef          	jal	ra,ffffffe0002013d8 <schedule>
}
ffffffe0002013c4:	00000013          	nop
ffffffe0002013c8:	00813083          	ld	ra,8(sp)
ffffffe0002013cc:	00013403          	ld	s0,0(sp)
ffffffe0002013d0:	01010113          	addi	sp,sp,16
ffffffe0002013d4:	00008067          	ret

ffffffe0002013d8 <schedule>:

void schedule(){
ffffffe0002013d8:	fd010113          	addi	sp,sp,-48
ffffffe0002013dc:	02113423          	sd	ra,40(sp)
ffffffe0002013e0:	02813023          	sd	s0,32(sp)
ffffffe0002013e4:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
ffffffe0002013e8:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
ffffffe0002013ec:	fe043023          	sd	zero,-32(s0)
    //找到 counter 最大的线程
    for(int i=0;i<NR_TASKS;i++){
ffffffe0002013f0:	fc042e23          	sw	zero,-36(s0)
ffffffe0002013f4:	0700006f          	j	ffffffe000201464 <schedule+0x8c>
        if(task[i]->counter>max_counter){
ffffffe0002013f8:	0000a717          	auipc	a4,0xa
ffffffe0002013fc:	c1870713          	addi	a4,a4,-1000 # ffffffe00020b010 <task>
ffffffe000201400:	fdc42783          	lw	a5,-36(s0)
ffffffe000201404:	00379793          	slli	a5,a5,0x3
ffffffe000201408:	00f707b3          	add	a5,a4,a5
ffffffe00020140c:	0007b783          	ld	a5,0(a5)
ffffffe000201410:	0087b783          	ld	a5,8(a5)
ffffffe000201414:	fe043703          	ld	a4,-32(s0)
ffffffe000201418:	04f77063          	bgeu	a4,a5,ffffffe000201458 <schedule+0x80>
            max_counter=task[i]->counter;
ffffffe00020141c:	0000a717          	auipc	a4,0xa
ffffffe000201420:	bf470713          	addi	a4,a4,-1036 # ffffffe00020b010 <task>
ffffffe000201424:	fdc42783          	lw	a5,-36(s0)
ffffffe000201428:	00379793          	slli	a5,a5,0x3
ffffffe00020142c:	00f707b3          	add	a5,a4,a5
ffffffe000201430:	0007b783          	ld	a5,0(a5)
ffffffe000201434:	0087b783          	ld	a5,8(a5)
ffffffe000201438:	fef43023          	sd	a5,-32(s0)
            next=task[i];
ffffffe00020143c:	0000a717          	auipc	a4,0xa
ffffffe000201440:	bd470713          	addi	a4,a4,-1068 # ffffffe00020b010 <task>
ffffffe000201444:	fdc42783          	lw	a5,-36(s0)
ffffffe000201448:	00379793          	slli	a5,a5,0x3
ffffffe00020144c:	00f707b3          	add	a5,a4,a5
ffffffe000201450:	0007b783          	ld	a5,0(a5)
ffffffe000201454:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
ffffffe000201458:	fdc42783          	lw	a5,-36(s0)
ffffffe00020145c:	0017879b          	addiw	a5,a5,1
ffffffe000201460:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201464:	fdc42783          	lw	a5,-36(s0)
ffffffe000201468:	0007871b          	sext.w	a4,a5
ffffffe00020146c:	00400793          	li	a5,4
ffffffe000201470:	f8e7d4e3          	bge	a5,a4,ffffffe0002013f8 <schedule+0x20>
        }
    }
    //如果所有线程的 counter 都为 0，则重新为每个线程分配时间片，分配策略为将线程的 priority 赋值给 counter
    if(max_counter==0){
ffffffe000201474:	fe043783          	ld	a5,-32(s0)
ffffffe000201478:	12079463          	bnez	a5,ffffffe0002015a0 <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
ffffffe00020147c:	00100793          	li	a5,1
ffffffe000201480:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201484:	10c0006f          	j	ffffffe000201590 <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
ffffffe000201488:	0000a717          	auipc	a4,0xa
ffffffe00020148c:	b8870713          	addi	a4,a4,-1144 # ffffffe00020b010 <task>
ffffffe000201490:	fd842783          	lw	a5,-40(s0)
ffffffe000201494:	00379793          	slli	a5,a5,0x3
ffffffe000201498:	00f707b3          	add	a5,a4,a5
ffffffe00020149c:	0007b703          	ld	a4,0(a5)
ffffffe0002014a0:	0000a697          	auipc	a3,0xa
ffffffe0002014a4:	b7068693          	addi	a3,a3,-1168 # ffffffe00020b010 <task>
ffffffe0002014a8:	fd842783          	lw	a5,-40(s0)
ffffffe0002014ac:	00379793          	slli	a5,a5,0x3
ffffffe0002014b0:	00f687b3          	add	a5,a3,a5
ffffffe0002014b4:	0007b783          	ld	a5,0(a5)
ffffffe0002014b8:	01073703          	ld	a4,16(a4)
ffffffe0002014bc:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
ffffffe0002014c0:	0000a717          	auipc	a4,0xa
ffffffe0002014c4:	b5070713          	addi	a4,a4,-1200 # ffffffe00020b010 <task>
ffffffe0002014c8:	fd842783          	lw	a5,-40(s0)
ffffffe0002014cc:	00379793          	slli	a5,a5,0x3
ffffffe0002014d0:	00f707b3          	add	a5,a4,a5
ffffffe0002014d4:	0007b783          	ld	a5,0(a5)
ffffffe0002014d8:	0187b583          	ld	a1,24(a5)
ffffffe0002014dc:	0000a717          	auipc	a4,0xa
ffffffe0002014e0:	b3470713          	addi	a4,a4,-1228 # ffffffe00020b010 <task>
ffffffe0002014e4:	fd842783          	lw	a5,-40(s0)
ffffffe0002014e8:	00379793          	slli	a5,a5,0x3
ffffffe0002014ec:	00f707b3          	add	a5,a4,a5
ffffffe0002014f0:	0007b783          	ld	a5,0(a5)
ffffffe0002014f4:	0107b603          	ld	a2,16(a5)
ffffffe0002014f8:	0000a717          	auipc	a4,0xa
ffffffe0002014fc:	b1870713          	addi	a4,a4,-1256 # ffffffe00020b010 <task>
ffffffe000201500:	fd842783          	lw	a5,-40(s0)
ffffffe000201504:	00379793          	slli	a5,a5,0x3
ffffffe000201508:	00f707b3          	add	a5,a4,a5
ffffffe00020150c:	0007b783          	ld	a5,0(a5)
ffffffe000201510:	0087b783          	ld	a5,8(a5)
ffffffe000201514:	00078693          	mv	a3,a5
ffffffe000201518:	00003517          	auipc	a0,0x3
ffffffe00020151c:	ba050513          	addi	a0,a0,-1120 # ffffffe0002040b8 <_srodata+0xb8>
ffffffe000201520:	195010ef          	jal	ra,ffffffe000202eb4 <printk>
            if(task[i]->counter>max_counter){
ffffffe000201524:	0000a717          	auipc	a4,0xa
ffffffe000201528:	aec70713          	addi	a4,a4,-1300 # ffffffe00020b010 <task>
ffffffe00020152c:	fd842783          	lw	a5,-40(s0)
ffffffe000201530:	00379793          	slli	a5,a5,0x3
ffffffe000201534:	00f707b3          	add	a5,a4,a5
ffffffe000201538:	0007b783          	ld	a5,0(a5)
ffffffe00020153c:	0087b783          	ld	a5,8(a5)
ffffffe000201540:	fe043703          	ld	a4,-32(s0)
ffffffe000201544:	04f77063          	bgeu	a4,a5,ffffffe000201584 <schedule+0x1ac>
                max_counter=task[i]->counter;
ffffffe000201548:	0000a717          	auipc	a4,0xa
ffffffe00020154c:	ac870713          	addi	a4,a4,-1336 # ffffffe00020b010 <task>
ffffffe000201550:	fd842783          	lw	a5,-40(s0)
ffffffe000201554:	00379793          	slli	a5,a5,0x3
ffffffe000201558:	00f707b3          	add	a5,a4,a5
ffffffe00020155c:	0007b783          	ld	a5,0(a5)
ffffffe000201560:	0087b783          	ld	a5,8(a5)
ffffffe000201564:	fef43023          	sd	a5,-32(s0)
                next=task[i];
ffffffe000201568:	0000a717          	auipc	a4,0xa
ffffffe00020156c:	aa870713          	addi	a4,a4,-1368 # ffffffe00020b010 <task>
ffffffe000201570:	fd842783          	lw	a5,-40(s0)
ffffffe000201574:	00379793          	slli	a5,a5,0x3
ffffffe000201578:	00f707b3          	add	a5,a4,a5
ffffffe00020157c:	0007b783          	ld	a5,0(a5)
ffffffe000201580:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
ffffffe000201584:	fd842783          	lw	a5,-40(s0)
ffffffe000201588:	0017879b          	addiw	a5,a5,1
ffffffe00020158c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201590:	fd842783          	lw	a5,-40(s0)
ffffffe000201594:	0007871b          	sext.w	a4,a5
ffffffe000201598:	00400793          	li	a5,4
ffffffe00020159c:	eee7d6e3          	bge	a5,a4,ffffffe000201488 <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
ffffffe0002015a0:	fe843783          	ld	a5,-24(s0)
ffffffe0002015a4:	00078663          	beqz	a5,ffffffe0002015b0 <schedule+0x1d8>
ffffffe0002015a8:	fe843503          	ld	a0,-24(s0)
ffffffe0002015ac:	d09ff0ef          	jal	ra,ffffffe0002012b4 <switch_to>
}
ffffffe0002015b0:	00000013          	nop
ffffffe0002015b4:	02813083          	ld	ra,40(sp)
ffffffe0002015b8:	02013403          	ld	s0,32(sp)
ffffffe0002015bc:	03010113          	addi	sp,sp,48
ffffffe0002015c0:	00008067          	ret

ffffffe0002015c4 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe0002015c4:	f8010113          	addi	sp,sp,-128
ffffffe0002015c8:	06813c23          	sd	s0,120(sp)
ffffffe0002015cc:	06913823          	sd	s1,112(sp)
ffffffe0002015d0:	07213423          	sd	s2,104(sp)
ffffffe0002015d4:	07313023          	sd	s3,96(sp)
ffffffe0002015d8:	08010413          	addi	s0,sp,128
ffffffe0002015dc:	faa43c23          	sd	a0,-72(s0)
ffffffe0002015e0:	fab43823          	sd	a1,-80(s0)
ffffffe0002015e4:	fac43423          	sd	a2,-88(s0)
ffffffe0002015e8:	fad43023          	sd	a3,-96(s0)
ffffffe0002015ec:	f8e43c23          	sd	a4,-104(s0)
ffffffe0002015f0:	f8f43823          	sd	a5,-112(s0)
ffffffe0002015f4:	f9043423          	sd	a6,-120(s0)
ffffffe0002015f8:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
ffffffe0002015fc:	fb843e03          	ld	t3,-72(s0)
ffffffe000201600:	fb043e83          	ld	t4,-80(s0)
ffffffe000201604:	fa843f03          	ld	t5,-88(s0)
ffffffe000201608:	fa043f83          	ld	t6,-96(s0)
ffffffe00020160c:	f9843283          	ld	t0,-104(s0)
ffffffe000201610:	f9043483          	ld	s1,-112(s0)
ffffffe000201614:	f8843903          	ld	s2,-120(s0)
ffffffe000201618:	f8043983          	ld	s3,-128(s0)
ffffffe00020161c:	000e0893          	mv	a7,t3
ffffffe000201620:	000e8813          	mv	a6,t4
ffffffe000201624:	000f0513          	mv	a0,t5
ffffffe000201628:	000f8593          	mv	a1,t6
ffffffe00020162c:	00028613          	mv	a2,t0
ffffffe000201630:	00048693          	mv	a3,s1
ffffffe000201634:	00090713          	mv	a4,s2
ffffffe000201638:	00098793          	mv	a5,s3
ffffffe00020163c:	00000073          	ecall
ffffffe000201640:	00050e93          	mv	t4,a0
ffffffe000201644:	00058e13          	mv	t3,a1
ffffffe000201648:	fdd43023          	sd	t4,-64(s0)
ffffffe00020164c:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
ffffffe000201650:	fc043783          	ld	a5,-64(s0)
ffffffe000201654:	fcf43823          	sd	a5,-48(s0)
ffffffe000201658:	fc843783          	ld	a5,-56(s0)
ffffffe00020165c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201660:	00000713          	li	a4,0
ffffffe000201664:	fd043703          	ld	a4,-48(s0)
ffffffe000201668:	00000793          	li	a5,0
ffffffe00020166c:	fd843783          	ld	a5,-40(s0)
ffffffe000201670:	00070313          	mv	t1,a4
ffffffe000201674:	00078393          	mv	t2,a5
ffffffe000201678:	00030713          	mv	a4,t1
ffffffe00020167c:	00038793          	mv	a5,t2
}
ffffffe000201680:	00070513          	mv	a0,a4
ffffffe000201684:	00078593          	mv	a1,a5
ffffffe000201688:	07813403          	ld	s0,120(sp)
ffffffe00020168c:	07013483          	ld	s1,112(sp)
ffffffe000201690:	06813903          	ld	s2,104(sp)
ffffffe000201694:	06013983          	ld	s3,96(sp)
ffffffe000201698:	08010113          	addi	sp,sp,128
ffffffe00020169c:	00008067          	ret

ffffffe0002016a0 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe0002016a0:	fc010113          	addi	sp,sp,-64
ffffffe0002016a4:	02113c23          	sd	ra,56(sp)
ffffffe0002016a8:	02813823          	sd	s0,48(sp)
ffffffe0002016ac:	03213423          	sd	s2,40(sp)
ffffffe0002016b0:	03313023          	sd	s3,32(sp)
ffffffe0002016b4:	04010413          	addi	s0,sp,64
ffffffe0002016b8:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
ffffffe0002016bc:	00000893          	li	a7,0
ffffffe0002016c0:	00000813          	li	a6,0
ffffffe0002016c4:	00000793          	li	a5,0
ffffffe0002016c8:	00000713          	li	a4,0
ffffffe0002016cc:	00000693          	li	a3,0
ffffffe0002016d0:	fc843603          	ld	a2,-56(s0)
ffffffe0002016d4:	00000593          	li	a1,0
ffffffe0002016d8:	54495537          	lui	a0,0x54495
ffffffe0002016dc:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002016e0:	ee5ff0ef          	jal	ra,ffffffe0002015c4 <sbi_ecall>
ffffffe0002016e4:	00050713          	mv	a4,a0
ffffffe0002016e8:	00058793          	mv	a5,a1
ffffffe0002016ec:	fce43823          	sd	a4,-48(s0)
ffffffe0002016f0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002016f4:	00000713          	li	a4,0
ffffffe0002016f8:	fd043703          	ld	a4,-48(s0)
ffffffe0002016fc:	00000793          	li	a5,0
ffffffe000201700:	fd843783          	ld	a5,-40(s0)
ffffffe000201704:	00070913          	mv	s2,a4
ffffffe000201708:	00078993          	mv	s3,a5
ffffffe00020170c:	00090713          	mv	a4,s2
ffffffe000201710:	00098793          	mv	a5,s3
}
ffffffe000201714:	00070513          	mv	a0,a4
ffffffe000201718:	00078593          	mv	a1,a5
ffffffe00020171c:	03813083          	ld	ra,56(sp)
ffffffe000201720:	03013403          	ld	s0,48(sp)
ffffffe000201724:	02813903          	ld	s2,40(sp)
ffffffe000201728:	02013983          	ld	s3,32(sp)
ffffffe00020172c:	04010113          	addi	sp,sp,64
ffffffe000201730:	00008067          	ret

ffffffe000201734 <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201734:	fc010113          	addi	sp,sp,-64
ffffffe000201738:	02113c23          	sd	ra,56(sp)
ffffffe00020173c:	02813823          	sd	s0,48(sp)
ffffffe000201740:	03213423          	sd	s2,40(sp)
ffffffe000201744:	03313023          	sd	s3,32(sp)
ffffffe000201748:	04010413          	addi	s0,sp,64
ffffffe00020174c:	00050793          	mv	a5,a0
ffffffe000201750:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
ffffffe000201754:	fcf44603          	lbu	a2,-49(s0)
ffffffe000201758:	00000893          	li	a7,0
ffffffe00020175c:	00000813          	li	a6,0
ffffffe000201760:	00000793          	li	a5,0
ffffffe000201764:	00000713          	li	a4,0
ffffffe000201768:	00000693          	li	a3,0
ffffffe00020176c:	00200593          	li	a1,2
ffffffe000201770:	44424537          	lui	a0,0x44424
ffffffe000201774:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201778:	e4dff0ef          	jal	ra,ffffffe0002015c4 <sbi_ecall>
ffffffe00020177c:	00050713          	mv	a4,a0
ffffffe000201780:	00058793          	mv	a5,a1
ffffffe000201784:	fce43823          	sd	a4,-48(s0)
ffffffe000201788:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020178c:	00000713          	li	a4,0
ffffffe000201790:	fd043703          	ld	a4,-48(s0)
ffffffe000201794:	00000793          	li	a5,0
ffffffe000201798:	fd843783          	ld	a5,-40(s0)
ffffffe00020179c:	00070913          	mv	s2,a4
ffffffe0002017a0:	00078993          	mv	s3,a5
ffffffe0002017a4:	00090713          	mv	a4,s2
ffffffe0002017a8:	00098793          	mv	a5,s3
}
ffffffe0002017ac:	00070513          	mv	a0,a4
ffffffe0002017b0:	00078593          	mv	a1,a5
ffffffe0002017b4:	03813083          	ld	ra,56(sp)
ffffffe0002017b8:	03013403          	ld	s0,48(sp)
ffffffe0002017bc:	02813903          	ld	s2,40(sp)
ffffffe0002017c0:	02013983          	ld	s3,32(sp)
ffffffe0002017c4:	04010113          	addi	sp,sp,64
ffffffe0002017c8:	00008067          	ret

ffffffe0002017cc <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe0002017cc:	fc010113          	addi	sp,sp,-64
ffffffe0002017d0:	02113c23          	sd	ra,56(sp)
ffffffe0002017d4:	02813823          	sd	s0,48(sp)
ffffffe0002017d8:	03213423          	sd	s2,40(sp)
ffffffe0002017dc:	03313023          	sd	s3,32(sp)
ffffffe0002017e0:	04010413          	addi	s0,sp,64
ffffffe0002017e4:	00050793          	mv	a5,a0
ffffffe0002017e8:	00058713          	mv	a4,a1
ffffffe0002017ec:	fcf42623          	sw	a5,-52(s0)
ffffffe0002017f0:	00070793          	mv	a5,a4
ffffffe0002017f4:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
ffffffe0002017f8:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002017fc:	fc846683          	lwu	a3,-56(s0)
ffffffe000201800:	00000893          	li	a7,0
ffffffe000201804:	00000813          	li	a6,0
ffffffe000201808:	00000793          	li	a5,0
ffffffe00020180c:	00000713          	li	a4,0
ffffffe000201810:	00000593          	li	a1,0
ffffffe000201814:	53525537          	lui	a0,0x53525
ffffffe000201818:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe00020181c:	da9ff0ef          	jal	ra,ffffffe0002015c4 <sbi_ecall>
ffffffe000201820:	00050713          	mv	a4,a0
ffffffe000201824:	00058793          	mv	a5,a1
ffffffe000201828:	fce43823          	sd	a4,-48(s0)
ffffffe00020182c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201830:	00000713          	li	a4,0
ffffffe000201834:	fd043703          	ld	a4,-48(s0)
ffffffe000201838:	00000793          	li	a5,0
ffffffe00020183c:	fd843783          	ld	a5,-40(s0)
ffffffe000201840:	00070913          	mv	s2,a4
ffffffe000201844:	00078993          	mv	s3,a5
ffffffe000201848:	00090713          	mv	a4,s2
ffffffe00020184c:	00098793          	mv	a5,s3
ffffffe000201850:	00070513          	mv	a0,a4
ffffffe000201854:	00078593          	mv	a1,a5
ffffffe000201858:	03813083          	ld	ra,56(sp)
ffffffe00020185c:	03013403          	ld	s0,48(sp)
ffffffe000201860:	02813903          	ld	s2,40(sp)
ffffffe000201864:	02013983          	ld	s3,32(sp)
ffffffe000201868:	04010113          	addi	sp,sp,64
ffffffe00020186c:	00008067          	ret

ffffffe000201870 <sys_write>:
#include "syscall.h"
#include "proc.h"
#include "printk.h"


uint64_t sys_write(unsigned int fd, const char* buf, size_t count){
ffffffe000201870:	fc010113          	addi	sp,sp,-64
ffffffe000201874:	02113c23          	sd	ra,56(sp)
ffffffe000201878:	02813823          	sd	s0,48(sp)
ffffffe00020187c:	04010413          	addi	s0,sp,64
ffffffe000201880:	00050793          	mv	a5,a0
ffffffe000201884:	fcb43823          	sd	a1,-48(s0)
ffffffe000201888:	fcc43423          	sd	a2,-56(s0)
ffffffe00020188c:	fcf42e23          	sw	a5,-36(s0)
    //标准输出
    if(fd==1){
ffffffe000201890:	fdc42783          	lw	a5,-36(s0)
ffffffe000201894:	0007871b          	sext.w	a4,a5
ffffffe000201898:	00100793          	li	a5,1
ffffffe00020189c:	04f71663          	bne	a4,a5,ffffffe0002018e8 <sys_write+0x78>
        for(uint64_t i=0;i<count;i++){
ffffffe0002018a0:	fe043423          	sd	zero,-24(s0)
ffffffe0002018a4:	0340006f          	j	ffffffe0002018d8 <sys_write+0x68>
            printk("%c",buf[i]);
ffffffe0002018a8:	fd043703          	ld	a4,-48(s0)
ffffffe0002018ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002018b0:	00f707b3          	add	a5,a4,a5
ffffffe0002018b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002018b8:	0007879b          	sext.w	a5,a5
ffffffe0002018bc:	00078593          	mv	a1,a5
ffffffe0002018c0:	00003517          	auipc	a0,0x3
ffffffe0002018c4:	83050513          	addi	a0,a0,-2000 # ffffffe0002040f0 <_srodata+0xf0>
ffffffe0002018c8:	5ec010ef          	jal	ra,ffffffe000202eb4 <printk>
        for(uint64_t i=0;i<count;i++){
ffffffe0002018cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002018d0:	00178793          	addi	a5,a5,1
ffffffe0002018d4:	fef43423          	sd	a5,-24(s0)
ffffffe0002018d8:	fe843703          	ld	a4,-24(s0)
ffffffe0002018dc:	fc843783          	ld	a5,-56(s0)
ffffffe0002018e0:	fcf764e3          	bltu	a4,a5,ffffffe0002018a8 <sys_write+0x38>
ffffffe0002018e4:	00c0006f          	j	ffffffe0002018f0 <sys_write+0x80>
        }
    }else{
        return -1; 
ffffffe0002018e8:	fff00793          	li	a5,-1
ffffffe0002018ec:	0080006f          	j	ffffffe0002018f4 <sys_write+0x84>
    }
    return count;
ffffffe0002018f0:	fc843783          	ld	a5,-56(s0)
}
ffffffe0002018f4:	00078513          	mv	a0,a5
ffffffe0002018f8:	03813083          	ld	ra,56(sp)
ffffffe0002018fc:	03013403          	ld	s0,48(sp)
ffffffe000201900:	04010113          	addi	sp,sp,64
ffffffe000201904:	00008067          	ret

ffffffe000201908 <sys_getpid>:
uint64_t sys_getpid(){
ffffffe000201908:	ff010113          	addi	sp,sp,-16
ffffffe00020190c:	00813423          	sd	s0,8(sp)
ffffffe000201910:	01010413          	addi	s0,sp,16
    return current->pid;
ffffffe000201914:	00009797          	auipc	a5,0x9
ffffffe000201918:	6f478793          	addi	a5,a5,1780 # ffffffe00020b008 <current>
ffffffe00020191c:	0007b783          	ld	a5,0(a5)
ffffffe000201920:	0187b783          	ld	a5,24(a5)
ffffffe000201924:	00078513          	mv	a0,a5
ffffffe000201928:	00813403          	ld	s0,8(sp)
ffffffe00020192c:	01010113          	addi	sp,sp,16
ffffffe000201930:	00008067          	ret

ffffffe000201934 <trap_handler>:
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "syscall.h"

void trap_handler(uint64_t scause, uint64_t sepc,struct pt_regs *regs) {
ffffffe000201934:	f9010113          	addi	sp,sp,-112
ffffffe000201938:	06113423          	sd	ra,104(sp)
ffffffe00020193c:	06813023          	sd	s0,96(sp)
ffffffe000201940:	07010413          	addi	s0,sp,112
ffffffe000201944:	faa43423          	sd	a0,-88(s0)
ffffffe000201948:	fab43023          	sd	a1,-96(s0)
ffffffe00020194c:	f8c43c23          	sd	a2,-104(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
ffffffe000201950:	fa843783          	ld	a5,-88(s0)
ffffffe000201954:	0407d263          	bgez	a5,ffffffe000201998 <trap_handler+0x64>
        uint64_t interrupt_code = scause & ~(1UL << 63);
ffffffe000201958:	fa843703          	ld	a4,-88(s0)
ffffffe00020195c:	fff00793          	li	a5,-1
ffffffe000201960:	0017d793          	srli	a5,a5,0x1
ffffffe000201964:	00f777b3          	and	a5,a4,a5
ffffffe000201968:	faf43c23          	sd	a5,-72(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
ffffffe00020196c:	fb843703          	ld	a4,-72(s0)
ffffffe000201970:	00500793          	li	a5,5
ffffffe000201974:	00f71863          	bne	a4,a5,ffffffe000201984 <trap_handler+0x50>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
ffffffe000201978:	9d1fe0ef          	jal	ra,ffffffe000200348 <clock_set_next_event>
            do_timer();
ffffffe00020197c:	9d1ff0ef          	jal	ra,ffffffe00020134c <do_timer>
ffffffe000201980:	0f00006f          	j	ffffffe000201a70 <trap_handler+0x13c>
        } else {
            printk("other interrupt: %d\n", interrupt_code);
ffffffe000201984:	fb843583          	ld	a1,-72(s0)
ffffffe000201988:	00002517          	auipc	a0,0x2
ffffffe00020198c:	77050513          	addi	a0,a0,1904 # ffffffe0002040f8 <_srodata+0xf8>
ffffffe000201990:	524010ef          	jal	ra,ffffffe000202eb4 <printk>
ffffffe000201994:	0dc0006f          	j	ffffffe000201a70 <trap_handler+0x13c>
        }
    } else {
        uint64_t exception_code = scause;
ffffffe000201998:	fa843783          	ld	a5,-88(s0)
ffffffe00020199c:	fef43023          	sd	a5,-32(s0)
        //用户态系统调用
        if(exception_code==8){
ffffffe0002019a0:	fe043703          	ld	a4,-32(s0)
ffffffe0002019a4:	00800793          	li	a5,8
ffffffe0002019a8:	0af71c63          	bne	a4,a5,ffffffe000201a60 <trap_handler+0x12c>
            uint64_t a7=regs->x[17]; //系统调用号
ffffffe0002019ac:	f9843783          	ld	a5,-104(s0)
ffffffe0002019b0:	0887b783          	ld	a5,136(a5)
ffffffe0002019b4:	fcf43c23          	sd	a5,-40(s0)
            uint64_t a0=regs->x[10]; //参数1
ffffffe0002019b8:	f9843783          	ld	a5,-104(s0)
ffffffe0002019bc:	0507b783          	ld	a5,80(a5)
ffffffe0002019c0:	fcf43823          	sd	a5,-48(s0)
            uint64_t a1=regs->x[11]; //参数2
ffffffe0002019c4:	f9843783          	ld	a5,-104(s0)
ffffffe0002019c8:	0587b783          	ld	a5,88(a5)
ffffffe0002019cc:	fcf43423          	sd	a5,-56(s0)
            uint64_t a2=regs->x[12]; //参数3
ffffffe0002019d0:	f9843783          	ld	a5,-104(s0)
ffffffe0002019d4:	0607b783          	ld	a5,96(a5)
ffffffe0002019d8:	fcf43023          	sd	a5,-64(s0)
            uint64_t ret=-1;
ffffffe0002019dc:	fff00793          	li	a5,-1
ffffffe0002019e0:	fef43423          	sd	a5,-24(s0)
            if(a7==SYS_write){
ffffffe0002019e4:	fd843703          	ld	a4,-40(s0)
ffffffe0002019e8:	04000793          	li	a5,64
ffffffe0002019ec:	02f71463          	bne	a4,a5,ffffffe000201a14 <trap_handler+0xe0>
                ret=sys_write((unsigned int)a0,(const char *)a1,(size_t)a2);
ffffffe0002019f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002019f4:	0007879b          	sext.w	a5,a5
ffffffe0002019f8:	fc843703          	ld	a4,-56(s0)
ffffffe0002019fc:	fc043603          	ld	a2,-64(s0)
ffffffe000201a00:	00070593          	mv	a1,a4
ffffffe000201a04:	00078513          	mv	a0,a5
ffffffe000201a08:	e69ff0ef          	jal	ra,ffffffe000201870 <sys_write>
ffffffe000201a0c:	fea43423          	sd	a0,-24(s0)
ffffffe000201a10:	02c0006f          	j	ffffffe000201a3c <trap_handler+0x108>
            }else if(a7==SYS_getpid){
ffffffe000201a14:	fd843703          	ld	a4,-40(s0)
ffffffe000201a18:	0ac00793          	li	a5,172
ffffffe000201a1c:	00f71863          	bne	a4,a5,ffffffe000201a2c <trap_handler+0xf8>
                ret=sys_getpid();
ffffffe000201a20:	ee9ff0ef          	jal	ra,ffffffe000201908 <sys_getpid>
ffffffe000201a24:	fea43423          	sd	a0,-24(s0)
ffffffe000201a28:	0140006f          	j	ffffffe000201a3c <trap_handler+0x108>
            }else{
                printk("unknown syscall %d\n",a7);
ffffffe000201a2c:	fd843583          	ld	a1,-40(s0)
ffffffe000201a30:	00002517          	auipc	a0,0x2
ffffffe000201a34:	6e050513          	addi	a0,a0,1760 # ffffffe000204110 <_srodata+0x110>
ffffffe000201a38:	47c010ef          	jal	ra,ffffffe000202eb4 <printk>
            }
            regs->x[10]=ret; //将返回值写入 a0
ffffffe000201a3c:	f9843783          	ld	a5,-104(s0)
ffffffe000201a40:	fe843703          	ld	a4,-24(s0)
ffffffe000201a44:	04e7b823          	sd	a4,80(a5)
            regs->sepc+=4; //指令地址后移
ffffffe000201a48:	f9843783          	ld	a5,-104(s0)
ffffffe000201a4c:	1007b783          	ld	a5,256(a5)
ffffffe000201a50:	00478713          	addi	a4,a5,4
ffffffe000201a54:	f9843783          	ld	a5,-104(s0)
ffffffe000201a58:	10e7b023          	sd	a4,256(a5)
            return;
ffffffe000201a5c:	0140006f          	j	ffffffe000201a70 <trap_handler+0x13c>
        }

        printk("exception: %d\n", exception_code);
ffffffe000201a60:	fe043583          	ld	a1,-32(s0)
ffffffe000201a64:	00002517          	auipc	a0,0x2
ffffffe000201a68:	6c450513          	addi	a0,a0,1732 # ffffffe000204128 <_srodata+0x128>
ffffffe000201a6c:	448010ef          	jal	ra,ffffffe000202eb4 <printk>
    }   
ffffffe000201a70:	06813083          	ld	ra,104(sp)
ffffffe000201a74:	06013403          	ld	s0,96(sp)
ffffffe000201a78:	07010113          	addi	sp,sp,112
ffffffe000201a7c:	00008067          	ret

ffffffe000201a80 <setup_vm>:
extern char _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000201a80:	fc010113          	addi	sp,sp,-64
ffffffe000201a84:	02813c23          	sd	s0,56(sp)
ffffffe000201a88:	04010413          	addi	s0,sp,64
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   uint64_t pa=0x80000000;
ffffffe000201a8c:	00100793          	li	a5,1
ffffffe000201a90:	01f79793          	slli	a5,a5,0x1f
ffffffe000201a94:	fef43423          	sd	a5,-24(s0)
   uint64_t va_eq=pa;
ffffffe000201a98:	fe843783          	ld	a5,-24(s0)
ffffffe000201a9c:	fef43023          	sd	a5,-32(s0)
   uint64_t va_direct=pa+PA2VA_OFFSET;
ffffffe000201aa0:	fe843703          	ld	a4,-24(s0)
ffffffe000201aa4:	fbf00793          	li	a5,-65
ffffffe000201aa8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201aac:	00f707b3          	add	a5,a4,a5
ffffffe000201ab0:	fcf43c23          	sd	a5,-40(s0)

   uint64_t perm = PTE_V|PTE_R|PTE_W|PTE_X; // V | R | W | X
ffffffe000201ab4:	00f00793          	li	a5,15
ffffffe000201ab8:	fcf43823          	sd	a5,-48(s0)
    //中间 9 bit 作为 early_pgtbl 的 index
   uint64_t idx_eq=(va_eq>>30)&0x1ff; 
ffffffe000201abc:	fe043783          	ld	a5,-32(s0)
ffffffe000201ac0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201ac4:	1ff7f793          	andi	a5,a5,511
ffffffe000201ac8:	fcf43423          	sd	a5,-56(s0)
   uint64_t idx_direct=(va_direct>>30)&0x1ff;
ffffffe000201acc:	fd843783          	ld	a5,-40(s0)
ffffffe000201ad0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201ad4:	1ff7f793          	andi	a5,a5,511
ffffffe000201ad8:	fcf43023          	sd	a5,-64(s0)

    early_pgtbl[idx_eq]= (pa>>12)<<10 | perm;       //等值映射
ffffffe000201adc:	fe843783          	ld	a5,-24(s0)
ffffffe000201ae0:	00c7d793          	srli	a5,a5,0xc
ffffffe000201ae4:	00a79713          	slli	a4,a5,0xa
ffffffe000201ae8:	fd043783          	ld	a5,-48(s0)
ffffffe000201aec:	00f76733          	or	a4,a4,a5
ffffffe000201af0:	0000a697          	auipc	a3,0xa
ffffffe000201af4:	51068693          	addi	a3,a3,1296 # ffffffe00020c000 <early_pgtbl>
ffffffe000201af8:	fc843783          	ld	a5,-56(s0)
ffffffe000201afc:	00379793          	slli	a5,a5,0x3
ffffffe000201b00:	00f687b3          	add	a5,a3,a5
ffffffe000201b04:	00e7b023          	sd	a4,0(a5)
    early_pgtbl[idx_direct]= (pa>>12)<<10 | perm;   //直接映射
ffffffe000201b08:	fe843783          	ld	a5,-24(s0)
ffffffe000201b0c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201b10:	00a79713          	slli	a4,a5,0xa
ffffffe000201b14:	fd043783          	ld	a5,-48(s0)
ffffffe000201b18:	00f76733          	or	a4,a4,a5
ffffffe000201b1c:	0000a697          	auipc	a3,0xa
ffffffe000201b20:	4e468693          	addi	a3,a3,1252 # ffffffe00020c000 <early_pgtbl>
ffffffe000201b24:	fc043783          	ld	a5,-64(s0)
ffffffe000201b28:	00379793          	slli	a5,a5,0x3
ffffffe000201b2c:	00f687b3          	add	a5,a3,a5
ffffffe000201b30:	00e7b023          	sd	a4,0(a5)
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //       pa, va_eq, idx_eq);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //        pa, va_direct, idx_direct);

}
ffffffe000201b34:	00000013          	nop
ffffffe000201b38:	03813403          	ld	s0,56(sp)
ffffffe000201b3c:	04010113          	addi	sp,sp,64
ffffffe000201b40:	00008067          	ret

ffffffe000201b44 <setup_vm_neq>:

void setup_vm_neq(){
ffffffe000201b44:	ff010113          	addi	sp,sp,-16
ffffffe000201b48:	00813423          	sd	s0,8(sp)
ffffffe000201b4c:	01010413          	addi	s0,sp,16

}
ffffffe000201b50:	00000013          	nop
ffffffe000201b54:	00813403          	ld	s0,8(sp)
ffffffe000201b58:	01010113          	addi	sp,sp,16
ffffffe000201b5c:	00008067          	ret

ffffffe000201b60 <create_mapping>:

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000201b60:	f5010113          	addi	sp,sp,-176
ffffffe000201b64:	0a113423          	sd	ra,168(sp)
ffffffe000201b68:	0a813023          	sd	s0,160(sp)
ffffffe000201b6c:	0b010413          	addi	s0,sp,176
ffffffe000201b70:	f6a43c23          	sd	a0,-136(s0)
ffffffe000201b74:	f6b43823          	sd	a1,-144(s0)
ffffffe000201b78:	f6c43423          	sd	a2,-152(s0)
ffffffe000201b7c:	f6d43023          	sd	a3,-160(s0)
ffffffe000201b80:	f4e43c23          	sd	a4,-168(s0)
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_curr=va;
ffffffe000201b84:	f7043783          	ld	a5,-144(s0)
ffffffe000201b88:	fef43423          	sd	a5,-24(s0)
    uint64_t pa_curr=pa;
ffffffe000201b8c:	f6843783          	ld	a5,-152(s0)
ffffffe000201b90:	fef43023          	sd	a5,-32(s0)
    uint64_t va_end=va+sz;
ffffffe000201b94:	f7043703          	ld	a4,-144(s0)
ffffffe000201b98:	f6043783          	ld	a5,-160(s0)
ffffffe000201b9c:	00f707b3          	add	a5,a4,a5
ffffffe000201ba0:	fcf43c23          	sd	a5,-40(s0)

    while(va_curr<va_end){
ffffffe000201ba4:	1bc0006f          	j	ffffffe000201d60 <create_mapping+0x200>
        uint64_t vpn2=(va_curr>>30)&0x1ff;  //VA[39:30]
ffffffe000201ba8:	fe843783          	ld	a5,-24(s0)
ffffffe000201bac:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201bb0:	1ff7f793          	andi	a5,a5,511
ffffffe000201bb4:	fcf43823          	sd	a5,-48(s0)
        uint64_t vpn1=(va_curr>>21)&0x1ff;  //VA[29:21]
ffffffe000201bb8:	fe843783          	ld	a5,-24(s0)
ffffffe000201bbc:	0157d793          	srli	a5,a5,0x15
ffffffe000201bc0:	1ff7f793          	andi	a5,a5,511
ffffffe000201bc4:	fcf43423          	sd	a5,-56(s0)
        uint64_t vpn0=(va_curr>>12)&0x1ff;  //VA[20:12]
ffffffe000201bc8:	fe843783          	ld	a5,-24(s0)
ffffffe000201bcc:	00c7d793          	srli	a5,a5,0xc
ffffffe000201bd0:	1ff7f793          	andi	a5,a5,511
ffffffe000201bd4:	fcf43023          	sd	a5,-64(s0)

        
        if(!(pgtbl[vpn2]&PTE_V)){
ffffffe000201bd8:	fd043783          	ld	a5,-48(s0)
ffffffe000201bdc:	00379793          	slli	a5,a5,0x3
ffffffe000201be0:	f7843703          	ld	a4,-136(s0)
ffffffe000201be4:	00f707b3          	add	a5,a4,a5
ffffffe000201be8:	0007b783          	ld	a5,0(a5)
ffffffe000201bec:	0017f793          	andi	a5,a5,1
ffffffe000201bf0:	04079a63          	bnez	a5,ffffffe000201c44 <create_mapping+0xe4>
            //分配新的二级页表
            uint64_t *patbl2=(uint64_t *)kalloc();
ffffffe000201bf4:	e2dfe0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe000201bf8:	faa43c23          	sd	a0,-72(s0)
            memset(patbl2,0,PGSIZE);
ffffffe000201bfc:	00001637          	lui	a2,0x1
ffffffe000201c00:	00000593          	li	a1,0
ffffffe000201c04:	fb843503          	ld	a0,-72(s0)
ffffffe000201c08:	3cc010ef          	jal	ra,ffffffe000202fd4 <memset>
            //转化物理地址
            uint64_t patbl2_pa=(uint64_t)patbl2-PA2VA_OFFSET;
ffffffe000201c0c:	fb843703          	ld	a4,-72(s0)
ffffffe000201c10:	04100793          	li	a5,65
ffffffe000201c14:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c18:	00f707b3          	add	a5,a4,a5
ffffffe000201c1c:	faf43823          	sd	a5,-80(s0)
            pgtbl[vpn2]=((uint64_t)patbl2_pa>>12)<<10|PTE_V;
ffffffe000201c20:	fb043783          	ld	a5,-80(s0)
ffffffe000201c24:	00c7d793          	srli	a5,a5,0xc
ffffffe000201c28:	00a79713          	slli	a4,a5,0xa
ffffffe000201c2c:	fd043783          	ld	a5,-48(s0)
ffffffe000201c30:	00379793          	slli	a5,a5,0x3
ffffffe000201c34:	f7843683          	ld	a3,-136(s0)
ffffffe000201c38:	00f687b3          	add	a5,a3,a5
ffffffe000201c3c:	00176713          	ori	a4,a4,1
ffffffe000201c40:	00e7b023          	sd	a4,0(a5)
        }
        //二级页表物理地址
        uint64_t patbl2_pa=(uint64_t *)((pgtbl[vpn2]>>10)<<12); 
ffffffe000201c44:	fd043783          	ld	a5,-48(s0)
ffffffe000201c48:	00379793          	slli	a5,a5,0x3
ffffffe000201c4c:	f7843703          	ld	a4,-136(s0)
ffffffe000201c50:	00f707b3          	add	a5,a4,a5
ffffffe000201c54:	0007b783          	ld	a5,0(a5)
ffffffe000201c58:	00a7d793          	srli	a5,a5,0xa
ffffffe000201c5c:	00c79793          	slli	a5,a5,0xc
ffffffe000201c60:	faf43423          	sd	a5,-88(s0)
        uint64_t *patbl2=(uint64_t *)(patbl2_pa+PA2VA_OFFSET);              
ffffffe000201c64:	fa843703          	ld	a4,-88(s0)
ffffffe000201c68:	fbf00793          	li	a5,-65
ffffffe000201c6c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c70:	00f707b3          	add	a5,a4,a5
ffffffe000201c74:	faf43023          	sd	a5,-96(s0)

        if(!(patbl2[vpn1]&PTE_V)){
ffffffe000201c78:	fc843783          	ld	a5,-56(s0)
ffffffe000201c7c:	00379793          	slli	a5,a5,0x3
ffffffe000201c80:	fa043703          	ld	a4,-96(s0)
ffffffe000201c84:	00f707b3          	add	a5,a4,a5
ffffffe000201c88:	0007b783          	ld	a5,0(a5)
ffffffe000201c8c:	0017f793          	andi	a5,a5,1
ffffffe000201c90:	04079a63          	bnez	a5,ffffffe000201ce4 <create_mapping+0x184>
            uint64_t *patbl1=(uint64_t *)kalloc();
ffffffe000201c94:	d8dfe0ef          	jal	ra,ffffffe000200a20 <kalloc>
ffffffe000201c98:	f8a43c23          	sd	a0,-104(s0)
            memset(patbl1,0,PGSIZE);
ffffffe000201c9c:	00001637          	lui	a2,0x1
ffffffe000201ca0:	00000593          	li	a1,0
ffffffe000201ca4:	f9843503          	ld	a0,-104(s0)
ffffffe000201ca8:	32c010ef          	jal	ra,ffffffe000202fd4 <memset>
            uint64_t patbl1_pa=(uint64_t)patbl1-PA2VA_OFFSET;
ffffffe000201cac:	f9843703          	ld	a4,-104(s0)
ffffffe000201cb0:	04100793          	li	a5,65
ffffffe000201cb4:	01f79793          	slli	a5,a5,0x1f
ffffffe000201cb8:	00f707b3          	add	a5,a4,a5
ffffffe000201cbc:	f8f43823          	sd	a5,-112(s0)
            patbl2[vpn1]=((uint64_t)patbl1_pa>>12)<<10|PTE_V;
ffffffe000201cc0:	f9043783          	ld	a5,-112(s0)
ffffffe000201cc4:	00c7d793          	srli	a5,a5,0xc
ffffffe000201cc8:	00a79713          	slli	a4,a5,0xa
ffffffe000201ccc:	fc843783          	ld	a5,-56(s0)
ffffffe000201cd0:	00379793          	slli	a5,a5,0x3
ffffffe000201cd4:	fa043683          	ld	a3,-96(s0)
ffffffe000201cd8:	00f687b3          	add	a5,a3,a5
ffffffe000201cdc:	00176713          	ori	a4,a4,1
ffffffe000201ce0:	00e7b023          	sd	a4,0(a5)
        }
        //三级页表物理地址
        uint64_t patbl1_pa=(uint64_t *)((patbl2[vpn1]>>10)<<12); 
ffffffe000201ce4:	fc843783          	ld	a5,-56(s0)
ffffffe000201ce8:	00379793          	slli	a5,a5,0x3
ffffffe000201cec:	fa043703          	ld	a4,-96(s0)
ffffffe000201cf0:	00f707b3          	add	a5,a4,a5
ffffffe000201cf4:	0007b783          	ld	a5,0(a5)
ffffffe000201cf8:	00a7d793          	srli	a5,a5,0xa
ffffffe000201cfc:	00c79793          	slli	a5,a5,0xc
ffffffe000201d00:	f8f43423          	sd	a5,-120(s0)
        uint64_t *patbl1=(uint64_t *)(patbl1_pa+PA2VA_OFFSET);
ffffffe000201d04:	f8843703          	ld	a4,-120(s0)
ffffffe000201d08:	fbf00793          	li	a5,-65
ffffffe000201d0c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201d10:	00f707b3          	add	a5,a4,a5
ffffffe000201d14:	f8f43023          	sd	a5,-128(s0)
        //最终页表项
        patbl1[vpn0]=(pa_curr>>12)<<10|perm;
ffffffe000201d18:	fe043783          	ld	a5,-32(s0)
ffffffe000201d1c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201d20:	00a79693          	slli	a3,a5,0xa
ffffffe000201d24:	fc043783          	ld	a5,-64(s0)
ffffffe000201d28:	00379793          	slli	a5,a5,0x3
ffffffe000201d2c:	f8043703          	ld	a4,-128(s0)
ffffffe000201d30:	00f707b3          	add	a5,a4,a5
ffffffe000201d34:	f5843703          	ld	a4,-168(s0)
ffffffe000201d38:	00e6e733          	or	a4,a3,a4
ffffffe000201d3c:	00e7b023          	sd	a4,0(a5)

        va_curr+=PGSIZE;
ffffffe000201d40:	fe843703          	ld	a4,-24(s0)
ffffffe000201d44:	000017b7          	lui	a5,0x1
ffffffe000201d48:	00f707b3          	add	a5,a4,a5
ffffffe000201d4c:	fef43423          	sd	a5,-24(s0)
        pa_curr+=PGSIZE;
ffffffe000201d50:	fe043703          	ld	a4,-32(s0)
ffffffe000201d54:	000017b7          	lui	a5,0x1
ffffffe000201d58:	00f707b3          	add	a5,a4,a5
ffffffe000201d5c:	fef43023          	sd	a5,-32(s0)
    while(va_curr<va_end){
ffffffe000201d60:	fe843703          	ld	a4,-24(s0)
ffffffe000201d64:	fd843783          	ld	a5,-40(s0)
ffffffe000201d68:	e4f760e3          	bltu	a4,a5,ffffffe000201ba8 <create_mapping+0x48>
    }
}
ffffffe000201d6c:	00000013          	nop
ffffffe000201d70:	00000013          	nop
ffffffe000201d74:	0a813083          	ld	ra,168(sp)
ffffffe000201d78:	0a013403          	ld	s0,160(sp)
ffffffe000201d7c:	0b010113          	addi	sp,sp,176
ffffffe000201d80:	00008067          	ret

ffffffe000201d84 <setup_vm_final>:

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
ffffffe000201d84:	fe010113          	addi	sp,sp,-32
ffffffe000201d88:	00113c23          	sd	ra,24(sp)
ffffffe000201d8c:	00813823          	sd	s0,16(sp)
ffffffe000201d90:	02010413          	addi	s0,sp,32
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000201d94:	00001637          	lui	a2,0x1
ffffffe000201d98:	00000593          	li	a1,0
ffffffe000201d9c:	00008517          	auipc	a0,0x8
ffffffe000201da0:	26450513          	addi	a0,a0,612 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201da4:	230010ef          	jal	ra,ffffffe000202fd4 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201da8:	ffffe597          	auipc	a1,0xffffe
ffffffe000201dac:	25858593          	addi	a1,a1,600 # ffffffe000200000 <_skernel>
ffffffe000201db0:	ffffe717          	auipc	a4,0xffffe
ffffffe000201db4:	25070713          	addi	a4,a4,592 # ffffffe000200000 <_skernel>
ffffffe000201db8:	04100793          	li	a5,65
ffffffe000201dbc:	01f79793          	slli	a5,a5,0x1f
ffffffe000201dc0:	00f707b3          	add	a5,a4,a5
ffffffe000201dc4:	00078613          	mv	a2,a5
                   (uint64_t)(_etext - _stext),PTE_X|PTE_R|PTE_V);
ffffffe000201dc8:	00001717          	auipc	a4,0x1
ffffffe000201dcc:	27c70713          	addi	a4,a4,636 # ffffffe000203044 <_etext>
ffffffe000201dd0:	ffffe797          	auipc	a5,0xffffe
ffffffe000201dd4:	23078793          	addi	a5,a5,560 # ffffffe000200000 <_skernel>
ffffffe000201dd8:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201ddc:	00b00713          	li	a4,11
ffffffe000201de0:	00078693          	mv	a3,a5
ffffffe000201de4:	00008517          	auipc	a0,0x8
ffffffe000201de8:	21c50513          	addi	a0,a0,540 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201dec:	d75ff0ef          	jal	ra,ffffffe000201b60 <create_mapping>
    printk("setup_vm_final: mapping kernel text done!\n");
ffffffe000201df0:	00002517          	auipc	a0,0x2
ffffffe000201df4:	34850513          	addi	a0,a0,840 # ffffffe000204138 <_srodata+0x138>
ffffffe000201df8:	0bc010ef          	jal	ra,ffffffe000202eb4 <printk>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201dfc:	00002597          	auipc	a1,0x2
ffffffe000201e00:	20458593          	addi	a1,a1,516 # ffffffe000204000 <_srodata>
ffffffe000201e04:	00002717          	auipc	a4,0x2
ffffffe000201e08:	1fc70713          	addi	a4,a4,508 # ffffffe000204000 <_srodata>
ffffffe000201e0c:	04100793          	li	a5,65
ffffffe000201e10:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e14:	00f707b3          	add	a5,a4,a5
ffffffe000201e18:	00078613          	mv	a2,a5
                   (uint64_t)(_erodata - _srodata),PTE_R|PTE_V);
ffffffe000201e1c:	00002717          	auipc	a4,0x2
ffffffe000201e20:	47c70713          	addi	a4,a4,1148 # ffffffe000204298 <_erodata>
ffffffe000201e24:	00002797          	auipc	a5,0x2
ffffffe000201e28:	1dc78793          	addi	a5,a5,476 # ffffffe000204000 <_srodata>
ffffffe000201e2c:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201e30:	00300713          	li	a4,3
ffffffe000201e34:	00078693          	mv	a3,a5
ffffffe000201e38:	00008517          	auipc	a0,0x8
ffffffe000201e3c:	1c850513          	addi	a0,a0,456 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201e40:	d21ff0ef          	jal	ra,ffffffe000201b60 <create_mapping>
    printk("setup_vm_final: mapping kernel rodata done!\n");
ffffffe000201e44:	00002517          	auipc	a0,0x2
ffffffe000201e48:	32450513          	addi	a0,a0,804 # ffffffe000204168 <_srodata+0x168>
ffffffe000201e4c:	068010ef          	jal	ra,ffffffe000202eb4 <printk>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201e50:	00003597          	auipc	a1,0x3
ffffffe000201e54:	1b058593          	addi	a1,a1,432 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e58:	00003717          	auipc	a4,0x3
ffffffe000201e5c:	1a870713          	addi	a4,a4,424 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e60:	04100793          	li	a5,65
ffffffe000201e64:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e68:	00f707b3          	add	a5,a4,a5
ffffffe000201e6c:	00078613          	mv	a2,a5
                   (uint64_t)(PHY_END-((uint64_t)_sdata-PA2VA_OFFSET)),PTE_W|PTE_R|PTE_V);
ffffffe000201e70:	00003797          	auipc	a5,0x3
ffffffe000201e74:	19078793          	addi	a5,a5,400 # ffffffe000205000 <TIMECLOCK>
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201e78:	c0100713          	li	a4,-1023
ffffffe000201e7c:	01b71713          	slli	a4,a4,0x1b
ffffffe000201e80:	40f707b3          	sub	a5,a4,a5
ffffffe000201e84:	00700713          	li	a4,7
ffffffe000201e88:	00078693          	mv	a3,a5
ffffffe000201e8c:	00008517          	auipc	a0,0x8
ffffffe000201e90:	17450513          	addi	a0,a0,372 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201e94:	ccdff0ef          	jal	ra,ffffffe000201b60 <create_mapping>
    printk("setup_vm_final: mapping other memory done!\n");
ffffffe000201e98:	00002517          	auipc	a0,0x2
ffffffe000201e9c:	30050513          	addi	a0,a0,768 # ffffffe000204198 <_srodata+0x198>
ffffffe000201ea0:	014010ef          	jal	ra,ffffffe000202eb4 <printk>

    // set satp with swapper_pg_dir
    uint64_t satp_val=0;
ffffffe000201ea4:	fe043423          	sd	zero,-24(s0)
    satp_val|=(8ULL<<60);                          // MODE=8 Sv39
ffffffe000201ea8:	fe843703          	ld	a4,-24(s0)
ffffffe000201eac:	fff00793          	li	a5,-1
ffffffe000201eb0:	03f79793          	slli	a5,a5,0x3f
ffffffe000201eb4:	00f767b3          	or	a5,a4,a5
ffffffe000201eb8:	fef43423          	sd	a5,-24(s0)
    satp_val|=(((uint64_t)swapper_pg_dir-PA2VA_OFFSET)>>12);   // PPN
ffffffe000201ebc:	00008717          	auipc	a4,0x8
ffffffe000201ec0:	14470713          	addi	a4,a4,324 # ffffffe00020a000 <swapper_pg_dir>
ffffffe000201ec4:	04100793          	li	a5,65
ffffffe000201ec8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201ecc:	00f707b3          	add	a5,a4,a5
ffffffe000201ed0:	00c7d793          	srli	a5,a5,0xc
ffffffe000201ed4:	fe843703          	ld	a4,-24(s0)
ffffffe000201ed8:	00f767b3          	or	a5,a4,a5
ffffffe000201edc:	fef43423          	sd	a5,-24(s0)
    csr_write(satp,satp_val);
ffffffe000201ee0:	fe843783          	ld	a5,-24(s0)
ffffffe000201ee4:	fef43023          	sd	a5,-32(s0)
ffffffe000201ee8:	fe043783          	ld	a5,-32(s0)
ffffffe000201eec:	18079073          	csrw	satp,a5

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201ef0:	12000073          	sfence.vma
    return;
ffffffe000201ef4:	00000013          	nop
}
ffffffe000201ef8:	01813083          	ld	ra,24(sp)
ffffffe000201efc:	01013403          	ld	s0,16(sp)
ffffffe000201f00:	02010113          	addi	sp,sp,32
ffffffe000201f04:	00008067          	ret

ffffffe000201f08 <test_rw>:
extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];

void test_rw(){
ffffffe000201f08:	ff010113          	addi	sp,sp,-16
ffffffe000201f0c:	00113423          	sd	ra,8(sp)
ffffffe000201f10:	00813023          	sd	s0,0(sp)
ffffffe000201f14:	01010413          	addi	s0,sp,16
    printk("stext read:%lx\n",&_stext);
ffffffe000201f18:	ffffe597          	auipc	a1,0xffffe
ffffffe000201f1c:	0e858593          	addi	a1,a1,232 # ffffffe000200000 <_skernel>
ffffffe000201f20:	00002517          	auipc	a0,0x2
ffffffe000201f24:	2a850513          	addi	a0,a0,680 # ffffffe0002041c8 <_srodata+0x1c8>
ffffffe000201f28:	78d000ef          	jal	ra,ffffffe000202eb4 <printk>
    printk("srodata read:%lx\n",&_srodata);
ffffffe000201f2c:	00002597          	auipc	a1,0x2
ffffffe000201f30:	0d458593          	addi	a1,a1,212 # ffffffe000204000 <_srodata>
ffffffe000201f34:	00002517          	auipc	a0,0x2
ffffffe000201f38:	2a450513          	addi	a0,a0,676 # ffffffe0002041d8 <_srodata+0x1d8>
ffffffe000201f3c:	779000ef          	jal	ra,ffffffe000202eb4 <printk>
    // }
    // *_srodata=0x1;
    // if(*_srodata==0x1){
    //     printk("srodata write: success\n");
    // }
}
ffffffe000201f40:	00000013          	nop
ffffffe000201f44:	00813083          	ld	ra,8(sp)
ffffffe000201f48:	00013403          	ld	s0,0(sp)
ffffffe000201f4c:	01010113          	addi	sp,sp,16
ffffffe000201f50:	00008067          	ret

ffffffe000201f54 <test_exe>:

void test_exe(){
ffffffe000201f54:	fe010113          	addi	sp,sp,-32
ffffffe000201f58:	00113c23          	sd	ra,24(sp)
ffffffe000201f5c:	00813823          	sd	s0,16(sp)
ffffffe000201f60:	02010413          	addi	s0,sp,32
    typedef void (*func_ptr)(void);

    func_ptr func = (func_ptr)_srodata;
ffffffe000201f64:	00002797          	auipc	a5,0x2
ffffffe000201f68:	09c78793          	addi	a5,a5,156 # ffffffe000204000 <_srodata>
ffffffe000201f6c:	fef43423          	sd	a5,-24(s0)
    func();
ffffffe000201f70:	fe843783          	ld	a5,-24(s0)
ffffffe000201f74:	000780e7          	jalr	a5
    printk("execute stext success\n");
ffffffe000201f78:	00002517          	auipc	a0,0x2
ffffffe000201f7c:	27850513          	addi	a0,a0,632 # ffffffe0002041f0 <_srodata+0x1f0>
ffffffe000201f80:	735000ef          	jal	ra,ffffffe000202eb4 <printk>

}
ffffffe000201f84:	00000013          	nop
ffffffe000201f88:	01813083          	ld	ra,24(sp)
ffffffe000201f8c:	01013403          	ld	s0,16(sp)
ffffffe000201f90:	02010113          	addi	sp,sp,32
ffffffe000201f94:	00008067          	ret

ffffffe000201f98 <start_kernel>:

int start_kernel() {
ffffffe000201f98:	ff010113          	addi	sp,sp,-16
ffffffe000201f9c:	00113423          	sd	ra,8(sp)
ffffffe000201fa0:	00813023          	sd	s0,0(sp)
ffffffe000201fa4:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201fa8:	00002517          	auipc	a0,0x2
ffffffe000201fac:	26050513          	addi	a0,a0,608 # ffffffe000204208 <_srodata+0x208>
ffffffe000201fb0:	705000ef          	jal	ra,ffffffe000202eb4 <printk>
    printk(" ZJU Operating System\n");
ffffffe000201fb4:	00002517          	auipc	a0,0x2
ffffffe000201fb8:	25c50513          	addi	a0,a0,604 # ffffffe000204210 <_srodata+0x210>
ffffffe000201fbc:	6f9000ef          	jal	ra,ffffffe000202eb4 <printk>
    schedule();
ffffffe000201fc0:	c18ff0ef          	jal	ra,ffffffe0002013d8 <schedule>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
ffffffe000201fc4:	01c000ef          	jal	ra,ffffffe000201fe0 <test>
    return 0;
ffffffe000201fc8:	00000793          	li	a5,0
}
ffffffe000201fcc:	00078513          	mv	a0,a5
ffffffe000201fd0:	00813083          	ld	ra,8(sp)
ffffffe000201fd4:	00013403          	ld	s0,0(sp)
ffffffe000201fd8:	01010113          	addi	sp,sp,16
ffffffe000201fdc:	00008067          	ret

ffffffe000201fe0 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
ffffffe000201fe0:	fe010113          	addi	sp,sp,-32
ffffffe000201fe4:	00113c23          	sd	ra,24(sp)
ffffffe000201fe8:	00813823          	sd	s0,16(sp)
ffffffe000201fec:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
ffffffe000201ff0:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000201ff4:	fec42783          	lw	a5,-20(s0)
ffffffe000201ff8:	0017879b          	addiw	a5,a5,1
ffffffe000201ffc:	fef42623          	sw	a5,-20(s0)
ffffffe000202000:	fec42703          	lw	a4,-20(s0)
ffffffe000202004:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000202008:	1007879b          	addiw	a5,a5,256
ffffffe00020200c:	02f767bb          	remw	a5,a4,a5
ffffffe000202010:	0007879b          	sext.w	a5,a5
ffffffe000202014:	fe0790e3          	bnez	a5,ffffffe000201ff4 <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
ffffffe000202018:	00002517          	auipc	a0,0x2
ffffffe00020201c:	21050513          	addi	a0,a0,528 # ffffffe000204228 <_srodata+0x228>
ffffffe000202020:	695000ef          	jal	ra,ffffffe000202eb4 <printk>
            i = 0;
ffffffe000202024:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000202028:	fcdff06f          	j	ffffffe000201ff4 <test+0x14>

ffffffe00020202c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe00020202c:	fe010113          	addi	sp,sp,-32
ffffffe000202030:	00113c23          	sd	ra,24(sp)
ffffffe000202034:	00813823          	sd	s0,16(sp)
ffffffe000202038:	02010413          	addi	s0,sp,32
ffffffe00020203c:	00050793          	mv	a5,a0
ffffffe000202040:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000202044:	fec42783          	lw	a5,-20(s0)
ffffffe000202048:	0ff7f793          	andi	a5,a5,255
ffffffe00020204c:	00078513          	mv	a0,a5
ffffffe000202050:	ee4ff0ef          	jal	ra,ffffffe000201734 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000202054:	fec42783          	lw	a5,-20(s0)
ffffffe000202058:	0ff7f793          	andi	a5,a5,255
ffffffe00020205c:	0007879b          	sext.w	a5,a5
}
ffffffe000202060:	00078513          	mv	a0,a5
ffffffe000202064:	01813083          	ld	ra,24(sp)
ffffffe000202068:	01013403          	ld	s0,16(sp)
ffffffe00020206c:	02010113          	addi	sp,sp,32
ffffffe000202070:	00008067          	ret

ffffffe000202074 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000202074:	fe010113          	addi	sp,sp,-32
ffffffe000202078:	00813c23          	sd	s0,24(sp)
ffffffe00020207c:	02010413          	addi	s0,sp,32
ffffffe000202080:	00050793          	mv	a5,a0
ffffffe000202084:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202088:	fec42783          	lw	a5,-20(s0)
ffffffe00020208c:	0007871b          	sext.w	a4,a5
ffffffe000202090:	02000793          	li	a5,32
ffffffe000202094:	02f70263          	beq	a4,a5,ffffffe0002020b8 <isspace+0x44>
ffffffe000202098:	fec42783          	lw	a5,-20(s0)
ffffffe00020209c:	0007871b          	sext.w	a4,a5
ffffffe0002020a0:	00800793          	li	a5,8
ffffffe0002020a4:	00e7de63          	bge	a5,a4,ffffffe0002020c0 <isspace+0x4c>
ffffffe0002020a8:	fec42783          	lw	a5,-20(s0)
ffffffe0002020ac:	0007871b          	sext.w	a4,a5
ffffffe0002020b0:	00d00793          	li	a5,13
ffffffe0002020b4:	00e7c663          	blt	a5,a4,ffffffe0002020c0 <isspace+0x4c>
ffffffe0002020b8:	00100793          	li	a5,1
ffffffe0002020bc:	0080006f          	j	ffffffe0002020c4 <isspace+0x50>
ffffffe0002020c0:	00000793          	li	a5,0
}
ffffffe0002020c4:	00078513          	mv	a0,a5
ffffffe0002020c8:	01813403          	ld	s0,24(sp)
ffffffe0002020cc:	02010113          	addi	sp,sp,32
ffffffe0002020d0:	00008067          	ret

ffffffe0002020d4 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe0002020d4:	fb010113          	addi	sp,sp,-80
ffffffe0002020d8:	04113423          	sd	ra,72(sp)
ffffffe0002020dc:	04813023          	sd	s0,64(sp)
ffffffe0002020e0:	05010413          	addi	s0,sp,80
ffffffe0002020e4:	fca43423          	sd	a0,-56(s0)
ffffffe0002020e8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002020ec:	00060793          	mv	a5,a2
ffffffe0002020f0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe0002020f4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe0002020f8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe0002020fc:	fc843783          	ld	a5,-56(s0)
ffffffe000202100:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000202104:	0100006f          	j	ffffffe000202114 <strtol+0x40>
        p++;
ffffffe000202108:	fd843783          	ld	a5,-40(s0)
ffffffe00020210c:	00178793          	addi	a5,a5,1 # 5f5e001 <OPENSBI_SIZE+0x5d5e001>
ffffffe000202110:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000202114:	fd843783          	ld	a5,-40(s0)
ffffffe000202118:	0007c783          	lbu	a5,0(a5)
ffffffe00020211c:	0007879b          	sext.w	a5,a5
ffffffe000202120:	00078513          	mv	a0,a5
ffffffe000202124:	f51ff0ef          	jal	ra,ffffffe000202074 <isspace>
ffffffe000202128:	00050793          	mv	a5,a0
ffffffe00020212c:	fc079ee3          	bnez	a5,ffffffe000202108 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000202130:	fd843783          	ld	a5,-40(s0)
ffffffe000202134:	0007c783          	lbu	a5,0(a5)
ffffffe000202138:	00078713          	mv	a4,a5
ffffffe00020213c:	02d00793          	li	a5,45
ffffffe000202140:	00f71e63          	bne	a4,a5,ffffffe00020215c <strtol+0x88>
        neg = true;
ffffffe000202144:	00100793          	li	a5,1
ffffffe000202148:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe00020214c:	fd843783          	ld	a5,-40(s0)
ffffffe000202150:	00178793          	addi	a5,a5,1
ffffffe000202154:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202158:	0240006f          	j	ffffffe00020217c <strtol+0xa8>
    } else if (*p == '+') {
ffffffe00020215c:	fd843783          	ld	a5,-40(s0)
ffffffe000202160:	0007c783          	lbu	a5,0(a5)
ffffffe000202164:	00078713          	mv	a4,a5
ffffffe000202168:	02b00793          	li	a5,43
ffffffe00020216c:	00f71863          	bne	a4,a5,ffffffe00020217c <strtol+0xa8>
        p++;
ffffffe000202170:	fd843783          	ld	a5,-40(s0)
ffffffe000202174:	00178793          	addi	a5,a5,1
ffffffe000202178:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe00020217c:	fbc42783          	lw	a5,-68(s0)
ffffffe000202180:	0007879b          	sext.w	a5,a5
ffffffe000202184:	06079c63          	bnez	a5,ffffffe0002021fc <strtol+0x128>
        if (*p == '0') {
ffffffe000202188:	fd843783          	ld	a5,-40(s0)
ffffffe00020218c:	0007c783          	lbu	a5,0(a5)
ffffffe000202190:	00078713          	mv	a4,a5
ffffffe000202194:	03000793          	li	a5,48
ffffffe000202198:	04f71e63          	bne	a4,a5,ffffffe0002021f4 <strtol+0x120>
            p++;
ffffffe00020219c:	fd843783          	ld	a5,-40(s0)
ffffffe0002021a0:	00178793          	addi	a5,a5,1
ffffffe0002021a4:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe0002021a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002021ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002021b0:	00078713          	mv	a4,a5
ffffffe0002021b4:	07800793          	li	a5,120
ffffffe0002021b8:	00f70c63          	beq	a4,a5,ffffffe0002021d0 <strtol+0xfc>
ffffffe0002021bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002021c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002021c4:	00078713          	mv	a4,a5
ffffffe0002021c8:	05800793          	li	a5,88
ffffffe0002021cc:	00f71e63          	bne	a4,a5,ffffffe0002021e8 <strtol+0x114>
                base = 16;
ffffffe0002021d0:	01000793          	li	a5,16
ffffffe0002021d4:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe0002021d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002021dc:	00178793          	addi	a5,a5,1
ffffffe0002021e0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002021e4:	0180006f          	j	ffffffe0002021fc <strtol+0x128>
            } else {
                base = 8;
ffffffe0002021e8:	00800793          	li	a5,8
ffffffe0002021ec:	faf42e23          	sw	a5,-68(s0)
ffffffe0002021f0:	00c0006f          	j	ffffffe0002021fc <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe0002021f4:	00a00793          	li	a5,10
ffffffe0002021f8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe0002021fc:	fd843783          	ld	a5,-40(s0)
ffffffe000202200:	0007c783          	lbu	a5,0(a5)
ffffffe000202204:	00078713          	mv	a4,a5
ffffffe000202208:	02f00793          	li	a5,47
ffffffe00020220c:	02e7f863          	bgeu	a5,a4,ffffffe00020223c <strtol+0x168>
ffffffe000202210:	fd843783          	ld	a5,-40(s0)
ffffffe000202214:	0007c783          	lbu	a5,0(a5)
ffffffe000202218:	00078713          	mv	a4,a5
ffffffe00020221c:	03900793          	li	a5,57
ffffffe000202220:	00e7ee63          	bltu	a5,a4,ffffffe00020223c <strtol+0x168>
            digit = *p - '0';
ffffffe000202224:	fd843783          	ld	a5,-40(s0)
ffffffe000202228:	0007c783          	lbu	a5,0(a5)
ffffffe00020222c:	0007879b          	sext.w	a5,a5
ffffffe000202230:	fd07879b          	addiw	a5,a5,-48
ffffffe000202234:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202238:	0800006f          	j	ffffffe0002022b8 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe00020223c:	fd843783          	ld	a5,-40(s0)
ffffffe000202240:	0007c783          	lbu	a5,0(a5)
ffffffe000202244:	00078713          	mv	a4,a5
ffffffe000202248:	06000793          	li	a5,96
ffffffe00020224c:	02e7f863          	bgeu	a5,a4,ffffffe00020227c <strtol+0x1a8>
ffffffe000202250:	fd843783          	ld	a5,-40(s0)
ffffffe000202254:	0007c783          	lbu	a5,0(a5)
ffffffe000202258:	00078713          	mv	a4,a5
ffffffe00020225c:	07a00793          	li	a5,122
ffffffe000202260:	00e7ee63          	bltu	a5,a4,ffffffe00020227c <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000202264:	fd843783          	ld	a5,-40(s0)
ffffffe000202268:	0007c783          	lbu	a5,0(a5)
ffffffe00020226c:	0007879b          	sext.w	a5,a5
ffffffe000202270:	fa97879b          	addiw	a5,a5,-87
ffffffe000202274:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202278:	0400006f          	j	ffffffe0002022b8 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe00020227c:	fd843783          	ld	a5,-40(s0)
ffffffe000202280:	0007c783          	lbu	a5,0(a5)
ffffffe000202284:	00078713          	mv	a4,a5
ffffffe000202288:	04000793          	li	a5,64
ffffffe00020228c:	06e7f663          	bgeu	a5,a4,ffffffe0002022f8 <strtol+0x224>
ffffffe000202290:	fd843783          	ld	a5,-40(s0)
ffffffe000202294:	0007c783          	lbu	a5,0(a5)
ffffffe000202298:	00078713          	mv	a4,a5
ffffffe00020229c:	05a00793          	li	a5,90
ffffffe0002022a0:	04e7ec63          	bltu	a5,a4,ffffffe0002022f8 <strtol+0x224>
            digit = *p - ('A' - 10);
ffffffe0002022a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002022a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002022ac:	0007879b          	sext.w	a5,a5
ffffffe0002022b0:	fc97879b          	addiw	a5,a5,-55
ffffffe0002022b4:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe0002022b8:	fd442703          	lw	a4,-44(s0)
ffffffe0002022bc:	fbc42783          	lw	a5,-68(s0)
ffffffe0002022c0:	0007071b          	sext.w	a4,a4
ffffffe0002022c4:	0007879b          	sext.w	a5,a5
ffffffe0002022c8:	02f75663          	bge	a4,a5,ffffffe0002022f4 <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
ffffffe0002022cc:	fbc42703          	lw	a4,-68(s0)
ffffffe0002022d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002022d4:	02f70733          	mul	a4,a4,a5
ffffffe0002022d8:	fd442783          	lw	a5,-44(s0)
ffffffe0002022dc:	00f707b3          	add	a5,a4,a5
ffffffe0002022e0:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe0002022e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002022e8:	00178793          	addi	a5,a5,1
ffffffe0002022ec:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe0002022f0:	f0dff06f          	j	ffffffe0002021fc <strtol+0x128>
            break;
ffffffe0002022f4:	00000013          	nop
    }

    if (endptr) {
ffffffe0002022f8:	fc043783          	ld	a5,-64(s0)
ffffffe0002022fc:	00078863          	beqz	a5,ffffffe00020230c <strtol+0x238>
        *endptr = (char *)p;
ffffffe000202300:	fc043783          	ld	a5,-64(s0)
ffffffe000202304:	fd843703          	ld	a4,-40(s0)
ffffffe000202308:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe00020230c:	fe744783          	lbu	a5,-25(s0)
ffffffe000202310:	0ff7f793          	andi	a5,a5,255
ffffffe000202314:	00078863          	beqz	a5,ffffffe000202324 <strtol+0x250>
ffffffe000202318:	fe843783          	ld	a5,-24(s0)
ffffffe00020231c:	40f007b3          	neg	a5,a5
ffffffe000202320:	0080006f          	j	ffffffe000202328 <strtol+0x254>
ffffffe000202324:	fe843783          	ld	a5,-24(s0)
}
ffffffe000202328:	00078513          	mv	a0,a5
ffffffe00020232c:	04813083          	ld	ra,72(sp)
ffffffe000202330:	04013403          	ld	s0,64(sp)
ffffffe000202334:	05010113          	addi	sp,sp,80
ffffffe000202338:	00008067          	ret

ffffffe00020233c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe00020233c:	fd010113          	addi	sp,sp,-48
ffffffe000202340:	02113423          	sd	ra,40(sp)
ffffffe000202344:	02813023          	sd	s0,32(sp)
ffffffe000202348:	03010413          	addi	s0,sp,48
ffffffe00020234c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202350:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000202354:	fd043783          	ld	a5,-48(s0)
ffffffe000202358:	00079863          	bnez	a5,ffffffe000202368 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe00020235c:	00002797          	auipc	a5,0x2
ffffffe000202360:	ee478793          	addi	a5,a5,-284 # ffffffe000204240 <_srodata+0x240>
ffffffe000202364:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000202368:	fd043783          	ld	a5,-48(s0)
ffffffe00020236c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000202370:	0240006f          	j	ffffffe000202394 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000202374:	fe843783          	ld	a5,-24(s0)
ffffffe000202378:	00178713          	addi	a4,a5,1
ffffffe00020237c:	fee43423          	sd	a4,-24(s0)
ffffffe000202380:	0007c783          	lbu	a5,0(a5)
ffffffe000202384:	0007879b          	sext.w	a5,a5
ffffffe000202388:	fd843703          	ld	a4,-40(s0)
ffffffe00020238c:	00078513          	mv	a0,a5
ffffffe000202390:	000700e7          	jalr	a4
    while (*p) {
ffffffe000202394:	fe843783          	ld	a5,-24(s0)
ffffffe000202398:	0007c783          	lbu	a5,0(a5)
ffffffe00020239c:	fc079ce3          	bnez	a5,ffffffe000202374 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe0002023a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002023a4:	fd043783          	ld	a5,-48(s0)
ffffffe0002023a8:	40f707b3          	sub	a5,a4,a5
ffffffe0002023ac:	0007879b          	sext.w	a5,a5
}
ffffffe0002023b0:	00078513          	mv	a0,a5
ffffffe0002023b4:	02813083          	ld	ra,40(sp)
ffffffe0002023b8:	02013403          	ld	s0,32(sp)
ffffffe0002023bc:	03010113          	addi	sp,sp,48
ffffffe0002023c0:	00008067          	ret

ffffffe0002023c4 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe0002023c4:	f9010113          	addi	sp,sp,-112
ffffffe0002023c8:	06113423          	sd	ra,104(sp)
ffffffe0002023cc:	06813023          	sd	s0,96(sp)
ffffffe0002023d0:	07010413          	addi	s0,sp,112
ffffffe0002023d4:	faa43423          	sd	a0,-88(s0)
ffffffe0002023d8:	fab43023          	sd	a1,-96(s0)
ffffffe0002023dc:	00060793          	mv	a5,a2
ffffffe0002023e0:	f8d43823          	sd	a3,-112(s0)
ffffffe0002023e4:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe0002023e8:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002023ec:	0ff7f793          	andi	a5,a5,255
ffffffe0002023f0:	02078663          	beqz	a5,ffffffe00020241c <print_dec_int+0x58>
ffffffe0002023f4:	fa043703          	ld	a4,-96(s0)
ffffffe0002023f8:	fff00793          	li	a5,-1
ffffffe0002023fc:	03f79793          	slli	a5,a5,0x3f
ffffffe000202400:	00f71e63          	bne	a4,a5,ffffffe00020241c <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202404:	00002597          	auipc	a1,0x2
ffffffe000202408:	e4458593          	addi	a1,a1,-444 # ffffffe000204248 <_srodata+0x248>
ffffffe00020240c:	fa843503          	ld	a0,-88(s0)
ffffffe000202410:	f2dff0ef          	jal	ra,ffffffe00020233c <puts_wo_nl>
ffffffe000202414:	00050793          	mv	a5,a0
ffffffe000202418:	2980006f          	j	ffffffe0002026b0 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe00020241c:	f9043783          	ld	a5,-112(s0)
ffffffe000202420:	00c7a783          	lw	a5,12(a5)
ffffffe000202424:	00079a63          	bnez	a5,ffffffe000202438 <print_dec_int+0x74>
ffffffe000202428:	fa043783          	ld	a5,-96(s0)
ffffffe00020242c:	00079663          	bnez	a5,ffffffe000202438 <print_dec_int+0x74>
        return 0;
ffffffe000202430:	00000793          	li	a5,0
ffffffe000202434:	27c0006f          	j	ffffffe0002026b0 <print_dec_int+0x2ec>
    }

    bool neg = false;
ffffffe000202438:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe00020243c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202440:	0ff7f793          	andi	a5,a5,255
ffffffe000202444:	02078063          	beqz	a5,ffffffe000202464 <print_dec_int+0xa0>
ffffffe000202448:	fa043783          	ld	a5,-96(s0)
ffffffe00020244c:	0007dc63          	bgez	a5,ffffffe000202464 <print_dec_int+0xa0>
        neg = true;
ffffffe000202450:	00100793          	li	a5,1
ffffffe000202454:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000202458:	fa043783          	ld	a5,-96(s0)
ffffffe00020245c:	40f007b3          	neg	a5,a5
ffffffe000202460:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000202464:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000202468:	f9f44783          	lbu	a5,-97(s0)
ffffffe00020246c:	0ff7f793          	andi	a5,a5,255
ffffffe000202470:	02078863          	beqz	a5,ffffffe0002024a0 <print_dec_int+0xdc>
ffffffe000202474:	fef44783          	lbu	a5,-17(s0)
ffffffe000202478:	0ff7f793          	andi	a5,a5,255
ffffffe00020247c:	00079e63          	bnez	a5,ffffffe000202498 <print_dec_int+0xd4>
ffffffe000202480:	f9043783          	ld	a5,-112(s0)
ffffffe000202484:	0057c783          	lbu	a5,5(a5)
ffffffe000202488:	00079863          	bnez	a5,ffffffe000202498 <print_dec_int+0xd4>
ffffffe00020248c:	f9043783          	ld	a5,-112(s0)
ffffffe000202490:	0047c783          	lbu	a5,4(a5)
ffffffe000202494:	00078663          	beqz	a5,ffffffe0002024a0 <print_dec_int+0xdc>
ffffffe000202498:	00100793          	li	a5,1
ffffffe00020249c:	0080006f          	j	ffffffe0002024a4 <print_dec_int+0xe0>
ffffffe0002024a0:	00000793          	li	a5,0
ffffffe0002024a4:	fcf40ba3          	sb	a5,-41(s0)
ffffffe0002024a8:	fd744783          	lbu	a5,-41(s0)
ffffffe0002024ac:	0017f793          	andi	a5,a5,1
ffffffe0002024b0:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe0002024b4:	fa043703          	ld	a4,-96(s0)
ffffffe0002024b8:	00a00793          	li	a5,10
ffffffe0002024bc:	02f777b3          	remu	a5,a4,a5
ffffffe0002024c0:	0ff7f713          	andi	a4,a5,255
ffffffe0002024c4:	fe842783          	lw	a5,-24(s0)
ffffffe0002024c8:	0017869b          	addiw	a3,a5,1
ffffffe0002024cc:	fed42423          	sw	a3,-24(s0)
ffffffe0002024d0:	0307071b          	addiw	a4,a4,48
ffffffe0002024d4:	0ff77713          	andi	a4,a4,255
ffffffe0002024d8:	ff040693          	addi	a3,s0,-16
ffffffe0002024dc:	00f687b3          	add	a5,a3,a5
ffffffe0002024e0:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe0002024e4:	fa043703          	ld	a4,-96(s0)
ffffffe0002024e8:	00a00793          	li	a5,10
ffffffe0002024ec:	02f757b3          	divu	a5,a4,a5
ffffffe0002024f0:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe0002024f4:	fa043783          	ld	a5,-96(s0)
ffffffe0002024f8:	fa079ee3          	bnez	a5,ffffffe0002024b4 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe0002024fc:	f9043783          	ld	a5,-112(s0)
ffffffe000202500:	00c7a783          	lw	a5,12(a5)
ffffffe000202504:	00078713          	mv	a4,a5
ffffffe000202508:	fff00793          	li	a5,-1
ffffffe00020250c:	02f71063          	bne	a4,a5,ffffffe00020252c <print_dec_int+0x168>
ffffffe000202510:	f9043783          	ld	a5,-112(s0)
ffffffe000202514:	0037c783          	lbu	a5,3(a5)
ffffffe000202518:	00078a63          	beqz	a5,ffffffe00020252c <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe00020251c:	f9043783          	ld	a5,-112(s0)
ffffffe000202520:	0087a703          	lw	a4,8(a5)
ffffffe000202524:	f9043783          	ld	a5,-112(s0)
ffffffe000202528:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe00020252c:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000202530:	f9043783          	ld	a5,-112(s0)
ffffffe000202534:	0087a703          	lw	a4,8(a5)
ffffffe000202538:	fe842783          	lw	a5,-24(s0)
ffffffe00020253c:	fcf42823          	sw	a5,-48(s0)
ffffffe000202540:	f9043783          	ld	a5,-112(s0)
ffffffe000202544:	00c7a783          	lw	a5,12(a5)
ffffffe000202548:	fcf42623          	sw	a5,-52(s0)
ffffffe00020254c:	fd042583          	lw	a1,-48(s0)
ffffffe000202550:	fcc42783          	lw	a5,-52(s0)
ffffffe000202554:	0007861b          	sext.w	a2,a5
ffffffe000202558:	0005869b          	sext.w	a3,a1
ffffffe00020255c:	00d65463          	bge	a2,a3,ffffffe000202564 <print_dec_int+0x1a0>
ffffffe000202560:	00058793          	mv	a5,a1
ffffffe000202564:	0007879b          	sext.w	a5,a5
ffffffe000202568:	40f707bb          	subw	a5,a4,a5
ffffffe00020256c:	0007871b          	sext.w	a4,a5
ffffffe000202570:	fd744783          	lbu	a5,-41(s0)
ffffffe000202574:	0007879b          	sext.w	a5,a5
ffffffe000202578:	40f707bb          	subw	a5,a4,a5
ffffffe00020257c:	fef42023          	sw	a5,-32(s0)
ffffffe000202580:	0280006f          	j	ffffffe0002025a8 <print_dec_int+0x1e4>
        putch(' ');
ffffffe000202584:	fa843783          	ld	a5,-88(s0)
ffffffe000202588:	02000513          	li	a0,32
ffffffe00020258c:	000780e7          	jalr	a5
        ++written;
ffffffe000202590:	fe442783          	lw	a5,-28(s0)
ffffffe000202594:	0017879b          	addiw	a5,a5,1
ffffffe000202598:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe00020259c:	fe042783          	lw	a5,-32(s0)
ffffffe0002025a0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002025a4:	fef42023          	sw	a5,-32(s0)
ffffffe0002025a8:	fe042783          	lw	a5,-32(s0)
ffffffe0002025ac:	0007879b          	sext.w	a5,a5
ffffffe0002025b0:	fcf04ae3          	bgtz	a5,ffffffe000202584 <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
ffffffe0002025b4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002025b8:	0ff7f793          	andi	a5,a5,255
ffffffe0002025bc:	04078463          	beqz	a5,ffffffe000202604 <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe0002025c0:	fef44783          	lbu	a5,-17(s0)
ffffffe0002025c4:	0ff7f793          	andi	a5,a5,255
ffffffe0002025c8:	00078663          	beqz	a5,ffffffe0002025d4 <print_dec_int+0x210>
ffffffe0002025cc:	02d00793          	li	a5,45
ffffffe0002025d0:	01c0006f          	j	ffffffe0002025ec <print_dec_int+0x228>
ffffffe0002025d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002025d8:	0057c783          	lbu	a5,5(a5)
ffffffe0002025dc:	00078663          	beqz	a5,ffffffe0002025e8 <print_dec_int+0x224>
ffffffe0002025e0:	02b00793          	li	a5,43
ffffffe0002025e4:	0080006f          	j	ffffffe0002025ec <print_dec_int+0x228>
ffffffe0002025e8:	02000793          	li	a5,32
ffffffe0002025ec:	fa843703          	ld	a4,-88(s0)
ffffffe0002025f0:	00078513          	mv	a0,a5
ffffffe0002025f4:	000700e7          	jalr	a4
        ++written;
ffffffe0002025f8:	fe442783          	lw	a5,-28(s0)
ffffffe0002025fc:	0017879b          	addiw	a5,a5,1
ffffffe000202600:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202604:	fe842783          	lw	a5,-24(s0)
ffffffe000202608:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020260c:	0280006f          	j	ffffffe000202634 <print_dec_int+0x270>
        putch('0');
ffffffe000202610:	fa843783          	ld	a5,-88(s0)
ffffffe000202614:	03000513          	li	a0,48
ffffffe000202618:	000780e7          	jalr	a5
        ++written;
ffffffe00020261c:	fe442783          	lw	a5,-28(s0)
ffffffe000202620:	0017879b          	addiw	a5,a5,1
ffffffe000202624:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202628:	fdc42783          	lw	a5,-36(s0)
ffffffe00020262c:	0017879b          	addiw	a5,a5,1
ffffffe000202630:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202634:	f9043783          	ld	a5,-112(s0)
ffffffe000202638:	00c7a703          	lw	a4,12(a5)
ffffffe00020263c:	fd744783          	lbu	a5,-41(s0)
ffffffe000202640:	0007879b          	sext.w	a5,a5
ffffffe000202644:	40f707bb          	subw	a5,a4,a5
ffffffe000202648:	0007871b          	sext.w	a4,a5
ffffffe00020264c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202650:	0007879b          	sext.w	a5,a5
ffffffe000202654:	fae7cee3          	blt	a5,a4,ffffffe000202610 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000202658:	fe842783          	lw	a5,-24(s0)
ffffffe00020265c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202660:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202664:	03c0006f          	j	ffffffe0002026a0 <print_dec_int+0x2dc>
        putch(buf[i]);
ffffffe000202668:	fd842783          	lw	a5,-40(s0)
ffffffe00020266c:	ff040713          	addi	a4,s0,-16
ffffffe000202670:	00f707b3          	add	a5,a4,a5
ffffffe000202674:	fc87c783          	lbu	a5,-56(a5)
ffffffe000202678:	0007879b          	sext.w	a5,a5
ffffffe00020267c:	fa843703          	ld	a4,-88(s0)
ffffffe000202680:	00078513          	mv	a0,a5
ffffffe000202684:	000700e7          	jalr	a4
        ++written;
ffffffe000202688:	fe442783          	lw	a5,-28(s0)
ffffffe00020268c:	0017879b          	addiw	a5,a5,1
ffffffe000202690:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000202694:	fd842783          	lw	a5,-40(s0)
ffffffe000202698:	fff7879b          	addiw	a5,a5,-1
ffffffe00020269c:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002026a0:	fd842783          	lw	a5,-40(s0)
ffffffe0002026a4:	0007879b          	sext.w	a5,a5
ffffffe0002026a8:	fc07d0e3          	bgez	a5,ffffffe000202668 <print_dec_int+0x2a4>
    }

    return written;
ffffffe0002026ac:	fe442783          	lw	a5,-28(s0)
}
ffffffe0002026b0:	00078513          	mv	a0,a5
ffffffe0002026b4:	06813083          	ld	ra,104(sp)
ffffffe0002026b8:	06013403          	ld	s0,96(sp)
ffffffe0002026bc:	07010113          	addi	sp,sp,112
ffffffe0002026c0:	00008067          	ret

ffffffe0002026c4 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe0002026c4:	f4010113          	addi	sp,sp,-192
ffffffe0002026c8:	0a113c23          	sd	ra,184(sp)
ffffffe0002026cc:	0a813823          	sd	s0,176(sp)
ffffffe0002026d0:	0c010413          	addi	s0,sp,192
ffffffe0002026d4:	f4a43c23          	sd	a0,-168(s0)
ffffffe0002026d8:	f4b43823          	sd	a1,-176(s0)
ffffffe0002026dc:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe0002026e0:	f8043023          	sd	zero,-128(s0)
ffffffe0002026e4:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe0002026e8:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe0002026ec:	7a40006f          	j	ffffffe000202e90 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe0002026f0:	f8044783          	lbu	a5,-128(s0)
ffffffe0002026f4:	72078e63          	beqz	a5,ffffffe000202e30 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe0002026f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002026fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202700:	00078713          	mv	a4,a5
ffffffe000202704:	02300793          	li	a5,35
ffffffe000202708:	00f71863          	bne	a4,a5,ffffffe000202718 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe00020270c:	00100793          	li	a5,1
ffffffe000202710:	f8f40123          	sb	a5,-126(s0)
ffffffe000202714:	7700006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000202718:	f5043783          	ld	a5,-176(s0)
ffffffe00020271c:	0007c783          	lbu	a5,0(a5)
ffffffe000202720:	00078713          	mv	a4,a5
ffffffe000202724:	03000793          	li	a5,48
ffffffe000202728:	00f71863          	bne	a4,a5,ffffffe000202738 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe00020272c:	00100793          	li	a5,1
ffffffe000202730:	f8f401a3          	sb	a5,-125(s0)
ffffffe000202734:	7500006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000202738:	f5043783          	ld	a5,-176(s0)
ffffffe00020273c:	0007c783          	lbu	a5,0(a5)
ffffffe000202740:	00078713          	mv	a4,a5
ffffffe000202744:	06c00793          	li	a5,108
ffffffe000202748:	04f70063          	beq	a4,a5,ffffffe000202788 <vprintfmt+0xc4>
ffffffe00020274c:	f5043783          	ld	a5,-176(s0)
ffffffe000202750:	0007c783          	lbu	a5,0(a5)
ffffffe000202754:	00078713          	mv	a4,a5
ffffffe000202758:	07a00793          	li	a5,122
ffffffe00020275c:	02f70663          	beq	a4,a5,ffffffe000202788 <vprintfmt+0xc4>
ffffffe000202760:	f5043783          	ld	a5,-176(s0)
ffffffe000202764:	0007c783          	lbu	a5,0(a5)
ffffffe000202768:	00078713          	mv	a4,a5
ffffffe00020276c:	07400793          	li	a5,116
ffffffe000202770:	00f70c63          	beq	a4,a5,ffffffe000202788 <vprintfmt+0xc4>
ffffffe000202774:	f5043783          	ld	a5,-176(s0)
ffffffe000202778:	0007c783          	lbu	a5,0(a5)
ffffffe00020277c:	00078713          	mv	a4,a5
ffffffe000202780:	06a00793          	li	a5,106
ffffffe000202784:	00f71863          	bne	a4,a5,ffffffe000202794 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000202788:	00100793          	li	a5,1
ffffffe00020278c:	f8f400a3          	sb	a5,-127(s0)
ffffffe000202790:	6f40006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000202794:	f5043783          	ld	a5,-176(s0)
ffffffe000202798:	0007c783          	lbu	a5,0(a5)
ffffffe00020279c:	00078713          	mv	a4,a5
ffffffe0002027a0:	02b00793          	li	a5,43
ffffffe0002027a4:	00f71863          	bne	a4,a5,ffffffe0002027b4 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe0002027a8:	00100793          	li	a5,1
ffffffe0002027ac:	f8f402a3          	sb	a5,-123(s0)
ffffffe0002027b0:	6d40006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe0002027b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002027b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002027bc:	00078713          	mv	a4,a5
ffffffe0002027c0:	02000793          	li	a5,32
ffffffe0002027c4:	00f71863          	bne	a4,a5,ffffffe0002027d4 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe0002027c8:	00100793          	li	a5,1
ffffffe0002027cc:	f8f40223          	sb	a5,-124(s0)
ffffffe0002027d0:	6b40006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe0002027d4:	f5043783          	ld	a5,-176(s0)
ffffffe0002027d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002027dc:	00078713          	mv	a4,a5
ffffffe0002027e0:	02a00793          	li	a5,42
ffffffe0002027e4:	00f71e63          	bne	a4,a5,ffffffe000202800 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002027e8:	f4843783          	ld	a5,-184(s0)
ffffffe0002027ec:	00878713          	addi	a4,a5,8
ffffffe0002027f0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002027f4:	0007a783          	lw	a5,0(a5)
ffffffe0002027f8:	f8f42423          	sw	a5,-120(s0)
ffffffe0002027fc:	6880006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000202800:	f5043783          	ld	a5,-176(s0)
ffffffe000202804:	0007c783          	lbu	a5,0(a5)
ffffffe000202808:	00078713          	mv	a4,a5
ffffffe00020280c:	03000793          	li	a5,48
ffffffe000202810:	04e7f663          	bgeu	a5,a4,ffffffe00020285c <vprintfmt+0x198>
ffffffe000202814:	f5043783          	ld	a5,-176(s0)
ffffffe000202818:	0007c783          	lbu	a5,0(a5)
ffffffe00020281c:	00078713          	mv	a4,a5
ffffffe000202820:	03900793          	li	a5,57
ffffffe000202824:	02e7ec63          	bltu	a5,a4,ffffffe00020285c <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000202828:	f5043783          	ld	a5,-176(s0)
ffffffe00020282c:	f5040713          	addi	a4,s0,-176
ffffffe000202830:	00a00613          	li	a2,10
ffffffe000202834:	00070593          	mv	a1,a4
ffffffe000202838:	00078513          	mv	a0,a5
ffffffe00020283c:	899ff0ef          	jal	ra,ffffffe0002020d4 <strtol>
ffffffe000202840:	00050793          	mv	a5,a0
ffffffe000202844:	0007879b          	sext.w	a5,a5
ffffffe000202848:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe00020284c:	f5043783          	ld	a5,-176(s0)
ffffffe000202850:	fff78793          	addi	a5,a5,-1
ffffffe000202854:	f4f43823          	sd	a5,-176(s0)
ffffffe000202858:	62c0006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe00020285c:	f5043783          	ld	a5,-176(s0)
ffffffe000202860:	0007c783          	lbu	a5,0(a5)
ffffffe000202864:	00078713          	mv	a4,a5
ffffffe000202868:	02e00793          	li	a5,46
ffffffe00020286c:	06f71863          	bne	a4,a5,ffffffe0002028dc <vprintfmt+0x218>
                fmt++;
ffffffe000202870:	f5043783          	ld	a5,-176(s0)
ffffffe000202874:	00178793          	addi	a5,a5,1
ffffffe000202878:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe00020287c:	f5043783          	ld	a5,-176(s0)
ffffffe000202880:	0007c783          	lbu	a5,0(a5)
ffffffe000202884:	00078713          	mv	a4,a5
ffffffe000202888:	02a00793          	li	a5,42
ffffffe00020288c:	00f71e63          	bne	a4,a5,ffffffe0002028a8 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000202890:	f4843783          	ld	a5,-184(s0)
ffffffe000202894:	00878713          	addi	a4,a5,8
ffffffe000202898:	f4e43423          	sd	a4,-184(s0)
ffffffe00020289c:	0007a783          	lw	a5,0(a5)
ffffffe0002028a0:	f8f42623          	sw	a5,-116(s0)
ffffffe0002028a4:	5e00006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe0002028a8:	f5043783          	ld	a5,-176(s0)
ffffffe0002028ac:	f5040713          	addi	a4,s0,-176
ffffffe0002028b0:	00a00613          	li	a2,10
ffffffe0002028b4:	00070593          	mv	a1,a4
ffffffe0002028b8:	00078513          	mv	a0,a5
ffffffe0002028bc:	819ff0ef          	jal	ra,ffffffe0002020d4 <strtol>
ffffffe0002028c0:	00050793          	mv	a5,a0
ffffffe0002028c4:	0007879b          	sext.w	a5,a5
ffffffe0002028c8:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe0002028cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002028d0:	fff78793          	addi	a5,a5,-1
ffffffe0002028d4:	f4f43823          	sd	a5,-176(s0)
ffffffe0002028d8:	5ac0006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002028dc:	f5043783          	ld	a5,-176(s0)
ffffffe0002028e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002028e4:	00078713          	mv	a4,a5
ffffffe0002028e8:	07800793          	li	a5,120
ffffffe0002028ec:	02f70663          	beq	a4,a5,ffffffe000202918 <vprintfmt+0x254>
ffffffe0002028f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002028f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002028f8:	00078713          	mv	a4,a5
ffffffe0002028fc:	05800793          	li	a5,88
ffffffe000202900:	00f70c63          	beq	a4,a5,ffffffe000202918 <vprintfmt+0x254>
ffffffe000202904:	f5043783          	ld	a5,-176(s0)
ffffffe000202908:	0007c783          	lbu	a5,0(a5)
ffffffe00020290c:	00078713          	mv	a4,a5
ffffffe000202910:	07000793          	li	a5,112
ffffffe000202914:	2ef71e63          	bne	a4,a5,ffffffe000202c10 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000202918:	f5043783          	ld	a5,-176(s0)
ffffffe00020291c:	0007c783          	lbu	a5,0(a5)
ffffffe000202920:	00078713          	mv	a4,a5
ffffffe000202924:	07000793          	li	a5,112
ffffffe000202928:	00f70663          	beq	a4,a5,ffffffe000202934 <vprintfmt+0x270>
ffffffe00020292c:	f8144783          	lbu	a5,-127(s0)
ffffffe000202930:	00078663          	beqz	a5,ffffffe00020293c <vprintfmt+0x278>
ffffffe000202934:	00100793          	li	a5,1
ffffffe000202938:	0080006f          	j	ffffffe000202940 <vprintfmt+0x27c>
ffffffe00020293c:	00000793          	li	a5,0
ffffffe000202940:	faf403a3          	sb	a5,-89(s0)
ffffffe000202944:	fa744783          	lbu	a5,-89(s0)
ffffffe000202948:	0017f793          	andi	a5,a5,1
ffffffe00020294c:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000202950:	fa744783          	lbu	a5,-89(s0)
ffffffe000202954:	0ff7f793          	andi	a5,a5,255
ffffffe000202958:	00078c63          	beqz	a5,ffffffe000202970 <vprintfmt+0x2ac>
ffffffe00020295c:	f4843783          	ld	a5,-184(s0)
ffffffe000202960:	00878713          	addi	a4,a5,8
ffffffe000202964:	f4e43423          	sd	a4,-184(s0)
ffffffe000202968:	0007b783          	ld	a5,0(a5)
ffffffe00020296c:	01c0006f          	j	ffffffe000202988 <vprintfmt+0x2c4>
ffffffe000202970:	f4843783          	ld	a5,-184(s0)
ffffffe000202974:	00878713          	addi	a4,a5,8
ffffffe000202978:	f4e43423          	sd	a4,-184(s0)
ffffffe00020297c:	0007a783          	lw	a5,0(a5)
ffffffe000202980:	02079793          	slli	a5,a5,0x20
ffffffe000202984:	0207d793          	srli	a5,a5,0x20
ffffffe000202988:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe00020298c:	f8c42783          	lw	a5,-116(s0)
ffffffe000202990:	02079463          	bnez	a5,ffffffe0002029b8 <vprintfmt+0x2f4>
ffffffe000202994:	fe043783          	ld	a5,-32(s0)
ffffffe000202998:	02079063          	bnez	a5,ffffffe0002029b8 <vprintfmt+0x2f4>
ffffffe00020299c:	f5043783          	ld	a5,-176(s0)
ffffffe0002029a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002029a4:	00078713          	mv	a4,a5
ffffffe0002029a8:	07000793          	li	a5,112
ffffffe0002029ac:	00f70663          	beq	a4,a5,ffffffe0002029b8 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe0002029b0:	f8040023          	sb	zero,-128(s0)
ffffffe0002029b4:	4d00006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe0002029b8:	f5043783          	ld	a5,-176(s0)
ffffffe0002029bc:	0007c783          	lbu	a5,0(a5)
ffffffe0002029c0:	00078713          	mv	a4,a5
ffffffe0002029c4:	07000793          	li	a5,112
ffffffe0002029c8:	00f70a63          	beq	a4,a5,ffffffe0002029dc <vprintfmt+0x318>
ffffffe0002029cc:	f8244783          	lbu	a5,-126(s0)
ffffffe0002029d0:	00078a63          	beqz	a5,ffffffe0002029e4 <vprintfmt+0x320>
ffffffe0002029d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002029d8:	00078663          	beqz	a5,ffffffe0002029e4 <vprintfmt+0x320>
ffffffe0002029dc:	00100793          	li	a5,1
ffffffe0002029e0:	0080006f          	j	ffffffe0002029e8 <vprintfmt+0x324>
ffffffe0002029e4:	00000793          	li	a5,0
ffffffe0002029e8:	faf40323          	sb	a5,-90(s0)
ffffffe0002029ec:	fa644783          	lbu	a5,-90(s0)
ffffffe0002029f0:	0017f793          	andi	a5,a5,1
ffffffe0002029f4:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe0002029f8:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe0002029fc:	f5043783          	ld	a5,-176(s0)
ffffffe000202a00:	0007c783          	lbu	a5,0(a5)
ffffffe000202a04:	00078713          	mv	a4,a5
ffffffe000202a08:	05800793          	li	a5,88
ffffffe000202a0c:	00f71863          	bne	a4,a5,ffffffe000202a1c <vprintfmt+0x358>
ffffffe000202a10:	00002797          	auipc	a5,0x2
ffffffe000202a14:	85078793          	addi	a5,a5,-1968 # ffffffe000204260 <upperxdigits.1101>
ffffffe000202a18:	00c0006f          	j	ffffffe000202a24 <vprintfmt+0x360>
ffffffe000202a1c:	00002797          	auipc	a5,0x2
ffffffe000202a20:	85c78793          	addi	a5,a5,-1956 # ffffffe000204278 <lowerxdigits.1100>
ffffffe000202a24:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000202a28:	fe043783          	ld	a5,-32(s0)
ffffffe000202a2c:	00f7f793          	andi	a5,a5,15
ffffffe000202a30:	f9843703          	ld	a4,-104(s0)
ffffffe000202a34:	00f70733          	add	a4,a4,a5
ffffffe000202a38:	fdc42783          	lw	a5,-36(s0)
ffffffe000202a3c:	0017869b          	addiw	a3,a5,1
ffffffe000202a40:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202a44:	00074703          	lbu	a4,0(a4)
ffffffe000202a48:	ff040693          	addi	a3,s0,-16
ffffffe000202a4c:	00f687b3          	add	a5,a3,a5
ffffffe000202a50:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000202a54:	fe043783          	ld	a5,-32(s0)
ffffffe000202a58:	0047d793          	srli	a5,a5,0x4
ffffffe000202a5c:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000202a60:	fe043783          	ld	a5,-32(s0)
ffffffe000202a64:	fc0792e3          	bnez	a5,ffffffe000202a28 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000202a68:	f8c42783          	lw	a5,-116(s0)
ffffffe000202a6c:	00078713          	mv	a4,a5
ffffffe000202a70:	fff00793          	li	a5,-1
ffffffe000202a74:	02f71663          	bne	a4,a5,ffffffe000202aa0 <vprintfmt+0x3dc>
ffffffe000202a78:	f8344783          	lbu	a5,-125(s0)
ffffffe000202a7c:	02078263          	beqz	a5,ffffffe000202aa0 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000202a80:	f8842703          	lw	a4,-120(s0)
ffffffe000202a84:	fa644783          	lbu	a5,-90(s0)
ffffffe000202a88:	0007879b          	sext.w	a5,a5
ffffffe000202a8c:	0017979b          	slliw	a5,a5,0x1
ffffffe000202a90:	0007879b          	sext.w	a5,a5
ffffffe000202a94:	40f707bb          	subw	a5,a4,a5
ffffffe000202a98:	0007879b          	sext.w	a5,a5
ffffffe000202a9c:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202aa0:	f8842703          	lw	a4,-120(s0)
ffffffe000202aa4:	fa644783          	lbu	a5,-90(s0)
ffffffe000202aa8:	0007879b          	sext.w	a5,a5
ffffffe000202aac:	0017979b          	slliw	a5,a5,0x1
ffffffe000202ab0:	0007879b          	sext.w	a5,a5
ffffffe000202ab4:	40f707bb          	subw	a5,a4,a5
ffffffe000202ab8:	0007871b          	sext.w	a4,a5
ffffffe000202abc:	fdc42783          	lw	a5,-36(s0)
ffffffe000202ac0:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202ac4:	f8c42783          	lw	a5,-116(s0)
ffffffe000202ac8:	f8f42823          	sw	a5,-112(s0)
ffffffe000202acc:	f9442583          	lw	a1,-108(s0)
ffffffe000202ad0:	f9042783          	lw	a5,-112(s0)
ffffffe000202ad4:	0007861b          	sext.w	a2,a5
ffffffe000202ad8:	0005869b          	sext.w	a3,a1
ffffffe000202adc:	00d65463          	bge	a2,a3,ffffffe000202ae4 <vprintfmt+0x420>
ffffffe000202ae0:	00058793          	mv	a5,a1
ffffffe000202ae4:	0007879b          	sext.w	a5,a5
ffffffe000202ae8:	40f707bb          	subw	a5,a4,a5
ffffffe000202aec:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202af0:	0280006f          	j	ffffffe000202b18 <vprintfmt+0x454>
                    putch(' ');
ffffffe000202af4:	f5843783          	ld	a5,-168(s0)
ffffffe000202af8:	02000513          	li	a0,32
ffffffe000202afc:	000780e7          	jalr	a5
                    ++written;
ffffffe000202b00:	fec42783          	lw	a5,-20(s0)
ffffffe000202b04:	0017879b          	addiw	a5,a5,1
ffffffe000202b08:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202b0c:	fd842783          	lw	a5,-40(s0)
ffffffe000202b10:	fff7879b          	addiw	a5,a5,-1
ffffffe000202b14:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202b18:	fd842783          	lw	a5,-40(s0)
ffffffe000202b1c:	0007879b          	sext.w	a5,a5
ffffffe000202b20:	fcf04ae3          	bgtz	a5,ffffffe000202af4 <vprintfmt+0x430>
                }

                if (prefix) {
ffffffe000202b24:	fa644783          	lbu	a5,-90(s0)
ffffffe000202b28:	0ff7f793          	andi	a5,a5,255
ffffffe000202b2c:	04078463          	beqz	a5,ffffffe000202b74 <vprintfmt+0x4b0>
                    putch('0');
ffffffe000202b30:	f5843783          	ld	a5,-168(s0)
ffffffe000202b34:	03000513          	li	a0,48
ffffffe000202b38:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202b3c:	f5043783          	ld	a5,-176(s0)
ffffffe000202b40:	0007c783          	lbu	a5,0(a5)
ffffffe000202b44:	00078713          	mv	a4,a5
ffffffe000202b48:	05800793          	li	a5,88
ffffffe000202b4c:	00f71663          	bne	a4,a5,ffffffe000202b58 <vprintfmt+0x494>
ffffffe000202b50:	05800793          	li	a5,88
ffffffe000202b54:	0080006f          	j	ffffffe000202b5c <vprintfmt+0x498>
ffffffe000202b58:	07800793          	li	a5,120
ffffffe000202b5c:	f5843703          	ld	a4,-168(s0)
ffffffe000202b60:	00078513          	mv	a0,a5
ffffffe000202b64:	000700e7          	jalr	a4
                    written += 2;
ffffffe000202b68:	fec42783          	lw	a5,-20(s0)
ffffffe000202b6c:	0027879b          	addiw	a5,a5,2
ffffffe000202b70:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202b74:	fdc42783          	lw	a5,-36(s0)
ffffffe000202b78:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202b7c:	0280006f          	j	ffffffe000202ba4 <vprintfmt+0x4e0>
                    putch('0');
ffffffe000202b80:	f5843783          	ld	a5,-168(s0)
ffffffe000202b84:	03000513          	li	a0,48
ffffffe000202b88:	000780e7          	jalr	a5
                    ++written;
ffffffe000202b8c:	fec42783          	lw	a5,-20(s0)
ffffffe000202b90:	0017879b          	addiw	a5,a5,1
ffffffe000202b94:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202b98:	fd442783          	lw	a5,-44(s0)
ffffffe000202b9c:	0017879b          	addiw	a5,a5,1
ffffffe000202ba0:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202ba4:	f8c42703          	lw	a4,-116(s0)
ffffffe000202ba8:	fd442783          	lw	a5,-44(s0)
ffffffe000202bac:	0007879b          	sext.w	a5,a5
ffffffe000202bb0:	fce7c8e3          	blt	a5,a4,ffffffe000202b80 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202bb4:	fdc42783          	lw	a5,-36(s0)
ffffffe000202bb8:	fff7879b          	addiw	a5,a5,-1
ffffffe000202bbc:	fcf42823          	sw	a5,-48(s0)
ffffffe000202bc0:	03c0006f          	j	ffffffe000202bfc <vprintfmt+0x538>
                    putch(buf[i]);
ffffffe000202bc4:	fd042783          	lw	a5,-48(s0)
ffffffe000202bc8:	ff040713          	addi	a4,s0,-16
ffffffe000202bcc:	00f707b3          	add	a5,a4,a5
ffffffe000202bd0:	f807c783          	lbu	a5,-128(a5)
ffffffe000202bd4:	0007879b          	sext.w	a5,a5
ffffffe000202bd8:	f5843703          	ld	a4,-168(s0)
ffffffe000202bdc:	00078513          	mv	a0,a5
ffffffe000202be0:	000700e7          	jalr	a4
                    ++written;
ffffffe000202be4:	fec42783          	lw	a5,-20(s0)
ffffffe000202be8:	0017879b          	addiw	a5,a5,1
ffffffe000202bec:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202bf0:	fd042783          	lw	a5,-48(s0)
ffffffe000202bf4:	fff7879b          	addiw	a5,a5,-1
ffffffe000202bf8:	fcf42823          	sw	a5,-48(s0)
ffffffe000202bfc:	fd042783          	lw	a5,-48(s0)
ffffffe000202c00:	0007879b          	sext.w	a5,a5
ffffffe000202c04:	fc07d0e3          	bgez	a5,ffffffe000202bc4 <vprintfmt+0x500>
                }

                flags.in_format = false;
ffffffe000202c08:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202c0c:	2780006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202c10:	f5043783          	ld	a5,-176(s0)
ffffffe000202c14:	0007c783          	lbu	a5,0(a5)
ffffffe000202c18:	00078713          	mv	a4,a5
ffffffe000202c1c:	06400793          	li	a5,100
ffffffe000202c20:	02f70663          	beq	a4,a5,ffffffe000202c4c <vprintfmt+0x588>
ffffffe000202c24:	f5043783          	ld	a5,-176(s0)
ffffffe000202c28:	0007c783          	lbu	a5,0(a5)
ffffffe000202c2c:	00078713          	mv	a4,a5
ffffffe000202c30:	06900793          	li	a5,105
ffffffe000202c34:	00f70c63          	beq	a4,a5,ffffffe000202c4c <vprintfmt+0x588>
ffffffe000202c38:	f5043783          	ld	a5,-176(s0)
ffffffe000202c3c:	0007c783          	lbu	a5,0(a5)
ffffffe000202c40:	00078713          	mv	a4,a5
ffffffe000202c44:	07500793          	li	a5,117
ffffffe000202c48:	08f71263          	bne	a4,a5,ffffffe000202ccc <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202c4c:	f8144783          	lbu	a5,-127(s0)
ffffffe000202c50:	00078c63          	beqz	a5,ffffffe000202c68 <vprintfmt+0x5a4>
ffffffe000202c54:	f4843783          	ld	a5,-184(s0)
ffffffe000202c58:	00878713          	addi	a4,a5,8
ffffffe000202c5c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202c60:	0007b783          	ld	a5,0(a5)
ffffffe000202c64:	0140006f          	j	ffffffe000202c78 <vprintfmt+0x5b4>
ffffffe000202c68:	f4843783          	ld	a5,-184(s0)
ffffffe000202c6c:	00878713          	addi	a4,a5,8
ffffffe000202c70:	f4e43423          	sd	a4,-184(s0)
ffffffe000202c74:	0007a783          	lw	a5,0(a5)
ffffffe000202c78:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202c7c:	fa843583          	ld	a1,-88(s0)
ffffffe000202c80:	f5043783          	ld	a5,-176(s0)
ffffffe000202c84:	0007c783          	lbu	a5,0(a5)
ffffffe000202c88:	0007871b          	sext.w	a4,a5
ffffffe000202c8c:	07500793          	li	a5,117
ffffffe000202c90:	40f707b3          	sub	a5,a4,a5
ffffffe000202c94:	00f037b3          	snez	a5,a5
ffffffe000202c98:	0ff7f793          	andi	a5,a5,255
ffffffe000202c9c:	f8040713          	addi	a4,s0,-128
ffffffe000202ca0:	00070693          	mv	a3,a4
ffffffe000202ca4:	00078613          	mv	a2,a5
ffffffe000202ca8:	f5843503          	ld	a0,-168(s0)
ffffffe000202cac:	f18ff0ef          	jal	ra,ffffffe0002023c4 <print_dec_int>
ffffffe000202cb0:	00050793          	mv	a5,a0
ffffffe000202cb4:	00078713          	mv	a4,a5
ffffffe000202cb8:	fec42783          	lw	a5,-20(s0)
ffffffe000202cbc:	00e787bb          	addw	a5,a5,a4
ffffffe000202cc0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202cc4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202cc8:	1bc0006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000202ccc:	f5043783          	ld	a5,-176(s0)
ffffffe000202cd0:	0007c783          	lbu	a5,0(a5)
ffffffe000202cd4:	00078713          	mv	a4,a5
ffffffe000202cd8:	06e00793          	li	a5,110
ffffffe000202cdc:	04f71c63          	bne	a4,a5,ffffffe000202d34 <vprintfmt+0x670>
                if (flags.longflag) {
ffffffe000202ce0:	f8144783          	lbu	a5,-127(s0)
ffffffe000202ce4:	02078463          	beqz	a5,ffffffe000202d0c <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
ffffffe000202ce8:	f4843783          	ld	a5,-184(s0)
ffffffe000202cec:	00878713          	addi	a4,a5,8
ffffffe000202cf0:	f4e43423          	sd	a4,-184(s0)
ffffffe000202cf4:	0007b783          	ld	a5,0(a5)
ffffffe000202cf8:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000202cfc:	fec42703          	lw	a4,-20(s0)
ffffffe000202d00:	fb043783          	ld	a5,-80(s0)
ffffffe000202d04:	00e7b023          	sd	a4,0(a5)
ffffffe000202d08:	0240006f          	j	ffffffe000202d2c <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202d0c:	f4843783          	ld	a5,-184(s0)
ffffffe000202d10:	00878713          	addi	a4,a5,8
ffffffe000202d14:	f4e43423          	sd	a4,-184(s0)
ffffffe000202d18:	0007b783          	ld	a5,0(a5)
ffffffe000202d1c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202d20:	fb843783          	ld	a5,-72(s0)
ffffffe000202d24:	fec42703          	lw	a4,-20(s0)
ffffffe000202d28:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202d2c:	f8040023          	sb	zero,-128(s0)
ffffffe000202d30:	1540006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202d34:	f5043783          	ld	a5,-176(s0)
ffffffe000202d38:	0007c783          	lbu	a5,0(a5)
ffffffe000202d3c:	00078713          	mv	a4,a5
ffffffe000202d40:	07300793          	li	a5,115
ffffffe000202d44:	04f71063          	bne	a4,a5,ffffffe000202d84 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202d48:	f4843783          	ld	a5,-184(s0)
ffffffe000202d4c:	00878713          	addi	a4,a5,8
ffffffe000202d50:	f4e43423          	sd	a4,-184(s0)
ffffffe000202d54:	0007b783          	ld	a5,0(a5)
ffffffe000202d58:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000202d5c:	fc043583          	ld	a1,-64(s0)
ffffffe000202d60:	f5843503          	ld	a0,-168(s0)
ffffffe000202d64:	dd8ff0ef          	jal	ra,ffffffe00020233c <puts_wo_nl>
ffffffe000202d68:	00050793          	mv	a5,a0
ffffffe000202d6c:	00078713          	mv	a4,a5
ffffffe000202d70:	fec42783          	lw	a5,-20(s0)
ffffffe000202d74:	00e787bb          	addw	a5,a5,a4
ffffffe000202d78:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202d7c:	f8040023          	sb	zero,-128(s0)
ffffffe000202d80:	1040006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202d84:	f5043783          	ld	a5,-176(s0)
ffffffe000202d88:	0007c783          	lbu	a5,0(a5)
ffffffe000202d8c:	00078713          	mv	a4,a5
ffffffe000202d90:	06300793          	li	a5,99
ffffffe000202d94:	02f71e63          	bne	a4,a5,ffffffe000202dd0 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202d98:	f4843783          	ld	a5,-184(s0)
ffffffe000202d9c:	00878713          	addi	a4,a5,8
ffffffe000202da0:	f4e43423          	sd	a4,-184(s0)
ffffffe000202da4:	0007a783          	lw	a5,0(a5)
ffffffe000202da8:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202dac:	fcc42783          	lw	a5,-52(s0)
ffffffe000202db0:	f5843703          	ld	a4,-168(s0)
ffffffe000202db4:	00078513          	mv	a0,a5
ffffffe000202db8:	000700e7          	jalr	a4
                ++written;
ffffffe000202dbc:	fec42783          	lw	a5,-20(s0)
ffffffe000202dc0:	0017879b          	addiw	a5,a5,1
ffffffe000202dc4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202dc8:	f8040023          	sb	zero,-128(s0)
ffffffe000202dcc:	0b80006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202dd0:	f5043783          	ld	a5,-176(s0)
ffffffe000202dd4:	0007c783          	lbu	a5,0(a5)
ffffffe000202dd8:	00078713          	mv	a4,a5
ffffffe000202ddc:	02500793          	li	a5,37
ffffffe000202de0:	02f71263          	bne	a4,a5,ffffffe000202e04 <vprintfmt+0x740>
                putch('%');
ffffffe000202de4:	f5843783          	ld	a5,-168(s0)
ffffffe000202de8:	02500513          	li	a0,37
ffffffe000202dec:	000780e7          	jalr	a5
                ++written;
ffffffe000202df0:	fec42783          	lw	a5,-20(s0)
ffffffe000202df4:	0017879b          	addiw	a5,a5,1
ffffffe000202df8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202dfc:	f8040023          	sb	zero,-128(s0)
ffffffe000202e00:	0840006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000202e04:	f5043783          	ld	a5,-176(s0)
ffffffe000202e08:	0007c783          	lbu	a5,0(a5)
ffffffe000202e0c:	0007879b          	sext.w	a5,a5
ffffffe000202e10:	f5843703          	ld	a4,-168(s0)
ffffffe000202e14:	00078513          	mv	a0,a5
ffffffe000202e18:	000700e7          	jalr	a4
                ++written;
ffffffe000202e1c:	fec42783          	lw	a5,-20(s0)
ffffffe000202e20:	0017879b          	addiw	a5,a5,1
ffffffe000202e24:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202e28:	f8040023          	sb	zero,-128(s0)
ffffffe000202e2c:	0580006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202e30:	f5043783          	ld	a5,-176(s0)
ffffffe000202e34:	0007c783          	lbu	a5,0(a5)
ffffffe000202e38:	00078713          	mv	a4,a5
ffffffe000202e3c:	02500793          	li	a5,37
ffffffe000202e40:	02f71063          	bne	a4,a5,ffffffe000202e60 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202e44:	f8043023          	sd	zero,-128(s0)
ffffffe000202e48:	f8043423          	sd	zero,-120(s0)
ffffffe000202e4c:	00100793          	li	a5,1
ffffffe000202e50:	f8f40023          	sb	a5,-128(s0)
ffffffe000202e54:	fff00793          	li	a5,-1
ffffffe000202e58:	f8f42623          	sw	a5,-116(s0)
ffffffe000202e5c:	0280006f          	j	ffffffe000202e84 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202e60:	f5043783          	ld	a5,-176(s0)
ffffffe000202e64:	0007c783          	lbu	a5,0(a5)
ffffffe000202e68:	0007879b          	sext.w	a5,a5
ffffffe000202e6c:	f5843703          	ld	a4,-168(s0)
ffffffe000202e70:	00078513          	mv	a0,a5
ffffffe000202e74:	000700e7          	jalr	a4
            ++written;
ffffffe000202e78:	fec42783          	lw	a5,-20(s0)
ffffffe000202e7c:	0017879b          	addiw	a5,a5,1
ffffffe000202e80:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202e84:	f5043783          	ld	a5,-176(s0)
ffffffe000202e88:	00178793          	addi	a5,a5,1
ffffffe000202e8c:	f4f43823          	sd	a5,-176(s0)
ffffffe000202e90:	f5043783          	ld	a5,-176(s0)
ffffffe000202e94:	0007c783          	lbu	a5,0(a5)
ffffffe000202e98:	84079ce3          	bnez	a5,ffffffe0002026f0 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202e9c:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202ea0:	00078513          	mv	a0,a5
ffffffe000202ea4:	0b813083          	ld	ra,184(sp)
ffffffe000202ea8:	0b013403          	ld	s0,176(sp)
ffffffe000202eac:	0c010113          	addi	sp,sp,192
ffffffe000202eb0:	00008067          	ret

ffffffe000202eb4 <printk>:

int printk(const char* s, ...) {
ffffffe000202eb4:	f9010113          	addi	sp,sp,-112
ffffffe000202eb8:	02113423          	sd	ra,40(sp)
ffffffe000202ebc:	02813023          	sd	s0,32(sp)
ffffffe000202ec0:	03010413          	addi	s0,sp,48
ffffffe000202ec4:	fca43c23          	sd	a0,-40(s0)
ffffffe000202ec8:	00b43423          	sd	a1,8(s0)
ffffffe000202ecc:	00c43823          	sd	a2,16(s0)
ffffffe000202ed0:	00d43c23          	sd	a3,24(s0)
ffffffe000202ed4:	02e43023          	sd	a4,32(s0)
ffffffe000202ed8:	02f43423          	sd	a5,40(s0)
ffffffe000202edc:	03043823          	sd	a6,48(s0)
ffffffe000202ee0:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000202ee4:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000202ee8:	04040793          	addi	a5,s0,64
ffffffe000202eec:	fcf43823          	sd	a5,-48(s0)
ffffffe000202ef0:	fd043783          	ld	a5,-48(s0)
ffffffe000202ef4:	fc878793          	addi	a5,a5,-56
ffffffe000202ef8:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000202efc:	fe043783          	ld	a5,-32(s0)
ffffffe000202f00:	00078613          	mv	a2,a5
ffffffe000202f04:	fd843583          	ld	a1,-40(s0)
ffffffe000202f08:	fffff517          	auipc	a0,0xfffff
ffffffe000202f0c:	12450513          	addi	a0,a0,292 # ffffffe00020202c <putc>
ffffffe000202f10:	fb4ff0ef          	jal	ra,ffffffe0002026c4 <vprintfmt>
ffffffe000202f14:	00050793          	mv	a5,a0
ffffffe000202f18:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202f1c:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202f20:	00078513          	mv	a0,a5
ffffffe000202f24:	02813083          	ld	ra,40(sp)
ffffffe000202f28:	02013403          	ld	s0,32(sp)
ffffffe000202f2c:	07010113          	addi	sp,sp,112
ffffffe000202f30:	00008067          	ret

ffffffe000202f34 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202f34:	fe010113          	addi	sp,sp,-32
ffffffe000202f38:	00813c23          	sd	s0,24(sp)
ffffffe000202f3c:	02010413          	addi	s0,sp,32
ffffffe000202f40:	00050793          	mv	a5,a0
ffffffe000202f44:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202f48:	fec42783          	lw	a5,-20(s0)
ffffffe000202f4c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202f50:	0007879b          	sext.w	a5,a5
ffffffe000202f54:	02079713          	slli	a4,a5,0x20
ffffffe000202f58:	02075713          	srli	a4,a4,0x20
ffffffe000202f5c:	00006797          	auipc	a5,0x6
ffffffe000202f60:	0a478793          	addi	a5,a5,164 # ffffffe000209000 <seed>
ffffffe000202f64:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202f68:	00000013          	nop
ffffffe000202f6c:	01813403          	ld	s0,24(sp)
ffffffe000202f70:	02010113          	addi	sp,sp,32
ffffffe000202f74:	00008067          	ret

ffffffe000202f78 <rand>:

int rand(void) {
ffffffe000202f78:	ff010113          	addi	sp,sp,-16
ffffffe000202f7c:	00813423          	sd	s0,8(sp)
ffffffe000202f80:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202f84:	00006797          	auipc	a5,0x6
ffffffe000202f88:	07c78793          	addi	a5,a5,124 # ffffffe000209000 <seed>
ffffffe000202f8c:	0007b703          	ld	a4,0(a5)
ffffffe000202f90:	00001797          	auipc	a5,0x1
ffffffe000202f94:	30078793          	addi	a5,a5,768 # ffffffe000204290 <lowerxdigits.1100+0x18>
ffffffe000202f98:	0007b783          	ld	a5,0(a5)
ffffffe000202f9c:	02f707b3          	mul	a5,a4,a5
ffffffe000202fa0:	00178713          	addi	a4,a5,1
ffffffe000202fa4:	00006797          	auipc	a5,0x6
ffffffe000202fa8:	05c78793          	addi	a5,a5,92 # ffffffe000209000 <seed>
ffffffe000202fac:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202fb0:	00006797          	auipc	a5,0x6
ffffffe000202fb4:	05078793          	addi	a5,a5,80 # ffffffe000209000 <seed>
ffffffe000202fb8:	0007b783          	ld	a5,0(a5)
ffffffe000202fbc:	0217d793          	srli	a5,a5,0x21
ffffffe000202fc0:	0007879b          	sext.w	a5,a5
}
ffffffe000202fc4:	00078513          	mv	a0,a5
ffffffe000202fc8:	00813403          	ld	s0,8(sp)
ffffffe000202fcc:	01010113          	addi	sp,sp,16
ffffffe000202fd0:	00008067          	ret

ffffffe000202fd4 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000202fd4:	fc010113          	addi	sp,sp,-64
ffffffe000202fd8:	02813c23          	sd	s0,56(sp)
ffffffe000202fdc:	04010413          	addi	s0,sp,64
ffffffe000202fe0:	fca43c23          	sd	a0,-40(s0)
ffffffe000202fe4:	00058793          	mv	a5,a1
ffffffe000202fe8:	fcc43423          	sd	a2,-56(s0)
ffffffe000202fec:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000202ff0:	fd843783          	ld	a5,-40(s0)
ffffffe000202ff4:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202ff8:	fe043423          	sd	zero,-24(s0)
ffffffe000202ffc:	0280006f          	j	ffffffe000203024 <memset+0x50>
        s[i] = c;
ffffffe000203000:	fe043703          	ld	a4,-32(s0)
ffffffe000203004:	fe843783          	ld	a5,-24(s0)
ffffffe000203008:	00f707b3          	add	a5,a4,a5
ffffffe00020300c:	fd442703          	lw	a4,-44(s0)
ffffffe000203010:	0ff77713          	andi	a4,a4,255
ffffffe000203014:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203018:	fe843783          	ld	a5,-24(s0)
ffffffe00020301c:	00178793          	addi	a5,a5,1
ffffffe000203020:	fef43423          	sd	a5,-24(s0)
ffffffe000203024:	fe843703          	ld	a4,-24(s0)
ffffffe000203028:	fc843783          	ld	a5,-56(s0)
ffffffe00020302c:	fcf76ae3          	bltu	a4,a5,ffffffe000203000 <memset+0x2c>
    }
    return dest;
ffffffe000203030:	fd843783          	ld	a5,-40(s0)
}
ffffffe000203034:	00078513          	mv	a0,a5
ffffffe000203038:	03813403          	ld	s0,56(sp)
ffffffe00020303c:	04010113          	addi	sp,sp,64
ffffffe000203040:	00008067          	ret
