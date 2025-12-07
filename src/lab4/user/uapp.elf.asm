
uapp.elf:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000000000000 <_start>:
   0:	0380006f          	j	38 <main>

Disassembly of section .text.getpid:

0000000000000004 <getpid>:
   4:	fe010113          	addi	sp,sp,-32
   8:	00813c23          	sd	s0,24(sp)
   c:	02010413          	addi	s0,sp,32
  10:	fe843783          	ld	a5,-24(s0)
  14:	0ac00893          	li	a7,172
  18:	00000073          	ecall
  1c:	00050793          	mv	a5,a0
  20:	fef43423          	sd	a5,-24(s0)
  24:	fe843783          	ld	a5,-24(s0)
  28:	00078513          	mv	a0,a5
  2c:	01813403          	ld	s0,24(sp)
  30:	02010113          	addi	sp,sp,32
  34:	00008067          	ret

Disassembly of section .text.main:

0000000000000038 <main>:
  38:	fe010113          	addi	sp,sp,-32
  3c:	00113c23          	sd	ra,24(sp)
  40:	00813823          	sd	s0,16(sp)
  44:	02010413          	addi	s0,sp,32
  48:	00000097          	auipc	ra,0x0
  4c:	fbc080e7          	jalr	-68(ra) # 4 <getpid>
  50:	00050593          	mv	a1,a0
  54:	00010613          	mv	a2,sp
  58:	00001797          	auipc	a5,0x1
  5c:	0b478793          	addi	a5,a5,180 # 110c <counter>
  60:	0007a783          	lw	a5,0(a5)
  64:	0017879b          	addiw	a5,a5,1
  68:	0007871b          	sext.w	a4,a5
  6c:	00001797          	auipc	a5,0x1
  70:	0a078793          	addi	a5,a5,160 # 110c <counter>
  74:	00e7a023          	sw	a4,0(a5)
  78:	00001797          	auipc	a5,0x1
  7c:	09478793          	addi	a5,a5,148 # 110c <counter>
  80:	0007a783          	lw	a5,0(a5)
  84:	00078693          	mv	a3,a5
  88:	00001517          	auipc	a0,0x1
  8c:	00050513          	mv	a0,a0
  90:	00001097          	auipc	ra,0x1
  94:	ef4080e7          	jalr	-268(ra) # f84 <printf>
  98:	fe042623          	sw	zero,-20(s0)
  9c:	0100006f          	j	ac <main+0x74>
  a0:	fec42783          	lw	a5,-20(s0)
  a4:	0017879b          	addiw	a5,a5,1
  a8:	fef42623          	sw	a5,-20(s0)
  ac:	fec42783          	lw	a5,-20(s0)
  b0:	0007871b          	sext.w	a4,a5
  b4:	500007b7          	lui	a5,0x50000
  b8:	ffe78793          	addi	a5,a5,-2 # 4ffffffe <buffer+0x4fffeee6>
  bc:	fee7f2e3          	bgeu	a5,a4,a0 <main+0x68>
  c0:	f89ff06f          	j	48 <main+0x10>

Disassembly of section .text.putc:

00000000000000c4 <putc>:
  c4:	fe010113          	addi	sp,sp,-32
  c8:	00813c23          	sd	s0,24(sp)
  cc:	02010413          	addi	s0,sp,32
  d0:	00050793          	mv	a5,a0
  d4:	fef42623          	sw	a5,-20(s0)
  d8:	00001797          	auipc	a5,0x1
  dc:	03878793          	addi	a5,a5,56 # 1110 <tail>
  e0:	0007a783          	lw	a5,0(a5)
  e4:	0017871b          	addiw	a4,a5,1
  e8:	0007069b          	sext.w	a3,a4
  ec:	00001717          	auipc	a4,0x1
  f0:	02470713          	addi	a4,a4,36 # 1110 <tail>
  f4:	00d72023          	sw	a3,0(a4)
  f8:	fec42703          	lw	a4,-20(s0)
  fc:	0ff77713          	andi	a4,a4,255
 100:	00001697          	auipc	a3,0x1
 104:	01868693          	addi	a3,a3,24 # 1118 <buffer>
 108:	00f687b3          	add	a5,a3,a5
 10c:	00e78023          	sb	a4,0(a5)
 110:	fec42783          	lw	a5,-20(s0)
 114:	0ff7f793          	andi	a5,a5,255
 118:	0007879b          	sext.w	a5,a5
 11c:	00078513          	mv	a0,a5
 120:	01813403          	ld	s0,24(sp)
 124:	02010113          	addi	sp,sp,32
 128:	00008067          	ret

Disassembly of section .text.isspace:

000000000000012c <isspace>:
 12c:	fe010113          	addi	sp,sp,-32
 130:	00813c23          	sd	s0,24(sp)
 134:	02010413          	addi	s0,sp,32
 138:	00050793          	mv	a5,a0
 13c:	fef42623          	sw	a5,-20(s0)
 140:	fec42783          	lw	a5,-20(s0)
 144:	0007871b          	sext.w	a4,a5
 148:	02000793          	li	a5,32
 14c:	02f70263          	beq	a4,a5,170 <isspace+0x44>
 150:	fec42783          	lw	a5,-20(s0)
 154:	0007871b          	sext.w	a4,a5
 158:	00800793          	li	a5,8
 15c:	00e7de63          	bge	a5,a4,178 <isspace+0x4c>
 160:	fec42783          	lw	a5,-20(s0)
 164:	0007871b          	sext.w	a4,a5
 168:	00d00793          	li	a5,13
 16c:	00e7c663          	blt	a5,a4,178 <isspace+0x4c>
 170:	00100793          	li	a5,1
 174:	0080006f          	j	17c <isspace+0x50>
 178:	00000793          	li	a5,0
 17c:	00078513          	mv	a0,a5
 180:	01813403          	ld	s0,24(sp)
 184:	02010113          	addi	sp,sp,32
 188:	00008067          	ret

Disassembly of section .text.strtol:

000000000000018c <strtol>:
 18c:	fb010113          	addi	sp,sp,-80
 190:	04113423          	sd	ra,72(sp)
 194:	04813023          	sd	s0,64(sp)
 198:	05010413          	addi	s0,sp,80
 19c:	fca43423          	sd	a0,-56(s0)
 1a0:	fcb43023          	sd	a1,-64(s0)
 1a4:	00060793          	mv	a5,a2
 1a8:	faf42e23          	sw	a5,-68(s0)
 1ac:	fe043423          	sd	zero,-24(s0)
 1b0:	fe0403a3          	sb	zero,-25(s0)
 1b4:	fc843783          	ld	a5,-56(s0)
 1b8:	fcf43c23          	sd	a5,-40(s0)
 1bc:	0100006f          	j	1cc <strtol+0x40>
 1c0:	fd843783          	ld	a5,-40(s0)
 1c4:	00178793          	addi	a5,a5,1
 1c8:	fcf43c23          	sd	a5,-40(s0)
 1cc:	fd843783          	ld	a5,-40(s0)
 1d0:	0007c783          	lbu	a5,0(a5)
 1d4:	0007879b          	sext.w	a5,a5
 1d8:	00078513          	mv	a0,a5
 1dc:	00000097          	auipc	ra,0x0
 1e0:	f50080e7          	jalr	-176(ra) # 12c <isspace>
 1e4:	00050793          	mv	a5,a0
 1e8:	fc079ce3          	bnez	a5,1c0 <strtol+0x34>
 1ec:	fd843783          	ld	a5,-40(s0)
 1f0:	0007c783          	lbu	a5,0(a5)
 1f4:	00078713          	mv	a4,a5
 1f8:	02d00793          	li	a5,45
 1fc:	00f71e63          	bne	a4,a5,218 <strtol+0x8c>
 200:	00100793          	li	a5,1
 204:	fef403a3          	sb	a5,-25(s0)
 208:	fd843783          	ld	a5,-40(s0)
 20c:	00178793          	addi	a5,a5,1
 210:	fcf43c23          	sd	a5,-40(s0)
 214:	0240006f          	j	238 <strtol+0xac>
 218:	fd843783          	ld	a5,-40(s0)
 21c:	0007c783          	lbu	a5,0(a5)
 220:	00078713          	mv	a4,a5
 224:	02b00793          	li	a5,43
 228:	00f71863          	bne	a4,a5,238 <strtol+0xac>
 22c:	fd843783          	ld	a5,-40(s0)
 230:	00178793          	addi	a5,a5,1
 234:	fcf43c23          	sd	a5,-40(s0)
 238:	fbc42783          	lw	a5,-68(s0)
 23c:	0007879b          	sext.w	a5,a5
 240:	06079c63          	bnez	a5,2b8 <strtol+0x12c>
 244:	fd843783          	ld	a5,-40(s0)
 248:	0007c783          	lbu	a5,0(a5)
 24c:	00078713          	mv	a4,a5
 250:	03000793          	li	a5,48
 254:	04f71e63          	bne	a4,a5,2b0 <strtol+0x124>
 258:	fd843783          	ld	a5,-40(s0)
 25c:	00178793          	addi	a5,a5,1
 260:	fcf43c23          	sd	a5,-40(s0)
 264:	fd843783          	ld	a5,-40(s0)
 268:	0007c783          	lbu	a5,0(a5)
 26c:	00078713          	mv	a4,a5
 270:	07800793          	li	a5,120
 274:	00f70c63          	beq	a4,a5,28c <strtol+0x100>
 278:	fd843783          	ld	a5,-40(s0)
 27c:	0007c783          	lbu	a5,0(a5)
 280:	00078713          	mv	a4,a5
 284:	05800793          	li	a5,88
 288:	00f71e63          	bne	a4,a5,2a4 <strtol+0x118>
 28c:	01000793          	li	a5,16
 290:	faf42e23          	sw	a5,-68(s0)
 294:	fd843783          	ld	a5,-40(s0)
 298:	00178793          	addi	a5,a5,1
 29c:	fcf43c23          	sd	a5,-40(s0)
 2a0:	0180006f          	j	2b8 <strtol+0x12c>
 2a4:	00800793          	li	a5,8
 2a8:	faf42e23          	sw	a5,-68(s0)
 2ac:	00c0006f          	j	2b8 <strtol+0x12c>
 2b0:	00a00793          	li	a5,10
 2b4:	faf42e23          	sw	a5,-68(s0)
 2b8:	fd843783          	ld	a5,-40(s0)
 2bc:	0007c783          	lbu	a5,0(a5)
 2c0:	00078713          	mv	a4,a5
 2c4:	02f00793          	li	a5,47
 2c8:	02e7f863          	bgeu	a5,a4,2f8 <strtol+0x16c>
 2cc:	fd843783          	ld	a5,-40(s0)
 2d0:	0007c783          	lbu	a5,0(a5)
 2d4:	00078713          	mv	a4,a5
 2d8:	03900793          	li	a5,57
 2dc:	00e7ee63          	bltu	a5,a4,2f8 <strtol+0x16c>
 2e0:	fd843783          	ld	a5,-40(s0)
 2e4:	0007c783          	lbu	a5,0(a5)
 2e8:	0007879b          	sext.w	a5,a5
 2ec:	fd07879b          	addiw	a5,a5,-48
 2f0:	fcf42a23          	sw	a5,-44(s0)
 2f4:	0800006f          	j	374 <strtol+0x1e8>
 2f8:	fd843783          	ld	a5,-40(s0)
 2fc:	0007c783          	lbu	a5,0(a5)
 300:	00078713          	mv	a4,a5
 304:	06000793          	li	a5,96
 308:	02e7f863          	bgeu	a5,a4,338 <strtol+0x1ac>
 30c:	fd843783          	ld	a5,-40(s0)
 310:	0007c783          	lbu	a5,0(a5)
 314:	00078713          	mv	a4,a5
 318:	07a00793          	li	a5,122
 31c:	00e7ee63          	bltu	a5,a4,338 <strtol+0x1ac>
 320:	fd843783          	ld	a5,-40(s0)
 324:	0007c783          	lbu	a5,0(a5)
 328:	0007879b          	sext.w	a5,a5
 32c:	fa97879b          	addiw	a5,a5,-87
 330:	fcf42a23          	sw	a5,-44(s0)
 334:	0400006f          	j	374 <strtol+0x1e8>
 338:	fd843783          	ld	a5,-40(s0)
 33c:	0007c783          	lbu	a5,0(a5)
 340:	00078713          	mv	a4,a5
 344:	04000793          	li	a5,64
 348:	06e7f663          	bgeu	a5,a4,3b4 <strtol+0x228>
 34c:	fd843783          	ld	a5,-40(s0)
 350:	0007c783          	lbu	a5,0(a5)
 354:	00078713          	mv	a4,a5
 358:	05a00793          	li	a5,90
 35c:	04e7ec63          	bltu	a5,a4,3b4 <strtol+0x228>
 360:	fd843783          	ld	a5,-40(s0)
 364:	0007c783          	lbu	a5,0(a5)
 368:	0007879b          	sext.w	a5,a5
 36c:	fc97879b          	addiw	a5,a5,-55
 370:	fcf42a23          	sw	a5,-44(s0)
 374:	fd442703          	lw	a4,-44(s0)
 378:	fbc42783          	lw	a5,-68(s0)
 37c:	0007071b          	sext.w	a4,a4
 380:	0007879b          	sext.w	a5,a5
 384:	02f75663          	bge	a4,a5,3b0 <strtol+0x224>
 388:	fbc42703          	lw	a4,-68(s0)
 38c:	fe843783          	ld	a5,-24(s0)
 390:	02f70733          	mul	a4,a4,a5
 394:	fd442783          	lw	a5,-44(s0)
 398:	00f707b3          	add	a5,a4,a5
 39c:	fef43423          	sd	a5,-24(s0)
 3a0:	fd843783          	ld	a5,-40(s0)
 3a4:	00178793          	addi	a5,a5,1
 3a8:	fcf43c23          	sd	a5,-40(s0)
 3ac:	f0dff06f          	j	2b8 <strtol+0x12c>
 3b0:	00000013          	nop
 3b4:	fc043783          	ld	a5,-64(s0)
 3b8:	00078863          	beqz	a5,3c8 <strtol+0x23c>
 3bc:	fc043783          	ld	a5,-64(s0)
 3c0:	fd843703          	ld	a4,-40(s0)
 3c4:	00e7b023          	sd	a4,0(a5)
 3c8:	fe744783          	lbu	a5,-25(s0)
 3cc:	0ff7f793          	andi	a5,a5,255
 3d0:	00078863          	beqz	a5,3e0 <strtol+0x254>
 3d4:	fe843783          	ld	a5,-24(s0)
 3d8:	40f007b3          	neg	a5,a5
 3dc:	0080006f          	j	3e4 <strtol+0x258>
 3e0:	fe843783          	ld	a5,-24(s0)
 3e4:	00078513          	mv	a0,a5
 3e8:	04813083          	ld	ra,72(sp)
 3ec:	04013403          	ld	s0,64(sp)
 3f0:	05010113          	addi	sp,sp,80
 3f4:	00008067          	ret

Disassembly of section .text.puts_wo_nl:

00000000000003f8 <puts_wo_nl>:
 3f8:	fd010113          	addi	sp,sp,-48
 3fc:	02113423          	sd	ra,40(sp)
 400:	02813023          	sd	s0,32(sp)
 404:	03010413          	addi	s0,sp,48
 408:	fca43c23          	sd	a0,-40(s0)
 40c:	fcb43823          	sd	a1,-48(s0)
 410:	fd043783          	ld	a5,-48(s0)
 414:	00079863          	bnez	a5,424 <puts_wo_nl+0x2c>
 418:	00001797          	auipc	a5,0x1
 41c:	ca878793          	addi	a5,a5,-856 # 10c0 <printf+0x13c>
 420:	fcf43823          	sd	a5,-48(s0)
 424:	fd043783          	ld	a5,-48(s0)
 428:	fef43423          	sd	a5,-24(s0)
 42c:	0240006f          	j	450 <puts_wo_nl+0x58>
 430:	fe843783          	ld	a5,-24(s0)
 434:	00178713          	addi	a4,a5,1
 438:	fee43423          	sd	a4,-24(s0)
 43c:	0007c783          	lbu	a5,0(a5)
 440:	0007879b          	sext.w	a5,a5
 444:	fd843703          	ld	a4,-40(s0)
 448:	00078513          	mv	a0,a5
 44c:	000700e7          	jalr	a4
 450:	fe843783          	ld	a5,-24(s0)
 454:	0007c783          	lbu	a5,0(a5)
 458:	fc079ce3          	bnez	a5,430 <puts_wo_nl+0x38>
 45c:	fe843703          	ld	a4,-24(s0)
 460:	fd043783          	ld	a5,-48(s0)
 464:	40f707b3          	sub	a5,a4,a5
 468:	0007879b          	sext.w	a5,a5
 46c:	00078513          	mv	a0,a5
 470:	02813083          	ld	ra,40(sp)
 474:	02013403          	ld	s0,32(sp)
 478:	03010113          	addi	sp,sp,48
 47c:	00008067          	ret

Disassembly of section .text.print_dec_int:

0000000000000480 <print_dec_int>:
 480:	f9010113          	addi	sp,sp,-112
 484:	06113423          	sd	ra,104(sp)
 488:	06813023          	sd	s0,96(sp)
 48c:	07010413          	addi	s0,sp,112
 490:	faa43423          	sd	a0,-88(s0)
 494:	fab43023          	sd	a1,-96(s0)
 498:	00060793          	mv	a5,a2
 49c:	f8d43823          	sd	a3,-112(s0)
 4a0:	f8f40fa3          	sb	a5,-97(s0)
 4a4:	f9f44783          	lbu	a5,-97(s0)
 4a8:	0ff7f793          	andi	a5,a5,255
 4ac:	02078863          	beqz	a5,4dc <print_dec_int+0x5c>
 4b0:	fa043703          	ld	a4,-96(s0)
 4b4:	fff00793          	li	a5,-1
 4b8:	03f79793          	slli	a5,a5,0x3f
 4bc:	02f71063          	bne	a4,a5,4dc <print_dec_int+0x5c>
 4c0:	00001597          	auipc	a1,0x1
 4c4:	c0858593          	addi	a1,a1,-1016 # 10c8 <printf+0x144>
 4c8:	fa843503          	ld	a0,-88(s0)
 4cc:	00000097          	auipc	ra,0x0
 4d0:	f2c080e7          	jalr	-212(ra) # 3f8 <puts_wo_nl>
 4d4:	00050793          	mv	a5,a0
 4d8:	2980006f          	j	770 <print_dec_int+0x2f0>
 4dc:	f9043783          	ld	a5,-112(s0)
 4e0:	00c7a783          	lw	a5,12(a5)
 4e4:	00079a63          	bnez	a5,4f8 <print_dec_int+0x78>
 4e8:	fa043783          	ld	a5,-96(s0)
 4ec:	00079663          	bnez	a5,4f8 <print_dec_int+0x78>
 4f0:	00000793          	li	a5,0
 4f4:	27c0006f          	j	770 <print_dec_int+0x2f0>
 4f8:	fe0407a3          	sb	zero,-17(s0)
 4fc:	f9f44783          	lbu	a5,-97(s0)
 500:	0ff7f793          	andi	a5,a5,255
 504:	02078063          	beqz	a5,524 <print_dec_int+0xa4>
 508:	fa043783          	ld	a5,-96(s0)
 50c:	0007dc63          	bgez	a5,524 <print_dec_int+0xa4>
 510:	00100793          	li	a5,1
 514:	fef407a3          	sb	a5,-17(s0)
 518:	fa043783          	ld	a5,-96(s0)
 51c:	40f007b3          	neg	a5,a5
 520:	faf43023          	sd	a5,-96(s0)
 524:	fe042423          	sw	zero,-24(s0)
 528:	f9f44783          	lbu	a5,-97(s0)
 52c:	0ff7f793          	andi	a5,a5,255
 530:	02078863          	beqz	a5,560 <print_dec_int+0xe0>
 534:	fef44783          	lbu	a5,-17(s0)
 538:	0ff7f793          	andi	a5,a5,255
 53c:	00079e63          	bnez	a5,558 <print_dec_int+0xd8>
 540:	f9043783          	ld	a5,-112(s0)
 544:	0057c783          	lbu	a5,5(a5)
 548:	00079863          	bnez	a5,558 <print_dec_int+0xd8>
 54c:	f9043783          	ld	a5,-112(s0)
 550:	0047c783          	lbu	a5,4(a5)
 554:	00078663          	beqz	a5,560 <print_dec_int+0xe0>
 558:	00100793          	li	a5,1
 55c:	0080006f          	j	564 <print_dec_int+0xe4>
 560:	00000793          	li	a5,0
 564:	fcf40ba3          	sb	a5,-41(s0)
 568:	fd744783          	lbu	a5,-41(s0)
 56c:	0017f793          	andi	a5,a5,1
 570:	fcf40ba3          	sb	a5,-41(s0)
 574:	fa043703          	ld	a4,-96(s0)
 578:	00a00793          	li	a5,10
 57c:	02f777b3          	remu	a5,a4,a5
 580:	0ff7f713          	andi	a4,a5,255
 584:	fe842783          	lw	a5,-24(s0)
 588:	0017869b          	addiw	a3,a5,1
 58c:	fed42423          	sw	a3,-24(s0)
 590:	0307071b          	addiw	a4,a4,48
 594:	0ff77713          	andi	a4,a4,255
 598:	ff040693          	addi	a3,s0,-16
 59c:	00f687b3          	add	a5,a3,a5
 5a0:	fce78423          	sb	a4,-56(a5)
 5a4:	fa043703          	ld	a4,-96(s0)
 5a8:	00a00793          	li	a5,10
 5ac:	02f757b3          	divu	a5,a4,a5
 5b0:	faf43023          	sd	a5,-96(s0)
 5b4:	fa043783          	ld	a5,-96(s0)
 5b8:	fa079ee3          	bnez	a5,574 <print_dec_int+0xf4>
 5bc:	f9043783          	ld	a5,-112(s0)
 5c0:	00c7a783          	lw	a5,12(a5)
 5c4:	00078713          	mv	a4,a5
 5c8:	fff00793          	li	a5,-1
 5cc:	02f71063          	bne	a4,a5,5ec <print_dec_int+0x16c>
 5d0:	f9043783          	ld	a5,-112(s0)
 5d4:	0037c783          	lbu	a5,3(a5)
 5d8:	00078a63          	beqz	a5,5ec <print_dec_int+0x16c>
 5dc:	f9043783          	ld	a5,-112(s0)
 5e0:	0087a703          	lw	a4,8(a5)
 5e4:	f9043783          	ld	a5,-112(s0)
 5e8:	00e7a623          	sw	a4,12(a5)
 5ec:	fe042223          	sw	zero,-28(s0)
 5f0:	f9043783          	ld	a5,-112(s0)
 5f4:	0087a703          	lw	a4,8(a5)
 5f8:	fe842783          	lw	a5,-24(s0)
 5fc:	fcf42823          	sw	a5,-48(s0)
 600:	f9043783          	ld	a5,-112(s0)
 604:	00c7a783          	lw	a5,12(a5)
 608:	fcf42623          	sw	a5,-52(s0)
 60c:	fd042583          	lw	a1,-48(s0)
 610:	fcc42783          	lw	a5,-52(s0)
 614:	0007861b          	sext.w	a2,a5
 618:	0005869b          	sext.w	a3,a1
 61c:	00d65463          	bge	a2,a3,624 <print_dec_int+0x1a4>
 620:	00058793          	mv	a5,a1
 624:	0007879b          	sext.w	a5,a5
 628:	40f707bb          	subw	a5,a4,a5
 62c:	0007871b          	sext.w	a4,a5
 630:	fd744783          	lbu	a5,-41(s0)
 634:	0007879b          	sext.w	a5,a5
 638:	40f707bb          	subw	a5,a4,a5
 63c:	fef42023          	sw	a5,-32(s0)
 640:	0280006f          	j	668 <print_dec_int+0x1e8>
 644:	fa843783          	ld	a5,-88(s0)
 648:	02000513          	li	a0,32
 64c:	000780e7          	jalr	a5
 650:	fe442783          	lw	a5,-28(s0)
 654:	0017879b          	addiw	a5,a5,1
 658:	fef42223          	sw	a5,-28(s0)
 65c:	fe042783          	lw	a5,-32(s0)
 660:	fff7879b          	addiw	a5,a5,-1
 664:	fef42023          	sw	a5,-32(s0)
 668:	fe042783          	lw	a5,-32(s0)
 66c:	0007879b          	sext.w	a5,a5
 670:	fcf04ae3          	bgtz	a5,644 <print_dec_int+0x1c4>
 674:	fd744783          	lbu	a5,-41(s0)
 678:	0ff7f793          	andi	a5,a5,255
 67c:	04078463          	beqz	a5,6c4 <print_dec_int+0x244>
 680:	fef44783          	lbu	a5,-17(s0)
 684:	0ff7f793          	andi	a5,a5,255
 688:	00078663          	beqz	a5,694 <print_dec_int+0x214>
 68c:	02d00793          	li	a5,45
 690:	01c0006f          	j	6ac <print_dec_int+0x22c>
 694:	f9043783          	ld	a5,-112(s0)
 698:	0057c783          	lbu	a5,5(a5)
 69c:	00078663          	beqz	a5,6a8 <print_dec_int+0x228>
 6a0:	02b00793          	li	a5,43
 6a4:	0080006f          	j	6ac <print_dec_int+0x22c>
 6a8:	02000793          	li	a5,32
 6ac:	fa843703          	ld	a4,-88(s0)
 6b0:	00078513          	mv	a0,a5
 6b4:	000700e7          	jalr	a4
 6b8:	fe442783          	lw	a5,-28(s0)
 6bc:	0017879b          	addiw	a5,a5,1
 6c0:	fef42223          	sw	a5,-28(s0)
 6c4:	fe842783          	lw	a5,-24(s0)
 6c8:	fcf42e23          	sw	a5,-36(s0)
 6cc:	0280006f          	j	6f4 <print_dec_int+0x274>
 6d0:	fa843783          	ld	a5,-88(s0)
 6d4:	03000513          	li	a0,48
 6d8:	000780e7          	jalr	a5
 6dc:	fe442783          	lw	a5,-28(s0)
 6e0:	0017879b          	addiw	a5,a5,1
 6e4:	fef42223          	sw	a5,-28(s0)
 6e8:	fdc42783          	lw	a5,-36(s0)
 6ec:	0017879b          	addiw	a5,a5,1
 6f0:	fcf42e23          	sw	a5,-36(s0)
 6f4:	f9043783          	ld	a5,-112(s0)
 6f8:	00c7a703          	lw	a4,12(a5)
 6fc:	fd744783          	lbu	a5,-41(s0)
 700:	0007879b          	sext.w	a5,a5
 704:	40f707bb          	subw	a5,a4,a5
 708:	0007871b          	sext.w	a4,a5
 70c:	fdc42783          	lw	a5,-36(s0)
 710:	0007879b          	sext.w	a5,a5
 714:	fae7cee3          	blt	a5,a4,6d0 <print_dec_int+0x250>
 718:	fe842783          	lw	a5,-24(s0)
 71c:	fff7879b          	addiw	a5,a5,-1
 720:	fcf42c23          	sw	a5,-40(s0)
 724:	03c0006f          	j	760 <print_dec_int+0x2e0>
 728:	fd842783          	lw	a5,-40(s0)
 72c:	ff040713          	addi	a4,s0,-16
 730:	00f707b3          	add	a5,a4,a5
 734:	fc87c783          	lbu	a5,-56(a5)
 738:	0007879b          	sext.w	a5,a5
 73c:	fa843703          	ld	a4,-88(s0)
 740:	00078513          	mv	a0,a5
 744:	000700e7          	jalr	a4
 748:	fe442783          	lw	a5,-28(s0)
 74c:	0017879b          	addiw	a5,a5,1
 750:	fef42223          	sw	a5,-28(s0)
 754:	fd842783          	lw	a5,-40(s0)
 758:	fff7879b          	addiw	a5,a5,-1
 75c:	fcf42c23          	sw	a5,-40(s0)
 760:	fd842783          	lw	a5,-40(s0)
 764:	0007879b          	sext.w	a5,a5
 768:	fc07d0e3          	bgez	a5,728 <print_dec_int+0x2a8>
 76c:	fe442783          	lw	a5,-28(s0)
 770:	00078513          	mv	a0,a5
 774:	06813083          	ld	ra,104(sp)
 778:	06013403          	ld	s0,96(sp)
 77c:	07010113          	addi	sp,sp,112
 780:	00008067          	ret

Disassembly of section .text.vprintfmt:

0000000000000784 <vprintfmt>:
 784:	f4010113          	addi	sp,sp,-192
 788:	0a113c23          	sd	ra,184(sp)
 78c:	0a813823          	sd	s0,176(sp)
 790:	0c010413          	addi	s0,sp,192
 794:	f4a43c23          	sd	a0,-168(s0)
 798:	f4b43823          	sd	a1,-176(s0)
 79c:	f4c43423          	sd	a2,-184(s0)
 7a0:	f8043023          	sd	zero,-128(s0)
 7a4:	f8043423          	sd	zero,-120(s0)
 7a8:	fe042623          	sw	zero,-20(s0)
 7ac:	7b40006f          	j	f60 <vprintfmt+0x7dc>
 7b0:	f8044783          	lbu	a5,-128(s0)
 7b4:	74078663          	beqz	a5,f00 <vprintfmt+0x77c>
 7b8:	f5043783          	ld	a5,-176(s0)
 7bc:	0007c783          	lbu	a5,0(a5)
 7c0:	00078713          	mv	a4,a5
 7c4:	02300793          	li	a5,35
 7c8:	00f71863          	bne	a4,a5,7d8 <vprintfmt+0x54>
 7cc:	00100793          	li	a5,1
 7d0:	f8f40123          	sb	a5,-126(s0)
 7d4:	7800006f          	j	f54 <vprintfmt+0x7d0>
 7d8:	f5043783          	ld	a5,-176(s0)
 7dc:	0007c783          	lbu	a5,0(a5)
 7e0:	00078713          	mv	a4,a5
 7e4:	03000793          	li	a5,48
 7e8:	00f71863          	bne	a4,a5,7f8 <vprintfmt+0x74>
 7ec:	00100793          	li	a5,1
 7f0:	f8f401a3          	sb	a5,-125(s0)
 7f4:	7600006f          	j	f54 <vprintfmt+0x7d0>
 7f8:	f5043783          	ld	a5,-176(s0)
 7fc:	0007c783          	lbu	a5,0(a5)
 800:	00078713          	mv	a4,a5
 804:	06c00793          	li	a5,108
 808:	04f70063          	beq	a4,a5,848 <vprintfmt+0xc4>
 80c:	f5043783          	ld	a5,-176(s0)
 810:	0007c783          	lbu	a5,0(a5)
 814:	00078713          	mv	a4,a5
 818:	07a00793          	li	a5,122
 81c:	02f70663          	beq	a4,a5,848 <vprintfmt+0xc4>
 820:	f5043783          	ld	a5,-176(s0)
 824:	0007c783          	lbu	a5,0(a5)
 828:	00078713          	mv	a4,a5
 82c:	07400793          	li	a5,116
 830:	00f70c63          	beq	a4,a5,848 <vprintfmt+0xc4>
 834:	f5043783          	ld	a5,-176(s0)
 838:	0007c783          	lbu	a5,0(a5)
 83c:	00078713          	mv	a4,a5
 840:	06a00793          	li	a5,106
 844:	00f71863          	bne	a4,a5,854 <vprintfmt+0xd0>
 848:	00100793          	li	a5,1
 84c:	f8f400a3          	sb	a5,-127(s0)
 850:	7040006f          	j	f54 <vprintfmt+0x7d0>
 854:	f5043783          	ld	a5,-176(s0)
 858:	0007c783          	lbu	a5,0(a5)
 85c:	00078713          	mv	a4,a5
 860:	02b00793          	li	a5,43
 864:	00f71863          	bne	a4,a5,874 <vprintfmt+0xf0>
 868:	00100793          	li	a5,1
 86c:	f8f402a3          	sb	a5,-123(s0)
 870:	6e40006f          	j	f54 <vprintfmt+0x7d0>
 874:	f5043783          	ld	a5,-176(s0)
 878:	0007c783          	lbu	a5,0(a5)
 87c:	00078713          	mv	a4,a5
 880:	02000793          	li	a5,32
 884:	00f71863          	bne	a4,a5,894 <vprintfmt+0x110>
 888:	00100793          	li	a5,1
 88c:	f8f40223          	sb	a5,-124(s0)
 890:	6c40006f          	j	f54 <vprintfmt+0x7d0>
 894:	f5043783          	ld	a5,-176(s0)
 898:	0007c783          	lbu	a5,0(a5)
 89c:	00078713          	mv	a4,a5
 8a0:	02a00793          	li	a5,42
 8a4:	00f71e63          	bne	a4,a5,8c0 <vprintfmt+0x13c>
 8a8:	f4843783          	ld	a5,-184(s0)
 8ac:	00878713          	addi	a4,a5,8
 8b0:	f4e43423          	sd	a4,-184(s0)
 8b4:	0007a783          	lw	a5,0(a5)
 8b8:	f8f42423          	sw	a5,-120(s0)
 8bc:	6980006f          	j	f54 <vprintfmt+0x7d0>
 8c0:	f5043783          	ld	a5,-176(s0)
 8c4:	0007c783          	lbu	a5,0(a5)
 8c8:	00078713          	mv	a4,a5
 8cc:	03000793          	li	a5,48
 8d0:	04e7f863          	bgeu	a5,a4,920 <vprintfmt+0x19c>
 8d4:	f5043783          	ld	a5,-176(s0)
 8d8:	0007c783          	lbu	a5,0(a5)
 8dc:	00078713          	mv	a4,a5
 8e0:	03900793          	li	a5,57
 8e4:	02e7ee63          	bltu	a5,a4,920 <vprintfmt+0x19c>
 8e8:	f5043783          	ld	a5,-176(s0)
 8ec:	f5040713          	addi	a4,s0,-176
 8f0:	00a00613          	li	a2,10
 8f4:	00070593          	mv	a1,a4
 8f8:	00078513          	mv	a0,a5
 8fc:	00000097          	auipc	ra,0x0
 900:	890080e7          	jalr	-1904(ra) # 18c <strtol>
 904:	00050793          	mv	a5,a0
 908:	0007879b          	sext.w	a5,a5
 90c:	f8f42423          	sw	a5,-120(s0)
 910:	f5043783          	ld	a5,-176(s0)
 914:	fff78793          	addi	a5,a5,-1
 918:	f4f43823          	sd	a5,-176(s0)
 91c:	6380006f          	j	f54 <vprintfmt+0x7d0>
 920:	f5043783          	ld	a5,-176(s0)
 924:	0007c783          	lbu	a5,0(a5)
 928:	00078713          	mv	a4,a5
 92c:	02e00793          	li	a5,46
 930:	06f71a63          	bne	a4,a5,9a4 <vprintfmt+0x220>
 934:	f5043783          	ld	a5,-176(s0)
 938:	00178793          	addi	a5,a5,1
 93c:	f4f43823          	sd	a5,-176(s0)
 940:	f5043783          	ld	a5,-176(s0)
 944:	0007c783          	lbu	a5,0(a5)
 948:	00078713          	mv	a4,a5
 94c:	02a00793          	li	a5,42
 950:	00f71e63          	bne	a4,a5,96c <vprintfmt+0x1e8>
 954:	f4843783          	ld	a5,-184(s0)
 958:	00878713          	addi	a4,a5,8
 95c:	f4e43423          	sd	a4,-184(s0)
 960:	0007a783          	lw	a5,0(a5)
 964:	f8f42623          	sw	a5,-116(s0)
 968:	5ec0006f          	j	f54 <vprintfmt+0x7d0>
 96c:	f5043783          	ld	a5,-176(s0)
 970:	f5040713          	addi	a4,s0,-176
 974:	00a00613          	li	a2,10
 978:	00070593          	mv	a1,a4
 97c:	00078513          	mv	a0,a5
 980:	00000097          	auipc	ra,0x0
 984:	80c080e7          	jalr	-2036(ra) # 18c <strtol>
 988:	00050793          	mv	a5,a0
 98c:	0007879b          	sext.w	a5,a5
 990:	f8f42623          	sw	a5,-116(s0)
 994:	f5043783          	ld	a5,-176(s0)
 998:	fff78793          	addi	a5,a5,-1
 99c:	f4f43823          	sd	a5,-176(s0)
 9a0:	5b40006f          	j	f54 <vprintfmt+0x7d0>
 9a4:	f5043783          	ld	a5,-176(s0)
 9a8:	0007c783          	lbu	a5,0(a5)
 9ac:	00078713          	mv	a4,a5
 9b0:	07800793          	li	a5,120
 9b4:	02f70663          	beq	a4,a5,9e0 <vprintfmt+0x25c>
 9b8:	f5043783          	ld	a5,-176(s0)
 9bc:	0007c783          	lbu	a5,0(a5)
 9c0:	00078713          	mv	a4,a5
 9c4:	05800793          	li	a5,88
 9c8:	00f70c63          	beq	a4,a5,9e0 <vprintfmt+0x25c>
 9cc:	f5043783          	ld	a5,-176(s0)
 9d0:	0007c783          	lbu	a5,0(a5)
 9d4:	00078713          	mv	a4,a5
 9d8:	07000793          	li	a5,112
 9dc:	2ef71e63          	bne	a4,a5,cd8 <vprintfmt+0x554>
 9e0:	f5043783          	ld	a5,-176(s0)
 9e4:	0007c783          	lbu	a5,0(a5)
 9e8:	00078713          	mv	a4,a5
 9ec:	07000793          	li	a5,112
 9f0:	00f70663          	beq	a4,a5,9fc <vprintfmt+0x278>
 9f4:	f8144783          	lbu	a5,-127(s0)
 9f8:	00078663          	beqz	a5,a04 <vprintfmt+0x280>
 9fc:	00100793          	li	a5,1
 a00:	0080006f          	j	a08 <vprintfmt+0x284>
 a04:	00000793          	li	a5,0
 a08:	faf403a3          	sb	a5,-89(s0)
 a0c:	fa744783          	lbu	a5,-89(s0)
 a10:	0017f793          	andi	a5,a5,1
 a14:	faf403a3          	sb	a5,-89(s0)
 a18:	fa744783          	lbu	a5,-89(s0)
 a1c:	0ff7f793          	andi	a5,a5,255
 a20:	00078c63          	beqz	a5,a38 <vprintfmt+0x2b4>
 a24:	f4843783          	ld	a5,-184(s0)
 a28:	00878713          	addi	a4,a5,8
 a2c:	f4e43423          	sd	a4,-184(s0)
 a30:	0007b783          	ld	a5,0(a5)
 a34:	01c0006f          	j	a50 <vprintfmt+0x2cc>
 a38:	f4843783          	ld	a5,-184(s0)
 a3c:	00878713          	addi	a4,a5,8
 a40:	f4e43423          	sd	a4,-184(s0)
 a44:	0007a783          	lw	a5,0(a5)
 a48:	02079793          	slli	a5,a5,0x20
 a4c:	0207d793          	srli	a5,a5,0x20
 a50:	fef43023          	sd	a5,-32(s0)
 a54:	f8c42783          	lw	a5,-116(s0)
 a58:	02079463          	bnez	a5,a80 <vprintfmt+0x2fc>
 a5c:	fe043783          	ld	a5,-32(s0)
 a60:	02079063          	bnez	a5,a80 <vprintfmt+0x2fc>
 a64:	f5043783          	ld	a5,-176(s0)
 a68:	0007c783          	lbu	a5,0(a5)
 a6c:	00078713          	mv	a4,a5
 a70:	07000793          	li	a5,112
 a74:	00f70663          	beq	a4,a5,a80 <vprintfmt+0x2fc>
 a78:	f8040023          	sb	zero,-128(s0)
 a7c:	4d80006f          	j	f54 <vprintfmt+0x7d0>
 a80:	f5043783          	ld	a5,-176(s0)
 a84:	0007c783          	lbu	a5,0(a5)
 a88:	00078713          	mv	a4,a5
 a8c:	07000793          	li	a5,112
 a90:	00f70a63          	beq	a4,a5,aa4 <vprintfmt+0x320>
 a94:	f8244783          	lbu	a5,-126(s0)
 a98:	00078a63          	beqz	a5,aac <vprintfmt+0x328>
 a9c:	fe043783          	ld	a5,-32(s0)
 aa0:	00078663          	beqz	a5,aac <vprintfmt+0x328>
 aa4:	00100793          	li	a5,1
 aa8:	0080006f          	j	ab0 <vprintfmt+0x32c>
 aac:	00000793          	li	a5,0
 ab0:	faf40323          	sb	a5,-90(s0)
 ab4:	fa644783          	lbu	a5,-90(s0)
 ab8:	0017f793          	andi	a5,a5,1
 abc:	faf40323          	sb	a5,-90(s0)
 ac0:	fc042e23          	sw	zero,-36(s0)
 ac4:	f5043783          	ld	a5,-176(s0)
 ac8:	0007c783          	lbu	a5,0(a5)
 acc:	00078713          	mv	a4,a5
 ad0:	05800793          	li	a5,88
 ad4:	00f71863          	bne	a4,a5,ae4 <vprintfmt+0x360>
 ad8:	00000797          	auipc	a5,0x0
 adc:	60878793          	addi	a5,a5,1544 # 10e0 <upperxdigits.1056>
 ae0:	00c0006f          	j	aec <vprintfmt+0x368>
 ae4:	00000797          	auipc	a5,0x0
 ae8:	61478793          	addi	a5,a5,1556 # 10f8 <lowerxdigits.1055>
 aec:	f8f43c23          	sd	a5,-104(s0)
 af0:	fe043783          	ld	a5,-32(s0)
 af4:	00f7f793          	andi	a5,a5,15
 af8:	f9843703          	ld	a4,-104(s0)
 afc:	00f70733          	add	a4,a4,a5
 b00:	fdc42783          	lw	a5,-36(s0)
 b04:	0017869b          	addiw	a3,a5,1
 b08:	fcd42e23          	sw	a3,-36(s0)
 b0c:	00074703          	lbu	a4,0(a4)
 b10:	ff040693          	addi	a3,s0,-16
 b14:	00f687b3          	add	a5,a3,a5
 b18:	f8e78023          	sb	a4,-128(a5)
 b1c:	fe043783          	ld	a5,-32(s0)
 b20:	0047d793          	srli	a5,a5,0x4
 b24:	fef43023          	sd	a5,-32(s0)
 b28:	fe043783          	ld	a5,-32(s0)
 b2c:	fc0792e3          	bnez	a5,af0 <vprintfmt+0x36c>
 b30:	f8c42783          	lw	a5,-116(s0)
 b34:	00078713          	mv	a4,a5
 b38:	fff00793          	li	a5,-1
 b3c:	02f71663          	bne	a4,a5,b68 <vprintfmt+0x3e4>
 b40:	f8344783          	lbu	a5,-125(s0)
 b44:	02078263          	beqz	a5,b68 <vprintfmt+0x3e4>
 b48:	f8842703          	lw	a4,-120(s0)
 b4c:	fa644783          	lbu	a5,-90(s0)
 b50:	0007879b          	sext.w	a5,a5
 b54:	0017979b          	slliw	a5,a5,0x1
 b58:	0007879b          	sext.w	a5,a5
 b5c:	40f707bb          	subw	a5,a4,a5
 b60:	0007879b          	sext.w	a5,a5
 b64:	f8f42623          	sw	a5,-116(s0)
 b68:	f8842703          	lw	a4,-120(s0)
 b6c:	fa644783          	lbu	a5,-90(s0)
 b70:	0007879b          	sext.w	a5,a5
 b74:	0017979b          	slliw	a5,a5,0x1
 b78:	0007879b          	sext.w	a5,a5
 b7c:	40f707bb          	subw	a5,a4,a5
 b80:	0007871b          	sext.w	a4,a5
 b84:	fdc42783          	lw	a5,-36(s0)
 b88:	f8f42a23          	sw	a5,-108(s0)
 b8c:	f8c42783          	lw	a5,-116(s0)
 b90:	f8f42823          	sw	a5,-112(s0)
 b94:	f9442583          	lw	a1,-108(s0)
 b98:	f9042783          	lw	a5,-112(s0)
 b9c:	0007861b          	sext.w	a2,a5
 ba0:	0005869b          	sext.w	a3,a1
 ba4:	00d65463          	bge	a2,a3,bac <vprintfmt+0x428>
 ba8:	00058793          	mv	a5,a1
 bac:	0007879b          	sext.w	a5,a5
 bb0:	40f707bb          	subw	a5,a4,a5
 bb4:	fcf42c23          	sw	a5,-40(s0)
 bb8:	0280006f          	j	be0 <vprintfmt+0x45c>
 bbc:	f5843783          	ld	a5,-168(s0)
 bc0:	02000513          	li	a0,32
 bc4:	000780e7          	jalr	a5
 bc8:	fec42783          	lw	a5,-20(s0)
 bcc:	0017879b          	addiw	a5,a5,1
 bd0:	fef42623          	sw	a5,-20(s0)
 bd4:	fd842783          	lw	a5,-40(s0)
 bd8:	fff7879b          	addiw	a5,a5,-1
 bdc:	fcf42c23          	sw	a5,-40(s0)
 be0:	fd842783          	lw	a5,-40(s0)
 be4:	0007879b          	sext.w	a5,a5
 be8:	fcf04ae3          	bgtz	a5,bbc <vprintfmt+0x438>
 bec:	fa644783          	lbu	a5,-90(s0)
 bf0:	0ff7f793          	andi	a5,a5,255
 bf4:	04078463          	beqz	a5,c3c <vprintfmt+0x4b8>
 bf8:	f5843783          	ld	a5,-168(s0)
 bfc:	03000513          	li	a0,48
 c00:	000780e7          	jalr	a5
 c04:	f5043783          	ld	a5,-176(s0)
 c08:	0007c783          	lbu	a5,0(a5)
 c0c:	00078713          	mv	a4,a5
 c10:	05800793          	li	a5,88
 c14:	00f71663          	bne	a4,a5,c20 <vprintfmt+0x49c>
 c18:	05800793          	li	a5,88
 c1c:	0080006f          	j	c24 <vprintfmt+0x4a0>
 c20:	07800793          	li	a5,120
 c24:	f5843703          	ld	a4,-168(s0)
 c28:	00078513          	mv	a0,a5
 c2c:	000700e7          	jalr	a4
 c30:	fec42783          	lw	a5,-20(s0)
 c34:	0027879b          	addiw	a5,a5,2
 c38:	fef42623          	sw	a5,-20(s0)
 c3c:	fdc42783          	lw	a5,-36(s0)
 c40:	fcf42a23          	sw	a5,-44(s0)
 c44:	0280006f          	j	c6c <vprintfmt+0x4e8>
 c48:	f5843783          	ld	a5,-168(s0)
 c4c:	03000513          	li	a0,48
 c50:	000780e7          	jalr	a5
 c54:	fec42783          	lw	a5,-20(s0)
 c58:	0017879b          	addiw	a5,a5,1
 c5c:	fef42623          	sw	a5,-20(s0)
 c60:	fd442783          	lw	a5,-44(s0)
 c64:	0017879b          	addiw	a5,a5,1
 c68:	fcf42a23          	sw	a5,-44(s0)
 c6c:	f8c42703          	lw	a4,-116(s0)
 c70:	fd442783          	lw	a5,-44(s0)
 c74:	0007879b          	sext.w	a5,a5
 c78:	fce7c8e3          	blt	a5,a4,c48 <vprintfmt+0x4c4>
 c7c:	fdc42783          	lw	a5,-36(s0)
 c80:	fff7879b          	addiw	a5,a5,-1
 c84:	fcf42823          	sw	a5,-48(s0)
 c88:	03c0006f          	j	cc4 <vprintfmt+0x540>
 c8c:	fd042783          	lw	a5,-48(s0)
 c90:	ff040713          	addi	a4,s0,-16
 c94:	00f707b3          	add	a5,a4,a5
 c98:	f807c783          	lbu	a5,-128(a5)
 c9c:	0007879b          	sext.w	a5,a5
 ca0:	f5843703          	ld	a4,-168(s0)
 ca4:	00078513          	mv	a0,a5
 ca8:	000700e7          	jalr	a4
 cac:	fec42783          	lw	a5,-20(s0)
 cb0:	0017879b          	addiw	a5,a5,1
 cb4:	fef42623          	sw	a5,-20(s0)
 cb8:	fd042783          	lw	a5,-48(s0)
 cbc:	fff7879b          	addiw	a5,a5,-1
 cc0:	fcf42823          	sw	a5,-48(s0)
 cc4:	fd042783          	lw	a5,-48(s0)
 cc8:	0007879b          	sext.w	a5,a5
 ccc:	fc07d0e3          	bgez	a5,c8c <vprintfmt+0x508>
 cd0:	f8040023          	sb	zero,-128(s0)
 cd4:	2800006f          	j	f54 <vprintfmt+0x7d0>
 cd8:	f5043783          	ld	a5,-176(s0)
 cdc:	0007c783          	lbu	a5,0(a5)
 ce0:	00078713          	mv	a4,a5
 ce4:	06400793          	li	a5,100
 ce8:	02f70663          	beq	a4,a5,d14 <vprintfmt+0x590>
 cec:	f5043783          	ld	a5,-176(s0)
 cf0:	0007c783          	lbu	a5,0(a5)
 cf4:	00078713          	mv	a4,a5
 cf8:	06900793          	li	a5,105
 cfc:	00f70c63          	beq	a4,a5,d14 <vprintfmt+0x590>
 d00:	f5043783          	ld	a5,-176(s0)
 d04:	0007c783          	lbu	a5,0(a5)
 d08:	00078713          	mv	a4,a5
 d0c:	07500793          	li	a5,117
 d10:	08f71463          	bne	a4,a5,d98 <vprintfmt+0x614>
 d14:	f8144783          	lbu	a5,-127(s0)
 d18:	00078c63          	beqz	a5,d30 <vprintfmt+0x5ac>
 d1c:	f4843783          	ld	a5,-184(s0)
 d20:	00878713          	addi	a4,a5,8
 d24:	f4e43423          	sd	a4,-184(s0)
 d28:	0007b783          	ld	a5,0(a5)
 d2c:	0140006f          	j	d40 <vprintfmt+0x5bc>
 d30:	f4843783          	ld	a5,-184(s0)
 d34:	00878713          	addi	a4,a5,8
 d38:	f4e43423          	sd	a4,-184(s0)
 d3c:	0007a783          	lw	a5,0(a5)
 d40:	faf43423          	sd	a5,-88(s0)
 d44:	fa843583          	ld	a1,-88(s0)
 d48:	f5043783          	ld	a5,-176(s0)
 d4c:	0007c783          	lbu	a5,0(a5)
 d50:	0007871b          	sext.w	a4,a5
 d54:	07500793          	li	a5,117
 d58:	40f707b3          	sub	a5,a4,a5
 d5c:	00f037b3          	snez	a5,a5
 d60:	0ff7f793          	andi	a5,a5,255
 d64:	f8040713          	addi	a4,s0,-128
 d68:	00070693          	mv	a3,a4
 d6c:	00078613          	mv	a2,a5
 d70:	f5843503          	ld	a0,-168(s0)
 d74:	fffff097          	auipc	ra,0xfffff
 d78:	70c080e7          	jalr	1804(ra) # 480 <print_dec_int>
 d7c:	00050793          	mv	a5,a0
 d80:	00078713          	mv	a4,a5
 d84:	fec42783          	lw	a5,-20(s0)
 d88:	00e787bb          	addw	a5,a5,a4
 d8c:	fef42623          	sw	a5,-20(s0)
 d90:	f8040023          	sb	zero,-128(s0)
 d94:	1c00006f          	j	f54 <vprintfmt+0x7d0>
 d98:	f5043783          	ld	a5,-176(s0)
 d9c:	0007c783          	lbu	a5,0(a5)
 da0:	00078713          	mv	a4,a5
 da4:	06e00793          	li	a5,110
 da8:	04f71c63          	bne	a4,a5,e00 <vprintfmt+0x67c>
 dac:	f8144783          	lbu	a5,-127(s0)
 db0:	02078463          	beqz	a5,dd8 <vprintfmt+0x654>
 db4:	f4843783          	ld	a5,-184(s0)
 db8:	00878713          	addi	a4,a5,8
 dbc:	f4e43423          	sd	a4,-184(s0)
 dc0:	0007b783          	ld	a5,0(a5)
 dc4:	faf43823          	sd	a5,-80(s0)
 dc8:	fec42703          	lw	a4,-20(s0)
 dcc:	fb043783          	ld	a5,-80(s0)
 dd0:	00e7b023          	sd	a4,0(a5)
 dd4:	0240006f          	j	df8 <vprintfmt+0x674>
 dd8:	f4843783          	ld	a5,-184(s0)
 ddc:	00878713          	addi	a4,a5,8
 de0:	f4e43423          	sd	a4,-184(s0)
 de4:	0007b783          	ld	a5,0(a5)
 de8:	faf43c23          	sd	a5,-72(s0)
 dec:	fb843783          	ld	a5,-72(s0)
 df0:	fec42703          	lw	a4,-20(s0)
 df4:	00e7a023          	sw	a4,0(a5)
 df8:	f8040023          	sb	zero,-128(s0)
 dfc:	1580006f          	j	f54 <vprintfmt+0x7d0>
 e00:	f5043783          	ld	a5,-176(s0)
 e04:	0007c783          	lbu	a5,0(a5)
 e08:	00078713          	mv	a4,a5
 e0c:	07300793          	li	a5,115
 e10:	04f71263          	bne	a4,a5,e54 <vprintfmt+0x6d0>
 e14:	f4843783          	ld	a5,-184(s0)
 e18:	00878713          	addi	a4,a5,8
 e1c:	f4e43423          	sd	a4,-184(s0)
 e20:	0007b783          	ld	a5,0(a5)
 e24:	fcf43023          	sd	a5,-64(s0)
 e28:	fc043583          	ld	a1,-64(s0)
 e2c:	f5843503          	ld	a0,-168(s0)
 e30:	fffff097          	auipc	ra,0xfffff
 e34:	5c8080e7          	jalr	1480(ra) # 3f8 <puts_wo_nl>
 e38:	00050793          	mv	a5,a0
 e3c:	00078713          	mv	a4,a5
 e40:	fec42783          	lw	a5,-20(s0)
 e44:	00e787bb          	addw	a5,a5,a4
 e48:	fef42623          	sw	a5,-20(s0)
 e4c:	f8040023          	sb	zero,-128(s0)
 e50:	1040006f          	j	f54 <vprintfmt+0x7d0>
 e54:	f5043783          	ld	a5,-176(s0)
 e58:	0007c783          	lbu	a5,0(a5)
 e5c:	00078713          	mv	a4,a5
 e60:	06300793          	li	a5,99
 e64:	02f71e63          	bne	a4,a5,ea0 <vprintfmt+0x71c>
 e68:	f4843783          	ld	a5,-184(s0)
 e6c:	00878713          	addi	a4,a5,8
 e70:	f4e43423          	sd	a4,-184(s0)
 e74:	0007a783          	lw	a5,0(a5)
 e78:	fcf42623          	sw	a5,-52(s0)
 e7c:	fcc42783          	lw	a5,-52(s0)
 e80:	f5843703          	ld	a4,-168(s0)
 e84:	00078513          	mv	a0,a5
 e88:	000700e7          	jalr	a4
 e8c:	fec42783          	lw	a5,-20(s0)
 e90:	0017879b          	addiw	a5,a5,1
 e94:	fef42623          	sw	a5,-20(s0)
 e98:	f8040023          	sb	zero,-128(s0)
 e9c:	0b80006f          	j	f54 <vprintfmt+0x7d0>
 ea0:	f5043783          	ld	a5,-176(s0)
 ea4:	0007c783          	lbu	a5,0(a5)
 ea8:	00078713          	mv	a4,a5
 eac:	02500793          	li	a5,37
 eb0:	02f71263          	bne	a4,a5,ed4 <vprintfmt+0x750>
 eb4:	f5843783          	ld	a5,-168(s0)
 eb8:	02500513          	li	a0,37
 ebc:	000780e7          	jalr	a5
 ec0:	fec42783          	lw	a5,-20(s0)
 ec4:	0017879b          	addiw	a5,a5,1
 ec8:	fef42623          	sw	a5,-20(s0)
 ecc:	f8040023          	sb	zero,-128(s0)
 ed0:	0840006f          	j	f54 <vprintfmt+0x7d0>
 ed4:	f5043783          	ld	a5,-176(s0)
 ed8:	0007c783          	lbu	a5,0(a5)
 edc:	0007879b          	sext.w	a5,a5
 ee0:	f5843703          	ld	a4,-168(s0)
 ee4:	00078513          	mv	a0,a5
 ee8:	000700e7          	jalr	a4
 eec:	fec42783          	lw	a5,-20(s0)
 ef0:	0017879b          	addiw	a5,a5,1
 ef4:	fef42623          	sw	a5,-20(s0)
 ef8:	f8040023          	sb	zero,-128(s0)
 efc:	0580006f          	j	f54 <vprintfmt+0x7d0>
 f00:	f5043783          	ld	a5,-176(s0)
 f04:	0007c783          	lbu	a5,0(a5)
 f08:	00078713          	mv	a4,a5
 f0c:	02500793          	li	a5,37
 f10:	02f71063          	bne	a4,a5,f30 <vprintfmt+0x7ac>
 f14:	f8043023          	sd	zero,-128(s0)
 f18:	f8043423          	sd	zero,-120(s0)
 f1c:	00100793          	li	a5,1
 f20:	f8f40023          	sb	a5,-128(s0)
 f24:	fff00793          	li	a5,-1
 f28:	f8f42623          	sw	a5,-116(s0)
 f2c:	0280006f          	j	f54 <vprintfmt+0x7d0>
 f30:	f5043783          	ld	a5,-176(s0)
 f34:	0007c783          	lbu	a5,0(a5)
 f38:	0007879b          	sext.w	a5,a5
 f3c:	f5843703          	ld	a4,-168(s0)
 f40:	00078513          	mv	a0,a5
 f44:	000700e7          	jalr	a4
 f48:	fec42783          	lw	a5,-20(s0)
 f4c:	0017879b          	addiw	a5,a5,1
 f50:	fef42623          	sw	a5,-20(s0)
 f54:	f5043783          	ld	a5,-176(s0)
 f58:	00178793          	addi	a5,a5,1
 f5c:	f4f43823          	sd	a5,-176(s0)
 f60:	f5043783          	ld	a5,-176(s0)
 f64:	0007c783          	lbu	a5,0(a5)
 f68:	840794e3          	bnez	a5,7b0 <vprintfmt+0x2c>
 f6c:	fec42783          	lw	a5,-20(s0)
 f70:	00078513          	mv	a0,a5
 f74:	0b813083          	ld	ra,184(sp)
 f78:	0b013403          	ld	s0,176(sp)
 f7c:	0c010113          	addi	sp,sp,192
 f80:	00008067          	ret

Disassembly of section .text.printf:

0000000000000f84 <printf>:
     f84:	f8010113          	addi	sp,sp,-128
     f88:	02113c23          	sd	ra,56(sp)
     f8c:	02813823          	sd	s0,48(sp)
     f90:	04010413          	addi	s0,sp,64
     f94:	fca43423          	sd	a0,-56(s0)
     f98:	00b43423          	sd	a1,8(s0)
     f9c:	00c43823          	sd	a2,16(s0)
     fa0:	00d43c23          	sd	a3,24(s0)
     fa4:	02e43023          	sd	a4,32(s0)
     fa8:	02f43423          	sd	a5,40(s0)
     fac:	03043823          	sd	a6,48(s0)
     fb0:	03143c23          	sd	a7,56(s0)
     fb4:	fe042623          	sw	zero,-20(s0)
     fb8:	04040793          	addi	a5,s0,64
     fbc:	fcf43023          	sd	a5,-64(s0)
     fc0:	fc043783          	ld	a5,-64(s0)
     fc4:	fc878793          	addi	a5,a5,-56
     fc8:	fcf43823          	sd	a5,-48(s0)
     fcc:	fd043783          	ld	a5,-48(s0)
     fd0:	00078613          	mv	a2,a5
     fd4:	fc843583          	ld	a1,-56(s0)
     fd8:	fffff517          	auipc	a0,0xfffff
     fdc:	0ec50513          	addi	a0,a0,236 # c4 <putc>
     fe0:	fffff097          	auipc	ra,0xfffff
     fe4:	7a4080e7          	jalr	1956(ra) # 784 <vprintfmt>
     fe8:	00050793          	mv	a5,a0
     fec:	fef42623          	sw	a5,-20(s0)
     ff0:	00100793          	li	a5,1
     ff4:	fef43023          	sd	a5,-32(s0)
     ff8:	00000797          	auipc	a5,0x0
     ffc:	11878793          	addi	a5,a5,280 # 1110 <tail>
    1000:	0007a783          	lw	a5,0(a5)
    1004:	0017871b          	addiw	a4,a5,1
    1008:	0007069b          	sext.w	a3,a4
    100c:	00000717          	auipc	a4,0x0
    1010:	10470713          	addi	a4,a4,260 # 1110 <tail>
    1014:	00d72023          	sw	a3,0(a4)
    1018:	00000717          	auipc	a4,0x0
    101c:	10070713          	addi	a4,a4,256 # 1118 <buffer>
    1020:	00f707b3          	add	a5,a4,a5
    1024:	00078023          	sb	zero,0(a5)
    1028:	00000797          	auipc	a5,0x0
    102c:	0e878793          	addi	a5,a5,232 # 1110 <tail>
    1030:	0007a603          	lw	a2,0(a5)
    1034:	fe043703          	ld	a4,-32(s0)
    1038:	00000697          	auipc	a3,0x0
    103c:	0e068693          	addi	a3,a3,224 # 1118 <buffer>
    1040:	fd843783          	ld	a5,-40(s0)
    1044:	04000893          	li	a7,64
    1048:	00070513          	mv	a0,a4
    104c:	00068593          	mv	a1,a3
    1050:	00060613          	mv	a2,a2
    1054:	00000073          	ecall
    1058:	00050793          	mv	a5,a0
    105c:	fcf43c23          	sd	a5,-40(s0)
    1060:	00000797          	auipc	a5,0x0
    1064:	0b078793          	addi	a5,a5,176 # 1110 <tail>
    1068:	0007a023          	sw	zero,0(a5)
    106c:	fec42783          	lw	a5,-20(s0)
    1070:	00078513          	mv	a0,a5
    1074:	03813083          	ld	ra,56(sp)
    1078:	03013403          	ld	s0,48(sp)
    107c:	08010113          	addi	sp,sp,128
    1080:	00008067          	ret
