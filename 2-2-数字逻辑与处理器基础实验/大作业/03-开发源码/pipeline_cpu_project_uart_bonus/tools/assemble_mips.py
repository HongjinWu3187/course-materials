#!/usr/bin/env python3
"""Small MIPS32 assembler for this course project.

It intentionally supports only the real instructions used by
asm/amplifier_fpga.asm and by the pipeline CPU RTL. It emits one 32-bit
hex word per line for Verilog $readmemh.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


REGS = {
    "$zero": 0, "$0": 0,
    "$at": 1, "$1": 1,
    "$v0": 2, "$v1": 3,
    "$a0": 4, "$a1": 5, "$a2": 6, "$a3": 7,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11, "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15,
    "$s0": 16, "$s1": 17, "$s2": 18, "$s3": 19, "$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
    "$t8": 24, "$t9": 25,
    "$k0": 26, "$k1": 27,
    "$gp": 28, "$sp": 29, "$fp": 30, "$ra": 31,
}


def parse_int(text: str) -> int:
    return int(text, 0)


def imm16(value: int) -> int:
    if value < -32768 or value > 0xFFFF:
        raise ValueError(f"immediate out of 16-bit range: {value}")
    return value & 0xFFFF


def reg(text: str) -> int:
    key = text.lower()
    if key not in REGS:
        raise ValueError(f"unknown register {text}")
    return REGS[key]


def clean_line(line: str) -> str:
    return line.split("#", 1)[0].strip()


def tokenize(line: str) -> list[str]:
    line = line.replace(",", " ")
    line = line.replace("(", " ")
    line = line.replace(")", " ")
    return [part for part in line.split() if part]


def r_type(rs: int, rt: int, rd: int, shamt: int, funct: int) -> int:
    return (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct


def i_type(op: int, rs: int, rt: int, imm: int) -> int:
    return (op << 26) | (rs << 21) | (rt << 16) | imm16(imm)


def j_type(op: int, target_addr: int) -> int:
    return (op << 26) | ((target_addr >> 2) & 0x03FFFFFF)


class Assembler:
    def __init__(self, source: str) -> None:
        self.source = source.splitlines()
        self.labels: dict[str, int] = {}
        self.instructions: list[tuple[int, str, int]] = []

    def first_pass(self) -> None:
        pc = 0
        for line_no, raw in enumerate(self.source, 1):
            line = clean_line(raw)
            if not line or line.startswith("."):
                continue
            while ":" in line:
                label, rest = line.split(":", 1)
                label = label.strip()
                if not re.match(r"^[A-Za-z_.$][A-Za-z0-9_.$]*$", label):
                    raise ValueError(f"bad label at line {line_no}: {label}")
                self.labels[label] = pc
                line = rest.strip()
                if not line:
                    break
            if not line or line.startswith("."):
                continue
            self.instructions.append((pc, line, line_no))
            pc += 4

    def encode(self, pc: int, line: str) -> int:
        parts = tokenize(line)
        op = parts[0].lower()
        a = parts[1:]

        if op in {"add", "addu", "sub", "subu", "and", "or", "xor", "nor", "slt", "sltu"}:
            funct = {
                "add": 0x20, "addu": 0x21, "sub": 0x22, "subu": 0x23,
                "and": 0x24, "or": 0x25, "xor": 0x26, "nor": 0x27,
                "slt": 0x2A, "sltu": 0x2B,
            }[op]
            rd, rs, rt = map(reg, a)
            return r_type(rs, rt, rd, 0, funct)

        if op in {"sll", "srl", "sra"}:
            funct = {"sll": 0x00, "srl": 0x02, "sra": 0x03}[op]
            rd = reg(a[0])
            rt = reg(a[1])
            shamt = parse_int(a[2]) & 0x1F
            return r_type(0, rt, rd, shamt, funct)

        if op == "jr":
            return r_type(reg(a[0]), 0, 0, 0, 0x08)

        if op == "jalr":
            if len(a) == 1:
                rd, rs = 31, reg(a[0])
            else:
                rd, rs = reg(a[0]), reg(a[1])
            return r_type(rs, 0, rd, 0, 0x09)

        if op == "mul":
            rd, rs, rt = map(reg, a)
            return (0x1C << 26) | (rs << 21) | (rt << 16) | (rd << 11) | 0x02

        if op in {"addi", "addiu", "slti", "sltiu", "andi", "ori", "xori"}:
            opcode = {
                "addi": 0x08, "addiu": 0x09, "slti": 0x0A, "sltiu": 0x0B,
                "andi": 0x0C, "ori": 0x0D, "xori": 0x0E,
            }[op]
            rt = reg(a[0])
            rs = reg(a[1])
            return i_type(opcode, rs, rt, parse_int(a[2]))

        if op == "lui":
            return i_type(0x0F, 0, reg(a[0]), parse_int(a[1]))

        if op in {"lw", "sw"}:
            opcode = 0x23 if op == "lw" else 0x2B
            rt = reg(a[0])
            imm = parse_int(a[1])
            rs = reg(a[2])
            return i_type(opcode, rs, rt, imm)

        if op in {"beq", "bne"}:
            opcode = 0x04 if op == "beq" else 0x05
            rs = reg(a[0])
            rt = reg(a[1])
            target = self.labels[a[2]]
            offset = (target - (pc + 4)) // 4
            return i_type(opcode, rs, rt, offset)

        if op in {"blez", "bgtz"}:
            opcode = 0x06 if op == "blez" else 0x07
            rs = reg(a[0])
            target = self.labels[a[1]]
            offset = (target - (pc + 4)) // 4
            return i_type(opcode, rs, 0, offset)

        if op in {"bltz", "bgez"}:
            rt = 0 if op == "bltz" else 1
            rs = reg(a[0])
            target = self.labels[a[1]]
            offset = (target - (pc + 4)) // 4
            return i_type(0x01, rs, rt, offset)

        if op in {"j", "jal"}:
            opcode = 0x02 if op == "j" else 0x03
            return j_type(opcode, self.labels[a[0]])

        raise ValueError(f"unsupported instruction at PC {pc:#x}: {line}")

    def assemble(self) -> list[int]:
        self.first_pass()
        words: list[int] = []
        for pc, line, line_no in self.instructions:
            try:
                words.append(self.encode(pc, line))
            except Exception as exc:
                raise RuntimeError(f"line {line_no}: {line}\n{exc}") from exc
        return words


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    asm = Assembler(args.input.read_text(encoding="utf-8"))
    words = asm.assemble()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(f"{word:08x}\n" for word in words), encoding="ascii")
    print(f"assembled {len(words)} instructions -> {args.output}")


if __name__ == "__main__":
    main()
