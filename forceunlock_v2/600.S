/* Force unlock v2, MechaCon 6.00 (CXR716080-101GG, 2004/06/21 09:53) */

    .equ LOAD,        0x02002E2C   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x20
    .equ LATCH_TABLE, 0x02001890
    .equ DVD_TYPING,  0x04E3C
    .equ CD_EPILOGUE, 0x0B51E
    .equ SWI_EXIT,    0x355F4

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00025678
    .word 0x0000B414
    .word 0x00004E80
    .word 0x0000B434
    .word 0x30002082   /* factory slot, as in forceunlock600 */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00F   /* beq 0x4EA2 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu600.inc"
