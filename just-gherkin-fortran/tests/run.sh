#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
gfortran -std=f2018 -O2 -Wall -Wextra -Werror -fcheck=all -fbacktrace \
  -Jbuild -Ibuild \
  src/skl_types.f90 src/skl_lexer.f90 src/skl_parser.f90 \
  src/functor_runtime.f90 src/gherkin_runner.f90 src/skl_main.f90 \
  -o build/skl
./build/skl parse examples/arithmetic.skl
./build/skl verify examples/arithmetic.skl
./build/skl test features/functor_execution.feature
./build/skl demo
