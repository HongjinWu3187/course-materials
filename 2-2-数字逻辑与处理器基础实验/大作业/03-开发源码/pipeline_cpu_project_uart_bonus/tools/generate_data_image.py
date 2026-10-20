#!/usr/bin/env python3
"""Generate the RAM initialization image for the UART-input amplifier program."""

from __future__ import annotations

import argparse
from pathlib import Path


RAM_WORDS = 4096
LUT_WORD = 0x1A00 // 4


# bit 0..6 map to a..g and bit 7 is dp. The CPU program ORs in AN[3:0].
SEVEN_SEG_HEX = [
    0x3F, 0x06, 0x5B, 0x4F,
    0x66, 0x6D, 0x7D, 0x07,
    0x7F, 0x6F, 0x77, 0x7C,
    0x39, 0x5E, 0x79, 0x71,
]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    words = [0] * RAM_WORDS
    for idx, value in enumerate(SEVEN_SEG_HEX):
        words[LUT_WORD + idx] = value

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(f"{word:08x}\n" for word in words), encoding="ascii")
    print(f"generated {RAM_WORDS} RAM words -> {args.output}")


if __name__ == "__main__":
    main()
