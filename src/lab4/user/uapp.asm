
uapp:     file format elf64-littleriscv


Disassembly of section .text:

000000000001010c <_start>:
    .section .text.init
    .global _start
_start:
    j   main
   1010c:	0380006f          	j	10144 <main>

0000000000010110 <getpid>:
#include "syscall.h"
#include "stdio.h"

int counter = 0;

static inline long getpid() {
   10110:	fe010113          	addi	sp,sp,-32
   10114:	00813c23          	sd	s0,24(sp)
   10118:	02010413          	addi	s0,sp,32
    long ret;
    asm volatile ("li a7, %1\n"
   1011c:	fe843783          	ld	a5,-24(s0)
   10120:	0ac00893          	li	a7,172
   10124:	00000073          	ecall
   10128:	00050793          	mv	a5,a0
   1012c:	fef43423          	sd	a5,-24(s0)
                  "ecall\n"
                  "mv %0, a0\n"
                : "+r" (ret) 
                : "i" (SYS_GETPID));
    return ret;
   10130:	fe843783          	ld	a5,-24(s0)
}
   10134:	00078513          	mv	a0,a5
   10138:	01813403          	ld	s0,24(sp)
   1013c:	02010113          	addi	sp,sp,32
   10140:	00008067          	ret

0000000000010144 <main>:

int main() {
   10144:	fe010113          	addi	sp,sp,-32
   10148:	00113c23          	sd	ra,24(sp)
   1014c:	00813823          	sd	s0,16(sp)
   10150:	02010413          	addi	s0,sp,32
    register void *current_sp __asm__("sp");
    while (1) {
        printf("[U-MODE] pid: %ld, sp is %p, this is print No.%d\n", getpid(), current_sp, ++counter);
   10154:	fbdff0ef          	jal	ra,10110 <getpid>
   10158:	00050593          	mv	a1,a0
   1015c:	00010613          	mv	a2,sp
   10160:	00002797          	auipc	a5,0x2
   10164:	09478793          	addi	a5,a5,148 # 121f4 <counter>
   10168:	0007a783          	lw	a5,0(a5)
   1016c:	0017879b          	addiw	a5,a5,1
   10170:	0007871b          	sext.w	a4,a5
   10174:	00002797          	auipc	a5,0x2
   10178:	08078793          	addi	a5,a5,128 # 121f4 <counter>
   1017c:	00e7a023          	sw	a4,0(a5)
   10180:	00002797          	auipc	a5,0x2
   10184:	07478793          	addi	a5,a5,116 # 121f4 <counter>
   10188:	0007a783          	lw	a5,0(a5)
   1018c:	00078693          	mv	a3,a5
   10190:	00001517          	auipc	a0,0x1
   10194:	fe050513          	addi	a0,a0,-32 # 11170 <printf+0x100>
   10198:	6d9000ef          	jal	ra,11070 <printf>
        for (unsigned int i = 0; i < 0x4FFFFFFF; i++);
   1019c:	fe042623          	sw	zero,-20(s0)
   101a0:	0100006f          	j	101b0 <main+0x6c>
   101a4:	fec42783          	lw	a5,-20(s0)
   101a8:	0017879b          	addiw	a5,a5,1
   101ac:	fef42623          	sw	a5,-20(s0)
   101b0:	fec42783          	lw	a5,-20(s0)
   101b4:	0007871b          	sext.w	a4,a5
   101b8:	500007b7          	lui	a5,0x50000
   101bc:	ffe78793          	addi	a5,a5,-2 # 4ffffffe <__global_pointer$+0x4ffed60d>
   101c0:	fee7f2e3          	bgeu	a5,a4,101a4 <main+0x60>
        printf("[U-MODE] pid: %ld, sp is %p, this is print No.%d\n", getpid(), current_sp, ++counter);
   101c4:	f91ff06f          	j	10154 <main+0x10>

00000000000101c8 <putc>:
#include "syscall.h"

int tail = 0;
char buffer[1000] = {[0 ... 999] = 0};

int putc(int c) {
   101c8:	fe010113          	addi	sp,sp,-32
   101cc:	00813c23          	sd	s0,24(sp)
   101d0:	02010413          	addi	s0,sp,32
   101d4:	00050793          	mv	a5,a0
   101d8:	fef42623          	sw	a5,-20(s0)
    buffer[tail++] = (char)c;
   101dc:	00002797          	auipc	a5,0x2
   101e0:	01c78793          	addi	a5,a5,28 # 121f8 <tail>
   101e4:	0007a783          	lw	a5,0(a5)
   101e8:	0017871b          	addiw	a4,a5,1
   101ec:	0007069b          	sext.w	a3,a4
   101f0:	00002717          	auipc	a4,0x2
   101f4:	00870713          	addi	a4,a4,8 # 121f8 <tail>
   101f8:	00d72023          	sw	a3,0(a4)
   101fc:	fec42703          	lw	a4,-20(s0)
   10200:	0ff77713          	andi	a4,a4,255
   10204:	00002697          	auipc	a3,0x2
   10208:	ffc68693          	addi	a3,a3,-4 # 12200 <buffer>
   1020c:	00f687b3          	add	a5,a3,a5
   10210:	00e78023          	sb	a4,0(a5)
    return (char)c;
   10214:	fec42783          	lw	a5,-20(s0)
   10218:	0ff7f793          	andi	a5,a5,255
   1021c:	0007879b          	sext.w	a5,a5
}
   10220:	00078513          	mv	a0,a5
   10224:	01813403          	ld	s0,24(sp)
   10228:	02010113          	addi	sp,sp,32
   1022c:	00008067          	ret

0000000000010230 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
   10230:	fe010113          	addi	sp,sp,-32
   10234:	00813c23          	sd	s0,24(sp)
   10238:	02010413          	addi	s0,sp,32
   1023c:	00050793          	mv	a5,a0
   10240:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
   10244:	fec42783          	lw	a5,-20(s0)
   10248:	0007871b          	sext.w	a4,a5
   1024c:	02000793          	li	a5,32
   10250:	02f70263          	beq	a4,a5,10274 <isspace+0x44>
   10254:	fec42783          	lw	a5,-20(s0)
   10258:	0007871b          	sext.w	a4,a5
   1025c:	00800793          	li	a5,8
   10260:	00e7de63          	bge	a5,a4,1027c <isspace+0x4c>
   10264:	fec42783          	lw	a5,-20(s0)
   10268:	0007871b          	sext.w	a4,a5
   1026c:	00d00793          	li	a5,13
   10270:	00e7c663          	blt	a5,a4,1027c <isspace+0x4c>
   10274:	00100793          	li	a5,1
   10278:	0080006f          	j	10280 <isspace+0x50>
   1027c:	00000793          	li	a5,0
}
   10280:	00078513          	mv	a0,a5
   10284:	01813403          	ld	s0,24(sp)
   10288:	02010113          	addi	sp,sp,32
   1028c:	00008067          	ret

0000000000010290 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
   10290:	fb010113          	addi	sp,sp,-80
   10294:	04113423          	sd	ra,72(sp)
   10298:	04813023          	sd	s0,64(sp)
   1029c:	05010413          	addi	s0,sp,80
   102a0:	fca43423          	sd	a0,-56(s0)
   102a4:	fcb43023          	sd	a1,-64(s0)
   102a8:	00060793          	mv	a5,a2
   102ac:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
   102b0:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
   102b4:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
   102b8:	fc843783          	ld	a5,-56(s0)
   102bc:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
   102c0:	0100006f          	j	102d0 <strtol+0x40>
        p++;
   102c4:	fd843783          	ld	a5,-40(s0)
   102c8:	00178793          	addi	a5,a5,1
   102cc:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
   102d0:	fd843783          	ld	a5,-40(s0)
   102d4:	0007c783          	lbu	a5,0(a5)
   102d8:	0007879b          	sext.w	a5,a5
   102dc:	00078513          	mv	a0,a5
   102e0:	f51ff0ef          	jal	ra,10230 <isspace>
   102e4:	00050793          	mv	a5,a0
   102e8:	fc079ee3          	bnez	a5,102c4 <strtol+0x34>
    }

    if (*p == '-') {
   102ec:	fd843783          	ld	a5,-40(s0)
   102f0:	0007c783          	lbu	a5,0(a5)
   102f4:	00078713          	mv	a4,a5
   102f8:	02d00793          	li	a5,45
   102fc:	00f71e63          	bne	a4,a5,10318 <strtol+0x88>
        neg = true;
   10300:	00100793          	li	a5,1
   10304:	fef403a3          	sb	a5,-25(s0)
        p++;
   10308:	fd843783          	ld	a5,-40(s0)
   1030c:	00178793          	addi	a5,a5,1
   10310:	fcf43c23          	sd	a5,-40(s0)
   10314:	0240006f          	j	10338 <strtol+0xa8>
    } else if (*p == '+') {
   10318:	fd843783          	ld	a5,-40(s0)
   1031c:	0007c783          	lbu	a5,0(a5)
   10320:	00078713          	mv	a4,a5
   10324:	02b00793          	li	a5,43
   10328:	00f71863          	bne	a4,a5,10338 <strtol+0xa8>
        p++;
   1032c:	fd843783          	ld	a5,-40(s0)
   10330:	00178793          	addi	a5,a5,1
   10334:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
   10338:	fbc42783          	lw	a5,-68(s0)
   1033c:	0007879b          	sext.w	a5,a5
   10340:	06079c63          	bnez	a5,103b8 <strtol+0x128>
        if (*p == '0') {
   10344:	fd843783          	ld	a5,-40(s0)
   10348:	0007c783          	lbu	a5,0(a5)
   1034c:	00078713          	mv	a4,a5
   10350:	03000793          	li	a5,48
   10354:	04f71e63          	bne	a4,a5,103b0 <strtol+0x120>
            p++;
   10358:	fd843783          	ld	a5,-40(s0)
   1035c:	00178793          	addi	a5,a5,1
   10360:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
   10364:	fd843783          	ld	a5,-40(s0)
   10368:	0007c783          	lbu	a5,0(a5)
   1036c:	00078713          	mv	a4,a5
   10370:	07800793          	li	a5,120
   10374:	00f70c63          	beq	a4,a5,1038c <strtol+0xfc>
   10378:	fd843783          	ld	a5,-40(s0)
   1037c:	0007c783          	lbu	a5,0(a5)
   10380:	00078713          	mv	a4,a5
   10384:	05800793          	li	a5,88
   10388:	00f71e63          	bne	a4,a5,103a4 <strtol+0x114>
                base = 16;
   1038c:	01000793          	li	a5,16
   10390:	faf42e23          	sw	a5,-68(s0)
                p++;
   10394:	fd843783          	ld	a5,-40(s0)
   10398:	00178793          	addi	a5,a5,1
   1039c:	fcf43c23          	sd	a5,-40(s0)
   103a0:	0180006f          	j	103b8 <strtol+0x128>
            } else {
                base = 8;
   103a4:	00800793          	li	a5,8
   103a8:	faf42e23          	sw	a5,-68(s0)
   103ac:	00c0006f          	j	103b8 <strtol+0x128>
            }
        } else {
            base = 10;
   103b0:	00a00793          	li	a5,10
   103b4:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
   103b8:	fd843783          	ld	a5,-40(s0)
   103bc:	0007c783          	lbu	a5,0(a5)
   103c0:	00078713          	mv	a4,a5
   103c4:	02f00793          	li	a5,47
   103c8:	02e7f863          	bgeu	a5,a4,103f8 <strtol+0x168>
   103cc:	fd843783          	ld	a5,-40(s0)
   103d0:	0007c783          	lbu	a5,0(a5)
   103d4:	00078713          	mv	a4,a5
   103d8:	03900793          	li	a5,57
   103dc:	00e7ee63          	bltu	a5,a4,103f8 <strtol+0x168>
            digit = *p - '0';
   103e0:	fd843783          	ld	a5,-40(s0)
   103e4:	0007c783          	lbu	a5,0(a5)
   103e8:	0007879b          	sext.w	a5,a5
   103ec:	fd07879b          	addiw	a5,a5,-48
   103f0:	fcf42a23          	sw	a5,-44(s0)
   103f4:	0800006f          	j	10474 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
   103f8:	fd843783          	ld	a5,-40(s0)
   103fc:	0007c783          	lbu	a5,0(a5)
   10400:	00078713          	mv	a4,a5
   10404:	06000793          	li	a5,96
   10408:	02e7f863          	bgeu	a5,a4,10438 <strtol+0x1a8>
   1040c:	fd843783          	ld	a5,-40(s0)
   10410:	0007c783          	lbu	a5,0(a5)
   10414:	00078713          	mv	a4,a5
   10418:	07a00793          	li	a5,122
   1041c:	00e7ee63          	bltu	a5,a4,10438 <strtol+0x1a8>
            digit = *p - ('a' - 10);
   10420:	fd843783          	ld	a5,-40(s0)
   10424:	0007c783          	lbu	a5,0(a5)
   10428:	0007879b          	sext.w	a5,a5
   1042c:	fa97879b          	addiw	a5,a5,-87
   10430:	fcf42a23          	sw	a5,-44(s0)
   10434:	0400006f          	j	10474 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
   10438:	fd843783          	ld	a5,-40(s0)
   1043c:	0007c783          	lbu	a5,0(a5)
   10440:	00078713          	mv	a4,a5
   10444:	04000793          	li	a5,64
   10448:	06e7f663          	bgeu	a5,a4,104b4 <strtol+0x224>
   1044c:	fd843783          	ld	a5,-40(s0)
   10450:	0007c783          	lbu	a5,0(a5)
   10454:	00078713          	mv	a4,a5
   10458:	05a00793          	li	a5,90
   1045c:	04e7ec63          	bltu	a5,a4,104b4 <strtol+0x224>
            digit = *p - ('A' - 10);
   10460:	fd843783          	ld	a5,-40(s0)
   10464:	0007c783          	lbu	a5,0(a5)
   10468:	0007879b          	sext.w	a5,a5
   1046c:	fc97879b          	addiw	a5,a5,-55
   10470:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
   10474:	fd442703          	lw	a4,-44(s0)
   10478:	fbc42783          	lw	a5,-68(s0)
   1047c:	0007071b          	sext.w	a4,a4
   10480:	0007879b          	sext.w	a5,a5
   10484:	02f75663          	bge	a4,a5,104b0 <strtol+0x220>
            break;
        }

        ret = ret * base + digit;
   10488:	fbc42703          	lw	a4,-68(s0)
   1048c:	fe843783          	ld	a5,-24(s0)
   10490:	02f70733          	mul	a4,a4,a5
   10494:	fd442783          	lw	a5,-44(s0)
   10498:	00f707b3          	add	a5,a4,a5
   1049c:	fef43423          	sd	a5,-24(s0)
        p++;
   104a0:	fd843783          	ld	a5,-40(s0)
   104a4:	00178793          	addi	a5,a5,1
   104a8:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
   104ac:	f0dff06f          	j	103b8 <strtol+0x128>
            break;
   104b0:	00000013          	nop
    }

    if (endptr) {
   104b4:	fc043783          	ld	a5,-64(s0)
   104b8:	00078863          	beqz	a5,104c8 <strtol+0x238>
        *endptr = (char *)p;
   104bc:	fc043783          	ld	a5,-64(s0)
   104c0:	fd843703          	ld	a4,-40(s0)
   104c4:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
   104c8:	fe744783          	lbu	a5,-25(s0)
   104cc:	0ff7f793          	andi	a5,a5,255
   104d0:	00078863          	beqz	a5,104e0 <strtol+0x250>
   104d4:	fe843783          	ld	a5,-24(s0)
   104d8:	40f007b3          	neg	a5,a5
   104dc:	0080006f          	j	104e4 <strtol+0x254>
   104e0:	fe843783          	ld	a5,-24(s0)
}
   104e4:	00078513          	mv	a0,a5
   104e8:	04813083          	ld	ra,72(sp)
   104ec:	04013403          	ld	s0,64(sp)
   104f0:	05010113          	addi	sp,sp,80
   104f4:	00008067          	ret

00000000000104f8 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
   104f8:	fd010113          	addi	sp,sp,-48
   104fc:	02113423          	sd	ra,40(sp)
   10500:	02813023          	sd	s0,32(sp)
   10504:	03010413          	addi	s0,sp,48
   10508:	fca43c23          	sd	a0,-40(s0)
   1050c:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
   10510:	fd043783          	ld	a5,-48(s0)
   10514:	00079863          	bnez	a5,10524 <puts_wo_nl+0x2c>
        s = "(null)";
   10518:	00001797          	auipc	a5,0x1
   1051c:	c9078793          	addi	a5,a5,-880 # 111a8 <printf+0x138>
   10520:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
   10524:	fd043783          	ld	a5,-48(s0)
   10528:	fef43423          	sd	a5,-24(s0)
    while (*p) {
   1052c:	0240006f          	j	10550 <puts_wo_nl+0x58>
        putch(*p++);
   10530:	fe843783          	ld	a5,-24(s0)
   10534:	00178713          	addi	a4,a5,1
   10538:	fee43423          	sd	a4,-24(s0)
   1053c:	0007c783          	lbu	a5,0(a5)
   10540:	0007879b          	sext.w	a5,a5
   10544:	fd843703          	ld	a4,-40(s0)
   10548:	00078513          	mv	a0,a5
   1054c:	000700e7          	jalr	a4
    while (*p) {
   10550:	fe843783          	ld	a5,-24(s0)
   10554:	0007c783          	lbu	a5,0(a5)
   10558:	fc079ce3          	bnez	a5,10530 <puts_wo_nl+0x38>
    }
    return p - s;
   1055c:	fe843703          	ld	a4,-24(s0)
   10560:	fd043783          	ld	a5,-48(s0)
   10564:	40f707b3          	sub	a5,a4,a5
   10568:	0007879b          	sext.w	a5,a5
}
   1056c:	00078513          	mv	a0,a5
   10570:	02813083          	ld	ra,40(sp)
   10574:	02013403          	ld	s0,32(sp)
   10578:	03010113          	addi	sp,sp,48
   1057c:	00008067          	ret

0000000000010580 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
   10580:	f9010113          	addi	sp,sp,-112
   10584:	06113423          	sd	ra,104(sp)
   10588:	06813023          	sd	s0,96(sp)
   1058c:	07010413          	addi	s0,sp,112
   10590:	faa43423          	sd	a0,-88(s0)
   10594:	fab43023          	sd	a1,-96(s0)
   10598:	00060793          	mv	a5,a2
   1059c:	f8d43823          	sd	a3,-112(s0)
   105a0:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
   105a4:	f9f44783          	lbu	a5,-97(s0)
   105a8:	0ff7f793          	andi	a5,a5,255
   105ac:	02078663          	beqz	a5,105d8 <print_dec_int+0x58>
   105b0:	fa043703          	ld	a4,-96(s0)
   105b4:	fff00793          	li	a5,-1
   105b8:	03f79793          	slli	a5,a5,0x3f
   105bc:	00f71e63          	bne	a4,a5,105d8 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
   105c0:	00001597          	auipc	a1,0x1
   105c4:	bf058593          	addi	a1,a1,-1040 # 111b0 <printf+0x140>
   105c8:	fa843503          	ld	a0,-88(s0)
   105cc:	f2dff0ef          	jal	ra,104f8 <puts_wo_nl>
   105d0:	00050793          	mv	a5,a0
   105d4:	2980006f          	j	1086c <print_dec_int+0x2ec>
    }

    if (flags->prec == 0 && num == 0) {
   105d8:	f9043783          	ld	a5,-112(s0)
   105dc:	00c7a783          	lw	a5,12(a5)
   105e0:	00079a63          	bnez	a5,105f4 <print_dec_int+0x74>
   105e4:	fa043783          	ld	a5,-96(s0)
   105e8:	00079663          	bnez	a5,105f4 <print_dec_int+0x74>
        return 0;
   105ec:	00000793          	li	a5,0
   105f0:	27c0006f          	j	1086c <print_dec_int+0x2ec>
    }

    bool neg = false;
   105f4:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
   105f8:	f9f44783          	lbu	a5,-97(s0)
   105fc:	0ff7f793          	andi	a5,a5,255
   10600:	02078063          	beqz	a5,10620 <print_dec_int+0xa0>
   10604:	fa043783          	ld	a5,-96(s0)
   10608:	0007dc63          	bgez	a5,10620 <print_dec_int+0xa0>
        neg = true;
   1060c:	00100793          	li	a5,1
   10610:	fef407a3          	sb	a5,-17(s0)
        num = -num;
   10614:	fa043783          	ld	a5,-96(s0)
   10618:	40f007b3          	neg	a5,a5
   1061c:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
   10620:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
   10624:	f9f44783          	lbu	a5,-97(s0)
   10628:	0ff7f793          	andi	a5,a5,255
   1062c:	02078863          	beqz	a5,1065c <print_dec_int+0xdc>
   10630:	fef44783          	lbu	a5,-17(s0)
   10634:	0ff7f793          	andi	a5,a5,255
   10638:	00079e63          	bnez	a5,10654 <print_dec_int+0xd4>
   1063c:	f9043783          	ld	a5,-112(s0)
   10640:	0057c783          	lbu	a5,5(a5)
   10644:	00079863          	bnez	a5,10654 <print_dec_int+0xd4>
   10648:	f9043783          	ld	a5,-112(s0)
   1064c:	0047c783          	lbu	a5,4(a5)
   10650:	00078663          	beqz	a5,1065c <print_dec_int+0xdc>
   10654:	00100793          	li	a5,1
   10658:	0080006f          	j	10660 <print_dec_int+0xe0>
   1065c:	00000793          	li	a5,0
   10660:	fcf40ba3          	sb	a5,-41(s0)
   10664:	fd744783          	lbu	a5,-41(s0)
   10668:	0017f793          	andi	a5,a5,1
   1066c:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
   10670:	fa043703          	ld	a4,-96(s0)
   10674:	00a00793          	li	a5,10
   10678:	02f777b3          	remu	a5,a4,a5
   1067c:	0ff7f713          	andi	a4,a5,255
   10680:	fe842783          	lw	a5,-24(s0)
   10684:	0017869b          	addiw	a3,a5,1
   10688:	fed42423          	sw	a3,-24(s0)
   1068c:	0307071b          	addiw	a4,a4,48
   10690:	0ff77713          	andi	a4,a4,255
   10694:	ff040693          	addi	a3,s0,-16
   10698:	00f687b3          	add	a5,a3,a5
   1069c:	fce78423          	sb	a4,-56(a5)
        num /= 10;
   106a0:	fa043703          	ld	a4,-96(s0)
   106a4:	00a00793          	li	a5,10
   106a8:	02f757b3          	divu	a5,a4,a5
   106ac:	faf43023          	sd	a5,-96(s0)
    } while (num);
   106b0:	fa043783          	ld	a5,-96(s0)
   106b4:	fa079ee3          	bnez	a5,10670 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
   106b8:	f9043783          	ld	a5,-112(s0)
   106bc:	00c7a783          	lw	a5,12(a5)
   106c0:	00078713          	mv	a4,a5
   106c4:	fff00793          	li	a5,-1
   106c8:	02f71063          	bne	a4,a5,106e8 <print_dec_int+0x168>
   106cc:	f9043783          	ld	a5,-112(s0)
   106d0:	0037c783          	lbu	a5,3(a5)
   106d4:	00078a63          	beqz	a5,106e8 <print_dec_int+0x168>
        flags->prec = flags->width;
   106d8:	f9043783          	ld	a5,-112(s0)
   106dc:	0087a703          	lw	a4,8(a5)
   106e0:	f9043783          	ld	a5,-112(s0)
   106e4:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
   106e8:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
   106ec:	f9043783          	ld	a5,-112(s0)
   106f0:	0087a703          	lw	a4,8(a5)
   106f4:	fe842783          	lw	a5,-24(s0)
   106f8:	fcf42823          	sw	a5,-48(s0)
   106fc:	f9043783          	ld	a5,-112(s0)
   10700:	00c7a783          	lw	a5,12(a5)
   10704:	fcf42623          	sw	a5,-52(s0)
   10708:	fd042583          	lw	a1,-48(s0)
   1070c:	fcc42783          	lw	a5,-52(s0)
   10710:	0007861b          	sext.w	a2,a5
   10714:	0005869b          	sext.w	a3,a1
   10718:	00d65463          	bge	a2,a3,10720 <print_dec_int+0x1a0>
   1071c:	00058793          	mv	a5,a1
   10720:	0007879b          	sext.w	a5,a5
   10724:	40f707bb          	subw	a5,a4,a5
   10728:	0007871b          	sext.w	a4,a5
   1072c:	fd744783          	lbu	a5,-41(s0)
   10730:	0007879b          	sext.w	a5,a5
   10734:	40f707bb          	subw	a5,a4,a5
   10738:	fef42023          	sw	a5,-32(s0)
   1073c:	0280006f          	j	10764 <print_dec_int+0x1e4>
        putch(' ');
   10740:	fa843783          	ld	a5,-88(s0)
   10744:	02000513          	li	a0,32
   10748:	000780e7          	jalr	a5
        ++written;
   1074c:	fe442783          	lw	a5,-28(s0)
   10750:	0017879b          	addiw	a5,a5,1
   10754:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
   10758:	fe042783          	lw	a5,-32(s0)
   1075c:	fff7879b          	addiw	a5,a5,-1
   10760:	fef42023          	sw	a5,-32(s0)
   10764:	fe042783          	lw	a5,-32(s0)
   10768:	0007879b          	sext.w	a5,a5
   1076c:	fcf04ae3          	bgtz	a5,10740 <print_dec_int+0x1c0>
    }

    if (has_sign_char) {
   10770:	fd744783          	lbu	a5,-41(s0)
   10774:	0ff7f793          	andi	a5,a5,255
   10778:	04078463          	beqz	a5,107c0 <print_dec_int+0x240>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
   1077c:	fef44783          	lbu	a5,-17(s0)
   10780:	0ff7f793          	andi	a5,a5,255
   10784:	00078663          	beqz	a5,10790 <print_dec_int+0x210>
   10788:	02d00793          	li	a5,45
   1078c:	01c0006f          	j	107a8 <print_dec_int+0x228>
   10790:	f9043783          	ld	a5,-112(s0)
   10794:	0057c783          	lbu	a5,5(a5)
   10798:	00078663          	beqz	a5,107a4 <print_dec_int+0x224>
   1079c:	02b00793          	li	a5,43
   107a0:	0080006f          	j	107a8 <print_dec_int+0x228>
   107a4:	02000793          	li	a5,32
   107a8:	fa843703          	ld	a4,-88(s0)
   107ac:	00078513          	mv	a0,a5
   107b0:	000700e7          	jalr	a4
        ++written;
   107b4:	fe442783          	lw	a5,-28(s0)
   107b8:	0017879b          	addiw	a5,a5,1
   107bc:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
   107c0:	fe842783          	lw	a5,-24(s0)
   107c4:	fcf42e23          	sw	a5,-36(s0)
   107c8:	0280006f          	j	107f0 <print_dec_int+0x270>
        putch('0');
   107cc:	fa843783          	ld	a5,-88(s0)
   107d0:	03000513          	li	a0,48
   107d4:	000780e7          	jalr	a5
        ++written;
   107d8:	fe442783          	lw	a5,-28(s0)
   107dc:	0017879b          	addiw	a5,a5,1
   107e0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
   107e4:	fdc42783          	lw	a5,-36(s0)
   107e8:	0017879b          	addiw	a5,a5,1
   107ec:	fcf42e23          	sw	a5,-36(s0)
   107f0:	f9043783          	ld	a5,-112(s0)
   107f4:	00c7a703          	lw	a4,12(a5)
   107f8:	fd744783          	lbu	a5,-41(s0)
   107fc:	0007879b          	sext.w	a5,a5
   10800:	40f707bb          	subw	a5,a4,a5
   10804:	0007871b          	sext.w	a4,a5
   10808:	fdc42783          	lw	a5,-36(s0)
   1080c:	0007879b          	sext.w	a5,a5
   10810:	fae7cee3          	blt	a5,a4,107cc <print_dec_int+0x24c>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
   10814:	fe842783          	lw	a5,-24(s0)
   10818:	fff7879b          	addiw	a5,a5,-1
   1081c:	fcf42c23          	sw	a5,-40(s0)
   10820:	03c0006f          	j	1085c <print_dec_int+0x2dc>
        putch(buf[i]);
   10824:	fd842783          	lw	a5,-40(s0)
   10828:	ff040713          	addi	a4,s0,-16
   1082c:	00f707b3          	add	a5,a4,a5
   10830:	fc87c783          	lbu	a5,-56(a5)
   10834:	0007879b          	sext.w	a5,a5
   10838:	fa843703          	ld	a4,-88(s0)
   1083c:	00078513          	mv	a0,a5
   10840:	000700e7          	jalr	a4
        ++written;
   10844:	fe442783          	lw	a5,-28(s0)
   10848:	0017879b          	addiw	a5,a5,1
   1084c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
   10850:	fd842783          	lw	a5,-40(s0)
   10854:	fff7879b          	addiw	a5,a5,-1
   10858:	fcf42c23          	sw	a5,-40(s0)
   1085c:	fd842783          	lw	a5,-40(s0)
   10860:	0007879b          	sext.w	a5,a5
   10864:	fc07d0e3          	bgez	a5,10824 <print_dec_int+0x2a4>
    }

    return written;
   10868:	fe442783          	lw	a5,-28(s0)
}
   1086c:	00078513          	mv	a0,a5
   10870:	06813083          	ld	ra,104(sp)
   10874:	06013403          	ld	s0,96(sp)
   10878:	07010113          	addi	sp,sp,112
   1087c:	00008067          	ret

0000000000010880 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
   10880:	f4010113          	addi	sp,sp,-192
   10884:	0a113c23          	sd	ra,184(sp)
   10888:	0a813823          	sd	s0,176(sp)
   1088c:	0c010413          	addi	s0,sp,192
   10890:	f4a43c23          	sd	a0,-168(s0)
   10894:	f4b43823          	sd	a1,-176(s0)
   10898:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
   1089c:	f8043023          	sd	zero,-128(s0)
   108a0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
   108a4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
   108a8:	7a40006f          	j	1104c <vprintfmt+0x7cc>
        if (flags.in_format) {
   108ac:	f8044783          	lbu	a5,-128(s0)
   108b0:	72078e63          	beqz	a5,10fec <vprintfmt+0x76c>
            if (*fmt == '#') {
   108b4:	f5043783          	ld	a5,-176(s0)
   108b8:	0007c783          	lbu	a5,0(a5)
   108bc:	00078713          	mv	a4,a5
   108c0:	02300793          	li	a5,35
   108c4:	00f71863          	bne	a4,a5,108d4 <vprintfmt+0x54>
                flags.sharpflag = true;
   108c8:	00100793          	li	a5,1
   108cc:	f8f40123          	sb	a5,-126(s0)
   108d0:	7700006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
   108d4:	f5043783          	ld	a5,-176(s0)
   108d8:	0007c783          	lbu	a5,0(a5)
   108dc:	00078713          	mv	a4,a5
   108e0:	03000793          	li	a5,48
   108e4:	00f71863          	bne	a4,a5,108f4 <vprintfmt+0x74>
                flags.zeroflag = true;
   108e8:	00100793          	li	a5,1
   108ec:	f8f401a3          	sb	a5,-125(s0)
   108f0:	7500006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
   108f4:	f5043783          	ld	a5,-176(s0)
   108f8:	0007c783          	lbu	a5,0(a5)
   108fc:	00078713          	mv	a4,a5
   10900:	06c00793          	li	a5,108
   10904:	04f70063          	beq	a4,a5,10944 <vprintfmt+0xc4>
   10908:	f5043783          	ld	a5,-176(s0)
   1090c:	0007c783          	lbu	a5,0(a5)
   10910:	00078713          	mv	a4,a5
   10914:	07a00793          	li	a5,122
   10918:	02f70663          	beq	a4,a5,10944 <vprintfmt+0xc4>
   1091c:	f5043783          	ld	a5,-176(s0)
   10920:	0007c783          	lbu	a5,0(a5)
   10924:	00078713          	mv	a4,a5
   10928:	07400793          	li	a5,116
   1092c:	00f70c63          	beq	a4,a5,10944 <vprintfmt+0xc4>
   10930:	f5043783          	ld	a5,-176(s0)
   10934:	0007c783          	lbu	a5,0(a5)
   10938:	00078713          	mv	a4,a5
   1093c:	06a00793          	li	a5,106
   10940:	00f71863          	bne	a4,a5,10950 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
   10944:	00100793          	li	a5,1
   10948:	f8f400a3          	sb	a5,-127(s0)
   1094c:	6f40006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
   10950:	f5043783          	ld	a5,-176(s0)
   10954:	0007c783          	lbu	a5,0(a5)
   10958:	00078713          	mv	a4,a5
   1095c:	02b00793          	li	a5,43
   10960:	00f71863          	bne	a4,a5,10970 <vprintfmt+0xf0>
                flags.sign = true;
   10964:	00100793          	li	a5,1
   10968:	f8f402a3          	sb	a5,-123(s0)
   1096c:	6d40006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
   10970:	f5043783          	ld	a5,-176(s0)
   10974:	0007c783          	lbu	a5,0(a5)
   10978:	00078713          	mv	a4,a5
   1097c:	02000793          	li	a5,32
   10980:	00f71863          	bne	a4,a5,10990 <vprintfmt+0x110>
                flags.spaceflag = true;
   10984:	00100793          	li	a5,1
   10988:	f8f40223          	sb	a5,-124(s0)
   1098c:	6b40006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
   10990:	f5043783          	ld	a5,-176(s0)
   10994:	0007c783          	lbu	a5,0(a5)
   10998:	00078713          	mv	a4,a5
   1099c:	02a00793          	li	a5,42
   109a0:	00f71e63          	bne	a4,a5,109bc <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
   109a4:	f4843783          	ld	a5,-184(s0)
   109a8:	00878713          	addi	a4,a5,8
   109ac:	f4e43423          	sd	a4,-184(s0)
   109b0:	0007a783          	lw	a5,0(a5)
   109b4:	f8f42423          	sw	a5,-120(s0)
   109b8:	6880006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
   109bc:	f5043783          	ld	a5,-176(s0)
   109c0:	0007c783          	lbu	a5,0(a5)
   109c4:	00078713          	mv	a4,a5
   109c8:	03000793          	li	a5,48
   109cc:	04e7f663          	bgeu	a5,a4,10a18 <vprintfmt+0x198>
   109d0:	f5043783          	ld	a5,-176(s0)
   109d4:	0007c783          	lbu	a5,0(a5)
   109d8:	00078713          	mv	a4,a5
   109dc:	03900793          	li	a5,57
   109e0:	02e7ec63          	bltu	a5,a4,10a18 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
   109e4:	f5043783          	ld	a5,-176(s0)
   109e8:	f5040713          	addi	a4,s0,-176
   109ec:	00a00613          	li	a2,10
   109f0:	00070593          	mv	a1,a4
   109f4:	00078513          	mv	a0,a5
   109f8:	899ff0ef          	jal	ra,10290 <strtol>
   109fc:	00050793          	mv	a5,a0
   10a00:	0007879b          	sext.w	a5,a5
   10a04:	f8f42423          	sw	a5,-120(s0)
                fmt--;
   10a08:	f5043783          	ld	a5,-176(s0)
   10a0c:	fff78793          	addi	a5,a5,-1
   10a10:	f4f43823          	sd	a5,-176(s0)
   10a14:	62c0006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
   10a18:	f5043783          	ld	a5,-176(s0)
   10a1c:	0007c783          	lbu	a5,0(a5)
   10a20:	00078713          	mv	a4,a5
   10a24:	02e00793          	li	a5,46
   10a28:	06f71863          	bne	a4,a5,10a98 <vprintfmt+0x218>
                fmt++;
   10a2c:	f5043783          	ld	a5,-176(s0)
   10a30:	00178793          	addi	a5,a5,1
   10a34:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
   10a38:	f5043783          	ld	a5,-176(s0)
   10a3c:	0007c783          	lbu	a5,0(a5)
   10a40:	00078713          	mv	a4,a5
   10a44:	02a00793          	li	a5,42
   10a48:	00f71e63          	bne	a4,a5,10a64 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
   10a4c:	f4843783          	ld	a5,-184(s0)
   10a50:	00878713          	addi	a4,a5,8
   10a54:	f4e43423          	sd	a4,-184(s0)
   10a58:	0007a783          	lw	a5,0(a5)
   10a5c:	f8f42623          	sw	a5,-116(s0)
   10a60:	5e00006f          	j	11040 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
   10a64:	f5043783          	ld	a5,-176(s0)
   10a68:	f5040713          	addi	a4,s0,-176
   10a6c:	00a00613          	li	a2,10
   10a70:	00070593          	mv	a1,a4
   10a74:	00078513          	mv	a0,a5
   10a78:	819ff0ef          	jal	ra,10290 <strtol>
   10a7c:	00050793          	mv	a5,a0
   10a80:	0007879b          	sext.w	a5,a5
   10a84:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
   10a88:	f5043783          	ld	a5,-176(s0)
   10a8c:	fff78793          	addi	a5,a5,-1
   10a90:	f4f43823          	sd	a5,-176(s0)
   10a94:	5ac0006f          	j	11040 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
   10a98:	f5043783          	ld	a5,-176(s0)
   10a9c:	0007c783          	lbu	a5,0(a5)
   10aa0:	00078713          	mv	a4,a5
   10aa4:	07800793          	li	a5,120
   10aa8:	02f70663          	beq	a4,a5,10ad4 <vprintfmt+0x254>
   10aac:	f5043783          	ld	a5,-176(s0)
   10ab0:	0007c783          	lbu	a5,0(a5)
   10ab4:	00078713          	mv	a4,a5
   10ab8:	05800793          	li	a5,88
   10abc:	00f70c63          	beq	a4,a5,10ad4 <vprintfmt+0x254>
   10ac0:	f5043783          	ld	a5,-176(s0)
   10ac4:	0007c783          	lbu	a5,0(a5)
   10ac8:	00078713          	mv	a4,a5
   10acc:	07000793          	li	a5,112
   10ad0:	2ef71e63          	bne	a4,a5,10dcc <vprintfmt+0x54c>
                bool is_long = *fmt == 'p' || flags.longflag;
   10ad4:	f5043783          	ld	a5,-176(s0)
   10ad8:	0007c783          	lbu	a5,0(a5)
   10adc:	00078713          	mv	a4,a5
   10ae0:	07000793          	li	a5,112
   10ae4:	00f70663          	beq	a4,a5,10af0 <vprintfmt+0x270>
   10ae8:	f8144783          	lbu	a5,-127(s0)
   10aec:	00078663          	beqz	a5,10af8 <vprintfmt+0x278>
   10af0:	00100793          	li	a5,1
   10af4:	0080006f          	j	10afc <vprintfmt+0x27c>
   10af8:	00000793          	li	a5,0
   10afc:	faf403a3          	sb	a5,-89(s0)
   10b00:	fa744783          	lbu	a5,-89(s0)
   10b04:	0017f793          	andi	a5,a5,1
   10b08:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
   10b0c:	fa744783          	lbu	a5,-89(s0)
   10b10:	0ff7f793          	andi	a5,a5,255
   10b14:	00078c63          	beqz	a5,10b2c <vprintfmt+0x2ac>
   10b18:	f4843783          	ld	a5,-184(s0)
   10b1c:	00878713          	addi	a4,a5,8
   10b20:	f4e43423          	sd	a4,-184(s0)
   10b24:	0007b783          	ld	a5,0(a5)
   10b28:	01c0006f          	j	10b44 <vprintfmt+0x2c4>
   10b2c:	f4843783          	ld	a5,-184(s0)
   10b30:	00878713          	addi	a4,a5,8
   10b34:	f4e43423          	sd	a4,-184(s0)
   10b38:	0007a783          	lw	a5,0(a5)
   10b3c:	02079793          	slli	a5,a5,0x20
   10b40:	0207d793          	srli	a5,a5,0x20
   10b44:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
   10b48:	f8c42783          	lw	a5,-116(s0)
   10b4c:	02079463          	bnez	a5,10b74 <vprintfmt+0x2f4>
   10b50:	fe043783          	ld	a5,-32(s0)
   10b54:	02079063          	bnez	a5,10b74 <vprintfmt+0x2f4>
   10b58:	f5043783          	ld	a5,-176(s0)
   10b5c:	0007c783          	lbu	a5,0(a5)
   10b60:	00078713          	mv	a4,a5
   10b64:	07000793          	li	a5,112
   10b68:	00f70663          	beq	a4,a5,10b74 <vprintfmt+0x2f4>
                    flags.in_format = false;
   10b6c:	f8040023          	sb	zero,-128(s0)
   10b70:	4d00006f          	j	11040 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
   10b74:	f5043783          	ld	a5,-176(s0)
   10b78:	0007c783          	lbu	a5,0(a5)
   10b7c:	00078713          	mv	a4,a5
   10b80:	07000793          	li	a5,112
   10b84:	00f70a63          	beq	a4,a5,10b98 <vprintfmt+0x318>
   10b88:	f8244783          	lbu	a5,-126(s0)
   10b8c:	00078a63          	beqz	a5,10ba0 <vprintfmt+0x320>
   10b90:	fe043783          	ld	a5,-32(s0)
   10b94:	00078663          	beqz	a5,10ba0 <vprintfmt+0x320>
   10b98:	00100793          	li	a5,1
   10b9c:	0080006f          	j	10ba4 <vprintfmt+0x324>
   10ba0:	00000793          	li	a5,0
   10ba4:	faf40323          	sb	a5,-90(s0)
   10ba8:	fa644783          	lbu	a5,-90(s0)
   10bac:	0017f793          	andi	a5,a5,1
   10bb0:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
   10bb4:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
   10bb8:	f5043783          	ld	a5,-176(s0)
   10bbc:	0007c783          	lbu	a5,0(a5)
   10bc0:	00078713          	mv	a4,a5
   10bc4:	05800793          	li	a5,88
   10bc8:	00f71863          	bne	a4,a5,10bd8 <vprintfmt+0x358>
   10bcc:	00000797          	auipc	a5,0x0
   10bd0:	5fc78793          	addi	a5,a5,1532 # 111c8 <upperxdigits.1056>
   10bd4:	00c0006f          	j	10be0 <vprintfmt+0x360>
   10bd8:	00000797          	auipc	a5,0x0
   10bdc:	60878793          	addi	a5,a5,1544 # 111e0 <lowerxdigits.1055>
   10be0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
   10be4:	fe043783          	ld	a5,-32(s0)
   10be8:	00f7f793          	andi	a5,a5,15
   10bec:	f9843703          	ld	a4,-104(s0)
   10bf0:	00f70733          	add	a4,a4,a5
   10bf4:	fdc42783          	lw	a5,-36(s0)
   10bf8:	0017869b          	addiw	a3,a5,1
   10bfc:	fcd42e23          	sw	a3,-36(s0)
   10c00:	00074703          	lbu	a4,0(a4)
   10c04:	ff040693          	addi	a3,s0,-16
   10c08:	00f687b3          	add	a5,a3,a5
   10c0c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
   10c10:	fe043783          	ld	a5,-32(s0)
   10c14:	0047d793          	srli	a5,a5,0x4
   10c18:	fef43023          	sd	a5,-32(s0)
                } while (num);
   10c1c:	fe043783          	ld	a5,-32(s0)
   10c20:	fc0792e3          	bnez	a5,10be4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
   10c24:	f8c42783          	lw	a5,-116(s0)
   10c28:	00078713          	mv	a4,a5
   10c2c:	fff00793          	li	a5,-1
   10c30:	02f71663          	bne	a4,a5,10c5c <vprintfmt+0x3dc>
   10c34:	f8344783          	lbu	a5,-125(s0)
   10c38:	02078263          	beqz	a5,10c5c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
   10c3c:	f8842703          	lw	a4,-120(s0)
   10c40:	fa644783          	lbu	a5,-90(s0)
   10c44:	0007879b          	sext.w	a5,a5
   10c48:	0017979b          	slliw	a5,a5,0x1
   10c4c:	0007879b          	sext.w	a5,a5
   10c50:	40f707bb          	subw	a5,a4,a5
   10c54:	0007879b          	sext.w	a5,a5
   10c58:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
   10c5c:	f8842703          	lw	a4,-120(s0)
   10c60:	fa644783          	lbu	a5,-90(s0)
   10c64:	0007879b          	sext.w	a5,a5
   10c68:	0017979b          	slliw	a5,a5,0x1
   10c6c:	0007879b          	sext.w	a5,a5
   10c70:	40f707bb          	subw	a5,a4,a5
   10c74:	0007871b          	sext.w	a4,a5
   10c78:	fdc42783          	lw	a5,-36(s0)
   10c7c:	f8f42a23          	sw	a5,-108(s0)
   10c80:	f8c42783          	lw	a5,-116(s0)
   10c84:	f8f42823          	sw	a5,-112(s0)
   10c88:	f9442583          	lw	a1,-108(s0)
   10c8c:	f9042783          	lw	a5,-112(s0)
   10c90:	0007861b          	sext.w	a2,a5
   10c94:	0005869b          	sext.w	a3,a1
   10c98:	00d65463          	bge	a2,a3,10ca0 <vprintfmt+0x420>
   10c9c:	00058793          	mv	a5,a1
   10ca0:	0007879b          	sext.w	a5,a5
   10ca4:	40f707bb          	subw	a5,a4,a5
   10ca8:	fcf42c23          	sw	a5,-40(s0)
   10cac:	0280006f          	j	10cd4 <vprintfmt+0x454>
                    putch(' ');
   10cb0:	f5843783          	ld	a5,-168(s0)
   10cb4:	02000513          	li	a0,32
   10cb8:	000780e7          	jalr	a5
                    ++written;
   10cbc:	fec42783          	lw	a5,-20(s0)
   10cc0:	0017879b          	addiw	a5,a5,1
   10cc4:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
   10cc8:	fd842783          	lw	a5,-40(s0)
   10ccc:	fff7879b          	addiw	a5,a5,-1
   10cd0:	fcf42c23          	sw	a5,-40(s0)
   10cd4:	fd842783          	lw	a5,-40(s0)
   10cd8:	0007879b          	sext.w	a5,a5
   10cdc:	fcf04ae3          	bgtz	a5,10cb0 <vprintfmt+0x430>
                }

                if (prefix) {
   10ce0:	fa644783          	lbu	a5,-90(s0)
   10ce4:	0ff7f793          	andi	a5,a5,255
   10ce8:	04078463          	beqz	a5,10d30 <vprintfmt+0x4b0>
                    putch('0');
   10cec:	f5843783          	ld	a5,-168(s0)
   10cf0:	03000513          	li	a0,48
   10cf4:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
   10cf8:	f5043783          	ld	a5,-176(s0)
   10cfc:	0007c783          	lbu	a5,0(a5)
   10d00:	00078713          	mv	a4,a5
   10d04:	05800793          	li	a5,88
   10d08:	00f71663          	bne	a4,a5,10d14 <vprintfmt+0x494>
   10d0c:	05800793          	li	a5,88
   10d10:	0080006f          	j	10d18 <vprintfmt+0x498>
   10d14:	07800793          	li	a5,120
   10d18:	f5843703          	ld	a4,-168(s0)
   10d1c:	00078513          	mv	a0,a5
   10d20:	000700e7          	jalr	a4
                    written += 2;
   10d24:	fec42783          	lw	a5,-20(s0)
   10d28:	0027879b          	addiw	a5,a5,2
   10d2c:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
   10d30:	fdc42783          	lw	a5,-36(s0)
   10d34:	fcf42a23          	sw	a5,-44(s0)
   10d38:	0280006f          	j	10d60 <vprintfmt+0x4e0>
                    putch('0');
   10d3c:	f5843783          	ld	a5,-168(s0)
   10d40:	03000513          	li	a0,48
   10d44:	000780e7          	jalr	a5
                    ++written;
   10d48:	fec42783          	lw	a5,-20(s0)
   10d4c:	0017879b          	addiw	a5,a5,1
   10d50:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
   10d54:	fd442783          	lw	a5,-44(s0)
   10d58:	0017879b          	addiw	a5,a5,1
   10d5c:	fcf42a23          	sw	a5,-44(s0)
   10d60:	f8c42703          	lw	a4,-116(s0)
   10d64:	fd442783          	lw	a5,-44(s0)
   10d68:	0007879b          	sext.w	a5,a5
   10d6c:	fce7c8e3          	blt	a5,a4,10d3c <vprintfmt+0x4bc>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
   10d70:	fdc42783          	lw	a5,-36(s0)
   10d74:	fff7879b          	addiw	a5,a5,-1
   10d78:	fcf42823          	sw	a5,-48(s0)
   10d7c:	03c0006f          	j	10db8 <vprintfmt+0x538>
                    putch(buf[i]);
   10d80:	fd042783          	lw	a5,-48(s0)
   10d84:	ff040713          	addi	a4,s0,-16
   10d88:	00f707b3          	add	a5,a4,a5
   10d8c:	f807c783          	lbu	a5,-128(a5)
   10d90:	0007879b          	sext.w	a5,a5
   10d94:	f5843703          	ld	a4,-168(s0)
   10d98:	00078513          	mv	a0,a5
   10d9c:	000700e7          	jalr	a4
                    ++written;
   10da0:	fec42783          	lw	a5,-20(s0)
   10da4:	0017879b          	addiw	a5,a5,1
   10da8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
   10dac:	fd042783          	lw	a5,-48(s0)
   10db0:	fff7879b          	addiw	a5,a5,-1
   10db4:	fcf42823          	sw	a5,-48(s0)
   10db8:	fd042783          	lw	a5,-48(s0)
   10dbc:	0007879b          	sext.w	a5,a5
   10dc0:	fc07d0e3          	bgez	a5,10d80 <vprintfmt+0x500>
                }

                flags.in_format = false;
   10dc4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
   10dc8:	2780006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
   10dcc:	f5043783          	ld	a5,-176(s0)
   10dd0:	0007c783          	lbu	a5,0(a5)
   10dd4:	00078713          	mv	a4,a5
   10dd8:	06400793          	li	a5,100
   10ddc:	02f70663          	beq	a4,a5,10e08 <vprintfmt+0x588>
   10de0:	f5043783          	ld	a5,-176(s0)
   10de4:	0007c783          	lbu	a5,0(a5)
   10de8:	00078713          	mv	a4,a5
   10dec:	06900793          	li	a5,105
   10df0:	00f70c63          	beq	a4,a5,10e08 <vprintfmt+0x588>
   10df4:	f5043783          	ld	a5,-176(s0)
   10df8:	0007c783          	lbu	a5,0(a5)
   10dfc:	00078713          	mv	a4,a5
   10e00:	07500793          	li	a5,117
   10e04:	08f71263          	bne	a4,a5,10e88 <vprintfmt+0x608>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
   10e08:	f8144783          	lbu	a5,-127(s0)
   10e0c:	00078c63          	beqz	a5,10e24 <vprintfmt+0x5a4>
   10e10:	f4843783          	ld	a5,-184(s0)
   10e14:	00878713          	addi	a4,a5,8
   10e18:	f4e43423          	sd	a4,-184(s0)
   10e1c:	0007b783          	ld	a5,0(a5)
   10e20:	0140006f          	j	10e34 <vprintfmt+0x5b4>
   10e24:	f4843783          	ld	a5,-184(s0)
   10e28:	00878713          	addi	a4,a5,8
   10e2c:	f4e43423          	sd	a4,-184(s0)
   10e30:	0007a783          	lw	a5,0(a5)
   10e34:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
   10e38:	fa843583          	ld	a1,-88(s0)
   10e3c:	f5043783          	ld	a5,-176(s0)
   10e40:	0007c783          	lbu	a5,0(a5)
   10e44:	0007871b          	sext.w	a4,a5
   10e48:	07500793          	li	a5,117
   10e4c:	40f707b3          	sub	a5,a4,a5
   10e50:	00f037b3          	snez	a5,a5
   10e54:	0ff7f793          	andi	a5,a5,255
   10e58:	f8040713          	addi	a4,s0,-128
   10e5c:	00070693          	mv	a3,a4
   10e60:	00078613          	mv	a2,a5
   10e64:	f5843503          	ld	a0,-168(s0)
   10e68:	f18ff0ef          	jal	ra,10580 <print_dec_int>
   10e6c:	00050793          	mv	a5,a0
   10e70:	00078713          	mv	a4,a5
   10e74:	fec42783          	lw	a5,-20(s0)
   10e78:	00e787bb          	addw	a5,a5,a4
   10e7c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
   10e80:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
   10e84:	1bc0006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
   10e88:	f5043783          	ld	a5,-176(s0)
   10e8c:	0007c783          	lbu	a5,0(a5)
   10e90:	00078713          	mv	a4,a5
   10e94:	06e00793          	li	a5,110
   10e98:	04f71c63          	bne	a4,a5,10ef0 <vprintfmt+0x670>
                if (flags.longflag) {
   10e9c:	f8144783          	lbu	a5,-127(s0)
   10ea0:	02078463          	beqz	a5,10ec8 <vprintfmt+0x648>
                    long *n = va_arg(vl, long *);
   10ea4:	f4843783          	ld	a5,-184(s0)
   10ea8:	00878713          	addi	a4,a5,8
   10eac:	f4e43423          	sd	a4,-184(s0)
   10eb0:	0007b783          	ld	a5,0(a5)
   10eb4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
   10eb8:	fec42703          	lw	a4,-20(s0)
   10ebc:	fb043783          	ld	a5,-80(s0)
   10ec0:	00e7b023          	sd	a4,0(a5)
   10ec4:	0240006f          	j	10ee8 <vprintfmt+0x668>
                } else {
                    int *n = va_arg(vl, int *);
   10ec8:	f4843783          	ld	a5,-184(s0)
   10ecc:	00878713          	addi	a4,a5,8
   10ed0:	f4e43423          	sd	a4,-184(s0)
   10ed4:	0007b783          	ld	a5,0(a5)
   10ed8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
   10edc:	fb843783          	ld	a5,-72(s0)
   10ee0:	fec42703          	lw	a4,-20(s0)
   10ee4:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
   10ee8:	f8040023          	sb	zero,-128(s0)
   10eec:	1540006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
   10ef0:	f5043783          	ld	a5,-176(s0)
   10ef4:	0007c783          	lbu	a5,0(a5)
   10ef8:	00078713          	mv	a4,a5
   10efc:	07300793          	li	a5,115
   10f00:	04f71063          	bne	a4,a5,10f40 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
   10f04:	f4843783          	ld	a5,-184(s0)
   10f08:	00878713          	addi	a4,a5,8
   10f0c:	f4e43423          	sd	a4,-184(s0)
   10f10:	0007b783          	ld	a5,0(a5)
   10f14:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
   10f18:	fc043583          	ld	a1,-64(s0)
   10f1c:	f5843503          	ld	a0,-168(s0)
   10f20:	dd8ff0ef          	jal	ra,104f8 <puts_wo_nl>
   10f24:	00050793          	mv	a5,a0
   10f28:	00078713          	mv	a4,a5
   10f2c:	fec42783          	lw	a5,-20(s0)
   10f30:	00e787bb          	addw	a5,a5,a4
   10f34:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
   10f38:	f8040023          	sb	zero,-128(s0)
   10f3c:	1040006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
   10f40:	f5043783          	ld	a5,-176(s0)
   10f44:	0007c783          	lbu	a5,0(a5)
   10f48:	00078713          	mv	a4,a5
   10f4c:	06300793          	li	a5,99
   10f50:	02f71e63          	bne	a4,a5,10f8c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
   10f54:	f4843783          	ld	a5,-184(s0)
   10f58:	00878713          	addi	a4,a5,8
   10f5c:	f4e43423          	sd	a4,-184(s0)
   10f60:	0007a783          	lw	a5,0(a5)
   10f64:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
   10f68:	fcc42783          	lw	a5,-52(s0)
   10f6c:	f5843703          	ld	a4,-168(s0)
   10f70:	00078513          	mv	a0,a5
   10f74:	000700e7          	jalr	a4
                ++written;
   10f78:	fec42783          	lw	a5,-20(s0)
   10f7c:	0017879b          	addiw	a5,a5,1
   10f80:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
   10f84:	f8040023          	sb	zero,-128(s0)
   10f88:	0b80006f          	j	11040 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
   10f8c:	f5043783          	ld	a5,-176(s0)
   10f90:	0007c783          	lbu	a5,0(a5)
   10f94:	00078713          	mv	a4,a5
   10f98:	02500793          	li	a5,37
   10f9c:	02f71263          	bne	a4,a5,10fc0 <vprintfmt+0x740>
                putch('%');
   10fa0:	f5843783          	ld	a5,-168(s0)
   10fa4:	02500513          	li	a0,37
   10fa8:	000780e7          	jalr	a5
                ++written;
   10fac:	fec42783          	lw	a5,-20(s0)
   10fb0:	0017879b          	addiw	a5,a5,1
   10fb4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
   10fb8:	f8040023          	sb	zero,-128(s0)
   10fbc:	0840006f          	j	11040 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
   10fc0:	f5043783          	ld	a5,-176(s0)
   10fc4:	0007c783          	lbu	a5,0(a5)
   10fc8:	0007879b          	sext.w	a5,a5
   10fcc:	f5843703          	ld	a4,-168(s0)
   10fd0:	00078513          	mv	a0,a5
   10fd4:	000700e7          	jalr	a4
                ++written;
   10fd8:	fec42783          	lw	a5,-20(s0)
   10fdc:	0017879b          	addiw	a5,a5,1
   10fe0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
   10fe4:	f8040023          	sb	zero,-128(s0)
   10fe8:	0580006f          	j	11040 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
   10fec:	f5043783          	ld	a5,-176(s0)
   10ff0:	0007c783          	lbu	a5,0(a5)
   10ff4:	00078713          	mv	a4,a5
   10ff8:	02500793          	li	a5,37
   10ffc:	02f71063          	bne	a4,a5,1101c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
   11000:	f8043023          	sd	zero,-128(s0)
   11004:	f8043423          	sd	zero,-120(s0)
   11008:	00100793          	li	a5,1
   1100c:	f8f40023          	sb	a5,-128(s0)
   11010:	fff00793          	li	a5,-1
   11014:	f8f42623          	sw	a5,-116(s0)
   11018:	0280006f          	j	11040 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
   1101c:	f5043783          	ld	a5,-176(s0)
   11020:	0007c783          	lbu	a5,0(a5)
   11024:	0007879b          	sext.w	a5,a5
   11028:	f5843703          	ld	a4,-168(s0)
   1102c:	00078513          	mv	a0,a5
   11030:	000700e7          	jalr	a4
            ++written;
   11034:	fec42783          	lw	a5,-20(s0)
   11038:	0017879b          	addiw	a5,a5,1
   1103c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
   11040:	f5043783          	ld	a5,-176(s0)
   11044:	00178793          	addi	a5,a5,1
   11048:	f4f43823          	sd	a5,-176(s0)
   1104c:	f5043783          	ld	a5,-176(s0)
   11050:	0007c783          	lbu	a5,0(a5)
   11054:	84079ce3          	bnez	a5,108ac <vprintfmt+0x2c>
        }
    }

    return written;
   11058:	fec42783          	lw	a5,-20(s0)
}
   1105c:	00078513          	mv	a0,a5
   11060:	0b813083          	ld	ra,184(sp)
   11064:	0b013403          	ld	s0,176(sp)
   11068:	0c010113          	addi	sp,sp,192
   1106c:	00008067          	ret

0000000000011070 <printf>:

int printf(const char* s, ...) {
   11070:	f8010113          	addi	sp,sp,-128
   11074:	02113c23          	sd	ra,56(sp)
   11078:	02813823          	sd	s0,48(sp)
   1107c:	04010413          	addi	s0,sp,64
   11080:	fca43423          	sd	a0,-56(s0)
   11084:	00b43423          	sd	a1,8(s0)
   11088:	00c43823          	sd	a2,16(s0)
   1108c:	00d43c23          	sd	a3,24(s0)
   11090:	02e43023          	sd	a4,32(s0)
   11094:	02f43423          	sd	a5,40(s0)
   11098:	03043823          	sd	a6,48(s0)
   1109c:	03143c23          	sd	a7,56(s0)
    int res = 0;
   110a0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
   110a4:	04040793          	addi	a5,s0,64
   110a8:	fcf43023          	sd	a5,-64(s0)
   110ac:	fc043783          	ld	a5,-64(s0)
   110b0:	fc878793          	addi	a5,a5,-56
   110b4:	fcf43823          	sd	a5,-48(s0)
    res = vprintfmt(putc, s, vl);
   110b8:	fd043783          	ld	a5,-48(s0)
   110bc:	00078613          	mv	a2,a5
   110c0:	fc843583          	ld	a1,-56(s0)
   110c4:	fffff517          	auipc	a0,0xfffff
   110c8:	10450513          	addi	a0,a0,260 # 101c8 <putc>
   110cc:	fb4ff0ef          	jal	ra,10880 <vprintfmt>
   110d0:	00050793          	mv	a5,a0
   110d4:	fef42623          	sw	a5,-20(s0)
    long syscall_ret, fd = 1;
   110d8:	00100793          	li	a5,1
   110dc:	fef43023          	sd	a5,-32(s0)
    buffer[tail++] = '\0';
   110e0:	00001797          	auipc	a5,0x1
   110e4:	11878793          	addi	a5,a5,280 # 121f8 <tail>
   110e8:	0007a783          	lw	a5,0(a5)
   110ec:	0017871b          	addiw	a4,a5,1
   110f0:	0007069b          	sext.w	a3,a4
   110f4:	00001717          	auipc	a4,0x1
   110f8:	10470713          	addi	a4,a4,260 # 121f8 <tail>
   110fc:	00d72023          	sw	a3,0(a4)
   11100:	00001717          	auipc	a4,0x1
   11104:	10070713          	addi	a4,a4,256 # 12200 <buffer>
   11108:	00f707b3          	add	a5,a4,a5
   1110c:	00078023          	sb	zero,0(a5)
    asm volatile ("li a7, %1\n"
   11110:	00001797          	auipc	a5,0x1
   11114:	0e878793          	addi	a5,a5,232 # 121f8 <tail>
   11118:	0007a603          	lw	a2,0(a5)
   1111c:	fe043703          	ld	a4,-32(s0)
   11120:	00001697          	auipc	a3,0x1
   11124:	0e068693          	addi	a3,a3,224 # 12200 <buffer>
   11128:	fd843783          	ld	a5,-40(s0)
   1112c:	04000893          	li	a7,64
   11130:	00070513          	mv	a0,a4
   11134:	00068593          	mv	a1,a3
   11138:	00060613          	mv	a2,a2
   1113c:	00000073          	ecall
   11140:	00050793          	mv	a5,a0
   11144:	fcf43c23          	sd	a5,-40(s0)
                  "mv a2, %4\n"
                  "ecall\n"
                  "mv %0, a0\n"
                  : "+r" (syscall_ret)
                  : "i" (SYS_WRITE), "r" (fd), "r" (&buffer), "r" (tail));
    tail = 0;
   11148:	00001797          	auipc	a5,0x1
   1114c:	0b078793          	addi	a5,a5,176 # 121f8 <tail>
   11150:	0007a023          	sw	zero,0(a5)
    va_end(vl);
    return res;
   11154:	fec42783          	lw	a5,-20(s0)
}
   11158:	00078513          	mv	a0,a5
   1115c:	03813083          	ld	ra,56(sp)
   11160:	03013403          	ld	s0,48(sp)
   11164:	08010113          	addi	sp,sp,128
   11168:	00008067          	ret
