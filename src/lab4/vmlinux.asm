
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
ffffffe000200008:	0cd010ef          	jal	ra,ffffffe0002018d4 <setup_vm>
    call relocate
ffffffe00020000c:	03c000ef          	jal	ra,ffffffe000200048 <relocate>
    call mm_init #初始化内存管理系统
ffffffe000200010:	2f1000ef          	jal	ra,ffffffe000200b00 <mm_init>
    call task_init #初始化线程数据结构 
ffffffe000200014:	39d000ef          	jal	ra,ffffffe000200bb0 <task_init>
    call setup_vm_final
ffffffe000200018:	3c1010ef          	jal	ra,ffffffe000201bd8 <setup_vm_final>
    
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
ffffffe000200030:	2f8000ef          	jal	ra,ffffffe000200328 <get_cycles>
    li t0,10000000
ffffffe000200034:	009892b7          	lui	t0,0x989
ffffffe000200038:	6802829b          	addiw	t0,t0,1664
    add a0,a0,t0
ffffffe00020003c:	00550533          	add	a0,a0,t0
    call sbi_set_timer
ffffffe000200040:	4b4010ef          	jal	ra,ffffffe0002014f4 <sbi_set_timer>

    # set sstatus[SIE]=1
    #li t0,(1<<1)
    #csrs sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
ffffffe000200044:	5a90106f          	j	ffffffe000201dec <start_kernel>

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
ffffffe000200070:	0000a297          	auipc	t0,0xa
ffffffe000200074:	f9028293          	addi	t0,t0,-112 # ffffffe00020a000 <early_pgtbl>
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
ffffffe0002000d0:	ef010113          	addi	sp,sp,-272 # ffffffe000206ef0 <_sbss+0xef0>
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
ffffffe000200170:	618010ef          	jal	ra,ffffffe000201788 <trap_handler>

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
    # 交换寄存器值
    csrr t0,sscratch
ffffffe000200214:	140022f3          	csrr	t0,sscratch
    csrw sscratch,sp
ffffffe000200218:	14011073          	csrw	sscratch,sp
    mv sp,t0
ffffffe00020021c:	00028113          	mv	sp,t0

    la t0,dummy
ffffffe000200220:	00001297          	auipc	t0,0x1
ffffffe000200224:	e0428293          	addi	t0,t0,-508 # ffffffe000201024 <dummy>
    csrw sepc,t0
ffffffe000200228:	14129073          	csrw	sepc,t0
    sret
ffffffe00020022c:	10200073          	sret

ffffffe000200230 <__switch_to>:

    .globl __switch_to
__switch_to:
    #保存当前进程上下文
    #保存 pre->thread.ra
    sd ra,32(a0)
ffffffe000200230:	02153023          	sd	ra,32(a0)
    #保存 pre->thread.sp
    sd sp,40(a0)
ffffffe000200234:	02253423          	sd	sp,40(a0)
    #保存 s0-s11 
    sd s0,48(a0)
ffffffe000200238:	02853823          	sd	s0,48(a0)
    sd s1,56(a0)
ffffffe00020023c:	02953c23          	sd	s1,56(a0)
    sd s2,64(a0)
ffffffe000200240:	05253023          	sd	s2,64(a0)
    sd s3,72(a0)
ffffffe000200244:	05353423          	sd	s3,72(a0)
    sd s4,80(a0)
ffffffe000200248:	05453823          	sd	s4,80(a0)
    sd s5,88(a0)
ffffffe00020024c:	05553c23          	sd	s5,88(a0)
    sd s6,96(a0)
ffffffe000200250:	07653023          	sd	s6,96(a0)
    sd s7,104(a0)
ffffffe000200254:	07753423          	sd	s7,104(a0)
    sd s8,112(a0)
ffffffe000200258:	07853823          	sd	s8,112(a0)
    sd s9,120(a0)
ffffffe00020025c:	07953c23          	sd	s9,120(a0)
    sd s10,128(a0)
ffffffe000200260:	09a53023          	sd	s10,128(a0)
    sd s11,136(a0)
ffffffe000200264:	09b53423          	sd	s11,136(a0)

    # 保存 sepc ,sstatus,sscratch
    csrr t0,sepc
ffffffe000200268:	141022f3          	csrr	t0,sepc
    sd t0,152(a0)
ffffffe00020026c:	08553c23          	sd	t0,152(a0)
    csrr t0,sstatus
ffffffe000200270:	100022f3          	csrr	t0,sstatus
    sd t0,160(a0)
ffffffe000200274:	0a553023          	sd	t0,160(a0)
    csrr t0,sscratch
ffffffe000200278:	140022f3          	csrr	t0,sscratch
    sd t0,168(a0)
ffffffe00020027c:	0a553423          	sd	t0,168(a0)

    # 切换页表
    li t0,0x80000000
ffffffe000200280:	0010029b          	addiw	t0,zero,1
ffffffe000200284:	01f29293          	slli	t0,t0,0x1f
    li t1,0xffffffdf
ffffffe000200288:	0010031b          	addiw	t1,zero,1
ffffffe00020028c:	02031313          	slli	t1,t1,0x20
ffffffe000200290:	fdf30313          	addi	t1,t1,-33
    slli t1,t1,32
ffffffe000200294:	02031313          	slli	t1,t1,0x20
    or t0,t0,t1         # PA2VA_OFFSET=0xffffffdf80000000
ffffffe000200298:	0062e2b3          	or	t0,t0,t1
    ld t1,176(a1)       # next->pgd
ffffffe00020029c:	0b05b303          	ld	t1,176(a1)
    sub t1,t1,t0        # 物理地址
ffffffe0002002a0:	40530333          	sub	t1,t1,t0
    srli t1,t1,12       # PPN
ffffffe0002002a4:	00c35313          	srli	t1,t1,0xc
    li t0,(8<<60)       # MOOD=8 SV39
ffffffe0002002a8:	fff0029b          	addiw	t0,zero,-1
ffffffe0002002ac:	03f29293          	slli	t0,t0,0x3f
    or t0,t0,t1
ffffffe0002002b0:	0062e2b3          	or	t0,t0,t1
    csrw satp,t0
ffffffe0002002b4:	18029073          	csrw	satp,t0
    sfence.vma zero, zero
ffffffe0002002b8:	12000073          	sfence.vma

    # 恢复下一个进程 sepc,sstatus,sscratch
    ld t0,152(a1)
ffffffe0002002bc:	0985b283          	ld	t0,152(a1)
    csrw sepc,t0
ffffffe0002002c0:	14129073          	csrw	sepc,t0
    ld t0,160(a1)
ffffffe0002002c4:	0a05b283          	ld	t0,160(a1)
    csrw sstatus,t0
ffffffe0002002c8:	10029073          	csrw	sstatus,t0
    ld t0,168(a1)
ffffffe0002002cc:	0a85b283          	ld	t0,168(a1)
    csrw sscratch,t0
ffffffe0002002d0:	14029073          	csrw	sscratch,t0


    #next是否为第一次调度
    ld t0,144(a1)
ffffffe0002002d4:	0905b283          	ld	t0,144(a1)
    beqz t0,first_schedule
ffffffe0002002d8:	04028063          	beqz	t0,ffffffe000200318 <first_schedule>

    #恢复下一个进程上下文
    ld ra,32(a1)
ffffffe0002002dc:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe0002002e0:	0285b103          	ld	sp,40(a1)
    ld s0,48(a1)
ffffffe0002002e4:	0305b403          	ld	s0,48(a1)
    ld s1,56(a1)
ffffffe0002002e8:	0385b483          	ld	s1,56(a1)
    ld s2,64(a1)
ffffffe0002002ec:	0405b903          	ld	s2,64(a1)
    ld s3,72(a1)
ffffffe0002002f0:	0485b983          	ld	s3,72(a1)
    ld s4,80(a1)
ffffffe0002002f4:	0505ba03          	ld	s4,80(a1)
    ld s5,88(a1)
ffffffe0002002f8:	0585ba83          	ld	s5,88(a1)
    ld s6,96(a1)
ffffffe0002002fc:	0605bb03          	ld	s6,96(a1)
    ld s7,104(a1)
ffffffe000200300:	0685bb83          	ld	s7,104(a1)
    ld s8,112(a1)
ffffffe000200304:	0705bc03          	ld	s8,112(a1)
    ld s9,120(a1)
ffffffe000200308:	0785bc83          	ld	s9,120(a1)
    ld s10,128(a1)
ffffffe00020030c:	0805bd03          	ld	s10,128(a1)
    ld s11,136(a1)
ffffffe000200310:	0885bd83          	ld	s11,136(a1)


    j switch_done
ffffffe000200314:	0100006f          	j	ffffffe000200324 <switch_done>

ffffffe000200318 <first_schedule>:

first_schedule:
    ld ra,32(a1)
ffffffe000200318:	0205b083          	ld	ra,32(a1)
    ld sp,40(a1)
ffffffe00020031c:	0285b103          	ld	sp,40(a1)
    j switch_done
ffffffe000200320:	0040006f          	j	ffffffe000200324 <switch_done>

ffffffe000200324 <switch_done>:

switch_done:
    ret
ffffffe000200324:	00008067          	ret

ffffffe000200328 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200328:	fe010113          	addi	sp,sp,-32
ffffffe00020032c:	00813c23          	sd	s0,24(sp)
ffffffe000200330:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    asm volatile(
ffffffe000200334:	c01027f3          	rdtime	a5
ffffffe000200338:	fef43423          	sd	a5,-24(s0)
       "rdtime %0"
         : "=r" (cycles)
    );
    return cycles;
ffffffe00020033c:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200340:	00078513          	mv	a0,a5
ffffffe000200344:	01813403          	ld	s0,24(sp)
ffffffe000200348:	02010113          	addi	sp,sp,32
ffffffe00020034c:	00008067          	ret

ffffffe000200350 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200350:	fe010113          	addi	sp,sp,-32
ffffffe000200354:	00113c23          	sd	ra,24(sp)
ffffffe000200358:	00813823          	sd	s0,16(sp)
ffffffe00020035c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200360:	fc9ff0ef          	jal	ra,ffffffe000200328 <get_cycles>
ffffffe000200364:	00050713          	mv	a4,a0
ffffffe000200368:	00004797          	auipc	a5,0x4
ffffffe00020036c:	c9878793          	addi	a5,a5,-872 # ffffffe000204000 <TIMECLOCK>
ffffffe000200370:	0007b783          	ld	a5,0(a5)
ffffffe000200374:	00f707b3          	add	a5,a4,a5
ffffffe000200378:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
   sbi_set_timer(next);
ffffffe00020037c:	fe843503          	ld	a0,-24(s0)
ffffffe000200380:	174010ef          	jal	ra,ffffffe0002014f4 <sbi_set_timer>
ffffffe000200384:	00000013          	nop
ffffffe000200388:	01813083          	ld	ra,24(sp)
ffffffe00020038c:	01013403          	ld	s0,16(sp)
ffffffe000200390:	02010113          	addi	sp,sp,32
ffffffe000200394:	00008067          	ret

ffffffe000200398 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200398:	fe010113          	addi	sp,sp,-32
ffffffe00020039c:	00813c23          	sd	s0,24(sp)
ffffffe0002003a0:	02010413          	addi	s0,sp,32
ffffffe0002003a4:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe0002003a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003ac:	fff78793          	addi	a5,a5,-1
ffffffe0002003b0:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe0002003b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b8:	0017d793          	srli	a5,a5,0x1
ffffffe0002003bc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003c0:	00f767b3          	or	a5,a4,a5
ffffffe0002003c4:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe0002003c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003cc:	0027d793          	srli	a5,a5,0x2
ffffffe0002003d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003d4:	00f767b3          	or	a5,a4,a5
ffffffe0002003d8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe0002003dc:	fe843783          	ld	a5,-24(s0)
ffffffe0002003e0:	0047d793          	srli	a5,a5,0x4
ffffffe0002003e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e8:	00f767b3          	or	a5,a4,a5
ffffffe0002003ec:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe0002003f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003f4:	0087d793          	srli	a5,a5,0x8
ffffffe0002003f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002003fc:	00f767b3          	or	a5,a4,a5
ffffffe000200400:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe000200404:	fe843783          	ld	a5,-24(s0)
ffffffe000200408:	0107d793          	srli	a5,a5,0x10
ffffffe00020040c:	fe843703          	ld	a4,-24(s0)
ffffffe000200410:	00f767b3          	or	a5,a4,a5
ffffffe000200414:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe000200418:	fe843783          	ld	a5,-24(s0)
ffffffe00020041c:	0207d793          	srli	a5,a5,0x20
ffffffe000200420:	fe843703          	ld	a4,-24(s0)
ffffffe000200424:	00f767b3          	or	a5,a4,a5
ffffffe000200428:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe00020042c:	fe843783          	ld	a5,-24(s0)
ffffffe000200430:	00178793          	addi	a5,a5,1
}
ffffffe000200434:	00078513          	mv	a0,a5
ffffffe000200438:	01813403          	ld	s0,24(sp)
ffffffe00020043c:	02010113          	addi	sp,sp,32
ffffffe000200440:	00008067          	ret

ffffffe000200444 <buddy_init>:

void buddy_init() {
ffffffe000200444:	fd010113          	addi	sp,sp,-48
ffffffe000200448:	02113423          	sd	ra,40(sp)
ffffffe00020044c:	02813023          	sd	s0,32(sp)
ffffffe000200450:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe000200454:	000087b7          	lui	a5,0x8
ffffffe000200458:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe00020045c:	fe843783          	ld	a5,-24(s0)
ffffffe000200460:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe000200464:	fe843783          	ld	a5,-24(s0)
ffffffe000200468:	00f777b3          	and	a5,a4,a5
ffffffe00020046c:	00078863          	beqz	a5,ffffffe00020047c <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe000200470:	fe843503          	ld	a0,-24(s0)
ffffffe000200474:	f25ff0ef          	jal	ra,ffffffe000200398 <fixsize>
ffffffe000200478:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe00020047c:	00007797          	auipc	a5,0x7
ffffffe000200480:	b9478793          	addi	a5,a5,-1132 # ffffffe000207010 <buddy>
ffffffe000200484:	fe843703          	ld	a4,-24(s0)
ffffffe000200488:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe00020048c:	00004797          	auipc	a5,0x4
ffffffe000200490:	b7c78793          	addi	a5,a5,-1156 # ffffffe000204008 <free_page_start>
ffffffe000200494:	0007b703          	ld	a4,0(a5)
ffffffe000200498:	00007797          	auipc	a5,0x7
ffffffe00020049c:	b7878793          	addi	a5,a5,-1160 # ffffffe000207010 <buddy>
ffffffe0002004a0:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe0002004a4:	00004797          	auipc	a5,0x4
ffffffe0002004a8:	b6478793          	addi	a5,a5,-1180 # ffffffe000204008 <free_page_start>
ffffffe0002004ac:	0007b703          	ld	a4,0(a5)
ffffffe0002004b0:	00007797          	auipc	a5,0x7
ffffffe0002004b4:	b6078793          	addi	a5,a5,-1184 # ffffffe000207010 <buddy>
ffffffe0002004b8:	0007b783          	ld	a5,0(a5)
ffffffe0002004bc:	00479793          	slli	a5,a5,0x4
ffffffe0002004c0:	00f70733          	add	a4,a4,a5
ffffffe0002004c4:	00004797          	auipc	a5,0x4
ffffffe0002004c8:	b4478793          	addi	a5,a5,-1212 # ffffffe000204008 <free_page_start>
ffffffe0002004cc:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe0002004d0:	00007797          	auipc	a5,0x7
ffffffe0002004d4:	b4078793          	addi	a5,a5,-1216 # ffffffe000207010 <buddy>
ffffffe0002004d8:	0087b703          	ld	a4,8(a5)
ffffffe0002004dc:	00007797          	auipc	a5,0x7
ffffffe0002004e0:	b3478793          	addi	a5,a5,-1228 # ffffffe000207010 <buddy>
ffffffe0002004e4:	0007b783          	ld	a5,0(a5)
ffffffe0002004e8:	00479793          	slli	a5,a5,0x4
ffffffe0002004ec:	00078613          	mv	a2,a5
ffffffe0002004f0:	00000593          	li	a1,0
ffffffe0002004f4:	00070513          	mv	a0,a4
ffffffe0002004f8:	131020ef          	jal	ra,ffffffe000202e28 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe0002004fc:	00007797          	auipc	a5,0x7
ffffffe000200500:	b1478793          	addi	a5,a5,-1260 # ffffffe000207010 <buddy>
ffffffe000200504:	0007b783          	ld	a5,0(a5)
ffffffe000200508:	00179793          	slli	a5,a5,0x1
ffffffe00020050c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200510:	fc043c23          	sd	zero,-40(s0)
ffffffe000200514:	0500006f          	j	ffffffe000200564 <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe000200518:	fd843783          	ld	a5,-40(s0)
ffffffe00020051c:	00178713          	addi	a4,a5,1
ffffffe000200520:	fd843783          	ld	a5,-40(s0)
ffffffe000200524:	00f777b3          	and	a5,a4,a5
ffffffe000200528:	00079863          	bnez	a5,ffffffe000200538 <buddy_init+0xf4>
            node_size /= 2;
ffffffe00020052c:	fe043783          	ld	a5,-32(s0)
ffffffe000200530:	0017d793          	srli	a5,a5,0x1
ffffffe000200534:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe000200538:	00007797          	auipc	a5,0x7
ffffffe00020053c:	ad878793          	addi	a5,a5,-1320 # ffffffe000207010 <buddy>
ffffffe000200540:	0087b703          	ld	a4,8(a5)
ffffffe000200544:	fd843783          	ld	a5,-40(s0)
ffffffe000200548:	00379793          	slli	a5,a5,0x3
ffffffe00020054c:	00f707b3          	add	a5,a4,a5
ffffffe000200550:	fe043703          	ld	a4,-32(s0)
ffffffe000200554:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200558:	fd843783          	ld	a5,-40(s0)
ffffffe00020055c:	00178793          	addi	a5,a5,1
ffffffe000200560:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200564:	00007797          	auipc	a5,0x7
ffffffe000200568:	aac78793          	addi	a5,a5,-1364 # ffffffe000207010 <buddy>
ffffffe00020056c:	0007b783          	ld	a5,0(a5)
ffffffe000200570:	00179793          	slli	a5,a5,0x1
ffffffe000200574:	fff78793          	addi	a5,a5,-1
ffffffe000200578:	fd843703          	ld	a4,-40(s0)
ffffffe00020057c:	f8f76ee3          	bltu	a4,a5,ffffffe000200518 <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200580:	fc043823          	sd	zero,-48(s0)
ffffffe000200584:	0180006f          	j	ffffffe00020059c <buddy_init+0x158>
        buddy_alloc(1);
ffffffe000200588:	00100513          	li	a0,1
ffffffe00020058c:	1fc000ef          	jal	ra,ffffffe000200788 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200590:	fd043783          	ld	a5,-48(s0)
ffffffe000200594:	00178793          	addi	a5,a5,1
ffffffe000200598:	fcf43823          	sd	a5,-48(s0)
ffffffe00020059c:	fd043783          	ld	a5,-48(s0)
ffffffe0002005a0:	00c79713          	slli	a4,a5,0xc
ffffffe0002005a4:	00100793          	li	a5,1
ffffffe0002005a8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005ac:	00f70733          	add	a4,a4,a5
ffffffe0002005b0:	00004797          	auipc	a5,0x4
ffffffe0002005b4:	a5878793          	addi	a5,a5,-1448 # ffffffe000204008 <free_page_start>
ffffffe0002005b8:	0007b783          	ld	a5,0(a5)
ffffffe0002005bc:	00078693          	mv	a3,a5
ffffffe0002005c0:	04100793          	li	a5,65
ffffffe0002005c4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005c8:	00f687b3          	add	a5,a3,a5
ffffffe0002005cc:	faf76ee3          	bltu	a4,a5,ffffffe000200588 <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe0002005d0:	00003517          	auipc	a0,0x3
ffffffe0002005d4:	a3050513          	addi	a0,a0,-1488 # ffffffe000203000 <_srodata>
ffffffe0002005d8:	730020ef          	jal	ra,ffffffe000202d08 <printk>
    return;
ffffffe0002005dc:	00000013          	nop
}
ffffffe0002005e0:	02813083          	ld	ra,40(sp)
ffffffe0002005e4:	02013403          	ld	s0,32(sp)
ffffffe0002005e8:	03010113          	addi	sp,sp,48
ffffffe0002005ec:	00008067          	ret

ffffffe0002005f0 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe0002005f0:	fc010113          	addi	sp,sp,-64
ffffffe0002005f4:	02813c23          	sd	s0,56(sp)
ffffffe0002005f8:	04010413          	addi	s0,sp,64
ffffffe0002005fc:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe000200600:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe000200604:	00100793          	li	a5,1
ffffffe000200608:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe00020060c:	00007797          	auipc	a5,0x7
ffffffe000200610:	a0478793          	addi	a5,a5,-1532 # ffffffe000207010 <buddy>
ffffffe000200614:	0007b703          	ld	a4,0(a5)
ffffffe000200618:	fc843783          	ld	a5,-56(s0)
ffffffe00020061c:	00f707b3          	add	a5,a4,a5
ffffffe000200620:	fff78793          	addi	a5,a5,-1
ffffffe000200624:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200628:	02c0006f          	j	ffffffe000200654 <buddy_free+0x64>
        node_size *= 2;
ffffffe00020062c:	fe843783          	ld	a5,-24(s0)
ffffffe000200630:	00179793          	slli	a5,a5,0x1
ffffffe000200634:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe000200638:	fe043783          	ld	a5,-32(s0)
ffffffe00020063c:	02078e63          	beqz	a5,ffffffe000200678 <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200640:	fe043783          	ld	a5,-32(s0)
ffffffe000200644:	00178793          	addi	a5,a5,1
ffffffe000200648:	0017d793          	srli	a5,a5,0x1
ffffffe00020064c:	fff78793          	addi	a5,a5,-1
ffffffe000200650:	fef43023          	sd	a5,-32(s0)
ffffffe000200654:	00007797          	auipc	a5,0x7
ffffffe000200658:	9bc78793          	addi	a5,a5,-1604 # ffffffe000207010 <buddy>
ffffffe00020065c:	0087b703          	ld	a4,8(a5)
ffffffe000200660:	fe043783          	ld	a5,-32(s0)
ffffffe000200664:	00379793          	slli	a5,a5,0x3
ffffffe000200668:	00f707b3          	add	a5,a4,a5
ffffffe00020066c:	0007b783          	ld	a5,0(a5)
ffffffe000200670:	fa079ee3          	bnez	a5,ffffffe00020062c <buddy_free+0x3c>
ffffffe000200674:	0080006f          	j	ffffffe00020067c <buddy_free+0x8c>
            break;
ffffffe000200678:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe00020067c:	00007797          	auipc	a5,0x7
ffffffe000200680:	99478793          	addi	a5,a5,-1644 # ffffffe000207010 <buddy>
ffffffe000200684:	0087b703          	ld	a4,8(a5)
ffffffe000200688:	fe043783          	ld	a5,-32(s0)
ffffffe00020068c:	00379793          	slli	a5,a5,0x3
ffffffe000200690:	00f707b3          	add	a5,a4,a5
ffffffe000200694:	fe843703          	ld	a4,-24(s0)
ffffffe000200698:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe00020069c:	0d00006f          	j	ffffffe00020076c <buddy_free+0x17c>
        index = PARENT(index);
ffffffe0002006a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002006a4:	00178793          	addi	a5,a5,1
ffffffe0002006a8:	0017d793          	srli	a5,a5,0x1
ffffffe0002006ac:	fff78793          	addi	a5,a5,-1
ffffffe0002006b0:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe0002006b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002006b8:	00179793          	slli	a5,a5,0x1
ffffffe0002006bc:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe0002006c0:	00007797          	auipc	a5,0x7
ffffffe0002006c4:	95078793          	addi	a5,a5,-1712 # ffffffe000207010 <buddy>
ffffffe0002006c8:	0087b703          	ld	a4,8(a5)
ffffffe0002006cc:	fe043783          	ld	a5,-32(s0)
ffffffe0002006d0:	00479793          	slli	a5,a5,0x4
ffffffe0002006d4:	00878793          	addi	a5,a5,8
ffffffe0002006d8:	00f707b3          	add	a5,a4,a5
ffffffe0002006dc:	0007b783          	ld	a5,0(a5)
ffffffe0002006e0:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe0002006e4:	00007797          	auipc	a5,0x7
ffffffe0002006e8:	92c78793          	addi	a5,a5,-1748 # ffffffe000207010 <buddy>
ffffffe0002006ec:	0087b703          	ld	a4,8(a5)
ffffffe0002006f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002006f4:	00178793          	addi	a5,a5,1
ffffffe0002006f8:	00479793          	slli	a5,a5,0x4
ffffffe0002006fc:	00f707b3          	add	a5,a4,a5
ffffffe000200700:	0007b783          	ld	a5,0(a5)
ffffffe000200704:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe000200708:	fd843703          	ld	a4,-40(s0)
ffffffe00020070c:	fd043783          	ld	a5,-48(s0)
ffffffe000200710:	00f707b3          	add	a5,a4,a5
ffffffe000200714:	fe843703          	ld	a4,-24(s0)
ffffffe000200718:	02f71463          	bne	a4,a5,ffffffe000200740 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe00020071c:	00007797          	auipc	a5,0x7
ffffffe000200720:	8f478793          	addi	a5,a5,-1804 # ffffffe000207010 <buddy>
ffffffe000200724:	0087b703          	ld	a4,8(a5)
ffffffe000200728:	fe043783          	ld	a5,-32(s0)
ffffffe00020072c:	00379793          	slli	a5,a5,0x3
ffffffe000200730:	00f707b3          	add	a5,a4,a5
ffffffe000200734:	fe843703          	ld	a4,-24(s0)
ffffffe000200738:	00e7b023          	sd	a4,0(a5)
ffffffe00020073c:	0300006f          	j	ffffffe00020076c <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200740:	00007797          	auipc	a5,0x7
ffffffe000200744:	8d078793          	addi	a5,a5,-1840 # ffffffe000207010 <buddy>
ffffffe000200748:	0087b703          	ld	a4,8(a5)
ffffffe00020074c:	fe043783          	ld	a5,-32(s0)
ffffffe000200750:	00379793          	slli	a5,a5,0x3
ffffffe000200754:	00f706b3          	add	a3,a4,a5
ffffffe000200758:	fd843703          	ld	a4,-40(s0)
ffffffe00020075c:	fd043783          	ld	a5,-48(s0)
ffffffe000200760:	00e7f463          	bgeu	a5,a4,ffffffe000200768 <buddy_free+0x178>
ffffffe000200764:	00070793          	mv	a5,a4
ffffffe000200768:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe00020076c:	fe043783          	ld	a5,-32(s0)
ffffffe000200770:	f20798e3          	bnez	a5,ffffffe0002006a0 <buddy_free+0xb0>
    }
}
ffffffe000200774:	00000013          	nop
ffffffe000200778:	00000013          	nop
ffffffe00020077c:	03813403          	ld	s0,56(sp)
ffffffe000200780:	04010113          	addi	sp,sp,64
ffffffe000200784:	00008067          	ret

ffffffe000200788 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe000200788:	fc010113          	addi	sp,sp,-64
ffffffe00020078c:	02113c23          	sd	ra,56(sp)
ffffffe000200790:	02813823          	sd	s0,48(sp)
ffffffe000200794:	04010413          	addi	s0,sp,64
ffffffe000200798:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe00020079c:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe0002007a0:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe0002007a4:	fc843783          	ld	a5,-56(s0)
ffffffe0002007a8:	00079863          	bnez	a5,ffffffe0002007b8 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe0002007ac:	00100793          	li	a5,1
ffffffe0002007b0:	fcf43423          	sd	a5,-56(s0)
ffffffe0002007b4:	0240006f          	j	ffffffe0002007d8 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe0002007b8:	fc843783          	ld	a5,-56(s0)
ffffffe0002007bc:	fff78713          	addi	a4,a5,-1
ffffffe0002007c0:	fc843783          	ld	a5,-56(s0)
ffffffe0002007c4:	00f777b3          	and	a5,a4,a5
ffffffe0002007c8:	00078863          	beqz	a5,ffffffe0002007d8 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe0002007cc:	fc843503          	ld	a0,-56(s0)
ffffffe0002007d0:	bc9ff0ef          	jal	ra,ffffffe000200398 <fixsize>
ffffffe0002007d4:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe0002007d8:	00007797          	auipc	a5,0x7
ffffffe0002007dc:	83878793          	addi	a5,a5,-1992 # ffffffe000207010 <buddy>
ffffffe0002007e0:	0087b703          	ld	a4,8(a5)
ffffffe0002007e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002007e8:	00379793          	slli	a5,a5,0x3
ffffffe0002007ec:	00f707b3          	add	a5,a4,a5
ffffffe0002007f0:	0007b783          	ld	a5,0(a5)
ffffffe0002007f4:	fc843703          	ld	a4,-56(s0)
ffffffe0002007f8:	00e7f663          	bgeu	a5,a4,ffffffe000200804 <buddy_alloc+0x7c>
        return 0;
ffffffe0002007fc:	00000793          	li	a5,0
ffffffe000200800:	1480006f          	j	ffffffe000200948 <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200804:	00007797          	auipc	a5,0x7
ffffffe000200808:	80c78793          	addi	a5,a5,-2036 # ffffffe000207010 <buddy>
ffffffe00020080c:	0007b783          	ld	a5,0(a5)
ffffffe000200810:	fef43023          	sd	a5,-32(s0)
ffffffe000200814:	05c0006f          	j	ffffffe000200870 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe000200818:	00006797          	auipc	a5,0x6
ffffffe00020081c:	7f878793          	addi	a5,a5,2040 # ffffffe000207010 <buddy>
ffffffe000200820:	0087b703          	ld	a4,8(a5)
ffffffe000200824:	fe843783          	ld	a5,-24(s0)
ffffffe000200828:	00479793          	slli	a5,a5,0x4
ffffffe00020082c:	00878793          	addi	a5,a5,8
ffffffe000200830:	00f707b3          	add	a5,a4,a5
ffffffe000200834:	0007b783          	ld	a5,0(a5)
ffffffe000200838:	fc843703          	ld	a4,-56(s0)
ffffffe00020083c:	00e7ec63          	bltu	a5,a4,ffffffe000200854 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200840:	fe843783          	ld	a5,-24(s0)
ffffffe000200844:	00179793          	slli	a5,a5,0x1
ffffffe000200848:	00178793          	addi	a5,a5,1
ffffffe00020084c:	fef43423          	sd	a5,-24(s0)
ffffffe000200850:	0140006f          	j	ffffffe000200864 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe000200854:	fe843783          	ld	a5,-24(s0)
ffffffe000200858:	00178793          	addi	a5,a5,1
ffffffe00020085c:	00179793          	slli	a5,a5,0x1
ffffffe000200860:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200864:	fe043783          	ld	a5,-32(s0)
ffffffe000200868:	0017d793          	srli	a5,a5,0x1
ffffffe00020086c:	fef43023          	sd	a5,-32(s0)
ffffffe000200870:	fe043703          	ld	a4,-32(s0)
ffffffe000200874:	fc843783          	ld	a5,-56(s0)
ffffffe000200878:	faf710e3          	bne	a4,a5,ffffffe000200818 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe00020087c:	00006797          	auipc	a5,0x6
ffffffe000200880:	79478793          	addi	a5,a5,1940 # ffffffe000207010 <buddy>
ffffffe000200884:	0087b703          	ld	a4,8(a5)
ffffffe000200888:	fe843783          	ld	a5,-24(s0)
ffffffe00020088c:	00379793          	slli	a5,a5,0x3
ffffffe000200890:	00f707b3          	add	a5,a4,a5
ffffffe000200894:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200898:	fe843783          	ld	a5,-24(s0)
ffffffe00020089c:	00178713          	addi	a4,a5,1
ffffffe0002008a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002008a4:	02f70733          	mul	a4,a4,a5
ffffffe0002008a8:	00006797          	auipc	a5,0x6
ffffffe0002008ac:	76878793          	addi	a5,a5,1896 # ffffffe000207010 <buddy>
ffffffe0002008b0:	0007b783          	ld	a5,0(a5)
ffffffe0002008b4:	40f707b3          	sub	a5,a4,a5
ffffffe0002008b8:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe0002008bc:	0800006f          	j	ffffffe00020093c <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe0002008c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008c4:	00178793          	addi	a5,a5,1
ffffffe0002008c8:	0017d793          	srli	a5,a5,0x1
ffffffe0002008cc:	fff78793          	addi	a5,a5,-1
ffffffe0002008d0:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008d4:	00006797          	auipc	a5,0x6
ffffffe0002008d8:	73c78793          	addi	a5,a5,1852 # ffffffe000207010 <buddy>
ffffffe0002008dc:	0087b703          	ld	a4,8(a5)
ffffffe0002008e0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008e4:	00178793          	addi	a5,a5,1
ffffffe0002008e8:	00479793          	slli	a5,a5,0x4
ffffffe0002008ec:	00f707b3          	add	a5,a4,a5
ffffffe0002008f0:	0007b603          	ld	a2,0(a5)
ffffffe0002008f4:	00006797          	auipc	a5,0x6
ffffffe0002008f8:	71c78793          	addi	a5,a5,1820 # ffffffe000207010 <buddy>
ffffffe0002008fc:	0087b703          	ld	a4,8(a5)
ffffffe000200900:	fe843783          	ld	a5,-24(s0)
ffffffe000200904:	00479793          	slli	a5,a5,0x4
ffffffe000200908:	00878793          	addi	a5,a5,8
ffffffe00020090c:	00f707b3          	add	a5,a4,a5
ffffffe000200910:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe000200914:	00006797          	auipc	a5,0x6
ffffffe000200918:	6fc78793          	addi	a5,a5,1788 # ffffffe000207010 <buddy>
ffffffe00020091c:	0087b683          	ld	a3,8(a5)
ffffffe000200920:	fe843783          	ld	a5,-24(s0)
ffffffe000200924:	00379793          	slli	a5,a5,0x3
ffffffe000200928:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe00020092c:	00060793          	mv	a5,a2
ffffffe000200930:	00e7f463          	bgeu	a5,a4,ffffffe000200938 <buddy_alloc+0x1b0>
ffffffe000200934:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200938:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe00020093c:	fe843783          	ld	a5,-24(s0)
ffffffe000200940:	f80790e3          	bnez	a5,ffffffe0002008c0 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe000200944:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200948:	00078513          	mv	a0,a5
ffffffe00020094c:	03813083          	ld	ra,56(sp)
ffffffe000200950:	03013403          	ld	s0,48(sp)
ffffffe000200954:	04010113          	addi	sp,sp,64
ffffffe000200958:	00008067          	ret

ffffffe00020095c <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe00020095c:	fd010113          	addi	sp,sp,-48
ffffffe000200960:	02113423          	sd	ra,40(sp)
ffffffe000200964:	02813023          	sd	s0,32(sp)
ffffffe000200968:	03010413          	addi	s0,sp,48
ffffffe00020096c:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200970:	fd843503          	ld	a0,-40(s0)
ffffffe000200974:	e15ff0ef          	jal	ra,ffffffe000200788 <buddy_alloc>
ffffffe000200978:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe00020097c:	fe843783          	ld	a5,-24(s0)
ffffffe000200980:	00079663          	bnez	a5,ffffffe00020098c <alloc_pages+0x30>
        return 0;
ffffffe000200984:	00000793          	li	a5,0
ffffffe000200988:	0180006f          	j	ffffffe0002009a0 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe00020098c:	fe843783          	ld	a5,-24(s0)
ffffffe000200990:	00c79713          	slli	a4,a5,0xc
ffffffe000200994:	fff00793          	li	a5,-1
ffffffe000200998:	02579793          	slli	a5,a5,0x25
ffffffe00020099c:	00f707b3          	add	a5,a4,a5
}
ffffffe0002009a0:	00078513          	mv	a0,a5
ffffffe0002009a4:	02813083          	ld	ra,40(sp)
ffffffe0002009a8:	02013403          	ld	s0,32(sp)
ffffffe0002009ac:	03010113          	addi	sp,sp,48
ffffffe0002009b0:	00008067          	ret

ffffffe0002009b4 <alloc_page>:

void *alloc_page() {
ffffffe0002009b4:	ff010113          	addi	sp,sp,-16
ffffffe0002009b8:	00113423          	sd	ra,8(sp)
ffffffe0002009bc:	00813023          	sd	s0,0(sp)
ffffffe0002009c0:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe0002009c4:	00100513          	li	a0,1
ffffffe0002009c8:	f95ff0ef          	jal	ra,ffffffe00020095c <alloc_pages>
ffffffe0002009cc:	00050793          	mv	a5,a0
}
ffffffe0002009d0:	00078513          	mv	a0,a5
ffffffe0002009d4:	00813083          	ld	ra,8(sp)
ffffffe0002009d8:	00013403          	ld	s0,0(sp)
ffffffe0002009dc:	01010113          	addi	sp,sp,16
ffffffe0002009e0:	00008067          	ret

ffffffe0002009e4 <free_pages>:

void free_pages(void *va) {
ffffffe0002009e4:	fe010113          	addi	sp,sp,-32
ffffffe0002009e8:	00113c23          	sd	ra,24(sp)
ffffffe0002009ec:	00813823          	sd	s0,16(sp)
ffffffe0002009f0:	02010413          	addi	s0,sp,32
ffffffe0002009f4:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe0002009f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002009fc:	00100793          	li	a5,1
ffffffe000200a00:	02579793          	slli	a5,a5,0x25
ffffffe000200a04:	00f707b3          	add	a5,a4,a5
ffffffe000200a08:	00c7d793          	srli	a5,a5,0xc
ffffffe000200a0c:	00078513          	mv	a0,a5
ffffffe000200a10:	be1ff0ef          	jal	ra,ffffffe0002005f0 <buddy_free>
}
ffffffe000200a14:	00000013          	nop
ffffffe000200a18:	01813083          	ld	ra,24(sp)
ffffffe000200a1c:	01013403          	ld	s0,16(sp)
ffffffe000200a20:	02010113          	addi	sp,sp,32
ffffffe000200a24:	00008067          	ret

ffffffe000200a28 <kalloc>:

void *kalloc() {
ffffffe000200a28:	ff010113          	addi	sp,sp,-16
ffffffe000200a2c:	00113423          	sd	ra,8(sp)
ffffffe000200a30:	00813023          	sd	s0,0(sp)
ffffffe000200a34:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200a38:	f7dff0ef          	jal	ra,ffffffe0002009b4 <alloc_page>
ffffffe000200a3c:	00050793          	mv	a5,a0
}
ffffffe000200a40:	00078513          	mv	a0,a5
ffffffe000200a44:	00813083          	ld	ra,8(sp)
ffffffe000200a48:	00013403          	ld	s0,0(sp)
ffffffe000200a4c:	01010113          	addi	sp,sp,16
ffffffe000200a50:	00008067          	ret

ffffffe000200a54 <kfree>:

void kfree(void *addr) {
ffffffe000200a54:	fe010113          	addi	sp,sp,-32
ffffffe000200a58:	00113c23          	sd	ra,24(sp)
ffffffe000200a5c:	00813823          	sd	s0,16(sp)
ffffffe000200a60:	02010413          	addi	s0,sp,32
ffffffe000200a64:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200a68:	fe843503          	ld	a0,-24(s0)
ffffffe000200a6c:	f79ff0ef          	jal	ra,ffffffe0002009e4 <free_pages>

    return;
ffffffe000200a70:	00000013          	nop
}
ffffffe000200a74:	01813083          	ld	ra,24(sp)
ffffffe000200a78:	01013403          	ld	s0,16(sp)
ffffffe000200a7c:	02010113          	addi	sp,sp,32
ffffffe000200a80:	00008067          	ret

ffffffe000200a84 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200a84:	fd010113          	addi	sp,sp,-48
ffffffe000200a88:	02113423          	sd	ra,40(sp)
ffffffe000200a8c:	02813023          	sd	s0,32(sp)
ffffffe000200a90:	03010413          	addi	s0,sp,48
ffffffe000200a94:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a98:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a9c:	fd843703          	ld	a4,-40(s0)
ffffffe000200aa0:	000017b7          	lui	a5,0x1
ffffffe000200aa4:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200aa8:	00f70733          	add	a4,a4,a5
ffffffe000200aac:	fffff7b7          	lui	a5,0xfffff
ffffffe000200ab0:	00f777b3          	and	a5,a4,a5
ffffffe000200ab4:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200ab8:	01c0006f          	j	ffffffe000200ad4 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200abc:	fe843503          	ld	a0,-24(s0)
ffffffe000200ac0:	f95ff0ef          	jal	ra,ffffffe000200a54 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200ac4:	fe843703          	ld	a4,-24(s0)
ffffffe000200ac8:	000017b7          	lui	a5,0x1
ffffffe000200acc:	00f707b3          	add	a5,a4,a5
ffffffe000200ad0:	fef43423          	sd	a5,-24(s0)
ffffffe000200ad4:	fe843703          	ld	a4,-24(s0)
ffffffe000200ad8:	000017b7          	lui	a5,0x1
ffffffe000200adc:	00f70733          	add	a4,a4,a5
ffffffe000200ae0:	fd043783          	ld	a5,-48(s0)
ffffffe000200ae4:	fce7fce3          	bgeu	a5,a4,ffffffe000200abc <kfreerange+0x38>
    }
}
ffffffe000200ae8:	00000013          	nop
ffffffe000200aec:	00000013          	nop
ffffffe000200af0:	02813083          	ld	ra,40(sp)
ffffffe000200af4:	02013403          	ld	s0,32(sp)
ffffffe000200af8:	03010113          	addi	sp,sp,48
ffffffe000200afc:	00008067          	ret

ffffffe000200b00 <mm_init>:

void mm_init(void) {
ffffffe000200b00:	ff010113          	addi	sp,sp,-16
ffffffe000200b04:	00113423          	sd	ra,8(sp)
ffffffe000200b08:	00813023          	sd	s0,0(sp)
ffffffe000200b0c:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200b10:	935ff0ef          	jal	ra,ffffffe000200444 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200b14:	00002517          	auipc	a0,0x2
ffffffe000200b18:	50450513          	addi	a0,a0,1284 # ffffffe000203018 <_srodata+0x18>
ffffffe000200b1c:	1ec020ef          	jal	ra,ffffffe000202d08 <printk>
}
ffffffe000200b20:	00000013          	nop
ffffffe000200b24:	00813083          	ld	ra,8(sp)
ffffffe000200b28:	00013403          	ld	s0,0(sp)
ffffffe000200b2c:	01010113          	addi	sp,sp,16
ffffffe000200b30:	00008067          	ret

ffffffe000200b34 <memcpy>:

// upaa 起始结束地址
extern char _sramdisk[];
extern char _eramdisk[];

void memcpy(void *dest,void *src, size_t n) {
ffffffe000200b34:	fb010113          	addi	sp,sp,-80
ffffffe000200b38:	04813423          	sd	s0,72(sp)
ffffffe000200b3c:	05010413          	addi	s0,sp,80
ffffffe000200b40:	fca43423          	sd	a0,-56(s0)
ffffffe000200b44:	fcb43023          	sd	a1,-64(s0)
ffffffe000200b48:	fac43c23          	sd	a2,-72(s0)
    char *d = (char *)dest;
ffffffe000200b4c:	fc843783          	ld	a5,-56(s0)
ffffffe000200b50:	fef43023          	sd	a5,-32(s0)
    char *s = (char *)src;
ffffffe000200b54:	fc043783          	ld	a5,-64(s0)
ffffffe000200b58:	fcf43c23          	sd	a5,-40(s0)
    for (size_t i = 0; i < n; i++) {
ffffffe000200b5c:	fe043423          	sd	zero,-24(s0)
ffffffe000200b60:	0300006f          	j	ffffffe000200b90 <memcpy+0x5c>
        d[i] = s[i];
ffffffe000200b64:	fd843703          	ld	a4,-40(s0)
ffffffe000200b68:	fe843783          	ld	a5,-24(s0)
ffffffe000200b6c:	00f70733          	add	a4,a4,a5
ffffffe000200b70:	fe043683          	ld	a3,-32(s0)
ffffffe000200b74:	fe843783          	ld	a5,-24(s0)
ffffffe000200b78:	00f687b3          	add	a5,a3,a5
ffffffe000200b7c:	00074703          	lbu	a4,0(a4)
ffffffe000200b80:	00e78023          	sb	a4,0(a5) # 1000 <PGSIZE>
    for (size_t i = 0; i < n; i++) {
ffffffe000200b84:	fe843783          	ld	a5,-24(s0)
ffffffe000200b88:	00178793          	addi	a5,a5,1
ffffffe000200b8c:	fef43423          	sd	a5,-24(s0)
ffffffe000200b90:	fe843703          	ld	a4,-24(s0)
ffffffe000200b94:	fb843783          	ld	a5,-72(s0)
ffffffe000200b98:	fcf766e3          	bltu	a4,a5,ffffffe000200b64 <memcpy+0x30>
    }
}
ffffffe000200b9c:	00000013          	nop
ffffffe000200ba0:	00000013          	nop
ffffffe000200ba4:	04813403          	ld	s0,72(sp)
ffffffe000200ba8:	05010113          	addi	sp,sp,80
ffffffe000200bac:	00008067          	ret

ffffffe000200bb0 <task_init>:

void task_init() {
ffffffe000200bb0:	fb010113          	addi	sp,sp,-80
ffffffe000200bb4:	04113423          	sd	ra,72(sp)
ffffffe000200bb8:	04813023          	sd	s0,64(sp)
ffffffe000200bbc:	02913c23          	sd	s1,56(sp)
ffffffe000200bc0:	05010413          	addi	s0,sp,80
    srand(2024);
ffffffe000200bc4:	7e800513          	li	a0,2024
ffffffe000200bc8:	1c0020ef          	jal	ra,ffffffe000202d88 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle=(struct task_struct *)kalloc();
ffffffe000200bcc:	e5dff0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000200bd0:	00050713          	mv	a4,a0
ffffffe000200bd4:	00008797          	auipc	a5,0x8
ffffffe000200bd8:	42c78793          	addi	a5,a5,1068 # ffffffe000209000 <idle>
ffffffe000200bdc:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200be0:	00008797          	auipc	a5,0x8
ffffffe000200be4:	42078793          	addi	a5,a5,1056 # ffffffe000209000 <idle>
ffffffe000200be8:	0007b783          	ld	a5,0(a5)
ffffffe000200bec:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200bf0:	00008797          	auipc	a5,0x8
ffffffe000200bf4:	41078793          	addi	a5,a5,1040 # ffffffe000209000 <idle>
ffffffe000200bf8:	0007b783          	ld	a5,0(a5)
ffffffe000200bfc:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200c00:	00008797          	auipc	a5,0x8
ffffffe000200c04:	40078793          	addi	a5,a5,1024 # ffffffe000209000 <idle>
ffffffe000200c08:	0007b783          	ld	a5,0(a5)
ffffffe000200c0c:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200c10:	00008797          	auipc	a5,0x8
ffffffe000200c14:	3f078793          	addi	a5,a5,1008 # ffffffe000209000 <idle>
ffffffe000200c18:	0007b783          	ld	a5,0(a5)
ffffffe000200c1c:	0007bc23          	sd	zero,24(a5)
    idle->thread.first_schedule=0;
ffffffe000200c20:	00008797          	auipc	a5,0x8
ffffffe000200c24:	3e078793          	addi	a5,a5,992 # ffffffe000209000 <idle>
ffffffe000200c28:	0007b783          	ld	a5,0(a5)
ffffffe000200c2c:	0807b823          	sd	zero,144(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200c30:	00008797          	auipc	a5,0x8
ffffffe000200c34:	3d078793          	addi	a5,a5,976 # ffffffe000209000 <idle>
ffffffe000200c38:	0007b703          	ld	a4,0(a5)
ffffffe000200c3c:	00008797          	auipc	a5,0x8
ffffffe000200c40:	3cc78793          	addi	a5,a5,972 # ffffffe000209008 <current>
ffffffe000200c44:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200c48:	00008797          	auipc	a5,0x8
ffffffe000200c4c:	3b878793          	addi	a5,a5,952 # ffffffe000209000 <idle>
ffffffe000200c50:	0007b703          	ld	a4,0(a5)
ffffffe000200c54:	00008797          	auipc	a5,0x8
ffffffe000200c58:	3bc78793          	addi	a5,a5,956 # ffffffe000209010 <task>
ffffffe000200c5c:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    size_t uapp_size=(size_t)(_eramdisk-_sramdisk); // uapp 大小
ffffffe000200c60:	00004717          	auipc	a4,0x4
ffffffe000200c64:	3c470713          	addi	a4,a4,964 # ffffffe000205024 <_eramdisk>
ffffffe000200c68:	00004797          	auipc	a5,0x4
ffffffe000200c6c:	39878793          	addi	a5,a5,920 # ffffffe000205000 <_sramdisk>
ffffffe000200c70:	40f707b3          	sub	a5,a4,a5
ffffffe000200c74:	fcf43823          	sd	a5,-48(s0)
    size_t num_pages=(uapp_size+PGSIZE-1)/PGSIZE; // uapp 占用页数
ffffffe000200c78:	fd043703          	ld	a4,-48(s0)
ffffffe000200c7c:	000017b7          	lui	a5,0x1
ffffffe000200c80:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200c84:	00f707b3          	add	a5,a4,a5
ffffffe000200c88:	00c7d793          	srli	a5,a5,0xc
ffffffe000200c8c:	fcf43423          	sd	a5,-56(s0)

    for(int i=1;i<NR_TASKS;i++){
ffffffe000200c90:	00100793          	li	a5,1
ffffffe000200c94:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200c98:	3580006f          	j	ffffffe000200ff0 <task_init+0x440>
        task[i]=(struct task_struct *)kalloc();
ffffffe000200c9c:	d8dff0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000200ca0:	00050693          	mv	a3,a0
ffffffe000200ca4:	00008717          	auipc	a4,0x8
ffffffe000200ca8:	36c70713          	addi	a4,a4,876 # ffffffe000209010 <task>
ffffffe000200cac:	fdc42783          	lw	a5,-36(s0)
ffffffe000200cb0:	00379793          	slli	a5,a5,0x3
ffffffe000200cb4:	00f707b3          	add	a5,a4,a5
ffffffe000200cb8:	00d7b023          	sd	a3,0(a5)
        memset(task[i],0,sizeof(struct task_struct));
ffffffe000200cbc:	00008717          	auipc	a4,0x8
ffffffe000200cc0:	35470713          	addi	a4,a4,852 # ffffffe000209010 <task>
ffffffe000200cc4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200cc8:	00379793          	slli	a5,a5,0x3
ffffffe000200ccc:	00f707b3          	add	a5,a4,a5
ffffffe000200cd0:	0007b783          	ld	a5,0(a5)
ffffffe000200cd4:	0b800613          	li	a2,184
ffffffe000200cd8:	00000593          	li	a1,0
ffffffe000200cdc:	00078513          	mv	a0,a5
ffffffe000200ce0:	148020ef          	jal	ra,ffffffe000202e28 <memset>
        task[i]->state=TASK_RUNNING;
ffffffe000200ce4:	00008717          	auipc	a4,0x8
ffffffe000200ce8:	32c70713          	addi	a4,a4,812 # ffffffe000209010 <task>
ffffffe000200cec:	fdc42783          	lw	a5,-36(s0)
ffffffe000200cf0:	00379793          	slli	a5,a5,0x3
ffffffe000200cf4:	00f707b3          	add	a5,a4,a5
ffffffe000200cf8:	0007b783          	ld	a5,0(a5)
ffffffe000200cfc:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe000200d00:	00008717          	auipc	a4,0x8
ffffffe000200d04:	31070713          	addi	a4,a4,784 # ffffffe000209010 <task>
ffffffe000200d08:	fdc42783          	lw	a5,-36(s0)
ffffffe000200d0c:	00379793          	slli	a5,a5,0x3
ffffffe000200d10:	00f707b3          	add	a5,a4,a5
ffffffe000200d14:	0007b783          	ld	a5,0(a5)
ffffffe000200d18:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX-PRIORITY_MIN+1)+PRIORITY_MIN;
ffffffe000200d1c:	0b0020ef          	jal	ra,ffffffe000202dcc <rand>
ffffffe000200d20:	00050793          	mv	a5,a0
ffffffe000200d24:	00078713          	mv	a4,a5
ffffffe000200d28:	00a00793          	li	a5,10
ffffffe000200d2c:	02f767bb          	remw	a5,a4,a5
ffffffe000200d30:	0007879b          	sext.w	a5,a5
ffffffe000200d34:	0017879b          	addiw	a5,a5,1
ffffffe000200d38:	0007869b          	sext.w	a3,a5
ffffffe000200d3c:	00008717          	auipc	a4,0x8
ffffffe000200d40:	2d470713          	addi	a4,a4,724 # ffffffe000209010 <task>
ffffffe000200d44:	fdc42783          	lw	a5,-36(s0)
ffffffe000200d48:	00379793          	slli	a5,a5,0x3
ffffffe000200d4c:	00f707b3          	add	a5,a4,a5
ffffffe000200d50:	0007b783          	ld	a5,0(a5)
ffffffe000200d54:	00068713          	mv	a4,a3
ffffffe000200d58:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe000200d5c:	00008717          	auipc	a4,0x8
ffffffe000200d60:	2b470713          	addi	a4,a4,692 # ffffffe000209010 <task>
ffffffe000200d64:	fdc42783          	lw	a5,-36(s0)
ffffffe000200d68:	00379793          	slli	a5,a5,0x3
ffffffe000200d6c:	00f707b3          	add	a5,a4,a5
ffffffe000200d70:	0007b783          	ld	a5,0(a5)
ffffffe000200d74:	fdc42703          	lw	a4,-36(s0)
ffffffe000200d78:	00e7bc23          	sd	a4,24(a5)
        task[i]->thread.ra=(uint64_t)&__dummy;
ffffffe000200d7c:	00008717          	auipc	a4,0x8
ffffffe000200d80:	29470713          	addi	a4,a4,660 # ffffffe000209010 <task>
ffffffe000200d84:	fdc42783          	lw	a5,-36(s0)
ffffffe000200d88:	00379793          	slli	a5,a5,0x3
ffffffe000200d8c:	00f707b3          	add	a5,a4,a5
ffffffe000200d90:	0007b783          	ld	a5,0(a5)
ffffffe000200d94:	fffff717          	auipc	a4,0xfffff
ffffffe000200d98:	48070713          	addi	a4,a4,1152 # ffffffe000200214 <__dummy>
ffffffe000200d9c:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe000200da0:	00008717          	auipc	a4,0x8
ffffffe000200da4:	27070713          	addi	a4,a4,624 # ffffffe000209010 <task>
ffffffe000200da8:	fdc42783          	lw	a5,-36(s0)
ffffffe000200dac:	00379793          	slli	a5,a5,0x3
ffffffe000200db0:	00f707b3          	add	a5,a4,a5
ffffffe000200db4:	0007b783          	ld	a5,0(a5)
ffffffe000200db8:	00078693          	mv	a3,a5
ffffffe000200dbc:	00008717          	auipc	a4,0x8
ffffffe000200dc0:	25470713          	addi	a4,a4,596 # ffffffe000209010 <task>
ffffffe000200dc4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200dc8:	00379793          	slli	a5,a5,0x3
ffffffe000200dcc:	00f707b3          	add	a5,a4,a5
ffffffe000200dd0:	0007b783          	ld	a5,0(a5)
ffffffe000200dd4:	00001737          	lui	a4,0x1
ffffffe000200dd8:	00e68733          	add	a4,a3,a4
ffffffe000200ddc:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.first_schedule=1;
ffffffe000200de0:	00008717          	auipc	a4,0x8
ffffffe000200de4:	23070713          	addi	a4,a4,560 # ffffffe000209010 <task>
ffffffe000200de8:	fdc42783          	lw	a5,-36(s0)
ffffffe000200dec:	00379793          	slli	a5,a5,0x3
ffffffe000200df0:	00f707b3          	add	a5,a4,a5
ffffffe000200df4:	0007b783          	ld	a5,0(a5)
ffffffe000200df8:	00100713          	li	a4,1
ffffffe000200dfc:	08e7b823          	sd	a4,144(a5)
        task[i]->thread.sepc=(uint64_t)USER_START;   //将 sepc 设置为 USER_START
ffffffe000200e00:	00008717          	auipc	a4,0x8
ffffffe000200e04:	21070713          	addi	a4,a4,528 # ffffffe000209010 <task>
ffffffe000200e08:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e0c:	00379793          	slli	a5,a5,0x3
ffffffe000200e10:	00f707b3          	add	a5,a4,a5
ffffffe000200e14:	0007b783          	ld	a5,0(a5)
ffffffe000200e18:	0807bc23          	sd	zero,152(a5)
        task[i]->thread.sstatus=0;
ffffffe000200e1c:	00008717          	auipc	a4,0x8
ffffffe000200e20:	1f470713          	addi	a4,a4,500 # ffffffe000209010 <task>
ffffffe000200e24:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e28:	00379793          	slli	a5,a5,0x3
ffffffe000200e2c:	00f707b3          	add	a5,a4,a5
ffffffe000200e30:	0007b783          	ld	a5,0(a5)
ffffffe000200e34:	0a07b023          	sd	zero,160(a5)
        task[i]->thread.sstatus&=~(1UL<<8);         //将 SPP 位置 0，使得 sret 返回至 U-Mode
ffffffe000200e38:	00008717          	auipc	a4,0x8
ffffffe000200e3c:	1d870713          	addi	a4,a4,472 # ffffffe000209010 <task>
ffffffe000200e40:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e44:	00379793          	slli	a5,a5,0x3
ffffffe000200e48:	00f707b3          	add	a5,a4,a5
ffffffe000200e4c:	0007b783          	ld	a5,0(a5)
ffffffe000200e50:	0a07b703          	ld	a4,160(a5)
ffffffe000200e54:	00008697          	auipc	a3,0x8
ffffffe000200e58:	1bc68693          	addi	a3,a3,444 # ffffffe000209010 <task>
ffffffe000200e5c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e60:	00379793          	slli	a5,a5,0x3
ffffffe000200e64:	00f687b3          	add	a5,a3,a5
ffffffe000200e68:	0007b783          	ld	a5,0(a5)
ffffffe000200e6c:	eff77713          	andi	a4,a4,-257
ffffffe000200e70:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sstatus|=(1UL<<18);        //将 SUM 位置 1， S-Mode 可以访问 User 页表
ffffffe000200e74:	00008717          	auipc	a4,0x8
ffffffe000200e78:	19c70713          	addi	a4,a4,412 # ffffffe000209010 <task>
ffffffe000200e7c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e80:	00379793          	slli	a5,a5,0x3
ffffffe000200e84:	00f707b3          	add	a5,a4,a5
ffffffe000200e88:	0007b783          	ld	a5,0(a5)
ffffffe000200e8c:	0a07b683          	ld	a3,160(a5)
ffffffe000200e90:	00008717          	auipc	a4,0x8
ffffffe000200e94:	18070713          	addi	a4,a4,384 # ffffffe000209010 <task>
ffffffe000200e98:	fdc42783          	lw	a5,-36(s0)
ffffffe000200e9c:	00379793          	slli	a5,a5,0x3
ffffffe000200ea0:	00f707b3          	add	a5,a4,a5
ffffffe000200ea4:	0007b783          	ld	a5,0(a5)
ffffffe000200ea8:	00040737          	lui	a4,0x40
ffffffe000200eac:	00e6e733          	or	a4,a3,a4
ffffffe000200eb0:	0ae7b023          	sd	a4,160(a5)
        task[i]->thread.sscratch = (uint64_t)USER_END;//将 sscratch 设置为 U-Mode 的 sp
ffffffe000200eb4:	00008717          	auipc	a4,0x8
ffffffe000200eb8:	15c70713          	addi	a4,a4,348 # ffffffe000209010 <task>
ffffffe000200ebc:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ec0:	00379793          	slli	a5,a5,0x3
ffffffe000200ec4:	00f707b3          	add	a5,a4,a5
ffffffe000200ec8:	0007b783          	ld	a5,0(a5)
ffffffe000200ecc:	00100713          	li	a4,1
ffffffe000200ed0:	02671713          	slli	a4,a4,0x26
ffffffe000200ed4:	0ae7b423          	sd	a4,168(a5)

        // 创建属于它自己的页表：
        task[i]->pgd=(uint64_t *)kalloc();
ffffffe000200ed8:	00008717          	auipc	a4,0x8
ffffffe000200edc:	13870713          	addi	a4,a4,312 # ffffffe000209010 <task>
ffffffe000200ee0:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ee4:	00379793          	slli	a5,a5,0x3
ffffffe000200ee8:	00f707b3          	add	a5,a4,a5
ffffffe000200eec:	0007b483          	ld	s1,0(a5)
ffffffe000200ef0:	b39ff0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000200ef4:	00050793          	mv	a5,a0
ffffffe000200ef8:	0af4b823          	sd	a5,176(s1)
        //将内核页表 swapper_pg_dir 复制到进程的页表中
        memcpy(task[i]->pgd,swapper_pg_dir,PGSIZE);
ffffffe000200efc:	00008717          	auipc	a4,0x8
ffffffe000200f00:	11470713          	addi	a4,a4,276 # ffffffe000209010 <task>
ffffffe000200f04:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f08:	00379793          	slli	a5,a5,0x3
ffffffe000200f0c:	00f707b3          	add	a5,a4,a5
ffffffe000200f10:	0007b783          	ld	a5,0(a5)
ffffffe000200f14:	0b07b783          	ld	a5,176(a5)
ffffffe000200f18:	00001637          	lui	a2,0x1
ffffffe000200f1c:	00007597          	auipc	a1,0x7
ffffffe000200f20:	0e458593          	addi	a1,a1,228 # ffffffe000208000 <swapper_pg_dir>
ffffffe000200f24:	00078513          	mv	a0,a5
ffffffe000200f28:	c0dff0ef          	jal	ra,ffffffe000200b34 <memcpy>
        void *uapp_mem=alloc_pages(num_pages);  //分配内存
ffffffe000200f2c:	fc843503          	ld	a0,-56(s0)
ffffffe000200f30:	a2dff0ef          	jal	ra,ffffffe00020095c <alloc_pages>
ffffffe000200f34:	fca43023          	sd	a0,-64(s0)
        //将 uapp 复制到分配的内存中
        memcpy(uapp_mem,_sramdisk,uapp_size);
ffffffe000200f38:	fd043603          	ld	a2,-48(s0)
ffffffe000200f3c:	00004597          	auipc	a1,0x4
ffffffe000200f40:	0c458593          	addi	a1,a1,196 # ffffffe000205000 <_sramdisk>
ffffffe000200f44:	fc043503          	ld	a0,-64(s0)
ffffffe000200f48:	bedff0ef          	jal	ra,ffffffe000200b34 <memcpy>
        //将 uapp 所在的页面映射到进程的页表中
        create_mapping(task[i]->pgd,(uint64_t)USER_START,VA2PA((uint64_t)uapp_mem),uapp_size,PTE_V|PTE_R|PTE_W|PTE_X|PTE_U);
ffffffe000200f4c:	00008717          	auipc	a4,0x8
ffffffe000200f50:	0c470713          	addi	a4,a4,196 # ffffffe000209010 <task>
ffffffe000200f54:	fdc42783          	lw	a5,-36(s0)
ffffffe000200f58:	00379793          	slli	a5,a5,0x3
ffffffe000200f5c:	00f707b3          	add	a5,a4,a5
ffffffe000200f60:	0007b783          	ld	a5,0(a5)
ffffffe000200f64:	0b07b503          	ld	a0,176(a5)
ffffffe000200f68:	fc043703          	ld	a4,-64(s0)
ffffffe000200f6c:	04100793          	li	a5,65
ffffffe000200f70:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f74:	00f707b3          	add	a5,a4,a5
ffffffe000200f78:	01f00713          	li	a4,31
ffffffe000200f7c:	fd043683          	ld	a3,-48(s0)
ffffffe000200f80:	00078613          	mv	a2,a5
ffffffe000200f84:	00000593          	li	a1,0
ffffffe000200f88:	22d000ef          	jal	ra,ffffffe0002019b4 <create_mapping>

        //设置用户态栈
        void *user_stack=kalloc();
ffffffe000200f8c:	a9dff0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000200f90:	faa43c23          	sd	a0,-72(s0)
        uint64_t stack_va=USER_END-PGSIZE; //用户栈顶虚拟地址
ffffffe000200f94:	040007b7          	lui	a5,0x4000
ffffffe000200f98:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000200f9c:	00c79793          	slli	a5,a5,0xc
ffffffe000200fa0:	faf43823          	sd	a5,-80(s0)
        create_mapping(task[i]->pgd,stack_va,VA2PA((uint64_t)user_stack),PGSIZE,PTE_V|PTE_R|PTE_W|PTE_U);
ffffffe000200fa4:	00008717          	auipc	a4,0x8
ffffffe000200fa8:	06c70713          	addi	a4,a4,108 # ffffffe000209010 <task>
ffffffe000200fac:	fdc42783          	lw	a5,-36(s0)
ffffffe000200fb0:	00379793          	slli	a5,a5,0x3
ffffffe000200fb4:	00f707b3          	add	a5,a4,a5
ffffffe000200fb8:	0007b783          	ld	a5,0(a5)
ffffffe000200fbc:	0b07b503          	ld	a0,176(a5)
ffffffe000200fc0:	fb843703          	ld	a4,-72(s0)
ffffffe000200fc4:	04100793          	li	a5,65
ffffffe000200fc8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200fcc:	00f707b3          	add	a5,a4,a5
ffffffe000200fd0:	01700713          	li	a4,23
ffffffe000200fd4:	000016b7          	lui	a3,0x1
ffffffe000200fd8:	00078613          	mv	a2,a5
ffffffe000200fdc:	fb043583          	ld	a1,-80(s0)
ffffffe000200fe0:	1d5000ef          	jal	ra,ffffffe0002019b4 <create_mapping>
    for(int i=1;i<NR_TASKS;i++){
ffffffe000200fe4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200fe8:	0017879b          	addiw	a5,a5,1
ffffffe000200fec:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200ff0:	fdc42783          	lw	a5,-36(s0)
ffffffe000200ff4:	0007871b          	sext.w	a4,a5
ffffffe000200ff8:	00400793          	li	a5,4
ffffffe000200ffc:	cae7d0e3          	bge	a5,a4,ffffffe000200c9c <task_init+0xec>
                                            

    }

    printk("...task_init done!\n");
ffffffe000201000:	00002517          	auipc	a0,0x2
ffffffe000201004:	03050513          	addi	a0,a0,48 # ffffffe000203030 <_srodata+0x30>
ffffffe000201008:	501010ef          	jal	ra,ffffffe000202d08 <printk>
}
ffffffe00020100c:	00000013          	nop
ffffffe000201010:	04813083          	ld	ra,72(sp)
ffffffe000201014:	04013403          	ld	s0,64(sp)
ffffffe000201018:	03813483          	ld	s1,56(sp)
ffffffe00020101c:	05010113          	addi	sp,sp,80
ffffffe000201020:	00008067          	ret

ffffffe000201024 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000201024:	fd010113          	addi	sp,sp,-48
ffffffe000201028:	02113423          	sd	ra,40(sp)
ffffffe00020102c:	02813023          	sd	s0,32(sp)
ffffffe000201030:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe000201034:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000201038:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe00020103c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000201040:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000201044:	fff00793          	li	a5,-1
ffffffe000201048:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020104c:	fe442783          	lw	a5,-28(s0)
ffffffe000201050:	0007871b          	sext.w	a4,a5
ffffffe000201054:	fff00793          	li	a5,-1
ffffffe000201058:	00f70e63          	beq	a4,a5,ffffffe000201074 <dummy+0x50>
ffffffe00020105c:	00008797          	auipc	a5,0x8
ffffffe000201060:	fac78793          	addi	a5,a5,-84 # ffffffe000209008 <current>
ffffffe000201064:	0007b783          	ld	a5,0(a5)
ffffffe000201068:	0087b703          	ld	a4,8(a5)
ffffffe00020106c:	fe442783          	lw	a5,-28(s0)
ffffffe000201070:	fcf70ee3          	beq	a4,a5,ffffffe00020104c <dummy+0x28>
ffffffe000201074:	00008797          	auipc	a5,0x8
ffffffe000201078:	f9478793          	addi	a5,a5,-108 # ffffffe000209008 <current>
ffffffe00020107c:	0007b783          	ld	a5,0(a5)
ffffffe000201080:	0087b783          	ld	a5,8(a5)
ffffffe000201084:	fc0784e3          	beqz	a5,ffffffe00020104c <dummy+0x28>
            if (current->counter == 1) {
ffffffe000201088:	00008797          	auipc	a5,0x8
ffffffe00020108c:	f8078793          	addi	a5,a5,-128 # ffffffe000209008 <current>
ffffffe000201090:	0007b783          	ld	a5,0(a5)
ffffffe000201094:	0087b703          	ld	a4,8(a5)
ffffffe000201098:	00100793          	li	a5,1
ffffffe00020109c:	00f71e63          	bne	a4,a5,ffffffe0002010b8 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe0002010a0:	00008797          	auipc	a5,0x8
ffffffe0002010a4:	f6878793          	addi	a5,a5,-152 # ffffffe000209008 <current>
ffffffe0002010a8:	0007b783          	ld	a5,0(a5)
ffffffe0002010ac:	0087b703          	ld	a4,8(a5)
ffffffe0002010b0:	fff70713          	addi	a4,a4,-1
ffffffe0002010b4:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe0002010b8:	00008797          	auipc	a5,0x8
ffffffe0002010bc:	f5078793          	addi	a5,a5,-176 # ffffffe000209008 <current>
ffffffe0002010c0:	0007b783          	ld	a5,0(a5)
ffffffe0002010c4:	0087b783          	ld	a5,8(a5)
ffffffe0002010c8:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe0002010cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002010d0:	00178713          	addi	a4,a5,1
ffffffe0002010d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002010d8:	02f777b3          	remu	a5,a4,a5
ffffffe0002010dc:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe0002010e0:	00008797          	auipc	a5,0x8
ffffffe0002010e4:	f2878793          	addi	a5,a5,-216 # ffffffe000209008 <current>
ffffffe0002010e8:	0007b783          	ld	a5,0(a5)
ffffffe0002010ec:	0187b783          	ld	a5,24(a5)
ffffffe0002010f0:	fe843603          	ld	a2,-24(s0)
ffffffe0002010f4:	00078593          	mv	a1,a5
ffffffe0002010f8:	00002517          	auipc	a0,0x2
ffffffe0002010fc:	f5050513          	addi	a0,a0,-176 # ffffffe000203048 <_srodata+0x48>
ffffffe000201100:	409010ef          	jal	ra,ffffffe000202d08 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000201104:	f49ff06f          	j	ffffffe00020104c <dummy+0x28>

ffffffe000201108 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev,struct task_struct *next);

void switch_to(struct task_struct *next){
ffffffe000201108:	fd010113          	addi	sp,sp,-48
ffffffe00020110c:	02113423          	sd	ra,40(sp)
ffffffe000201110:	02813023          	sd	s0,32(sp)
ffffffe000201114:	03010413          	addi	s0,sp,48
ffffffe000201118:	fca43c23          	sd	a0,-40(s0)
    if(current==next){
ffffffe00020111c:	00008797          	auipc	a5,0x8
ffffffe000201120:	eec78793          	addi	a5,a5,-276 # ffffffe000209008 <current>
ffffffe000201124:	0007b783          	ld	a5,0(a5)
ffffffe000201128:	fd843703          	ld	a4,-40(s0)
ffffffe00020112c:	06f70063          	beq	a4,a5,ffffffe00020118c <switch_to+0x84>
        return;
    }
    struct task_struct *prev=current;
ffffffe000201130:	00008797          	auipc	a5,0x8
ffffffe000201134:	ed878793          	addi	a5,a5,-296 # ffffffe000209008 <current>
ffffffe000201138:	0007b783          	ld	a5,0(a5)
ffffffe00020113c:	fef43423          	sd	a5,-24(s0)
    current=next;
ffffffe000201140:	00008797          	auipc	a5,0x8
ffffffe000201144:	ec878793          	addi	a5,a5,-312 # ffffffe000209008 <current>
ffffffe000201148:	fd843703          	ld	a4,-40(s0)
ffffffe00020114c:	00e7b023          	sd	a4,0(a5)
    printk(RED "switch to [PID = %d PRIORITY =  %d COUNTER = %d]\n" CLEAR,next->pid,next->priority,next->counter);
ffffffe000201150:	fd843783          	ld	a5,-40(s0)
ffffffe000201154:	0187b703          	ld	a4,24(a5)
ffffffe000201158:	fd843783          	ld	a5,-40(s0)
ffffffe00020115c:	0107b603          	ld	a2,16(a5)
ffffffe000201160:	fd843783          	ld	a5,-40(s0)
ffffffe000201164:	0087b783          	ld	a5,8(a5)
ffffffe000201168:	00078693          	mv	a3,a5
ffffffe00020116c:	00070593          	mv	a1,a4
ffffffe000201170:	00002517          	auipc	a0,0x2
ffffffe000201174:	f0850513          	addi	a0,a0,-248 # ffffffe000203078 <_srodata+0x78>
ffffffe000201178:	391010ef          	jal	ra,ffffffe000202d08 <printk>
    __switch_to(prev,next);
ffffffe00020117c:	fd843583          	ld	a1,-40(s0)
ffffffe000201180:	fe843503          	ld	a0,-24(s0)
ffffffe000201184:	8acff0ef          	jal	ra,ffffffe000200230 <__switch_to>
ffffffe000201188:	0080006f          	j	ffffffe000201190 <switch_to+0x88>
        return;
ffffffe00020118c:	00000013          	nop
    
}
ffffffe000201190:	02813083          	ld	ra,40(sp)
ffffffe000201194:	02013403          	ld	s0,32(sp)
ffffffe000201198:	03010113          	addi	sp,sp,48
ffffffe00020119c:	00008067          	ret

ffffffe0002011a0 <do_timer>:

void do_timer(){
ffffffe0002011a0:	ff010113          	addi	sp,sp,-16
ffffffe0002011a4:	00113423          	sd	ra,8(sp)
ffffffe0002011a8:	00813023          	sd	s0,0(sp)
ffffffe0002011ac:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if(current==idle||current->counter==0){
ffffffe0002011b0:	00008797          	auipc	a5,0x8
ffffffe0002011b4:	e5878793          	addi	a5,a5,-424 # ffffffe000209008 <current>
ffffffe0002011b8:	0007b703          	ld	a4,0(a5)
ffffffe0002011bc:	00008797          	auipc	a5,0x8
ffffffe0002011c0:	e4478793          	addi	a5,a5,-444 # ffffffe000209000 <idle>
ffffffe0002011c4:	0007b783          	ld	a5,0(a5)
ffffffe0002011c8:	00f70c63          	beq	a4,a5,ffffffe0002011e0 <do_timer+0x40>
ffffffe0002011cc:	00008797          	auipc	a5,0x8
ffffffe0002011d0:	e3c78793          	addi	a5,a5,-452 # ffffffe000209008 <current>
ffffffe0002011d4:	0007b783          	ld	a5,0(a5)
ffffffe0002011d8:	0087b783          	ld	a5,8(a5)
ffffffe0002011dc:	00079663          	bnez	a5,ffffffe0002011e8 <do_timer+0x48>
        schedule();
ffffffe0002011e0:	04c000ef          	jal	ra,ffffffe00020122c <schedule>
        current->counter--;
        if(current->counter==0){
            schedule();
        }
    }
}
ffffffe0002011e4:	0340006f          	j	ffffffe000201218 <do_timer+0x78>
        current->counter--;
ffffffe0002011e8:	00008797          	auipc	a5,0x8
ffffffe0002011ec:	e2078793          	addi	a5,a5,-480 # ffffffe000209008 <current>
ffffffe0002011f0:	0007b783          	ld	a5,0(a5)
ffffffe0002011f4:	0087b703          	ld	a4,8(a5)
ffffffe0002011f8:	fff70713          	addi	a4,a4,-1
ffffffe0002011fc:	00e7b423          	sd	a4,8(a5)
        if(current->counter==0){
ffffffe000201200:	00008797          	auipc	a5,0x8
ffffffe000201204:	e0878793          	addi	a5,a5,-504 # ffffffe000209008 <current>
ffffffe000201208:	0007b783          	ld	a5,0(a5)
ffffffe00020120c:	0087b783          	ld	a5,8(a5)
ffffffe000201210:	00079463          	bnez	a5,ffffffe000201218 <do_timer+0x78>
            schedule();
ffffffe000201214:	018000ef          	jal	ra,ffffffe00020122c <schedule>
}
ffffffe000201218:	00000013          	nop
ffffffe00020121c:	00813083          	ld	ra,8(sp)
ffffffe000201220:	00013403          	ld	s0,0(sp)
ffffffe000201224:	01010113          	addi	sp,sp,16
ffffffe000201228:	00008067          	ret

ffffffe00020122c <schedule>:

void schedule(){
ffffffe00020122c:	fd010113          	addi	sp,sp,-48
ffffffe000201230:	02113423          	sd	ra,40(sp)
ffffffe000201234:	02813023          	sd	s0,32(sp)
ffffffe000201238:	03010413          	addi	s0,sp,48
    struct task_struct *next=NULL;
ffffffe00020123c:	fe043423          	sd	zero,-24(s0)
    uint64_t max_counter=0;
ffffffe000201240:	fe043023          	sd	zero,-32(s0)
    //找到 counter 最大的线程
    for(int i=0;i<NR_TASKS;i++){
ffffffe000201244:	fc042e23          	sw	zero,-36(s0)
ffffffe000201248:	0700006f          	j	ffffffe0002012b8 <schedule+0x8c>
        if(task[i]->counter>max_counter){
ffffffe00020124c:	00008717          	auipc	a4,0x8
ffffffe000201250:	dc470713          	addi	a4,a4,-572 # ffffffe000209010 <task>
ffffffe000201254:	fdc42783          	lw	a5,-36(s0)
ffffffe000201258:	00379793          	slli	a5,a5,0x3
ffffffe00020125c:	00f707b3          	add	a5,a4,a5
ffffffe000201260:	0007b783          	ld	a5,0(a5)
ffffffe000201264:	0087b783          	ld	a5,8(a5)
ffffffe000201268:	fe043703          	ld	a4,-32(s0)
ffffffe00020126c:	04f77063          	bgeu	a4,a5,ffffffe0002012ac <schedule+0x80>
            max_counter=task[i]->counter;
ffffffe000201270:	00008717          	auipc	a4,0x8
ffffffe000201274:	da070713          	addi	a4,a4,-608 # ffffffe000209010 <task>
ffffffe000201278:	fdc42783          	lw	a5,-36(s0)
ffffffe00020127c:	00379793          	slli	a5,a5,0x3
ffffffe000201280:	00f707b3          	add	a5,a4,a5
ffffffe000201284:	0007b783          	ld	a5,0(a5)
ffffffe000201288:	0087b783          	ld	a5,8(a5)
ffffffe00020128c:	fef43023          	sd	a5,-32(s0)
            next=task[i];
ffffffe000201290:	00008717          	auipc	a4,0x8
ffffffe000201294:	d8070713          	addi	a4,a4,-640 # ffffffe000209010 <task>
ffffffe000201298:	fdc42783          	lw	a5,-36(s0)
ffffffe00020129c:	00379793          	slli	a5,a5,0x3
ffffffe0002012a0:	00f707b3          	add	a5,a4,a5
ffffffe0002012a4:	0007b783          	ld	a5,0(a5)
ffffffe0002012a8:	fef43423          	sd	a5,-24(s0)
    for(int i=0;i<NR_TASKS;i++){
ffffffe0002012ac:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012b0:	0017879b          	addiw	a5,a5,1
ffffffe0002012b4:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002012b8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012bc:	0007871b          	sext.w	a4,a5
ffffffe0002012c0:	00400793          	li	a5,4
ffffffe0002012c4:	f8e7d4e3          	bge	a5,a4,ffffffe00020124c <schedule+0x20>
        }
    }
    //如果所有线程的 counter 都为 0，则重新为每个线程分配时间片，分配策略为将线程的 priority 赋值给 counter
    if(max_counter==0){
ffffffe0002012c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002012cc:	12079463          	bnez	a5,ffffffe0002013f4 <schedule+0x1c8>
        for(int i=1;i<NR_TASKS;i++){
ffffffe0002012d0:	00100793          	li	a5,1
ffffffe0002012d4:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002012d8:	10c0006f          	j	ffffffe0002013e4 <schedule+0x1b8>
            task[i]->counter=task[i]->priority;
ffffffe0002012dc:	00008717          	auipc	a4,0x8
ffffffe0002012e0:	d3470713          	addi	a4,a4,-716 # ffffffe000209010 <task>
ffffffe0002012e4:	fd842783          	lw	a5,-40(s0)
ffffffe0002012e8:	00379793          	slli	a5,a5,0x3
ffffffe0002012ec:	00f707b3          	add	a5,a4,a5
ffffffe0002012f0:	0007b703          	ld	a4,0(a5)
ffffffe0002012f4:	00008697          	auipc	a3,0x8
ffffffe0002012f8:	d1c68693          	addi	a3,a3,-740 # ffffffe000209010 <task>
ffffffe0002012fc:	fd842783          	lw	a5,-40(s0)
ffffffe000201300:	00379793          	slli	a5,a5,0x3
ffffffe000201304:	00f687b3          	add	a5,a3,a5
ffffffe000201308:	0007b783          	ld	a5,0(a5)
ffffffe00020130c:	01073703          	ld	a4,16(a4)
ffffffe000201310:	00e7b423          	sd	a4,8(a5)
             printk(BLUE "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[i]->pid,task[i]->priority,task[i]->counter);
ffffffe000201314:	00008717          	auipc	a4,0x8
ffffffe000201318:	cfc70713          	addi	a4,a4,-772 # ffffffe000209010 <task>
ffffffe00020131c:	fd842783          	lw	a5,-40(s0)
ffffffe000201320:	00379793          	slli	a5,a5,0x3
ffffffe000201324:	00f707b3          	add	a5,a4,a5
ffffffe000201328:	0007b783          	ld	a5,0(a5)
ffffffe00020132c:	0187b583          	ld	a1,24(a5)
ffffffe000201330:	00008717          	auipc	a4,0x8
ffffffe000201334:	ce070713          	addi	a4,a4,-800 # ffffffe000209010 <task>
ffffffe000201338:	fd842783          	lw	a5,-40(s0)
ffffffe00020133c:	00379793          	slli	a5,a5,0x3
ffffffe000201340:	00f707b3          	add	a5,a4,a5
ffffffe000201344:	0007b783          	ld	a5,0(a5)
ffffffe000201348:	0107b603          	ld	a2,16(a5)
ffffffe00020134c:	00008717          	auipc	a4,0x8
ffffffe000201350:	cc470713          	addi	a4,a4,-828 # ffffffe000209010 <task>
ffffffe000201354:	fd842783          	lw	a5,-40(s0)
ffffffe000201358:	00379793          	slli	a5,a5,0x3
ffffffe00020135c:	00f707b3          	add	a5,a4,a5
ffffffe000201360:	0007b783          	ld	a5,0(a5)
ffffffe000201364:	0087b783          	ld	a5,8(a5)
ffffffe000201368:	00078693          	mv	a3,a5
ffffffe00020136c:	00002517          	auipc	a0,0x2
ffffffe000201370:	d4c50513          	addi	a0,a0,-692 # ffffffe0002030b8 <_srodata+0xb8>
ffffffe000201374:	195010ef          	jal	ra,ffffffe000202d08 <printk>
            if(task[i]->counter>max_counter){
ffffffe000201378:	00008717          	auipc	a4,0x8
ffffffe00020137c:	c9870713          	addi	a4,a4,-872 # ffffffe000209010 <task>
ffffffe000201380:	fd842783          	lw	a5,-40(s0)
ffffffe000201384:	00379793          	slli	a5,a5,0x3
ffffffe000201388:	00f707b3          	add	a5,a4,a5
ffffffe00020138c:	0007b783          	ld	a5,0(a5)
ffffffe000201390:	0087b783          	ld	a5,8(a5)
ffffffe000201394:	fe043703          	ld	a4,-32(s0)
ffffffe000201398:	04f77063          	bgeu	a4,a5,ffffffe0002013d8 <schedule+0x1ac>
                max_counter=task[i]->counter;
ffffffe00020139c:	00008717          	auipc	a4,0x8
ffffffe0002013a0:	c7470713          	addi	a4,a4,-908 # ffffffe000209010 <task>
ffffffe0002013a4:	fd842783          	lw	a5,-40(s0)
ffffffe0002013a8:	00379793          	slli	a5,a5,0x3
ffffffe0002013ac:	00f707b3          	add	a5,a4,a5
ffffffe0002013b0:	0007b783          	ld	a5,0(a5)
ffffffe0002013b4:	0087b783          	ld	a5,8(a5)
ffffffe0002013b8:	fef43023          	sd	a5,-32(s0)
                next=task[i];
ffffffe0002013bc:	00008717          	auipc	a4,0x8
ffffffe0002013c0:	c5470713          	addi	a4,a4,-940 # ffffffe000209010 <task>
ffffffe0002013c4:	fd842783          	lw	a5,-40(s0)
ffffffe0002013c8:	00379793          	slli	a5,a5,0x3
ffffffe0002013cc:	00f707b3          	add	a5,a4,a5
ffffffe0002013d0:	0007b783          	ld	a5,0(a5)
ffffffe0002013d4:	fef43423          	sd	a5,-24(s0)
        for(int i=1;i<NR_TASKS;i++){
ffffffe0002013d8:	fd842783          	lw	a5,-40(s0)
ffffffe0002013dc:	0017879b          	addiw	a5,a5,1
ffffffe0002013e0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002013e4:	fd842783          	lw	a5,-40(s0)
ffffffe0002013e8:	0007871b          	sext.w	a4,a5
ffffffe0002013ec:	00400793          	li	a5,4
ffffffe0002013f0:	eee7d6e3          	bge	a5,a4,ffffffe0002012dc <schedule+0xb0>
                
            }
        }
    }

    if(next!=NULL) switch_to(next);
ffffffe0002013f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002013f8:	00078663          	beqz	a5,ffffffe000201404 <schedule+0x1d8>
ffffffe0002013fc:	fe843503          	ld	a0,-24(s0)
ffffffe000201400:	d09ff0ef          	jal	ra,ffffffe000201108 <switch_to>
}
ffffffe000201404:	00000013          	nop
ffffffe000201408:	02813083          	ld	ra,40(sp)
ffffffe00020140c:	02013403          	ld	s0,32(sp)
ffffffe000201410:	03010113          	addi	sp,sp,48
ffffffe000201414:	00008067          	ret

ffffffe000201418 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201418:	f8010113          	addi	sp,sp,-128
ffffffe00020141c:	06813c23          	sd	s0,120(sp)
ffffffe000201420:	06913823          	sd	s1,112(sp)
ffffffe000201424:	07213423          	sd	s2,104(sp)
ffffffe000201428:	07313023          	sd	s3,96(sp)
ffffffe00020142c:	08010413          	addi	s0,sp,128
ffffffe000201430:	faa43c23          	sd	a0,-72(s0)
ffffffe000201434:	fab43823          	sd	a1,-80(s0)
ffffffe000201438:	fac43423          	sd	a2,-88(s0)
ffffffe00020143c:	fad43023          	sd	a3,-96(s0)
ffffffe000201440:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201444:	f8f43823          	sd	a5,-112(s0)
ffffffe000201448:	f9043423          	sd	a6,-120(s0)
ffffffe00020144c:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
ffffffe000201450:	fb843e03          	ld	t3,-72(s0)
ffffffe000201454:	fb043e83          	ld	t4,-80(s0)
ffffffe000201458:	fa843f03          	ld	t5,-88(s0)
ffffffe00020145c:	fa043f83          	ld	t6,-96(s0)
ffffffe000201460:	f9843283          	ld	t0,-104(s0)
ffffffe000201464:	f9043483          	ld	s1,-112(s0)
ffffffe000201468:	f8843903          	ld	s2,-120(s0)
ffffffe00020146c:	f8043983          	ld	s3,-128(s0)
ffffffe000201470:	000e0893          	mv	a7,t3
ffffffe000201474:	000e8813          	mv	a6,t4
ffffffe000201478:	000f0513          	mv	a0,t5
ffffffe00020147c:	000f8593          	mv	a1,t6
ffffffe000201480:	00028613          	mv	a2,t0
ffffffe000201484:	00048693          	mv	a3,s1
ffffffe000201488:	00090713          	mv	a4,s2
ffffffe00020148c:	00098793          	mv	a5,s3
ffffffe000201490:	00000073          	ecall
ffffffe000201494:	00050e93          	mv	t4,a0
ffffffe000201498:	00058e13          	mv	t3,a1
ffffffe00020149c:	fdd43023          	sd	t4,-64(s0)
ffffffe0002014a0:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
ffffffe0002014a4:	fc043783          	ld	a5,-64(s0)
ffffffe0002014a8:	fcf43823          	sd	a5,-48(s0)
ffffffe0002014ac:	fc843783          	ld	a5,-56(s0)
ffffffe0002014b0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002014b4:	00000713          	li	a4,0
ffffffe0002014b8:	fd043703          	ld	a4,-48(s0)
ffffffe0002014bc:	00000793          	li	a5,0
ffffffe0002014c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002014c4:	00070313          	mv	t1,a4
ffffffe0002014c8:	00078393          	mv	t2,a5
ffffffe0002014cc:	00030713          	mv	a4,t1
ffffffe0002014d0:	00038793          	mv	a5,t2
}
ffffffe0002014d4:	00070513          	mv	a0,a4
ffffffe0002014d8:	00078593          	mv	a1,a5
ffffffe0002014dc:	07813403          	ld	s0,120(sp)
ffffffe0002014e0:	07013483          	ld	s1,112(sp)
ffffffe0002014e4:	06813903          	ld	s2,104(sp)
ffffffe0002014e8:	06013983          	ld	s3,96(sp)
ffffffe0002014ec:	08010113          	addi	sp,sp,128
ffffffe0002014f0:	00008067          	ret

ffffffe0002014f4 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe0002014f4:	fc010113          	addi	sp,sp,-64
ffffffe0002014f8:	02113c23          	sd	ra,56(sp)
ffffffe0002014fc:	02813823          	sd	s0,48(sp)
ffffffe000201500:	03213423          	sd	s2,40(sp)
ffffffe000201504:	03313023          	sd	s3,32(sp)
ffffffe000201508:	04010413          	addi	s0,sp,64
ffffffe00020150c:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
ffffffe000201510:	00000893          	li	a7,0
ffffffe000201514:	00000813          	li	a6,0
ffffffe000201518:	00000793          	li	a5,0
ffffffe00020151c:	00000713          	li	a4,0
ffffffe000201520:	00000693          	li	a3,0
ffffffe000201524:	fc843603          	ld	a2,-56(s0)
ffffffe000201528:	00000593          	li	a1,0
ffffffe00020152c:	54495537          	lui	a0,0x54495
ffffffe000201530:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201534:	ee5ff0ef          	jal	ra,ffffffe000201418 <sbi_ecall>
ffffffe000201538:	00050713          	mv	a4,a0
ffffffe00020153c:	00058793          	mv	a5,a1
ffffffe000201540:	fce43823          	sd	a4,-48(s0)
ffffffe000201544:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201548:	00000713          	li	a4,0
ffffffe00020154c:	fd043703          	ld	a4,-48(s0)
ffffffe000201550:	00000793          	li	a5,0
ffffffe000201554:	fd843783          	ld	a5,-40(s0)
ffffffe000201558:	00070913          	mv	s2,a4
ffffffe00020155c:	00078993          	mv	s3,a5
ffffffe000201560:	00090713          	mv	a4,s2
ffffffe000201564:	00098793          	mv	a5,s3
}
ffffffe000201568:	00070513          	mv	a0,a4
ffffffe00020156c:	00078593          	mv	a1,a5
ffffffe000201570:	03813083          	ld	ra,56(sp)
ffffffe000201574:	03013403          	ld	s0,48(sp)
ffffffe000201578:	02813903          	ld	s2,40(sp)
ffffffe00020157c:	02013983          	ld	s3,32(sp)
ffffffe000201580:	04010113          	addi	sp,sp,64
ffffffe000201584:	00008067          	ret

ffffffe000201588 <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201588:	fc010113          	addi	sp,sp,-64
ffffffe00020158c:	02113c23          	sd	ra,56(sp)
ffffffe000201590:	02813823          	sd	s0,48(sp)
ffffffe000201594:	03213423          	sd	s2,40(sp)
ffffffe000201598:	03313023          	sd	s3,32(sp)
ffffffe00020159c:	04010413          	addi	s0,sp,64
ffffffe0002015a0:	00050793          	mv	a5,a0
ffffffe0002015a4:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
ffffffe0002015a8:	fcf44603          	lbu	a2,-49(s0)
ffffffe0002015ac:	00000893          	li	a7,0
ffffffe0002015b0:	00000813          	li	a6,0
ffffffe0002015b4:	00000793          	li	a5,0
ffffffe0002015b8:	00000713          	li	a4,0
ffffffe0002015bc:	00000693          	li	a3,0
ffffffe0002015c0:	00200593          	li	a1,2
ffffffe0002015c4:	44424537          	lui	a0,0x44424
ffffffe0002015c8:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe0002015cc:	e4dff0ef          	jal	ra,ffffffe000201418 <sbi_ecall>
ffffffe0002015d0:	00050713          	mv	a4,a0
ffffffe0002015d4:	00058793          	mv	a5,a1
ffffffe0002015d8:	fce43823          	sd	a4,-48(s0)
ffffffe0002015dc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002015e0:	00000713          	li	a4,0
ffffffe0002015e4:	fd043703          	ld	a4,-48(s0)
ffffffe0002015e8:	00000793          	li	a5,0
ffffffe0002015ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002015f0:	00070913          	mv	s2,a4
ffffffe0002015f4:	00078993          	mv	s3,a5
ffffffe0002015f8:	00090713          	mv	a4,s2
ffffffe0002015fc:	00098793          	mv	a5,s3
}
ffffffe000201600:	00070513          	mv	a0,a4
ffffffe000201604:	00078593          	mv	a1,a5
ffffffe000201608:	03813083          	ld	ra,56(sp)
ffffffe00020160c:	03013403          	ld	s0,48(sp)
ffffffe000201610:	02813903          	ld	s2,40(sp)
ffffffe000201614:	02013983          	ld	s3,32(sp)
ffffffe000201618:	04010113          	addi	sp,sp,64
ffffffe00020161c:	00008067          	ret

ffffffe000201620 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201620:	fc010113          	addi	sp,sp,-64
ffffffe000201624:	02113c23          	sd	ra,56(sp)
ffffffe000201628:	02813823          	sd	s0,48(sp)
ffffffe00020162c:	03213423          	sd	s2,40(sp)
ffffffe000201630:	03313023          	sd	s3,32(sp)
ffffffe000201634:	04010413          	addi	s0,sp,64
ffffffe000201638:	00050793          	mv	a5,a0
ffffffe00020163c:	00058713          	mv	a4,a1
ffffffe000201640:	fcf42623          	sw	a5,-52(s0)
ffffffe000201644:	00070793          	mv	a5,a4
ffffffe000201648:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
ffffffe00020164c:	fcc46603          	lwu	a2,-52(s0)
ffffffe000201650:	fc846683          	lwu	a3,-56(s0)
ffffffe000201654:	00000893          	li	a7,0
ffffffe000201658:	00000813          	li	a6,0
ffffffe00020165c:	00000793          	li	a5,0
ffffffe000201660:	00000713          	li	a4,0
ffffffe000201664:	00000593          	li	a1,0
ffffffe000201668:	53525537          	lui	a0,0x53525
ffffffe00020166c:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000201670:	da9ff0ef          	jal	ra,ffffffe000201418 <sbi_ecall>
ffffffe000201674:	00050713          	mv	a4,a0
ffffffe000201678:	00058793          	mv	a5,a1
ffffffe00020167c:	fce43823          	sd	a4,-48(s0)
ffffffe000201680:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201684:	00000713          	li	a4,0
ffffffe000201688:	fd043703          	ld	a4,-48(s0)
ffffffe00020168c:	00000793          	li	a5,0
ffffffe000201690:	fd843783          	ld	a5,-40(s0)
ffffffe000201694:	00070913          	mv	s2,a4
ffffffe000201698:	00078993          	mv	s3,a5
ffffffe00020169c:	00090713          	mv	a4,s2
ffffffe0002016a0:	00098793          	mv	a5,s3
ffffffe0002016a4:	00070513          	mv	a0,a4
ffffffe0002016a8:	00078593          	mv	a1,a5
ffffffe0002016ac:	03813083          	ld	ra,56(sp)
ffffffe0002016b0:	03013403          	ld	s0,48(sp)
ffffffe0002016b4:	02813903          	ld	s2,40(sp)
ffffffe0002016b8:	02013983          	ld	s3,32(sp)
ffffffe0002016bc:	04010113          	addi	sp,sp,64
ffffffe0002016c0:	00008067          	ret

ffffffe0002016c4 <sys_write>:
#include "syscall.h"
#include "proc.h"
#include "printk.h"


uint64_t sys_write(unsigned int fd, const char* buf, size_t count){
ffffffe0002016c4:	fc010113          	addi	sp,sp,-64
ffffffe0002016c8:	02113c23          	sd	ra,56(sp)
ffffffe0002016cc:	02813823          	sd	s0,48(sp)
ffffffe0002016d0:	04010413          	addi	s0,sp,64
ffffffe0002016d4:	00050793          	mv	a5,a0
ffffffe0002016d8:	fcb43823          	sd	a1,-48(s0)
ffffffe0002016dc:	fcc43423          	sd	a2,-56(s0)
ffffffe0002016e0:	fcf42e23          	sw	a5,-36(s0)
    //标准输出
    if(fd==1){
ffffffe0002016e4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002016e8:	0007871b          	sext.w	a4,a5
ffffffe0002016ec:	00100793          	li	a5,1
ffffffe0002016f0:	04f71663          	bne	a4,a5,ffffffe00020173c <sys_write+0x78>
        for(uint64_t i=0;i<count;i++){
ffffffe0002016f4:	fe043423          	sd	zero,-24(s0)
ffffffe0002016f8:	0340006f          	j	ffffffe00020172c <sys_write+0x68>
            printk("%c",buf[i]);
ffffffe0002016fc:	fd043703          	ld	a4,-48(s0)
ffffffe000201700:	fe843783          	ld	a5,-24(s0)
ffffffe000201704:	00f707b3          	add	a5,a4,a5
ffffffe000201708:	0007c783          	lbu	a5,0(a5)
ffffffe00020170c:	0007879b          	sext.w	a5,a5
ffffffe000201710:	00078593          	mv	a1,a5
ffffffe000201714:	00002517          	auipc	a0,0x2
ffffffe000201718:	9dc50513          	addi	a0,a0,-1572 # ffffffe0002030f0 <_srodata+0xf0>
ffffffe00020171c:	5ec010ef          	jal	ra,ffffffe000202d08 <printk>
        for(uint64_t i=0;i<count;i++){
ffffffe000201720:	fe843783          	ld	a5,-24(s0)
ffffffe000201724:	00178793          	addi	a5,a5,1
ffffffe000201728:	fef43423          	sd	a5,-24(s0)
ffffffe00020172c:	fe843703          	ld	a4,-24(s0)
ffffffe000201730:	fc843783          	ld	a5,-56(s0)
ffffffe000201734:	fcf764e3          	bltu	a4,a5,ffffffe0002016fc <sys_write+0x38>
ffffffe000201738:	00c0006f          	j	ffffffe000201744 <sys_write+0x80>
        }
    }else{
        return -1; 
ffffffe00020173c:	fff00793          	li	a5,-1
ffffffe000201740:	0080006f          	j	ffffffe000201748 <sys_write+0x84>
    }
    return count;
ffffffe000201744:	fc843783          	ld	a5,-56(s0)
}
ffffffe000201748:	00078513          	mv	a0,a5
ffffffe00020174c:	03813083          	ld	ra,56(sp)
ffffffe000201750:	03013403          	ld	s0,48(sp)
ffffffe000201754:	04010113          	addi	sp,sp,64
ffffffe000201758:	00008067          	ret

ffffffe00020175c <sys_getpid>:
uint64_t sys_getpid(){
ffffffe00020175c:	ff010113          	addi	sp,sp,-16
ffffffe000201760:	00813423          	sd	s0,8(sp)
ffffffe000201764:	01010413          	addi	s0,sp,16
    return current->pid;
ffffffe000201768:	00008797          	auipc	a5,0x8
ffffffe00020176c:	8a078793          	addi	a5,a5,-1888 # ffffffe000209008 <current>
ffffffe000201770:	0007b783          	ld	a5,0(a5)
ffffffe000201774:	0187b783          	ld	a5,24(a5)
ffffffe000201778:	00078513          	mv	a0,a5
ffffffe00020177c:	00813403          	ld	s0,8(sp)
ffffffe000201780:	01010113          	addi	sp,sp,16
ffffffe000201784:	00008067          	ret

ffffffe000201788 <trap_handler>:
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "syscall.h"

void trap_handler(uint64_t scause, uint64_t sepc,struct pt_regs *regs) {
ffffffe000201788:	f9010113          	addi	sp,sp,-112
ffffffe00020178c:	06113423          	sd	ra,104(sp)
ffffffe000201790:	06813023          	sd	s0,96(sp)
ffffffe000201794:	07010413          	addi	s0,sp,112
ffffffe000201798:	faa43423          	sd	a0,-88(s0)
ffffffe00020179c:	fab43023          	sd	a1,-96(s0)
ffffffe0002017a0:	f8c43c23          	sd	a2,-104(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
ffffffe0002017a4:	fa843783          	ld	a5,-88(s0)
ffffffe0002017a8:	0407d263          	bgez	a5,ffffffe0002017ec <trap_handler+0x64>
        uint64_t interrupt_code = scause & ~(1UL << 63);
ffffffe0002017ac:	fa843703          	ld	a4,-88(s0)
ffffffe0002017b0:	fff00793          	li	a5,-1
ffffffe0002017b4:	0017d793          	srli	a5,a5,0x1
ffffffe0002017b8:	00f777b3          	and	a5,a4,a5
ffffffe0002017bc:	faf43c23          	sd	a5,-72(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
ffffffe0002017c0:	fb843703          	ld	a4,-72(s0)
ffffffe0002017c4:	00500793          	li	a5,5
ffffffe0002017c8:	00f71863          	bne	a4,a5,ffffffe0002017d8 <trap_handler+0x50>
            //printk("[S] Supervisor Mode TImer Interrupt\n");
            clock_set_next_event();
ffffffe0002017cc:	b85fe0ef          	jal	ra,ffffffe000200350 <clock_set_next_event>
            do_timer();
ffffffe0002017d0:	9d1ff0ef          	jal	ra,ffffffe0002011a0 <do_timer>
ffffffe0002017d4:	0f00006f          	j	ffffffe0002018c4 <trap_handler+0x13c>
        } else {
            printk("other interrupt: %d\n", interrupt_code);
ffffffe0002017d8:	fb843583          	ld	a1,-72(s0)
ffffffe0002017dc:	00002517          	auipc	a0,0x2
ffffffe0002017e0:	91c50513          	addi	a0,a0,-1764 # ffffffe0002030f8 <_srodata+0xf8>
ffffffe0002017e4:	524010ef          	jal	ra,ffffffe000202d08 <printk>
ffffffe0002017e8:	0dc0006f          	j	ffffffe0002018c4 <trap_handler+0x13c>
        }
    } else {
        uint64_t exception_code = scause;
ffffffe0002017ec:	fa843783          	ld	a5,-88(s0)
ffffffe0002017f0:	fef43023          	sd	a5,-32(s0)
        //用户态系统调用
        if(exception_code==8){
ffffffe0002017f4:	fe043703          	ld	a4,-32(s0)
ffffffe0002017f8:	00800793          	li	a5,8
ffffffe0002017fc:	0af71c63          	bne	a4,a5,ffffffe0002018b4 <trap_handler+0x12c>
            uint64_t a7=regs->x[17]; //系统调用号
ffffffe000201800:	f9843783          	ld	a5,-104(s0)
ffffffe000201804:	0887b783          	ld	a5,136(a5)
ffffffe000201808:	fcf43c23          	sd	a5,-40(s0)
            uint64_t a0=regs->x[10]; //参数1
ffffffe00020180c:	f9843783          	ld	a5,-104(s0)
ffffffe000201810:	0507b783          	ld	a5,80(a5)
ffffffe000201814:	fcf43823          	sd	a5,-48(s0)
            uint64_t a1=regs->x[11]; //参数2
ffffffe000201818:	f9843783          	ld	a5,-104(s0)
ffffffe00020181c:	0587b783          	ld	a5,88(a5)
ffffffe000201820:	fcf43423          	sd	a5,-56(s0)
            uint64_t a2=regs->x[12]; //参数3
ffffffe000201824:	f9843783          	ld	a5,-104(s0)
ffffffe000201828:	0607b783          	ld	a5,96(a5)
ffffffe00020182c:	fcf43023          	sd	a5,-64(s0)
            uint64_t ret=-1;
ffffffe000201830:	fff00793          	li	a5,-1
ffffffe000201834:	fef43423          	sd	a5,-24(s0)
            if(a7==SYS_write){
ffffffe000201838:	fd843703          	ld	a4,-40(s0)
ffffffe00020183c:	04000793          	li	a5,64
ffffffe000201840:	02f71463          	bne	a4,a5,ffffffe000201868 <trap_handler+0xe0>
                ret=sys_write((unsigned int)a0,(const char *)a1,(size_t)a2);
ffffffe000201844:	fd043783          	ld	a5,-48(s0)
ffffffe000201848:	0007879b          	sext.w	a5,a5
ffffffe00020184c:	fc843703          	ld	a4,-56(s0)
ffffffe000201850:	fc043603          	ld	a2,-64(s0)
ffffffe000201854:	00070593          	mv	a1,a4
ffffffe000201858:	00078513          	mv	a0,a5
ffffffe00020185c:	e69ff0ef          	jal	ra,ffffffe0002016c4 <sys_write>
ffffffe000201860:	fea43423          	sd	a0,-24(s0)
ffffffe000201864:	02c0006f          	j	ffffffe000201890 <trap_handler+0x108>
            }else if(a7==SYS_getpid){
ffffffe000201868:	fd843703          	ld	a4,-40(s0)
ffffffe00020186c:	0ac00793          	li	a5,172
ffffffe000201870:	00f71863          	bne	a4,a5,ffffffe000201880 <trap_handler+0xf8>
                ret=sys_getpid();
ffffffe000201874:	ee9ff0ef          	jal	ra,ffffffe00020175c <sys_getpid>
ffffffe000201878:	fea43423          	sd	a0,-24(s0)
ffffffe00020187c:	0140006f          	j	ffffffe000201890 <trap_handler+0x108>
            }else{
                printk("unknown syscall %d\n",a7);
ffffffe000201880:	fd843583          	ld	a1,-40(s0)
ffffffe000201884:	00002517          	auipc	a0,0x2
ffffffe000201888:	88c50513          	addi	a0,a0,-1908 # ffffffe000203110 <_srodata+0x110>
ffffffe00020188c:	47c010ef          	jal	ra,ffffffe000202d08 <printk>
            }
            regs->x[10]=ret; //将返回值写入 a0
ffffffe000201890:	f9843783          	ld	a5,-104(s0)
ffffffe000201894:	fe843703          	ld	a4,-24(s0)
ffffffe000201898:	04e7b823          	sd	a4,80(a5)
            regs->sepc+=4; //指令地址后移
ffffffe00020189c:	f9843783          	ld	a5,-104(s0)
ffffffe0002018a0:	1007b783          	ld	a5,256(a5)
ffffffe0002018a4:	00478713          	addi	a4,a5,4
ffffffe0002018a8:	f9843783          	ld	a5,-104(s0)
ffffffe0002018ac:	10e7b023          	sd	a4,256(a5)
            return;
ffffffe0002018b0:	0140006f          	j	ffffffe0002018c4 <trap_handler+0x13c>
        }

        printk("exception: %d\n", exception_code);
ffffffe0002018b4:	fe043583          	ld	a1,-32(s0)
ffffffe0002018b8:	00002517          	auipc	a0,0x2
ffffffe0002018bc:	87050513          	addi	a0,a0,-1936 # ffffffe000203128 <_srodata+0x128>
ffffffe0002018c0:	448010ef          	jal	ra,ffffffe000202d08 <printk>
    }   
ffffffe0002018c4:	06813083          	ld	ra,104(sp)
ffffffe0002018c8:	06013403          	ld	s0,96(sp)
ffffffe0002018cc:	07010113          	addi	sp,sp,112
ffffffe0002018d0:	00008067          	ret

ffffffe0002018d4 <setup_vm>:
extern char _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe0002018d4:	fc010113          	addi	sp,sp,-64
ffffffe0002018d8:	02813c23          	sd	s0,56(sp)
ffffffe0002018dc:	04010413          	addi	s0,sp,64
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   uint64_t pa=0x80000000;
ffffffe0002018e0:	00100793          	li	a5,1
ffffffe0002018e4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002018e8:	fef43423          	sd	a5,-24(s0)
   uint64_t va_eq=pa;
ffffffe0002018ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002018f0:	fef43023          	sd	a5,-32(s0)
   uint64_t va_direct=pa+PA2VA_OFFSET;
ffffffe0002018f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002018f8:	fbf00793          	li	a5,-65
ffffffe0002018fc:	01f79793          	slli	a5,a5,0x1f
ffffffe000201900:	00f707b3          	add	a5,a4,a5
ffffffe000201904:	fcf43c23          	sd	a5,-40(s0)

   uint64_t perm = PTE_V|PTE_R|PTE_W|PTE_X; // V | R | W | X
ffffffe000201908:	00f00793          	li	a5,15
ffffffe00020190c:	fcf43823          	sd	a5,-48(s0)
    //中间 9 bit 作为 early_pgtbl 的 index
   uint64_t idx_eq=(va_eq>>30)&0x1ff; 
ffffffe000201910:	fe043783          	ld	a5,-32(s0)
ffffffe000201914:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201918:	1ff7f793          	andi	a5,a5,511
ffffffe00020191c:	fcf43423          	sd	a5,-56(s0)
   uint64_t idx_direct=(va_direct>>30)&0x1ff;
ffffffe000201920:	fd843783          	ld	a5,-40(s0)
ffffffe000201924:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201928:	1ff7f793          	andi	a5,a5,511
ffffffe00020192c:	fcf43023          	sd	a5,-64(s0)

    early_pgtbl[idx_eq]= (pa>>12)<<10 | perm;       //等值映射
ffffffe000201930:	fe843783          	ld	a5,-24(s0)
ffffffe000201934:	00c7d793          	srli	a5,a5,0xc
ffffffe000201938:	00a79713          	slli	a4,a5,0xa
ffffffe00020193c:	fd043783          	ld	a5,-48(s0)
ffffffe000201940:	00f76733          	or	a4,a4,a5
ffffffe000201944:	00008697          	auipc	a3,0x8
ffffffe000201948:	6bc68693          	addi	a3,a3,1724 # ffffffe00020a000 <early_pgtbl>
ffffffe00020194c:	fc843783          	ld	a5,-56(s0)
ffffffe000201950:	00379793          	slli	a5,a5,0x3
ffffffe000201954:	00f687b3          	add	a5,a3,a5
ffffffe000201958:	00e7b023          	sd	a4,0(a5)
    early_pgtbl[idx_direct]= (pa>>12)<<10 | perm;   //直接映射
ffffffe00020195c:	fe843783          	ld	a5,-24(s0)
ffffffe000201960:	00c7d793          	srli	a5,a5,0xc
ffffffe000201964:	00a79713          	slli	a4,a5,0xa
ffffffe000201968:	fd043783          	ld	a5,-48(s0)
ffffffe00020196c:	00f76733          	or	a4,a4,a5
ffffffe000201970:	00008697          	auipc	a3,0x8
ffffffe000201974:	69068693          	addi	a3,a3,1680 # ffffffe00020a000 <early_pgtbl>
ffffffe000201978:	fc043783          	ld	a5,-64(s0)
ffffffe00020197c:	00379793          	slli	a5,a5,0x3
ffffffe000201980:	00f687b3          	add	a5,a3,a5
ffffffe000201984:	00e7b023          	sd	a4,0(a5)
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //       pa, va_eq, idx_eq);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //        pa, va_direct, idx_direct);

}
ffffffe000201988:	00000013          	nop
ffffffe00020198c:	03813403          	ld	s0,56(sp)
ffffffe000201990:	04010113          	addi	sp,sp,64
ffffffe000201994:	00008067          	ret

ffffffe000201998 <setup_vm_neq>:

void setup_vm_neq(){
ffffffe000201998:	ff010113          	addi	sp,sp,-16
ffffffe00020199c:	00813423          	sd	s0,8(sp)
ffffffe0002019a0:	01010413          	addi	s0,sp,16

}
ffffffe0002019a4:	00000013          	nop
ffffffe0002019a8:	00813403          	ld	s0,8(sp)
ffffffe0002019ac:	01010113          	addi	sp,sp,16
ffffffe0002019b0:	00008067          	ret

ffffffe0002019b4 <create_mapping>:

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe0002019b4:	f5010113          	addi	sp,sp,-176
ffffffe0002019b8:	0a113423          	sd	ra,168(sp)
ffffffe0002019bc:	0a813023          	sd	s0,160(sp)
ffffffe0002019c0:	0b010413          	addi	s0,sp,176
ffffffe0002019c4:	f6a43c23          	sd	a0,-136(s0)
ffffffe0002019c8:	f6b43823          	sd	a1,-144(s0)
ffffffe0002019cc:	f6c43423          	sd	a2,-152(s0)
ffffffe0002019d0:	f6d43023          	sd	a3,-160(s0)
ffffffe0002019d4:	f4e43c23          	sd	a4,-168(s0)
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_curr=va;
ffffffe0002019d8:	f7043783          	ld	a5,-144(s0)
ffffffe0002019dc:	fef43423          	sd	a5,-24(s0)
    uint64_t pa_curr=pa;
ffffffe0002019e0:	f6843783          	ld	a5,-152(s0)
ffffffe0002019e4:	fef43023          	sd	a5,-32(s0)
    uint64_t va_end=va+sz;
ffffffe0002019e8:	f7043703          	ld	a4,-144(s0)
ffffffe0002019ec:	f6043783          	ld	a5,-160(s0)
ffffffe0002019f0:	00f707b3          	add	a5,a4,a5
ffffffe0002019f4:	fcf43c23          	sd	a5,-40(s0)

    while(va_curr<va_end){
ffffffe0002019f8:	1bc0006f          	j	ffffffe000201bb4 <create_mapping+0x200>
        uint64_t vpn2=(va_curr>>30)&0x1ff;  //VA[39:30]
ffffffe0002019fc:	fe843783          	ld	a5,-24(s0)
ffffffe000201a00:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201a04:	1ff7f793          	andi	a5,a5,511
ffffffe000201a08:	fcf43823          	sd	a5,-48(s0)
        uint64_t vpn1=(va_curr>>21)&0x1ff;  //VA[29:21]
ffffffe000201a0c:	fe843783          	ld	a5,-24(s0)
ffffffe000201a10:	0157d793          	srli	a5,a5,0x15
ffffffe000201a14:	1ff7f793          	andi	a5,a5,511
ffffffe000201a18:	fcf43423          	sd	a5,-56(s0)
        uint64_t vpn0=(va_curr>>12)&0x1ff;  //VA[20:12]
ffffffe000201a1c:	fe843783          	ld	a5,-24(s0)
ffffffe000201a20:	00c7d793          	srli	a5,a5,0xc
ffffffe000201a24:	1ff7f793          	andi	a5,a5,511
ffffffe000201a28:	fcf43023          	sd	a5,-64(s0)

        
        if(!(pgtbl[vpn2]&PTE_V)){
ffffffe000201a2c:	fd043783          	ld	a5,-48(s0)
ffffffe000201a30:	00379793          	slli	a5,a5,0x3
ffffffe000201a34:	f7843703          	ld	a4,-136(s0)
ffffffe000201a38:	00f707b3          	add	a5,a4,a5
ffffffe000201a3c:	0007b783          	ld	a5,0(a5)
ffffffe000201a40:	0017f793          	andi	a5,a5,1
ffffffe000201a44:	04079a63          	bnez	a5,ffffffe000201a98 <create_mapping+0xe4>
            //分配新的二级页表
            uint64_t *patbl2=(uint64_t *)kalloc();
ffffffe000201a48:	fe1fe0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000201a4c:	faa43c23          	sd	a0,-72(s0)
            memset(patbl2,0,PGSIZE);
ffffffe000201a50:	00001637          	lui	a2,0x1
ffffffe000201a54:	00000593          	li	a1,0
ffffffe000201a58:	fb843503          	ld	a0,-72(s0)
ffffffe000201a5c:	3cc010ef          	jal	ra,ffffffe000202e28 <memset>
            //转化物理地址
            uint64_t patbl2_pa=(uint64_t)patbl2-PA2VA_OFFSET;
ffffffe000201a60:	fb843703          	ld	a4,-72(s0)
ffffffe000201a64:	04100793          	li	a5,65
ffffffe000201a68:	01f79793          	slli	a5,a5,0x1f
ffffffe000201a6c:	00f707b3          	add	a5,a4,a5
ffffffe000201a70:	faf43823          	sd	a5,-80(s0)
            pgtbl[vpn2]=((uint64_t)patbl2_pa>>12)<<10|PTE_V;
ffffffe000201a74:	fb043783          	ld	a5,-80(s0)
ffffffe000201a78:	00c7d793          	srli	a5,a5,0xc
ffffffe000201a7c:	00a79713          	slli	a4,a5,0xa
ffffffe000201a80:	fd043783          	ld	a5,-48(s0)
ffffffe000201a84:	00379793          	slli	a5,a5,0x3
ffffffe000201a88:	f7843683          	ld	a3,-136(s0)
ffffffe000201a8c:	00f687b3          	add	a5,a3,a5
ffffffe000201a90:	00176713          	ori	a4,a4,1
ffffffe000201a94:	00e7b023          	sd	a4,0(a5)
        }
        //二级页表物理地址
        uint64_t patbl2_pa=(uint64_t *)((pgtbl[vpn2]>>10)<<12); 
ffffffe000201a98:	fd043783          	ld	a5,-48(s0)
ffffffe000201a9c:	00379793          	slli	a5,a5,0x3
ffffffe000201aa0:	f7843703          	ld	a4,-136(s0)
ffffffe000201aa4:	00f707b3          	add	a5,a4,a5
ffffffe000201aa8:	0007b783          	ld	a5,0(a5)
ffffffe000201aac:	00a7d793          	srli	a5,a5,0xa
ffffffe000201ab0:	00c79793          	slli	a5,a5,0xc
ffffffe000201ab4:	faf43423          	sd	a5,-88(s0)
        uint64_t *patbl2=(uint64_t *)(patbl2_pa+PA2VA_OFFSET);              
ffffffe000201ab8:	fa843703          	ld	a4,-88(s0)
ffffffe000201abc:	fbf00793          	li	a5,-65
ffffffe000201ac0:	01f79793          	slli	a5,a5,0x1f
ffffffe000201ac4:	00f707b3          	add	a5,a4,a5
ffffffe000201ac8:	faf43023          	sd	a5,-96(s0)

        if(!(patbl2[vpn1]&PTE_V)){
ffffffe000201acc:	fc843783          	ld	a5,-56(s0)
ffffffe000201ad0:	00379793          	slli	a5,a5,0x3
ffffffe000201ad4:	fa043703          	ld	a4,-96(s0)
ffffffe000201ad8:	00f707b3          	add	a5,a4,a5
ffffffe000201adc:	0007b783          	ld	a5,0(a5)
ffffffe000201ae0:	0017f793          	andi	a5,a5,1
ffffffe000201ae4:	04079a63          	bnez	a5,ffffffe000201b38 <create_mapping+0x184>
            uint64_t *patbl1=(uint64_t *)kalloc();
ffffffe000201ae8:	f41fe0ef          	jal	ra,ffffffe000200a28 <kalloc>
ffffffe000201aec:	f8a43c23          	sd	a0,-104(s0)
            memset(patbl1,0,PGSIZE);
ffffffe000201af0:	00001637          	lui	a2,0x1
ffffffe000201af4:	00000593          	li	a1,0
ffffffe000201af8:	f9843503          	ld	a0,-104(s0)
ffffffe000201afc:	32c010ef          	jal	ra,ffffffe000202e28 <memset>
            uint64_t patbl1_pa=(uint64_t)patbl1-PA2VA_OFFSET;
ffffffe000201b00:	f9843703          	ld	a4,-104(s0)
ffffffe000201b04:	04100793          	li	a5,65
ffffffe000201b08:	01f79793          	slli	a5,a5,0x1f
ffffffe000201b0c:	00f707b3          	add	a5,a4,a5
ffffffe000201b10:	f8f43823          	sd	a5,-112(s0)
            patbl2[vpn1]=((uint64_t)patbl1_pa>>12)<<10|PTE_V;
ffffffe000201b14:	f9043783          	ld	a5,-112(s0)
ffffffe000201b18:	00c7d793          	srli	a5,a5,0xc
ffffffe000201b1c:	00a79713          	slli	a4,a5,0xa
ffffffe000201b20:	fc843783          	ld	a5,-56(s0)
ffffffe000201b24:	00379793          	slli	a5,a5,0x3
ffffffe000201b28:	fa043683          	ld	a3,-96(s0)
ffffffe000201b2c:	00f687b3          	add	a5,a3,a5
ffffffe000201b30:	00176713          	ori	a4,a4,1
ffffffe000201b34:	00e7b023          	sd	a4,0(a5)
        }
        //三级页表物理地址
        uint64_t patbl1_pa=(uint64_t *)((patbl2[vpn1]>>10)<<12); 
ffffffe000201b38:	fc843783          	ld	a5,-56(s0)
ffffffe000201b3c:	00379793          	slli	a5,a5,0x3
ffffffe000201b40:	fa043703          	ld	a4,-96(s0)
ffffffe000201b44:	00f707b3          	add	a5,a4,a5
ffffffe000201b48:	0007b783          	ld	a5,0(a5)
ffffffe000201b4c:	00a7d793          	srli	a5,a5,0xa
ffffffe000201b50:	00c79793          	slli	a5,a5,0xc
ffffffe000201b54:	f8f43423          	sd	a5,-120(s0)
        uint64_t *patbl1=(uint64_t *)(patbl1_pa+PA2VA_OFFSET);
ffffffe000201b58:	f8843703          	ld	a4,-120(s0)
ffffffe000201b5c:	fbf00793          	li	a5,-65
ffffffe000201b60:	01f79793          	slli	a5,a5,0x1f
ffffffe000201b64:	00f707b3          	add	a5,a4,a5
ffffffe000201b68:	f8f43023          	sd	a5,-128(s0)
        //最终页表项
        patbl1[vpn0]=(pa_curr>>12)<<10|perm;
ffffffe000201b6c:	fe043783          	ld	a5,-32(s0)
ffffffe000201b70:	00c7d793          	srli	a5,a5,0xc
ffffffe000201b74:	00a79693          	slli	a3,a5,0xa
ffffffe000201b78:	fc043783          	ld	a5,-64(s0)
ffffffe000201b7c:	00379793          	slli	a5,a5,0x3
ffffffe000201b80:	f8043703          	ld	a4,-128(s0)
ffffffe000201b84:	00f707b3          	add	a5,a4,a5
ffffffe000201b88:	f5843703          	ld	a4,-168(s0)
ffffffe000201b8c:	00e6e733          	or	a4,a3,a4
ffffffe000201b90:	00e7b023          	sd	a4,0(a5)

        va_curr+=PGSIZE;
ffffffe000201b94:	fe843703          	ld	a4,-24(s0)
ffffffe000201b98:	000017b7          	lui	a5,0x1
ffffffe000201b9c:	00f707b3          	add	a5,a4,a5
ffffffe000201ba0:	fef43423          	sd	a5,-24(s0)
        pa_curr+=PGSIZE;
ffffffe000201ba4:	fe043703          	ld	a4,-32(s0)
ffffffe000201ba8:	000017b7          	lui	a5,0x1
ffffffe000201bac:	00f707b3          	add	a5,a4,a5
ffffffe000201bb0:	fef43023          	sd	a5,-32(s0)
    while(va_curr<va_end){
ffffffe000201bb4:	fe843703          	ld	a4,-24(s0)
ffffffe000201bb8:	fd843783          	ld	a5,-40(s0)
ffffffe000201bbc:	e4f760e3          	bltu	a4,a5,ffffffe0002019fc <create_mapping+0x48>
    }
}
ffffffe000201bc0:	00000013          	nop
ffffffe000201bc4:	00000013          	nop
ffffffe000201bc8:	0a813083          	ld	ra,168(sp)
ffffffe000201bcc:	0a013403          	ld	s0,160(sp)
ffffffe000201bd0:	0b010113          	addi	sp,sp,176
ffffffe000201bd4:	00008067          	ret

ffffffe000201bd8 <setup_vm_final>:

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
ffffffe000201bd8:	fe010113          	addi	sp,sp,-32
ffffffe000201bdc:	00113c23          	sd	ra,24(sp)
ffffffe000201be0:	00813823          	sd	s0,16(sp)
ffffffe000201be4:	02010413          	addi	s0,sp,32
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000201be8:	00001637          	lui	a2,0x1
ffffffe000201bec:	00000593          	li	a1,0
ffffffe000201bf0:	00006517          	auipc	a0,0x6
ffffffe000201bf4:	41050513          	addi	a0,a0,1040 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201bf8:	230010ef          	jal	ra,ffffffe000202e28 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201bfc:	ffffe597          	auipc	a1,0xffffe
ffffffe000201c00:	40458593          	addi	a1,a1,1028 # ffffffe000200000 <_skernel>
ffffffe000201c04:	ffffe717          	auipc	a4,0xffffe
ffffffe000201c08:	3fc70713          	addi	a4,a4,1020 # ffffffe000200000 <_skernel>
ffffffe000201c0c:	04100793          	li	a5,65
ffffffe000201c10:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c14:	00f707b3          	add	a5,a4,a5
ffffffe000201c18:	00078613          	mv	a2,a5
                   (uint64_t)(_etext - _stext),PTE_X|PTE_R|PTE_V);
ffffffe000201c1c:	00001717          	auipc	a4,0x1
ffffffe000201c20:	27c70713          	addi	a4,a4,636 # ffffffe000202e98 <_etext>
ffffffe000201c24:	ffffe797          	auipc	a5,0xffffe
ffffffe000201c28:	3dc78793          	addi	a5,a5,988 # ffffffe000200000 <_skernel>
ffffffe000201c2c:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
ffffffe000201c30:	00b00713          	li	a4,11
ffffffe000201c34:	00078693          	mv	a3,a5
ffffffe000201c38:	00006517          	auipc	a0,0x6
ffffffe000201c3c:	3c850513          	addi	a0,a0,968 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201c40:	d75ff0ef          	jal	ra,ffffffe0002019b4 <create_mapping>
    printk("setup_vm_final: mapping kernel text done!\n");
ffffffe000201c44:	00001517          	auipc	a0,0x1
ffffffe000201c48:	4f450513          	addi	a0,a0,1268 # ffffffe000203138 <_srodata+0x138>
ffffffe000201c4c:	0bc010ef          	jal	ra,ffffffe000202d08 <printk>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201c50:	00001597          	auipc	a1,0x1
ffffffe000201c54:	3b058593          	addi	a1,a1,944 # ffffffe000203000 <_srodata>
ffffffe000201c58:	00001717          	auipc	a4,0x1
ffffffe000201c5c:	3a870713          	addi	a4,a4,936 # ffffffe000203000 <_srodata>
ffffffe000201c60:	04100793          	li	a5,65
ffffffe000201c64:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c68:	00f707b3          	add	a5,a4,a5
ffffffe000201c6c:	00078613          	mv	a2,a5
                   (uint64_t)(_erodata - _srodata),PTE_R|PTE_V);
ffffffe000201c70:	00001717          	auipc	a4,0x1
ffffffe000201c74:	62870713          	addi	a4,a4,1576 # ffffffe000203298 <_erodata>
ffffffe000201c78:	00001797          	auipc	a5,0x1
ffffffe000201c7c:	38878793          	addi	a5,a5,904 # ffffffe000203000 <_srodata>
ffffffe000201c80:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
ffffffe000201c84:	00300713          	li	a4,3
ffffffe000201c88:	00078693          	mv	a3,a5
ffffffe000201c8c:	00006517          	auipc	a0,0x6
ffffffe000201c90:	37450513          	addi	a0,a0,884 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201c94:	d21ff0ef          	jal	ra,ffffffe0002019b4 <create_mapping>
    printk("setup_vm_final: mapping kernel rodata done!\n");
ffffffe000201c98:	00001517          	auipc	a0,0x1
ffffffe000201c9c:	4d050513          	addi	a0,a0,1232 # ffffffe000203168 <_srodata+0x168>
ffffffe000201ca0:	068010ef          	jal	ra,ffffffe000202d08 <printk>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201ca4:	00002597          	auipc	a1,0x2
ffffffe000201ca8:	35c58593          	addi	a1,a1,860 # ffffffe000204000 <TIMECLOCK>
ffffffe000201cac:	00002717          	auipc	a4,0x2
ffffffe000201cb0:	35470713          	addi	a4,a4,852 # ffffffe000204000 <TIMECLOCK>
ffffffe000201cb4:	04100793          	li	a5,65
ffffffe000201cb8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201cbc:	00f707b3          	add	a5,a4,a5
ffffffe000201cc0:	00078613          	mv	a2,a5
                   (uint64_t)(PHY_END-((uint64_t)_sdata-PA2VA_OFFSET)),PTE_W|PTE_R|PTE_V);
ffffffe000201cc4:	00002797          	auipc	a5,0x2
ffffffe000201cc8:	33c78793          	addi	a5,a5,828 # ffffffe000204000 <TIMECLOCK>
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
ffffffe000201ccc:	c0100713          	li	a4,-1023
ffffffe000201cd0:	01b71713          	slli	a4,a4,0x1b
ffffffe000201cd4:	40f707b3          	sub	a5,a4,a5
ffffffe000201cd8:	00700713          	li	a4,7
ffffffe000201cdc:	00078693          	mv	a3,a5
ffffffe000201ce0:	00006517          	auipc	a0,0x6
ffffffe000201ce4:	32050513          	addi	a0,a0,800 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201ce8:	ccdff0ef          	jal	ra,ffffffe0002019b4 <create_mapping>
    printk("setup_vm_final: mapping other memory done!\n");
ffffffe000201cec:	00001517          	auipc	a0,0x1
ffffffe000201cf0:	4ac50513          	addi	a0,a0,1196 # ffffffe000203198 <_srodata+0x198>
ffffffe000201cf4:	014010ef          	jal	ra,ffffffe000202d08 <printk>

    // set satp with swapper_pg_dir
    uint64_t satp_val=0;
ffffffe000201cf8:	fe043423          	sd	zero,-24(s0)
    satp_val|=(8ULL<<60);                          // MODE=8 Sv39
ffffffe000201cfc:	fe843703          	ld	a4,-24(s0)
ffffffe000201d00:	fff00793          	li	a5,-1
ffffffe000201d04:	03f79793          	slli	a5,a5,0x3f
ffffffe000201d08:	00f767b3          	or	a5,a4,a5
ffffffe000201d0c:	fef43423          	sd	a5,-24(s0)
    satp_val|=(((uint64_t)swapper_pg_dir-PA2VA_OFFSET)>>12);   // PPN
ffffffe000201d10:	00006717          	auipc	a4,0x6
ffffffe000201d14:	2f070713          	addi	a4,a4,752 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201d18:	04100793          	li	a5,65
ffffffe000201d1c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201d20:	00f707b3          	add	a5,a4,a5
ffffffe000201d24:	00c7d793          	srli	a5,a5,0xc
ffffffe000201d28:	fe843703          	ld	a4,-24(s0)
ffffffe000201d2c:	00f767b3          	or	a5,a4,a5
ffffffe000201d30:	fef43423          	sd	a5,-24(s0)
    csr_write(satp,satp_val);
ffffffe000201d34:	fe843783          	ld	a5,-24(s0)
ffffffe000201d38:	fef43023          	sd	a5,-32(s0)
ffffffe000201d3c:	fe043783          	ld	a5,-32(s0)
ffffffe000201d40:	18079073          	csrw	satp,a5

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201d44:	12000073          	sfence.vma
    return;
ffffffe000201d48:	00000013          	nop
}
ffffffe000201d4c:	01813083          	ld	ra,24(sp)
ffffffe000201d50:	01013403          	ld	s0,16(sp)
ffffffe000201d54:	02010113          	addi	sp,sp,32
ffffffe000201d58:	00008067          	ret

ffffffe000201d5c <test_rw>:
extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];

void test_rw(){
ffffffe000201d5c:	ff010113          	addi	sp,sp,-16
ffffffe000201d60:	00113423          	sd	ra,8(sp)
ffffffe000201d64:	00813023          	sd	s0,0(sp)
ffffffe000201d68:	01010413          	addi	s0,sp,16
    printk("stext read:%lx\n",&_stext);
ffffffe000201d6c:	ffffe597          	auipc	a1,0xffffe
ffffffe000201d70:	29458593          	addi	a1,a1,660 # ffffffe000200000 <_skernel>
ffffffe000201d74:	00001517          	auipc	a0,0x1
ffffffe000201d78:	45450513          	addi	a0,a0,1108 # ffffffe0002031c8 <_srodata+0x1c8>
ffffffe000201d7c:	78d000ef          	jal	ra,ffffffe000202d08 <printk>
    printk("srodata read:%lx\n",&_srodata);
ffffffe000201d80:	00001597          	auipc	a1,0x1
ffffffe000201d84:	28058593          	addi	a1,a1,640 # ffffffe000203000 <_srodata>
ffffffe000201d88:	00001517          	auipc	a0,0x1
ffffffe000201d8c:	45050513          	addi	a0,a0,1104 # ffffffe0002031d8 <_srodata+0x1d8>
ffffffe000201d90:	779000ef          	jal	ra,ffffffe000202d08 <printk>
    // }
    // *_srodata=0x1;
    // if(*_srodata==0x1){
    //     printk("srodata write: success\n");
    // }
}
ffffffe000201d94:	00000013          	nop
ffffffe000201d98:	00813083          	ld	ra,8(sp)
ffffffe000201d9c:	00013403          	ld	s0,0(sp)
ffffffe000201da0:	01010113          	addi	sp,sp,16
ffffffe000201da4:	00008067          	ret

ffffffe000201da8 <test_exe>:

void test_exe(){
ffffffe000201da8:	fe010113          	addi	sp,sp,-32
ffffffe000201dac:	00113c23          	sd	ra,24(sp)
ffffffe000201db0:	00813823          	sd	s0,16(sp)
ffffffe000201db4:	02010413          	addi	s0,sp,32
    typedef void (*func_ptr)(void);

    func_ptr func = (func_ptr)_srodata;
ffffffe000201db8:	00001797          	auipc	a5,0x1
ffffffe000201dbc:	24878793          	addi	a5,a5,584 # ffffffe000203000 <_srodata>
ffffffe000201dc0:	fef43423          	sd	a5,-24(s0)
    func();
ffffffe000201dc4:	fe843783          	ld	a5,-24(s0)
ffffffe000201dc8:	000780e7          	jalr	a5
    printk("execute stext success\n");
ffffffe000201dcc:	00001517          	auipc	a0,0x1
ffffffe000201dd0:	42450513          	addi	a0,a0,1060 # ffffffe0002031f0 <_srodata+0x1f0>
ffffffe000201dd4:	735000ef          	jal	ra,ffffffe000202d08 <printk>

}
ffffffe000201dd8:	00000013          	nop
ffffffe000201ddc:	01813083          	ld	ra,24(sp)
ffffffe000201de0:	01013403          	ld	s0,16(sp)
ffffffe000201de4:	02010113          	addi	sp,sp,32
ffffffe000201de8:	00008067          	ret

ffffffe000201dec <start_kernel>:

int start_kernel() {
ffffffe000201dec:	ff010113          	addi	sp,sp,-16
ffffffe000201df0:	00113423          	sd	ra,8(sp)
ffffffe000201df4:	00813023          	sd	s0,0(sp)
ffffffe000201df8:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201dfc:	00001517          	auipc	a0,0x1
ffffffe000201e00:	40c50513          	addi	a0,a0,1036 # ffffffe000203208 <_srodata+0x208>
ffffffe000201e04:	705000ef          	jal	ra,ffffffe000202d08 <printk>
    printk(" ZJU Operating System\n");
ffffffe000201e08:	00001517          	auipc	a0,0x1
ffffffe000201e0c:	40850513          	addi	a0,a0,1032 # ffffffe000203210 <_srodata+0x210>
ffffffe000201e10:	6f9000ef          	jal	ra,ffffffe000202d08 <printk>
    schedule();
ffffffe000201e14:	c18ff0ef          	jal	ra,ffffffe00020122c <schedule>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
ffffffe000201e18:	01c000ef          	jal	ra,ffffffe000201e34 <test>
    return 0;
ffffffe000201e1c:	00000793          	li	a5,0
}
ffffffe000201e20:	00078513          	mv	a0,a5
ffffffe000201e24:	00813083          	ld	ra,8(sp)
ffffffe000201e28:	00013403          	ld	s0,0(sp)
ffffffe000201e2c:	01010113          	addi	sp,sp,16
ffffffe000201e30:	00008067          	ret

ffffffe000201e34 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
ffffffe000201e34:	fe010113          	addi	sp,sp,-32
ffffffe000201e38:	00113c23          	sd	ra,24(sp)
ffffffe000201e3c:	00813823          	sd	s0,16(sp)
ffffffe000201e40:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
ffffffe000201e44:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000201e48:	fec42783          	lw	a5,-20(s0)
ffffffe000201e4c:	0017879b          	addiw	a5,a5,1
ffffffe000201e50:	fef42623          	sw	a5,-20(s0)
ffffffe000201e54:	fec42703          	lw	a4,-20(s0)
ffffffe000201e58:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000201e5c:	1007879b          	addiw	a5,a5,256
ffffffe000201e60:	02f767bb          	remw	a5,a4,a5
ffffffe000201e64:	0007879b          	sext.w	a5,a5
ffffffe000201e68:	fe0790e3          	bnez	a5,ffffffe000201e48 <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
ffffffe000201e6c:	00001517          	auipc	a0,0x1
ffffffe000201e70:	3bc50513          	addi	a0,a0,956 # ffffffe000203228 <_srodata+0x228>
ffffffe000201e74:	695000ef          	jal	ra,ffffffe000202d08 <printk>
            i = 0;
ffffffe000201e78:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000201e7c:	fcdff06f          	j	ffffffe000201e48 <test+0x14>

ffffffe000201e80 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000201e80:	fe010113          	addi	sp,sp,-32
ffffffe000201e84:	00113c23          	sd	ra,24(sp)
ffffffe000201e88:	00813823          	sd	s0,16(sp)
ffffffe000201e8c:	02010413          	addi	s0,sp,32
ffffffe000201e90:	00050793          	mv	a5,a0
ffffffe000201e94:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000201e98:	fec42783          	lw	a5,-20(s0)
ffffffe000201e9c:	0ff7f793          	andi	a5,a5,255
ffffffe000201ea0:	00078513          	mv	a0,a5
ffffffe000201ea4:	ee4ff0ef          	jal	ra,ffffffe000201588 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201ea8:	fec42783          	lw	a5,-20(s0)
ffffffe000201eac:	0ff7f793          	andi	a5,a5,255
ffffffe000201eb0:	0007879b          	sext.w	a5,a5
}
ffffffe000201eb4:	00078513          	mv	a0,a5
ffffffe000201eb8:	01813083          	ld	ra,24(sp)
ffffffe000201ebc:	01013403          	ld	s0,16(sp)
ffffffe000201ec0:	02010113          	addi	sp,sp,32
ffffffe000201ec4:	00008067          	ret

ffffffe000201ec8 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201ec8:	fe010113          	addi	sp,sp,-32
ffffffe000201ecc:	00813c23          	sd	s0,24(sp)
ffffffe000201ed0:	02010413          	addi	s0,sp,32
ffffffe000201ed4:	00050793          	mv	a5,a0
ffffffe000201ed8:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201edc:	fec42783          	lw	a5,-20(s0)
ffffffe000201ee0:	0007871b          	sext.w	a4,a5
ffffffe000201ee4:	02000793          	li	a5,32
ffffffe000201ee8:	02f70263          	beq	a4,a5,ffffffe000201f0c <isspace+0x44>
ffffffe000201eec:	fec42783          	lw	a5,-20(s0)
ffffffe000201ef0:	0007871b          	sext.w	a4,a5
ffffffe000201ef4:	00800793          	li	a5,8
ffffffe000201ef8:	00e7de63          	bge	a5,a4,ffffffe000201f14 <isspace+0x4c>
ffffffe000201efc:	fec42783          	lw	a5,-20(s0)
ffffffe000201f00:	0007871b          	sext.w	a4,a5
ffffffe000201f04:	00d00793          	li	a5,13
ffffffe000201f08:	00e7c663          	blt	a5,a4,ffffffe000201f14 <isspace+0x4c>
ffffffe000201f0c:	00100793          	li	a5,1
ffffffe000201f10:	0080006f          	j	ffffffe000201f18 <isspace+0x50>
ffffffe000201f14:	00000793          	li	a5,0
}
ffffffe000201f18:	00078513          	mv	a0,a5
ffffffe000201f1c:	01813403          	ld	s0,24(sp)
ffffffe000201f20:	02010113          	addi	sp,sp,32
ffffffe000201f24:	00008067          	ret

ffffffe000201f28 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000201f28:	fb010113          	addi	sp,sp,-80
ffffffe000201f2c:	04113423          	sd	ra,72(sp)
ffffffe000201f30:	04813023          	sd	s0,64(sp)
ffffffe000201f34:	05010413          	addi	s0,sp,80
ffffffe000201f38:	fca43423          	sd	a0,-56(s0)
ffffffe000201f3c:	fcb43023          	sd	a1,-64(s0)
ffffffe000201f40:	00060793          	mv	a5,a2
ffffffe000201f44:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000201f48:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000201f4c:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000201f50:	fc843783          	ld	a5,-56(s0)
ffffffe000201f54:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000201f58:	0100006f          	j	ffffffe000201f68 <strtol+0x40>
        p++;
ffffffe000201f5c:	fd843783          	ld	a5,-40(s0)
ffffffe000201f60:	00178793          	addi	a5,a5,1 # 5f5e001 <OPENSBI_SIZE+0x5d5e001>
ffffffe000201f64:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000201f68:	fd843783          	ld	a5,-40(s0)
ffffffe000201f6c:	0007c783          	lbu	a5,0(a5)
ffffffe000201f70:	0007879b          	sext.w	a5,a5
ffffffe000201f74:	00078513          	mv	a0,a5
ffffffe000201f78:	f51ff0ef          	jal	ra,ffffffe000201ec8 <isspace>
ffffffe000201f7c:	00050793          	mv	a5,a0
ffffffe000201f80:	fc079ee3          	bnez	a5,ffffffe000201f5c <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000201f84:	fd843783          	ld	a5,-40(s0)
ffffffe000201f88:	0007c783          	lbu	a5,0(a5)
ffffffe000201f8c:	00078713          	mv	a4,a5
ffffffe000201f90:	02d00793          	li	a5,45
ffffffe000201f94:	00f71e63          	bne	a4,a5,ffffffe000201fb0 <strtol+0x88>
        neg = true;
ffffffe000201f98:	00100793          	li	a5,1
ffffffe000201f9c:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000201fa0:	fd843783          	ld	a5,-40(s0)
ffffffe000201fa4:	00178793          	addi	a5,a5,1
ffffffe000201fa8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201fac:	0240006f          	j	ffffffe000201fd0 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000201fb0:	fd843783          	ld	a5,-40(s0)
ffffffe000201fb4:	0007c783          	lbu	a5,0(a5)
ffffffe000201fb8:	00078713          	mv	a4,a5
ffffffe000201fbc:	02b00793          	li	a5,43
ffffffe000201fc0:	00f71863          	bne	a4,a5,ffffffe000201fd0 <strtol+0xa8>
        p++;
ffffffe000201fc4:	fd843783          	ld	a5,-40(s0)
ffffffe000201fc8:	00178793          	addi	a5,a5,1
ffffffe000201fcc:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201fd0:	fbc42783          	lw	a5,-68(s0)
ffffffe000201fd4:	0007879b          	sext.w	a5,a5
ffffffe000201fd8:	06079c63          	bnez	a5,ffffffe000202050 <strtol+0x128>
        if (*p == '0') {
ffffffe000201fdc:	fd843783          	ld	a5,-40(s0)
ffffffe000201fe0:	0007c783          	lbu	a5,0(a5)
ffffffe000201fe4:	00078713          	mv	a4,a5
ffffffe000201fe8:	03000793          	li	a5,48
ffffffe000201fec:	04f71e63          	bne	a4,a5,ffffffe000202048 <strtol+0x120>
            p++;
ffffffe000201ff0:	fd843783          	ld	a5,-40(s0)
ffffffe000201ff4:	00178793          	addi	a5,a5,1
ffffffe000201ff8:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201ffc:	fd843783          	ld	a5,-40(s0)
ffffffe000202000:	0007c783          	lbu	a5,0(a5)
ffffffe000202004:	00078713          	mv	a4,a5
ffffffe000202008:	07800793          	li	a5,120
ffffffe00020200c:	00f70c63          	beq	a4,a5,ffffffe000202024 <strtol+0xfc>
ffffffe000202010:	fd843783          	ld	a5,-40(s0)
ffffffe000202014:	0007c783          	lbu	a5,0(a5)
ffffffe000202018:	00078713          	mv	a4,a5
ffffffe00020201c:	05800793          	li	a5,88
ffffffe000202020:	00f71e63          	bne	a4,a5,ffffffe00020203c <strtol+0x114>
                base = 16;
ffffffe000202024:	01000793          	li	a5,16
ffffffe000202028:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe00020202c:	fd843783          	ld	a5,-40(s0)
ffffffe000202030:	00178793          	addi	a5,a5,1
ffffffe000202034:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202038:	0180006f          	j	ffffffe000202050 <strtol+0x128>
            } else {
                base = 8;
ffffffe00020203c:	00800793          	li	a5,8
ffffffe000202040:	faf42e23          	sw	a5,-68(s0)
ffffffe000202044:	00c0006f          	j	ffffffe000202050 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000202048:	00a00793          	li	a5,10
ffffffe00020204c:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000202050:	fd843783          	ld	a5,-40(s0)
ffffffe000202054:	0007c783          	lbu	a5,0(a5)
ffffffe000202058:	00078713          	mv	a4,a5
ffffffe00020205c:	02f00793          	li	a5,47
ffffffe000202060:	02e7f863          	bgeu	a5,a4,ffffffe000202090 <strtol+0x168>
ffffffe000202064:	fd843783          	ld	a5,-40(s0)
ffffffe000202068:	0007c783          	lbu	a5,0(a5)
ffffffe00020206c:	00078713          	mv	a4,a5
ffffffe000202070:	03900793          	li	a5,57
ffffffe000202074:	00e7ee63          	bltu	a5,a4,ffffffe000202090 <strtol+0x168>
            digit = *p - '0';
ffffffe000202078:	fd843783          	ld	a5,-40(s0)
ffffffe00020207c:	0007c783          	lbu	a5,0(a5)
ffffffe000202080:	0007879b          	sext.w	a5,a5
ffffffe000202084:	fd07879b          	addiw	a5,a5,-48
ffffffe000202088:	fcf42a23          	sw	a5,-44(s0)
ffffffe00020208c:	0800006f          	j	ffffffe00020210c <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000202090:	fd843783          	ld	a5,-40(s0)
ffffffe000202094:	0007c783          	lbu	a5,0(a5)
ffffffe000202098:	00078713          	mv	a4,a5
ffffffe00020209c:	06000793          	li	a5,96
ffffffe0002020a0:	02e7f863          	bgeu	a5,a4,ffffffe0002020d0 <strtol+0x1a8>
ffffffe0002020a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002020a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002020ac:	00078713          	mv	a4,a5
ffffffe0002020b0:	07a00793          	li	a5,122
ffffffe0002020b4:	00e7ee63          	bltu	a5,a4,ffffffe0002020d0 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe0002020b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002020bc:	0007c783          	lbu	a5,0(a5)
ffffffe0002020c0:	0007879b          	sext.w	a5,a5
ffffffe0002020c4:	fa97879b          	addiw	a5,a5,-87
ffffffe0002020c8:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002020cc:	0400006f          	j	ffffffe00020210c <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe0002020d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002020d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002020d8:	00078713          	mv	a4,a5
ffffffe0002020dc:	04000793          	li	a5,64
ffffffe0002020e0:	06e7f663          	bgeu	a5,a4,ffffffe00020214c <strtol+0x224>
ffffffe0002020e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002020e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002020ec:	00078713          	mv	a4,a5
ffffffe0002020f0:	05a00793          	li	a5,90
ffffffe0002020f4:	04e7ec63          	bltu	a5,a4,ffffffe00020214c <strtol+0x224>
            digit = *p - ('A' - 10);
ffffffe0002020f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002020fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202100:	0007879b          	sext.w	a5,a5
ffffffe000202104:	fc97879b          	addiw	a5,a5,-55
ffffffe000202108:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe00020210c:	fd442703          	lw	a4,-44(s0)
ffffffe000202110:	fbc42783          	lw	a5,-68(s0)
ffffffe000202114:	0007071b          	sext.w	a4,a4
ffffffe000202118:	0007879b          	sext.w	a5,a5
ffffffe00020211c:	02f75663          	bge	a4,a5,ffffffe000202148 <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
ffffffe000202120:	fbc42703          	lw	a4,-68(s0)
ffffffe000202124:	fe843783          	ld	a5,-24(s0)
ffffffe000202128:	02f70733          	mul	a4,a4,a5
ffffffe00020212c:	fd442783          	lw	a5,-44(s0)
ffffffe000202130:	00f707b3          	add	a5,a4,a5
ffffffe000202134:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202138:	fd843783          	ld	a5,-40(s0)
ffffffe00020213c:	00178793          	addi	a5,a5,1
ffffffe000202140:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000202144:	f0dff06f          	j	ffffffe000202050 <strtol+0x128>
            break;
ffffffe000202148:	00000013          	nop
    }

    if (endptr) {
ffffffe00020214c:	fc043783          	ld	a5,-64(s0)
ffffffe000202150:	00078863          	beqz	a5,ffffffe000202160 <strtol+0x238>
        *endptr = (char *)p;
ffffffe000202154:	fc043783          	ld	a5,-64(s0)
ffffffe000202158:	fd843703          	ld	a4,-40(s0)
ffffffe00020215c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202160:	fe744783          	lbu	a5,-25(s0)
ffffffe000202164:	0ff7f793          	andi	a5,a5,255
ffffffe000202168:	00078863          	beqz	a5,ffffffe000202178 <strtol+0x250>
ffffffe00020216c:	fe843783          	ld	a5,-24(s0)
ffffffe000202170:	40f007b3          	neg	a5,a5
ffffffe000202174:	0080006f          	j	ffffffe00020217c <strtol+0x254>
ffffffe000202178:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020217c:	00078513          	mv	a0,a5
ffffffe000202180:	04813083          	ld	ra,72(sp)
ffffffe000202184:	04013403          	ld	s0,64(sp)
ffffffe000202188:	05010113          	addi	sp,sp,80
ffffffe00020218c:	00008067          	ret

ffffffe000202190 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000202190:	fd010113          	addi	sp,sp,-48
ffffffe000202194:	02113423          	sd	ra,40(sp)
ffffffe000202198:	02813023          	sd	s0,32(sp)
ffffffe00020219c:	03010413          	addi	s0,sp,48
ffffffe0002021a0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002021a4:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002021a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002021ac:	00079863          	bnez	a5,ffffffe0002021bc <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002021b0:	00001797          	auipc	a5,0x1
ffffffe0002021b4:	09078793          	addi	a5,a5,144 # ffffffe000203240 <_srodata+0x240>
ffffffe0002021b8:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe0002021bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002021c0:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe0002021c4:	0240006f          	j	ffffffe0002021e8 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe0002021c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002021cc:	00178713          	addi	a4,a5,1
ffffffe0002021d0:	fee43423          	sd	a4,-24(s0)
ffffffe0002021d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002021d8:	0007879b          	sext.w	a5,a5
ffffffe0002021dc:	fd843703          	ld	a4,-40(s0)
ffffffe0002021e0:	00078513          	mv	a0,a5
ffffffe0002021e4:	000700e7          	jalr	a4
    while (*p) {
ffffffe0002021e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002021ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002021f0:	fc079ce3          	bnez	a5,ffffffe0002021c8 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe0002021f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002021f8:	fd043783          	ld	a5,-48(s0)
ffffffe0002021fc:	40f707b3          	sub	a5,a4,a5
ffffffe000202200:	0007879b          	sext.w	a5,a5
}
ffffffe000202204:	00078513          	mv	a0,a5
ffffffe000202208:	02813083          	ld	ra,40(sp)
ffffffe00020220c:	02013403          	ld	s0,32(sp)
ffffffe000202210:	03010113          	addi	sp,sp,48
ffffffe000202214:	00008067          	ret

ffffffe000202218 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202218:	f9010113          	addi	sp,sp,-112
ffffffe00020221c:	06113423          	sd	ra,104(sp)
ffffffe000202220:	06813023          	sd	s0,96(sp)
ffffffe000202224:	07010413          	addi	s0,sp,112
ffffffe000202228:	faa43423          	sd	a0,-88(s0)
ffffffe00020222c:	fab43023          	sd	a1,-96(s0)
ffffffe000202230:	00060793          	mv	a5,a2
ffffffe000202234:	f8d43823          	sd	a3,-112(s0)
ffffffe000202238:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe00020223c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202240:	0ff7f793          	andi	a5,a5,255
ffffffe000202244:	02078663          	beqz	a5,ffffffe000202270 <print_dec_int+0x58>
ffffffe000202248:	fa043703          	ld	a4,-96(s0)
ffffffe00020224c:	fff00793          	li	a5,-1
ffffffe000202250:	03f79793          	slli	a5,a5,0x3f
ffffffe000202254:	00f71e63          	bne	a4,a5,ffffffe000202270 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202258:	00001597          	auipc	a1,0x1
ffffffe00020225c:	ff058593          	addi	a1,a1,-16 # ffffffe000203248 <_srodata+0x248>
ffffffe000202260:	fa843503          	ld	a0,-88(s0)
ffffffe000202264:	f2dff0ef          	jal	ra,ffffffe000202190 <puts_wo_nl>
ffffffe000202268:	00050793          	mv	a5,a0
ffffffe00020226c:	2980006f          	j	ffffffe000202504 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202270:	f9043783          	ld	a5,-112(s0)
ffffffe000202274:	00c7a783          	lw	a5,12(a5)
ffffffe000202278:	00079a63          	bnez	a5,ffffffe00020228c <print_dec_int+0x74>
ffffffe00020227c:	fa043783          	ld	a5,-96(s0)
ffffffe000202280:	00079663          	bnez	a5,ffffffe00020228c <print_dec_int+0x74>
        return 0;
ffffffe000202284:	00000793          	li	a5,0
ffffffe000202288:	27c0006f          	j	ffffffe000202504 <print_dec_int+0x2ec>
    }

    bool neg = false;
ffffffe00020228c:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000202290:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202294:	0ff7f793          	andi	a5,a5,255
ffffffe000202298:	02078063          	beqz	a5,ffffffe0002022b8 <print_dec_int+0xa0>
ffffffe00020229c:	fa043783          	ld	a5,-96(s0)
ffffffe0002022a0:	0007dc63          	bgez	a5,ffffffe0002022b8 <print_dec_int+0xa0>
        neg = true;
ffffffe0002022a4:	00100793          	li	a5,1
ffffffe0002022a8:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe0002022ac:	fa043783          	ld	a5,-96(s0)
ffffffe0002022b0:	40f007b3          	neg	a5,a5
ffffffe0002022b4:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe0002022b8:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe0002022bc:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002022c0:	0ff7f793          	andi	a5,a5,255
ffffffe0002022c4:	02078863          	beqz	a5,ffffffe0002022f4 <print_dec_int+0xdc>
ffffffe0002022c8:	fef44783          	lbu	a5,-17(s0)
ffffffe0002022cc:	0ff7f793          	andi	a5,a5,255
ffffffe0002022d0:	00079e63          	bnez	a5,ffffffe0002022ec <print_dec_int+0xd4>
ffffffe0002022d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002022d8:	0057c783          	lbu	a5,5(a5)
ffffffe0002022dc:	00079863          	bnez	a5,ffffffe0002022ec <print_dec_int+0xd4>
ffffffe0002022e0:	f9043783          	ld	a5,-112(s0)
ffffffe0002022e4:	0047c783          	lbu	a5,4(a5)
ffffffe0002022e8:	00078663          	beqz	a5,ffffffe0002022f4 <print_dec_int+0xdc>
ffffffe0002022ec:	00100793          	li	a5,1
ffffffe0002022f0:	0080006f          	j	ffffffe0002022f8 <print_dec_int+0xe0>
ffffffe0002022f4:	00000793          	li	a5,0
ffffffe0002022f8:	fcf40ba3          	sb	a5,-41(s0)
ffffffe0002022fc:	fd744783          	lbu	a5,-41(s0)
ffffffe000202300:	0017f793          	andi	a5,a5,1
ffffffe000202304:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000202308:	fa043703          	ld	a4,-96(s0)
ffffffe00020230c:	00a00793          	li	a5,10
ffffffe000202310:	02f777b3          	remu	a5,a4,a5
ffffffe000202314:	0ff7f713          	andi	a4,a5,255
ffffffe000202318:	fe842783          	lw	a5,-24(s0)
ffffffe00020231c:	0017869b          	addiw	a3,a5,1
ffffffe000202320:	fed42423          	sw	a3,-24(s0)
ffffffe000202324:	0307071b          	addiw	a4,a4,48
ffffffe000202328:	0ff77713          	andi	a4,a4,255
ffffffe00020232c:	ff040693          	addi	a3,s0,-16
ffffffe000202330:	00f687b3          	add	a5,a3,a5
ffffffe000202334:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000202338:	fa043703          	ld	a4,-96(s0)
ffffffe00020233c:	00a00793          	li	a5,10
ffffffe000202340:	02f757b3          	divu	a5,a4,a5
ffffffe000202344:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000202348:	fa043783          	ld	a5,-96(s0)
ffffffe00020234c:	fa079ee3          	bnez	a5,ffffffe000202308 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000202350:	f9043783          	ld	a5,-112(s0)
ffffffe000202354:	00c7a783          	lw	a5,12(a5)
ffffffe000202358:	00078713          	mv	a4,a5
ffffffe00020235c:	fff00793          	li	a5,-1
ffffffe000202360:	02f71063          	bne	a4,a5,ffffffe000202380 <print_dec_int+0x168>
ffffffe000202364:	f9043783          	ld	a5,-112(s0)
ffffffe000202368:	0037c783          	lbu	a5,3(a5)
ffffffe00020236c:	00078a63          	beqz	a5,ffffffe000202380 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000202370:	f9043783          	ld	a5,-112(s0)
ffffffe000202374:	0087a703          	lw	a4,8(a5)
ffffffe000202378:	f9043783          	ld	a5,-112(s0)
ffffffe00020237c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000202380:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000202384:	f9043783          	ld	a5,-112(s0)
ffffffe000202388:	0087a703          	lw	a4,8(a5)
ffffffe00020238c:	fe842783          	lw	a5,-24(s0)
ffffffe000202390:	fcf42823          	sw	a5,-48(s0)
ffffffe000202394:	f9043783          	ld	a5,-112(s0)
ffffffe000202398:	00c7a783          	lw	a5,12(a5)
ffffffe00020239c:	fcf42623          	sw	a5,-52(s0)
ffffffe0002023a0:	fd042583          	lw	a1,-48(s0)
ffffffe0002023a4:	fcc42783          	lw	a5,-52(s0)
ffffffe0002023a8:	0007861b          	sext.w	a2,a5
ffffffe0002023ac:	0005869b          	sext.w	a3,a1
ffffffe0002023b0:	00d65463          	bge	a2,a3,ffffffe0002023b8 <print_dec_int+0x1a0>
ffffffe0002023b4:	00058793          	mv	a5,a1
ffffffe0002023b8:	0007879b          	sext.w	a5,a5
ffffffe0002023bc:	40f707bb          	subw	a5,a4,a5
ffffffe0002023c0:	0007871b          	sext.w	a4,a5
ffffffe0002023c4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002023c8:	0007879b          	sext.w	a5,a5
ffffffe0002023cc:	40f707bb          	subw	a5,a4,a5
ffffffe0002023d0:	fef42023          	sw	a5,-32(s0)
ffffffe0002023d4:	0280006f          	j	ffffffe0002023fc <print_dec_int+0x1e4>
        putch(' ');
ffffffe0002023d8:	fa843783          	ld	a5,-88(s0)
ffffffe0002023dc:	02000513          	li	a0,32
ffffffe0002023e0:	000780e7          	jalr	a5
        ++written;
ffffffe0002023e4:	fe442783          	lw	a5,-28(s0)
ffffffe0002023e8:	0017879b          	addiw	a5,a5,1
ffffffe0002023ec:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002023f0:	fe042783          	lw	a5,-32(s0)
ffffffe0002023f4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002023f8:	fef42023          	sw	a5,-32(s0)
ffffffe0002023fc:	fe042783          	lw	a5,-32(s0)
ffffffe000202400:	0007879b          	sext.w	a5,a5
ffffffe000202404:	fcf04ae3          	bgtz	a5,ffffffe0002023d8 <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
ffffffe000202408:	fd744783          	lbu	a5,-41(s0)
ffffffe00020240c:	0ff7f793          	andi	a5,a5,255
ffffffe000202410:	04078463          	beqz	a5,ffffffe000202458 <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000202414:	fef44783          	lbu	a5,-17(s0)
ffffffe000202418:	0ff7f793          	andi	a5,a5,255
ffffffe00020241c:	00078663          	beqz	a5,ffffffe000202428 <print_dec_int+0x210>
ffffffe000202420:	02d00793          	li	a5,45
ffffffe000202424:	01c0006f          	j	ffffffe000202440 <print_dec_int+0x228>
ffffffe000202428:	f9043783          	ld	a5,-112(s0)
ffffffe00020242c:	0057c783          	lbu	a5,5(a5)
ffffffe000202430:	00078663          	beqz	a5,ffffffe00020243c <print_dec_int+0x224>
ffffffe000202434:	02b00793          	li	a5,43
ffffffe000202438:	0080006f          	j	ffffffe000202440 <print_dec_int+0x228>
ffffffe00020243c:	02000793          	li	a5,32
ffffffe000202440:	fa843703          	ld	a4,-88(s0)
ffffffe000202444:	00078513          	mv	a0,a5
ffffffe000202448:	000700e7          	jalr	a4
        ++written;
ffffffe00020244c:	fe442783          	lw	a5,-28(s0)
ffffffe000202450:	0017879b          	addiw	a5,a5,1
ffffffe000202454:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202458:	fe842783          	lw	a5,-24(s0)
ffffffe00020245c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202460:	0280006f          	j	ffffffe000202488 <print_dec_int+0x270>
        putch('0');
ffffffe000202464:	fa843783          	ld	a5,-88(s0)
ffffffe000202468:	03000513          	li	a0,48
ffffffe00020246c:	000780e7          	jalr	a5
        ++written;
ffffffe000202470:	fe442783          	lw	a5,-28(s0)
ffffffe000202474:	0017879b          	addiw	a5,a5,1
ffffffe000202478:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe00020247c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202480:	0017879b          	addiw	a5,a5,1
ffffffe000202484:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202488:	f9043783          	ld	a5,-112(s0)
ffffffe00020248c:	00c7a703          	lw	a4,12(a5)
ffffffe000202490:	fd744783          	lbu	a5,-41(s0)
ffffffe000202494:	0007879b          	sext.w	a5,a5
ffffffe000202498:	40f707bb          	subw	a5,a4,a5
ffffffe00020249c:	0007871b          	sext.w	a4,a5
ffffffe0002024a0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002024a4:	0007879b          	sext.w	a5,a5
ffffffe0002024a8:	fae7cee3          	blt	a5,a4,ffffffe000202464 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002024ac:	fe842783          	lw	a5,-24(s0)
ffffffe0002024b0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024b4:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002024b8:	03c0006f          	j	ffffffe0002024f4 <print_dec_int+0x2dc>
        putch(buf[i]);
ffffffe0002024bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002024c0:	ff040713          	addi	a4,s0,-16
ffffffe0002024c4:	00f707b3          	add	a5,a4,a5
ffffffe0002024c8:	fc87c783          	lbu	a5,-56(a5)
ffffffe0002024cc:	0007879b          	sext.w	a5,a5
ffffffe0002024d0:	fa843703          	ld	a4,-88(s0)
ffffffe0002024d4:	00078513          	mv	a0,a5
ffffffe0002024d8:	000700e7          	jalr	a4
        ++written;
ffffffe0002024dc:	fe442783          	lw	a5,-28(s0)
ffffffe0002024e0:	0017879b          	addiw	a5,a5,1
ffffffe0002024e4:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002024e8:	fd842783          	lw	a5,-40(s0)
ffffffe0002024ec:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024f0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002024f4:	fd842783          	lw	a5,-40(s0)
ffffffe0002024f8:	0007879b          	sext.w	a5,a5
ffffffe0002024fc:	fc07d0e3          	bgez	a5,ffffffe0002024bc <print_dec_int+0x2a4>
    }

    return written;
ffffffe000202500:	fe442783          	lw	a5,-28(s0)
}
ffffffe000202504:	00078513          	mv	a0,a5
ffffffe000202508:	06813083          	ld	ra,104(sp)
ffffffe00020250c:	06013403          	ld	s0,96(sp)
ffffffe000202510:	07010113          	addi	sp,sp,112
ffffffe000202514:	00008067          	ret

ffffffe000202518 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000202518:	f4010113          	addi	sp,sp,-192
ffffffe00020251c:	0a113c23          	sd	ra,184(sp)
ffffffe000202520:	0a813823          	sd	s0,176(sp)
ffffffe000202524:	0c010413          	addi	s0,sp,192
ffffffe000202528:	f4a43c23          	sd	a0,-168(s0)
ffffffe00020252c:	f4b43823          	sd	a1,-176(s0)
ffffffe000202530:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000202534:	f8043023          	sd	zero,-128(s0)
ffffffe000202538:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe00020253c:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000202540:	7a40006f          	j	ffffffe000202ce4 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000202544:	f8044783          	lbu	a5,-128(s0)
ffffffe000202548:	72078e63          	beqz	a5,ffffffe000202c84 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe00020254c:	f5043783          	ld	a5,-176(s0)
ffffffe000202550:	0007c783          	lbu	a5,0(a5)
ffffffe000202554:	00078713          	mv	a4,a5
ffffffe000202558:	02300793          	li	a5,35
ffffffe00020255c:	00f71863          	bne	a4,a5,ffffffe00020256c <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000202560:	00100793          	li	a5,1
ffffffe000202564:	f8f40123          	sb	a5,-126(s0)
ffffffe000202568:	7700006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe00020256c:	f5043783          	ld	a5,-176(s0)
ffffffe000202570:	0007c783          	lbu	a5,0(a5)
ffffffe000202574:	00078713          	mv	a4,a5
ffffffe000202578:	03000793          	li	a5,48
ffffffe00020257c:	00f71863          	bne	a4,a5,ffffffe00020258c <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000202580:	00100793          	li	a5,1
ffffffe000202584:	f8f401a3          	sb	a5,-125(s0)
ffffffe000202588:	7500006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe00020258c:	f5043783          	ld	a5,-176(s0)
ffffffe000202590:	0007c783          	lbu	a5,0(a5)
ffffffe000202594:	00078713          	mv	a4,a5
ffffffe000202598:	06c00793          	li	a5,108
ffffffe00020259c:	04f70063          	beq	a4,a5,ffffffe0002025dc <vprintfmt+0xc4>
ffffffe0002025a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002025a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002025a8:	00078713          	mv	a4,a5
ffffffe0002025ac:	07a00793          	li	a5,122
ffffffe0002025b0:	02f70663          	beq	a4,a5,ffffffe0002025dc <vprintfmt+0xc4>
ffffffe0002025b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002025b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002025bc:	00078713          	mv	a4,a5
ffffffe0002025c0:	07400793          	li	a5,116
ffffffe0002025c4:	00f70c63          	beq	a4,a5,ffffffe0002025dc <vprintfmt+0xc4>
ffffffe0002025c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002025cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002025d0:	00078713          	mv	a4,a5
ffffffe0002025d4:	06a00793          	li	a5,106
ffffffe0002025d8:	00f71863          	bne	a4,a5,ffffffe0002025e8 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe0002025dc:	00100793          	li	a5,1
ffffffe0002025e0:	f8f400a3          	sb	a5,-127(s0)
ffffffe0002025e4:	6f40006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe0002025e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002025ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002025f0:	00078713          	mv	a4,a5
ffffffe0002025f4:	02b00793          	li	a5,43
ffffffe0002025f8:	00f71863          	bne	a4,a5,ffffffe000202608 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe0002025fc:	00100793          	li	a5,1
ffffffe000202600:	f8f402a3          	sb	a5,-123(s0)
ffffffe000202604:	6d40006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000202608:	f5043783          	ld	a5,-176(s0)
ffffffe00020260c:	0007c783          	lbu	a5,0(a5)
ffffffe000202610:	00078713          	mv	a4,a5
ffffffe000202614:	02000793          	li	a5,32
ffffffe000202618:	00f71863          	bne	a4,a5,ffffffe000202628 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe00020261c:	00100793          	li	a5,1
ffffffe000202620:	f8f40223          	sb	a5,-124(s0)
ffffffe000202624:	6b40006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000202628:	f5043783          	ld	a5,-176(s0)
ffffffe00020262c:	0007c783          	lbu	a5,0(a5)
ffffffe000202630:	00078713          	mv	a4,a5
ffffffe000202634:	02a00793          	li	a5,42
ffffffe000202638:	00f71e63          	bne	a4,a5,ffffffe000202654 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe00020263c:	f4843783          	ld	a5,-184(s0)
ffffffe000202640:	00878713          	addi	a4,a5,8
ffffffe000202644:	f4e43423          	sd	a4,-184(s0)
ffffffe000202648:	0007a783          	lw	a5,0(a5)
ffffffe00020264c:	f8f42423          	sw	a5,-120(s0)
ffffffe000202650:	6880006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000202654:	f5043783          	ld	a5,-176(s0)
ffffffe000202658:	0007c783          	lbu	a5,0(a5)
ffffffe00020265c:	00078713          	mv	a4,a5
ffffffe000202660:	03000793          	li	a5,48
ffffffe000202664:	04e7f663          	bgeu	a5,a4,ffffffe0002026b0 <vprintfmt+0x198>
ffffffe000202668:	f5043783          	ld	a5,-176(s0)
ffffffe00020266c:	0007c783          	lbu	a5,0(a5)
ffffffe000202670:	00078713          	mv	a4,a5
ffffffe000202674:	03900793          	li	a5,57
ffffffe000202678:	02e7ec63          	bltu	a5,a4,ffffffe0002026b0 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe00020267c:	f5043783          	ld	a5,-176(s0)
ffffffe000202680:	f5040713          	addi	a4,s0,-176
ffffffe000202684:	00a00613          	li	a2,10
ffffffe000202688:	00070593          	mv	a1,a4
ffffffe00020268c:	00078513          	mv	a0,a5
ffffffe000202690:	899ff0ef          	jal	ra,ffffffe000201f28 <strtol>
ffffffe000202694:	00050793          	mv	a5,a0
ffffffe000202698:	0007879b          	sext.w	a5,a5
ffffffe00020269c:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe0002026a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002026a4:	fff78793          	addi	a5,a5,-1
ffffffe0002026a8:	f4f43823          	sd	a5,-176(s0)
ffffffe0002026ac:	62c0006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe0002026b0:	f5043783          	ld	a5,-176(s0)
ffffffe0002026b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002026b8:	00078713          	mv	a4,a5
ffffffe0002026bc:	02e00793          	li	a5,46
ffffffe0002026c0:	06f71863          	bne	a4,a5,ffffffe000202730 <vprintfmt+0x218>
                fmt++;
ffffffe0002026c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002026c8:	00178793          	addi	a5,a5,1
ffffffe0002026cc:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe0002026d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002026d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002026d8:	00078713          	mv	a4,a5
ffffffe0002026dc:	02a00793          	li	a5,42
ffffffe0002026e0:	00f71e63          	bne	a4,a5,ffffffe0002026fc <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe0002026e4:	f4843783          	ld	a5,-184(s0)
ffffffe0002026e8:	00878713          	addi	a4,a5,8
ffffffe0002026ec:	f4e43423          	sd	a4,-184(s0)
ffffffe0002026f0:	0007a783          	lw	a5,0(a5)
ffffffe0002026f4:	f8f42623          	sw	a5,-116(s0)
ffffffe0002026f8:	5e00006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe0002026fc:	f5043783          	ld	a5,-176(s0)
ffffffe000202700:	f5040713          	addi	a4,s0,-176
ffffffe000202704:	00a00613          	li	a2,10
ffffffe000202708:	00070593          	mv	a1,a4
ffffffe00020270c:	00078513          	mv	a0,a5
ffffffe000202710:	819ff0ef          	jal	ra,ffffffe000201f28 <strtol>
ffffffe000202714:	00050793          	mv	a5,a0
ffffffe000202718:	0007879b          	sext.w	a5,a5
ffffffe00020271c:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000202720:	f5043783          	ld	a5,-176(s0)
ffffffe000202724:	fff78793          	addi	a5,a5,-1
ffffffe000202728:	f4f43823          	sd	a5,-176(s0)
ffffffe00020272c:	5ac0006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202730:	f5043783          	ld	a5,-176(s0)
ffffffe000202734:	0007c783          	lbu	a5,0(a5)
ffffffe000202738:	00078713          	mv	a4,a5
ffffffe00020273c:	07800793          	li	a5,120
ffffffe000202740:	02f70663          	beq	a4,a5,ffffffe00020276c <vprintfmt+0x254>
ffffffe000202744:	f5043783          	ld	a5,-176(s0)
ffffffe000202748:	0007c783          	lbu	a5,0(a5)
ffffffe00020274c:	00078713          	mv	a4,a5
ffffffe000202750:	05800793          	li	a5,88
ffffffe000202754:	00f70c63          	beq	a4,a5,ffffffe00020276c <vprintfmt+0x254>
ffffffe000202758:	f5043783          	ld	a5,-176(s0)
ffffffe00020275c:	0007c783          	lbu	a5,0(a5)
ffffffe000202760:	00078713          	mv	a4,a5
ffffffe000202764:	07000793          	li	a5,112
ffffffe000202768:	2ef71e63          	bne	a4,a5,ffffffe000202a64 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe00020276c:	f5043783          	ld	a5,-176(s0)
ffffffe000202770:	0007c783          	lbu	a5,0(a5)
ffffffe000202774:	00078713          	mv	a4,a5
ffffffe000202778:	07000793          	li	a5,112
ffffffe00020277c:	00f70663          	beq	a4,a5,ffffffe000202788 <vprintfmt+0x270>
ffffffe000202780:	f8144783          	lbu	a5,-127(s0)
ffffffe000202784:	00078663          	beqz	a5,ffffffe000202790 <vprintfmt+0x278>
ffffffe000202788:	00100793          	li	a5,1
ffffffe00020278c:	0080006f          	j	ffffffe000202794 <vprintfmt+0x27c>
ffffffe000202790:	00000793          	li	a5,0
ffffffe000202794:	faf403a3          	sb	a5,-89(s0)
ffffffe000202798:	fa744783          	lbu	a5,-89(s0)
ffffffe00020279c:	0017f793          	andi	a5,a5,1
ffffffe0002027a0:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe0002027a4:	fa744783          	lbu	a5,-89(s0)
ffffffe0002027a8:	0ff7f793          	andi	a5,a5,255
ffffffe0002027ac:	00078c63          	beqz	a5,ffffffe0002027c4 <vprintfmt+0x2ac>
ffffffe0002027b0:	f4843783          	ld	a5,-184(s0)
ffffffe0002027b4:	00878713          	addi	a4,a5,8
ffffffe0002027b8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002027bc:	0007b783          	ld	a5,0(a5)
ffffffe0002027c0:	01c0006f          	j	ffffffe0002027dc <vprintfmt+0x2c4>
ffffffe0002027c4:	f4843783          	ld	a5,-184(s0)
ffffffe0002027c8:	00878713          	addi	a4,a5,8
ffffffe0002027cc:	f4e43423          	sd	a4,-184(s0)
ffffffe0002027d0:	0007a783          	lw	a5,0(a5)
ffffffe0002027d4:	02079793          	slli	a5,a5,0x20
ffffffe0002027d8:	0207d793          	srli	a5,a5,0x20
ffffffe0002027dc:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe0002027e0:	f8c42783          	lw	a5,-116(s0)
ffffffe0002027e4:	02079463          	bnez	a5,ffffffe00020280c <vprintfmt+0x2f4>
ffffffe0002027e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002027ec:	02079063          	bnez	a5,ffffffe00020280c <vprintfmt+0x2f4>
ffffffe0002027f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002027f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002027f8:	00078713          	mv	a4,a5
ffffffe0002027fc:	07000793          	li	a5,112
ffffffe000202800:	00f70663          	beq	a4,a5,ffffffe00020280c <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000202804:	f8040023          	sb	zero,-128(s0)
ffffffe000202808:	4d00006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe00020280c:	f5043783          	ld	a5,-176(s0)
ffffffe000202810:	0007c783          	lbu	a5,0(a5)
ffffffe000202814:	00078713          	mv	a4,a5
ffffffe000202818:	07000793          	li	a5,112
ffffffe00020281c:	00f70a63          	beq	a4,a5,ffffffe000202830 <vprintfmt+0x318>
ffffffe000202820:	f8244783          	lbu	a5,-126(s0)
ffffffe000202824:	00078a63          	beqz	a5,ffffffe000202838 <vprintfmt+0x320>
ffffffe000202828:	fe043783          	ld	a5,-32(s0)
ffffffe00020282c:	00078663          	beqz	a5,ffffffe000202838 <vprintfmt+0x320>
ffffffe000202830:	00100793          	li	a5,1
ffffffe000202834:	0080006f          	j	ffffffe00020283c <vprintfmt+0x324>
ffffffe000202838:	00000793          	li	a5,0
ffffffe00020283c:	faf40323          	sb	a5,-90(s0)
ffffffe000202840:	fa644783          	lbu	a5,-90(s0)
ffffffe000202844:	0017f793          	andi	a5,a5,1
ffffffe000202848:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe00020284c:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000202850:	f5043783          	ld	a5,-176(s0)
ffffffe000202854:	0007c783          	lbu	a5,0(a5)
ffffffe000202858:	00078713          	mv	a4,a5
ffffffe00020285c:	05800793          	li	a5,88
ffffffe000202860:	00f71863          	bne	a4,a5,ffffffe000202870 <vprintfmt+0x358>
ffffffe000202864:	00001797          	auipc	a5,0x1
ffffffe000202868:	9fc78793          	addi	a5,a5,-1540 # ffffffe000203260 <upperxdigits.1101>
ffffffe00020286c:	00c0006f          	j	ffffffe000202878 <vprintfmt+0x360>
ffffffe000202870:	00001797          	auipc	a5,0x1
ffffffe000202874:	a0878793          	addi	a5,a5,-1528 # ffffffe000203278 <lowerxdigits.1100>
ffffffe000202878:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe00020287c:	fe043783          	ld	a5,-32(s0)
ffffffe000202880:	00f7f793          	andi	a5,a5,15
ffffffe000202884:	f9843703          	ld	a4,-104(s0)
ffffffe000202888:	00f70733          	add	a4,a4,a5
ffffffe00020288c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202890:	0017869b          	addiw	a3,a5,1
ffffffe000202894:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202898:	00074703          	lbu	a4,0(a4)
ffffffe00020289c:	ff040693          	addi	a3,s0,-16
ffffffe0002028a0:	00f687b3          	add	a5,a3,a5
ffffffe0002028a4:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002028a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002028ac:	0047d793          	srli	a5,a5,0x4
ffffffe0002028b0:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe0002028b4:	fe043783          	ld	a5,-32(s0)
ffffffe0002028b8:	fc0792e3          	bnez	a5,ffffffe00020287c <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe0002028bc:	f8c42783          	lw	a5,-116(s0)
ffffffe0002028c0:	00078713          	mv	a4,a5
ffffffe0002028c4:	fff00793          	li	a5,-1
ffffffe0002028c8:	02f71663          	bne	a4,a5,ffffffe0002028f4 <vprintfmt+0x3dc>
ffffffe0002028cc:	f8344783          	lbu	a5,-125(s0)
ffffffe0002028d0:	02078263          	beqz	a5,ffffffe0002028f4 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe0002028d4:	f8842703          	lw	a4,-120(s0)
ffffffe0002028d8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002028dc:	0007879b          	sext.w	a5,a5
ffffffe0002028e0:	0017979b          	slliw	a5,a5,0x1
ffffffe0002028e4:	0007879b          	sext.w	a5,a5
ffffffe0002028e8:	40f707bb          	subw	a5,a4,a5
ffffffe0002028ec:	0007879b          	sext.w	a5,a5
ffffffe0002028f0:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002028f4:	f8842703          	lw	a4,-120(s0)
ffffffe0002028f8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002028fc:	0007879b          	sext.w	a5,a5
ffffffe000202900:	0017979b          	slliw	a5,a5,0x1
ffffffe000202904:	0007879b          	sext.w	a5,a5
ffffffe000202908:	40f707bb          	subw	a5,a4,a5
ffffffe00020290c:	0007871b          	sext.w	a4,a5
ffffffe000202910:	fdc42783          	lw	a5,-36(s0)
ffffffe000202914:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202918:	f8c42783          	lw	a5,-116(s0)
ffffffe00020291c:	f8f42823          	sw	a5,-112(s0)
ffffffe000202920:	f9442583          	lw	a1,-108(s0)
ffffffe000202924:	f9042783          	lw	a5,-112(s0)
ffffffe000202928:	0007861b          	sext.w	a2,a5
ffffffe00020292c:	0005869b          	sext.w	a3,a1
ffffffe000202930:	00d65463          	bge	a2,a3,ffffffe000202938 <vprintfmt+0x420>
ffffffe000202934:	00058793          	mv	a5,a1
ffffffe000202938:	0007879b          	sext.w	a5,a5
ffffffe00020293c:	40f707bb          	subw	a5,a4,a5
ffffffe000202940:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202944:	0280006f          	j	ffffffe00020296c <vprintfmt+0x454>
                    putch(' ');
ffffffe000202948:	f5843783          	ld	a5,-168(s0)
ffffffe00020294c:	02000513          	li	a0,32
ffffffe000202950:	000780e7          	jalr	a5
                    ++written;
ffffffe000202954:	fec42783          	lw	a5,-20(s0)
ffffffe000202958:	0017879b          	addiw	a5,a5,1
ffffffe00020295c:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202960:	fd842783          	lw	a5,-40(s0)
ffffffe000202964:	fff7879b          	addiw	a5,a5,-1
ffffffe000202968:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020296c:	fd842783          	lw	a5,-40(s0)
ffffffe000202970:	0007879b          	sext.w	a5,a5
ffffffe000202974:	fcf04ae3          	bgtz	a5,ffffffe000202948 <vprintfmt+0x430>
                }

                if (prefix) {
ffffffe000202978:	fa644783          	lbu	a5,-90(s0)
ffffffe00020297c:	0ff7f793          	andi	a5,a5,255
ffffffe000202980:	04078463          	beqz	a5,ffffffe0002029c8 <vprintfmt+0x4b0>
                    putch('0');
ffffffe000202984:	f5843783          	ld	a5,-168(s0)
ffffffe000202988:	03000513          	li	a0,48
ffffffe00020298c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202990:	f5043783          	ld	a5,-176(s0)
ffffffe000202994:	0007c783          	lbu	a5,0(a5)
ffffffe000202998:	00078713          	mv	a4,a5
ffffffe00020299c:	05800793          	li	a5,88
ffffffe0002029a0:	00f71663          	bne	a4,a5,ffffffe0002029ac <vprintfmt+0x494>
ffffffe0002029a4:	05800793          	li	a5,88
ffffffe0002029a8:	0080006f          	j	ffffffe0002029b0 <vprintfmt+0x498>
ffffffe0002029ac:	07800793          	li	a5,120
ffffffe0002029b0:	f5843703          	ld	a4,-168(s0)
ffffffe0002029b4:	00078513          	mv	a0,a5
ffffffe0002029b8:	000700e7          	jalr	a4
                    written += 2;
ffffffe0002029bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002029c0:	0027879b          	addiw	a5,a5,2
ffffffe0002029c4:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002029c8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002029cc:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002029d0:	0280006f          	j	ffffffe0002029f8 <vprintfmt+0x4e0>
                    putch('0');
ffffffe0002029d4:	f5843783          	ld	a5,-168(s0)
ffffffe0002029d8:	03000513          	li	a0,48
ffffffe0002029dc:	000780e7          	jalr	a5
                    ++written;
ffffffe0002029e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002029e4:	0017879b          	addiw	a5,a5,1
ffffffe0002029e8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002029ec:	fd442783          	lw	a5,-44(s0)
ffffffe0002029f0:	0017879b          	addiw	a5,a5,1
ffffffe0002029f4:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002029f8:	f8c42703          	lw	a4,-116(s0)
ffffffe0002029fc:	fd442783          	lw	a5,-44(s0)
ffffffe000202a00:	0007879b          	sext.w	a5,a5
ffffffe000202a04:	fce7c8e3          	blt	a5,a4,ffffffe0002029d4 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202a08:	fdc42783          	lw	a5,-36(s0)
ffffffe000202a0c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202a10:	fcf42823          	sw	a5,-48(s0)
ffffffe000202a14:	03c0006f          	j	ffffffe000202a50 <vprintfmt+0x538>
                    putch(buf[i]);
ffffffe000202a18:	fd042783          	lw	a5,-48(s0)
ffffffe000202a1c:	ff040713          	addi	a4,s0,-16
ffffffe000202a20:	00f707b3          	add	a5,a4,a5
ffffffe000202a24:	f807c783          	lbu	a5,-128(a5)
ffffffe000202a28:	0007879b          	sext.w	a5,a5
ffffffe000202a2c:	f5843703          	ld	a4,-168(s0)
ffffffe000202a30:	00078513          	mv	a0,a5
ffffffe000202a34:	000700e7          	jalr	a4
                    ++written;
ffffffe000202a38:	fec42783          	lw	a5,-20(s0)
ffffffe000202a3c:	0017879b          	addiw	a5,a5,1
ffffffe000202a40:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202a44:	fd042783          	lw	a5,-48(s0)
ffffffe000202a48:	fff7879b          	addiw	a5,a5,-1
ffffffe000202a4c:	fcf42823          	sw	a5,-48(s0)
ffffffe000202a50:	fd042783          	lw	a5,-48(s0)
ffffffe000202a54:	0007879b          	sext.w	a5,a5
ffffffe000202a58:	fc07d0e3          	bgez	a5,ffffffe000202a18 <vprintfmt+0x500>
                }

                flags.in_format = false;
ffffffe000202a5c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202a60:	2780006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202a64:	f5043783          	ld	a5,-176(s0)
ffffffe000202a68:	0007c783          	lbu	a5,0(a5)
ffffffe000202a6c:	00078713          	mv	a4,a5
ffffffe000202a70:	06400793          	li	a5,100
ffffffe000202a74:	02f70663          	beq	a4,a5,ffffffe000202aa0 <vprintfmt+0x588>
ffffffe000202a78:	f5043783          	ld	a5,-176(s0)
ffffffe000202a7c:	0007c783          	lbu	a5,0(a5)
ffffffe000202a80:	00078713          	mv	a4,a5
ffffffe000202a84:	06900793          	li	a5,105
ffffffe000202a88:	00f70c63          	beq	a4,a5,ffffffe000202aa0 <vprintfmt+0x588>
ffffffe000202a8c:	f5043783          	ld	a5,-176(s0)
ffffffe000202a90:	0007c783          	lbu	a5,0(a5)
ffffffe000202a94:	00078713          	mv	a4,a5
ffffffe000202a98:	07500793          	li	a5,117
ffffffe000202a9c:	08f71263          	bne	a4,a5,ffffffe000202b20 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202aa0:	f8144783          	lbu	a5,-127(s0)
ffffffe000202aa4:	00078c63          	beqz	a5,ffffffe000202abc <vprintfmt+0x5a4>
ffffffe000202aa8:	f4843783          	ld	a5,-184(s0)
ffffffe000202aac:	00878713          	addi	a4,a5,8
ffffffe000202ab0:	f4e43423          	sd	a4,-184(s0)
ffffffe000202ab4:	0007b783          	ld	a5,0(a5)
ffffffe000202ab8:	0140006f          	j	ffffffe000202acc <vprintfmt+0x5b4>
ffffffe000202abc:	f4843783          	ld	a5,-184(s0)
ffffffe000202ac0:	00878713          	addi	a4,a5,8
ffffffe000202ac4:	f4e43423          	sd	a4,-184(s0)
ffffffe000202ac8:	0007a783          	lw	a5,0(a5)
ffffffe000202acc:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202ad0:	fa843583          	ld	a1,-88(s0)
ffffffe000202ad4:	f5043783          	ld	a5,-176(s0)
ffffffe000202ad8:	0007c783          	lbu	a5,0(a5)
ffffffe000202adc:	0007871b          	sext.w	a4,a5
ffffffe000202ae0:	07500793          	li	a5,117
ffffffe000202ae4:	40f707b3          	sub	a5,a4,a5
ffffffe000202ae8:	00f037b3          	snez	a5,a5
ffffffe000202aec:	0ff7f793          	andi	a5,a5,255
ffffffe000202af0:	f8040713          	addi	a4,s0,-128
ffffffe000202af4:	00070693          	mv	a3,a4
ffffffe000202af8:	00078613          	mv	a2,a5
ffffffe000202afc:	f5843503          	ld	a0,-168(s0)
ffffffe000202b00:	f18ff0ef          	jal	ra,ffffffe000202218 <print_dec_int>
ffffffe000202b04:	00050793          	mv	a5,a0
ffffffe000202b08:	00078713          	mv	a4,a5
ffffffe000202b0c:	fec42783          	lw	a5,-20(s0)
ffffffe000202b10:	00e787bb          	addw	a5,a5,a4
ffffffe000202b14:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202b18:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202b1c:	1bc0006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000202b20:	f5043783          	ld	a5,-176(s0)
ffffffe000202b24:	0007c783          	lbu	a5,0(a5)
ffffffe000202b28:	00078713          	mv	a4,a5
ffffffe000202b2c:	06e00793          	li	a5,110
ffffffe000202b30:	04f71c63          	bne	a4,a5,ffffffe000202b88 <vprintfmt+0x670>
                if (flags.longflag) {
ffffffe000202b34:	f8144783          	lbu	a5,-127(s0)
ffffffe000202b38:	02078463          	beqz	a5,ffffffe000202b60 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
ffffffe000202b3c:	f4843783          	ld	a5,-184(s0)
ffffffe000202b40:	00878713          	addi	a4,a5,8
ffffffe000202b44:	f4e43423          	sd	a4,-184(s0)
ffffffe000202b48:	0007b783          	ld	a5,0(a5)
ffffffe000202b4c:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000202b50:	fec42703          	lw	a4,-20(s0)
ffffffe000202b54:	fb043783          	ld	a5,-80(s0)
ffffffe000202b58:	00e7b023          	sd	a4,0(a5)
ffffffe000202b5c:	0240006f          	j	ffffffe000202b80 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202b60:	f4843783          	ld	a5,-184(s0)
ffffffe000202b64:	00878713          	addi	a4,a5,8
ffffffe000202b68:	f4e43423          	sd	a4,-184(s0)
ffffffe000202b6c:	0007b783          	ld	a5,0(a5)
ffffffe000202b70:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202b74:	fb843783          	ld	a5,-72(s0)
ffffffe000202b78:	fec42703          	lw	a4,-20(s0)
ffffffe000202b7c:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202b80:	f8040023          	sb	zero,-128(s0)
ffffffe000202b84:	1540006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202b88:	f5043783          	ld	a5,-176(s0)
ffffffe000202b8c:	0007c783          	lbu	a5,0(a5)
ffffffe000202b90:	00078713          	mv	a4,a5
ffffffe000202b94:	07300793          	li	a5,115
ffffffe000202b98:	04f71063          	bne	a4,a5,ffffffe000202bd8 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202b9c:	f4843783          	ld	a5,-184(s0)
ffffffe000202ba0:	00878713          	addi	a4,a5,8
ffffffe000202ba4:	f4e43423          	sd	a4,-184(s0)
ffffffe000202ba8:	0007b783          	ld	a5,0(a5)
ffffffe000202bac:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000202bb0:	fc043583          	ld	a1,-64(s0)
ffffffe000202bb4:	f5843503          	ld	a0,-168(s0)
ffffffe000202bb8:	dd8ff0ef          	jal	ra,ffffffe000202190 <puts_wo_nl>
ffffffe000202bbc:	00050793          	mv	a5,a0
ffffffe000202bc0:	00078713          	mv	a4,a5
ffffffe000202bc4:	fec42783          	lw	a5,-20(s0)
ffffffe000202bc8:	00e787bb          	addw	a5,a5,a4
ffffffe000202bcc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202bd0:	f8040023          	sb	zero,-128(s0)
ffffffe000202bd4:	1040006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202bd8:	f5043783          	ld	a5,-176(s0)
ffffffe000202bdc:	0007c783          	lbu	a5,0(a5)
ffffffe000202be0:	00078713          	mv	a4,a5
ffffffe000202be4:	06300793          	li	a5,99
ffffffe000202be8:	02f71e63          	bne	a4,a5,ffffffe000202c24 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202bec:	f4843783          	ld	a5,-184(s0)
ffffffe000202bf0:	00878713          	addi	a4,a5,8
ffffffe000202bf4:	f4e43423          	sd	a4,-184(s0)
ffffffe000202bf8:	0007a783          	lw	a5,0(a5)
ffffffe000202bfc:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202c00:	fcc42783          	lw	a5,-52(s0)
ffffffe000202c04:	f5843703          	ld	a4,-168(s0)
ffffffe000202c08:	00078513          	mv	a0,a5
ffffffe000202c0c:	000700e7          	jalr	a4
                ++written;
ffffffe000202c10:	fec42783          	lw	a5,-20(s0)
ffffffe000202c14:	0017879b          	addiw	a5,a5,1
ffffffe000202c18:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202c1c:	f8040023          	sb	zero,-128(s0)
ffffffe000202c20:	0b80006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202c24:	f5043783          	ld	a5,-176(s0)
ffffffe000202c28:	0007c783          	lbu	a5,0(a5)
ffffffe000202c2c:	00078713          	mv	a4,a5
ffffffe000202c30:	02500793          	li	a5,37
ffffffe000202c34:	02f71263          	bne	a4,a5,ffffffe000202c58 <vprintfmt+0x740>
                putch('%');
ffffffe000202c38:	f5843783          	ld	a5,-168(s0)
ffffffe000202c3c:	02500513          	li	a0,37
ffffffe000202c40:	000780e7          	jalr	a5
                ++written;
ffffffe000202c44:	fec42783          	lw	a5,-20(s0)
ffffffe000202c48:	0017879b          	addiw	a5,a5,1
ffffffe000202c4c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202c50:	f8040023          	sb	zero,-128(s0)
ffffffe000202c54:	0840006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000202c58:	f5043783          	ld	a5,-176(s0)
ffffffe000202c5c:	0007c783          	lbu	a5,0(a5)
ffffffe000202c60:	0007879b          	sext.w	a5,a5
ffffffe000202c64:	f5843703          	ld	a4,-168(s0)
ffffffe000202c68:	00078513          	mv	a0,a5
ffffffe000202c6c:	000700e7          	jalr	a4
                ++written;
ffffffe000202c70:	fec42783          	lw	a5,-20(s0)
ffffffe000202c74:	0017879b          	addiw	a5,a5,1
ffffffe000202c78:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202c7c:	f8040023          	sb	zero,-128(s0)
ffffffe000202c80:	0580006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202c84:	f5043783          	ld	a5,-176(s0)
ffffffe000202c88:	0007c783          	lbu	a5,0(a5)
ffffffe000202c8c:	00078713          	mv	a4,a5
ffffffe000202c90:	02500793          	li	a5,37
ffffffe000202c94:	02f71063          	bne	a4,a5,ffffffe000202cb4 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202c98:	f8043023          	sd	zero,-128(s0)
ffffffe000202c9c:	f8043423          	sd	zero,-120(s0)
ffffffe000202ca0:	00100793          	li	a5,1
ffffffe000202ca4:	f8f40023          	sb	a5,-128(s0)
ffffffe000202ca8:	fff00793          	li	a5,-1
ffffffe000202cac:	f8f42623          	sw	a5,-116(s0)
ffffffe000202cb0:	0280006f          	j	ffffffe000202cd8 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202cb4:	f5043783          	ld	a5,-176(s0)
ffffffe000202cb8:	0007c783          	lbu	a5,0(a5)
ffffffe000202cbc:	0007879b          	sext.w	a5,a5
ffffffe000202cc0:	f5843703          	ld	a4,-168(s0)
ffffffe000202cc4:	00078513          	mv	a0,a5
ffffffe000202cc8:	000700e7          	jalr	a4
            ++written;
ffffffe000202ccc:	fec42783          	lw	a5,-20(s0)
ffffffe000202cd0:	0017879b          	addiw	a5,a5,1
ffffffe000202cd4:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202cd8:	f5043783          	ld	a5,-176(s0)
ffffffe000202cdc:	00178793          	addi	a5,a5,1
ffffffe000202ce0:	f4f43823          	sd	a5,-176(s0)
ffffffe000202ce4:	f5043783          	ld	a5,-176(s0)
ffffffe000202ce8:	0007c783          	lbu	a5,0(a5)
ffffffe000202cec:	84079ce3          	bnez	a5,ffffffe000202544 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202cf0:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202cf4:	00078513          	mv	a0,a5
ffffffe000202cf8:	0b813083          	ld	ra,184(sp)
ffffffe000202cfc:	0b013403          	ld	s0,176(sp)
ffffffe000202d00:	0c010113          	addi	sp,sp,192
ffffffe000202d04:	00008067          	ret

ffffffe000202d08 <printk>:

int printk(const char* s, ...) {
ffffffe000202d08:	f9010113          	addi	sp,sp,-112
ffffffe000202d0c:	02113423          	sd	ra,40(sp)
ffffffe000202d10:	02813023          	sd	s0,32(sp)
ffffffe000202d14:	03010413          	addi	s0,sp,48
ffffffe000202d18:	fca43c23          	sd	a0,-40(s0)
ffffffe000202d1c:	00b43423          	sd	a1,8(s0)
ffffffe000202d20:	00c43823          	sd	a2,16(s0)
ffffffe000202d24:	00d43c23          	sd	a3,24(s0)
ffffffe000202d28:	02e43023          	sd	a4,32(s0)
ffffffe000202d2c:	02f43423          	sd	a5,40(s0)
ffffffe000202d30:	03043823          	sd	a6,48(s0)
ffffffe000202d34:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000202d38:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000202d3c:	04040793          	addi	a5,s0,64
ffffffe000202d40:	fcf43823          	sd	a5,-48(s0)
ffffffe000202d44:	fd043783          	ld	a5,-48(s0)
ffffffe000202d48:	fc878793          	addi	a5,a5,-56
ffffffe000202d4c:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000202d50:	fe043783          	ld	a5,-32(s0)
ffffffe000202d54:	00078613          	mv	a2,a5
ffffffe000202d58:	fd843583          	ld	a1,-40(s0)
ffffffe000202d5c:	fffff517          	auipc	a0,0xfffff
ffffffe000202d60:	12450513          	addi	a0,a0,292 # ffffffe000201e80 <putc>
ffffffe000202d64:	fb4ff0ef          	jal	ra,ffffffe000202518 <vprintfmt>
ffffffe000202d68:	00050793          	mv	a5,a0
ffffffe000202d6c:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202d70:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202d74:	00078513          	mv	a0,a5
ffffffe000202d78:	02813083          	ld	ra,40(sp)
ffffffe000202d7c:	02013403          	ld	s0,32(sp)
ffffffe000202d80:	07010113          	addi	sp,sp,112
ffffffe000202d84:	00008067          	ret

ffffffe000202d88 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202d88:	fe010113          	addi	sp,sp,-32
ffffffe000202d8c:	00813c23          	sd	s0,24(sp)
ffffffe000202d90:	02010413          	addi	s0,sp,32
ffffffe000202d94:	00050793          	mv	a5,a0
ffffffe000202d98:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202d9c:	fec42783          	lw	a5,-20(s0)
ffffffe000202da0:	fff7879b          	addiw	a5,a5,-1
ffffffe000202da4:	0007879b          	sext.w	a5,a5
ffffffe000202da8:	02079713          	slli	a4,a5,0x20
ffffffe000202dac:	02075713          	srli	a4,a4,0x20
ffffffe000202db0:	00004797          	auipc	a5,0x4
ffffffe000202db4:	25078793          	addi	a5,a5,592 # ffffffe000207000 <seed>
ffffffe000202db8:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202dbc:	00000013          	nop
ffffffe000202dc0:	01813403          	ld	s0,24(sp)
ffffffe000202dc4:	02010113          	addi	sp,sp,32
ffffffe000202dc8:	00008067          	ret

ffffffe000202dcc <rand>:

int rand(void) {
ffffffe000202dcc:	ff010113          	addi	sp,sp,-16
ffffffe000202dd0:	00813423          	sd	s0,8(sp)
ffffffe000202dd4:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202dd8:	00004797          	auipc	a5,0x4
ffffffe000202ddc:	22878793          	addi	a5,a5,552 # ffffffe000207000 <seed>
ffffffe000202de0:	0007b703          	ld	a4,0(a5)
ffffffe000202de4:	00000797          	auipc	a5,0x0
ffffffe000202de8:	4ac78793          	addi	a5,a5,1196 # ffffffe000203290 <lowerxdigits.1100+0x18>
ffffffe000202dec:	0007b783          	ld	a5,0(a5)
ffffffe000202df0:	02f707b3          	mul	a5,a4,a5
ffffffe000202df4:	00178713          	addi	a4,a5,1
ffffffe000202df8:	00004797          	auipc	a5,0x4
ffffffe000202dfc:	20878793          	addi	a5,a5,520 # ffffffe000207000 <seed>
ffffffe000202e00:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202e04:	00004797          	auipc	a5,0x4
ffffffe000202e08:	1fc78793          	addi	a5,a5,508 # ffffffe000207000 <seed>
ffffffe000202e0c:	0007b783          	ld	a5,0(a5)
ffffffe000202e10:	0217d793          	srli	a5,a5,0x21
ffffffe000202e14:	0007879b          	sext.w	a5,a5
}
ffffffe000202e18:	00078513          	mv	a0,a5
ffffffe000202e1c:	00813403          	ld	s0,8(sp)
ffffffe000202e20:	01010113          	addi	sp,sp,16
ffffffe000202e24:	00008067          	ret

ffffffe000202e28 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000202e28:	fc010113          	addi	sp,sp,-64
ffffffe000202e2c:	02813c23          	sd	s0,56(sp)
ffffffe000202e30:	04010413          	addi	s0,sp,64
ffffffe000202e34:	fca43c23          	sd	a0,-40(s0)
ffffffe000202e38:	00058793          	mv	a5,a1
ffffffe000202e3c:	fcc43423          	sd	a2,-56(s0)
ffffffe000202e40:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000202e44:	fd843783          	ld	a5,-40(s0)
ffffffe000202e48:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202e4c:	fe043423          	sd	zero,-24(s0)
ffffffe000202e50:	0280006f          	j	ffffffe000202e78 <memset+0x50>
        s[i] = c;
ffffffe000202e54:	fe043703          	ld	a4,-32(s0)
ffffffe000202e58:	fe843783          	ld	a5,-24(s0)
ffffffe000202e5c:	00f707b3          	add	a5,a4,a5
ffffffe000202e60:	fd442703          	lw	a4,-44(s0)
ffffffe000202e64:	0ff77713          	andi	a4,a4,255
ffffffe000202e68:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202e6c:	fe843783          	ld	a5,-24(s0)
ffffffe000202e70:	00178793          	addi	a5,a5,1
ffffffe000202e74:	fef43423          	sd	a5,-24(s0)
ffffffe000202e78:	fe843703          	ld	a4,-24(s0)
ffffffe000202e7c:	fc843783          	ld	a5,-56(s0)
ffffffe000202e80:	fcf76ae3          	bltu	a4,a5,ffffffe000202e54 <memset+0x2c>
    }
    return dest;
ffffffe000202e84:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202e88:	00078513          	mv	a0,a5
ffffffe000202e8c:	03813403          	ld	s0,56(sp)
ffffffe000202e90:	04010113          	addi	sp,sp,64
ffffffe000202e94:	00008067          	ret
