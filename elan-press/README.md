# ELAN press reader

Rebuild pack for the power-button fingerprint readers USB `04f3:0c6e`, `04f3:0c4f`, and `04f3:0c63`. The stock libfprint swipe driver claims them, reads one status byte, then wedges, so enrollment dies with a protocol error. This patch puts those three IDs on a press driver. `04f3:0c4b` stays on the swipe driver.

The same change is in [omacom/omarchy-pkgs#2329](https://github.com/omacom/omarchy-pkgs/pull/2329). Keep this folder so a later package update can be rebuilt from here if that pull request is not what got installed.

`elanpress.patch` is libfprint source, LGPL-2.1-or-later. The press driver is Filip R. Spanne's. The MIT license of this repo covers these notes and scripts, not that patch.

The patch applies to libfprint `6f9479c3d55f847c1b3769f28ceb99227f9858cf`. Print format is unchanged, so an already enrolled finger stays valid. Do not delete the print store to rebuild.

A verify that never covers the whole pad still ends. After a short hold at about 60% coverage, or when the finger lifts, that frame is the picture. Enrollment still waits for a full press. A match needs 8 keypoint pairs.

The udev rule keeps `04f3:0c6e` awake. The resume hook restarts fprintd after suspend so a wedged claim does not survive sleep. The stop timeout is 3 seconds so a stale handle cannot ignore SIGTERM.

Build dependencies are the ones libfprint needs: meson, ninja, glib2, libgusb, libgudev, pixman, openssl, cairo.

```bash
./rebuild.sh
sudo ./install.sh ~/.cache/elan-press-build/build/libfprint/libfprint-2.so.2.0.0
```

`rebuild.sh` takes an optional work directory. The default is `~/.cache/elan-press-build`. Do not run Omarchy's fingerprint setup after this install. That setup replaces libfprint and will drop this library.
