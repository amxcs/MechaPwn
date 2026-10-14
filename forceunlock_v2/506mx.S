/* Force unlock v2, MechaCon 5.06MX (CXR706080-106GG, 2004/04/06 13:05) */

    .equ LOAD,        0x02002C40   /* patch block; svc table at LOAD + 0x20 */
    .equ CD2_LR_BIT,  0x20
    .equ LATCH_TABLE, 0x02001828
    .equ DVD_TYPING,  0x04DFC
    .equ CD_EPILOGUE, 0x0B952
    .equ SWI_EXIT,    0x33C18

    .syntax unified
    .cpu arm7tdmi
    .text

/* ROM patch slots: four addresses, then four values */
    .word 0x00000000
    .word 0x0000B848
    .word 0x00004E40
    .word 0x0000B868
    .word 0x00000000   /* unused */
    .word 0x9009DF00   /* svc #0 ; str r0, [sp, #0x24]  CD site 1 */
    .word 0xDF00D00F   /* beq 0x4E62 ; svc #0            DVD site */
    .word 0x46C0DF00   /* svc #0 ; nop                   CD site 2 */

    .include "fu600.inc"
