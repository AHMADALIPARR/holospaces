//! Concrete reference implementation of the Qubit certificate chain and
//! exact Grover amplitude evolution.
//! Matches production/qubit_cert and algorithms/grover_exact.rs.

use num_bigint::BigInt;
use num_rational::BigRational;

/// Substrate description (identical fields to production/qubit_cert).
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

/// Result of the certificate chain evaluation.
#[derive(Debug, PartialEq)]
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
    /// Pure evaluation of the certificate chain.
    pub fn evaluate(&self) -> CertChainResult {
        let su2_refuted = self.su2_is_projective_clifford_24;
        let pu22 = self.pu22_dense;
        let machine =
            self.pu576_adjoint_ok && self.pu576_rank92_ok && self.pu576_ent_witness_ok;
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

/// Exact Grover solver (identical arithmetic to algorithms/grover_exact.rs).
pub struct GroverSolver {
    pub num_qubits: usize,
}

#[derive(Debug)]
pub struct ExactGroverReport {
    pub num_qubits: usize,
    pub target_state: usize,
    pub iterations: usize,
    pub target_amplitude_coeff: BigRational,
    pub non_target_amplitude_coeff: BigRational,
}

impl GroverSolver {
    pub fn new(num_qubits: usize) -> Self {
        Self { num_qubits }
    }

    pub fn execute_exact_witness(
        &self,
        target_state: usize,
    ) -> Result<ExactGroverReport, String> {
        let n_states = 1 << self.num_qubits;
        if target_state >= n_states {
            return Err("Target state out of bounds".into());
        }

        // floor(π/4 √N) via scaled integer square-root (no f64)
        let n_states_u128 = n_states as u128;
        let pi_sq_over_16_scaled = 6_168_502_750_680_849u128;
        let iters_scaled_sq = n_states_u128 * pi_sq_over_16_scaled;
        let mut x = iters_scaled_sq;
        let mut y = x.div_ceil(2);
        while y < x {
            x = y;
            y = (x + iters_scaled_sq / x) / 2;
        }
        let iterations = (x / 100_000_000) as usize;

        let mut a_t = BigRational::new(BigInt::from(1), BigInt::from(1));
        let mut a_u = BigRational::new(BigInt::from(1), BigInt::from(1));
        let n_states_bi = BigRational::new(BigInt::from(n_states), BigInt::from(1));
        let n_minus_1_bi = BigRational::new(BigInt::from(n_states - 1), BigInt::from(1));
        let two = BigRational::new(BigInt::from(2), BigInt::from(1));

        for _ in 0..iterations {
            a_t = -a_t;
            let mean = (&a_t + &n_minus_1_bi * &a_u) / &n_states_bi;
            a_t = &two * &mean - a_t;
            a_u = &two * &mean - a_u;
        }

        Ok(ExactGroverReport {
            num_qubits: self.num_qubits,
            target_state,
            iterations,
            target_amplitude_coeff: a_t,
            non_target_amplitude_coeff: a_u,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn certificate_overall_true_when_all_flags_set() {
        let s = Substrate {
            su2_is_projective_clifford_24: true,
            pu22_dense: true,
            pu576_adjoint_ok: true,
            pu576_rank92_ok: true,
            pu576_ent_witness_ok: true,
            mult_one_closure: true,
            two_local_comp: true,
            dedup_ratio: 0.5,
        };
        assert!(s.evaluate().overall);
    }

    #[test]
    fn grover_3qubit_probability() {
        let solver = GroverSolver::new(3);
        let report = solver.execute_exact_witness(5).unwrap();
        let p_t = &report.target_amplitude_coeff * &report.target_amplitude_coeff
            / BigRational::new(BigInt::from(8), BigInt::from(1));
        let expected = BigRational::new(BigInt::from(121), BigInt::from(128));
        assert_eq!(p_t, expected);
    }
}
