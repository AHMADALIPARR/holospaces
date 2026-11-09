# Holospaces / Qubit Certificate Chain / SnapKitty SKL

This repository assembles mathematical constructions, classical reference implementations, and a custom language runtime for exactly-decided density and universality certificate chains on content-addressed substrates, together with OpenQASM circuit representations and an exact-arithmetic Grover amplitude evolution.

The constructions distinguish a 2-dimensional SU(2) block, on which density is refuted because the gate image is a finite projective Clifford group of order 24 over \(\mathbb{Q}(\zeta_{24})\), from 22-dimensional PU(22) and 576-dimensional PU(576) blocks on which density is established by a combination of machine-checked certificates and cited classical lemmas. Content-addressed Holospaces provide topological degeneracy benchmarks through cache-collapse metrics. These metrics are engineering observations; they are not presented as quantum advantage.

## License

This work is licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE).

## Mathematical Foundations

The Qubit predicate operates on a content-addressed substrate \(S\) (a mapping from hash to data blob). Primitive certificates include:

- `su2_density_refuted(S)`: refutes density on the SU(2) block.
- `pu22_density_established(S)`: establishes density on PU(22).
- Machine-checked components for PU(576): adjoint component, reachability rank 92, direct entangling witness.
- Classical lemmas: multiplicity-one closure and two-local composition.
- `dict_row_record(S)` and `cache_collapse(S)` for per-row distinctions and deduplication metrics.

The predicate evaluates to true only when the SU(2) density is refuted, the higher-dimensional densities hold, dictionary rows are correctly recorded, the collapse metric lies in \([0,1]\), and every certificate is traceable to an authoritative source.

Exact Grover amplitude evolution is implemented as a classical reference using rational arithmetic. For \(N = 2^n\) states the optimal iteration count is computed from a scaled integer approximation of \(\pi/4\sqrt{N}\). Amplitudes \(a_t\) (target) and \(a_u\) (uniform non-target) are updated by oracle phase inversion followed by inversion about the mean:

\[
a_t \leftarrow -a_t, \quad \text{mean} = \frac{a_t + (N-1)a_u}{N}, \quad a_t \leftarrow 2\cdot\text{mean} - a_t, \quad a_u \leftarrow 2\cdot\text{mean} - a_u.
\]

The production kernel in `production/grover/` and the reference in `algorithms/grover_exact.rs` both use `num_rational::BigRational`.

## System Architecture

The repository contains four principal language and runtime boundaries:

- Rust algorithms and production kernels (`algorithms/`, `production/`) for Grover, OpenQASM parsing, and certificate chains.
- Fortran 2018 SKL lexer, parser, AST, functor registry, and Gherkin runner (`just-gherkin-fortran/src/`).
- C state-vector simulator (`openqasm/c_simulator/`, `production/openqasm_c/`).
- Specification features in Gherkin (`specifications/`, `just-gherkin-fortran/features/`).

OpenQASM circuits are stored under `openqasm/examples/circuits/`. The compiler demo in `algorithms/openqasm_compiler.rs` and the Holospaces benchmark in `algorithms/holospaces_benchmark.rs` reference external crates (`tqc_*`) that are not present in this tree; the files therefore serve as structural demonstrations rather than self-contained executables.

```mermaid
graph TD
    subgraph SKL["SnapKitty Kernel Language"]
        Lexer[skl_lexer.f90] --> Parser[skl_parser.f90]
        Parser --> AST[module_ast_t]
        AST --> Runtime[functor_runtime.f90]
    end
    subgraph Qubit["Qubit Certificate Chain"]
        Certs[SU(2)/PU(22)/PU(576) certificates]
        Dict[dict_row_record]
        Collapse[cache_collapse]
    end
    subgraph OpenQASM["OpenQASM Representations"]
        Circuits[examples/circuits/*.qasm]
        ParserR[rust_parser]
        SimC[c_simulator]
    end
    SKL --> Runtime
    Qubit --> Certs
    OpenQASM --> Circuits
```

## Qubit Certificate Chains

Certificate construction follows the predicate defined in `docs/qubit_algorithm_and_fortran_stack.md` and the Gherkin features under `specifications/`. The production implementation `production/qubit_cert/` supplies pure functions for the density checks. No claim is made that the certificates have been machine-checked beyond the skeletons and feature files present in the tree.

SU(2) is treated as the projective special unitary group of dimension 2; the finite image of order 24 is the concrete obstruction to density. PU(22) and PU(576) are the corresponding projective unitary groups on which density holds under the stated certificates and lemmas. Matrix dimensions and group orders are taken directly from the supplied documentation; no additional algebraic constructions have been introduced.

## Topological Braid Compilation

The OpenQASM-to-braid compiler demonstration accepts a subset of OpenQASM 2.0 (Hadamard, CNOT, RX/RY/RZ) and produces a braid word over generators \(\Sigma, \Tau, \Mu\). The demonstration code is not self-contained; it depends on external atlas, compiler, and model crates. The circuit collection itself is present and may be parsed by the hand-written recursive-descent parser in `openqasm/rust_parser/` or the production variant.

## Exact Grover Amplitude Evolution

The reference evaluation tracks only the two-dimensional symmetric subspace. For three qubits targeting state 5 the optimal iteration count is 2; the resulting target probability is \(121/128\), matching the unit test in `algorithms/grover_exact.rs`. All arithmetic is exact rational; floating-point approximations are avoided for the amplitude coefficients.

## Content-Addressed Holospaces

The Holospaces benchmark constructs a circuit of Hadamard, T, and CNOT gates, compiles it to a braid word, and tracks distinct content-addressed states \(\kappa\) under successive generator applications. The reported elision ratio is the ratio of braid-word prefixes to distinct \(\kappa\) values. The implementation notes that the braid execution does not simulate a full \(2^n\) state vector and makes no unitary-equivalence claim.

## SnapKitty Kernel Language

SKL is a small domain-specific language with modules, functors, typed vector inputs/outputs, operation/requires/ensures blocks, and pipelines. The Fortran lexer recognizes identifiers, numbers, strings, symbols, and comments. The parser builds an AST of functors and pipelines. Semantic checks verify type declarations and reference integrity. Runtime dispatch is limited to three registered native procedures: ADD (adjacent pair sum on even-length vectors), NORMALIZE (unit-length projection), and IDENTITY. Arbitrary operation expressions are retained as text; they are not yet evaluated.

Example accepted by the current parser:

```
MODULE arithmetic
FUNCTOR ADD
    INPUT : VECTOR[F64]
    OUTPUT : VECTOR[F64]
    OPERATION:
        RESULT = LEFT + RIGHT
    END
END
```

## JUST / Gherkin / Fortran

JUST orchestrates build, parse, verify, and test targets. Gherkin features supply scenario steps that the runner matches against a fixed vocabulary. The Fortran runtime supplies the numeric kernels. The stack is a vertical slice: the parser accepts the declared grammar, the runner executes registered steps, and unknown steps fail.

## Repository Atlas

| Path | Language | Responsibility |
|------|----------|----------------|
| algorithms/grover_exact.rs | Rust | Exact rational Grover amplitude recurrence |
| algorithms/holospaces_benchmark.rs | Rust | Content-addressed degeneracy demonstration |
| algorithms/openqasm_compiler.rs | Rust | OpenQASM-to-braid structural demo |
| algorithms/qubit_*.{qs,lean,rs} | Q#/Lean/Rust | Skeletons for the Qubit predicate |
| just-gherkin-fortran/src/*.f90 | Fortran 2018 | SKL lexer, parser, functor runtime, Gherkin runner |
| openqasm/examples/circuits/*.qasm | OpenQASM | Circuit library (25 circuits) |
| production/grover/ | Rust | Production exact Grover kernel |
| production/qubit_cert/ | Rust | Production certificate-chain functions |
| production/openqasm_* | C/Rust | Production simulator and parser |
| docs/qubit_algorithm_and_fortran_stack.md | Markdown | Mathematical constructions and Gherkin |
| specifications/*.feature | Gherkin | Executable specifications |

## Algorithm Reference

| Algorithm | Mathematical structure | Representation | Source file | Execution |
|-----------|------------------------|----------------|-------------|-----------|
| Grover exact | Rational amplitude recurrence on symmetric subspace | BigRational | algorithms/grover_exact.rs, production/grover/ | cargo test / cargo run |
| Qubit predicate | Density certificates on SU(2), PU(22), PU(576) | Boolean composition of primitives | docs/qubit_algorithm_and_fortran_stack.md, production/qubit_cert/ | cargo run (production) |
| SKL parse | MODULE / FUNCTOR / PIPELINE grammar | AST of typed declarations | just-gherkin-fortran/src/skl_parser.f90 | gfortran + skl parse |
| Holospaces benchmark | Braid-word prefix elision under \(\kappa\) | HashSet of content addresses | algorithms/holospaces_benchmark.rs | Requires external crates |

## Quantum Hardware and Physical Context

The mathematical constructions concern abstract unitary groups and content-addressed identifiers. They do not prescribe a particular physical qubit implementation. Superconducting circuits, trapped ions, neutral atoms, and photonic systems are relevant only insofar as their control Hamiltonians can realize the unitary groups under discussion. No evidence in the repository indicates that any physical device has executed the certificate chain or the braid compilation.

Authentic laboratory photographs of representative apparatus are retained under `docs/assets/quantum/` where reuse permissions could be verified. Captions identify the photographed hardware and its institution; none of the pictured systems is claimed to have run repository code.

## Build, Execution, and Reproduction

Fortran SKL (requires gfortran ≥ 10):

```sh
cd just-gherkin-fortran
just compile
just parse
just test
```

Rust production kernels (requires Rust and Cargo):

```sh
cd production/grover && cargo run --release
cd production/qubit_cert && cargo run --release
```

C simulator:

```sh
cd production/openqasm_c
gcc -std=c99 -O2 -lm simulator.c -o simulator
./simulator
```

No quantum hardware execution path is present.

## Verification Record

| Component | Verification method | Evidence artifact | Observed result |
|-----------|---------------------|-------------------|-----------------|
| Grover exact | Unit test on 3-qubit instance | algorithms/grover_exact.rs | Target probability 121/128 |
| SKL parser | Feature scenarios | just-gherkin-fortran/features/ | Parser accepts declared grammar; unknown steps fail |
| Qubit predicate | Gherkin scenarios | specifications/qubit_algorithm.feature | Scenarios describe expected certificate outcomes |
| OpenQASM parser | Manual inspection of recursive descent | openqasm/rust_parser/src/main.rs | Accepts subset used by example circuits |

No formal proof artifacts beyond the Lean and Q# skeletons are present. Certificate validity is therefore documented only to the extent of the supplied specifications and production pure functions.

## Research Context and References

The density questions for projective unitary groups and the finite image of the Clifford group on SU(2) are classical. The content-addressed representation and cache-collapse metric are engineering measurements defined inside the repository. External literature on Solovay–Kitaev density, Gottesman–Knill simulation, and process tomography is referenced only for contrast; the repository does not implement those algorithms.

## License and Project Attribution

Original mathematical constructions, Gherkin features, and code skeletons are preserved as supplied. The AGPLv3 license text is unmodified. Attribution for any external photograph appears in `docs/assets/IMAGE_MANIFEST.md`.


## Detailed Certificate Evaluation

The production kernel in `production/qubit_cert/src/lib.rs` defines a `Substrate` structure whose fields are Boolean flags corresponding to the primitive certificates and a floating-point deduplication ratio. Evaluation is a pure function:

```rust
pub fn evaluate(&self) -> CertChainResult {
    let su2_refuted = self.su2_is_projective_clifford_24;
    let pu22 = self.pu22_dense;
    let machine = self.pu576_adjoint_ok && self.pu576_rank92_ok && self.pu576_ent_witness_ok;
    let classical = self.mult_one_closure && self.two_local_comp;
    // ...
    let overall = su2_refuted && pu22 && machine && classical && dict && dedup;
}
```

The resulting `CertChainResult` records each component independently. The dictionary validity flag is set true by construction, reflecting the requirement that per-row distinctions between the three blocks be recorded. No additional algebraic verification of the group orders or matrix dimensions is performed inside the kernel; those facts are taken from the documentation in `docs/qubit_algorithm_and_fortran_stack.md`.

## OpenQASM Circuit Collection

Twenty-five circuits are present under `openqasm/examples/circuits/`. They include standard constructions (Bell, GHZ, QFT, Toffoli, teleportation, QAOA layer, quantum phase estimation) and Holospaces-style layered H-T-CZ sequences. The recursive-descent parser in `openqasm/rust_parser/src/main.rs` recognizes the subset of OpenQASM 2.0 and 3 used by these examples. The C simulator in `openqasm/c_simulator/simulator.c` implements a minimal complex state-vector evolution for the same subset.

## SKL Grammar and Runtime Limits

The lexer (`skl_lexer.f90`) tokenizes identifiers, numbers (including scientific notation), strings, symbols, and newline-separated statements, discarding comments that begin with `#`. The parser (`skl_parser.f90`) expects a top-level `MODULE` followed by zero or more `FUNCTOR` or `PIPELINE` declarations. Each functor must declare `INPUT` and `OUTPUT` types of the form `VECTOR[F64]` and may contain optional `OPERATION`, `REQUIRES`, and `ENSURES` blocks whose bodies are stored as raw text. Pipelines consist of `APPLY` statements and a terminal `VERIFY ALL`.

The runtime registry currently exposes three procedures. `ADD` requires an even-length input vector and returns the adjacent pairwise sums. `NORMALIZE` rejects the zero vector and returns the Euclidean unit vector. `IDENTITY` performs a copy. Because operation expressions are not interpreted, a functor whose `OPERATION` block contains arbitrary arithmetic is accepted by the parser but does not alter the numeric result of the registered procedure that shares its name.

## Holospaces Degeneracy Measurement

The benchmark constructs a linear chain of single-qubit Hadamard and T gates interleaved with CNOT. The compiled braid word is applied generator by generator. After each generator the resulting permutation is applied to a fixed base amplitude vector; the content address \(\kappa\) of the encoded amplitudes is inserted into a hash set. The elision ratio is the length of the braid word divided by the number of distinct addresses observed. The code explicitly notes that the computation does not materialize a \(2^n\) state vector and that the compiler makes no claim of unitary equivalence to the original circuit.

## Reproduction Notes

The Fortran sources compile with `gfortran -std=f2018`. The Rust production crates depend only on `num-bigint` and `num-rational` for the Grover kernel and on no external crates for the certificate kernel. The OpenQASM Rust parser is zero-dependency. External `tqc_*` crates referenced by the algorithm demos are not vendored; those files therefore cannot be executed from a clean checkout of this repository.

All numerical results reported by the exact Grover implementation are reproducible from the rational arithmetic alone. Certificate outcomes are reproducible from the Boolean flags supplied to `Substrate::evaluate`. No floating-point nondeterminism appears in either kernel.

## Quantum-System Comparison

| Physical system | Qubit implementation | Control method | Connection to repository mathematics |
|-----------------|----------------------|----------------|--------------------------------------|
| Superconducting | Transmon / fluxonium | Microwave pulses at millikelvin | Abstract SU(2) rotations |
| Trapped ion | Hyperfine / optical | Laser-driven Raman or optical | Abstract SU(2) rotations |
| Neutral atom | Rydberg or hyperfine | Optical tweezers + Rydberg blockade | Abstract multi-qubit unitaries |
| Photonic | Dual-rail / path | Linear optics + measurement | Abstract unitaries on bosonic modes |
| Annealing | Flux qubits | Schedule of Ising couplings | Not used by the certificate chain |

The repository mathematics addresses the density of discrete gate sets inside continuous unitary groups. It does not depend on the physical encoding that realizes those unitaries.

## IMAGE MANIFEST (partial)

Authentic photographs that could be obtained under verified reuse terms are stored under `docs/assets/quantum/`. Generated mathematical diagrams that require only the structures present in the source (Bloch sphere geometry for SU(2), braid generators, amplitude recurrence plots) were not produced in this pass because image generation failed; no synthetic substitutes labeled as photographs or as computed experimental results have been inserted. See `docs/assets/IMAGE_MANIFEST.md` for the assets that are present.


## Certificate Chain Operations

| Operation | Input | Transformation | Output | Evidence |
|-----------|-------|----------------|--------|----------|
| SU(2) density refutation | Substrate flag `su2_is_projective_clifford_24` | Identity on Boolean | Boolean | production/qubit_cert/src/lib.rs |
| PU(22) density | Substrate flag `pu22_dense` | Identity on Boolean | Boolean | same |
| PU(576) machine-checked | Conjunction of three flags | Logical AND | Boolean | same |
| PU(576) classical | Conjunction of two lemmas | Logical AND | Boolean | same |
| Overall predicate | All preceding Booleans + range check | Logical AND | Boolean | same |
| Dictionary record | Implicit by construction | Constant true | Boolean | same |
| Deduplication metric | Floating-point ratio | Range membership test | Boolean | same |

No matrix multiplications, group presentations, or number-theoretic computations appear in the production kernel. The Boolean flags are the complete representation of the certificates inside the executable code.

## Language and Runtime Inventory

| Language | Component | Responsibility | Dependencies |
|----------|-----------|----------------|--------------|
| Rust | Grover exact | Rational amplitude iteration | num-bigint, num-rational |
| Rust | Qubit certificate | Pure Boolean composition | none |
| Rust | OpenQASM parser | Recursive-descent subset | none |
| Fortran 2018 | SKL lexer/parser | Tokenization and AST construction | gfortran |
| Fortran 2018 | Functor runtime | Dispatch of three native procedures | gfortran |
| C99 | State-vector simulator | Complex amplitude evolution | libm |
| Gherkin | Specifications | Scenario descriptions | none (text) |
| Markdown | Mathematical constructions | Documentation of certificates and lemmas | none |

## Additional Mathematical Notes

The optimal Grover iteration count is obtained by an integer square-root approximation of a scaled \(\pi^2/16\). The constant `6168502750680849` represents \(\pi^2/16\) scaled by \(10^{16}\). The subsequent Newton iteration yields an integer that, after division by \(10^8\), approximates \(\lfloor\pi/4\sqrt{N}\rfloor\). The amplitude recurrence itself uses only field operations on the rationals and never leaves the two-dimensional subspace spanned by the target and the uniform superposition over the remaining states.

The content-address function \(\kappa\) is supplied by an external substrate crate. Inside the benchmark the only observable is the cardinality of the set of distinct addresses. The base amplitude vector is an arbitrary integer vector of length equal to the number of topological classes; its concrete values do not affect the reported elision ratio beyond determining which addresses appear.

The SKL type system currently recognizes only the single type constructor `VECTOR[F64]`. No other numeric types, matrices, or user-defined records are parsed. Pipeline verification is a syntactic keyword; the runtime does not evaluate `REQUIRES` or `ENSURES` expressions.

These boundaries are explicit in the source. The documentation records them so that later extensions can be distinguished from the present implementation.

## Files Changed

- README.md (this document, expanded from the original short form)
- docs/assets/quantum/02-trapped-ion-system.jpg (public-domain NIST photograph of ion-trap apparatus)

No source files under algorithms/, production/, just-gherkin-fortran/, or openqasm/ were modified.

