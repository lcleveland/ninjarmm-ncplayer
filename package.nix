{
  lib,
  stdenv,
  fetchurl,
  rpmextract,
  buildFHSEnv,
  writeShellScript,
}:
let
  version = "15.37.8880";

  src = fetchurl {
    url = "https://resources.ninjarmm.com/development/ninjacontrol/${version}/ninjarmm-ncplayer-${version}_x86_64.rpm";
    hash = "sha256-HQryXZXm6BgmqzsYCcXHQTwLYyChDMpdKrxk5G68C+o=";
  };

  # Extract the single self-contained binary from the RPM.
  ncplayer-bin = stdenv.mkDerivation {
    pname = "ninjarmm-ncplayer-bin";
    inherit version src;
    nativeBuildInputs = [ rpmextract ];
    unpackPhase = "rpmextract ${src}";
    installPhase = ''
      install -Dm755 opt/NinjaRemote/ncplayer/ncplayer $out/bin/ncplayer
    '';
  };
in
# Wrap in an FHS environment to satisfy the binary's runtime library deps.
buildFHSEnv {
  name = "ncplayer";
  targetPkgs =
    pkgs: with pkgs; [
      libdrm
      libgbm
      mesa
      dbus
      stdenv.cc.cc.lib
    ];
  runScript = writeShellScript "ncplayer-run" ''
    export QT_QPA_PLATFORM=xcb
    exec ${ncplayer-bin}/bin/ncplayer "$@"
  '';

  meta = {
    description = "NinjaOne Remote Player (ncplayer) — handles ninjarmm:// remote sessions";
    homepage = "https://www.ninjaone.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ncplayer";
  };
}
