/* Force unlock v2, MechaCon 5.02 (CXR706080-102GG, 2003/03/05 22:40) */

    .equ LOAD,        0x02002C3C   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x80
    .equ LATCH_TABLE, 0x02001824
    .equ DVD_TYPING,  0x04ECC
    .equ CD_EPILOGUE, 0x0B96A
    .equ SWI_EXIT,    0x33A10

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00000000
    .word 0x0000B860
    .word 0x00004F10
    .word 0x0000B880
    .word 0x00000000   /* unused */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00E   /* beq 0x4F30 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu600.inc"
