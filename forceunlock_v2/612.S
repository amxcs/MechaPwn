/* Force unlock v2, MechaCon 6.12 (CXR726080-301GB, 2007/01/29 03:47) */

    .equ LOAD,        0x02002F28   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x40
    .equ LATCH_TABLE, 0x020019BC
    .equ DVD_TYPING,  0x04E22
    .equ CD_EPILOGUE, 0x0BABE
    .equ SWI_EXIT,    0x377A8

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00000000
    .word 0x0000B9A0
    .word 0x00004EC8
    .word 0x0000B9C0
    .word 0x00000000   /* unused */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00E   /* beq 0x4EE8 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu610.inc"
