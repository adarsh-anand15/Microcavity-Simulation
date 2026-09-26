# Microcavity Simulation

Simulates a Distributed Bragg Reflector (DBR) and a microcavity made of two
DBRs using the characteristic (transfer) matrix method. Given layer
refractive indices, thicknesses, and angle of incidence, it computes:

- Reflectance vs wavelength (single DBR and microcavity)
- Electric field profile through the layer stack (with animation)
- Resonance wavelength vs angle of incidence
- Energy vs in-plane wavevector dispersion for a bare microcavity

The project exists in three parallel implementations, all built on the same
physics:

| App | Location | Stack | Status |
|---|---|---|---|
| Original desktop app | [`matlab/`](matlab/) | MATLAB App Designer | Reference implementation |
| Web app | [`webapp/`](webapp/) | Python, Streamlit | Active port |
| Android app | [`android_app/`](android_app/) | Python, Kivy | Active port, built via CI |

## MATLAB app

The original implementation, in [`matlab/`](matlab/). See the `.m` files
there (`CMatrices.m`, `DS_DBR.m`, `DS_Microcavity.m`, `Reflectivity_calc.m`,
`Stack_field_profile.m`, `Lambda_Resonance.m`, etc.) for the underlying
transfer-matrix physics.

Requirements: MATLAB R2017a or later.

To run:
1. Open the `matlab/` folder in MATLAB (all scripts expect to run with it as
   the working directory).
2. Open `Microcavity_Simulation.mlapp` and run it.

To rebuild the standalone Windows installer, open `Microcavity_Simulation.prj`
in MATLAB's Application Compiler and build — the packaged output
(`matlab/Microcavity_Simulation/for_redistribution/...`) isn't checked into
git.

## Web app

A Streamlit port of the MATLAB app with the same two tabs (Microcavity
Simulation, DBR Simulation). See [`webapp/README.md`](webapp/README.md) for
details, including a note on a transcription fix made during the port.

```bash
cd webapp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
streamlit run app.py
```

## Android app

A Kivy port with a DBR tab and a Microcavity tab, packaged as an APK. See
[`android_app/README.md`](android_app/README.md) for build instructions.

Debug APKs are built automatically by the
[Build Android APK](.github/workflows/android-build.yml) GitHub Actions
workflow on pushes/PRs touching `android_app/**`, or on demand from the
Actions tab; download the `microcavity-sim-debug-apk` artifact from a
completed run.

## License

MIT — see [LICENSE](LICENSE). Copyright (c) Adarsh Anand. You're free to use,
modify, and distribute this code (commercially or otherwise); the license
just asks that the copyright notice be kept with any copies.
