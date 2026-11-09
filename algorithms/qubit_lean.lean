but the *projective Clifford group* is known to have order 24 when we keep the central `-I` (see e.g. the presentation  
\(\langle X,Z\mid X^4=Z^{24}=I, XZX^{-1}=Z^{-1}\rangle\)). Hence the generated group has exactly 24 elements.  

3. A finite subset of a Lie group cannot be Zariski‑dense unless the group is zero‑dimensional. Since `SU(2)` is 3‑dimensional, the Zariski closure of a finite set is the set itself.  

4. Therefore the closure of `G` is `G ≠ SU(2)`, i.e. `G` is **not** dense. ∎



### Lemma 2 (PU(22) density established)

**Statement.**  
Let `n=22`. Define the *clock* and *shift* matrices  

\[
C = \operatorname{diag}(1,\omega,\omega^2,\dots,\omega^{n-1}),\qquad
S = \begin{pmatrix}
0&1&0&\cdots&0\\
0&0&1&\cdots&0\\
\vdots&&\ddots&\ddots&\vdots\\
0&\cdots&0&0&1\\
1&0&\cdots&0&0
\end{pmatrix},
\]

where \(\omega=e^{2\pi i/n}\). Then the projective group \(\langle C,S\rangle\subset PU(n)\) acts irreducibly on \(\mathbb{C}^n\); by Burnside’s theorem its Zariski closure is the full `PU(n)`, hence it is dense.

**Proof.**  

1. Both `C` and `S` have determinant 1, thus belong to `SU(n)` and consequently to `PU(n)`.  
2. The pair `(C,S)` satisfies the Weyl commutation relation \(SC=\omega CS\). This is the defining relation of the discrete Heisenberg group modulo `n`.  