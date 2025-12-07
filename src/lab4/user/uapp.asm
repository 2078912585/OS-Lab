
uapp:     file format elf64-littleriscv


Disassembly of section .text:

00000000000100b0 <_start>:
   100b0:	0380006f          	j	100e8 <main>

00000000000100b4 <getpid>:
   100b4:	fe010113          	addi	sp,sp,-32
   100b8:	00813c23          	sd	s0,24(sp)
   100bc:	02010413          	addi	s0,sp,32
   100c0:	fe843783          	ld	a5,-24(s0)
   100c4:	0ac00893          	li	a7,172
   100c8:	00000073          	ecall
   100cc:	00050793          	mv	a5,a0
   100d0:	fef43423          	sd	a5,-24(s0)
   100d4:	fe843783          	ld	a5,-24(s0)
   100d8:	00078513          	mv	a0,a5
   100dc:	01813403          	ld	s0,24(sp)
   100e0:	02010113          	addi	sp,sp,32
   100e4:	00008067          	ret

00000000000100e8 <main>:
   100e8:	fe010113          	addi	sp,sp,-32
   100ec:	00113c23          	sd	ra,24(sp)
   100f0:	00813823          	sd	s0,16(sp)
   100f4:	02010413          	addi	s0,sp,32
   100f8:	00000097          	auipc	ra,0x0
   100fc:	fbc080e7          	jalr	-68(ra) # 100b4 <getpid>
   10100:	00050593          	mv	a1,a0
   10104:	00010613          	mv	a2,sp
   10108:	00002797          	auipc	a5,0x2
   1010c:	0b878793          	addi	a5,a5,184 # 121c0 <counter>
   10110:	0007a783          	lw	a5,0(a5)
   10114:	0017879b          	addiw	a5,a5,1
   10118:	0007871b          	sext.w	a4,a5
   1011c:	00002797          	auipc	a5,0x2
   10120:	0a478793          	addi	a5,a5,164 # 121c0 <counter>
   10124:	00e7a023          	sw	a4,0(a5)
   10128:	00002797          	auipc	a5,0x2
   1012c:	09878793          	addi	a5,a5,152 # 121c0 <counter>
   10130:	0007a783          	lw	a5,0(a5)
   10134:	00078693          	mv	a3,a5
   10138:	00001517          	auipc	a0,0x1
   1013c:	00050513          	mv	a0,a0
   10140:	00001097          	auipc	ra,0x1
   10144:	ef4080e7          	jalr	-268(ra) # 11034 <printf>
   10148:	fe042623          	sw	zero,-20(s0)
   1014c:	0100006f          	j	1015c <main+0x74>
   10150:	fec42783          	lw	a5,-20(s0)
   10154:	0017879b          	addiw	a5,a5,1
   10158:	fef42623          	sw	a5,-20(s0)
   1015c:	fec42783          	lw	a5,-20(s0)
   10160:	0007871b          	sext.w	a4,a5
   10164:	500007b7          	lui	a5,0x50000
   10168:	ffe78793          	addi	a5,a5,-2 # 4ffffffe <__global_pointer$+0x4ffed645>
   1016c:	fee7f2e3          	bgeu	a5,a4,10150 <main+0x68>
   10170:	f89ff06f          	j	100f8 <main+0x10>

0000000000010174 <putc>:
   10174:	fe010113          	addi	sp,sp,-32
   10178:	00813c23          	sd	s0,24(sp)
   1017c:	02010413          	addi	s0,sp,32
   10180:	00050793          	mv	a5,a0
   10184:	fef42623          	sw	a5,-20(s0)
   10188:	00002797          	auipc	a5,0x2
   1018c:	03c78793          	addi	a5,a5,60 # 121c4 <tail>
   10190:	0007a783          	lw	a5,0(a5)
   10194:	0017871b          	addiw	a4,a5,1
   10198:	0007069b          	sext.w	a3,a4
   1019c:	00002717          	auipc	a4,0x2
   101a0:	02870713          	addi	a4,a4,40 # 121c4 <tail>
   101a4:	00d72023          	sw	a3,0(a4)
   101a8:	fec42703          	lw	a4,-20(s0)
   101ac:	0ff77713          	andi	a4,a4,255
   101b0:	00002697          	auipc	a3,0x2
   101b4:	01868693          	addi	a3,a3,24 # 121c8 <buffer>
   101b8:	00f687b3          	add	a5,a3,a5
   101bc:	00e78023          	sb	a4,0(a5)
   101c0:	fec42783          	lw	a5,-20(s0)
   101c4:	0ff7f793          	andi	a5,a5,255
   101c8:	0007879b          	sext.w	a5,a5
   101cc:	00078513          	mv	a0,a5
   101d0:	01813403          	ld	s0,24(sp)
   101d4:	02010113          	addi	sp,sp,32
   101d8:	00008067          	ret

00000000000101dc <isspace>:
   101dc:	fe010113          	addi	sp,sp,-32
   101e0:	00813c23          	sd	s0,24(sp)
   101e4:	02010413          	addi	s0,sp,32
   101e8:	00050793          	mv	a5,a0
   101ec:	fef42623          	sw	a5,-20(s0)
   101f0:	fec42783          	lw	a5,-20(s0)
   101f4:	0007871b          	sext.w	a4,a5
   101f8:	02000793          	li	a5,32
   101fc:	02f70263          	beq	a4,a5,10220 <isspace+0x44>
   10200:	fec42783          	lw	a5,-20(s0)
   10204:	0007871b          	sext.w	a4,a5
   10208:	00800793          	li	a5,8
   1020c:	00e7de63          	bge	a5,a4,10228 <isspace+0x4c>
   10210:	fec42783          	lw	a5,-20(s0)
   10214:	0007871b          	sext.w	a4,a5
   10218:	00d00793          	li	a5,13
   1021c:	00e7c663          	blt	a5,a4,10228 <isspace+0x4c>
   10220:	00100793          	li	a5,1
   10224:	0080006f          	j	1022c <isspace+0x50>
   10228:	00000793          	li	a5,0
   1022c:	00078513          	mv	a0,a5
   10230:	01813403          	ld	s0,24(sp)
   10234:	02010113          	addi	sp,sp,32
   10238:	00008067          	ret

000000000001023c <strtol>:
   1023c:	fb010113          	addi	sp,sp,-80
   10240:	04113423          	sd	ra,72(sp)
   10244:	04813023          	sd	s0,64(sp)
   10248:	05010413          	addi	s0,sp,80
   1024c:	fca43423          	sd	a0,-56(s0)
   10250:	fcb43023          	sd	a1,-64(s0)
   10254:	00060793          	mv	a5,a2
   10258:	faf42e23          	sw	a5,-68(s0)
   1025c:	fe043423          	sd	zero,-24(s0)
   10260:	fe0403a3          	sb	zero,-25(s0)
   10264:	fc843783          	ld	a5,-56(s0)
   10268:	fcf43c23          	sd	a5,-40(s0)
   1026c:	0100006f          	j	1027c <strtol+0x40>
   10270:	fd843783          	ld	a5,-40(s0)
   10274:	00178793          	addi	a5,a5,1
   10278:	fcf43c23          	sd	a5,-40(s0)
   1027c:	fd843783          	ld	a5,-40(s0)
   10280:	0007c783          	lbu	a5,0(a5)
   10284:	0007879b          	sext.w	a5,a5
   10288:	00078513          	mv	a0,a5
   1028c:	00000097          	auipc	ra,0x0
   10290:	f50080e7          	jalr	-176(ra) # 101dc <isspace>
   10294:	00050793          	mv	a5,a0
   10298:	fc079ce3          	bnez	a5,10270 <strtol+0x34>
   1029c:	fd843783          	ld	a5,-40(s0)
   102a0:	0007c783          	lbu	a5,0(a5)
   102a4:	00078713          	mv	a4,a5
   102a8:	02d00793          	li	a5,45
   102ac:	00f71e63          	bne	a4,a5,102c8 <strtol+0x8c>
   102b0:	00100793          	li	a5,1
   102b4:	fef403a3          	sb	a5,-25(s0)
   102b8:	fd843783          	ld	a5,-40(s0)
   102bc:	00178793          	addi	a5,a5,1
   102c0:	fcf43c23          	sd	a5,-40(s0)
   102c4:	0240006f          	j	102e8 <strtol+0xac>
   102c8:	fd843783          	ld	a5,-40(s0)
   102cc:	0007c783          	lbu	a5,0(a5)
   102d0:	00078713          	mv	a4,a5
   102d4:	02b00793          	li	a5,43
   102d8:	00f71863          	bne	a4,a5,102e8 <strtol+0xac>
   102dc:	fd843783          	ld	a5,-40(s0)
   102e0:	00178793          	addi	a5,a5,1
   102e4:	fcf43c23          	sd	a5,-40(s0)
   102e8:	fbc42783          	lw	a5,-68(s0)
   102ec:	0007879b          	sext.w	a5,a5
   102f0:	06079c63          	bnez	a5,10368 <strtol+0x12c>
   102f4:	fd843783          	ld	a5,-40(s0)
   102f8:	0007c783          	lbu	a5,0(a5)
   102fc:	00078713          	mv	a4,a5
   10300:	03000793          	li	a5,48
   10304:	04f71e63          	bne	a4,a5,10360 <strtol+0x124>
   10308:	fd843783          	ld	a5,-40(s0)
   1030c:	00178793          	addi	a5,a5,1
   10310:	fcf43c23          	sd	a5,-40(s0)
   10314:	fd843783          	ld	a5,-40(s0)
   10318:	0007c783          	lbu	a5,0(a5)
   1031c:	00078713          	mv	a4,a5
   10320:	07800793          	li	a5,120
   10324:	00f70c63          	beq	a4,a5,1033c <strtol+0x100>
   10328:	fd843783          	ld	a5,-40(s0)
   1032c:	0007c783          	lbu	a5,0(a5)
   10330:	00078713          	mv	a4,a5
   10334:	05800793          	li	a5,88
   10338:	00f71e63          	bne	a4,a5,10354 <strtol+0x118>
   1033c:	01000793          	li	a5,16
   10340:	faf42e23          	sw	a5,-68(s0)
   10344:	fd843783          	ld	a5,-40(s0)
   10348:	00178793          	addi	a5,a5,1
   1034c:	fcf43c23          	sd	a5,-40(s0)
   10350:	0180006f          	j	10368 <strtol+0x12c>
   10354:	00800793          	li	a5,8
   10358:	faf42e23          	sw	a5,-68(s0)
   1035c:	00c0006f          	j	10368 <strtol+0x12c>
   10360:	00a00793          	li	a5,10
   10364:	faf42e23          	sw	a5,-68(s0)
   10368:	fd843783          	ld	a5,-40(s0)
   1036c:	0007c783          	lbu	a5,0(a5)
   10370:	00078713          	mv	a4,a5
   10374:	02f00793          	li	a5,47
   10378:	02e7f863          	bgeu	a5,a4,103a8 <strtol+0x16c>
   1037c:	fd843783          	ld	a5,-40(s0)
   10380:	0007c783          	lbu	a5,0(a5)
   10384:	00078713          	mv	a4,a5
   10388:	03900793          	li	a5,57
   1038c:	00e7ee63          	bltu	a5,a4,103a8 <strtol+0x16c>
   10390:	fd843783          	ld	a5,-40(s0)
   10394:	0007c783          	lbu	a5,0(a5)
   10398:	0007879b          	sext.w	a5,a5
   1039c:	fd07879b          	addiw	a5,a5,-48
   103a0:	fcf42a23          	sw	a5,-44(s0)
   103a4:	0800006f          	j	10424 <strtol+0x1e8>
   103a8:	fd843783          	ld	a5,-40(s0)
   103ac:	0007c783          	lbu	a5,0(a5)
   103b0:	00078713          	mv	a4,a5
   103b4:	06000793          	li	a5,96
   103b8:	02e7f863          	bgeu	a5,a4,103e8 <strtol+0x1ac>
   103bc:	fd843783          	ld	a5,-40(s0)
   103c0:	0007c783          	lbu	a5,0(a5)
   103c4:	00078713          	mv	a4,a5
   103c8:	07a00793          	li	a5,122
   103cc:	00e7ee63          	bltu	a5,a4,103e8 <strtol+0x1ac>
   103d0:	fd843783          	ld	a5,-40(s0)
   103d4:	0007c783          	lbu	a5,0(a5)
   103d8:	0007879b          	sext.w	a5,a5
   103dc:	fa97879b          	addiw	a5,a5,-87
   103e0:	fcf42a23          	sw	a5,-44(s0)
   103e4:	0400006f          	j	10424 <strtol+0x1e8>
   103e8:	fd843783          	ld	a5,-40(s0)
   103ec:	0007c783          	lbu	a5,0(a5)
   103f0:	00078713          	mv	a4,a5
   103f4:	04000793          	li	a5,64
   103f8:	06e7f663          	bgeu	a5,a4,10464 <strtol+0x228>
   103fc:	fd843783          	ld	a5,-40(s0)
   10400:	0007c783          	lbu	a5,0(a5)
   10404:	00078713          	mv	a4,a5
   10408:	05a00793          	li	a5,90
   1040c:	04e7ec63          	bltu	a5,a4,10464 <strtol+0x228>
   10410:	fd843783          	ld	a5,-40(s0)
   10414:	0007c783          	lbu	a5,0(a5)
   10418:	0007879b          	sext.w	a5,a5
   1041c:	fc97879b          	addiw	a5,a5,-55
   10420:	fcf42a23          	sw	a5,-44(s0)
   10424:	fd442703          	lw	a4,-44(s0)
   10428:	fbc42783          	lw	a5,-68(s0)
   1042c:	0007071b          	sext.w	a4,a4
   10430:	0007879b          	sext.w	a5,a5
   10434:	02f75663          	bge	a4,a5,10460 <strtol+0x224>
   10438:	fbc42703          	lw	a4,-68(s0)
   1043c:	fe843783          	ld	a5,-24(s0)
   10440:	02f70733          	mul	a4,a4,a5
   10444:	fd442783          	lw	a5,-44(s0)
   10448:	00f707b3          	add	a5,a4,a5
   1044c:	fef43423          	sd	a5,-24(s0)
   10450:	fd843783          	ld	a5,-40(s0)
   10454:	00178793          	addi	a5,a5,1
   10458:	fcf43c23          	sd	a5,-40(s0)
   1045c:	f0dff06f          	j	10368 <strtol+0x12c>
   10460:	00000013          	nop
   10464:	fc043783          	ld	a5,-64(s0)
   10468:	00078863          	beqz	a5,10478 <strtol+0x23c>
   1046c:	fc043783          	ld	a5,-64(s0)
   10470:	fd843703          	ld	a4,-40(s0)
   10474:	00e7b023          	sd	a4,0(a5)
   10478:	fe744783          	lbu	a5,-25(s0)
   1047c:	0ff7f793          	andi	a5,a5,255
   10480:	00078863          	beqz	a5,10490 <strtol+0x254>
   10484:	fe843783          	ld	a5,-24(s0)
   10488:	40f007b3          	neg	a5,a5
   1048c:	0080006f          	j	10494 <strtol+0x258>
   10490:	fe843783          	ld	a5,-24(s0)
   10494:	00078513          	mv	a0,a5
   10498:	04813083          	ld	ra,72(sp)
   1049c:	04013403          	ld	s0,64(sp)
   104a0:	05010113          	addi	sp,sp,80
   104a4:	00008067          	ret

00000000000104a8 <puts_wo_nl>:
   104a8:	fd010113          	addi	sp,sp,-48
   104ac:	02113423          	sd	ra,40(sp)
   104b0:	02813023          	sd	s0,32(sp)
   104b4:	03010413          	addi	s0,sp,48
   104b8:	fca43c23          	sd	a0,-40(s0)
   104bc:	fcb43823          	sd	a1,-48(s0)
   104c0:	fd043783          	ld	a5,-48(s0)
   104c4:	00079863          	bnez	a5,104d4 <puts_wo_nl+0x2c>
   104c8:	00001797          	auipc	a5,0x1
   104cc:	ca878793          	addi	a5,a5,-856 # 11170 <printf+0x13c>
   104d0:	fcf43823          	sd	a5,-48(s0)
   104d4:	fd043783          	ld	a5,-48(s0)
   104d8:	fef43423          	sd	a5,-24(s0)
   104dc:	0240006f          	j	10500 <puts_wo_nl+0x58>
   104e0:	fe843783          	ld	a5,-24(s0)
   104e4:	00178713          	addi	a4,a5,1
   104e8:	fee43423          	sd	a4,-24(s0)
   104ec:	0007c783          	lbu	a5,0(a5)
   104f0:	0007879b          	sext.w	a5,a5
   104f4:	fd843703          	ld	a4,-40(s0)
   104f8:	00078513          	mv	a0,a5
   104fc:	000700e7          	jalr	a4
   10500:	fe843783          	ld	a5,-24(s0)
   10504:	0007c783          	lbu	a5,0(a5)
   10508:	fc079ce3          	bnez	a5,104e0 <puts_wo_nl+0x38>
   1050c:	fe843703          	ld	a4,-24(s0)
   10510:	fd043783          	ld	a5,-48(s0)
   10514:	40f707b3          	sub	a5,a4,a5
   10518:	0007879b          	sext.w	a5,a5
   1051c:	00078513          	mv	a0,a5
   10520:	02813083          	ld	ra,40(sp)
   10524:	02013403          	ld	s0,32(sp)
   10528:	03010113          	addi	sp,sp,48
   1052c:	00008067          	ret

0000000000010530 <print_dec_int>:
   10530:	f9010113          	addi	sp,sp,-112
   10534:	06113423          	sd	ra,104(sp)
   10538:	06813023          	sd	s0,96(sp)
   1053c:	07010413          	addi	s0,sp,112
   10540:	faa43423          	sd	a0,-88(s0)
   10544:	fab43023          	sd	a1,-96(s0)
   10548:	00060793          	mv	a5,a2
   1054c:	f8d43823          	sd	a3,-112(s0)
   10550:	f8f40fa3          	sb	a5,-97(s0)
   10554:	f9f44783          	lbu	a5,-97(s0)
   10558:	0ff7f793          	andi	a5,a5,255
   1055c:	02078863          	beqz	a5,1058c <print_dec_int+0x5c>
   10560:	fa043703          	ld	a4,-96(s0)
   10564:	fff00793          	li	a5,-1
   10568:	03f79793          	slli	a5,a5,0x3f
   1056c:	02f71063          	bne	a4,a5,1058c <print_dec_int+0x5c>
   10570:	00001597          	auipc	a1,0x1
   10574:	c0858593          	addi	a1,a1,-1016 # 11178 <printf+0x144>
   10578:	fa843503          	ld	a0,-88(s0)
   1057c:	00000097          	auipc	ra,0x0
   10580:	f2c080e7          	jalr	-212(ra) # 104a8 <puts_wo_nl>
   10584:	00050793          	mv	a5,a0
   10588:	2980006f          	j	10820 <print_dec_int+0x2f0>
   1058c:	f9043783          	ld	a5,-112(s0)
   10590:	00c7a783          	lw	a5,12(a5)
   10594:	00079a63          	bnez	a5,105a8 <print_dec_int+0x78>
   10598:	fa043783          	ld	a5,-96(s0)
   1059c:	00079663          	bnez	a5,105a8 <print_dec_int+0x78>
   105a0:	00000793          	li	a5,0
   105a4:	27c0006f          	j	10820 <print_dec_int+0x2f0>
   105a8:	fe0407a3          	sb	zero,-17(s0)
   105ac:	f9f44783          	lbu	a5,-97(s0)
   105b0:	0ff7f793          	andi	a5,a5,255
   105b4:	02078063          	beqz	a5,105d4 <print_dec_int+0xa4>
   105b8:	fa043783          	ld	a5,-96(s0)
   105bc:	0007dc63          	bgez	a5,105d4 <print_dec_int+0xa4>
   105c0:	00100793          	li	a5,1
   105c4:	fef407a3          	sb	a5,-17(s0)
   105c8:	fa043783          	ld	a5,-96(s0)
   105cc:	40f007b3          	neg	a5,a5
   105d0:	faf43023          	sd	a5,-96(s0)
   105d4:	fe042423          	sw	zero,-24(s0)
   105d8:	f9f44783          	lbu	a5,-97(s0)
   105dc:	0ff7f793          	andi	a5,a5,255
   105e0:	02078863          	beqz	a5,10610 <print_dec_int+0xe0>
   105e4:	fef44783          	lbu	a5,-17(s0)
   105e8:	0ff7f793          	andi	a5,a5,255
   105ec:	00079e63          	bnez	a5,10608 <print_dec_int+0xd8>
   105f0:	f9043783          	ld	a5,-112(s0)
   105f4:	0057c783          	lbu	a5,5(a5)
   105f8:	00079863          	bnez	a5,10608 <print_dec_int+0xd8>
   105fc:	f9043783          	ld	a5,-112(s0)
   10600:	0047c783          	lbu	a5,4(a5)
   10604:	00078663          	beqz	a5,10610 <print_dec_int+0xe0>
   10608:	00100793          	li	a5,1
   1060c:	0080006f          	j	10614 <print_dec_int+0xe4>
   10610:	00000793          	li	a5,0
   10614:	fcf40ba3          	sb	a5,-41(s0)
   10618:	fd744783          	lbu	a5,-41(s0)
   1061c:	0017f793          	andi	a5,a5,1
   10620:	fcf40ba3          	sb	a5,-41(s0)
   10624:	fa043703          	ld	a4,-96(s0)
   10628:	00a00793          	li	a5,10
   1062c:	02f777b3          	remu	a5,a4,a5
   10630:	0ff7f713          	andi	a4,a5,255
   10634:	fe842783          	lw	a5,-24(s0)
   10638:	0017869b          	addiw	a3,a5,1
   1063c:	fed42423          	sw	a3,-24(s0)
   10640:	0307071b          	addiw	a4,a4,48
   10644:	0ff77713          	andi	a4,a4,255
   10648:	ff040693          	addi	a3,s0,-16
   1064c:	00f687b3          	add	a5,a3,a5
   10650:	fce78423          	sb	a4,-56(a5)
   10654:	fa043703          	ld	a4,-96(s0)
   10658:	00a00793          	li	a5,10
   1065c:	02f757b3          	divu	a5,a4,a5
   10660:	faf43023          	sd	a5,-96(s0)
   10664:	fa043783          	ld	a5,-96(s0)
   10668:	fa079ee3          	bnez	a5,10624 <print_dec_int+0xf4>
   1066c:	f9043783          	ld	a5,-112(s0)
   10670:	00c7a783          	lw	a5,12(a5)
   10674:	00078713          	mv	a4,a5
   10678:	fff00793          	li	a5,-1
   1067c:	02f71063          	bne	a4,a5,1069c <print_dec_int+0x16c>
   10680:	f9043783          	ld	a5,-112(s0)
   10684:	0037c783          	lbu	a5,3(a5)
   10688:	00078a63          	beqz	a5,1069c <print_dec_int+0x16c>
   1068c:	f9043783          	ld	a5,-112(s0)
   10690:	0087a703          	lw	a4,8(a5)
   10694:	f9043783          	ld	a5,-112(s0)
   10698:	00e7a623          	sw	a4,12(a5)
   1069c:	fe042223          	sw	zero,-28(s0)
   106a0:	f9043783          	ld	a5,-112(s0)
   106a4:	0087a703          	lw	a4,8(a5)
   106a8:	fe842783          	lw	a5,-24(s0)
   106ac:	fcf42823          	sw	a5,-48(s0)
   106b0:	f9043783          	ld	a5,-112(s0)
   106b4:	00c7a783          	lw	a5,12(a5)
   106b8:	fcf42623          	sw	a5,-52(s0)
   106bc:	fd042583          	lw	a1,-48(s0)
   106c0:	fcc42783          	lw	a5,-52(s0)
   106c4:	0007861b          	sext.w	a2,a5
   106c8:	0005869b          	sext.w	a3,a1
   106cc:	00d65463          	bge	a2,a3,106d4 <print_dec_int+0x1a4>
   106d0:	00058793          	mv	a5,a1
   106d4:	0007879b          	sext.w	a5,a5
   106d8:	40f707bb          	subw	a5,a4,a5
   106dc:	0007871b          	sext.w	a4,a5
   106e0:	fd744783          	lbu	a5,-41(s0)
   106e4:	0007879b          	sext.w	a5,a5
   106e8:	40f707bb          	subw	a5,a4,a5
   106ec:	fef42023          	sw	a5,-32(s0)
   106f0:	0280006f          	j	10718 <print_dec_int+0x1e8>
   106f4:	fa843783          	ld	a5,-88(s0)
   106f8:	02000513          	li	a0,32
   106fc:	000780e7          	jalr	a5
   10700:	fe442783          	lw	a5,-28(s0)
   10704:	0017879b          	addiw	a5,a5,1
   10708:	fef42223          	sw	a5,-28(s0)
   1070c:	fe042783          	lw	a5,-32(s0)
   10710:	fff7879b          	addiw	a5,a5,-1
   10714:	fef42023          	sw	a5,-32(s0)
   10718:	fe042783          	lw	a5,-32(s0)
   1071c:	0007879b          	sext.w	a5,a5
   10720:	fcf04ae3          	bgtz	a5,106f4 <print_dec_int+0x1c4>
   10724:	fd744783          	lbu	a5,-41(s0)
   10728:	0ff7f793          	andi	a5,a5,255
   1072c:	04078463          	beqz	a5,10774 <print_dec_int+0x244>
   10730:	fef44783          	lbu	a5,-17(s0)
   10734:	0ff7f793          	andi	a5,a5,255
   10738:	00078663          	beqz	a5,10744 <print_dec_int+0x214>
   1073c:	02d00793          	li	a5,45
   10740:	01c0006f          	j	1075c <print_dec_int+0x22c>
   10744:	f9043783          	ld	a5,-112(s0)
   10748:	0057c783          	lbu	a5,5(a5)
   1074c:	00078663          	beqz	a5,10758 <print_dec_int+0x228>
   10750:	02b00793          	li	a5,43
   10754:	0080006f          	j	1075c <print_dec_int+0x22c>
   10758:	02000793          	li	a5,32
   1075c:	fa843703          	ld	a4,-88(s0)
   10760:	00078513          	mv	a0,a5
   10764:	000700e7          	jalr	a4
   10768:	fe442783          	lw	a5,-28(s0)
   1076c:	0017879b          	addiw	a5,a5,1
   10770:	fef42223          	sw	a5,-28(s0)
   10774:	fe842783          	lw	a5,-24(s0)
   10778:	fcf42e23          	sw	a5,-36(s0)
   1077c:	0280006f          	j	107a4 <print_dec_int+0x274>
   10780:	fa843783          	ld	a5,-88(s0)
   10784:	03000513          	li	a0,48
   10788:	000780e7          	jalr	a5
   1078c:	fe442783          	lw	a5,-28(s0)
   10790:	0017879b          	addiw	a5,a5,1
   10794:	fef42223          	sw	a5,-28(s0)
   10798:	fdc42783          	lw	a5,-36(s0)
   1079c:	0017879b          	addiw	a5,a5,1
   107a0:	fcf42e23          	sw	a5,-36(s0)
   107a4:	f9043783          	ld	a5,-112(s0)
   107a8:	00c7a703          	lw	a4,12(a5)
   107ac:	fd744783          	lbu	a5,-41(s0)
   107b0:	0007879b          	sext.w	a5,a5
   107b4:	40f707bb          	subw	a5,a4,a5
   107b8:	0007871b          	sext.w	a4,a5
   107bc:	fdc42783          	lw	a5,-36(s0)
   107c0:	0007879b          	sext.w	a5,a5
   107c4:	fae7cee3          	blt	a5,a4,10780 <print_dec_int+0x250>
   107c8:	fe842783          	lw	a5,-24(s0)
   107cc:	fff7879b          	addiw	a5,a5,-1
   107d0:	fcf42c23          	sw	a5,-40(s0)
   107d4:	03c0006f          	j	10810 <print_dec_int+0x2e0>
   107d8:	fd842783          	lw	a5,-40(s0)
   107dc:	ff040713          	addi	a4,s0,-16
   107e0:	00f707b3          	add	a5,a4,a5
   107e4:	fc87c783          	lbu	a5,-56(a5)
   107e8:	0007879b          	sext.w	a5,a5
   107ec:	fa843703          	ld	a4,-88(s0)
   107f0:	00078513          	mv	a0,a5
   107f4:	000700e7          	jalr	a4
   107f8:	fe442783          	lw	a5,-28(s0)
   107fc:	0017879b          	addiw	a5,a5,1
   10800:	fef42223          	sw	a5,-28(s0)
   10804:	fd842783          	lw	a5,-40(s0)
   10808:	fff7879b          	addiw	a5,a5,-1
   1080c:	fcf42c23          	sw	a5,-40(s0)
   10810:	fd842783          	lw	a5,-40(s0)
   10814:	0007879b          	sext.w	a5,a5
   10818:	fc07d0e3          	bgez	a5,107d8 <print_dec_int+0x2a8>
   1081c:	fe442783          	lw	a5,-28(s0)
   10820:	00078513          	mv	a0,a5
   10824:	06813083          	ld	ra,104(sp)
   10828:	06013403          	ld	s0,96(sp)
   1082c:	07010113          	addi	sp,sp,112
   10830:	00008067          	ret

0000000000010834 <vprintfmt>:
   10834:	f4010113          	addi	sp,sp,-192
   10838:	0a113c23          	sd	ra,184(sp)
   1083c:	0a813823          	sd	s0,176(sp)
   10840:	0c010413          	addi	s0,sp,192
   10844:	f4a43c23          	sd	a0,-168(s0)
   10848:	f4b43823          	sd	a1,-176(s0)
   1084c:	f4c43423          	sd	a2,-184(s0)
   10850:	f8043023          	sd	zero,-128(s0)
   10854:	f8043423          	sd	zero,-120(s0)
   10858:	fe042623          	sw	zero,-20(s0)
   1085c:	7b40006f          	j	11010 <vprintfmt+0x7dc>
   10860:	f8044783          	lbu	a5,-128(s0)
   10864:	74078663          	beqz	a5,10fb0 <vprintfmt+0x77c>
   10868:	f5043783          	ld	a5,-176(s0)
   1086c:	0007c783          	lbu	a5,0(a5)
   10870:	00078713          	mv	a4,a5
   10874:	02300793          	li	a5,35
   10878:	00f71863          	bne	a4,a5,10888 <vprintfmt+0x54>
   1087c:	00100793          	li	a5,1
   10880:	f8f40123          	sb	a5,-126(s0)
   10884:	7800006f          	j	11004 <vprintfmt+0x7d0>
   10888:	f5043783          	ld	a5,-176(s0)
   1088c:	0007c783          	lbu	a5,0(a5)
   10890:	00078713          	mv	a4,a5
   10894:	03000793          	li	a5,48
   10898:	00f71863          	bne	a4,a5,108a8 <vprintfmt+0x74>
   1089c:	00100793          	li	a5,1
   108a0:	f8f401a3          	sb	a5,-125(s0)
   108a4:	7600006f          	j	11004 <vprintfmt+0x7d0>
   108a8:	f5043783          	ld	a5,-176(s0)
   108ac:	0007c783          	lbu	a5,0(a5)
   108b0:	00078713          	mv	a4,a5
   108b4:	06c00793          	li	a5,108
   108b8:	04f70063          	beq	a4,a5,108f8 <vprintfmt+0xc4>
   108bc:	f5043783          	ld	a5,-176(s0)
   108c0:	0007c783          	lbu	a5,0(a5)
   108c4:	00078713          	mv	a4,a5
   108c8:	07a00793          	li	a5,122
   108cc:	02f70663          	beq	a4,a5,108f8 <vprintfmt+0xc4>
   108d0:	f5043783          	ld	a5,-176(s0)
   108d4:	0007c783          	lbu	a5,0(a5)
   108d8:	00078713          	mv	a4,a5
   108dc:	07400793          	li	a5,116
   108e0:	00f70c63          	beq	a4,a5,108f8 <vprintfmt+0xc4>
   108e4:	f5043783          	ld	a5,-176(s0)
   108e8:	0007c783          	lbu	a5,0(a5)
   108ec:	00078713          	mv	a4,a5
   108f0:	06a00793          	li	a5,106
   108f4:	00f71863          	bne	a4,a5,10904 <vprintfmt+0xd0>
   108f8:	00100793          	li	a5,1
   108fc:	f8f400a3          	sb	a5,-127(s0)
   10900:	7040006f          	j	11004 <vprintfmt+0x7d0>
   10904:	f5043783          	ld	a5,-176(s0)
   10908:	0007c783          	lbu	a5,0(a5)
   1090c:	00078713          	mv	a4,a5
   10910:	02b00793          	li	a5,43
   10914:	00f71863          	bne	a4,a5,10924 <vprintfmt+0xf0>
   10918:	00100793          	li	a5,1
   1091c:	f8f402a3          	sb	a5,-123(s0)
   10920:	6e40006f          	j	11004 <vprintfmt+0x7d0>
   10924:	f5043783          	ld	a5,-176(s0)
   10928:	0007c783          	lbu	a5,0(a5)
   1092c:	00078713          	mv	a4,a5
   10930:	02000793          	li	a5,32
   10934:	00f71863          	bne	a4,a5,10944 <vprintfmt+0x110>
   10938:	00100793          	li	a5,1
   1093c:	f8f40223          	sb	a5,-124(s0)
   10940:	6c40006f          	j	11004 <vprintfmt+0x7d0>
   10944:	f5043783          	ld	a5,-176(s0)
   10948:	0007c783          	lbu	a5,0(a5)
   1094c:	00078713          	mv	a4,a5
   10950:	02a00793          	li	a5,42
   10954:	00f71e63          	bne	a4,a5,10970 <vprintfmt+0x13c>
   10958:	f4843783          	ld	a5,-184(s0)
   1095c:	00878713          	addi	a4,a5,8
   10960:	f4e43423          	sd	a4,-184(s0)
   10964:	0007a783          	lw	a5,0(a5)
   10968:	f8f42423          	sw	a5,-120(s0)
   1096c:	6980006f          	j	11004 <vprintfmt+0x7d0>
   10970:	f5043783          	ld	a5,-176(s0)
   10974:	0007c783          	lbu	a5,0(a5)
   10978:	00078713          	mv	a4,a5
   1097c:	03000793          	li	a5,48
   10980:	04e7f863          	bgeu	a5,a4,109d0 <vprintfmt+0x19c>
   10984:	f5043783          	ld	a5,-176(s0)
   10988:	0007c783          	lbu	a5,0(a5)
   1098c:	00078713          	mv	a4,a5
   10990:	03900793          	li	a5,57
   10994:	02e7ee63          	bltu	a5,a4,109d0 <vprintfmt+0x19c>
   10998:	f5043783          	ld	a5,-176(s0)
   1099c:	f5040713          	addi	a4,s0,-176
   109a0:	00a00613          	li	a2,10
   109a4:	00070593          	mv	a1,a4
   109a8:	00078513          	mv	a0,a5
   109ac:	00000097          	auipc	ra,0x0
   109b0:	890080e7          	jalr	-1904(ra) # 1023c <strtol>
   109b4:	00050793          	mv	a5,a0
   109b8:	0007879b          	sext.w	a5,a5
   109bc:	f8f42423          	sw	a5,-120(s0)
   109c0:	f5043783          	ld	a5,-176(s0)
   109c4:	fff78793          	addi	a5,a5,-1
   109c8:	f4f43823          	sd	a5,-176(s0)
   109cc:	6380006f          	j	11004 <vprintfmt+0x7d0>
   109d0:	f5043783          	ld	a5,-176(s0)
   109d4:	0007c783          	lbu	a5,0(a5)
   109d8:	00078713          	mv	a4,a5
   109dc:	02e00793          	li	a5,46
   109e0:	06f71a63          	bne	a4,a5,10a54 <vprintfmt+0x220>
   109e4:	f5043783          	ld	a5,-176(s0)
   109e8:	00178793          	addi	a5,a5,1
   109ec:	f4f43823          	sd	a5,-176(s0)
   109f0:	f5043783          	ld	a5,-176(s0)
   109f4:	0007c783          	lbu	a5,0(a5)
   109f8:	00078713          	mv	a4,a5
   109fc:	02a00793          	li	a5,42
   10a00:	00f71e63          	bne	a4,a5,10a1c <vprintfmt+0x1e8>
   10a04:	f4843783          	ld	a5,-184(s0)
   10a08:	00878713          	addi	a4,a5,8
   10a0c:	f4e43423          	sd	a4,-184(s0)
   10a10:	0007a783          	lw	a5,0(a5)
   10a14:	f8f42623          	sw	a5,-116(s0)
   10a18:	5ec0006f          	j	11004 <vprintfmt+0x7d0>
   10a1c:	f5043783          	ld	a5,-176(s0)
   10a20:	f5040713          	addi	a4,s0,-176
   10a24:	00a00613          	li	a2,10
   10a28:	00070593          	mv	a1,a4
   10a2c:	00078513          	mv	a0,a5
   10a30:	00000097          	auipc	ra,0x0
   10a34:	80c080e7          	jalr	-2036(ra) # 1023c <strtol>
   10a38:	00050793          	mv	a5,a0
   10a3c:	0007879b          	sext.w	a5,a5
   10a40:	f8f42623          	sw	a5,-116(s0)
   10a44:	f5043783          	ld	a5,-176(s0)
   10a48:	fff78793          	addi	a5,a5,-1
   10a4c:	f4f43823          	sd	a5,-176(s0)
   10a50:	5b40006f          	j	11004 <vprintfmt+0x7d0>
   10a54:	f5043783          	ld	a5,-176(s0)
   10a58:	0007c783          	lbu	a5,0(a5)
   10a5c:	00078713          	mv	a4,a5
   10a60:	07800793          	li	a5,120
   10a64:	02f70663          	beq	a4,a5,10a90 <vprintfmt+0x25c>
   10a68:	f5043783          	ld	a5,-176(s0)
   10a6c:	0007c783          	lbu	a5,0(a5)
   10a70:	00078713          	mv	a4,a5
   10a74:	05800793          	li	a5,88
   10a78:	00f70c63          	beq	a4,a5,10a90 <vprintfmt+0x25c>
   10a7c:	f5043783          	ld	a5,-176(s0)
   10a80:	0007c783          	lbu	a5,0(a5)
   10a84:	00078713          	mv	a4,a5
   10a88:	07000793          	li	a5,112
   10a8c:	2ef71e63          	bne	a4,a5,10d88 <vprintfmt+0x554>
   10a90:	f5043783          	ld	a5,-176(s0)
   10a94:	0007c783          	lbu	a5,0(a5)
   10a98:	00078713          	mv	a4,a5
   10a9c:	07000793          	li	a5,112
   10aa0:	00f70663          	beq	a4,a5,10aac <vprintfmt+0x278>
   10aa4:	f8144783          	lbu	a5,-127(s0)
   10aa8:	00078663          	beqz	a5,10ab4 <vprintfmt+0x280>
   10aac:	00100793          	li	a5,1
   10ab0:	0080006f          	j	10ab8 <vprintfmt+0x284>
   10ab4:	00000793          	li	a5,0
   10ab8:	faf403a3          	sb	a5,-89(s0)
   10abc:	fa744783          	lbu	a5,-89(s0)
   10ac0:	0017f793          	andi	a5,a5,1
   10ac4:	faf403a3          	sb	a5,-89(s0)
   10ac8:	fa744783          	lbu	a5,-89(s0)
   10acc:	0ff7f793          	andi	a5,a5,255
   10ad0:	00078c63          	beqz	a5,10ae8 <vprintfmt+0x2b4>
   10ad4:	f4843783          	ld	a5,-184(s0)
   10ad8:	00878713          	addi	a4,a5,8
   10adc:	f4e43423          	sd	a4,-184(s0)
   10ae0:	0007b783          	ld	a5,0(a5)
   10ae4:	01c0006f          	j	10b00 <vprintfmt+0x2cc>
   10ae8:	f4843783          	ld	a5,-184(s0)
   10aec:	00878713          	addi	a4,a5,8
   10af0:	f4e43423          	sd	a4,-184(s0)
   10af4:	0007a783          	lw	a5,0(a5)
   10af8:	02079793          	slli	a5,a5,0x20
   10afc:	0207d793          	srli	a5,a5,0x20
   10b00:	fef43023          	sd	a5,-32(s0)
   10b04:	f8c42783          	lw	a5,-116(s0)
   10b08:	02079463          	bnez	a5,10b30 <vprintfmt+0x2fc>
   10b0c:	fe043783          	ld	a5,-32(s0)
   10b10:	02079063          	bnez	a5,10b30 <vprintfmt+0x2fc>
   10b14:	f5043783          	ld	a5,-176(s0)
   10b18:	0007c783          	lbu	a5,0(a5)
   10b1c:	00078713          	mv	a4,a5
   10b20:	07000793          	li	a5,112
   10b24:	00f70663          	beq	a4,a5,10b30 <vprintfmt+0x2fc>
   10b28:	f8040023          	sb	zero,-128(s0)
   10b2c:	4d80006f          	j	11004 <vprintfmt+0x7d0>
   10b30:	f5043783          	ld	a5,-176(s0)
   10b34:	0007c783          	lbu	a5,0(a5)
   10b38:	00078713          	mv	a4,a5
   10b3c:	07000793          	li	a5,112
   10b40:	00f70a63          	beq	a4,a5,10b54 <vprintfmt+0x320>
   10b44:	f8244783          	lbu	a5,-126(s0)
   10b48:	00078a63          	beqz	a5,10b5c <vprintfmt+0x328>
   10b4c:	fe043783          	ld	a5,-32(s0)
   10b50:	00078663          	beqz	a5,10b5c <vprintfmt+0x328>
   10b54:	00100793          	li	a5,1
   10b58:	0080006f          	j	10b60 <vprintfmt+0x32c>
   10b5c:	00000793          	li	a5,0
   10b60:	faf40323          	sb	a5,-90(s0)
   10b64:	fa644783          	lbu	a5,-90(s0)
   10b68:	0017f793          	andi	a5,a5,1
   10b6c:	faf40323          	sb	a5,-90(s0)
   10b70:	fc042e23          	sw	zero,-36(s0)
   10b74:	f5043783          	ld	a5,-176(s0)
   10b78:	0007c783          	lbu	a5,0(a5)
   10b7c:	00078713          	mv	a4,a5
   10b80:	05800793          	li	a5,88
   10b84:	00f71863          	bne	a4,a5,10b94 <vprintfmt+0x360>
   10b88:	00000797          	auipc	a5,0x0
   10b8c:	60878793          	addi	a5,a5,1544 # 11190 <upperxdigits.1056>
   10b90:	00c0006f          	j	10b9c <vprintfmt+0x368>
   10b94:	00000797          	auipc	a5,0x0
   10b98:	61478793          	addi	a5,a5,1556 # 111a8 <lowerxdigits.1055>
   10b9c:	f8f43c23          	sd	a5,-104(s0)
   10ba0:	fe043783          	ld	a5,-32(s0)
   10ba4:	00f7f793          	andi	a5,a5,15
   10ba8:	f9843703          	ld	a4,-104(s0)
   10bac:	00f70733          	add	a4,a4,a5
   10bb0:	fdc42783          	lw	a5,-36(s0)
   10bb4:	0017869b          	addiw	a3,a5,1
   10bb8:	fcd42e23          	sw	a3,-36(s0)
   10bbc:	00074703          	lbu	a4,0(a4)
   10bc0:	ff040693          	addi	a3,s0,-16
   10bc4:	00f687b3          	add	a5,a3,a5
   10bc8:	f8e78023          	sb	a4,-128(a5)
   10bcc:	fe043783          	ld	a5,-32(s0)
   10bd0:	0047d793          	srli	a5,a5,0x4
   10bd4:	fef43023          	sd	a5,-32(s0)
   10bd8:	fe043783          	ld	a5,-32(s0)
   10bdc:	fc0792e3          	bnez	a5,10ba0 <vprintfmt+0x36c>
   10be0:	f8c42783          	lw	a5,-116(s0)
   10be4:	00078713          	mv	a4,a5
   10be8:	fff00793          	li	a5,-1
   10bec:	02f71663          	bne	a4,a5,10c18 <vprintfmt+0x3e4>
   10bf0:	f8344783          	lbu	a5,-125(s0)
   10bf4:	02078263          	beqz	a5,10c18 <vprintfmt+0x3e4>
   10bf8:	f8842703          	lw	a4,-120(s0)
   10bfc:	fa644783          	lbu	a5,-90(s0)
   10c00:	0007879b          	sext.w	a5,a5
   10c04:	0017979b          	slliw	a5,a5,0x1
   10c08:	0007879b          	sext.w	a5,a5
   10c0c:	40f707bb          	subw	a5,a4,a5
   10c10:	0007879b          	sext.w	a5,a5
   10c14:	f8f42623          	sw	a5,-116(s0)
   10c18:	f8842703          	lw	a4,-120(s0)
   10c1c:	fa644783          	lbu	a5,-90(s0)
   10c20:	0007879b          	sext.w	a5,a5
   10c24:	0017979b          	slliw	a5,a5,0x1
   10c28:	0007879b          	sext.w	a5,a5
   10c2c:	40f707bb          	subw	a5,a4,a5
   10c30:	0007871b          	sext.w	a4,a5
   10c34:	fdc42783          	lw	a5,-36(s0)
   10c38:	f8f42a23          	sw	a5,-108(s0)
   10c3c:	f8c42783          	lw	a5,-116(s0)
   10c40:	f8f42823          	sw	a5,-112(s0)
   10c44:	f9442583          	lw	a1,-108(s0)
   10c48:	f9042783          	lw	a5,-112(s0)
   10c4c:	0007861b          	sext.w	a2,a5
   10c50:	0005869b          	sext.w	a3,a1
   10c54:	00d65463          	bge	a2,a3,10c5c <vprintfmt+0x428>
   10c58:	00058793          	mv	a5,a1
   10c5c:	0007879b          	sext.w	a5,a5
   10c60:	40f707bb          	subw	a5,a4,a5
   10c64:	fcf42c23          	sw	a5,-40(s0)
   10c68:	0280006f          	j	10c90 <vprintfmt+0x45c>
   10c6c:	f5843783          	ld	a5,-168(s0)
   10c70:	02000513          	li	a0,32
   10c74:	000780e7          	jalr	a5
   10c78:	fec42783          	lw	a5,-20(s0)
   10c7c:	0017879b          	addiw	a5,a5,1
   10c80:	fef42623          	sw	a5,-20(s0)
   10c84:	fd842783          	lw	a5,-40(s0)
   10c88:	fff7879b          	addiw	a5,a5,-1
   10c8c:	fcf42c23          	sw	a5,-40(s0)
   10c90:	fd842783          	lw	a5,-40(s0)
   10c94:	0007879b          	sext.w	a5,a5
   10c98:	fcf04ae3          	bgtz	a5,10c6c <vprintfmt+0x438>
   10c9c:	fa644783          	lbu	a5,-90(s0)
   10ca0:	0ff7f793          	andi	a5,a5,255
   10ca4:	04078463          	beqz	a5,10cec <vprintfmt+0x4b8>
   10ca8:	f5843783          	ld	a5,-168(s0)
   10cac:	03000513          	li	a0,48
   10cb0:	000780e7          	jalr	a5
   10cb4:	f5043783          	ld	a5,-176(s0)
   10cb8:	0007c783          	lbu	a5,0(a5)
   10cbc:	00078713          	mv	a4,a5
   10cc0:	05800793          	li	a5,88
   10cc4:	00f71663          	bne	a4,a5,10cd0 <vprintfmt+0x49c>
   10cc8:	05800793          	li	a5,88
   10ccc:	0080006f          	j	10cd4 <vprintfmt+0x4a0>
   10cd0:	07800793          	li	a5,120
   10cd4:	f5843703          	ld	a4,-168(s0)
   10cd8:	00078513          	mv	a0,a5
   10cdc:	000700e7          	jalr	a4
   10ce0:	fec42783          	lw	a5,-20(s0)
   10ce4:	0027879b          	addiw	a5,a5,2
   10ce8:	fef42623          	sw	a5,-20(s0)
   10cec:	fdc42783          	lw	a5,-36(s0)
   10cf0:	fcf42a23          	sw	a5,-44(s0)
   10cf4:	0280006f          	j	10d1c <vprintfmt+0x4e8>
   10cf8:	f5843783          	ld	a5,-168(s0)
   10cfc:	03000513          	li	a0,48
   10d00:	000780e7          	jalr	a5
   10d04:	fec42783          	lw	a5,-20(s0)
   10d08:	0017879b          	addiw	a5,a5,1
   10d0c:	fef42623          	sw	a5,-20(s0)
   10d10:	fd442783          	lw	a5,-44(s0)
   10d14:	0017879b          	addiw	a5,a5,1
   10d18:	fcf42a23          	sw	a5,-44(s0)
   10d1c:	f8c42703          	lw	a4,-116(s0)
   10d20:	fd442783          	lw	a5,-44(s0)
   10d24:	0007879b          	sext.w	a5,a5
   10d28:	fce7c8e3          	blt	a5,a4,10cf8 <vprintfmt+0x4c4>
   10d2c:	fdc42783          	lw	a5,-36(s0)
   10d30:	fff7879b          	addiw	a5,a5,-1
   10d34:	fcf42823          	sw	a5,-48(s0)
   10d38:	03c0006f          	j	10d74 <vprintfmt+0x540>
   10d3c:	fd042783          	lw	a5,-48(s0)
   10d40:	ff040713          	addi	a4,s0,-16
   10d44:	00f707b3          	add	a5,a4,a5
   10d48:	f807c783          	lbu	a5,-128(a5)
   10d4c:	0007879b          	sext.w	a5,a5
   10d50:	f5843703          	ld	a4,-168(s0)
   10d54:	00078513          	mv	a0,a5
   10d58:	000700e7          	jalr	a4
   10d5c:	fec42783          	lw	a5,-20(s0)
   10d60:	0017879b          	addiw	a5,a5,1
   10d64:	fef42623          	sw	a5,-20(s0)
   10d68:	fd042783          	lw	a5,-48(s0)
   10d6c:	fff7879b          	addiw	a5,a5,-1
   10d70:	fcf42823          	sw	a5,-48(s0)
   10d74:	fd042783          	lw	a5,-48(s0)
   10d78:	0007879b          	sext.w	a5,a5
   10d7c:	fc07d0e3          	bgez	a5,10d3c <vprintfmt+0x508>
   10d80:	f8040023          	sb	zero,-128(s0)
   10d84:	2800006f          	j	11004 <vprintfmt+0x7d0>
   10d88:	f5043783          	ld	a5,-176(s0)
   10d8c:	0007c783          	lbu	a5,0(a5)
   10d90:	00078713          	mv	a4,a5
   10d94:	06400793          	li	a5,100
   10d98:	02f70663          	beq	a4,a5,10dc4 <vprintfmt+0x590>
   10d9c:	f5043783          	ld	a5,-176(s0)
   10da0:	0007c783          	lbu	a5,0(a5)
   10da4:	00078713          	mv	a4,a5
   10da8:	06900793          	li	a5,105
   10dac:	00f70c63          	beq	a4,a5,10dc4 <vprintfmt+0x590>
   10db0:	f5043783          	ld	a5,-176(s0)
   10db4:	0007c783          	lbu	a5,0(a5)
   10db8:	00078713          	mv	a4,a5
   10dbc:	07500793          	li	a5,117
   10dc0:	08f71463          	bne	a4,a5,10e48 <vprintfmt+0x614>
   10dc4:	f8144783          	lbu	a5,-127(s0)
   10dc8:	00078c63          	beqz	a5,10de0 <vprintfmt+0x5ac>
   10dcc:	f4843783          	ld	a5,-184(s0)
   10dd0:	00878713          	addi	a4,a5,8
   10dd4:	f4e43423          	sd	a4,-184(s0)
   10dd8:	0007b783          	ld	a5,0(a5)
   10ddc:	0140006f          	j	10df0 <vprintfmt+0x5bc>
   10de0:	f4843783          	ld	a5,-184(s0)
   10de4:	00878713          	addi	a4,a5,8
   10de8:	f4e43423          	sd	a4,-184(s0)
   10dec:	0007a783          	lw	a5,0(a5)
   10df0:	faf43423          	sd	a5,-88(s0)
   10df4:	fa843583          	ld	a1,-88(s0)
   10df8:	f5043783          	ld	a5,-176(s0)
   10dfc:	0007c783          	lbu	a5,0(a5)
   10e00:	0007871b          	sext.w	a4,a5
   10e04:	07500793          	li	a5,117
   10e08:	40f707b3          	sub	a5,a4,a5
   10e0c:	00f037b3          	snez	a5,a5
   10e10:	0ff7f793          	andi	a5,a5,255
   10e14:	f8040713          	addi	a4,s0,-128
   10e18:	00070693          	mv	a3,a4
   10e1c:	00078613          	mv	a2,a5
   10e20:	f5843503          	ld	a0,-168(s0)
   10e24:	fffff097          	auipc	ra,0xfffff
   10e28:	70c080e7          	jalr	1804(ra) # 10530 <print_dec_int>
   10e2c:	00050793          	mv	a5,a0
   10e30:	00078713          	mv	a4,a5
   10e34:	fec42783          	lw	a5,-20(s0)
   10e38:	00e787bb          	addw	a5,a5,a4
   10e3c:	fef42623          	sw	a5,-20(s0)
   10e40:	f8040023          	sb	zero,-128(s0)
   10e44:	1c00006f          	j	11004 <vprintfmt+0x7d0>
   10e48:	f5043783          	ld	a5,-176(s0)
   10e4c:	0007c783          	lbu	a5,0(a5)
   10e50:	00078713          	mv	a4,a5
   10e54:	06e00793          	li	a5,110
   10e58:	04f71c63          	bne	a4,a5,10eb0 <vprintfmt+0x67c>
   10e5c:	f8144783          	lbu	a5,-127(s0)
   10e60:	02078463          	beqz	a5,10e88 <vprintfmt+0x654>
   10e64:	f4843783          	ld	a5,-184(s0)
   10e68:	00878713          	addi	a4,a5,8
   10e6c:	f4e43423          	sd	a4,-184(s0)
   10e70:	0007b783          	ld	a5,0(a5)
   10e74:	faf43823          	sd	a5,-80(s0)
   10e78:	fec42703          	lw	a4,-20(s0)
   10e7c:	fb043783          	ld	a5,-80(s0)
   10e80:	00e7b023          	sd	a4,0(a5)
   10e84:	0240006f          	j	10ea8 <vprintfmt+0x674>
   10e88:	f4843783          	ld	a5,-184(s0)
   10e8c:	00878713          	addi	a4,a5,8
   10e90:	f4e43423          	sd	a4,-184(s0)
   10e94:	0007b783          	ld	a5,0(a5)
   10e98:	faf43c23          	sd	a5,-72(s0)
   10e9c:	fb843783          	ld	a5,-72(s0)
   10ea0:	fec42703          	lw	a4,-20(s0)
   10ea4:	00e7a023          	sw	a4,0(a5)
   10ea8:	f8040023          	sb	zero,-128(s0)
   10eac:	1580006f          	j	11004 <vprintfmt+0x7d0>
   10eb0:	f5043783          	ld	a5,-176(s0)
   10eb4:	0007c783          	lbu	a5,0(a5)
   10eb8:	00078713          	mv	a4,a5
   10ebc:	07300793          	li	a5,115
   10ec0:	04f71263          	bne	a4,a5,10f04 <vprintfmt+0x6d0>
   10ec4:	f4843783          	ld	a5,-184(s0)
   10ec8:	00878713          	addi	a4,a5,8
   10ecc:	f4e43423          	sd	a4,-184(s0)
   10ed0:	0007b783          	ld	a5,0(a5)
   10ed4:	fcf43023          	sd	a5,-64(s0)
   10ed8:	fc043583          	ld	a1,-64(s0)
   10edc:	f5843503          	ld	a0,-168(s0)
   10ee0:	fffff097          	auipc	ra,0xfffff
   10ee4:	5c8080e7          	jalr	1480(ra) # 104a8 <puts_wo_nl>
   10ee8:	00050793          	mv	a5,a0
   10eec:	00078713          	mv	a4,a5
   10ef0:	fec42783          	lw	a5,-20(s0)
   10ef4:	00e787bb          	addw	a5,a5,a4
   10ef8:	fef42623          	sw	a5,-20(s0)
   10efc:	f8040023          	sb	zero,-128(s0)
   10f00:	1040006f          	j	11004 <vprintfmt+0x7d0>
   10f04:	f5043783          	ld	a5,-176(s0)
   10f08:	0007c783          	lbu	a5,0(a5)
   10f0c:	00078713          	mv	a4,a5
   10f10:	06300793          	li	a5,99
   10f14:	02f71e63          	bne	a4,a5,10f50 <vprintfmt+0x71c>
   10f18:	f4843783          	ld	a5,-184(s0)
   10f1c:	00878713          	addi	a4,a5,8
   10f20:	f4e43423          	sd	a4,-184(s0)
   10f24:	0007a783          	lw	a5,0(a5)
   10f28:	fcf42623          	sw	a5,-52(s0)
   10f2c:	fcc42783          	lw	a5,-52(s0)
   10f30:	f5843703          	ld	a4,-168(s0)
   10f34:	00078513          	mv	a0,a5
   10f38:	000700e7          	jalr	a4
   10f3c:	fec42783          	lw	a5,-20(s0)
   10f40:	0017879b          	addiw	a5,a5,1
   10f44:	fef42623          	sw	a5,-20(s0)
   10f48:	f8040023          	sb	zero,-128(s0)
   10f4c:	0b80006f          	j	11004 <vprintfmt+0x7d0>
   10f50:	f5043783          	ld	a5,-176(s0)
   10f54:	0007c783          	lbu	a5,0(a5)
   10f58:	00078713          	mv	a4,a5
   10f5c:	02500793          	li	a5,37
   10f60:	02f71263          	bne	a4,a5,10f84 <vprintfmt+0x750>
   10f64:	f5843783          	ld	a5,-168(s0)
   10f68:	02500513          	li	a0,37
   10f6c:	000780e7          	jalr	a5
   10f70:	fec42783          	lw	a5,-20(s0)
   10f74:	0017879b          	addiw	a5,a5,1
   10f78:	fef42623          	sw	a5,-20(s0)
   10f7c:	f8040023          	sb	zero,-128(s0)
   10f80:	0840006f          	j	11004 <vprintfmt+0x7d0>
   10f84:	f5043783          	ld	a5,-176(s0)
   10f88:	0007c783          	lbu	a5,0(a5)
   10f8c:	0007879b          	sext.w	a5,a5
   10f90:	f5843703          	ld	a4,-168(s0)
   10f94:	00078513          	mv	a0,a5
   10f98:	000700e7          	jalr	a4
   10f9c:	fec42783          	lw	a5,-20(s0)
   10fa0:	0017879b          	addiw	a5,a5,1
   10fa4:	fef42623          	sw	a5,-20(s0)
   10fa8:	f8040023          	sb	zero,-128(s0)
   10fac:	0580006f          	j	11004 <vprintfmt+0x7d0>
   10fb0:	f5043783          	ld	a5,-176(s0)
   10fb4:	0007c783          	lbu	a5,0(a5)
   10fb8:	00078713          	mv	a4,a5
   10fbc:	02500793          	li	a5,37
   10fc0:	02f71063          	bne	a4,a5,10fe0 <vprintfmt+0x7ac>
   10fc4:	f8043023          	sd	zero,-128(s0)
   10fc8:	f8043423          	sd	zero,-120(s0)
   10fcc:	00100793          	li	a5,1
   10fd0:	f8f40023          	sb	a5,-128(s0)
   10fd4:	fff00793          	li	a5,-1
   10fd8:	f8f42623          	sw	a5,-116(s0)
   10fdc:	0280006f          	j	11004 <vprintfmt+0x7d0>
   10fe0:	f5043783          	ld	a5,-176(s0)
   10fe4:	0007c783          	lbu	a5,0(a5)
   10fe8:	0007879b          	sext.w	a5,a5
   10fec:	f5843703          	ld	a4,-168(s0)
   10ff0:	00078513          	mv	a0,a5
   10ff4:	000700e7          	jalr	a4
   10ff8:	fec42783          	lw	a5,-20(s0)
   10ffc:	0017879b          	addiw	a5,a5,1
   11000:	fef42623          	sw	a5,-20(s0)
   11004:	f5043783          	ld	a5,-176(s0)
   11008:	00178793          	addi	a5,a5,1
   1100c:	f4f43823          	sd	a5,-176(s0)
   11010:	f5043783          	ld	a5,-176(s0)
   11014:	0007c783          	lbu	a5,0(a5)
   11018:	840794e3          	bnez	a5,10860 <vprintfmt+0x2c>
   1101c:	fec42783          	lw	a5,-20(s0)
   11020:	00078513          	mv	a0,a5
   11024:	0b813083          	ld	ra,184(sp)
   11028:	0b013403          	ld	s0,176(sp)
   1102c:	0c010113          	addi	sp,sp,192
   11030:	00008067          	ret

0000000000011034 <printf>:
   11034:	f8010113          	addi	sp,sp,-128
   11038:	02113c23          	sd	ra,56(sp)
   1103c:	02813823          	sd	s0,48(sp)
   11040:	04010413          	addi	s0,sp,64
   11044:	fca43423          	sd	a0,-56(s0)
   11048:	00b43423          	sd	a1,8(s0)
   1104c:	00c43823          	sd	a2,16(s0)
   11050:	00d43c23          	sd	a3,24(s0)
   11054:	02e43023          	sd	a4,32(s0)
   11058:	02f43423          	sd	a5,40(s0)
   1105c:	03043823          	sd	a6,48(s0)
   11060:	03143c23          	sd	a7,56(s0)
   11064:	fe042623          	sw	zero,-20(s0)
   11068:	04040793          	addi	a5,s0,64
   1106c:	fcf43023          	sd	a5,-64(s0)
   11070:	fc043783          	ld	a5,-64(s0)
   11074:	fc878793          	addi	a5,a5,-56
   11078:	fcf43823          	sd	a5,-48(s0)
   1107c:	fd043783          	ld	a5,-48(s0)
   11080:	00078613          	mv	a2,a5
   11084:	fc843583          	ld	a1,-56(s0)
   11088:	fffff517          	auipc	a0,0xfffff
   1108c:	0ec50513          	addi	a0,a0,236 # 10174 <putc>
   11090:	fffff097          	auipc	ra,0xfffff
   11094:	7a4080e7          	jalr	1956(ra) # 10834 <vprintfmt>
   11098:	00050793          	mv	a5,a0
   1109c:	fef42623          	sw	a5,-20(s0)
   110a0:	00100793          	li	a5,1
   110a4:	fef43023          	sd	a5,-32(s0)
   110a8:	00001797          	auipc	a5,0x1
   110ac:	11c78793          	addi	a5,a5,284 # 121c4 <tail>
   110b0:	0007a783          	lw	a5,0(a5)
   110b4:	0017871b          	addiw	a4,a5,1
   110b8:	0007069b          	sext.w	a3,a4
   110bc:	00001717          	auipc	a4,0x1
   110c0:	10870713          	addi	a4,a4,264 # 121c4 <tail>
   110c4:	00d72023          	sw	a3,0(a4)
   110c8:	00001717          	auipc	a4,0x1
   110cc:	10070713          	addi	a4,a4,256 # 121c8 <buffer>
   110d0:	00f707b3          	add	a5,a4,a5
   110d4:	00078023          	sb	zero,0(a5)
   110d8:	00001797          	auipc	a5,0x1
   110dc:	0ec78793          	addi	a5,a5,236 # 121c4 <tail>
   110e0:	0007a603          	lw	a2,0(a5)
   110e4:	fe043703          	ld	a4,-32(s0)
   110e8:	00001697          	auipc	a3,0x1
   110ec:	0e068693          	addi	a3,a3,224 # 121c8 <buffer>
   110f0:	fd843783          	ld	a5,-40(s0)
   110f4:	04000893          	li	a7,64
   110f8:	00070513          	mv	a0,a4
   110fc:	00068593          	mv	a1,a3
   11100:	00060613          	mv	a2,a2
   11104:	00000073          	ecall
   11108:	00050793          	mv	a5,a0
   1110c:	fcf43c23          	sd	a5,-40(s0)
   11110:	00001797          	auipc	a5,0x1
   11114:	0b478793          	addi	a5,a5,180 # 121c4 <tail>
   11118:	0007a023          	sw	zero,0(a5)
   1111c:	fec42783          	lw	a5,-20(s0)
   11120:	00078513          	mv	a0,a5
   11124:	03813083          	ld	ra,56(sp)
   11128:	03013403          	ld	s0,48(sp)
   1112c:	08010113          	addi	sp,sp,128
   11130:	00008067          	ret
