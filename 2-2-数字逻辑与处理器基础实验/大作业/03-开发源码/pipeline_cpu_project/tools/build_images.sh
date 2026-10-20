#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$ROOT_DIR/tools/assemble_mips.py" \
  "$ROOT_DIR/asm/amplifier_fpga.asm" \
  "$ROOT_DIR/asm/amplifier_program.hex"
python3 "$ROOT_DIR/tools/generate_data_image.py" \
  "$ROOT_DIR/data/amplifier_data.hex"
