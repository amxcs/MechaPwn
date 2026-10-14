/* Force unlock v2, MechaCon 6.06 (CXR716080-104GG, 2005/04/27 09:17) */

    .equ LOAD,        0x02002E54   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x40
    .equ LATCH_TABLE, 0x020018E8
    .equ DVD_TYPING,  0x04E26
    .equ CD_EPILOGUE, 0x0BACA
    .equ SWI_EXIT,    0x36934

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00000000
    .word 0x0000B9AC
    .word 0x00004ECC
    .word 0x0000B9CC
    .word 0x00000000   /* unused */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00E   /* beq 0x4EEC ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu610.inc"
