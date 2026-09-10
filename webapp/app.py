"""Streamlit port of the MATLAB App Designer "Microcavity Simulation" app.

Two tabs mirror the original: Microcavity Simulation and DBR Simulation,
each with a parameter panel driving a transfer-matrix reflectivity /
field-profile / dispersion calculation from physics.py.
"""

import time
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import streamlit as st

from physics import (
    C_LIGHT,
    build_dbr_stack,
    build_microcavity_stack,
    field_profile,
    lambda_resonance,
    matlab_colon,
    reflectivity,
)

DATA_DIR = Path(__file__).parent / "data"

GENERAL_DEFAULTS = dict(theta_i_deg=30.0, Ei=5.0, theta_Ei_deg=45.0, ni=1.0, nf=1.0, lambda_c=660.0)
DBR_LAYER_DEFAULTS = dict(n1=2.02, n2=1.46, N=21, lambda_d=660.0)
CAVITY_DEFAULTS = dict(nc=1.46, lambda_dc=660.0)

st.set_page_config(page_title="Microcavity Simulation", layout="wide")


# ---------------------------------------------------------------- widgets --

def general_panel(prefix, theta_i_limits):
    st.markdown("**General**")
    c1, c2 = st.columns(2)
    with c1:
        theta_i_deg = st.number_input(
            "θi (deg)", theta_i_limits[0], theta_i_limits[1],
            GENERAL_DEFAULTS["theta_i_deg"], key=f"{prefix}_thetai",
        )
        Ei = st.number_input("Ei (V/m)", 0.0, None, GENERAL_DEFAULTS["Ei"], key=f"{prefix}_Ei")
        ni = st.number_input("ni", 1.0, None, GENERAL_DEFAULTS["ni"], key=f"{prefix}_ni")
    with c2:
        theta_Ei_deg = st.number_input(
            "θEi (deg)", 0.0, 90.0, GENERAL_DEFAULTS["theta_Ei_deg"], key=f"{prefix}_thetaEi"
        )
        nf = st.number_input("nf", 1.0, None, GENERAL_DEFAULTS["nf"], key=f"{prefix}_nf")
        lambda_c = st.number_input("λc (nm)", 0.0, None, GENERAL_DEFAULTS["lambda_c"], key=f"{prefix}_lambdac")
    return dict(
        theta_i=np.deg2rad(theta_i_deg), Ei=Ei, theta_Ei=np.deg2rad(theta_Ei_deg),
        ni=ni, nf=nf, lambda_c=lambda_c,
    )


def layer_panel(prefix, title):
    st.markdown(f"**{title}**")
    c1, c2 = st.columns(2)
    with c1:
        n1 = st.number_input("n1", 1.0, None, DBR_LAYER_DEFAULTS["n1"], key=f"{prefix}_n1")
        n2 = st.number_input("n2", 1.0, None, DBR_LAYER_DEFAULTS["n2"], key=f"{prefix}_n2")
    with c2:
        N = st.number_input("N", 1, None, DBR_LAYER_DEFAULTS["N"], step=1, key=f"{prefix}_N")
        lambda_d = st.number_input("λd (nm)", 0.0, None, DBR_LAYER_DEFAULTS["lambda_d"], key=f"{prefix}_lambdad")
    d1 = lambda_d / (4 * n1)
    d2 = lambda_d / (4 * n2)
    st.caption(f"d1 = {d1:.2f} nm    d2 = {d2:.2f} nm")
    return dict(n1=n1, n2=n2, N=int(N), lambda_d=lambda_d, d1=d1, d2=d2)


def cavity_panel(prefix):
    st.markdown("**Cavity Layer**")
    c1, c2 = st.columns(2)
    with c1:
        nc = st.number_input("nc", 1.0, None, CAVITY_DEFAULTS["nc"], key=f"{prefix}_nc")
    with c2:
        lambda_dc = st.number_input("λd (nm)", 0.0, None, CAVITY_DEFAULTS["lambda_dc"], key=f"{prefix}_lambdadc")
    dc = lambda_dc / (2 * nc)
    st.caption(f"dc = {dc:.2f} nm")
    return dict(nc=nc, lambda_dc=lambda_dc, dc=dc)


# ------------------------------------------------------------- field plot --

def _field_ylim(stack, lambda_c, Ei, max_tleg, nc):
    ymin, ymax = 0.0, 0.0
    for tleg in np.linspace(0.0, max_tleg, 11):
        t = tleg * lambda_c / (4 * C_LIGHT * nc)
        _, y = field_profile(stack, lambda_c, Ei, t)
        ymin, ymax = min(ymin, y.min()), max(ymax, y.max())
    return max(ymax, abs(ymin))


_MAX_PLOT_POINTS = 4000


def _plot_field(stack, lambda_c, Ei, t, tleg, ylimit, title):
    x, y = field_profile(stack, lambda_c, Ei, t)
    if x.size > _MAX_PLOT_POINTS:
        # Field profile arrays follow the MATLAB app's per-layer sampling
        # density (~1000 pts/layer) and can reach 5-figure point counts;
        # decimate for rendering only, the physics stays untouched.
        stride = x.size // _MAX_PLOT_POINTS
        x, y = x[::stride], y[::stride]
    fig, ax = plt.subplots()
    ax.plot(x, y, "b-")
    ax.set_ylim(-ylimit, ylimit)
    ax.set_title(title)
    ax.set_xlabel("x (nm)")
    ax.set_ylabel("Electric Field (V/m)")
    ax.legend([f"t = {tleg:.2f}·λc/(4c)"])
    return fig


def render_field_profile(prefix, stack, lambda_c, Ei, nc, title):
    # A blocking loop over a single placeholder (rather than st.fragment
    # run_every) — this app nests the animation inside st.tabs + st.columns,
    # and fragments there stopped re-rendering / went blank after the
    # Play/Stop button's full-script rerun, a known rough edge of nesting
    # auto-rerunning fragments inside tab containers.
    max_tleg = 4.0 * nc
    ylimit = _field_ylim(stack, lambda_c, Ei, max_tleg, nc)

    tleg_key = f"{prefix}_tleg"
    slider_key = f"{prefix}_tleg_slider"
    reset_key = f"{prefix}_tleg_reset"
    st.session_state.setdefault(tleg_key, 0.0)

    # A widget's session_state key can't be reassigned after that widget has
    # been instantiated in the same run, so the post-animation reset to 0 is
    # deferred to the top of the *next* run, before the slider is created.
    if st.session_state.pop(reset_key, False):
        st.session_state[tleg_key] = 0.0
        st.session_state[slider_key] = 0.0

    btn_col, slider_col = st.columns([1, 3])
    with slider_col:
        tleg = st.slider(
            "t (× λc/4c)", 0.0, max_tleg, st.session_state[tleg_key], step=0.1, key=slider_key
        )
        st.session_state[tleg_key] = tleg

    placeholder = st.empty()

    def draw(tleg_val):
        t = tleg_val * lambda_c / (4 * C_LIGHT * nc)
        fig = _plot_field(stack, lambda_c, Ei, t, tleg_val, ylimit, title)
        placeholder.pyplot(fig)
        plt.close(fig)

    draw(tleg)

    with btn_col:
        play = st.button("Play one cycle", key=f"{prefix}_play_btn")
    if play:
        n_frames = int(round(max_tleg / 0.1))
        for i in range(n_frames):
            draw((i * 0.1) % max_tleg)
            time.sleep(0.1)
        st.session_state[reset_key] = True
        st.rerun()


# ---------------------------------------------------------- experimental --

@st.cache_data
def load_experimental_data():
    df = pd.read_excel(
        DATA_DIR / "zone_9_12.xlsx",
        sheet_name="1304102U1_01",
        header=None,
        skiprows=6,
        usecols=[0, 1],
        nrows=2732,
        names=["wavelength", "reflectance"],
    )
    y = df["reflectance"].to_numpy() / 100
    y = y / y.max()
    return df["wavelength"].to_numpy(), y


# -------------------------------------------------------------- DBR tab --

def render_dbr_tab():
    left, right = st.columns([1, 2])
    with left:
        plot_choice = st.selectbox(
            "Plot", ["R vs λ", "E vs x", "Experimental vs Simulation"], key="dbr_plot"
        )
        gen = general_panel("dbr", theta_i_limits=(0.0, 90.0))
        layer = layer_panel("dbr", "DBR")

    with right:
        if plot_choice == "R vs λ":
            stack = build_dbr_stack(
                gen["theta_i"], gen["ni"], gen["nf"], layer["n1"], layer["n2"],
                layer["N"], layer["d1"], layer["d2"],
            )
            wavelength = matlab_colon(gen["lambda_c"] - 200, 0.5, gen["lambda_c"] + 200)
            Rs, Rp, R = reflectivity(stack, wavelength, gen["theta_Ei"])
            fig, ax = plt.subplots()
            ax.plot(wavelength, Rs, "b-", label="s-Polarization")
            ax.plot(wavelength, Rp, "r-", label="p-Polarization")
            ax.plot(wavelength, R, "g-", label="Given Polarization")
            ax.set_title("Reflectivity vs Wavelength of a DBR")
            ax.set_xlabel("Wavelength (nm)")
            ax.set_ylabel("Reflectivity")
            ax.legend()
            st.pyplot(fig)
            plt.close(fig)

        elif plot_choice == "E vs x":
            st.caption("Field profile is normal incidence: θi forced to 0°.")
            stack = build_dbr_stack(
                0.0, gen["ni"], gen["nf"], layer["n1"], layer["n2"],
                layer["N"], layer["d1"], layer["d2"],
            )
            render_field_profile("dbr", stack, gen["lambda_c"], gen["Ei"], nc=1.0,
                                  title="Electric Field Profile of a DBR")

        else:
            x, y = load_experimental_data()
            lambda_c_auto = x[np.argmax(y)]
            st.caption(f"λc auto-set from experimental peak: {lambda_c_auto:.2f} nm (θi forced to 0°).")
            stack = build_dbr_stack(
                0.0, gen["ni"], gen["nf"], layer["n1"], layer["n2"],
                layer["N"], layer["d1"], layer["d2"],
            )
            wavelength = matlab_colon(lambda_c_auto - 200, 0.5, lambda_c_auto + 200)
            _, _, R = reflectivity(stack, wavelength, gen["theta_Ei"])
            fig, ax = plt.subplots()
            ax.plot(x, y, "b-", label="Experiment")
            ax.plot(wavelength, R, "g-", label="Simulation")
            ax.set_title("Reflectivity vs Wavelength of a DBR")
            ax.set_xlabel("Wavelength (nm)")
            ax.set_ylabel("Reflectivity")
            ax.legend()
            st.pyplot(fig)
            plt.close(fig)


# -------------------------------------------------------- Microcavity tab --

def _mc_stack(theta_i, gen, d1, cavity, d2):
    return build_microcavity_stack(
        theta_i, gen["ni"], gen["nf"],
        d1["n1"], d1["n2"], d1["N"], d1["d1"], d1["d2"],
        cavity["nc"], cavity["dc"],
        d2["n1"], d2["n2"], d2["N"], d2["d1"], d2["d2"],
    )


def _lambda_c_theta(gen, cavity, theta_i):
    val = 1 - gen["ni"] ** 2 * np.sin(theta_i) ** 2 / cavity["nc"] ** 2
    return gen["lambda_c"] * np.sqrt(val) if val >= 0 else np.nan


def render_microcavity_tab():
    left, right = st.columns([1, 2])
    with left:
        plot_choice = st.selectbox(
            "Plot", ["R vs λ", "U vs k(parallel)", "LambdaC vs thetai", "E vs x"], key="mc_plot"
        )
        gen = general_panel("mc", theta_i_limits=(-90.0, 90.0))
        d1 = layer_panel("mc_d1", "DBR1")
        d2 = layer_panel("mc_d2", "DBR2")
        cavity = cavity_panel("mc")

    with right:
        if plot_choice == "R vs λ":
            stack = _mc_stack(gen["theta_i"], gen, d1, cavity, d2)
            lambda_c_theta = _lambda_c_theta(gen, cavity, gen["theta_i"])
            if np.isnan(lambda_c_theta):
                st.warning("Beyond critical angle for the cavity mode — no resonance to plot.")
                return
            delta = 300
            wavelength = matlab_colon(gen["lambda_c"] - delta / 2, 0.5, lambda_c_theta)
            wavelength = np.concatenate([wavelength, matlab_colon(lambda_c_theta, 0.004, lambda_c_theta + 25)])
            wavelength = np.concatenate(
                [wavelength, matlab_colon(lambda_c_theta + 25, 0.5, gen["lambda_c"] + delta / 2)]
            )
            Rs, Rp, R = reflectivity(stack, wavelength, gen["theta_Ei"])
            fig, ax = plt.subplots()
            ax.plot(wavelength, Rs, "b-", label="s-Polarization")
            ax.plot(wavelength, Rp, "r-", label="p-Polarization")
            ax.plot(wavelength, R, "g-", label="Given Polarization")
            ax.set_title("Reflectivity vs Wavelength of a Microcavity")
            ax.set_xlabel("Wavelength (nm)")
            ax.set_ylabel("Reflectivity")
            ax.legend()
            st.pyplot(fig)
            plt.close(fig)

        elif plot_choice == "E vs x":
            st.caption("Field profile is normal incidence: θi forced to 0°.")
            stack = _mc_stack(0.0, gen, d1, cavity, d2)
            render_field_profile("mc", stack, gen["lambda_c"], gen["Ei"], nc=cavity["nc"],
                                  title="Electric Field Profile of a Microcavity")

        else:
            theta_deg = np.arange(-60, 61, 2)
            LambdaCRs = np.full(theta_deg.shape, np.nan)
            LambdaCRp = np.full(theta_deg.shape, np.nan)
            with st.spinner("Sweeping angle of incidence (61 resonance searches)..."):
                for i, td in enumerate(theta_deg):
                    theta_i = np.deg2rad(float(td))
                    lambda_c_theta = _lambda_c_theta(gen, cavity, theta_i)
                    if np.isnan(lambda_c_theta):
                        continue
                    stack = _mc_stack(theta_i, gen, d1, cavity, d2)
                    LambdaCRs[i], LambdaCRp[i], _ = lambda_resonance(stack, lambda_c_theta, gen["theta_Ei"])

            fig, ax = plt.subplots()
            if plot_choice == "LambdaC vs thetai":
                ax.plot(theta_deg, LambdaCRs, "r-", label="s-Polarization")
                ax.plot(theta_deg, LambdaCRp, "b-", label="p-Polarization")
                ax.set_title("Resonance Wavelength vs Angle of incidence")
                ax.set_xlabel("Angle of Incidence (degrees)")
                ax.set_ylabel("Resonance Wavelength (nm)")
            else:
                h = 6.626e-34
                Us = h * C_LIGHT * 1e9 / LambdaCRs
                Up = h * C_LIGHT * 1e9 / LambdaCRp
                theta_rad = np.deg2rad(theta_deg.astype(float))
                kps = 2 * np.pi * 1000 * np.sin(theta_rad) / LambdaCRs
                kpp = 2 * np.pi * 1000 * np.sin(theta_rad) / LambdaCRp
                ax.plot(kps, Us, "r-", label="s-Polarization")
                ax.plot(kpp, Up, "b-", label="p-Polarization")
                ax.set_title("Energy vs k$_{||}$")
                ax.set_xlabel("k$_{||}$ ($\\mu m^{-1}$)")
                ax.set_ylabel("Energy (J)")
            ax.legend()
            st.pyplot(fig)
            plt.close(fig)


# ------------------------------------------------------------------ main --

st.title("Optics Simulations")
tab_microcavity, tab_dbr = st.tabs(["Microcavity Simulation", "DBR Simulation"])
with tab_microcavity:
    render_microcavity_tab()
with tab_dbr:
    render_dbr_tab()
