# Touch scroll

When the workspace layout is scrolling, a one-finger sideways swipe moves the columns with the finger. A tap and a vertical drag still go to the app. The columns snap when the finger lifts.

Hyprland's `scroll_move` gesture only hears the trackpad. [hyprgrass](https://github.com/horriblename/hyprgrass) turns the touchscreen drag into that gesture. The swipe is registered only while the active workspace layout is scrolling, so a sideways swipe stays with the app on the other layouts.

`input.lua` belongs in the user Hyprland config (`~/.config/hypr/` on Omarchy, which loads after the defaults). It expects `libhyprgrass.so` at `~/.local/lib/hypr/libhyprgrass.so`.

The plugin has to be built for the same Hyprland commit. This snippet was used with hyprgrass `8e605468cbf429791d61ddbfaeb14ff5e08fec3e` (v0.8.2) on Hyprland 0.56.2 (`efb50993780079460b0cbed1363e2166a2de1d9f`). After a Hyprland upgrade, rebuild the plugin. The binary is not in this repo.

```bash
git clone https://github.com/horriblename/hyprgrass
cd hyprgrass
git checkout 8e605468cbf429791d61ddbfaeb14ff5e08fec3e
meson setup build --buildtype=release
meson compile -C build
mkdir -p ~/.local/lib/hypr
cp build/src/libhyprgrass.so ~/.local/lib/hypr/
```

Then reload Hyprland. Sensitivity 4 makes the swipe claim the finger after about 40px. Border long-press resize is off.
