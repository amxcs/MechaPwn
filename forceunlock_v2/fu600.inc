/*
 * Force unlock v2 body for the 5.00 / 5.02 / 5.06 / 5.06MX / 6.00 ROM family.
 *
 * Same hooks and latch as fu610.inc. Two differences in this family:
 *  - the DVD path is inline in the caller, so there is no frame to drop;
 *  - the CD function returns 1 for a PS2 CD and 0 otherwise, read errors
 *    included, so the classifier uses that polarity.
 *
 * Parameters (.equ, set by the including file):
 *   CD2_LR_BIT    lr bit that is set after CD site 2 and clear after CD site 1
 *   LATCH_TABLE   512-byte disc key table that sceCdReadKey answers from
 *   DVD_TYPING    ROM code that types the disc as PS2 DVD (Thumb)
 *   CD_EPILOGUE   `adds r0, r7, #0` and epilogue of the CD function (Thumb)
 *   SWI_EXIT      exit of the ROM SWI handler: pop {r0-r12} ; movs pc, lr
 */
    .global body_start

body_start:
    .word svc_stub                /* svc table[0]; table[1..3] are unused */

    .arm
svc_stub:
    tst   lr, #0x4000
    adrne lr, dvd_resume + 1      /* DVD site */
    bne   to_latch
    tst   lr, #CD2_LR_BIT
    adrne lr, sector_resume + 1   /* CD site 2 */
    ldrne pc, svc_return
to_latch:                         /* CD site 1 and DVD site */
    adr   r3, latch + 1
    bx    r3

/* Latch, Thumb, SVC mode: see fu610.inc. */
    .thumb
    .thumb_func
latch:
    movs r0, #0
    str  r0, [sp]                 /* saved r0 = 0: CD site 1 requests LBA 0 */
    ldr  r1, =LATCH_TABLE
    movs r3, #127
    lsls r3, #2                   /* byte offset of word 127 */
latch_check:
    ldr  r0, [r1, r3]
    cmp  r0, #0
    bne  latch_done
    subs r3, #4
    bne  latch_check
    adds r1, #16                  /* record 1; r3 = 0 from here on */
    movs r0, #0x4b                /* 0000004B 0000104A 399169B3 000001ED */
    movs r2, #0x82
    lsls r2, #5
    adds r2, #10
    ldr  r4, =0x399169b3
    movs r5, #0xf6
    lsls r5, #1
    adds r5, #1
    stmia r1!, {r0, r2, r4, r5}
    movs r5, #0xd3                /* 0000004B 0000104A 00000000 0000034C */
    lsls r5, #2
    stmia r1!, {r0, r2, r3, r5}
latch_done:
    ldr  r3, svc_return
    bx   r3

/* DVD site, Thumb, caller's mode: type as PS2 DVD. */
    .thumb_func
dvd_resume:
    ldr  r3, =DVD_TYPING + 1
    bx   r3

/*
 * CD site 2, Thumb, caller's mode, after the ROM's LBA 0 request.
 * Read the raw sector from the DSP FIFO and OR all 2048 bytes:
 *   any byte non-zero -> r7 = 1  PS2 CD
 *   all zero, or the request failed -> r7 = 0
 */
    .thumb_func
sector_resume:
    movs r7, #0
    cmp  r0, #0
    bne  complete
    ldr  r0, [sp, #28]
    ldrb r0, [r0, #4]
    cmp  r0, #0
    bne  complete
    ldr  r1, =0x03600080          /* DSP: raw sector to the FIFO */
    strb r0, [r1, #5]
    strb r0, [r1, #8]
    movs r0, #24
    strb r0, [r1, #9]
    subs r1, #128
    movs r0, #2
    strb r0, [r1]
    adds r1, #52                  /* FIFO data at 0x03600034 / 0x03600035 */
    movs r4, #0
    movs r2, #1
    lsls r2, #10                  /* 1024 byte pairs */
pair:
    ldrb r0, [r1]
    orrs r4, r0
    ldrb r0, [r1, #1]
    orrs r4, r0
    subs r2, #1
    bne  pair
    cmp  r4, #0
    beq  complete
    movs r7, #1
complete:
    ldr  r3, =CD_EPILOGUE + 1
    bx   r3

    .balign 4
svc_return:
    .word SWI_EXIT
    .ltorg
