
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
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    
    # set stvec = _traps
    la t0,_traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
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
    8020002c:	284000ef          	jal	ra,802002b0 <sbi_set_timer>

    # set sstatus[SIE]=1
    li t0,(1<<1)
    80200030:	00200293          	li	t0,2
    csrs sstatus,t0
    80200034:	1002a073          	csrs	sstatus,t0
    
    j start_kernel       # 跳转到 main.c 中的 start_kernel
    80200038:	4dc0006f          	j	80200514 <start_kernel>

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
    802000d0:	3b0000ef          	jal	ra,80200480 <trap_handler>

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
    802001bc:	0f4000ef          	jal	ra,802002b0 <sbi_set_timer>
    802001c0:	00000013          	nop
    802001c4:	01813083          	ld	ra,24(sp)
    802001c8:	01013403          	ld	s0,16(sp)
    802001cc:	02010113          	addi	sp,sp,32
    802001d0:	00008067          	ret

00000000802001d4 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001d4:	f8010113          	addi	sp,sp,-128
    802001d8:	06813c23          	sd	s0,120(sp)
    802001dc:	06913823          	sd	s1,112(sp)
    802001e0:	07213423          	sd	s2,104(sp)
    802001e4:	07313023          	sd	s3,96(sp)
    802001e8:	08010413          	addi	s0,sp,128
    802001ec:	faa43c23          	sd	a0,-72(s0)
    802001f0:	fab43823          	sd	a1,-80(s0)
    802001f4:	fac43423          	sd	a2,-88(s0)
    802001f8:	fad43023          	sd	a3,-96(s0)
    802001fc:	f8e43c23          	sd	a4,-104(s0)
    80200200:	f8f43823          	sd	a5,-112(s0)
    80200204:	f9043423          	sd	a6,-120(s0)
    80200208:	f9143023          	sd	a7,-128(s0)
    struct sbiret  ret;
    asm volatile(
    8020020c:	fb843e03          	ld	t3,-72(s0)
    80200210:	fb043e83          	ld	t4,-80(s0)
    80200214:	fa843f03          	ld	t5,-88(s0)
    80200218:	fa043f83          	ld	t6,-96(s0)
    8020021c:	f9843283          	ld	t0,-104(s0)
    80200220:	f9043483          	ld	s1,-112(s0)
    80200224:	f8843903          	ld	s2,-120(s0)
    80200228:	f8043983          	ld	s3,-128(s0)
    8020022c:	000e0893          	mv	a7,t3
    80200230:	000e8813          	mv	a6,t4
    80200234:	000f0513          	mv	a0,t5
    80200238:	000f8593          	mv	a1,t6
    8020023c:	00028613          	mv	a2,t0
    80200240:	00048693          	mv	a3,s1
    80200244:	00090713          	mv	a4,s2
    80200248:	00098793          	mv	a5,s3
    8020024c:	00000073          	ecall
    80200250:	00050e93          	mv	t4,a0
    80200254:	00058e13          	mv	t3,a1
    80200258:	fdd43023          	sd	t4,-64(s0)
    8020025c:	fdc43423          	sd	t3,-56(s0)
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
        //破坏描述符
        :"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7","memory"
    );

    return ret;
    80200260:	fc043783          	ld	a5,-64(s0)
    80200264:	fcf43823          	sd	a5,-48(s0)
    80200268:	fc843783          	ld	a5,-56(s0)
    8020026c:	fcf43c23          	sd	a5,-40(s0)
    80200270:	00000713          	li	a4,0
    80200274:	fd043703          	ld	a4,-48(s0)
    80200278:	00000793          	li	a5,0
    8020027c:	fd843783          	ld	a5,-40(s0)
    80200280:	00070313          	mv	t1,a4
    80200284:	00078393          	mv	t2,a5
    80200288:	00030713          	mv	a4,t1
    8020028c:	00038793          	mv	a5,t2
}
    80200290:	00070513          	mv	a0,a4
    80200294:	00078593          	mv	a1,a5
    80200298:	07813403          	ld	s0,120(sp)
    8020029c:	07013483          	ld	s1,112(sp)
    802002a0:	06813903          	ld	s2,104(sp)
    802002a4:	06013983          	ld	s3,96(sp)
    802002a8:	08010113          	addi	sp,sp,128
    802002ac:	00008067          	ret

00000000802002b0 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    802002b0:	fc010113          	addi	sp,sp,-64
    802002b4:	02113c23          	sd	ra,56(sp)
    802002b8:	02813823          	sd	s0,48(sp)
    802002bc:	03213423          	sd	s2,40(sp)
    802002c0:	03313023          	sd	s3,32(sp)
    802002c4:	04010413          	addi	s0,sp,64
    802002c8:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45,0,stime_value,0,0,0,0,0);
    802002cc:	00000893          	li	a7,0
    802002d0:	00000813          	li	a6,0
    802002d4:	00000793          	li	a5,0
    802002d8:	00000713          	li	a4,0
    802002dc:	00000693          	li	a3,0
    802002e0:	fc843603          	ld	a2,-56(s0)
    802002e4:	00000593          	li	a1,0
    802002e8:	54495537          	lui	a0,0x54495
    802002ec:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    802002f0:	ee5ff0ef          	jal	ra,802001d4 <sbi_ecall>
    802002f4:	00050713          	mv	a4,a0
    802002f8:	00058793          	mv	a5,a1
    802002fc:	fce43823          	sd	a4,-48(s0)
    80200300:	fcf43c23          	sd	a5,-40(s0)
    80200304:	00000713          	li	a4,0
    80200308:	fd043703          	ld	a4,-48(s0)
    8020030c:	00000793          	li	a5,0
    80200310:	fd843783          	ld	a5,-40(s0)
    80200314:	00070913          	mv	s2,a4
    80200318:	00078993          	mv	s3,a5
    8020031c:	00090713          	mv	a4,s2
    80200320:	00098793          	mv	a5,s3
}
    80200324:	00070513          	mv	a0,a4
    80200328:	00078593          	mv	a1,a5
    8020032c:	03813083          	ld	ra,56(sp)
    80200330:	03013403          	ld	s0,48(sp)
    80200334:	02813903          	ld	s2,40(sp)
    80200338:	02013983          	ld	s3,32(sp)
    8020033c:	04010113          	addi	sp,sp,64
    80200340:	00008067          	ret

0000000080200344 <sbi_debug_console_write_byte>:


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200344:	fc010113          	addi	sp,sp,-64
    80200348:	02113c23          	sd	ra,56(sp)
    8020034c:	02813823          	sd	s0,48(sp)
    80200350:	03213423          	sd	s2,40(sp)
    80200354:	03313023          	sd	s3,32(sp)
    80200358:	04010413          	addi	s0,sp,64
    8020035c:	00050793          	mv	a5,a0
    80200360:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e,0x2,byte,0,0,0,0,0);
    80200364:	fcf44603          	lbu	a2,-49(s0)
    80200368:	00000893          	li	a7,0
    8020036c:	00000813          	li	a6,0
    80200370:	00000793          	li	a5,0
    80200374:	00000713          	li	a4,0
    80200378:	00000693          	li	a3,0
    8020037c:	00200593          	li	a1,2
    80200380:	44424537          	lui	a0,0x44424
    80200384:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200388:	e4dff0ef          	jal	ra,802001d4 <sbi_ecall>
    8020038c:	00050713          	mv	a4,a0
    80200390:	00058793          	mv	a5,a1
    80200394:	fce43823          	sd	a4,-48(s0)
    80200398:	fcf43c23          	sd	a5,-40(s0)
    8020039c:	00000713          	li	a4,0
    802003a0:	fd043703          	ld	a4,-48(s0)
    802003a4:	00000793          	li	a5,0
    802003a8:	fd843783          	ld	a5,-40(s0)
    802003ac:	00070913          	mv	s2,a4
    802003b0:	00078993          	mv	s3,a5
    802003b4:	00090713          	mv	a4,s2
    802003b8:	00098793          	mv	a5,s3
}
    802003bc:	00070513          	mv	a0,a4
    802003c0:	00078593          	mv	a1,a5
    802003c4:	03813083          	ld	ra,56(sp)
    802003c8:	03013403          	ld	s0,48(sp)
    802003cc:	02813903          	ld	s2,40(sp)
    802003d0:	02013983          	ld	s3,32(sp)
    802003d4:	04010113          	addi	sp,sp,64
    802003d8:	00008067          	ret

00000000802003dc <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    802003dc:	fc010113          	addi	sp,sp,-64
    802003e0:	02113c23          	sd	ra,56(sp)
    802003e4:	02813823          	sd	s0,48(sp)
    802003e8:	03213423          	sd	s2,40(sp)
    802003ec:	03313023          	sd	s3,32(sp)
    802003f0:	04010413          	addi	s0,sp,64
    802003f4:	00050793          	mv	a5,a0
    802003f8:	00058713          	mv	a4,a1
    802003fc:	fcf42623          	sw	a5,-52(s0)
    80200400:	00070793          	mv	a5,a4
    80200404:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354,0,reset_type,reset_reason,0,0,0,0);
    80200408:	fcc46603          	lwu	a2,-52(s0)
    8020040c:	fc846683          	lwu	a3,-56(s0)
    80200410:	00000893          	li	a7,0
    80200414:	00000813          	li	a6,0
    80200418:	00000793          	li	a5,0
    8020041c:	00000713          	li	a4,0
    80200420:	00000593          	li	a1,0
    80200424:	53525537          	lui	a0,0x53525
    80200428:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    8020042c:	da9ff0ef          	jal	ra,802001d4 <sbi_ecall>
    80200430:	00050713          	mv	a4,a0
    80200434:	00058793          	mv	a5,a1
    80200438:	fce43823          	sd	a4,-48(s0)
    8020043c:	fcf43c23          	sd	a5,-40(s0)
    80200440:	00000713          	li	a4,0
    80200444:	fd043703          	ld	a4,-48(s0)
    80200448:	00000793          	li	a5,0
    8020044c:	fd843783          	ld	a5,-40(s0)
    80200450:	00070913          	mv	s2,a4
    80200454:	00078993          	mv	s3,a5
    80200458:	00090713          	mv	a4,s2
    8020045c:	00098793          	mv	a5,s3
    80200460:	00070513          	mv	a0,a4
    80200464:	00078593          	mv	a1,a5
    80200468:	03813083          	ld	ra,56(sp)
    8020046c:	03013403          	ld	s0,48(sp)
    80200470:	02813903          	ld	s2,40(sp)
    80200474:	02013983          	ld	s3,32(sp)
    80200478:	04010113          	addi	sp,sp,64
    8020047c:	00008067          	ret

0000000080200480 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200480:	fd010113          	addi	sp,sp,-48
    80200484:	02113423          	sd	ra,40(sp)
    80200488:	02813023          	sd	s0,32(sp)
    8020048c:	03010413          	addi	s0,sp,48
    80200490:	fca43c23          	sd	a0,-40(s0)
    80200494:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型,最高位为1
    if(scause & (1ULL << 63)) {
    80200498:	fd843783          	ld	a5,-40(s0)
    8020049c:	0407d663          	bgez	a5,802004e8 <trap_handler+0x68>
        uint64_t interrupt_code = scause & ~(1UL << 63);
    802004a0:	fd843703          	ld	a4,-40(s0)
    802004a4:	fff00793          	li	a5,-1
    802004a8:	0017d793          	srli	a5,a5,0x1
    802004ac:	00f777b3          	and	a5,a4,a5
    802004b0:	fef43023          	sd	a5,-32(s0)
        // 如果是 interrupt 判断是否是 timer interrupt
        // 如果是 timer interrupt 则打印输出相关信息，
        // 通过 `clock_set_next_event()` 设置下一次时钟中断
        if(interrupt_code == 5) {
    802004b4:	fe043703          	ld	a4,-32(s0)
    802004b8:	00500793          	li	a5,5
    802004bc:	00f71c63          	bne	a4,a5,802004d4 <trap_handler+0x54>
            printk("[S] Supervisor Mode TImer Interrupt\n");
    802004c0:	00002517          	auipc	a0,0x2
    802004c4:	b4050513          	addi	a0,a0,-1216 # 80202000 <_srodata>
    802004c8:	765000ef          	jal	ra,8020142c <printk>
            clock_set_next_event();
    802004cc:	cc1ff0ef          	jal	ra,8020018c <clock_set_next_event>
        }
    } else {
        uint64_t exception_code = scause;
        printk("exception: %d\n", exception_code);
    }   
    802004d0:	0300006f          	j	80200500 <trap_handler+0x80>
            printk("other interrupt: %d\n", interrupt_code);
    802004d4:	fe043583          	ld	a1,-32(s0)
    802004d8:	00002517          	auipc	a0,0x2
    802004dc:	b5050513          	addi	a0,a0,-1200 # 80202028 <_srodata+0x28>
    802004e0:	74d000ef          	jal	ra,8020142c <printk>
    802004e4:	01c0006f          	j	80200500 <trap_handler+0x80>
        uint64_t exception_code = scause;
    802004e8:	fd843783          	ld	a5,-40(s0)
    802004ec:	fef43423          	sd	a5,-24(s0)
        printk("exception: %d\n", exception_code);
    802004f0:	fe843583          	ld	a1,-24(s0)
    802004f4:	00002517          	auipc	a0,0x2
    802004f8:	b4c50513          	addi	a0,a0,-1204 # 80202040 <_srodata+0x40>
    802004fc:	731000ef          	jal	ra,8020142c <printk>
    80200500:	00000013          	nop
    80200504:	02813083          	ld	ra,40(sp)
    80200508:	02013403          	ld	s0,32(sp)
    8020050c:	03010113          	addi	sp,sp,48
    80200510:	00008067          	ret

0000000080200514 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    80200514:	ff010113          	addi	sp,sp,-16
    80200518:	00113423          	sd	ra,8(sp)
    8020051c:	00813023          	sd	s0,0(sp)
    80200520:	01010413          	addi	s0,sp,16
    printk("2024");
    80200524:	00002517          	auipc	a0,0x2
    80200528:	b2c50513          	addi	a0,a0,-1236 # 80202050 <_srodata+0x50>
    8020052c:	701000ef          	jal	ra,8020142c <printk>
    printk(" ZJU Operating System\n");
    80200530:	00002517          	auipc	a0,0x2
    80200534:	b2850513          	addi	a0,a0,-1240 # 80202058 <_srodata+0x58>
    80200538:	6f5000ef          	jal	ra,8020142c <printk>
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
    8020053c:	01c000ef          	jal	ra,80200558 <test>
    return 0;
    80200540:	00000793          	li	a5,0
}
    80200544:	00078513          	mv	a0,a5
    80200548:	00813083          	ld	ra,8(sp)
    8020054c:	00013403          	ld	s0,0(sp)
    80200550:	01010113          	addi	sp,sp,16
    80200554:	00008067          	ret

0000000080200558 <test>:
//     __builtin_unreachable();
// }
#include "printk.h"
#include "defs.h"

void test() {
    80200558:	fe010113          	addi	sp,sp,-32
    8020055c:	00113c23          	sd	ra,24(sp)
    80200560:	00813823          	sd	s0,16(sp)
    80200564:	02010413          	addi	s0,sp,32
    // printk("sstatus = 0x%lx\n", csr_read(sstatus));
    int i = 0;
    80200568:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    8020056c:	fec42783          	lw	a5,-20(s0)
    80200570:	0017879b          	addiw	a5,a5,1
    80200574:	fef42623          	sw	a5,-20(s0)
    80200578:	fec42703          	lw	a4,-20(s0)
    8020057c:	05f5e7b7          	lui	a5,0x5f5e
    80200580:	1007879b          	addiw	a5,a5,256
    80200584:	02f767bb          	remw	a5,a4,a5
    80200588:	0007879b          	sext.w	a5,a5
    8020058c:	fe0790e3          	bnez	a5,8020056c <test+0x14>
            // printk("sstatus = 0x%lx\n", csr_read(sstatus));
            printk("kernel is running!\n");
    80200590:	00002517          	auipc	a0,0x2
    80200594:	ae050513          	addi	a0,a0,-1312 # 80202070 <_srodata+0x70>
    80200598:	695000ef          	jal	ra,8020142c <printk>
            i = 0;
    8020059c:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    802005a0:	fcdff06f          	j	8020056c <test+0x14>

00000000802005a4 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    802005a4:	fe010113          	addi	sp,sp,-32
    802005a8:	00113c23          	sd	ra,24(sp)
    802005ac:	00813823          	sd	s0,16(sp)
    802005b0:	02010413          	addi	s0,sp,32
    802005b4:	00050793          	mv	a5,a0
    802005b8:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    802005bc:	fec42783          	lw	a5,-20(s0)
    802005c0:	0ff7f793          	andi	a5,a5,255
    802005c4:	00078513          	mv	a0,a5
    802005c8:	d7dff0ef          	jal	ra,80200344 <sbi_debug_console_write_byte>
    return (char)c;
    802005cc:	fec42783          	lw	a5,-20(s0)
    802005d0:	0ff7f793          	andi	a5,a5,255
    802005d4:	0007879b          	sext.w	a5,a5
}
    802005d8:	00078513          	mv	a0,a5
    802005dc:	01813083          	ld	ra,24(sp)
    802005e0:	01013403          	ld	s0,16(sp)
    802005e4:	02010113          	addi	sp,sp,32
    802005e8:	00008067          	ret

00000000802005ec <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    802005ec:	fe010113          	addi	sp,sp,-32
    802005f0:	00813c23          	sd	s0,24(sp)
    802005f4:	02010413          	addi	s0,sp,32
    802005f8:	00050793          	mv	a5,a0
    802005fc:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200600:	fec42783          	lw	a5,-20(s0)
    80200604:	0007871b          	sext.w	a4,a5
    80200608:	02000793          	li	a5,32
    8020060c:	02f70263          	beq	a4,a5,80200630 <isspace+0x44>
    80200610:	fec42783          	lw	a5,-20(s0)
    80200614:	0007871b          	sext.w	a4,a5
    80200618:	00800793          	li	a5,8
    8020061c:	00e7de63          	bge	a5,a4,80200638 <isspace+0x4c>
    80200620:	fec42783          	lw	a5,-20(s0)
    80200624:	0007871b          	sext.w	a4,a5
    80200628:	00d00793          	li	a5,13
    8020062c:	00e7c663          	blt	a5,a4,80200638 <isspace+0x4c>
    80200630:	00100793          	li	a5,1
    80200634:	0080006f          	j	8020063c <isspace+0x50>
    80200638:	00000793          	li	a5,0
}
    8020063c:	00078513          	mv	a0,a5
    80200640:	01813403          	ld	s0,24(sp)
    80200644:	02010113          	addi	sp,sp,32
    80200648:	00008067          	ret

000000008020064c <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    8020064c:	fb010113          	addi	sp,sp,-80
    80200650:	04113423          	sd	ra,72(sp)
    80200654:	04813023          	sd	s0,64(sp)
    80200658:	05010413          	addi	s0,sp,80
    8020065c:	fca43423          	sd	a0,-56(s0)
    80200660:	fcb43023          	sd	a1,-64(s0)
    80200664:	00060793          	mv	a5,a2
    80200668:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    8020066c:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200670:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200674:	fc843783          	ld	a5,-56(s0)
    80200678:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    8020067c:	0100006f          	j	8020068c <strtol+0x40>
        p++;
    80200680:	fd843783          	ld	a5,-40(s0)
    80200684:	00178793          	addi	a5,a5,1 # 5f5e001 <_skernel-0x7a2a1fff>
    80200688:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    8020068c:	fd843783          	ld	a5,-40(s0)
    80200690:	0007c783          	lbu	a5,0(a5)
    80200694:	0007879b          	sext.w	a5,a5
    80200698:	00078513          	mv	a0,a5
    8020069c:	f51ff0ef          	jal	ra,802005ec <isspace>
    802006a0:	00050793          	mv	a5,a0
    802006a4:	fc079ee3          	bnez	a5,80200680 <strtol+0x34>
    }

    if (*p == '-') {
    802006a8:	fd843783          	ld	a5,-40(s0)
    802006ac:	0007c783          	lbu	a5,0(a5)
    802006b0:	00078713          	mv	a4,a5
    802006b4:	02d00793          	li	a5,45
    802006b8:	00f71e63          	bne	a4,a5,802006d4 <strtol+0x88>
        neg = true;
    802006bc:	00100793          	li	a5,1
    802006c0:	fef403a3          	sb	a5,-25(s0)
        p++;
    802006c4:	fd843783          	ld	a5,-40(s0)
    802006c8:	00178793          	addi	a5,a5,1
    802006cc:	fcf43c23          	sd	a5,-40(s0)
    802006d0:	0240006f          	j	802006f4 <strtol+0xa8>
    } else if (*p == '+') {
    802006d4:	fd843783          	ld	a5,-40(s0)
    802006d8:	0007c783          	lbu	a5,0(a5)
    802006dc:	00078713          	mv	a4,a5
    802006e0:	02b00793          	li	a5,43
    802006e4:	00f71863          	bne	a4,a5,802006f4 <strtol+0xa8>
        p++;
    802006e8:	fd843783          	ld	a5,-40(s0)
    802006ec:	00178793          	addi	a5,a5,1
    802006f0:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    802006f4:	fbc42783          	lw	a5,-68(s0)
    802006f8:	0007879b          	sext.w	a5,a5
    802006fc:	06079c63          	bnez	a5,80200774 <strtol+0x128>
        if (*p == '0') {
    80200700:	fd843783          	ld	a5,-40(s0)
    80200704:	0007c783          	lbu	a5,0(a5)
    80200708:	00078713          	mv	a4,a5
    8020070c:	03000793          	li	a5,48
    80200710:	04f71e63          	bne	a4,a5,8020076c <strtol+0x120>
            p++;
    80200714:	fd843783          	ld	a5,-40(s0)
    80200718:	00178793          	addi	a5,a5,1
    8020071c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200720:	fd843783          	ld	a5,-40(s0)
    80200724:	0007c783          	lbu	a5,0(a5)
    80200728:	00078713          	mv	a4,a5
    8020072c:	07800793          	li	a5,120
    80200730:	00f70c63          	beq	a4,a5,80200748 <strtol+0xfc>
    80200734:	fd843783          	ld	a5,-40(s0)
    80200738:	0007c783          	lbu	a5,0(a5)
    8020073c:	00078713          	mv	a4,a5
    80200740:	05800793          	li	a5,88
    80200744:	00f71e63          	bne	a4,a5,80200760 <strtol+0x114>
                base = 16;
    80200748:	01000793          	li	a5,16
    8020074c:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200750:	fd843783          	ld	a5,-40(s0)
    80200754:	00178793          	addi	a5,a5,1
    80200758:	fcf43c23          	sd	a5,-40(s0)
    8020075c:	0180006f          	j	80200774 <strtol+0x128>
            } else {
                base = 8;
    80200760:	00800793          	li	a5,8
    80200764:	faf42e23          	sw	a5,-68(s0)
    80200768:	00c0006f          	j	80200774 <strtol+0x128>
            }
        } else {
            base = 10;
    8020076c:	00a00793          	li	a5,10
    80200770:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200774:	fd843783          	ld	a5,-40(s0)
    80200778:	0007c783          	lbu	a5,0(a5)
    8020077c:	00078713          	mv	a4,a5
    80200780:	02f00793          	li	a5,47
    80200784:	02e7f863          	bgeu	a5,a4,802007b4 <strtol+0x168>
    80200788:	fd843783          	ld	a5,-40(s0)
    8020078c:	0007c783          	lbu	a5,0(a5)
    80200790:	00078713          	mv	a4,a5
    80200794:	03900793          	li	a5,57
    80200798:	00e7ee63          	bltu	a5,a4,802007b4 <strtol+0x168>
            digit = *p - '0';
    8020079c:	fd843783          	ld	a5,-40(s0)
    802007a0:	0007c783          	lbu	a5,0(a5)
    802007a4:	0007879b          	sext.w	a5,a5
    802007a8:	fd07879b          	addiw	a5,a5,-48
    802007ac:	fcf42a23          	sw	a5,-44(s0)
    802007b0:	0800006f          	j	80200830 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    802007b4:	fd843783          	ld	a5,-40(s0)
    802007b8:	0007c783          	lbu	a5,0(a5)
    802007bc:	00078713          	mv	a4,a5
    802007c0:	06000793          	li	a5,96
    802007c4:	02e7f863          	bgeu	a5,a4,802007f4 <strtol+0x1a8>
    802007c8:	fd843783          	ld	a5,-40(s0)
    802007cc:	0007c783          	lbu	a5,0(a5)
    802007d0:	00078713          	mv	a4,a5
    802007d4:	07a00793          	li	a5,122
    802007d8:	00e7ee63          	bltu	a5,a4,802007f4 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    802007dc:	fd843783          	ld	a5,-40(s0)
    802007e0:	0007c783          	lbu	a5,0(a5)
    802007e4:	0007879b          	sext.w	a5,a5
    802007e8:	fa97879b          	addiw	a5,a5,-87
    802007ec:	fcf42a23          	sw	a5,-44(s0)
    802007f0:	0400006f          	j	80200830 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    802007f4:	fd843783          	ld	a5,-40(s0)
    802007f8:	0007c783          	lbu	a5,0(a5)
    802007fc:	00078713          	mv	a4,a5
    80200800:	04000793          	li	a5,64
    80200804:	06e7f663          	bgeu	a5,a4,80200870 <strtol+0x224>
    80200808:	fd843783          	ld	a5,-40(s0)
    8020080c:	0007c783          	lbu	a5,0(a5)
    80200810:	00078713          	mv	a4,a5
    80200814:	05a00793          	li	a5,90
    80200818:	04e7ec63          	bltu	a5,a4,80200870 <strtol+0x224>
            digit = *p - ('A' - 10);
    8020081c:	fd843783          	ld	a5,-40(s0)
    80200820:	0007c783          	lbu	a5,0(a5)
    80200824:	0007879b          	sext.w	a5,a5
    80200828:	fc97879b          	addiw	a5,a5,-55
    8020082c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200830:	fd442703          	lw	a4,-44(s0)
    80200834:	fbc42783          	lw	a5,-68(s0)
    80200838:	0007071b          	sext.w	a4,a4
    8020083c:	0007879b          	sext.w	a5,a5
    80200840:	02f75663          	bge	a4,a5,8020086c <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
    80200844:	fbc42703          	lw	a4,-68(s0)
    80200848:	fe843783          	ld	a5,-24(s0)
    8020084c:	02f70733          	mul	a4,a4,a5
    80200850:	fd442783          	lw	a5,-44(s0)
    80200854:	00f707b3          	add	a5,a4,a5
    80200858:	fef43423          	sd	a5,-24(s0)
        p++;
    8020085c:	fd843783          	ld	a5,-40(s0)
    80200860:	00178793          	addi	a5,a5,1
    80200864:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200868:	f0dff06f          	j	80200774 <strtol+0x128>
            break;
    8020086c:	00000013          	nop
    }

    if (endptr) {
    80200870:	fc043783          	ld	a5,-64(s0)
    80200874:	00078863          	beqz	a5,80200884 <strtol+0x238>
        *endptr = (char *)p;
    80200878:	fc043783          	ld	a5,-64(s0)
    8020087c:	fd843703          	ld	a4,-40(s0)
    80200880:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200884:	fe744783          	lbu	a5,-25(s0)
    80200888:	0ff7f793          	andi	a5,a5,255
    8020088c:	00078863          	beqz	a5,8020089c <strtol+0x250>
    80200890:	fe843783          	ld	a5,-24(s0)
    80200894:	40f007b3          	neg	a5,a5
    80200898:	0080006f          	j	802008a0 <strtol+0x254>
    8020089c:	fe843783          	ld	a5,-24(s0)
}
    802008a0:	00078513          	mv	a0,a5
    802008a4:	04813083          	ld	ra,72(sp)
    802008a8:	04013403          	ld	s0,64(sp)
    802008ac:	05010113          	addi	sp,sp,80
    802008b0:	00008067          	ret

00000000802008b4 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    802008b4:	fd010113          	addi	sp,sp,-48
    802008b8:	02113423          	sd	ra,40(sp)
    802008bc:	02813023          	sd	s0,32(sp)
    802008c0:	03010413          	addi	s0,sp,48
    802008c4:	fca43c23          	sd	a0,-40(s0)
    802008c8:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    802008cc:	fd043783          	ld	a5,-48(s0)
    802008d0:	00079863          	bnez	a5,802008e0 <puts_wo_nl+0x2c>
        s = "(null)";
    802008d4:	00001797          	auipc	a5,0x1
    802008d8:	7b478793          	addi	a5,a5,1972 # 80202088 <_srodata+0x88>
    802008dc:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    802008e0:	fd043783          	ld	a5,-48(s0)
    802008e4:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    802008e8:	0240006f          	j	8020090c <puts_wo_nl+0x58>
        putch(*p++);
    802008ec:	fe843783          	ld	a5,-24(s0)
    802008f0:	00178713          	addi	a4,a5,1
    802008f4:	fee43423          	sd	a4,-24(s0)
    802008f8:	0007c783          	lbu	a5,0(a5)
    802008fc:	0007879b          	sext.w	a5,a5
    80200900:	fd843703          	ld	a4,-40(s0)
    80200904:	00078513          	mv	a0,a5
    80200908:	000700e7          	jalr	a4
    while (*p) {
    8020090c:	fe843783          	ld	a5,-24(s0)
    80200910:	0007c783          	lbu	a5,0(a5)
    80200914:	fc079ce3          	bnez	a5,802008ec <puts_wo_nl+0x38>
    }
    return p - s;
    80200918:	fe843703          	ld	a4,-24(s0)
    8020091c:	fd043783          	ld	a5,-48(s0)
    80200920:	40f707b3          	sub	a5,a4,a5
    80200924:	0007879b          	sext.w	a5,a5
}
    80200928:	00078513          	mv	a0,a5
    8020092c:	02813083          	ld	ra,40(sp)
    80200930:	02013403          	ld	s0,32(sp)
    80200934:	03010113          	addi	sp,sp,48
    80200938:	00008067          	ret

000000008020093c <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    8020093c:	f9010113          	addi	sp,sp,-112
    80200940:	06113423          	sd	ra,104(sp)
    80200944:	06813023          	sd	s0,96(sp)
    80200948:	07010413          	addi	s0,sp,112
    8020094c:	faa43423          	sd	a0,-88(s0)
    80200950:	fab43023          	sd	a1,-96(s0)
    80200954:	00060793          	mv	a5,a2
    80200958:	f8d43823          	sd	a3,-112(s0)
    8020095c:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200960:	f9f44783          	lbu	a5,-97(s0)
    80200964:	0ff7f793          	andi	a5,a5,255
    80200968:	02078663          	beqz	a5,80200994 <print_dec_int+0x58>
    8020096c:	fa043703          	ld	a4,-96(s0)
    80200970:	fff00793          	li	a5,-1
    80200974:	03f79793          	slli	a5,a5,0x3f
    80200978:	00f71e63          	bne	a4,a5,80200994 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    8020097c:	00001597          	auipc	a1,0x1
    80200980:	71458593          	addi	a1,a1,1812 # 80202090 <_srodata+0x90>
    80200984:	fa843503          	ld	a0,-88(s0)
    80200988:	f2dff0ef          	jal	ra,802008b4 <puts_wo_nl>
    8020098c:	00050793          	mv	a5,a0
    80200990:	2980006f          	j	80200c28 <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
    80200994:	f9043783          	ld	a5,-112(s0)
    80200998:	00c7a783          	lw	a5,12(a5)
    8020099c:	00079a63          	bnez	a5,802009b0 <print_dec_int+0x74>
    802009a0:	fa043783          	ld	a5,-96(s0)
    802009a4:	00079663          	bnez	a5,802009b0 <print_dec_int+0x74>
        return 0;
    802009a8:	00000793          	li	a5,0
    802009ac:	27c0006f          	j	80200c28 <print_dec_int+0x2ec>
    }

    bool neg = false;
    802009b0:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    802009b4:	f9f44783          	lbu	a5,-97(s0)
    802009b8:	0ff7f793          	andi	a5,a5,255
    802009bc:	02078063          	beqz	a5,802009dc <print_dec_int+0xa0>
    802009c0:	fa043783          	ld	a5,-96(s0)
    802009c4:	0007dc63          	bgez	a5,802009dc <print_dec_int+0xa0>
        neg = true;
    802009c8:	00100793          	li	a5,1
    802009cc:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    802009d0:	fa043783          	ld	a5,-96(s0)
    802009d4:	40f007b3          	neg	a5,a5
    802009d8:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    802009dc:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    802009e0:	f9f44783          	lbu	a5,-97(s0)
    802009e4:	0ff7f793          	andi	a5,a5,255
    802009e8:	02078863          	beqz	a5,80200a18 <print_dec_int+0xdc>
    802009ec:	fef44783          	lbu	a5,-17(s0)
    802009f0:	0ff7f793          	andi	a5,a5,255
    802009f4:	00079e63          	bnez	a5,80200a10 <print_dec_int+0xd4>
    802009f8:	f9043783          	ld	a5,-112(s0)
    802009fc:	0057c783          	lbu	a5,5(a5)
    80200a00:	00079863          	bnez	a5,80200a10 <print_dec_int+0xd4>
    80200a04:	f9043783          	ld	a5,-112(s0)
    80200a08:	0047c783          	lbu	a5,4(a5)
    80200a0c:	00078663          	beqz	a5,80200a18 <print_dec_int+0xdc>
    80200a10:	00100793          	li	a5,1
    80200a14:	0080006f          	j	80200a1c <print_dec_int+0xe0>
    80200a18:	00000793          	li	a5,0
    80200a1c:	fcf40ba3          	sb	a5,-41(s0)
    80200a20:	fd744783          	lbu	a5,-41(s0)
    80200a24:	0017f793          	andi	a5,a5,1
    80200a28:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200a2c:	fa043703          	ld	a4,-96(s0)
    80200a30:	00a00793          	li	a5,10
    80200a34:	02f777b3          	remu	a5,a4,a5
    80200a38:	0ff7f713          	andi	a4,a5,255
    80200a3c:	fe842783          	lw	a5,-24(s0)
    80200a40:	0017869b          	addiw	a3,a5,1
    80200a44:	fed42423          	sw	a3,-24(s0)
    80200a48:	0307071b          	addiw	a4,a4,48
    80200a4c:	0ff77713          	andi	a4,a4,255
    80200a50:	ff040693          	addi	a3,s0,-16
    80200a54:	00f687b3          	add	a5,a3,a5
    80200a58:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200a5c:	fa043703          	ld	a4,-96(s0)
    80200a60:	00a00793          	li	a5,10
    80200a64:	02f757b3          	divu	a5,a4,a5
    80200a68:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200a6c:	fa043783          	ld	a5,-96(s0)
    80200a70:	fa079ee3          	bnez	a5,80200a2c <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200a74:	f9043783          	ld	a5,-112(s0)
    80200a78:	00c7a783          	lw	a5,12(a5)
    80200a7c:	00078713          	mv	a4,a5
    80200a80:	fff00793          	li	a5,-1
    80200a84:	02f71063          	bne	a4,a5,80200aa4 <print_dec_int+0x168>
    80200a88:	f9043783          	ld	a5,-112(s0)
    80200a8c:	0037c783          	lbu	a5,3(a5)
    80200a90:	00078a63          	beqz	a5,80200aa4 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200a94:	f9043783          	ld	a5,-112(s0)
    80200a98:	0087a703          	lw	a4,8(a5)
    80200a9c:	f9043783          	ld	a5,-112(s0)
    80200aa0:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200aa4:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200aa8:	f9043783          	ld	a5,-112(s0)
    80200aac:	0087a703          	lw	a4,8(a5)
    80200ab0:	fe842783          	lw	a5,-24(s0)
    80200ab4:	fcf42823          	sw	a5,-48(s0)
    80200ab8:	f9043783          	ld	a5,-112(s0)
    80200abc:	00c7a783          	lw	a5,12(a5)
    80200ac0:	fcf42623          	sw	a5,-52(s0)
    80200ac4:	fd042583          	lw	a1,-48(s0)
    80200ac8:	fcc42783          	lw	a5,-52(s0)
    80200acc:	0007861b          	sext.w	a2,a5
    80200ad0:	0005869b          	sext.w	a3,a1
    80200ad4:	00d65463          	bge	a2,a3,80200adc <print_dec_int+0x1a0>
    80200ad8:	00058793          	mv	a5,a1
    80200adc:	0007879b          	sext.w	a5,a5
    80200ae0:	40f707bb          	subw	a5,a4,a5
    80200ae4:	0007871b          	sext.w	a4,a5
    80200ae8:	fd744783          	lbu	a5,-41(s0)
    80200aec:	0007879b          	sext.w	a5,a5
    80200af0:	40f707bb          	subw	a5,a4,a5
    80200af4:	fef42023          	sw	a5,-32(s0)
    80200af8:	0280006f          	j	80200b20 <print_dec_int+0x1e4>
        putch(' ');
    80200afc:	fa843783          	ld	a5,-88(s0)
    80200b00:	02000513          	li	a0,32
    80200b04:	000780e7          	jalr	a5
        ++written;
    80200b08:	fe442783          	lw	a5,-28(s0)
    80200b0c:	0017879b          	addiw	a5,a5,1
    80200b10:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b14:	fe042783          	lw	a5,-32(s0)
    80200b18:	fff7879b          	addiw	a5,a5,-1
    80200b1c:	fef42023          	sw	a5,-32(s0)
    80200b20:	fe042783          	lw	a5,-32(s0)
    80200b24:	0007879b          	sext.w	a5,a5
    80200b28:	fcf04ae3          	bgtz	a5,80200afc <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
    80200b2c:	fd744783          	lbu	a5,-41(s0)
    80200b30:	0ff7f793          	andi	a5,a5,255
    80200b34:	04078463          	beqz	a5,80200b7c <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200b38:	fef44783          	lbu	a5,-17(s0)
    80200b3c:	0ff7f793          	andi	a5,a5,255
    80200b40:	00078663          	beqz	a5,80200b4c <print_dec_int+0x210>
    80200b44:	02d00793          	li	a5,45
    80200b48:	01c0006f          	j	80200b64 <print_dec_int+0x228>
    80200b4c:	f9043783          	ld	a5,-112(s0)
    80200b50:	0057c783          	lbu	a5,5(a5)
    80200b54:	00078663          	beqz	a5,80200b60 <print_dec_int+0x224>
    80200b58:	02b00793          	li	a5,43
    80200b5c:	0080006f          	j	80200b64 <print_dec_int+0x228>
    80200b60:	02000793          	li	a5,32
    80200b64:	fa843703          	ld	a4,-88(s0)
    80200b68:	00078513          	mv	a0,a5
    80200b6c:	000700e7          	jalr	a4
        ++written;
    80200b70:	fe442783          	lw	a5,-28(s0)
    80200b74:	0017879b          	addiw	a5,a5,1
    80200b78:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200b7c:	fe842783          	lw	a5,-24(s0)
    80200b80:	fcf42e23          	sw	a5,-36(s0)
    80200b84:	0280006f          	j	80200bac <print_dec_int+0x270>
        putch('0');
    80200b88:	fa843783          	ld	a5,-88(s0)
    80200b8c:	03000513          	li	a0,48
    80200b90:	000780e7          	jalr	a5
        ++written;
    80200b94:	fe442783          	lw	a5,-28(s0)
    80200b98:	0017879b          	addiw	a5,a5,1
    80200b9c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200ba0:	fdc42783          	lw	a5,-36(s0)
    80200ba4:	0017879b          	addiw	a5,a5,1
    80200ba8:	fcf42e23          	sw	a5,-36(s0)
    80200bac:	f9043783          	ld	a5,-112(s0)
    80200bb0:	00c7a703          	lw	a4,12(a5)
    80200bb4:	fd744783          	lbu	a5,-41(s0)
    80200bb8:	0007879b          	sext.w	a5,a5
    80200bbc:	40f707bb          	subw	a5,a4,a5
    80200bc0:	0007871b          	sext.w	a4,a5
    80200bc4:	fdc42783          	lw	a5,-36(s0)
    80200bc8:	0007879b          	sext.w	a5,a5
    80200bcc:	fae7cee3          	blt	a5,a4,80200b88 <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200bd0:	fe842783          	lw	a5,-24(s0)
    80200bd4:	fff7879b          	addiw	a5,a5,-1
    80200bd8:	fcf42c23          	sw	a5,-40(s0)
    80200bdc:	03c0006f          	j	80200c18 <print_dec_int+0x2dc>
        putch(buf[i]);
    80200be0:	fd842783          	lw	a5,-40(s0)
    80200be4:	ff040713          	addi	a4,s0,-16
    80200be8:	00f707b3          	add	a5,a4,a5
    80200bec:	fc87c783          	lbu	a5,-56(a5)
    80200bf0:	0007879b          	sext.w	a5,a5
    80200bf4:	fa843703          	ld	a4,-88(s0)
    80200bf8:	00078513          	mv	a0,a5
    80200bfc:	000700e7          	jalr	a4
        ++written;
    80200c00:	fe442783          	lw	a5,-28(s0)
    80200c04:	0017879b          	addiw	a5,a5,1
    80200c08:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200c0c:	fd842783          	lw	a5,-40(s0)
    80200c10:	fff7879b          	addiw	a5,a5,-1
    80200c14:	fcf42c23          	sw	a5,-40(s0)
    80200c18:	fd842783          	lw	a5,-40(s0)
    80200c1c:	0007879b          	sext.w	a5,a5
    80200c20:	fc07d0e3          	bgez	a5,80200be0 <print_dec_int+0x2a4>
    }

    return written;
    80200c24:	fe442783          	lw	a5,-28(s0)
}
    80200c28:	00078513          	mv	a0,a5
    80200c2c:	06813083          	ld	ra,104(sp)
    80200c30:	06013403          	ld	s0,96(sp)
    80200c34:	07010113          	addi	sp,sp,112
    80200c38:	00008067          	ret

0000000080200c3c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200c3c:	f4010113          	addi	sp,sp,-192
    80200c40:	0a113c23          	sd	ra,184(sp)
    80200c44:	0a813823          	sd	s0,176(sp)
    80200c48:	0c010413          	addi	s0,sp,192
    80200c4c:	f4a43c23          	sd	a0,-168(s0)
    80200c50:	f4b43823          	sd	a1,-176(s0)
    80200c54:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200c58:	f8043023          	sd	zero,-128(s0)
    80200c5c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200c60:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200c64:	7a40006f          	j	80201408 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200c68:	f8044783          	lbu	a5,-128(s0)
    80200c6c:	72078e63          	beqz	a5,802013a8 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200c70:	f5043783          	ld	a5,-176(s0)
    80200c74:	0007c783          	lbu	a5,0(a5)
    80200c78:	00078713          	mv	a4,a5
    80200c7c:	02300793          	li	a5,35
    80200c80:	00f71863          	bne	a4,a5,80200c90 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200c84:	00100793          	li	a5,1
    80200c88:	f8f40123          	sb	a5,-126(s0)
    80200c8c:	7700006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200c90:	f5043783          	ld	a5,-176(s0)
    80200c94:	0007c783          	lbu	a5,0(a5)
    80200c98:	00078713          	mv	a4,a5
    80200c9c:	03000793          	li	a5,48
    80200ca0:	00f71863          	bne	a4,a5,80200cb0 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200ca4:	00100793          	li	a5,1
    80200ca8:	f8f401a3          	sb	a5,-125(s0)
    80200cac:	7500006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200cb0:	f5043783          	ld	a5,-176(s0)
    80200cb4:	0007c783          	lbu	a5,0(a5)
    80200cb8:	00078713          	mv	a4,a5
    80200cbc:	06c00793          	li	a5,108
    80200cc0:	04f70063          	beq	a4,a5,80200d00 <vprintfmt+0xc4>
    80200cc4:	f5043783          	ld	a5,-176(s0)
    80200cc8:	0007c783          	lbu	a5,0(a5)
    80200ccc:	00078713          	mv	a4,a5
    80200cd0:	07a00793          	li	a5,122
    80200cd4:	02f70663          	beq	a4,a5,80200d00 <vprintfmt+0xc4>
    80200cd8:	f5043783          	ld	a5,-176(s0)
    80200cdc:	0007c783          	lbu	a5,0(a5)
    80200ce0:	00078713          	mv	a4,a5
    80200ce4:	07400793          	li	a5,116
    80200ce8:	00f70c63          	beq	a4,a5,80200d00 <vprintfmt+0xc4>
    80200cec:	f5043783          	ld	a5,-176(s0)
    80200cf0:	0007c783          	lbu	a5,0(a5)
    80200cf4:	00078713          	mv	a4,a5
    80200cf8:	06a00793          	li	a5,106
    80200cfc:	00f71863          	bne	a4,a5,80200d0c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200d00:	00100793          	li	a5,1
    80200d04:	f8f400a3          	sb	a5,-127(s0)
    80200d08:	6f40006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200d0c:	f5043783          	ld	a5,-176(s0)
    80200d10:	0007c783          	lbu	a5,0(a5)
    80200d14:	00078713          	mv	a4,a5
    80200d18:	02b00793          	li	a5,43
    80200d1c:	00f71863          	bne	a4,a5,80200d2c <vprintfmt+0xf0>
                flags.sign = true;
    80200d20:	00100793          	li	a5,1
    80200d24:	f8f402a3          	sb	a5,-123(s0)
    80200d28:	6d40006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200d2c:	f5043783          	ld	a5,-176(s0)
    80200d30:	0007c783          	lbu	a5,0(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	02000793          	li	a5,32
    80200d3c:	00f71863          	bne	a4,a5,80200d4c <vprintfmt+0x110>
                flags.spaceflag = true;
    80200d40:	00100793          	li	a5,1
    80200d44:	f8f40223          	sb	a5,-124(s0)
    80200d48:	6b40006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200d4c:	f5043783          	ld	a5,-176(s0)
    80200d50:	0007c783          	lbu	a5,0(a5)
    80200d54:	00078713          	mv	a4,a5
    80200d58:	02a00793          	li	a5,42
    80200d5c:	00f71e63          	bne	a4,a5,80200d78 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200d60:	f4843783          	ld	a5,-184(s0)
    80200d64:	00878713          	addi	a4,a5,8
    80200d68:	f4e43423          	sd	a4,-184(s0)
    80200d6c:	0007a783          	lw	a5,0(a5)
    80200d70:	f8f42423          	sw	a5,-120(s0)
    80200d74:	6880006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200d78:	f5043783          	ld	a5,-176(s0)
    80200d7c:	0007c783          	lbu	a5,0(a5)
    80200d80:	00078713          	mv	a4,a5
    80200d84:	03000793          	li	a5,48
    80200d88:	04e7f663          	bgeu	a5,a4,80200dd4 <vprintfmt+0x198>
    80200d8c:	f5043783          	ld	a5,-176(s0)
    80200d90:	0007c783          	lbu	a5,0(a5)
    80200d94:	00078713          	mv	a4,a5
    80200d98:	03900793          	li	a5,57
    80200d9c:	02e7ec63          	bltu	a5,a4,80200dd4 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200da0:	f5043783          	ld	a5,-176(s0)
    80200da4:	f5040713          	addi	a4,s0,-176
    80200da8:	00a00613          	li	a2,10
    80200dac:	00070593          	mv	a1,a4
    80200db0:	00078513          	mv	a0,a5
    80200db4:	899ff0ef          	jal	ra,8020064c <strtol>
    80200db8:	00050793          	mv	a5,a0
    80200dbc:	0007879b          	sext.w	a5,a5
    80200dc0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200dc4:	f5043783          	ld	a5,-176(s0)
    80200dc8:	fff78793          	addi	a5,a5,-1
    80200dcc:	f4f43823          	sd	a5,-176(s0)
    80200dd0:	62c0006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200dd4:	f5043783          	ld	a5,-176(s0)
    80200dd8:	0007c783          	lbu	a5,0(a5)
    80200ddc:	00078713          	mv	a4,a5
    80200de0:	02e00793          	li	a5,46
    80200de4:	06f71863          	bne	a4,a5,80200e54 <vprintfmt+0x218>
                fmt++;
    80200de8:	f5043783          	ld	a5,-176(s0)
    80200dec:	00178793          	addi	a5,a5,1
    80200df0:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200df4:	f5043783          	ld	a5,-176(s0)
    80200df8:	0007c783          	lbu	a5,0(a5)
    80200dfc:	00078713          	mv	a4,a5
    80200e00:	02a00793          	li	a5,42
    80200e04:	00f71e63          	bne	a4,a5,80200e20 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200e08:	f4843783          	ld	a5,-184(s0)
    80200e0c:	00878713          	addi	a4,a5,8
    80200e10:	f4e43423          	sd	a4,-184(s0)
    80200e14:	0007a783          	lw	a5,0(a5)
    80200e18:	f8f42623          	sw	a5,-116(s0)
    80200e1c:	5e00006f          	j	802013fc <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200e20:	f5043783          	ld	a5,-176(s0)
    80200e24:	f5040713          	addi	a4,s0,-176
    80200e28:	00a00613          	li	a2,10
    80200e2c:	00070593          	mv	a1,a4
    80200e30:	00078513          	mv	a0,a5
    80200e34:	819ff0ef          	jal	ra,8020064c <strtol>
    80200e38:	00050793          	mv	a5,a0
    80200e3c:	0007879b          	sext.w	a5,a5
    80200e40:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200e44:	f5043783          	ld	a5,-176(s0)
    80200e48:	fff78793          	addi	a5,a5,-1
    80200e4c:	f4f43823          	sd	a5,-176(s0)
    80200e50:	5ac0006f          	j	802013fc <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200e54:	f5043783          	ld	a5,-176(s0)
    80200e58:	0007c783          	lbu	a5,0(a5)
    80200e5c:	00078713          	mv	a4,a5
    80200e60:	07800793          	li	a5,120
    80200e64:	02f70663          	beq	a4,a5,80200e90 <vprintfmt+0x254>
    80200e68:	f5043783          	ld	a5,-176(s0)
    80200e6c:	0007c783          	lbu	a5,0(a5)
    80200e70:	00078713          	mv	a4,a5
    80200e74:	05800793          	li	a5,88
    80200e78:	00f70c63          	beq	a4,a5,80200e90 <vprintfmt+0x254>
    80200e7c:	f5043783          	ld	a5,-176(s0)
    80200e80:	0007c783          	lbu	a5,0(a5)
    80200e84:	00078713          	mv	a4,a5
    80200e88:	07000793          	li	a5,112
    80200e8c:	2ef71e63          	bne	a4,a5,80201188 <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200e90:	f5043783          	ld	a5,-176(s0)
    80200e94:	0007c783          	lbu	a5,0(a5)
    80200e98:	00078713          	mv	a4,a5
    80200e9c:	07000793          	li	a5,112
    80200ea0:	00f70663          	beq	a4,a5,80200eac <vprintfmt+0x270>
    80200ea4:	f8144783          	lbu	a5,-127(s0)
    80200ea8:	00078663          	beqz	a5,80200eb4 <vprintfmt+0x278>
    80200eac:	00100793          	li	a5,1
    80200eb0:	0080006f          	j	80200eb8 <vprintfmt+0x27c>
    80200eb4:	00000793          	li	a5,0
    80200eb8:	faf403a3          	sb	a5,-89(s0)
    80200ebc:	fa744783          	lbu	a5,-89(s0)
    80200ec0:	0017f793          	andi	a5,a5,1
    80200ec4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200ec8:	fa744783          	lbu	a5,-89(s0)
    80200ecc:	0ff7f793          	andi	a5,a5,255
    80200ed0:	00078c63          	beqz	a5,80200ee8 <vprintfmt+0x2ac>
    80200ed4:	f4843783          	ld	a5,-184(s0)
    80200ed8:	00878713          	addi	a4,a5,8
    80200edc:	f4e43423          	sd	a4,-184(s0)
    80200ee0:	0007b783          	ld	a5,0(a5)
    80200ee4:	01c0006f          	j	80200f00 <vprintfmt+0x2c4>
    80200ee8:	f4843783          	ld	a5,-184(s0)
    80200eec:	00878713          	addi	a4,a5,8
    80200ef0:	f4e43423          	sd	a4,-184(s0)
    80200ef4:	0007a783          	lw	a5,0(a5)
    80200ef8:	02079793          	slli	a5,a5,0x20
    80200efc:	0207d793          	srli	a5,a5,0x20
    80200f00:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200f04:	f8c42783          	lw	a5,-116(s0)
    80200f08:	02079463          	bnez	a5,80200f30 <vprintfmt+0x2f4>
    80200f0c:	fe043783          	ld	a5,-32(s0)
    80200f10:	02079063          	bnez	a5,80200f30 <vprintfmt+0x2f4>
    80200f14:	f5043783          	ld	a5,-176(s0)
    80200f18:	0007c783          	lbu	a5,0(a5)
    80200f1c:	00078713          	mv	a4,a5
    80200f20:	07000793          	li	a5,112
    80200f24:	00f70663          	beq	a4,a5,80200f30 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200f28:	f8040023          	sb	zero,-128(s0)
    80200f2c:	4d00006f          	j	802013fc <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200f30:	f5043783          	ld	a5,-176(s0)
    80200f34:	0007c783          	lbu	a5,0(a5)
    80200f38:	00078713          	mv	a4,a5
    80200f3c:	07000793          	li	a5,112
    80200f40:	00f70a63          	beq	a4,a5,80200f54 <vprintfmt+0x318>
    80200f44:	f8244783          	lbu	a5,-126(s0)
    80200f48:	00078a63          	beqz	a5,80200f5c <vprintfmt+0x320>
    80200f4c:	fe043783          	ld	a5,-32(s0)
    80200f50:	00078663          	beqz	a5,80200f5c <vprintfmt+0x320>
    80200f54:	00100793          	li	a5,1
    80200f58:	0080006f          	j	80200f60 <vprintfmt+0x324>
    80200f5c:	00000793          	li	a5,0
    80200f60:	faf40323          	sb	a5,-90(s0)
    80200f64:	fa644783          	lbu	a5,-90(s0)
    80200f68:	0017f793          	andi	a5,a5,1
    80200f6c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200f70:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200f74:	f5043783          	ld	a5,-176(s0)
    80200f78:	0007c783          	lbu	a5,0(a5)
    80200f7c:	00078713          	mv	a4,a5
    80200f80:	05800793          	li	a5,88
    80200f84:	00f71863          	bne	a4,a5,80200f94 <vprintfmt+0x358>
    80200f88:	00001797          	auipc	a5,0x1
    80200f8c:	12078793          	addi	a5,a5,288 # 802020a8 <upperxdigits.1101>
    80200f90:	00c0006f          	j	80200f9c <vprintfmt+0x360>
    80200f94:	00001797          	auipc	a5,0x1
    80200f98:	12c78793          	addi	a5,a5,300 # 802020c0 <lowerxdigits.1100>
    80200f9c:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80200fa0:	fe043783          	ld	a5,-32(s0)
    80200fa4:	00f7f793          	andi	a5,a5,15
    80200fa8:	f9843703          	ld	a4,-104(s0)
    80200fac:	00f70733          	add	a4,a4,a5
    80200fb0:	fdc42783          	lw	a5,-36(s0)
    80200fb4:	0017869b          	addiw	a3,a5,1
    80200fb8:	fcd42e23          	sw	a3,-36(s0)
    80200fbc:	00074703          	lbu	a4,0(a4)
    80200fc0:	ff040693          	addi	a3,s0,-16
    80200fc4:	00f687b3          	add	a5,a3,a5
    80200fc8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80200fcc:	fe043783          	ld	a5,-32(s0)
    80200fd0:	0047d793          	srli	a5,a5,0x4
    80200fd4:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80200fd8:	fe043783          	ld	a5,-32(s0)
    80200fdc:	fc0792e3          	bnez	a5,80200fa0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80200fe0:	f8c42783          	lw	a5,-116(s0)
    80200fe4:	00078713          	mv	a4,a5
    80200fe8:	fff00793          	li	a5,-1
    80200fec:	02f71663          	bne	a4,a5,80201018 <vprintfmt+0x3dc>
    80200ff0:	f8344783          	lbu	a5,-125(s0)
    80200ff4:	02078263          	beqz	a5,80201018 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80200ff8:	f8842703          	lw	a4,-120(s0)
    80200ffc:	fa644783          	lbu	a5,-90(s0)
    80201000:	0007879b          	sext.w	a5,a5
    80201004:	0017979b          	slliw	a5,a5,0x1
    80201008:	0007879b          	sext.w	a5,a5
    8020100c:	40f707bb          	subw	a5,a4,a5
    80201010:	0007879b          	sext.w	a5,a5
    80201014:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201018:	f8842703          	lw	a4,-120(s0)
    8020101c:	fa644783          	lbu	a5,-90(s0)
    80201020:	0007879b          	sext.w	a5,a5
    80201024:	0017979b          	slliw	a5,a5,0x1
    80201028:	0007879b          	sext.w	a5,a5
    8020102c:	40f707bb          	subw	a5,a4,a5
    80201030:	0007871b          	sext.w	a4,a5
    80201034:	fdc42783          	lw	a5,-36(s0)
    80201038:	f8f42a23          	sw	a5,-108(s0)
    8020103c:	f8c42783          	lw	a5,-116(s0)
    80201040:	f8f42823          	sw	a5,-112(s0)
    80201044:	f9442583          	lw	a1,-108(s0)
    80201048:	f9042783          	lw	a5,-112(s0)
    8020104c:	0007861b          	sext.w	a2,a5
    80201050:	0005869b          	sext.w	a3,a1
    80201054:	00d65463          	bge	a2,a3,8020105c <vprintfmt+0x420>
    80201058:	00058793          	mv	a5,a1
    8020105c:	0007879b          	sext.w	a5,a5
    80201060:	40f707bb          	subw	a5,a4,a5
    80201064:	fcf42c23          	sw	a5,-40(s0)
    80201068:	0280006f          	j	80201090 <vprintfmt+0x454>
                    putch(' ');
    8020106c:	f5843783          	ld	a5,-168(s0)
    80201070:	02000513          	li	a0,32
    80201074:	000780e7          	jalr	a5
                    ++written;
    80201078:	fec42783          	lw	a5,-20(s0)
    8020107c:	0017879b          	addiw	a5,a5,1
    80201080:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201084:	fd842783          	lw	a5,-40(s0)
    80201088:	fff7879b          	addiw	a5,a5,-1
    8020108c:	fcf42c23          	sw	a5,-40(s0)
    80201090:	fd842783          	lw	a5,-40(s0)
    80201094:	0007879b          	sext.w	a5,a5
    80201098:	fcf04ae3          	bgtz	a5,8020106c <vprintfmt+0x430>
                }

                if (prefix) {
    8020109c:	fa644783          	lbu	a5,-90(s0)
    802010a0:	0ff7f793          	andi	a5,a5,255
    802010a4:	04078463          	beqz	a5,802010ec <vprintfmt+0x4b0>
                    putch('0');
    802010a8:	f5843783          	ld	a5,-168(s0)
    802010ac:	03000513          	li	a0,48
    802010b0:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    802010b4:	f5043783          	ld	a5,-176(s0)
    802010b8:	0007c783          	lbu	a5,0(a5)
    802010bc:	00078713          	mv	a4,a5
    802010c0:	05800793          	li	a5,88
    802010c4:	00f71663          	bne	a4,a5,802010d0 <vprintfmt+0x494>
    802010c8:	05800793          	li	a5,88
    802010cc:	0080006f          	j	802010d4 <vprintfmt+0x498>
    802010d0:	07800793          	li	a5,120
    802010d4:	f5843703          	ld	a4,-168(s0)
    802010d8:	00078513          	mv	a0,a5
    802010dc:	000700e7          	jalr	a4
                    written += 2;
    802010e0:	fec42783          	lw	a5,-20(s0)
    802010e4:	0027879b          	addiw	a5,a5,2
    802010e8:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    802010ec:	fdc42783          	lw	a5,-36(s0)
    802010f0:	fcf42a23          	sw	a5,-44(s0)
    802010f4:	0280006f          	j	8020111c <vprintfmt+0x4e0>
                    putch('0');
    802010f8:	f5843783          	ld	a5,-168(s0)
    802010fc:	03000513          	li	a0,48
    80201100:	000780e7          	jalr	a5
                    ++written;
    80201104:	fec42783          	lw	a5,-20(s0)
    80201108:	0017879b          	addiw	a5,a5,1
    8020110c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201110:	fd442783          	lw	a5,-44(s0)
    80201114:	0017879b          	addiw	a5,a5,1
    80201118:	fcf42a23          	sw	a5,-44(s0)
    8020111c:	f8c42703          	lw	a4,-116(s0)
    80201120:	fd442783          	lw	a5,-44(s0)
    80201124:	0007879b          	sext.w	a5,a5
    80201128:	fce7c8e3          	blt	a5,a4,802010f8 <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    8020112c:	fdc42783          	lw	a5,-36(s0)
    80201130:	fff7879b          	addiw	a5,a5,-1
    80201134:	fcf42823          	sw	a5,-48(s0)
    80201138:	03c0006f          	j	80201174 <vprintfmt+0x538>
                    putch(buf[i]);
    8020113c:	fd042783          	lw	a5,-48(s0)
    80201140:	ff040713          	addi	a4,s0,-16
    80201144:	00f707b3          	add	a5,a4,a5
    80201148:	f807c783          	lbu	a5,-128(a5)
    8020114c:	0007879b          	sext.w	a5,a5
    80201150:	f5843703          	ld	a4,-168(s0)
    80201154:	00078513          	mv	a0,a5
    80201158:	000700e7          	jalr	a4
                    ++written;
    8020115c:	fec42783          	lw	a5,-20(s0)
    80201160:	0017879b          	addiw	a5,a5,1
    80201164:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201168:	fd042783          	lw	a5,-48(s0)
    8020116c:	fff7879b          	addiw	a5,a5,-1
    80201170:	fcf42823          	sw	a5,-48(s0)
    80201174:	fd042783          	lw	a5,-48(s0)
    80201178:	0007879b          	sext.w	a5,a5
    8020117c:	fc07d0e3          	bgez	a5,8020113c <vprintfmt+0x500>
                }

                flags.in_format = false;
    80201180:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201184:	2780006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201188:	f5043783          	ld	a5,-176(s0)
    8020118c:	0007c783          	lbu	a5,0(a5)
    80201190:	00078713          	mv	a4,a5
    80201194:	06400793          	li	a5,100
    80201198:	02f70663          	beq	a4,a5,802011c4 <vprintfmt+0x588>
    8020119c:	f5043783          	ld	a5,-176(s0)
    802011a0:	0007c783          	lbu	a5,0(a5)
    802011a4:	00078713          	mv	a4,a5
    802011a8:	06900793          	li	a5,105
    802011ac:	00f70c63          	beq	a4,a5,802011c4 <vprintfmt+0x588>
    802011b0:	f5043783          	ld	a5,-176(s0)
    802011b4:	0007c783          	lbu	a5,0(a5)
    802011b8:	00078713          	mv	a4,a5
    802011bc:	07500793          	li	a5,117
    802011c0:	08f71263          	bne	a4,a5,80201244 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802011c4:	f8144783          	lbu	a5,-127(s0)
    802011c8:	00078c63          	beqz	a5,802011e0 <vprintfmt+0x5a4>
    802011cc:	f4843783          	ld	a5,-184(s0)
    802011d0:	00878713          	addi	a4,a5,8
    802011d4:	f4e43423          	sd	a4,-184(s0)
    802011d8:	0007b783          	ld	a5,0(a5)
    802011dc:	0140006f          	j	802011f0 <vprintfmt+0x5b4>
    802011e0:	f4843783          	ld	a5,-184(s0)
    802011e4:	00878713          	addi	a4,a5,8
    802011e8:	f4e43423          	sd	a4,-184(s0)
    802011ec:	0007a783          	lw	a5,0(a5)
    802011f0:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    802011f4:	fa843583          	ld	a1,-88(s0)
    802011f8:	f5043783          	ld	a5,-176(s0)
    802011fc:	0007c783          	lbu	a5,0(a5)
    80201200:	0007871b          	sext.w	a4,a5
    80201204:	07500793          	li	a5,117
    80201208:	40f707b3          	sub	a5,a4,a5
    8020120c:	00f037b3          	snez	a5,a5
    80201210:	0ff7f793          	andi	a5,a5,255
    80201214:	f8040713          	addi	a4,s0,-128
    80201218:	00070693          	mv	a3,a4
    8020121c:	00078613          	mv	a2,a5
    80201220:	f5843503          	ld	a0,-168(s0)
    80201224:	f18ff0ef          	jal	ra,8020093c <print_dec_int>
    80201228:	00050793          	mv	a5,a0
    8020122c:	00078713          	mv	a4,a5
    80201230:	fec42783          	lw	a5,-20(s0)
    80201234:	00e787bb          	addw	a5,a5,a4
    80201238:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020123c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201240:	1bc0006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201244:	f5043783          	ld	a5,-176(s0)
    80201248:	0007c783          	lbu	a5,0(a5)
    8020124c:	00078713          	mv	a4,a5
    80201250:	06e00793          	li	a5,110
    80201254:	04f71c63          	bne	a4,a5,802012ac <vprintfmt+0x670>
                if (flags.longflag) {
    80201258:	f8144783          	lbu	a5,-127(s0)
    8020125c:	02078463          	beqz	a5,80201284 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
    80201260:	f4843783          	ld	a5,-184(s0)
    80201264:	00878713          	addi	a4,a5,8
    80201268:	f4e43423          	sd	a4,-184(s0)
    8020126c:	0007b783          	ld	a5,0(a5)
    80201270:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201274:	fec42703          	lw	a4,-20(s0)
    80201278:	fb043783          	ld	a5,-80(s0)
    8020127c:	00e7b023          	sd	a4,0(a5)
    80201280:	0240006f          	j	802012a4 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
    80201284:	f4843783          	ld	a5,-184(s0)
    80201288:	00878713          	addi	a4,a5,8
    8020128c:	f4e43423          	sd	a4,-184(s0)
    80201290:	0007b783          	ld	a5,0(a5)
    80201294:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201298:	fb843783          	ld	a5,-72(s0)
    8020129c:	fec42703          	lw	a4,-20(s0)
    802012a0:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    802012a4:	f8040023          	sb	zero,-128(s0)
    802012a8:	1540006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    802012ac:	f5043783          	ld	a5,-176(s0)
    802012b0:	0007c783          	lbu	a5,0(a5)
    802012b4:	00078713          	mv	a4,a5
    802012b8:	07300793          	li	a5,115
    802012bc:	04f71063          	bne	a4,a5,802012fc <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802012c0:	f4843783          	ld	a5,-184(s0)
    802012c4:	00878713          	addi	a4,a5,8
    802012c8:	f4e43423          	sd	a4,-184(s0)
    802012cc:	0007b783          	ld	a5,0(a5)
    802012d0:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    802012d4:	fc043583          	ld	a1,-64(s0)
    802012d8:	f5843503          	ld	a0,-168(s0)
    802012dc:	dd8ff0ef          	jal	ra,802008b4 <puts_wo_nl>
    802012e0:	00050793          	mv	a5,a0
    802012e4:	00078713          	mv	a4,a5
    802012e8:	fec42783          	lw	a5,-20(s0)
    802012ec:	00e787bb          	addw	a5,a5,a4
    802012f0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012f4:	f8040023          	sb	zero,-128(s0)
    802012f8:	1040006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    802012fc:	f5043783          	ld	a5,-176(s0)
    80201300:	0007c783          	lbu	a5,0(a5)
    80201304:	00078713          	mv	a4,a5
    80201308:	06300793          	li	a5,99
    8020130c:	02f71e63          	bne	a4,a5,80201348 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201310:	f4843783          	ld	a5,-184(s0)
    80201314:	00878713          	addi	a4,a5,8
    80201318:	f4e43423          	sd	a4,-184(s0)
    8020131c:	0007a783          	lw	a5,0(a5)
    80201320:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201324:	fcc42783          	lw	a5,-52(s0)
    80201328:	f5843703          	ld	a4,-168(s0)
    8020132c:	00078513          	mv	a0,a5
    80201330:	000700e7          	jalr	a4
                ++written;
    80201334:	fec42783          	lw	a5,-20(s0)
    80201338:	0017879b          	addiw	a5,a5,1
    8020133c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201340:	f8040023          	sb	zero,-128(s0)
    80201344:	0b80006f          	j	802013fc <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201348:	f5043783          	ld	a5,-176(s0)
    8020134c:	0007c783          	lbu	a5,0(a5)
    80201350:	00078713          	mv	a4,a5
    80201354:	02500793          	li	a5,37
    80201358:	02f71263          	bne	a4,a5,8020137c <vprintfmt+0x740>
                putch('%');
    8020135c:	f5843783          	ld	a5,-168(s0)
    80201360:	02500513          	li	a0,37
    80201364:	000780e7          	jalr	a5
                ++written;
    80201368:	fec42783          	lw	a5,-20(s0)
    8020136c:	0017879b          	addiw	a5,a5,1
    80201370:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201374:	f8040023          	sb	zero,-128(s0)
    80201378:	0840006f          	j	802013fc <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    8020137c:	f5043783          	ld	a5,-176(s0)
    80201380:	0007c783          	lbu	a5,0(a5)
    80201384:	0007879b          	sext.w	a5,a5
    80201388:	f5843703          	ld	a4,-168(s0)
    8020138c:	00078513          	mv	a0,a5
    80201390:	000700e7          	jalr	a4
                ++written;
    80201394:	fec42783          	lw	a5,-20(s0)
    80201398:	0017879b          	addiw	a5,a5,1
    8020139c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013a0:	f8040023          	sb	zero,-128(s0)
    802013a4:	0580006f          	j	802013fc <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    802013a8:	f5043783          	ld	a5,-176(s0)
    802013ac:	0007c783          	lbu	a5,0(a5)
    802013b0:	00078713          	mv	a4,a5
    802013b4:	02500793          	li	a5,37
    802013b8:	02f71063          	bne	a4,a5,802013d8 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    802013bc:	f8043023          	sd	zero,-128(s0)
    802013c0:	f8043423          	sd	zero,-120(s0)
    802013c4:	00100793          	li	a5,1
    802013c8:	f8f40023          	sb	a5,-128(s0)
    802013cc:	fff00793          	li	a5,-1
    802013d0:	f8f42623          	sw	a5,-116(s0)
    802013d4:	0280006f          	j	802013fc <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    802013d8:	f5043783          	ld	a5,-176(s0)
    802013dc:	0007c783          	lbu	a5,0(a5)
    802013e0:	0007879b          	sext.w	a5,a5
    802013e4:	f5843703          	ld	a4,-168(s0)
    802013e8:	00078513          	mv	a0,a5
    802013ec:	000700e7          	jalr	a4
            ++written;
    802013f0:	fec42783          	lw	a5,-20(s0)
    802013f4:	0017879b          	addiw	a5,a5,1
    802013f8:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    802013fc:	f5043783          	ld	a5,-176(s0)
    80201400:	00178793          	addi	a5,a5,1
    80201404:	f4f43823          	sd	a5,-176(s0)
    80201408:	f5043783          	ld	a5,-176(s0)
    8020140c:	0007c783          	lbu	a5,0(a5)
    80201410:	84079ce3          	bnez	a5,80200c68 <vprintfmt+0x2c>
        }
    }

    return written;
    80201414:	fec42783          	lw	a5,-20(s0)
}
    80201418:	00078513          	mv	a0,a5
    8020141c:	0b813083          	ld	ra,184(sp)
    80201420:	0b013403          	ld	s0,176(sp)
    80201424:	0c010113          	addi	sp,sp,192
    80201428:	00008067          	ret

000000008020142c <printk>:

int printk(const char* s, ...) {
    8020142c:	f9010113          	addi	sp,sp,-112
    80201430:	02113423          	sd	ra,40(sp)
    80201434:	02813023          	sd	s0,32(sp)
    80201438:	03010413          	addi	s0,sp,48
    8020143c:	fca43c23          	sd	a0,-40(s0)
    80201440:	00b43423          	sd	a1,8(s0)
    80201444:	00c43823          	sd	a2,16(s0)
    80201448:	00d43c23          	sd	a3,24(s0)
    8020144c:	02e43023          	sd	a4,32(s0)
    80201450:	02f43423          	sd	a5,40(s0)
    80201454:	03043823          	sd	a6,48(s0)
    80201458:	03143c23          	sd	a7,56(s0)
    int res = 0;
    8020145c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201460:	04040793          	addi	a5,s0,64
    80201464:	fcf43823          	sd	a5,-48(s0)
    80201468:	fd043783          	ld	a5,-48(s0)
    8020146c:	fc878793          	addi	a5,a5,-56
    80201470:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201474:	fe043783          	ld	a5,-32(s0)
    80201478:	00078613          	mv	a2,a5
    8020147c:	fd843583          	ld	a1,-40(s0)
    80201480:	fffff517          	auipc	a0,0xfffff
    80201484:	12450513          	addi	a0,a0,292 # 802005a4 <putc>
    80201488:	fb4ff0ef          	jal	ra,80200c3c <vprintfmt>
    8020148c:	00050793          	mv	a5,a0
    80201490:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201494:	fec42783          	lw	a5,-20(s0)
}
    80201498:	00078513          	mv	a0,a5
    8020149c:	02813083          	ld	ra,40(sp)
    802014a0:	02013403          	ld	s0,32(sp)
    802014a4:	07010113          	addi	sp,sp,112
    802014a8:	00008067          	ret
