/*
 * Force unlock v2, MechaCon 6.02 (CXR716080-102GG, 2004/07/20 09:04)
 *
 * 6.02 needs its factory DSP fix, which takes one slot and part of the body,
 * so this body is laid out differently from fu610.inc / fu600.inc.
 *
 * One ARM stub serves all three `svc #0` sites. It stores the return address
 * in the saved r3 and leaves through the ROM's SWI exit to `common`, in the
 * caller's mode, with every other register as the caller had it. The sites
 * are told apart by bits 14 and 13 of the return address:
 *
 *   0x792C  1, 1   factory DSP fix
 *   0x4BD8  1, 0   DVD: master check failed
 *   0xB684  0, 1   CD: after the ROM's read of LBA 0
 */
    .equ LOAD,        0x02002E34   /* patch block; svc table at LOAD + 0x20 */
    .equ LATCH_TABLE, 0x02001898
    .equ SWI_EXIT,    0x35ADC      /* pop {r0-r12} ; movs pc, lr */
    .equ UDF_DETECT,  0x0AA3C      /* DVD-Video / DVD-VR detector (Thumb) */

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
patch_block:
    .word 0x00007928
    .word 0x00004BD4
    .word 0x0000B570
    .word 0x0000B680
    .word 0xDF004671   /* mov r1, lr ; svc #0              factory DSP fix */
    .word 0xDF00E045   /* b 0x4C62 ; svc #0                DVD */
    .word 0x90092000   /* movs r0, #0 ; str r0, [sp, #0x24]  CD reads LBA 0, not 14 */
    .word 0xDF002700   /* movs r7, #0 ; svc #0             CD */

    .global body_start
body_start:
    .word stub                    /* svc table[0] */

    .arm
stub:
    str   lr, [sp, #12]           /* saved r3 = return address */
    adr   lr, common + 1
    b     patch_block + (SWI_EXIT - LOAD)  /* SWI_EXIT, relative to the block */

    .thumb
    .thumb_func
common:
    lsls r2, r3, #18              /* C = bit 14, N = bit 13 */
    bcc  cd
    bpl  dvd

/*
 * Factory DSP fix, 0x792C. r1 = caller's lr. If lr - 0x20000 is a key in
 * `fixes`, add its value << 8 to r4. Then r5 = 64, r1 = 0, return.
 */
    movs r2, #2
    lsls r2, #16
    subs r1, r1, r2
    adr  r2, fixes
1:  ldrh r0, [r2]
    lsrs r5, r0, #1               /* keys are odd; an even halfword ends the table */
    bcc  3f
    cmp  r0, r1
    beq  2f
    adds r2, #4
    b    1b
2:  ldrh r0, [r2, #2]
    lsls r0, #8
    adds r4, r4, r0
3:  movs r5, #64
    movs r1, #0
    adds r3, #1
bx_r3:
    bx   r3

/*
 * DVD, 0x4BD8: the master check failed. Ask the UDF detector: DVD-Video (0)
 * and DVD-VR (1) resume the ROM at 0x4BDC; anything else gets the latch and
 * is typed as PS2 DVD at 0x4B9E.
 */
dvd:
    movs r7, #0
    push {r3}
    ldr  r3, =UDF_DETECT + 1
    bl   bx_r3
    pop  {r3}
    cmp  r0, #1
    bls  4f
    subs r3, #0x39                /* 0x4B9F */
    mov  lr, r3
    b    latch
4:  adds r3, #5                   /* 0x4BDD */
    bx   r3

/*
 * CD, 0xB684: the ROM has read 28 bytes of LBA 0 into sp+0..27 and its
 * signature compare failed. OR sp+0..15:
 *   not zero -> r7 = 0  PS2 CD
 *   zero     -> r7 = 1  not PS2
 * Then the latch, and back to the ROM at 0xB68E.
 */
cd:
    mov  r1, sp
    ldmia r1!, {r0, r2, r4, r7}
    orrs r0, r2
    orrs r0, r4
    orrs r0, r7
    negs r1, r0                   /* C = (r0 == 0) */
    movs r7, #0
    adcs r7, r7
    adds r3, #0xb                 /* 0xB68F */
    mov  lr, r3
    b    latch

/*
 * Latch: if words 1..127 of the disc key table are zero, write records 1
 * and 2 as a master disc leaves them, so sceCdReadKey succeeds on a disc
 * without a master descriptor. Preserves r3, r4, r5.
 */
latch:
    push {r4, r5, lr}
    ldr  r1, table_lit
    movs r2, #127
    lsls r2, #2
5:  ldr  r0, [r1, r2]
    cmp  r0, #0
    bne  9f
    subs r2, #4
    bne  5b
    adds r1, #16
    movs r0, #0x4b                /* 0000004B 0000104A 399169B3 000001ED */
    movs r2, #0x82
    lsls r2, #5
    adds r2, #10
    ldr  r4, =0x399169b3
    movs r5, #0xf6
    lsls r5, #1
    adds r5, #1
    stmia r1!, {r0, r2, r4, r5}
    movs r4, #0                   /* 0000004B 0000104A 00000000 0000034C */
    movs r5, #0xd3
    lsls r5, #2
    stmia r1!, {r0, r2, r4, r5}
9:  pop  {r4, r5, pc}

    .balign 4
fixes:                            /* caller - 0x20000, value */
    .hword 0x4851, 0x1100
    .hword 0x855d, 0x003d
    .hword 0x8bcd, 0x0900
    .hword 0x8d29, 0x003d
table_lit:
    .word LATCH_TABLE             /* even low half: also ends `fixes` */
    .ltorg
