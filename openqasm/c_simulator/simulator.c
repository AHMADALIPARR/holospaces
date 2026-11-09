#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

// ----- Quantum State Representation -----
typedef struct {
    double re[4]; // Real parts of [|00>, |01>, |10>, |11>]
    double im[4]; // Imaginary parts
} StateVec;

// ----- Gate Matrices (Hardcoded per OpenQASM 3 Spec) -----
// H = 1/√2 [[1, 1], [1, -1]] → 4x4 for qubit 0: H ⊗ I
static const double H_RE[4][4] = {
    {0.70710678118, 0, 0.70710678118, 0},
    {0, 0.70710678118, 0, 0.70710678118},
    {0.70710678118, 0, -0.70710678118, 0},
    {0, 0.70710678118, 0, -0.70710678118}
};
static const double H_IM[4][4] = {{0}}; // H is real

// Rz(θ) on qubit j: I ⊗ ... ⊗ Rz(θ) ⊗ ... ⊗ I
// Precomputed for θ in radians (we compute dynamically)
static void apply_rz(StateVec *state, int qubit, double theta) {
    double cos_half = cos(theta / 2.0);
    double sin_half = sin(theta / 2.0);
    double re, im;
    
    for (int i = 0; i < 4; i++) {
        int bit = (qubit == 0) ? ((i >> 1) & 1) : (i & 1); // Extract qubit j's bit
        double phase = (bit == 0) ? cos_half : -cos_half; // e^{-iθ/2} for |0>, e^{iθ/2} for |1>
        double re_old = state->re[i];
        double im_old = state->im[i];
        
        state->re[i] = re_old * phase - im_old * 0; // Rz is real-diagonal
        state->im[i] = re_old * 0 + im_old * phase;
    }
}

// CNOT(control, target): 4x4 matrix (control=0, target=1)
static void apply_cnot(StateVec *state) {
    StateVec temp = {{0}};
    // |00>→|00>, |01>→|01>, |10>→|11>, |11>→|10>
    temp.re[0] = state->re[0]; temp.im[0] = state->im[0];
    temp.re[1] = state->re[1]; temp.im[1] = state->im[1];
    temp.re[2] = state->re[3]; temp.im[2] = state->im[3];
    temp.re[3] = state->re[2]; temp.im[3] = state->im[2];
    *state = temp;
}

// Hadamard on qubit 0: H ⊗ I
static void apply_h(StateVec *state) {
    StateVec temp = {{0}};
    for (int i = 0; i < 4; i++) {
        int col = (i >> 1) * 2; // Column index in H⊗I
        double re_sum = 0, im_sum = 0;
        for (int row = 0; row < 2; row++) {
            int idx = col + row;
            double h_re = H_RE[idx][i];
            double h_im = H_IM[idx][i];
            re_sum += state->re[idx] * h_re - state->im[idx] * h_im;
            im_sum += state->re[idx] * h_im + state->im[idx] * h_re;
        }
        temp.re[i] = re_sum;
        temp.im[i] = im_sum;
    }
    *state = temp;
}

// ----- Klong Parser (Minimal, for :array[int int]) -----
static int* parse_klong_array(const char *filename, int *length) {
    FILE *fp = fopen(filename, "r");
    if (!fp) { perror("Failed to open Klong file"); exit(1); }
    
    fseek(fp, 0, SEEK_END);
    long fsize = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    
    char *buffer = malloc(fsize + 1);
    fread(buffer, 1, fsize, fp);
    buffer[fsize] = '\0';
    fclose(fp);
    
    // Find :array[ ... ]
    char *start = strstr(buffer, ":array[");
    if (!start) { free(buffer); fprintf(stderr, "Invalid Klong format\n"); exit(1); }
    start += 7; // Skip ":array["
    
    char *end = strstr(start, "]");
    if (!end) { free(buffer); fprintf(stderr, "Missing closing bracket\n"); exit(1); }
    *end = '\0';
    
    // Count integers
    int count = 0;
    char *tok = strtok(start, " ");
    while (tok) { count++; tok = strtok(NULL, " "); }
    
    int *result = malloc(count * sizeof(int));
    tok = strtok(start, " ");
    for (int i = 0; i < count; i++) {
        result[i] = atoi(tok);
        tok = strtok(NULL, " ");
    }
    
    free(buffer);
    *length = count;
    return result;
}

// ----- Main Execution -----
int main(void) {
    // 1. Parse Klong array
    int length;
    int *angles_mrad = parse_klong_array("angles.kg", &length);
    if (length < 2) {
        fprintf(stderr, "Need at least 2 angles\n");
        free(angles_mrad);
        return 1;
    }
    
    // 2. Convert milliradians → radians
    double alpha = angles_mrad[0] * (2.0 * M_PI) / 1000.0;
    double beta = angles_mrad[1] * (2.0 * M_PI) / 1000.0;
    free(angles_mrad);
    
    // 3. Initialize |00> state
    StateVec state = { {1.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0} };
    
    // 4. Apply gate sequence (OpenQASM 3 order)
    apply_h(&state); // H q[0]
    apply_rz(&state, 0, alpha); // Rz(α) q[0]
    apply_cnot(&state); // CX q[0],q[1]
    apply_rz(&state, 1, beta); // Rz(β) q[1]
    apply_cnot(&state); // CX q[0],q[1]
    
    // 5. Output final state (for verification)
    printf("Final state:\n");
    for (int i = 0; i < 4; i++) {
        const char *labels[] = {"|00>", "|01>", "|10>", "|11>"};
        printf(" %s: %.6f + %.6fi\n", labels[i], state.re[i], state.im[i]);
    }
    
    return 0;
}
