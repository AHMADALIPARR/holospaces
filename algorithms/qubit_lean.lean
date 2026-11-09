/-
  Holospaces / Qubit Certificate Chain — Lean 4 formalisation skeleton
  Mirrors the production kernel in production/qubit_cert/src/lib.rs

  The production executable is pure Boolean composition of substrate flags.
  This file records the corresponding propositions and the exact Grover
  amplitude recurrence as a computable function over rationals.
-/

import Mathlib.Data.Rat.Basic
import Mathlib.Data.Nat.Basic
import Mathlib.Tactic

namespace Holospaces

/-- Substrate description matching the Rust production kernel. -/
structure Substrate where
  su2_is_projective_clifford_24 : Bool
  pu22_dense                    : Bool
  pu576_adjoint_ok              : Bool
  pu576_rank92_ok               : Bool
  pu576_ent_witness_ok          : Bool
  mult_one_closure              : Bool
  two_local_comp                : Bool
  dedup_ratio                   : ℚ

/-- Certificate chain result matching CertChainResult in the Rust kernel. -/
structure CertChainResult where
  su2_density_refuted      : Bool
  pu22_density_established : Bool
  pu576_machine_ok         : Bool
  pu576_classical_ok       : Bool
  dict_valid               : Bool
  dedup_in_range           : Bool
  overall                  : Bool

/-- Pure evaluation of the certificate chain.
    Direct transcription of Substrate::evaluate in production/qubit_cert. -/
def evaluate (s : Substrate) : CertChainResult :=
  let su2_refuted := s.su2_is_projective_clifford_24
  let pu22        := s.pu22_dense
  let machine     := s.pu576_adjoint_ok && s.pu576_rank92_ok && s.pu576_ent_witness_ok
  let classical   := s.mult_one_closure && s.two_local_comp
  let dict        := true
  let dedup       := 0 ≤ s.dedup_ratio ∧ s.dedup_ratio ≤ 1
  let overall     := su2_refuted && pu22 && machine && classical && dict && dedup
  { su2_density_refuted      := su2_refuted
    pu22_density_established := pu22
    pu576_machine_ok         := machine
    pu576_classical_ok       := classical
    dict_valid               := dict
    dedup_in_range           := dedup
    overall                  := overall }

/-- Proposition: the overall certificate holds. -/
def Qubit (s : Substrate) : Prop :=
  (evaluate s).overall = true

/-- Exact Grover amplitude coefficients (target / non-target) as rationals.
    Mirrors the two-dimensional subspace evolution in algorithms/grover_exact.rs. -/
structure GroverAmplitudes where
  a_t : ℚ   -- target coefficient
  a_u : ℚ   -- uniform non-target coefficient

/-- One Oracle + Diffuser step on the two-coefficient subspace. -/
def groverStep (n : ℕ) (amps : GroverAmplitudes) : GroverAmplitudes :=
  let a_t := -amps.a_t
  let a_u := amps.a_u
  let mean := (a_t + (n - 1 : ℚ) * a_u) / (n : ℚ)
  { a_t := 2 * mean - a_t
    a_u := 2 * mean - a_u }

/-- Iterate the exact recurrence `iters` times starting from uniform amplitudes. -/
def groverIterate (n iters : ℕ) : GroverAmplitudes :=
  let init : GroverAmplitudes := { a_t := 1, a_u := 1 }
  (List.range iters).foldl (fun a _ => groverStep n a) init

/-- For n = 8 (3 qubits) and the optimal 2 iterations the target probability is 121/128.
    This is the same assertion present in the Rust unit test. -/
theorem grover_3qubit_probability :
    let amps := groverIterate 8 2
    let p := amps.a_t * amps.a_t / 8
    p = (121 : ℚ) / 128 := by
  native_decide

/-- The production kernel treats the SU(2) flag as a direct refutation.
    We record the intended mathematical content as a proposition, not a proof
    of density (the executable never computes the group order). -/
def su2_refutation_intent (s : Substrate) : Prop :=
  s.su2_is_projective_clifford_24 = true →
    (evaluate s).su2_density_refuted = true

theorem su2_refutation_holds (s : Substrate) : su2_refutation_intent s := by
  intro h
  simp [su2_refutation_intent, evaluate, h]

end Holospaces
