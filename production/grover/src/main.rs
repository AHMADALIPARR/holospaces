use grover_exact::GroverSolver;

fn main() {
    let solver = GroverSolver::new(3);
    match solver.execute_exact_witness(5) {
        Ok(r) => {
            println!("Qubits: {}", r.num_qubits);
            println!("Target: {}", r.target_state);
            println!("Iterations: {}", r.iterations);
            println!("Target coeff: {}", r.target_amplitude_coeff);
            println!("Non-target coeff: {}", r.non_target_amplitude_coeff);
        }
        Err(e) => eprintln!("Error: {}", e),
    }
}
