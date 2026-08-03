"""Transfer-matrix (characteristic matrix) optics engine.

Ported from the original MATLAB App Designer app (CMatrices.m, DS_DBR.m,
DS_Microcavity.m, Reflectivity_calc.m, Stack_field_profile.m,
Lambda_Resonance.m). A dielectric stack is represented by three parallel
1D arrays of length N+2: refractive index ``n``, thickness ``d``, and angle
of refraction ``theta``, where index 0 is the incident medium and index
N+1 is the exit medium.

Note on fidelity: the original ``CMatrices.m`` has a parenthesization typo
in the s-polarization transmission coefficient
(``n(m)*cos(theta(m)+n(m+1)*cos(theta(m+1)))``). It is fixed here to
``n(m)*cos(theta(m)) + n(m+1)*cos(theta(m+1))``. This does not change any
simulation output: the per-layer ``1/t`` factor is a wavelength-independent
scalar that cancels out of the ``S21/S11`` ratio used everywhere in this
app, and the field-profile code path never calls this function at
non-normal incidence.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

C_LIGHT = 299_792_458.0  # m/s, matches MATLAB physconst('LightSpeed')


def matlab_colon(start: float, step: float, stop: float) -> np.ndarray:
    """Reproduce MATLAB's ``start:step:stop`` (inclusive endpoint)."""
    n = int(np.floor((stop - start) / step + 1e-9)) + 1
    n = max(n, 0)
    return start + step * np.arange(n)


@dataclass
class Stack:
    n: np.ndarray
    d: np.ndarray
    theta: np.ndarray
    N: int


def build_dbr_stack(theta_i, n_i, n_f, n1, n2, N, d1, d2) -> Stack:
    """Port of DS_DBR.m. Layers alternate n2, n1, n2, n1, ... starting
    next to the incident medium (MATLAB layer index 2 gets n1)."""
    n = np.zeros(N + 2)
    d = np.zeros(N + 2)
    theta = np.zeros(N + 2)
    n[0] = n_i
    theta[0] = theta_i
    for m in range(2, N + 2):  # MATLAB 1-based layer index m = 2..N+1
        if m % 2 == 0:
            n[m - 1] = n1
            d[m - 1] = d1
        else:
            n[m - 1] = n2
            d[m - 1] = d2
        theta[m - 1] = np.arcsin(n_i / n[m - 1] * np.sin(theta_i))
    n[N + 1] = n_f
    theta[N + 1] = np.arcsin(n_i / n_f * np.sin(theta_i))
    return Stack(n=n, d=d, theta=theta, N=N)


def build_microcavity_stack(
    theta_i, n_i, n_f,
    d1_n1, d1_n2, d1_N, d1_d1, d1_d2,
    n_c, d_c,
    d2_n1, d2_n2, d2_N, d2_d1, d2_d2,
) -> Stack:
    """Port of DS_Microcavity.m: DBR1 - cavity layer - DBR2."""
    N = d1_N + d2_N + 1
    n = np.zeros(N + 2)
    d = np.zeros(N + 2)
    theta = np.zeros(N + 2)
    n[0] = n_i
    theta[0] = theta_i

    for m in range(2, d1_N + 2):
        if m % 2 == 0:
            n[m - 1] = d1_n1
            d[m - 1] = d1_d1
        else:
            n[m - 1] = d1_n2
            d[m - 1] = d1_d2
        theta[m - 1] = np.arcsin(n_i / n[m - 1] * np.sin(theta_i))

    n[d1_N + 1] = n_c
    d[d1_N + 1] = d_c
    theta[d1_N + 1] = np.arcsin(n_i / n_c * np.sin(theta_i))

    for m in range(d1_N + 3, N + 2):
        if m % 2 == 0:
            n[m - 1] = d2_n1
            d[m - 1] = d2_d1
        else:
            n[m - 1] = d2_n2
            d[m - 1] = d2_d2
        theta[m - 1] = np.arcsin(n_i / n[m - 1] * np.sin(theta_i))

    n[N + 1] = n_f
    theta[N + 1] = np.arcsin(n_i / n_f * np.sin(theta_i))
    return Stack(n=n, d=d, theta=theta, N=N)


def characteristic_matrices(stack: Stack, wavelength):
    """Port of CMatrices.m, vectorized over wavelength.

    Returns (Ss, Sp): complex arrays of shape (nLambda, 2, 2).
    """
    n, d, theta, N = stack.n, stack.d, stack.theta, stack.N
    wavelength = np.atleast_1d(np.asarray(wavelength, dtype=float))
    n_lambda = wavelength.size

    Ss = np.tile(np.eye(2, dtype=complex), (n_lambda, 1, 1))
    Sp = np.tile(np.eye(2, dtype=complex), (n_lambda, 1, 1))

    for m in range(N + 1):  # MATLAB m = 1..N+1, here 0-based m = 0..N
        delta_m = (2 * np.pi / wavelength) * n[m] * d[m] * np.cos(theta[m])
        exp_pos = np.exp(1j * delta_m)
        exp_neg = np.exp(-1j * delta_m)

        # s polarization
        rms = (n[m] * np.cos(theta[m]) - n[m + 1] * np.cos(theta[m + 1])) / (
            n[m] * np.cos(theta[m]) + n[m + 1] * np.cos(theta[m + 1])
        )
        tms = (2 * n[m] * np.cos(theta[m])) / (
            n[m] * np.cos(theta[m]) + n[m + 1] * np.cos(theta[m + 1])
        )
        Sms = np.empty((n_lambda, 2, 2), dtype=complex)
        Sms[:, 0, 0] = (1 / tms) * exp_pos
        Sms[:, 0, 1] = (rms / tms) * exp_pos
        Sms[:, 1, 0] = (rms / tms) * exp_neg
        Sms[:, 1, 1] = (1 / tms) * exp_neg

        # p polarization
        rmp = (n[m] * np.cos(theta[m + 1]) - n[m + 1] * np.cos(theta[m])) / (
            n[m] * np.cos(theta[m + 1]) + n[m + 1] * np.cos(theta[m])
        )
        tmp = (2 * n[m] * np.cos(theta[m])) / (
            n[m] * np.cos(theta[m + 1]) + n[m + 1] * np.cos(theta[m])
        )
        Smp = np.empty((n_lambda, 2, 2), dtype=complex)
        Smp[:, 0, 0] = (1 / tmp) * exp_pos
        Smp[:, 0, 1] = (rmp / tmp) * exp_pos
        Smp[:, 1, 0] = (rmp / tmp) * exp_neg
        Smp[:, 1, 1] = (1 / tmp) * exp_neg

        Ss = Ss @ Sms
        Sp = Sp @ Smp

    return Ss, Sp


def reflectivity(stack: Stack, wavelength, theta_Ei):
    """Port of Reflectivity_calc.m. Returns (Rs, Rp, R)."""
    Ss, Sp = characteristic_matrices(stack, wavelength)
    rs = Ss[:, 1, 0] / Ss[:, 0, 0]
    rp = Sp[:, 1, 0] / Sp[:, 0, 0]
    Rs = np.abs(rs) ** 2
    Rp = np.abs(rp) ** 2
    R = Rs * np.sin(theta_Ei) ** 2 + Rp * np.cos(theta_Ei) ** 2
    return Rs, Rp, R


def lambda_resonance(stack: Stack, lambda_c_theta, theta_Ei):
    """Port of Lambda_Resonance.m: resonance wavelength = reflectivity
    minimum searched over [lambda_c_theta, lambda_c_theta + 30] nm."""
    wavelength = matlab_colon(lambda_c_theta, 0.01, lambda_c_theta + 30)
    Rs, Rp, R = reflectivity(stack, wavelength, theta_Ei)
    return wavelength[np.argmin(Rs)], wavelength[np.argmin(Rp)], wavelength[np.argmin(R)]


def field_profile(stack: Stack, lambda_c, Ei, t):
    """Port of Stack_field_profile.m: electric field profile E(x) at time t
    (normal-incidence standing-wave construction from the characteristic
    matrix reflection coefficient)."""
    n, N = stack.n, stack.N
    d = stack.d.copy()
    d[N + 1] = 2 * lambda_c  # extend exit medium for plotting only

    w = C_LIGHT * 2 * np.pi / lambda_c
    E = np.zeros((2, N + 2), dtype=complex)

    normal_stack = Stack(n=n, d=d, theta=np.zeros(N + 2), N=N)
    S, _ = characteristic_matrices(normal_stack, lambda_c)
    S = S[0]
    r = S[1, 0] / S[0, 0]
    E[0, 0] = Ei
    E[1, 0] = r * E[0, 0]

    xi = matlab_colon(-2 * lambda_c, lambda_c / 4000, 0)
    k = 2 * np.pi / lambda_c * n[0]
    yi = np.real((E[0, 0] * np.exp(-1j * k * xi) + E[1, 0] * np.exp(1j * k * xi)) * np.exp(1j * w * t))

    x_parts = [xi]
    y_parts = [yi]
    l = 0.0
    for m in range(1, N + 2):  # MATLAB 1-based m = 1..N+1
        step = d[m] / 1000 if d[m] > 0 else 1.0
        xm = matlab_colon(l, step, d[m] + l)
        k = 2 * np.pi / lambda_c * n[m]
        delta_m = (2 * np.pi / lambda_c) * n[m - 1] * d[m - 1]
        rm = (n[m - 1] - n[m]) / (n[m - 1] + n[m])
        tm = (2 * n[m - 1]) / (n[m - 1] + n[m])
        Sm = np.array(
            [
                [(1 / tm) * np.exp(1j * delta_m), (rm / tm) * np.exp(1j * delta_m)],
                [(rm / tm) * np.exp(-1j * delta_m), (1 / tm) * np.exp(-1j * delta_m)],
            ]
        )
        E[:, m] = np.linalg.solve(Sm, E[:, m - 1])
        ym = np.real(
            (E[0, m] * np.exp(-1j * k * xm) * np.exp(1j * k * l) + E[1, m] * np.exp(1j * k * xm) * np.exp(-1j * k * l))
            * np.exp(1j * w * t)
        )
        l += d[m]
        x_parts.append(xm)
        y_parts.append(ym)

    return np.concatenate(x_parts), np.concatenate(y_parts)
