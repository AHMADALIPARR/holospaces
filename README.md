# HOLOSPACES TECHNICAL MANIFEST

Repository: AHMADALIPARR/holospaces  
Generated from source inspection only  
No invented components

## 1. TOP-LEVEL DIRECTORY STRUCTURE

```
LICENSE
README.md
algorithms/
docs/
just-gherkin-fortran/
openqasm/
production/
specifications/
```

## 2. ALGORITHMS DIRECTORY

| File | Language | Role |
|------|----------|------|
| algorithms/grover_exact.rs | Rust | Exact rational Grover amplitude evolution |
| algorithms/holospaces_benchmark.rs | Rust | κ-elision benchmark (external crates required) |
| algorithms/openqasm_compiler.rs | Rust | OpenQASM-to-braid demo (external crates required) |
| algorithms/qubit_lean.lean | Lean 4 | Certificate + Grover formalisation |
| algorithms/qubit_qsharp.qs | Q# | Classical certificate + Grover reference |
| algorithms/qubit_rust_skeleton.rs | Rust | Concrete Substrate/Grover reference |

## 3. GROVER EXACT ARITHMETIC

File: `algorithms/grover_exact.rs` / `production/grover/`

- Amplitude space restricted to span{|target⟩, uniform-rest}
- Coefficient pair (a_t, a_u) : BigRational × BigRational
- Oracle: a_t ← −a_t
- Diffuser:
  - mean ← (a_t + (N−1)·a_u) / N
  - a_t ← 2·mean − a_t
  - a_u ← 2·mean − a_u
- Iteration count via scaled integer square-root of π²/16
- Constant: 6168502750680849 ≈ (π²/16)×10¹⁶
- Unit test (3 qubits, target 5): probability = 121/128

## 4. QUBIT CERTIFICATE KERNEL

File: `production/qubit_cert/src/lib.rs`

```
Structure Substrate {
  su2_is_projective_clifford_24 : bool
  pu22_dense                    : bool
  pu576_adjoint_ok              : bool
  pu576_rank92_ok               : bool
  pu576_ent_witness_ok          : bool
  mult_one_closure              : bool
  two_local_comp                : bool
  dedup_ratio                   : f64
}

Structure CertChainResult {
  su2_density_refuted      : bool
  pu22_density_established : bool
  pu576_machine_ok         : bool
  pu576_classical_ok       : bool
  dict_valid               : bool
  dedup_in_range           : bool
  overall                  : bool
}
```

Evaluation:
```
su2_refuted := su2_is_projective_clifford_24
pu22        := pu22_dense
machine     := adjoint ∧ rank92 ∧ ent
classical   := mult_one ∧ two_local
dict        := true
dedup       := 0.0 ≤ ratio ≤ 1.0
overall     := conjunction of all
```

Invariants:
- No matrix arithmetic
- No group-order computation
- Boolean flags are the complete certificate representation

## 5. OPENQASM SUBSYSTEM

### 5.1 Layout
```
openqasm/
  c_simulator/simulator.c
  examples/circuits/   (25 .qasm files)
  rust_parser/src/main.rs
```

### 5.2 C Simulator
- Hard-coded 2-qubit StateVec { re[4], im[4] }
- Gates: H⊗I, Rz(θ), CNOT(0,1)
- Input: angles.kg (`:array[mrad mrad]`)
- Fixed sequence: H → Rz(α) → CX → Rz(β) → CX

### 5.3 Rust Parser
- Recursive-descent subset
- Gates recognised: h, cx, rz, x, y, z, s, t
- AST: Version, Include, QubitDecl, Decl, Gate
- No measurement, no custom gates, no classical control

### 5.4 Example Circuits (25)
amplitude_amplification, bell, bell_measure, bitflip_encode,  
controlled_phase_chain, custom_circuit_v2, ghz_rotations,  
grover_2qubit, hardware_efficient_ansatz, holospaces_ht_cnot,  
layered_ht_cz, mcx_4, parametric_entangler_3, phase_kickback,  
phaseflip_encode, qaoa_layer, qft_3, qft_5, qpe_3bit,  
rotation_cascade, shor_encode_step, swap_test, teleportation,  
toffoli, w_state

## 6. PRODUCTION KERNELS

```
production/
  grover/                 Exact Grover CLI + lib
  qubit_cert/             Boolean certificate kernel + CLI
  certificate_runner/     8-vector regression harness
  openqasm_c/             C simulator production path
  openqasm_rust/          Rust parser production path
  fortran_skl/            Fortran 2018 VECTOR[F64] functors
```

### 6.1 certificate_runner
Vectors:
- all_true → expect true
- su2_false → expect false
- pu22_false → expect false
- machine_partial → expect false
- classical_partial → expect false
- dedup_out_of_range → expect false
- dedup_boundary_zero → expect true
- dedup_boundary_one → expect true

CLI exits 0 only if every vector matches.

### 6.2 fortran_skl
Functors: skl_add, skl_normalize, skl_identity, skl_pipeline_add_norm  
Status: SKL_OK, SKL_ERR_SIZE, SKL_ERR_ZERO, SKL_ERR_RESOLVE  
Build: `just compile && just run`

## 7. SNAPKITTY / JUST-GHERKIN-FORTRAN

```
just-gherkin-fortran/
  justfile
  src/
    skl_types.f90
    skl_lexer.f90
    skl_parser.f90
    functor_runtime.f90
    gherkin_runner.f90
    skl_main.f90
  examples/arithmetic.skl
  features/functor_execution.feature
  specifications/grammar/snapkitty.grammar
```

### 7.1 Type System
Only accepted type: `VECTOR[F64]` / `VECTOR [ F64 ]`  
Error codes: SKL_OK=0, SKL_ERR_IO=10, SKL_ERR_LEX=20,  
SKL_ERR_PARSE=30, SKL_ERR_SEMANTIC=40, SKL_ERR_RESOLVE=50, SKL_ERR_EXEC=60

### 7.2 Parser
Recursive descent. Productions:
```
MODULE <ident>
FUNCTOR <ident>
  INPUT : <type>
  OUTPUT : <type>
  OPERATION : <block>
  REQUIRES : <block>   (optional, stored not evaluated)
  ENSURES : <block>    (optional, stored not evaluated)
  END
PIPELINE <ident>
  APPLY <ident>
  VERIFY ALL
  END
```

### 7.3 Built-in Functors
- ADD: pairwise sum, requires even length
- NORMALIZE: Euclidean unit vector, fails on zero
- IDENTITY: copy

### 7.4 Build
```
cd just-gherkin-fortran
just compile
just parse
just test
```

## 8. SPECIFICATIONS

| File | Role |
|------|------|
| specifications/qubit_algorithm.feature | Certificate scenarios |
| specifications/qubit_full_traceable.feature | Traceability scenarios |
| specifications/syntax_validation.feature | Syntax scenarios |
| just-gherkin-fortran/features/functor_execution.feature | Functor scenarios |

Qubit predicate (documentary):
```
Qubit(S) :=
  (¬su2_density_refuted) ∧
  pu22_density_established ∧
  (adj ∧ rank92 ∧ ent) ∧
  (mult_one ∧ two_local) ∧
  dict_valid ∧
  (0 ≤ dedup ≤ 1) ∧
  (∀c. source_trace(c) ≠ ⊥)
```

Executable realises only the Boolean conjunction; source_trace is documentation-only.

## 9. FORMAL SKELETONS

### Lean 4 (`algorithms/qubit_lean.lean`)
- Structures: Substrate, CertChainResult, GroverAmplitudes
- evaluate, groverStep, groverIterate
- Theorems: grover_3qubit_probability (121/128), su2_refutation_holds

### Q# (`algorithms/qubit_qsharp.qs`)
- Newtypes: Substrate, CertChainResult, GroverAmplitudes
- Evaluate, GroverStep, GroverIterate, QubitCertificate
- EntryPoint: RunHolospacesDemo
- Qubit allocation count: 0

### Rust reference (`algorithms/qubit_rust_skeleton.rs`)
- Full Substrate/evaluate matching production
- Full GroverSolver matching grover_exact
- Unit tests for overall certificate and 121/128

## 10. DOCUMENTATION ARTIFACTS

| File | Size | Subject |
|------|------|---------|
| docs/qubit_algorithm_and_fortran_stack.md | ~55 KB | Certificate chain + SKL design |
| docs/openqasm_klong_c_rust_parser.md | ~27 KB | Parser/simulator notes |
| docs/original_pasted_content.txt | ~66 KB | Archival operator text |
| docs/assets/IMAGE_MANIFEST.md | — | Asset provenance |

## 11. IMAGE ASSETS ON REMOTE

Present:
- docs/assets/quantum/02-trapped-ion-system.jpg
- docs/assets/quantum/05-quantum-annealer.jpg
- docs/assets/quantum/07-su2-bloch-sphere.png
- docs/assets/quantum/08-topological-braid.png
- docs/assets/quantum/09-grover-amplitudes.png

Absent on remote (referenced in older drafts only):
01, 03, 04, 06, 10–20 and all architecture/branding paths

## 12. EXTERNAL DEPENDENCIES NOT IN TREE

```
tqc_atlas
tqc_compiler
tqc_core
tqc_model
tqc_substrate
```

Effect: `holospaces_benchmark.rs` and `openqasm_compiler.rs` do not compile standalone.

## 13. VERIFICATION MATRIX

| Component | Method | Artifact | Result |
|-----------|--------|----------|--------|
| Grover exact | Unit test | grover_exact.rs | 121/128 |
| Certificate kernel | Pure function | qubit_cert/src/lib.rs | Boolean composition |
| Certificate runner | 8 vectors | certificate_runner | all pass |
| SKL parser | Feature scenarios | just-gherkin-fortran | Accepts grammar |
| SKL runtime | Built-ins | functor_runtime.f90 | ADD/NORMALIZE/IDENTITY |
| OpenQASM parser | Manual | rust_parser | Limited gate set |
| C simulator | Fixed sequence | simulator.c | 2-qubit H-RZ-CX |
| Lean | native_decide | qubit_lean.lean | 121/128 theorem |
| Q# | Classical | qubit_qsharp.qs | Certificate + Grover |

## 14. BUILD COMMANDS

```sh
# Fortran SKL (research)
cd just-gherkin-fortran && just compile && just parse && just test

# Fortran SKL (production)
cd production/fortran_skl && just compile && just run

# Rust Grover
cd production/grover && cargo run --release

# Rust Certificate
cd production/qubit_cert && cargo run --release

# Certificate regression
cd production/certificate_runner && cargo run --release

# C simulator
cd openqasm/c_simulator
gcc -std=c99 -O2 -lm simulator.c -o simulator && ./simulator
```

## 15. LICENSE

GNU Affero General Public License v3.0  
File: LICENSE (34009 bytes)

## 16. DETAILED FILE-LEVEL INVENTORY

### algorithms/grover_exact.rs
- Size: 4160 bytes
- Types: GroverSolver, ExactGroverReport
- Methods: new, execute_exact_witness
- Dependencies: num_bigint, num_rational
- Error: target_state ≥ 2^n → Err

### algorithms/holospaces_benchmark.rs
- Size: 4789 bytes
- Requires external tqc_* crates
- Behaviour when present: compile circuit → braid word → track distinct κ → elision_ratio
- Disclaimer in source: engineering measurement, not supremacy

### algorithms/openqasm_compiler.rs
- Size: 1403 bytes
- Requires external tqc_* crates
- Compile status in this tree: fails

### production/qubit_cert/src/lib.rs
- Size: 1679 bytes
- Pure Boolean evaluate
- No dependencies beyond std

### production/certificate_runner
- 8 named vectors covering every conjunct and boundary
- CLI exit code reflects full pass/fail

### production/fortran_skl
- skl_production.f90: pure functors
- skl_main.f90: driver
- Justfile: compile / run / clean

## 17. OPENQASM RUST PARSER DETAIL

AST:
```
Expr = Float(f64) | Int(i64) | Ident(String) | ArrayAccess
Stmt = Version | Include | QubitDecl | Decl | Gate
```

Tokenisation: whitespace and `[](),;` are separators  
Line comments: `//`  
No multi-line comments

Recognised gates: h cx rz x y z s t

Limitations:
- No OPENQASM 3
- No custom gate definitions
- No measurement
- No classical control
- No barrier / reset / delay

## 18. C SIMULATOR DETAIL

StateVec: double re[4], im[4] — basis |00⟩ |01⟩ |10⟩ |11⟩

Gates:
- apply_h: H ⊗ I (hard-coded 4×4)
- apply_rz(qubit, θ): diagonal phase
- apply_cnot: fixed control=0 target=1

Input: angles.kg milliradians → radians via ×2π/1000  
Sequence fixed in main

## 19. CERTIFICATE CHAIN LOGICAL STRUCTURE

Documentation predicate includes source_trace  
Executable has no source_trace function  

Documentation describes machine-checked certificates  
Executable receives pre-computed Boolean flags only  

No matrix or group computation at runtime

## 20. GROVER ARITHMETIC DETAIL

```
N = 2^n
scaled = N × 6168502750680849
integer Newton square-root
iterations = ⌊result / 1e8⌋
```

Initial: a_t = 1, a_u = 1  
After k steps: P_t = a_t² / N  
n=3, k=2 → a_t = 11/4 → P_t = 121/128

All operations in BigRational — no floating-point in amplitude path

## 21. SKL LANGUAGE SURFACE

Keywords: MODULE FUNCTOR PIPELINE INPUT OUTPUT OPERATION  
REQUIRES ENSURES APPLY VERIFY ALL END

Type constructor: VECTOR[F64]

Unsupported: user types, matrices, integers, conditionals, loops,  
imports, comments inside OPERATION (treated as text)

## 22. FUNCTOR EXECUTION SEMANTICS

ADD: size even → output[i] = input[2i]+input[2i+1]  
NORMALIZE: ‖x‖₂ > 0 → x/‖x‖₂  
IDENTITY: copy  

Pipeline: sequential application; first failure aborts

## 23. ERROR CODE TAXONOMY

| Code | Name | Origin |
|------|------|--------|
| 0 | SKL_OK | success |
| 10 | SKL_ERR_IO / SKL_ERR_SIZE | IO or size |
| 20 | SKL_ERR_LEX / SKL_ERR_ZERO | lexer or zero vector |
| 30 | SKL_ERR_PARSE / SKL_ERR_RESOLVE | parse or missing functor |
| 40 | SKL_ERR_SEMANTIC | type/name |
| 50 | SKL_ERR_RESOLVE | unregistered |
| 60 | SKL_ERR_EXEC | runtime arithmetic |

## 24. DATA FLOW SUMMARY

```
Gherkin features          → documentary only
docs/*.md                 → documentary only
production/qubit_cert     → executable Boolean conjunction
algorithms/grover_exact   → executable rational amplitudes
just-gherkin-fortran      → executable SKL parse + functors
openqasm/rust_parser      → executable subset parse
openqasm/c_simulator      → executable fixed 2-qubit circuit
holospaces_benchmark      → non-executable (missing crates)
```

## 25. MEMORY AND COMPLEXITY

| Component | Time | Space |
|-----------|------|-------|
| Grover (n qubits) | O(√(2ⁿ)·BigRational) | O(1) |
| Certificate evaluate | O(1) | O(1) |
| SKL ADD/NORMALIZE | O(m) | O(m) |
| C simulator | O(1) | O(1) |
| OpenQASM parse | O(L) | O(L) |

## 26. DETERMINISM GUARANTEES

- Grover: deterministic given (n, target)
- Certificate: deterministic given Substrate fields
- SKL: deterministic for fixed input + pipeline
- C simulator: deterministic for fixed angles.kg
- No RNG in any production path

## 27. KNOWN DOCUMENTATION / CODE DIVERGENCES

D1 source_trace described, not implemented  
D2 machine-checked certificates described, only flags present  
D3 Zariski-density arguments, no algebraic-geometry code  
D4 holospaces_benchmark described as runnable, crates missing  
D5 image manifest lists 20, remote has 5  
D6 REQUIRES/ENSURES described as contracts, runtime ignores them  
D7 OpenQASM compiler described, depends on absent crates  

## 28. ABSENCE REGISTER

Absent:
- tqc_* crates
- Full OpenQASM 2/3 grammar
- Measurement simulation beyond fixed C sequence
- Noise models
- Hardware backends
- CI configuration
- Automated certificate↔Gherkin binding
- source_trace implementation
- Matrix/group-order computation
- Image files 01,03,04,06,10–20 on remote

## 29. SOURCE-BOUND INVARIANTS

I1  Certificate evaluation is pure Boolean composition of eight fields  
I2  Grover amplitude path never leaves the two-dimensional rational subspace  
I3  SKL type system accepts only VECTOR[F64]  
I4  SKL runtime does not evaluate REQUIRES/ENSURES  
I5  holospaces_benchmark and openqasm_compiler require external crates  
I6  C simulator implements a single fixed 2-qubit circuit  
I7  OpenQASM Rust parser recognises exactly eight gate names  
I8  No executable path allocates or measures physical qubits  
I9  Deduplication metric is f64 range-checked to [0,1]  
I10 Formal skeletons contain concrete code matching production structures  
I11 Only five image assets resolve on the remote  
I12 Documentation claims exceed executable behaviour for source_trace and machine-checked certificates  

## 30. TERMINAL INVARIANT BLOCK

INV-A  evaluate is a pure function of eight fields  
INV-B  groverIterate stays in ℚ×ℚ  
INV-C  SKL accepts only VECTOR[F64]  
INV-D  No tqc_* symbols resolve inside this tree  
INV-E  Five image paths resolve; fifteen do not  
INV-F  source_trace is documentation-only  
INV-G  REQUIRES/ENSURES are syntax-only  
INV-H  All Boolean certificate results are flag conjunctions  
INV-I  121/128 is the sole numeric probability claim backed by unit test  
INV-J  No physical qubit is allocated by any executable in the tree  

## 31. PRODUCTION MODULE STATUS

| Module | Status | Entry |
|--------|--------|-------|
| production/grover | complete | cargo run |
| production/qubit_cert | complete | cargo run |
| production/certificate_runner | complete | cargo run (8 vectors) |
| production/openqasm_c | present | gcc + run |
| production/openqasm_rust | present | cargo run <qasm> |
| production/fortran_skl | complete | just compile && just run |

## 32. REPOSITORY STATISTICS

- Top-level directories: 6
- Rust production crates: 4
- Fortran production module: 1
- QASM examples: 25
- Gherkin features: ≥4
- Lean file: 1
- Q# file: 1
- Image files on remote: 5
- License: AGPLv3

## 33. SAFE EXTENSION PROTOCOL

1. New certificate flag → add to Substrate + evaluate + runner vectors  
2. New SKL type → update semantic checker + runtime  
3. New OpenQASM gate → update parser match + tests  
4. New image → manifest entry + binary upload  
5. External crates → vendor or replace before claiming executability  

## 34. COMPLIANCE CHECKLIST

[x] Certificate kernel is pure  
[x] Grover uses exact rationals  
[x] SKL parser rejects unknown constructs  
[x] No quantum hardware path in executable code  
[x] External crate absence documented  
[x] Image resolution status documented  
[x] Formal skeletons contain concrete matching code  
[x] Unit tests exist for core arithmetic claims  
[x] License is AGPLv3  
[x] Divergence register maintained  
[x] Production certificate runner with boundary vectors  
[x] Production Fortran SKL kernel with status codes  
