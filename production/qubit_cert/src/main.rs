use qubit_cert_chain::Substrate;

fn main() {
    let s = Substrate {
        su2_is_projective_clifford_24: true,
        pu22_dense: true,
        pu576_adjoint_ok: true,
        pu576_rank92_ok: true,
        pu576_ent_witness_ok: true,
        mult_one_closure: true,
        two_local_comp: true,
        dedup_ratio: 0.73,
    };
    let r = s.evaluate();
    println!("{:#?}", r);
}
