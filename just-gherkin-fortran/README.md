# JUST + Gherkin + Fortran Functor Stack

A Fortran 2018 implementation prototype with a custom SKL lexer/parser, AST, semantic checks, procedure-pointer functor registry, pipeline executor, and a small Gherkin scenario runner.

## Requirements

- GNU Fortran 10+ (Fortran 2018 support)
- [just](https://github.com/casey/just)

## Build and run

```sh
just compile
just parse
just verify
just test
just demo
```

Without `just`, compile directly:

```sh
mkdir -p build
gfortran -std=f2018 -O2 -Wall -Wextra -fcheck=all -fbacktrace \
  -Jbuild -Ibuild \
  src/skl_types.f90 src/skl_lexer.f90 src/skl_parser.f90 \
  src/functor_runtime.f90 src/gherkin_runner.f90 src/skl_main.f90 \
  -o build/skl
```

## CLI

```text
skl parse <file.skl>
skl verify <file.skl>
skl test <feature.feature>
skl demo
```

## SKL subset implemented

- `MODULE name`
- `FUNCTOR name ... END`
- `INPUT : VECTOR[F64]` and `OUTPUT : VECTOR[F64]`
- `OPERATION:`, `REQUIRES:`, and `ENSURES:` blocks
- `PIPELINE name`, `APPLY functor`, `VERIFY ALL`, `END`
- comments beginning with `#`
- source line/column positions on tokens and parser diagnostics

The current semantic layer checks supported vector types, required functor declarations, duplicate declarations, and pipeline references. The operation and contract bodies are retained as AST text; they are not yet compiled into executable expressions. Runtime execution currently dispatches registered native Fortran procedures.

## Runtime functors

- `ADD`: accepts a flat vector of even length, adds adjacent pairs.
- `NORMALIZE`: returns the unit-length vector, rejects a zero vector.
- `IDENTITY`: copies its input.

The Gherkin runner currently implements the step vocabulary in `features/functor_execution.feature`. Unknown steps fail the scenario rather than being silently accepted.

## Current boundaries

This is a working vertical slice, not a complete general-purpose Gherkin implementation or a general SKL compiler. It does not yet evaluate arbitrary `OPERATION`, `REQUIRES`, or `ENSURES` expressions. The parser recognizes the declared structure, and the runtime uses explicitly registered Fortran procedures. The runner currently supports fixed step definitions rather than arbitrary step-parameter binding.
