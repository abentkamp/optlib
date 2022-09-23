import missing.linear_algebra.matrix.pos_def
import linear_algebra.matrix.ldl
import linear_algebra.matrix.spectrum

namespace finset
open_locale big_operators

lemma one_add_prod_le_prod_one_add {n : Type*} [fintype n] [nonempty n]
  (f : n → ℝ) (hf : ∀ i, 0 ≤ f i) :
  1 + (∏ i, f i) ≤ ∏ i, (1 + f i) :=
begin
classical,
calc
  1 + (∏ i, f i) =
      (∏ (a : n), 1 : ℝ) * ∏ (a : n) in univ \ univ, f a
       + (∏ (a : n) in ∅, 1) * ∏ (a : n) in univ \ ∅, f a : by simp
  ... ≤ ∑ (t : finset n),
          (∏ (a : n) in t, 1 : ℝ) * ∏ (a : n) in univ \ t, f a :
  begin
    convert finset.sum_le_univ_sum_of_nonneg _,
    { rw finset.sum_pair ,
      exact finset.univ_nonempty.ne_empty },
    { simp [hf, prod_nonneg] }
  end
  ... = ∏ i, (1 + f i) : by rw [prod_add, powerset_univ]
end

end finset

namespace matrix
variables {n : Type*} [fintype n] [decidable_eq n] [linear_order n] [locally_finite_order_bot n]
open_locale big_operators
open_locale matrix


-- If A is semidef, then BᵀAB is semidef.
#check pos_semidef.mul_mul_of_is_hermitian
--

#check is_hermitian.eigenvector_matrix

-- -- where μ i are the eigenvalues of A.sqrt⁻¹ ⬝ B ⬝ A.sqrt⁻¹

#check is_hermitian.eigenvalues

-- A (1 + A.sqrt⁻¹ ⬝ B ⬝ A.sqrt⁻¹) = A.sqrt ⬝ (A + B) ⬝ A.sqrt⁻¹

#check pos_def.eigenvalues_pos


namespace is_hermitian

variables {𝕜 : Type*} [decidable_eq 𝕜 ] [is_R_or_C 𝕜] {A : matrix n n 𝕜} (hA : A.is_hermitian)

lemma eigenvector_matrix_inv_mul :
  hA.eigenvector_matrix_inv ⬝ hA.eigenvector_matrix = 1 :=
by apply basis.to_matrix_mul_to_matrix_flip

theorem spectral_theorem' :
  hA.eigenvector_matrix ⬝ diagonal (coe ∘ hA.eigenvalues) ⬝ hA.eigenvector_matrixᴴ = A :=
by rw [conj_transpose_eigenvector_matrix, matrix.mul_assoc, ← spectral_theorem, ← matrix.mul_assoc,
    eigenvector_matrix_mul_inv, matrix.one_mul]

end is_hermitian

noncomputable def is_hermitian.sqrt {A : matrix n n ℝ} (hA : A.is_hermitian) : matrix n n ℝ :=
hA.eigenvector_matrix ⬝ matrix.diagonal (λ i, (hA.eigenvalues i).sqrt) ⬝ hA.eigenvector_matrixᵀ

lemma conj_transpose_eq_transpose {m n : Type*} {A : matrix m n ℝ} : Aᴴ = Aᵀ := rfl

@[simp] lemma pos_semidef.sqrt_mul_sqrt {A : matrix n n ℝ} (hA : A.pos_semidef) :
  hA.1.sqrt ⬝ hA.1.sqrt = A :=
calc
  hA.1.sqrt ⬝ hA.1.sqrt =
    hA.1.eigenvector_matrix ⬝ (matrix.diagonal (λ i, (hA.1.eigenvalues i).sqrt)
    ⬝ (hA.1.eigenvector_matrixᵀ ⬝ hA.1.eigenvector_matrix)
    ⬝ matrix.diagonal (λ i, (hA.1.eigenvalues i).sqrt)) ⬝ hA.1.eigenvector_matrixᵀ :
by simp [is_hermitian.sqrt, matrix.mul_assoc]
  ... = A :
begin
  rw [←conj_transpose_eq_transpose, hA.1.conj_transpose_eigenvector_matrix,
    hA.1.eigenvector_matrix_inv_mul, matrix.mul_one, diagonal_mul_diagonal,
    ← hA.1.conj_transpose_eigenvector_matrix],
  convert hA.1.spectral_theorem',
  funext i,
  rw [←real.sqrt_mul (hA.eigenvalues_nonneg i), real.sqrt_mul_self (hA.eigenvalues_nonneg i)],
  refl
end

lemma pos_semidef.sqrt.pos_semidef {A : matrix n n ℝ} (hA : A.pos_semidef) :
  hA.1.sqrt.pos_semidef :=
pos_semidef.conj_transpose_mul_mul _ _
  (pos_semidef_diagonal (λ i, real.sqrt_nonneg (hA.1.eigenvalues i)))

lemma det_add_det_le_det_add [nonempty n] (A B : matrix n n ℝ) (hA : A.pos_def) (hB : B.pos_semidef) :
  A.det + B.det ≤ (A + B).det :=
begin
  let sqrtA := hA.1.sqrt,
  have is_hermitian_sqrtA : sqrtA⁻¹.is_hermitian := sorry,
  have hABA : (sqrtA⁻¹ ⬝ B ⬝ sqrtA⁻¹).pos_semidef,
    from pos_semidef.mul_mul_of_is_hermitian hB is_hermitian_sqrtA,
  have := finset.one_add_prod_le_prod_one_add hABA.1.eigenvalues,
  sorry
  -- A.det + B.det = A.det * (1 + A.sqrt⁻¹ ⬝ B ⬝ A.sqrt⁻¹).det
  -- ... ≤ A.det * (1 + A.sqrt⁻¹ ⬝ B ⬝ A.sqrt⁻¹).det = (A+B).det

end

lemma det_add_det_le_det_add [nonempty n] (A B : matrix n n ℝ) (hA : A.pos_semidef) (hB : B.pos_semidef) :
  A.det + B.det ≤ (A + B).det :=
begin
-- !!! Inverse of square root is only defined for pos_definite matrices !!!
-- --> go through all 4 cases.
end

end matrix
