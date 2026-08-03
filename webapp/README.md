# Microcavity Simulation — Python webapp

A Streamlit port of the original MATLAB App Designer app
(`Microcavity_Simulation.mlapp`) in the parent directory. Simulates a
Distributed Bragg Reflector (DBR) and a microcavity made of two DBRs using
the characteristic (transfer) matrix method: reflectance vs wavelength,
electric field profile, resonance wavelength vs angle of incidence, and
energy vs in-plane wavevector dispersion.

## Structure

- `physics.py` — the transfer-matrix optics engine (stack construction,
  reflectivity, field profile, resonance search). Pure NumPy, no UI
  dependencies, covered by `tests/`.
- `app.py` — Streamlit UI: a "Microcavity Simulation" tab and a "DBR
  Simulation" tab, mirroring the two tabs of the original app.
- `data/zone_9_12.xlsx` — experimental reflectance spectrum used by the
  DBR tab's "Experimental vs Simulation" plot.

## Run

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
streamlit run app.py
```

## Test

```bash
source venv/bin/activate
pytest
```

## Notes on the port

- `CMatrices.m` had a parenthesization typo in the s-polarization
  transmission coefficient. It's fixed in `physics.py`; the fix does not
  change any simulated output because the per-layer amplitude factor it
  affects cancels out of the reflectivity ratio used everywhere in this
  app.
- The MATLAB app's Play/Stop field-profile animation (a blocking `while`
  loop) is replaced with a Streamlit fragment that redraws on an interval,
  plus a manual scrub slider for when playback is stopped.
