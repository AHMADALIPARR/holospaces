// Holospaces / Qubit Certificate Chain — Q# implementation
// Mirrors the production Boolean kernel and the exact Grover reference.
// No quantum hardware execution is claimed; all operations are classical
// simulation of the documented certificate flags and amplitude recurrence.

namespace Holospaces {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    /// Substrate flags matching production/qubit_cert/src/lib.rs
    newtype Substrate = (
        Su2IsProjectiveClifford24 : Bool,
        Pu22Dense                 : Bool,
        Pu576AdjointOk            : Bool,
        Pu576Rank92Ok             : Bool,
        Pu576EntWitnessOk         : Bool,
        MultOneClosure            : Bool,
        TwoLocalComp              : Bool,
        DedupRatio                : Double
    );

    /// Result of the certificate chain evaluation.
    newtype CertChainResult = (
        Su2DensityRefuted      : Bool,
        Pu22DensityEstablished : Bool,
        Pu576MachineOk         : Bool,
        Pu576ClassicalOk       : Bool,
        DictValid              : Bool,
        DedupInRange           : Bool,
        Overall                : Bool
    );

    /// Pure evaluation of the certificate chain.
    /// Direct transcription of the Rust Substrate::evaluate method.
    function Evaluate(s : Substrate) : CertChainResult {
        let su2Refuted = s::Su2IsProjectiveClifford24;
        let pu22       = s::Pu22Dense;
        let machine    = s::Pu576AdjointOk and s::Pu576Rank92Ok and s::Pu576EntWitnessOk;
        let classical  = s::MultOneClosure and s::TwoLocalComp;
        let dict       = true;
        let dedup      = (0.0 <= s::DedupRatio) and (s::DedupRatio <= 1.0);
        let overall    = su2Refuted and pu22 and machine and classical and dict and dedup;
        return CertChainResult(
            su2Refuted, pu22, machine, classical, dict, dedup, overall
        );
    }

    /// Exact Grover amplitude coefficients on the two-dimensional subspace.
    newtype GroverAmplitudes = (At : Double, Au : Double);

    /// One Oracle + Diffuser step (classical arithmetic).
    function GroverStep(n : Int, amps : GroverAmplitudes) : GroverAmplitudes {
        let at = -amps::At;
        let au = amps::Au;
        let mean = (at + IntAsDouble(n - 1) * au) / IntAsDouble(n);
        return GroverAmplitudes(2.0 * mean - at, 2.0 * mean - au);
    }

    /// Iterate the recurrence `iters` times from uniform amplitudes.
    function GroverIterate(n : Int, iters : Int) : GroverAmplitudes {
        mutable amps = GroverAmplitudes(1.0, 1.0);
        for _ in 1 .. iters {
            set amps = GroverStep(n, amps);
        }
        return amps;
    }

    /// Reference computation for the 3-qubit case used by the Rust unit test.
    /// Target probability after 2 iterations is 121/128 ≈ 0.9453125.
    function Grover3QubitProbability() : Double {
        let amps = GroverIterate(8, 2);
        return (amps::At * amps::At) / 8.0;
    }

    /// Operation that simply returns the overall certificate Boolean.
    /// No qubits are allocated; this is a classical decision procedure.
    operation QubitCertificate(s : Substrate) : Bool {
        return Evaluate(s)::Overall;
    }

    /// Demonstration entry point that exercises the classical certificate
    /// and the exact Grover amplitude reference.
    @EntryPoint()
    operation RunHolospacesDemo() : Unit {
        let s = Substrate(
            true,   // su2_is_projective_clifford_24
            true,   // pu22_dense
            true,   // pu576_adjoint_ok
            true,   // pu576_rank92_ok
            true,   // pu576_ent_witness_ok
            true,   // mult_one_closure
            true,   // two_local_comp
            0.42    // dedup_ratio
        );
        let result = Evaluate(s);
        Message($"Overall certificate: {result::Overall}");
        Message($"3-qubit Grover target probability: {Grover3QubitProbability()}");
    }
}
