TWEAKS in `package.nix`:

1. Set `DEFAULT_SIZES` to native resolution of your client PC.
2. If you `startplasma-11` is not at `/run/current-system/sw/bin/startplasma-x11`, edit the file location.
3. If you want to use `xdummy` instead of `Xvfb`, replace `--replace '"Xorg"' '"${xorg.xorgserver}/bin/Xorg"' \`
   with two commented-out lines at the bottom of `patchPhase`.
