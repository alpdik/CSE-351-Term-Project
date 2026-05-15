# CSE351 YU Assembly — Project Roadmap

## Phase 1: BNF Grammar (15 pts) — Start here, ~1–2 hours

Write the formal grammar before touching any code. This becomes your blueprint.

- Define terminals: registers (`R0`–`R7`), immediates, labels, memory operands
- Define rules for all 11 instructions (`mov`, `load`, `store`, `addi`, `add`, `and`, `or`, `xor`, `blt`, `bgt`, `beq`)
- Cover memory address variants: `mem[REG]`, `mem[REG+N]`, `mem[REG-N]`
- Include label declarations (`LABEL:`) and label references in branch instructions

---

## Phase 2: Flex Lexer `.l` (15 pts) — ~2–3 hours

Tokenize the input stream.

- Tokens: keywords (`mov`, `load`, etc.), registers (`R[0-7]` valid, `R[8-9]+` → error), integers, labels, punctuation (`,`, `[`, `]`, `:`, `+`, `-`)
- Whitespace/newline handling
- Error rule for invalid registers

---

## Phase 3: Bison/Yacc Parser `.y` (20 pts) — ~4–6 hours

Build an **AST** (required — string-only approaches lose credit).

- Define AST node structs in C: one per instruction type
- Grammar rules map directly from your BNF
- Enforce syntax errors: missing commas, wrong operand types (e.g. label where register expected in `mov`)
- Support multiple labeled blocks and cross-label branches

---

## Phase 4: Loop Unrolling (35 pts) — ~4–6 hours, hardest part

Traverse the AST to detect and unroll loops.

- **Loop detection:** scan for backward branch (`blt`/`bgt`/`beq`) whose target label was defined *earlier* in the program
- **Unrolling by factor 2:** duplicate the loop body once, adjust all `addi` increment immediates (`×2`), keep the single branch at the end
- Handle memory address offsets in `load`/`store`: `mem[R2]` → `mem[R2+1]` for the duplicated body
- Edge case: programs with no loops must pass through unmodified

---

## Phase 5: Sample Programs — ~1 hour

Create 6 test files:

| File | Covers |
|---|---|
| `valid1.asm` | The copy-loop example from the spec |
| `valid2.asm` | Loop-free program (chained `and`/`or`/`xor`) |
| `valid3.asm` | Multiple labeled blocks, multiple branches |
| `invalid1.asm` | Invalid register (`R8`) |
| `invalid2.asm` | Missing comma |
| `invalid3.asm` | `mov` with label as first operand |

---

## Phase 6: Build Scripts + Report (15 pts) — ~2–3 hours

- `Makefile` or shell script: `flex yu.l && bison -d yu.y && gcc ...`
- Report sections: grammar design decisions, AST node design, loop detection algorithm, unrolling logic, test results

---

## Bonus (pick one, +20 pts)

**Recommended:** Symbol table for label resolution — it integrates naturally with the AST pass you already need for loop detection, and it's well-scoped.

Other options:
- Constant folding of arithmetic expressions
- Dead code elimination
- Peephole optimization on 2–3 instruction windows

---

## Suggested Order & Time Estimate

```
Day 1:  BNF Grammar + Flex Lexer
Day 2:  Bison Parser + AST nodes
Day 3:  Loop unrolling implementation
Day 4:  Sample programs + testing + bug fixes
Day 5:  Report + bonus (optional) + zip packaging
```

---

## Grading Summary

| Component | Points |
|---|---|
| BNF Grammar | 15 |
| Lexer (Flex) | 15 |
| Parser (Bison/Yacc) | 20 |
| Loop Unrolling | 35 |
| Report | 15 |
| **Total** | **100** |
| Bonus | +20 |

---

## Deliverables Checklist

- [ ] BNF grammar document
- [ ] `yu.l` — Flex lexical analyzer
- [ ] `yu.y` — Bison/Yacc parser
- [ ] Build script / Makefile
- [ ] `valid1.asm`, `valid2.asm`, `valid3.asm`
- [ ] `invalid1.asm`, `invalid2.asm`, `invalid3.asm`
- [ ] Report (design and analysis)
- [ ] Zip: `Dikmen_CSE351_Project.zip`
