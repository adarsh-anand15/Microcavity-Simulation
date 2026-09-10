"""Transfer-matrix physics for DBR / Microcavity reflectivity and field profiles.

Ported from the original MATLAB files (CMatrices.m, DS_DBR.m, DS_Microcavity.m,
Reflectivity_calc.m, Stack_field_profile.m, Lambda_Resonance.m). Arrays here are
kept 1-indexed (index 0 unused) to mirror the MATLAB source directly and avoid
off-by-one translation errors.

Default parameter values below match the ones baked into Microcavity_Simulation.mlapp.
"""
import numpy as np

LIGHT_SPEED = 299792458.0  # m/s, matches MATLAB physconst('LightSpeed')

DBR_DEFAULTS = dict(
    thetai=30.0, Ei=5.0, thetaEi=45.0, ni=1.0, nf=1.0,
    LambdaC=660.0, LambdaD=660.0, n1=2.02, n2=1.46, N=21,
)

MICROCAVITY_DEFAULTS = dict(
    thetai=30.0, Ei=5.0, thetaEi=45.0, ni=1.0, nf=1.0, LambdaC=660.0,
    LambdaD1=660.0, D1_n1=2.02, D1_n2=1.46, D1_N=21,
    LambdaD2=660.0, D2_n1=2.02, D2_n2=1.46, D2_N=21,
    LambdaDc=660.0, nc=1.46,
)


class Stack:
    """1-indexed layer stack: n, d, theta have length N+3 (index 0 unused)."""

    def __init__(self, N):
        self.N = N
        self.n = np.zeros(N + 3)
        self.d = np.zeros(N + 3)
        self.theta = np.zeros(N + 3)


def ds_dbr(p):
    """p: dict with thetai(deg), Ei, thetaEi(deg), ni, nf, LambdaC, LambdaD, n1, n2, N."""
    N = int(p['N'])
    thetai = np.radians(p['thetai'])
    s = Stack(N)
    d1 = p['LambdaD'] / (4 * p['n1'])
    d2 = p['LambdaD'] / (4 * p['n2'])
    s.n[1] = p['ni']
    s.d[1] = 0
    s.theta[1] = thetai
    for m in range(2, N + 2):
        if m % 2 == 0:
            s.n[m] = p['n1']
            s.d[m] = d1
        else:
            s.n[m] = p['n2']
            s.d[m] = d2
        s.theta[m] = np.arcsin(p['ni'] / s.n[m] * np.sin(thetai))
    s.n[N + 2] = p['nf']
    s.d[N + 2] = 0
    s.theta[N + 2] = np.arcsin(p['ni'] / p['nf'] * np.sin(thetai))
    return s, d1, d2


def ds_microcavity(p):
    """p: dict with thetai(deg), Ei, thetaEi(deg), ni, nf, LambdaC,
    LambdaD1, D1_n1, D1_n2, D1_N, LambdaD2, D2_n1, D2_n2, D2_N, LambdaDc, nc."""
    thetai = np.radians(p['thetai'])
    D1_N = int(p['D1_N'])
    D2_N = int(p['D2_N'])
    N = D1_N + D2_N + 1
    s = Stack(N)

    D1_d1 = p['LambdaD1'] / (4 * p['D1_n1'])
    D1_d2 = p['LambdaD1'] / (4 * p['D1_n2'])
    D2_d1 = p['LambdaD2'] / (4 * p['D2_n1'])
    D2_d2 = p['LambdaD2'] / (4 * p['D2_n2'])
    dc = p['LambdaDc'] / (2 * p['nc'])

    s.n[1] = p['ni']
    s.d[1] = 0
    s.theta[1] = thetai

    for m in range(2, D1_N + 2):
        if m % 2 == 0:
            s.n[m] = p['D1_n1']
            s.d[m] = D1_d1
        else:
            s.n[m] = p['D1_n2']
            s.d[m] = D1_d2
        s.theta[m] = np.arcsin(p['ni'] / s.n[m] * np.sin(thetai))

    s.n[D1_N + 2] = p['nc']
    s.d[D1_N + 2] = dc
    s.theta[D1_N + 2] = np.arcsin(p['ni'] / p['nc'] * np.sin(thetai))

    for m in range(D1_N + 3, N + 2):
        if m % 2 == 0:
            s.n[m] = p['D2_n1']
            s.d[m] = D2_d1
        else:
            s.n[m] = p['D2_n2']
            s.d[m] = D2_d2
        s.theta[m] = np.arcsin(p['ni'] / s.n[m] * np.sin(thetai))

    s.n[N + 2] = p['nf']
    s.d[N + 2] = 0
    s.theta[N + 2] = np.arcsin(p['ni'] / p['nf'] * np.sin(thetai))
    return s, dict(D1_d1=D1_d1, D1_d2=D1_d2, D2_d1=D2_d1, D2_d2=D2_d2, dc=dc)


def c_matrices(stack, wavelengths):
    """Characteristic (Abeles) matrices for s- and p-polarization.

    wavelengths: 1D array (nm). Returns Ss, Sp of shape (nLambda, 2, 2) complex.
    """
    n, d, theta, N = stack.n, stack.d, stack.theta, stack.N
    nLambda = wavelengths.shape[0]
    Ss = np.tile(np.eye(2, dtype=complex), (nLambda, 1, 1))
    Sp = np.tile(np.eye(2, dtype=complex), (nLambda, 1, 1))

    for m in range(1, N + 2):
        deltam = (2 * np.pi / wavelengths) * n[m] * d[m] * np.cos(theta[m])

        cos_m, cos_m1 = np.cos(theta[m]), np.cos(theta[m + 1])
        rms = (n[m] * cos_m - n[m + 1] * cos_m1) / (n[m] * cos_m + n[m + 1] * cos_m1)
        tms = (2 * n[m] * cos_m) / (n[m] * cos_m + n[m + 1] * cos_m1)

        rmp = (n[m] * cos_m1 - n[m + 1] * cos_m) / (n[m] * cos_m1 + n[m + 1] * cos_m)
        tmp = (2 * n[m] * cos_m) / (n[m] * cos_m1 + n[m + 1] * cos_m)

        exp_pos = np.exp(1j * deltam)
        exp_neg = np.exp(-1j * deltam)

        Sms = np.empty((nLambda, 2, 2), dtype=complex)
        Sms[:, 0, 0] = (1 / tms) * exp_pos
        Sms[:, 0, 1] = (rms / tms) * exp_pos
        Sms[:, 1, 0] = (rms / tms) * exp_neg
        Sms[:, 1, 1] = (1 / tms) * exp_neg

        Smp = np.empty((nLambda, 2, 2), dtype=complex)
        Smp[:, 0, 0] = (1 / tmp) * exp_pos
        Smp[:, 0, 1] = (rmp / tmp) * exp_pos
        Smp[:, 1, 0] = (rmp / tmp) * exp_neg
        Smp[:, 1, 1] = (1 / tmp) * exp_neg

        Ss = np.matmul(Ss, Sms)
        Sp = np.matmul(Sp, Smp)

    return Ss, Sp


def reflectivity_calc(stack, wavelengths, thetaEi_deg):
    """Returns Rs, Rp, R (numpy arrays, same length as wavelengths)."""
    Ss, Sp = c_matrices(stack, wavelengths)
    rs = Ss[:, 1, 0] / Ss[:, 0, 0]
    rp = Sp[:, 1, 0] / Sp[:, 0, 0]
    Rs = np.abs(rs) ** 2
    Rp = np.abs(rp) ** 2
    thetaEi = np.radians(thetaEi_deg)
    R = Rs * np.sin(thetaEi) ** 2 + Rp * np.cos(thetaEi) ** 2
    return Rs, Rp, R


def dbr_reflectivity(p):
    """Returns (Lambda, Rs, Rp, R) for the DBR reflectivity-vs-wavelength plot."""
    stack, _, _ = ds_dbr(p)
    delta_lambda = 400
    Lambda = np.arange(p['LambdaC'] - delta_lambda / 2, p['LambdaC'] + delta_lambda / 2 + 0.5, 0.5)
    Rs, Rp, R = reflectivity_calc(stack, Lambda, p['thetaEi'])
    return Lambda, Rs, Rp, R


def microcavity_reflectivity(p):
    """Returns (Lambda, Rs, Rp, R) for the microcavity reflectivity-vs-wavelength plot."""
    stack, _ = ds_microcavity(p)
    thetai = np.radians(p['thetai'])
    LambdaCtheta = p['LambdaC'] * np.sqrt(1 - p['ni'] ** 2 * np.sin(thetai) ** 2 / p['nc'] ** 2)
    delta_lambda = 300

    coarse_lo = np.arange(p['LambdaC'] - delta_lambda / 2, LambdaCtheta, 0.5)
    fine = np.arange(LambdaCtheta, LambdaCtheta + 25, 0.004)
    coarse_hi = np.arange(LambdaCtheta + 25, p['LambdaC'] + delta_lambda / 2 + 0.5, 0.5)
    Lambda = np.concatenate([coarse_lo, fine, coarse_hi])

    Rs, Rp, R = reflectivity_calc(stack, Lambda, p['thetaEi'])
    return Lambda, Rs, Rp, R


def lambda_resonance(stack, lambda_c_theta, thetaEi_deg):
    """Finds the resonance (minimum-reflectivity) wavelength near lambda_c_theta."""
    Lambda = np.arange(lambda_c_theta, lambda_c_theta + 30, 0.01)
    Rs, Rp, R = reflectivity_calc(stack, Lambda, thetaEi_deg)
    return Lambda[np.argmin(Rs)], Lambda[np.argmin(Rp)], Lambda[np.argmin(R)]


def stack_field_profile(stack, lambda_c, Ei, t):
    """Snapshot of the standing electric field through the stack at time t.

    Returns (x, y) 1D numpy arrays (x in nm).
    """
    n, d, N = stack.n, stack.d.copy(), stack.N
    d[N + 2] = 2 * lambda_c
    c = LIGHT_SPEED
    w = c * 2 * np.pi / lambda_c

    E = np.zeros((3, N + 3), dtype=complex)  # E[1,:] and E[2,:] used (1-indexed rows)
    S, _ = c_matrices(stack, np.array([lambda_c]))
    S = S[0]
    r = S[1, 0] / S[0, 0]
    E[1, 1] = Ei
    E[2, 1] = r * Ei

    xi = np.arange(-2 * lambda_c, 0 + lambda_c / 4000, lambda_c / 4000)
    k = 2 * np.pi / lambda_c * n[1]
    yi = np.real((E[1, 1] * np.exp(-1j * k * xi) + E[2, 1] * np.exp(1j * k * xi)) * np.exp(1j * w * t))
    x_parts = [xi]
    y_parts = [yi]

    l = 0.0
    for m in range(1, N + 2):
        xm = np.arange(l, d[m + 1] + l + d[m + 1] / 1000, d[m + 1] / 1000) if d[m + 1] > 0 else np.array([l])
        k = 2 * np.pi / lambda_c * n[m + 1]
        deltam = (2 * np.pi / lambda_c) * n[m] * d[m]
        rm = (n[m] - n[m + 1]) / (n[m] + n[m + 1])
        tm = (2 * n[m]) / (n[m] + n[m + 1])
        Sm = np.array([
            [(1 / tm) * np.exp(1j * deltam), (rm / tm) * np.exp(1j * deltam)],
            [(rm / tm) * np.exp(-1j * deltam), (1 / tm) * np.exp(-1j * deltam)],
        ])
        E[1:3, m + 1] = np.linalg.solve(Sm, E[1:3, m])
        ym = np.real(
            (E[1, m + 1] * np.exp(-1j * k * xm) * np.exp(1j * k * l)
             + E[2, m + 1] * np.exp(1j * k * xm) * np.exp(-1j * k * l)) * np.exp(1j * w * t)
        )
        l += d[m + 1]
        x_parts.append(xm)
        y_parts.append(ym)

    return np.concatenate(x_parts), np.concatenate(y_parts)


def dispersion_vs_k_parallel(p):
    """Energy vs k_parallel for the microcavity (Uvskparallel.m port).

    Returns dict with kparallel_s, Us, kparallel_p, Up (energies in Joules, k in 1/um).
    """
    h = 6.626e-34
    c = LIGHT_SPEED
    theta_deg = np.arange(-60, 60 + 2, 2)
    LambdaCRs = np.zeros_like(theta_deg, dtype=float)
    LambdaCRp = np.zeros_like(theta_deg, dtype=float)

    for i, td in enumerate(theta_deg):
        pi_ = dict(p)
        pi_['thetai'] = float(td)
        thetai = np.radians(td)
        LambdaCtheta = p['LambdaC'] * np.sqrt(1 - p['ni'] ** 2 * np.sin(thetai) ** 2 / p['nc'] ** 2)
        stack, _ = ds_microcavity(pi_)
        LambdaCRs[i], LambdaCRp[i], _ = lambda_resonance(stack, LambdaCtheta, p['thetaEi'])

    Us = (h * c * 1e9) / LambdaCRs
    Up = (h * c * 1e9) / LambdaCRp
    theta_rad = np.radians(theta_deg)
    kparallel_s = 2 * np.pi * 1000 * np.sin(theta_rad) / LambdaCRs
    kparallel_p = 2 * np.pi * 1000 * np.sin(theta_rad) / LambdaCRp
    return dict(kparallel_s=kparallel_s, Us=Us, kparallel_p=kparallel_p, Up=Up)


def resonance_vs_angle(p):
    """Resonance wavelength vs angle of incidence for the microcavity (LambdaCvsthetai.m port)."""
    theta_deg = np.arange(-60, 60 + 2, 2)
    LambdaCRs = np.zeros_like(theta_deg, dtype=float)
    LambdaCRp = np.zeros_like(theta_deg, dtype=float)

    for i, td in enumerate(theta_deg):
        pi_ = dict(p)
        pi_['thetai'] = float(td)
        thetai = np.radians(td)
        LambdaCtheta = p['LambdaC'] * np.sqrt(1 - p['ni'] ** 2 * np.sin(thetai) ** 2 / p['nc'] ** 2)
        stack, _ = ds_microcavity(pi_)
        LambdaCRs[i], LambdaCRp[i], _ = lambda_resonance(stack, LambdaCtheta, p['thetaEi'])

    return theta_deg, LambdaCRs, LambdaCRp
