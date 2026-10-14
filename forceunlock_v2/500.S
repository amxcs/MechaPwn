/* Force unlock v2, MechaCon 5.00 (CXR706080-101GG, 2003/01/20 15:28) */

    .equ LOAD,        0x02002C30   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x80
    .equ LATCH_TABLE, 0x02001824
    .equ DVD_TYPING,  0x04D2A
    .equ CD_EPILOGUE, 0x0B752
    .equ SWI_EXIT,    0x33544

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00000000
    .word 0x0000B670
    .word 0x00004D70
    .word 0x0000B694
    .word 0x00000000   /* unused */
    .word 0xDF0070D8   /* strb r0, [r3, #3] ; svc #0    CD site 1 */
    .word 0x46C0DF00   /* svc #0 ; nop                   DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu600.inc"
