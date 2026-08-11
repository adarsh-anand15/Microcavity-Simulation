[app]
title = Microcavity Simulation
package.name = microcavitysim
package.domain = org.adarshanand

source.dir = .
source.include_exts = py,png,jpg,kv,atlas

version = 1.0

requirements = python3,kivy==2.3.1,numpy

orientation = landscape
fullscreen = 0

android.permissions =
android.api = 34
android.minapi = 24
android.ndk = 25b
android.archs = arm64-v8a,armeabi-v7a
android.accept_sdk_license = True

[buildozer]
log_level = 2
warn_on_root = 0
