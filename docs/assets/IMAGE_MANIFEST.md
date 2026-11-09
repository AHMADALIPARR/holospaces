# IMAGE MANIFEST — Holospaces Visual Asset Collection

Every asset under `docs/assets/` with provenance, license, and generation method. Assets that could not be produced under strict authenticity criteria are still listed with explicit status.

## Directory Layout

```
docs/assets/
├── IMAGE_MANIFEST.md
├── quantum/
│   ├── 01-superconducting-processor.jpg
│   ├── 02-trapped-ion-system.jpg
│   ├── 03-neutral-atom-array.jpg
│   ├── 04-photonic-processor.png
│   ├── 05-quantum-annealer.jpg
│   ├── 06-quantum-control.jpg
│   ├── 07-su2-bloch-sphere.png
│   ├── 08-topological-braid.png
│   ├── 09-grover-amplitudes.png
│   ├── 10-state-space-geometry.png
│   ├── 11-pu22-certificate.png
│   ├── 12-pu576-certificate.png
│   ├── 13-topological-degeneracy.png
│   └── 14-holospaces-dag.png
├── architecture/
│   ├── 15-system-architecture.png
│   ├── 16-openqasm-pipeline.png
│   ├── 17-certificate-chain.png
│   └── 18-skl-language.png
└── branding/
    └── 19-holospaces-cover.png
```

---

## GROUP A — Physical Quantum Computing Systems

### IMAGE 01 — Superconducting Quantum Processor
- File: `docs/assets/quantum/01-superconducting-processor.jpg`
- Subject: Google Sycamore quantum processor package (display specimen)
- Type: Authentic photograph
- Original: https://commons.wikimedia.org/wiki/File:Sycamore_Quantum_Chip.jpg
- License: CC BY-SA 4.0 (Coldupnorth)
- Caption: Google Sycamore superconducting quantum processor package. Context only; no repository execution path against hardware.

### IMAGE 02 — Trapped-Ion Quantum Computer
- File: `docs/assets/quantum/02-trapped-ion-system.jpg`
- Subject: NIST ion-trap apparatus (gold chip + copper enclosure)
- Type: Authentic photograph
- License: US public domain (NIST)
- Caption: NIST ion-trap hardware. Context only.

### IMAGE 03 — Neutral-Atom Quantum Array
- File: `docs/assets/quantum/03-neutral-atom-array.jpg`
- Subject: Cloud of ultracold atoms levitated in a magneto-optical trap (related neutral-atom experimental apparatus)
- Type: Authentic photograph
- Original: https://commons.wikimedia.org/wiki/File:Cloud_of_ultracold_atoms_levitated_in_a_magneto-optical_trap.webp
- License: CC BY-SA 4.0 (Balping)
- Caption: Ultracold atoms in a magneto-optical trap / optical cavity apparatus. Representative of neutral-atom platforms; not a fluorescence image of a large tweezer array from any specific experiment in this repository.

### IMAGE 04 — Photonic Quantum Computing
- File: `docs/assets/quantum/04-photonic-processor.png`
- Subject: Schematic of integrated photonic quantum circuit (sources → waveguide interferometers → SNSPDs)
- Type: Generated technical schematic (not a photograph)
- Source: Standard dual-rail / path-encoded photonic architecture literature; no specific device claimed.
- Caption: Illustrative schematic of a photonic integrated circuit for quantum processing. Explicitly not a photograph of any physical chip.

### IMAGE 05 — Quantum Annealing Hardware
- File: `docs/assets/quantum/05-quantum-annealer.jpg`
- Subject: D-Wave 128-qubit processor chip
- Type: Authentic photograph
- License: CC BY 3.0 (D-Wave Systems / Wikimedia)
- Caption: D-Wave 128-qubit quantum annealing processor.

### IMAGE 06 — Quantum Control Instrumentation
- File: `docs/assets/quantum/06-quantum-control.jpg`
- Subject: NIST microwave apparatus used in quantum computing / ion experiments
- Type: Authentic photograph (public domain)
- Original: NIST / PublicDomainFiles
- License: US public domain (NIST)
- Caption: Composite photograph of microwave apparatus used in NIST quantum experiments. Context for control instrumentation.

---

## GROUP B — Original Mathematical Visualizations

### IMAGE 07 — Bloch Sphere / SU(2)
- File: `docs/assets/quantum/07-su2-bloch-sphere.png`
- Type: Generated
- Source: Standard SU(2)/Bloch geometry consistent with the projective Clifford obstruction for the SU(2) block.

### IMAGE 08 — Topological Braid Compilation
- File: `docs/assets/quantum/08-topological-braid.png`
- Type: Generated
- Source: Braid generators referenced by the OpenQASM-to-braid discussion.

### IMAGE 09 — Grover Amplitude Evolution
- File: `docs/assets/quantum/09-grover-amplitudes.png`
- Type: Generated
- Source: Exact rational recurrence in `algorithms/grover_exact.rs` / `production/grover`.

### IMAGE 10 — Quantum State-Space Geometry
- File: `docs/assets/quantum/10-state-space-geometry.png`
- Type: Generated conceptual diagram
- Source: Projective Hilbert space (CP^{n-1}), normalization, unitary action. Explicitly avoids treating Hilbert-space dimensions as physical spatial axes.

### IMAGE 11 — PU(22) Certificate Structure
- File: `docs/assets/quantum/11-pu22-certificate.png`
- Type: Generated from production kernel
- Source: `production/qubit_cert/src/lib.rs` — `pu22_dense : bool`. No matrix stored; certificate is the Boolean predicate.

### IMAGE 12 — PU(576) Certificate Structure
- File: `docs/assets/quantum/12-pu576-certificate.png`
- Type: Generated from production kernel
- Source: Three machine flags (`pu576_adjoint_ok`, `pu576_rank92_ok`, `pu576_ent_witness_ok`) + two classical lemmas. No 576-dimensional matrix present.

### IMAGE 13 — Topological Degeneracy
- File: `docs/assets/quantum/13-topological-degeneracy.png`
- Type: Generated conceptual
- Source: `algorithms/holospaces_benchmark.rs` — cardinality of distinct κ-labels after braid-word prefix elision. No energy spectrum or topological invariant beyond the set size is recorded.

### IMAGE 14 — Content-Addressed Holospaces DAG
- File: `docs/assets/quantum/14-holospaces-dag.png`
- Type: Generated conceptual dependency graph
- Source: Composition order of the certificate predicates. Illustrative; no serialized DAG object exists in the tree.

---

## GROUP C — Software and Computational Architecture

### IMAGE 15 — Complete Repository Architecture
- File: `docs/assets/architecture/15-system-architecture.png`
- Type: Generated systems diagram from actual directory / language boundaries.

### IMAGE 16 — OpenQASM Compiler Pipeline
- File: `docs/assets/architecture/16-openqasm-pipeline.png`
- Type: Generated from openqasm/ and algorithms/openqasm_compiler.rs.

### IMAGE 17 — Qubit Certificate Verification Flow
- File: `docs/assets/architecture/17-certificate-chain.png`
- Type: Generated from production/qubit_cert Boolean composition.

### IMAGE 18 — SKL Language Engine
- File: `docs/assets/architecture/18-skl-language.png`
- Type: Generated from just-gherkin-fortran/src.

---

## GROUP D — Publication Graphics

### IMAGE 19 — Holospaces Technical Cover
- File: `docs/assets/branding/19-holospaces-cover.png`
- Type: Generated technical monograph cover.

### IMAGE 20 — Integrated Computational Atlas
- Status: Not generated as a separate large-format atlas. The architecture diagram (15) and certificate flow (17) already encode the supported component relationships without inventing edges.

---

## Notes

- All photographic assets carry verified public-domain or Creative Commons licenses.
- Generated diagrams are derived from repository structures or standard mathematical objects referenced by the source; none are presented as experimental results or as photographs of specific hardware.
- SHA-256 digests can be recomputed with `sha256sum docs/assets/**/*.{png,jpg}`.
