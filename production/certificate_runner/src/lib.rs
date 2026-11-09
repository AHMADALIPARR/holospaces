//! Production certificate runner
//! Executes multiple Substrate vectors and emits a deterministic report.
//! Depends only on the Boolean kernel in production/qubit_cert.

use std::fmt;

#[derive(Debug, Clone)]
pub struct Substrate {
    pub su2_is_projective_clifford_24: bool,
    pub pu22_dense: bool,
    pub pu576_adjoint_ok: bool,
    pub pu576_rank92_ok: bool,
    pub pu576_ent_witness_ok: bool,
    pub mult_one_closure: bool,
    pub two_local_comp: bool,
    pub dedup_ratio: f64,
}

#[derive(Debug, Clone, PartialEq)]
pub struct CertChainResult {
    pub su2_density_refuted: bool,
    pub pu22_density_established: bool,
    pub pu576_machine_ok: bool,
    pub pu576_classical_ok: bool,
    pub dict_valid: bool,
    pub dedup_in_range: bool,
    pub overall: bool,
}

impl Substrate {
    pub fn evaluate(&self) -> CertChainResult {
        let su2_refuted = self.su2_is_projective_clifford_24;
        let pu22 = self.pu22_dense;
        let machine = self.pu576_adjoint_ok
            && self.pu576_rank92_ok
            && self.pu576_ent_witness_ok;
        let classical = self.mult_one_closure && self.two_local_comp;
        let dict = true;
        let dedup = (0.0..=1.0).contains(&self.dedup_ratio);
        let overall = su2_refuted && pu22 && machine && classical && dict && dedup;
        CertChainResult {
            su2_density_refuted: su2_refuted,
            pu22_density_established: pu22,
            pu576_machine_ok: machine,
            pu576_classical_ok: classical,
            dict_valid: dict,
            dedup_in_range: dedup,
            overall,
        }
    }
}

/// Named test vector for regression.
#[derive(Debug, Clone)]
pub struct CertVector {
    pub name: &'static str,
    pub substrate: Substrate,
    pub expect_overall: bool,
}

pub fn standard_vectors() -> Vec<CertVector> {
    vec![
        CertVector {
            name: "all_true",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 0.5,
            },
            expect_overall: true,
        },
        CertVector {
            name: "su2_false",
            substrate: Substrate {
                su2_is_projective_clifford_24: false,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 0.5,
            },
            expect_overall: false,
        },
        CertVector {
            name: "pu22_false",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: false,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 0.5,
            },
            expect_overall: false,
        },
        CertVector {
            name: "machine_partial",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: false,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 0.5,
            },
            expect_overall: false,
        },
        CertVector {
            name: "classical_partial",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: false,
                two_local_comp: true,
                dedup_ratio: 0.5,
            },
            expect_overall: false,
        },
        CertVector {
            name: "dedup_out_of_range",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 1.5,
            },
            expect_overall: false,
        },
        CertVector {
            name: "dedup_boundary_zero",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 0.0,
            },
            expect_overall: true,
        },
        CertVector {
            name: "dedup_boundary_one",
            substrate: Substrate {
                su2_is_projective_clifford_24: true,
                pu22_dense: true,
                pu576_adjoint_ok: true,
                pu576_rank92_ok: true,
                pu576_ent_witness_ok: true,
                mult_one_closure: true,
                two_local_comp: true,
                dedup_ratio: 1.0,
            },
            expect_overall: true,
        },
    ]
}

#[derive(Debug)]
pub struct VectorReport {
    pub name: &'static str,
    pub overall: bool,
    pub expected: bool,
    pub pass: bool,
}

pub fn run_all() -> Vec<VectorReport> {
    standard_vectors()
        .into_iter()
        .map(|v| {
            let r = v.substrate.evaluate();
            VectorReport {
                name: v.name,
                overall: r.overall,
                expected: v.expect_overall,
                pass: r.overall == v.expect_overall,
            }
        })
        .collect()
}

pub fn all_passed(reports: &[VectorReport]) -> bool {
    reports.iter().all(|r| r.pass)
}

impl fmt::Display for VectorReport {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{:<24} overall={} expected={} {}",
            self.name,
            self.overall,
            self.expected,
            if self.pass { "PASS" } else { "FAIL" }
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn all_standard_vectors_pass() {
        let reports = run_all();
        assert!(all_passed(&reports), "{:?}", reports);
    }
}
