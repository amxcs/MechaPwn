# Force unlock v2

Sources of the NVRAM patches behind "Install force unlock v2". The menu entry
writes them exactly like "Install force unlock" (words 400..511); backup and
restore are unchanged.

## What it does

The original force unlock makes the MechaCon's master disc and CD checks pass
for every disc. v2 keeps each ROM's own detection and only changes the cases
it gets wrong for burnt discs:

- **CD:** read LBA 0 and call it a PS2 CD if any byte is non-zero (the PS2
  logo), otherwise not PS2. PS1 discs keep LBA 0 blank.
- **DVD:** the ROM's UDF / VIDEO_TS detector runs first, so DVD-Video and
  DVD-VR stay video. Only a disc it does not recognise is typed as PS2 DVD.
- **Disc key latch:** a burnt disc without a master descriptor leaves the
  disc key table empty and `sceCdReadKey` fails. When words 1..127 of the
  table are zero, the patch writes the two records a master disc leaves.
  The table is RAM; nothing persists across power off.
- The factory patch slot is kept where the ROM has one (5.04, 5.12, 6.00,
  6.02, 6.04, 6.10).

## Files

| File | MechaCon |
|---|---|
| `fu600.inc` | body for 5.00, 5.02, 5.06, 5.06MX, 6.00 |
| `fu610.inc` | body for 6.04, 6.06, 6.10, 6.12 |
| `<version>.S` | slots and ROM addresses; 5.04, 5.12 and 6.02 carry their own body |
| `build.py` | assembles, encrypts, writes `forceunlock_v2.h` |
| `forceunlock_v2.h` | generated; included by `exploit.c` |

Each `.S` assembles to the 216-byte plaintext block: 4 slot addresses,
4 slot values, then the body at `LOAD + 0x20`, which starts with svc table[0].

## Build

```sh
MECHA_PATCH_KEY=<16 hex digits> python3 forceunlock_v2/build.py           # arm-none-eabi-*
MECHA_PATCH_KEY=<16 hex digits> python3 forceunlock_v2/build.py --clang   # clang + ld.lld
MECHA_PATCH_KEY=<16 hex digits> python3 forceunlock_v2/build.py --check   # compare only
```

Needs pycryptodome. The MechaPwn build itself does not need any of this; it
uses the committed `forceunlock_v2.h`.

## Tested

| MechaCon | Status |
|---|---|
| 6.00, 6.02, 6.06, 6.10, 6.12 | tested on a console |
| 5.00, 5.02, 5.04, 5.06, 5.06MX, 5.12, 6.04 | not tested on a console; replayed against the ROM only |

On the tested consoles PS1, PS2 CD/DVD and DVD-Video discs are read. Burnt
PS2 discs start from a disc loader, not from the Browser.

5.10 and 5.14 have no v2 patch.
