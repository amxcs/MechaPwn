/* Force unlock v2, MechaCon 6.04 (CXR716080-103GG, 2004/12/10 01:30) */

    .equ LOAD,        0x02002E50   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x80
    .equ LATCH_TABLE, 0x020018E4
    .equ DVD_TYPING,  0x04E12
    .equ CD_EPILOGUE, 0x0B986
    .equ SWI_EXIT,    0x365A8

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00022634
    .word 0x0000B868
    .word 0x00004EB8
    .word 0x0000B888
    .word 0x9B109000   /* factory slot, as in forceunlock604 */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00E   /* beq 0x4ED8 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu610.inc"
