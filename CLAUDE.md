# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a compiler project for **CSE351: Programming Languages** at Yeditepe University. The goal is to design and implement **YU Assembly**, a custom pseudo-assembly language, using Flex (lexer) and Bison/Yacc (parser) with full AST construction and loop unrolling optimization.

## Toolchain

- **Flex** — lexical analyzer generator (produces `lex.yy.c` from `yu.l`)
- **Bison** — parser generator (produces `yu.tab.c` / `yu.tab.h` from `yu.y`)
- **GCC** — compiles the generated C code

### Build

```sh
flex yu.l
bison -d yu.y
gcc -o yu_asm lex.yy.c yu.tab.c -lfl
```

### Run

```sh
./yu_asm < input.asm
```

## Language Specification

### Instruction Set

| Instruction | Syntax | Semantics |
|---|---|---|
| `mov` | `mov Rd, imm` | `Rd = imm` |
| `load` | `load Rd, mem[addr]` | `Rd = mem[addr]` |
| `store` | `store Rs, mem[addr]` | `mem[addr] = Rs` |
| `addi` | `addi Rd, Rs, imm` | `Rd = Rs + imm` |
| `add` | `add Rd, Rs1, Rs2` | `Rd = Rs1 + Rs2` |
| `and` | `and Rd, Rs1, Rs2` | `Rd = Rs1 & Rs2` |
| `or` | `or Rd, Rs1, Rs2` | `Rd = Rs1 \| Rs2` |
| `xor` | `xor Rd, Rs1, Rs2` | `Rd = Rs1 ^ Rs2` |
| `blt` | `blt Rs1, Rs2, label` | branch if `Rs1 < Rs2` |
| `bgt` | `bgt Rs1, Rs2, label` | branch if `Rs1 > Rs2` |
| `beq` | `beq Rs1, Rs2, label` | branch if `Rs1 == Rs2` |

### Validity Rules (must be enforced)

- Valid registers: `R0`–`R7` only. `R8` or higher must produce an error.
- Memory addressing forms: `mem[REG]`, `mem[REG+NUMBER]`, `mem[REG-NUMBER]`.
- `mov` first operand must be a register, not a label (syntax error otherwise).
- Missing commas are syntax errors.
- Programs with no loops must be accepted.

## Architecture

The implementation must be **AST-based** — the grader explicitly penalizes string-manipulation approaches.

### Expected file structure

```
yu.l          # Flex lexer: tokenizes registers, keywords, integers, labels, punctuation
yu.y          # Bison parser: grammar rules + AST node construction + loop unrolling pass
ast.h         # AST node type definitions (optional separate header)
Makefile      # Build script
valid1.asm    # Valid: copy-loop (spec example)
valid2.asm    # Valid: loop-free with chained and/or/xor
valid3.asm    # Valid: multiple labeled blocks and branches
invalid1.asm  # Invalid: register R8
invalid2.asm  # Invalid: missing comma
invalid3.asm  # Invalid: label as first operand of mov
report.pdf    # Design and analysis report
```

### AST Design

Each instruction type maps to a node. A program is a linked list of instruction nodes. Key node fields:
- `type` — enum of all 11 instruction types plus LABEL
- `rd`, `rs1`, `rs2` — register numbers (0–7)
- `imm` — integer immediate
- `label` — string for label declarations and branch targets
- `mem_reg`, `mem_offset`, `mem_offset_sign` — for memory addressing
- `next` — pointer to next instruction node

### Loop Unrolling Logic

1. First pass: collect all label names and their positions in the instruction list.
2. Second pass: find backward branches — a `blt`/`bgt`/`beq` whose target label appears *before* it in the list.
3. For each detected loop (exactly one backward branch per loop):
   - Duplicate every instruction between the label and the branch (exclusive of the branch).
   - In duplicated `load`/`store` instructions, increment `mem_offset` by 1.
   - In duplicated `addi` instructions that increment loop counters, double the immediate.
   - Keep a single branch instruction at the end.

## Bonus (symbol table recommended)

If implementing the bonus, a symbol table for label resolution is the best fit — it reuses the label-collection pass already needed for loop detection. Validate that every branch target (`blt`/`bgt`/`beq` label operand) refers to a declared label; emit a semantic error otherwise.
