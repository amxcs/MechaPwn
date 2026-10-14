/*
 * Force unlock v2, MechaCon 5.04 (CXR706080-103GG, 2003/04/08 23:27)
 *
 * The factory patch needs its slot and part of the body, so this body is
 * laid out like 602.S: one ARM stub stores the return address in the saved
 * r3 and leaves through the ROM's SWI exit to `common`, in the caller's
 * mode. The sites are told apart by the return address:
 *
 *   0x2854A  bit 17 set   factory fix
 *   0x04F28  bit 14 set   DVD
 *   0x0B926  both clear   CD
 */
    .equ LOAD,        0x02002C40   /* patch block; svc table at LOAD + 0x20 */
    .equ LATCH_TABLE, 0x02001828
    .equ SWI_EXIT,    0x33BFC      /* pop {r0-r12} ; movs pc, lr */

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
patch_block:
    .word 0x00028548
    .word 0x00004F24
    .word 0x0000B874
    .word 0x0000B924
    .word 0x2000DF00   /* svc #0 ; movs r0, #0            factory fix */
    .word 0xDF00D00E   /* beq 0x4F44 ; svc #0            DVD */
    .word 0x90092000   /* movs r0, #0 ; str r0, [sp, #0x24]  CD reads LBA 0, not 14 */
    .word 0xA800DF00   /* svc #0 ; add r0, sp, #0        CD */
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
    lsrs r2, r3, #18              /* C = bit 17 */
    bcs  fac
    lsls r2, r3, #18              /* C = bit 14 */
    bcs  dvd

/*
 * CD: the ROM has read 28 bytes of LBA 0 into sp+0..27 and compared a
 * signature. OR sp+0..15:
 *   not zero -> r7 = 1  PS2 CD
 *   zero     -> r7 = 0  not PS2
 * Then the latch, and back to the ROM at the CD function's epilogue.
 */
    mov  r1, sp
    ldmia r1!, {r0, r2, r4, r7}
    orrs r0, r2
    orrs r0, r4
    orrs r0, r7
    negs r1, r0                   /* C = (r0 == 0) */
    sbcs r7, r7                   /* 0 or -1 */
    negs r7, r7
    adds r3, #89                  /* 0x0B97E: adds r0, r7, #0 ; epilogue */
    mov  lr, r3
    b    latch

/* DVD: the UDF detector answered neither DVD-Video nor DVD-VR. */
dvd:
    subs r3, #71                  /* 0x04EE0: type as PS2 DVD */
    mov  lr, r3
    b    latch

/*
 * Factory fix, 0x2854A, as in the stock 5.04 patch: copy the byte at
 * 0x02002C1C to 0x02000446 and branch on its bit 4.
 */
fac:
    ldr  r0, =0x02002c1c
    ldrb r0, [r0]
    ldr  r1, =0x02000446
    strb r0, [r1]
    lsrs r0, r0, #5               /* C = bit 4 */
    bcs  1f
    adds r3, #10                  /* bit 4 clear: 0x28555 */
1:  adds r3, #1                   /* bit 4 set:   0x2854B */
    bx   r3

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
table_lit:
    .word LATCH_TABLE
    .ltorg
