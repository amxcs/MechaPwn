/* Force unlock v2, MechaCon 6.10 (CXR716080-106GG, 2006/03/29 06:48) */

    .equ LOAD,        0x02002E54   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x20
    .equ LATCH_TABLE, 0x020018E8
    .equ DVD_TYPING,  0x04E4A
    .equ CD_EPILOGUE, 0x0BB2E
    .equ SWI_EXIT,    0x369A8

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x0001B4C0
    .word 0x0000BA10
    .word 0x00004EF0
    .word 0x0000BA30
    .word 0x20017208   /* factory slot, as in forceunlock610 */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00E   /* beq 0x4F10 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu610.inc"
