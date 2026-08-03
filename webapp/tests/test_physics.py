import numpy as np

from physics import (
    Stack,
    build_dbr_stack,
    build_microcavity_stack,
    characteristic_matrices,
    field_profile,
    lambda_resonance,
    matlab_colon,
    reflectivity,
)


def test_matlab_colon_inclusive_endpoint():
    assert np.allclose(matlab_colon(0, 0.5, 2), [0, 0.5, 1.0, 1.5, 2.0])
    assert np.allclose(matlab_colon(1, 1, 1), [1.0])


def test_single_interface_matches_fresnel_normal_incidence():
    ni, nf = 1.0, 1.46
    stack = build_dbr_stack(theta_i=0.0, n_i=ni, n_f=nf, n1=2.0, n2=1.46, N=0, d1=0.0, d2=0.0)
    _, _, R = reflectivity(stack, wavelength=550.0, theta_Ei=0.0)
    expected = ((ni - nf) / (ni + nf)) ** 2
    assert np.isclose(R[0], expected, atol=1e-10)


def test_dbr_reflects_strongly_at_design_wavelength():
    lambda_d = 660.0
    n1, n2 = 2.02, 1.46
    d1, d2 = lambda_d / (4 * n1), lambda_d / (4 * n2)
    stack = build_dbr_stack(theta_i=0.0, n_i=1.0, n_f=1.0, n1=n1, n2=n2, N=21, d1=d1, d2=d2)
    wavelength = matlab_colon(lambda_d - 200, 0.5, lambda_d + 200)
    _, _, R = reflectivity(stack, wavelength, theta_Ei=np.pi / 4)
    center_R = R[np.argmin(np.abs(wavelength - lambda_d))]
    edge_R = R[0]
    assert center_R > 0.99
    assert center_R > edge_R


def test_reflectivity_bounded_between_zero_and_one():
    stack = build_dbr_stack(theta_i=0.3, n_i=1.0, n_f=1.0, n1=2.02, n2=1.46, N=11, d1=80.0, d2=110.0)
    wavelength = matlab_colon(400.0, 1.0, 900.0)
    Rs, Rp, R = reflectivity(stack, wavelength, theta_Ei=np.pi / 4)
    for arr in (Rs, Rp, R):
        assert np.all(arr >= -1e-9)
        assert np.all(arr <= 1 + 1e-9)


def test_microcavity_has_resonance_dip_inside_stopband():
    lambda_c = 660.0
    n1, n2, nc = 2.02, 1.46, 1.46
    d1, d2 = lambda_c / (4 * n1), lambda_c / (4 * n2)
    dc = lambda_c / (2 * nc)
    stack = build_microcavity_stack(
        theta_i=0.0, n_i=1.0, n_f=1.0,
        d1_n1=n1, d1_n2=n2, d1_N=15, d1_d1=d1, d1_d2=d2,
        n_c=nc, d_c=dc,
        d2_n1=n1, d2_n2=n2, d2_N=15, d2_d1=d1, d2_d2=d2,
    )
    _, _, LambdaCR = lambda_resonance(stack, lambda_c, theta_Ei=np.pi / 4)
    assert abs(LambdaCR - lambda_c) < 5.0

    _, _, R_at_resonance = reflectivity(stack, LambdaCR, theta_Ei=np.pi / 4)
    _, _, R_offset = reflectivity(stack, lambda_c - 60, theta_Ei=np.pi / 4)
    assert R_at_resonance[0] < R_offset[0]


def test_field_profile_shape_and_finiteness():
    lambda_c = 660.0
    n1, n2 = 2.02, 1.46
    d1, d2 = lambda_c / (4 * n1), lambda_c / (4 * n2)
    stack = build_dbr_stack(theta_i=0.0, n_i=1.0, n_f=1.0, n1=n1, n2=n2, N=9, d1=d1, d2=d2)
    x, y = field_profile(stack, lambda_c, Ei=5.0, t=0.0)
    assert x.shape == y.shape
    assert x.size > 0
    assert np.all(np.isfinite(y))
    assert np.all(np.diff(x) >= -1e-6)  # x is non-decreasing across concatenated segments


def test_characteristic_matrices_identity_for_zero_length_stack():
    stack = Stack(n=np.array([1.0, 1.0]), d=np.array([0.0, 0.0]), theta=np.array([0.0, 0.0]), N=0)
    Ss, Sp = characteristic_matrices(stack, wavelength=[500.0, 600.0])
    assert np.allclose(Ss, np.eye(2), atol=1e-10)
    assert np.allclose(Sp, np.eye(2), atol=1e-10)
