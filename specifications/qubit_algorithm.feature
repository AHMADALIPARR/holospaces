Feature: Qubit algorithm correctness on content-addressed substrate

  Background:
    Given a verified library providing:
      | su2_density_refuted |
      | pu22_density_established |
      | adjoint_ok |
      | rank92_ok |
      | ent_witness_ok |
      | mult_one_closure |
      | two_local_comp |
      | dict_row_record |
      | cache_collapse |
      | trace_source |

  Scenario: SU(2) density is refuted, PU(22) and PU(576) densities established
    Given a substrate S_SU2 that encodes the finite projective Clifford group of order 24 over Q(ζ₂₄)
    When su2_density_refuted(S_SU2) is evaluated
    Then the result is false
    And trace_source(su2_density_refuted) points to the SU(2) source

  Scenario: PU(22) density established
    Given a substrate S_PU22 that satisfies the PU(22) density condition
    When pu22_density_established(S_PU22) is evaluated
    Then the result is true
    And trace_source(pu22_density_established) points to the PU(22) source

  Scenario: PU(576) machine‑checked certificates hold
    Given a substrate S_PU576_M that passes adjoint, rank‑92, and entangling witness checks
    When adjoint_ok(S_PU576_M) is evaluated
      And rank92_ok(S_PU576_M) is evaluated
      And ent_witness_ok(S_PU576_M) is evaluated
    Then each result is true
    And each trace_source points to its respective machine‑checked source

  Scenario: PU(576) classical lemmas hold
    Given a substrate S_PU576_C that satisfies multiplicity‑one closure and two‑local composition
    When mult_one_closure(S_PU576_C) is evaluated
      And two_local_comp(S_PU576_C) is evaluated
    Then each result is true
    And each trace_source points to its classical lemma source

  Scenario: Dictionary rows recorded correctly
    Given a substrate S_Dict that distinguishes SU(2) refutation from PU(22)/PU(576) establishment
    When dict_row_record(S_Dict) is evaluated
    Then the resulting dictionary contains a row for each of the three blocks
      And each row’s annotation matches the source‑provided distinction

  Scenario: Deduplication metric is within engineering bounds
    Given any substrate S_Dedup
    When cache_collapse(S_Dedup) is evaluated
    Then the result is a real number r such that 0.0 ≤ r ≤ 1.0
    And no claim of quantum advantage is derived from r

  Scenario: Full Qubit predicate succeeds on a compliant substrate
    Given a substrate S_Full that simultaneously satisfies all prior conditions
    When Qubit(S_Full) is evaluated
    Then the result is true
```

Each step maps directly to a primitive or sub‑routine defined earlier; no step introduces unverified behavior.

---

**Known‑Method Collision Analysis**

| Known Method | Similarity | Difference |
|--------------|------------|------------|
| Standard quantum process tomography (QPT) | Both aim to certify properties of quantum operations. | Qubit does **not** reconstruct a process matrix; it works purely with logical certificates and content‑addressed hashes, without any tomographic measurement. |
| Clifford‑group simulation (Gottesman‑Knill) | Uses the fact that the Clifford group is efficiently simulable. | Qubit’s SU(2) block specifically references the *finite projective* Clifford group of order 24 over ℚ(ζ₂₄) – a number‑theoretic twist not present in ordinary stabilizer simulations. |
| Universal gate set synthesis (Solovay‑Kitaev) | Concerns density of gate sets in SU(N). | Qubit treats density as a *certificate* that is either refuted or established per block, rather than approximating arbitrary unitaries. The algorithm never performs synthesis; it only checks pre‑existing certificates. |
| Content‑addressed storage deduplication (e.g., Git, IPFS) | Measures cache‑collapse ratios. | Here the deduplication metric is **purely observational**; Qubit makes no claim that the metric influences quantum advantage, unlike proposals that link storage efficiency to quantum speed‑up. |
| Proof‑carrying hardware / certified compilation | Attaches proofs to binaries. | Qubit attaches *certificates* to *data blobs* via the substrate, but the certificates are about algebraic density properties, not functional correctness of compiled code. |

No existing algorithm matches the exact combination of:

* a **refutation** certificate on a number‑theoretic SU(2) block,  
* **establishment** certificates on PU(22) and PU(576) blocks built from both machine‑checked and classical lemmas,  
* a **dictionary** recording per‑row distinctions, and  
* an **engineering‑only** deduplication measurement, all under strict source‑traceability.

Hence the construction is **not obviously equivalent** to any known method.

---

**Novelty Status**

**POSSIBLY_NOVEL** – The assembled certificate chain and its logical composition have not been identified in the surveyed literature (standard QPT, Clifford simulation, Solovay‑Kitaev, deduplication schemes, or proof‑carrying systems). However, a definitive novelty claim would require an independent expert review of the cited sources to ensure no overlooked precedent exists. Until such verification, we conservatively label the status as *possibly novel*.

---
### JUST + Gherkin + Fortran Functor Stack

Build a deterministic, specification-driven development stack combining:

* JUST: command orchestration, build recipes, execution contracts.

* Gherkin: executable behavioral specifications using `Feature`, `Scenario`, `Given`, `When`, `Then`, `And`, and `But`.

* Fortran Functors: typed computational units, procedure-pointer dispatch, stateful and stateless operations.

* Custom Syntax Engine: a native Fortran lexer, parser, AST, semantic analyzer, and execution engine.

* Verification Runtime: deterministic execution, invariant checking, trace generation, and reproducible test results.

The central design principle:

Gherkin describes behavior. JUST orchestrates execution. Fortran functors perform computation. The custom syntax engine controls how everything is interpreted.

### 1\. Architecture

JUST COMMAND LAYER

Build · Test · Parse · Verify · Execute

GHERKIN SPECIFICATION LAYER

Features · Scenarios · Steps · Assertions

CUSTOM SYNTAX ENGINE

Lexer · Parser · AST · Semantic Analysis

FUNCTOR REGISTRY

Typed dispatch · Contracts

FORTRAN RUNTIME

Numerics · State · Execution

VERIFICATION AND RECEIPTS

Assertions · Execution traces · Deterministic results

### 2\. Project structure

```text
just-gherkin-fortran/
│
├── justfile
├── README.md
│
├── specifications/
│ ├── features/
│ │ ├── functor_execution.feature
│ │ ├── syntax_validation.feature
│ │ └── deterministic_execution.feature
│ │
│ └── grammar/
│ └── snapkitty.grammar
│
├── syntax/
│ ├── lexer.f90
│ ├── token_types.f90
│ ├── parser.f90
│ ├── ast.f90
│ ├── semantic_analyzer.f90
│ └── syntax_errors.f90
│
├── functors/
│ ├── functor_types.f90
│ ├── functor_registry.f90
│ ├── arithmetic_functors.f90
│ ├── logical_functors.f90
│ └── composition.f90
│
├── runtime/
│ ├── execution_engine.f90
│ ├── execution_context.f90
│ └── verification.f90
│
├── gherkin/
│ ├── feature_loader.f90
│ ├── step_registry.f90
│ └── scenario_runner.f90
│
├── tests/
│ ├── unit/
│ └── integration/
│
└── build/
```

### 3\. Custom language syntax

Create a small domain-specific language called `SKL` (SnapKitty Kernel Language).

Example:

```text
MODULE arithmetic

FUNCTOR ADD
    INPUT : VECTOR[F64]
    OUTPUT : VECTOR[F64]
    OPERATION:
        RESULT = LEFT + RIGHT
    END
END

FUNCTOR NORMALIZE
    INPUT : VECTOR[F64]
    OUTPUT : VECTOR[F64]
    REQUIRES:
        NORM(INPUT) > 0
    OPERATION:
        RESULT = INPUT / NORM(INPUT)
    ENSURES:
        NORM(RESULT) ~= 1.0
    END
END

PIPELINE COMPUTE
    APPLY ADD
    APPLY NORMALIZE
    VERIFY ALL
END
```

The syntax engine must support:

| Feature | Responsibility |
| ----------------- | -------------------------------------- |
| Lexer | Tokenization |
| Parser | Grammar recognition |
| AST | Typed syntax representation |
| Semantic analyzer | Type and contract checking |
| Functor resolver | Resolve named computational units |
| Runtime | Execute validated operations |
| Verifier | Check preconditions and postconditions |

Important: SKL is not a text substitution layer. It must construct an AST and reject invalid programs before execution.

### 4\. Fortran functor implementation

Use Fortran 2018 procedure pointers and derived types.

`functors/functor_types.f90`

```fortran
module functor_types
    use iso_fortran_env, only: real64
    implicit none
    private

    public :: functor_type
    public :: functor_interface

    abstract interface
        subroutine functor_interface(input, output, status)
            import real64
            real(real64), intent(in) :: input(:)
            real(real64), allocatable, intent(out) :: output(:)
            integer, intent(out) :: status
        end subroutine
    end interface

    type :: functor_type
        character(len=64) :: name = ""
        procedure(functor_interface), pointer, nopass :: &
            invoke => null()
    end type

end module functor_types
```

`functors/arithmetic_functors.f90`

```fortran
module arithmetic_functors
    use iso_fortran_env, only: real64
    implicit none
    private

    public :: add_vectors
    public :: normalize_vector

contains

    subroutine add_vectors(input, output, status)
        real(real64), intent(in) :: input(:)
        real(real64), allocatable, intent(out) :: output(:)
        integer, intent(out) :: status

