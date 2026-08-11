Android port of the Microcavity Simulation app (Kivy + numpy).

## What's here

- `physics.py` — transfer-matrix (Abeles method) physics ported from the
  original MATLAB files (`CMatrices.m`, `DS_DBR.m`, `DS_Microcavity.m`,
  `Reflectivity_calc.m`, `Stack_field_profile.m`, `Lambda_Resonance.m`, etc).
  Default parameter values match `Microcavity_Simulation.mlapp`.
- `main.py` — Kivy UI with a DBR tab and a Microcavity tab: parameter form,
  reflectivity-vs-wavelength plot, animated electric-field-profile plot, and
  (for the microcavity) energy-vs-k∥ and resonance-wavelength-vs-angle plots.
  Curves are drawn with a small custom Kivy widget instead of matplotlib to
  keep the Android build light.
- `buildozer.spec` — Android packaging config (package `org.adarshanand.microcavitysim`).

## Building the APK

Building the Android SDK/NDK toolchain needs unrestricted internet access
(Google's SDK/NDK mirrors), so it's built by CI, not locally in a sandboxed
environment:

- Push to `master`/`main` (or open a PR) touching `android_app/**`, or run the
  **Build Android APK** workflow manually from the Actions tab.
- Download the `microcavity-sim-debug-apk` artifact from the completed run
  and install it on an Android device (`adb install app-debug.apk`, or copy
  it to the device and open it — allow "install unknown apps" for the source).

To build locally instead (Linux, with Android SDK/NDK reachable):

```
pip install buildozer cython
cd android_app
buildozer -v android debug
```

The APK lands in `android_app/bin/`.

## Notes

- This is a debug build (unsigned, not for the Play Store). For a release
  build you'd add signing config to `buildozer.spec` and run
  `buildozer android release`.
- `physics.py` was sanity-checked against the `.mlapp` defaults (reflectivity
  values in [0,1], finite field profiles, no NaNs) but not compared
  point-by-point against MATLAB output — spot-check numerically if the exact
  values matter for your use case.
