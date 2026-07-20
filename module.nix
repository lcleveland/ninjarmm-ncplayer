{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ninjarmm-ncplayer;

  # Desktop entry registering the ninjarmm:// URL scheme so the portal can
  # launch remote sessions. Exec=ncplayer resolves to the FHS wrapper on PATH.
  ncplayer-desktop = pkgs.writeTextFile {
    name = "ninjarmm-ncplayer-desktop";
    destination = "/share/applications/ninjarmm-ncplayer.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=NinjaOne Remote Player
      Exec=ncplayer %u
      StartupNotify=false
      MimeType=x-scheme-handler/ninjarmm;
    '';
  };
in
{
  options.programs.ninjarmm-ncplayer = {
    enable = lib.mkEnableOption "NinjaOne Remote Player (ncplayer) and the ninjarmm:// URL handler";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The ncplayer package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      ncplayer-desktop
    ];

    xdg.mime.defaultApplications."x-scheme-handler/ninjarmm" = "ninjarmm-ncplayer.desktop";
  };
}
