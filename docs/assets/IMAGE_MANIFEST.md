# IMAGE MANIFEST — Holospaces Visual Asset Collection

Complete set of 20 assets as specified by the Visual Engineering Directive.

## Directory Structure

```
docs/assets/
├── quantum/          (01–14)
├── architecture/     (15–18)
└── branding/         (19–20)
```

---

## GROUP A — Physical Quantum Computing Systems

### IMAGE 01 — Superconducting Quantum Processor
- File: `docs/assets/quantum/01-superconducting-processor.jpg`
- Subject: Google Sycamore quantum processor package (display specimen)
- Type: Authentic photograph
- Original URL: https://commons.wikimedia.org/wiki/File:Sycamore_Quantum_Chip.jpg
- Copyright / License: Coldupnorth / CC BY-SA 4.0
- Resolution: 1280 × 960 JPEG
- Caption: Google Sycamore superconducting quantum processor package. Context only; no repository execution path against hardware.
- Intended README section: Quantum Hardware Context

### IMAGE 02 — Trapped-Ion Quantum Computer
- File: `docs/assets/quantum/02-trapped-ion-system.jpg`
- Subject: NIST ion-trap apparatus (gold chip + copper enclosure)
- Type: Authentic photograph
- License: US public domain (NIST)
- Resolution: 1568 × 1070 JPEG
- Caption: NIST ion-trap hardware. Context only.
- Intended README section: Quantum Hardware Context

### IMAGE 03 — Neutral-Atom Quantum Array
- File: `docs/assets/quantum/03-neutral-atom-array.jpg`
- Subject: Cloud of ultracold atoms levitated in a magneto-optical trap (related neutral-atom experimental apparatus)
- Type: Authentic photograph
- Original URL: https://commons.wikimedia.org/wiki/File:Cloud_of_ultracold_atoms_levitated_in_a_magneto-optical_trap.webp
- License: CC BY-SA 4.0 (Balping)
- Resolution: 1280 × 711 JPEG
- Caption: Ultracold atoms in a magneto-optical trap / optical cavity apparatus. Representative of neutral-atom platforms.
- Intended README section: Quantum Hardware Context

### IMAGE 04 — Photonic Quantum Computing
- File: `docs/assets/quantum/04-photonic-processor.jpg`
- Subject: Schematic of integrated photonic quantum circuit (sources → waveguide interferometers → SNSPDs)
- Type: Generated technical schematic (explicitly not a photograph)
- Source: Standard dual-rail / path-encoded photonic architecture
- Resolution: 2862 × 1601 JPEG
- Caption: Illustrative schematic of a photonic integrated circuit. Not a photograph of any physical chip.
- Intended README section: Quantum Hardware Context

### IMAGE 05 — Quantum Annealing Hardware
- File: `docs/assets/quantum/05-quantum-annealer.jpg`
- Subject: D-Wave Systems 128-qubit superconducting adiabatic quantum optimization processor chip
- Type: Authentic photograph
- License: CC BY 3.0 (D-Wave Systems / Wikimedia)
- Resolution: 1280 × 883 JPEG
- Caption: D-Wave 128-qubit quantum annealing processor.
- Intended README section: Quantum Hardware Context

### IMAGE 06 — Quantum Control Instrumentation
- File: `docs/assets/quantum/06-quantum-control.jpg`
- Subject: NIST microwave apparatus used in quantum computing / ion experiments
- Type: Authentic photograph
- License: US public domain (NIST)
- Resolution: 958 × 690 JPEG
- Caption: NIST microwave apparatus. Context for control instrumentation.
- Intended README section: Quantum Hardware Context

---

## GROUP B — Original Mathematical Visualizations

### IMAGE 07 — Bloch Sphere / SU(2)
- File: `docs/assets/quantum/07-su2-bloch-sphere.png`
- Type: Generated
- Source: Standard SU(2)/Bloch geometry consistent with the projective Clifford obstruction for the SU(2) block
- Resolution: 2135 × 2135 PNG

### IMAGE 08 — Topological Braid Compilation
- File: `docs/assets/quantum/08-topological-braid.png`
- Type: Generated
- Source: Braid generators referenced by the OpenQASM-to-braid discussion
- Resolution: 3840 × 2160 PNG

### IMAGE 09 — Grover Amplitude Evolution
- File: `docs/assets/quantum/09-grover-amplitudes.png`
- Type: Generated
- Source: Exact rational recurrence in `algorithms/grover_exact.rs` / `production/grover`
- Resolution: 3840 × 2160 PNG

### IMAGE 10 — Quantum State-Space Geometry
- File: `docs/assets/quantum/10-state-space-geometry.png`
- Type: Generated conceptual diagram
- Source: Projective Hilbert space (CP^{n-1}), normalization, unitary action
- Resolution: 2501 × 1421 PNG

### IMAGE 11 — PU(22) Certificate Structure
- File: `docs/assets/quantum/11-pu22-certificate.png`
- Type: Generated from production kernel
- Source: `production/qubit_cert/src/lib.rs` — `pu22_dense : bool`
- Resolution: 2321 × 1421 PNG

### IMAGE 12 — PU(576) Certificate Structure
- File: `docs/assets/quantum/12-pu576-certificate.png`
- Type: Generated from production kernel
- Source: Three machine flags + two classical lemmas
- Resolution: 2501 × 1421 PNG

### IMAGE 13 — Topological Degeneracy
- File: `docs/assets/quantum/13-topological-degeneracy.png`
- Type: Generated conceptual
- Source: `algorithms/holospaces_benchmark.rs` — κ-label cardinality after braid-word prefix elision
- Resolution: 2321 × 1421 PNG

### IMAGE 14 — Content-Addressed Holospaces DAG
- File: `docs/assets/quantum/14-holospaces-dag.png`
- Type: Generated conceptual dependency graph
- Source: Composition order of the certificate predicates
- Resolution: 2501 × 1601 PNG

---

## GROUP C — Software and Computational Architecture

### IMAGE 15 — Complete Repository Architecture
- File: `docs/assets/architecture/15-system-architecture.png`
- Type: Generated systems diagram from actual directory / language boundaries
- Resolution: 3133 × 1779 PNG

### IMAGE 16 — OpenQASM Compiler Pipeline
- File: `docs/assets/architecture/16-openqasm-pipeline.png`
- Type: Generated from openqasm/ and algorithms/openqasm_compiler.rs
- Resolution: 2501 × 1421 PNG

### IMAGE 17 — Qubit Certificate Verification Flow
- File: `docs/assets/architecture/17-certificate-chain.png`
- Type: Generated from production/qubit_cert Boolean composition
- Resolution: 2501 × 1601 PNG

### IMAGE 18 — SKL Language Engine
- File: `docs/assets/architecture/18-skl-language.png`
- Type: Generated from just-gherkin-fortran/src
- Resolution: 2321 × 1421 PNG

---

## GROUP D — Publication and Repository Graphics

### IMAGE 19 — Holospaces Technical Cover
- File: `docs/assets/branding/19-holospaces-cover.png`
- Type: Generated technical monograph cover
- Resolution: 1785 × 2385 PNG

### IMAGE 20 — Integrated Computational Atlas
- File: `docs/assets/branding/20-quantum-computational-atlas.png`
- Type: Generated systems atlas
- Source: Verified components and relationships present in the repository only; no invented edges
- Resolution: 3179 × 1779 PNG

---

## Acceptance Record

- All 20 target filenames exist and decode successfully.
- No empty assets.
- Photographic assets carry verified public-domain or Creative Commons licenses.
- Generated diagrams are derived from repository structures or standard mathematical objects referenced by the source.
- No synthetic hardware photographs were substituted for authentic ones.
- No fabricated experimental results or invented institutional logos.
