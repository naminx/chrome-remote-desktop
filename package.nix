{
  stdenvNoCC,
  lib,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  glib,
  gtk3,
  libdrm,
  libutempter,
  mesa,
  nss,
  pam,
  python3,
  shadow,
  xorg,
  llvmPackages_17,
  libcxx,
  xdummy,
  ...
}: let
  replacePrefix = "/opt/google/chrome-remote-desktop";
in
  stdenvNoCC.mkDerivation rec {
    name = "chrome-remote-desktop";
    # Get the latest version from:
    # https://dl.google.com/linux/chrome-remote-desktop/deb/dists/stable/main/binary-amd64/Packages
    version = "118.0.5993.9";
    src = fetchurl {
      url = "https://dl.google.com/linux/chrome-remote-desktop/deb/pool/main/c/chrome-remote-desktop/chrome-remote-desktop_${version}_amd64.deb";
      hash = "sha256-8EcWktLxTTgiWReKnVSr1TJV3FKM5P8ixQUQA1Q4zew=";
      # url = "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb";
      # hash = "sha256-HA1sMR/v3b7u1GaCTzqdAV4Ov5mrRoYU4vPdyEYnX2Y=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      glib
      gtk3
      libdrm
      libutempter
      mesa
      nss
      pam
      xorg.libX11
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXtst
      libcxx
      xdummy
    ];

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      runHook preUnpack
      ${dpkg}/bin/dpkg -x $src $out
      runHook postUnpack
    '';

    patchPhase = ''
      runHook prePatch
      sed \
        -e '/^.*sudo_command =/ s/"gksudo .*"/"pkexec"/' \
        -e '/^.*command =/ s/s -- sh -c/s sh -c/' \
        -i $out/opt/google/chrome-remote-desktop/chrome-remote-desktop
      substituteInPlace $out/lib/systemd/system/chrome-remote-desktop@.service \
        --replace /opt/google/chrome-remote-desktop/chrome-remote-desktop '${placeholder "out"}/bin/chrome-remote-desktop'
      substituteInPlace $out/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json \
        --replace ${replacePrefix}/native-messaging-host $out/${replacePrefix}/native-messaging-host
      substituteInPlace $out/${replacePrefix}/chrome-remote-desktop \
        --replace /usr/bin/python3 ${python3.withPackages (ps: with ps; [psutil pyxdg packaging])}/bin/python3 \
        --replace '"Xvfb"' '"${xorg.xorgserver}/bin/Xvfb"' \
        --replace '"Xorg"' '"${xorg.xorgserver}/bin/Xorg"' \
        --replace '"xrandr"' '"${xorg.xrandr}/bin/xrandr"' \
        --replace /usr/lib/xorg/modules ${xorg.xorgserver}/lib/xorg/modules \
        --replace xdpyinfo ${xorg.xdpyinfo}/bin/xdpyinfo \
        --replace /usr/bin/sudo /run/wrappers/bin/sudo \
        --replace /usr/bin/pkexec /run/wrappers/bin/pkexec \
        --replace /usr/bin/gpasswd ${shadow}/bin/gpasswd \
        --replace /usr/sbin/groupadd ${shadow}/bin/groupadd \
        --replace 'DEFAULT_SIZES = "1600x1200,3840x2560"' 'DEFAULT_SIZES = "2160x1440,3840x2160"' \
        --replace 'FIRST_X_DISPLAY_NUMBER = 20' 'FIRST_X_DISPLAY_NUMBER = 1'
      substituteInPlace $out/opt/google/chrome-remote-desktop/Xsession \
        --replace /etc/X11/Xsession /run/current-system/sw/bin/startplasma-x11
      runHook postPatch
    '';
    #   --replace '"Xorg"' '"${xdummy}/bin/xdummy"' \
    #   --replace 'self.use_xvfb = self.should_use_xvfb()' 'self.use_xvfb = False # self.should_use_xvfb()' \

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      for i in "$out/opt/google/chrome-remote-desktop/"*; do
        if [[ ! -x "$i" ]]; then
          continue
        fi
        ln -s "$i" "$out/bin/"
      done
      runHook postInstall
    '';

    meta = {
      description = "Access your computer or share your screen with others using your phone, tablet, or another device";
      homepage = "https://remotedesktop.google.com/";
      platforms = ["x86_64-linux"];
      license = with lib.licenses; [unfree];
      mainProgram = "chrome-remote-desktop";
      maintainers = with lib.maintainers; [thiagokokada];
    };
  }
