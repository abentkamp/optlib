import linear_algebra.matrix.pos_def

namespace matrix
variables {𝕜 : Type*} [is_R_or_C 𝕜] {m n : Type*} [fintype m] [fintype n]
open_locale matrix

/-- A matrix `M : matrix n n 𝕜` is positive semidefinite if it is hermitian
   and `xᴴMx` is nonnegative for all `x`. -/
def pos_semidef (M : matrix n n 𝕜) :=
M.is_hermitian ∧ ∀ x : n → 𝕜, 0 ≤ is_R_or_C.re (dot_product (star x) (M.mul_vec x))

lemma pos_def.pos_semidef {M : matrix n n 𝕜} (hM : M.pos_def) : M.pos_semidef :=
begin
  refine ⟨hM.1, _⟩,
  intros x,
  by_cases hx : x = 0,
  { simp only [hx, zero_dot_product, star_zero, is_R_or_C.zero_re'] },
  { exact le_of_lt (hM.2 x hx) }
end

lemma pos_semidef.is_hermitian {M : matrix n n 𝕜} (hM : M.pos_semidef) : M.is_hermitian := hM.1

lemma pos_semidef.transpose {M : matrix n n 𝕜} (hM : M.pos_semidef) : Mᵀ.pos_semidef :=
begin
  refine ⟨is_hermitian.transpose hM.1, λ x, _⟩,
  convert hM.2 (star x) using 2,
  rw [mul_vec_transpose, matrix.dot_product_mul_vec, star_star, dot_product_comm]
end

lemma pos_semidef_diagonal [decidable_eq n] {f : n → ℝ} (hf : ∀ i, 0 ≤ f i) :
  (diagonal f).pos_semidef :=
begin
  refine ⟨is_hermitian_diagonal _, _⟩,
  intro x,
  simp only [star, id.def, is_R_or_C.re_to_real],
  apply finset.sum_nonneg',
  intro i,
  rw [mul_vec_diagonal f x i, mul_comm, mul_assoc],
  exact mul_nonneg (hf i) (mul_self_nonneg (x i))
end

-- instance : nontrivial 𝕜 := by apply_instance--infinite.nontrivial 𝕜
instance : is_domain 𝕜 := by apply_instance


-- Replace? seems to have fewer assumptions than `eq_zero_of_mul_vec_eq_zero`
lemma eq_zero_of_mul_vec_eq_zero' {R : Type*} [comm_ring R] [decidable_eq n]
  {M : matrix n n R} (hM : is_unit M.det) (x : n → R) (h : M.mul_vec x = 0) : x = 0 :=
calc
  x = (M⁻¹ ⬝ M).mul_vec x : by rw [nonsing_inv_mul M hM, one_mul_vec]
  ... = 0 : by rw [← mul_vec_mul_vec, h, mul_vec_zero]

lemma pos_def.det_ne_zero [decidable_eq n] {M : matrix n n 𝕜} (hM : M.pos_def) : M.det ≠ 0 :=
begin
  rw ← matrix.nondegenerate_iff_det_ne_zero,
  intros v hv,
  have hv' := hv (star v),
  rw [← star_eq_zero],
  by_contra h,
  have := hM.2 (star v) h,
  rw [star_star, hv'] at this,
  simpa using this,
end

lemma pos_def.nonsingular_inv [decidable_eq n] {M : matrix n n 𝕜} (hM : M.pos_def) :
  M⁻¹.pos_def :=
begin
  refine ⟨sorry, _⟩,
  intros x hx,
  have hMMinv := (mul_nonsing_inv _ (is_unit_iff_ne_zero.2 hM.det_ne_zero)),
  have hMinvdet : M⁻¹.det ≠ 0 := det_ne_zero_of_left_inverse hMMinv,
  have := hM.2 (M⁻¹.mul_vec x) (λ h, hx (eq_zero_of_mul_vec_eq_zero hMinvdet h)),
  rw [mul_vec_mul_vec, hMMinv, one_mul_vec, star_dot_product] at this,
  rw [← is_R_or_C.conj_re],
  exact this
end

-- TODO: move
lemma is_hermitian.conj_transpose_mul_mul (M N : matrix n n 𝕜) (hM : M.is_hermitian) :
  (Nᴴ ⬝ M ⬝ N).is_hermitian :=
by simp [is_hermitian, hM.eq, matrix.mul_assoc]

lemma pos_semidef.conj_transpose_mul_mul (M N : matrix n n 𝕜) (hM : M.pos_semidef) :
  (Nᴴ ⬝ M ⬝ N).pos_semidef :=
begin
  refine ⟨hM.1.conj_transpose_mul_mul M N, _⟩,
  intro x,
  convert hM.2 (N.mul_vec x) using 2,
  rw [matrix.mul_assoc, mul_vec_mul_vec, ←mul_vec_mul_vec, dot_product_mul_vec, star_mul_vec]
end

lemma pos_semidef.mul_mul_of_is_hermitian {M N : matrix n n 𝕜}
    (hM : M.pos_semidef) (hN : N.is_hermitian) :
  (N ⬝ M ⬝ N).pos_semidef :=
by { convert hM.conj_transpose_mul_mul M N, exact hN.symm }

lemma pos_semidef.submatrix {M : matrix n n 𝕜} (hM : M.pos_semidef) (e : m ≃ n):
  (M.submatrix e e).pos_semidef :=
begin
  refine ⟨hM.1.submatrix e, λ x, _⟩,
  have : (M.submatrix ⇑e ⇑e).mul_vec x = M.mul_vec (λ (i : n), x (e.symm i)) ∘ e,
  { ext i,
    dsimp only [(∘), mul_vec, dot_product],
    rw finset.sum_bij' (λ i _, e i) _ _ (λ i _, e.symm i);
    simp only [eq_self_iff_true, implies_true_iff, equiv.symm_apply_apply, finset.mem_univ,
      submatrix_apply, equiv.apply_symm_apply] },
  rw this,
  convert hM.2 (λ i, x (e.symm i)) using 3,
  unfold dot_product,
  rw [finset.sum_bij' (λ i _, e i) _ _ (λ i _, e.symm i)];
  simp only [eq_self_iff_true, implies_true_iff, equiv.symm_apply_apply, finset.mem_univ,
    submatrix_apply, equiv.apply_symm_apply, pi.star_apply],
end

@[simp] lemma pos_semidef_submatrix_equiv {M : matrix n n 𝕜} (e : m ≃ n) :
  (M.submatrix e e).pos_semidef ↔ M.pos_semidef :=
⟨λ h, by simpa using h.submatrix e.symm, λ h, h.submatrix _⟩


namespace pos_def

variables {M : matrix n n ℝ} (hM : M.pos_def)
include hM

--TODO: use in `det_pos`
lemma eigenvalues_pos [decidable_eq n] (i : n) : 0 < hM.1.eigenvalues i :=
begin
  rw hM.is_hermitian.eigenvalues_eq,
  apply hM.2 _ (λ h, _),
  have h_det : (hM.is_hermitian.eigenvector_matrix)ᵀ.det = 0,
    from matrix.det_eq_zero_of_row_eq_zero i (λ j, congr_fun h j),
  simpa only [h_det, not_is_unit_zero] using
    is_unit_det_of_invertible hM.is_hermitian.eigenvector_matrixᵀ,
end

end pos_def


namespace pos_semidef

variables {M : matrix n n ℝ} (hM : M.pos_semidef)
include hM

lemma eigenvalues_nonneg [decidable_eq n] (i : n) : 0 ≤ hM.1.eigenvalues i :=
by {rw hM.is_hermitian.eigenvalues_eq, apply hM.2}

end pos_semidef

end matrix
