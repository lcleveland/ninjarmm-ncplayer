{
  description = "NinjaOne Remote Player (ncplayer) — standalone NixOS module & package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        ncplayer = pkgs.callPackage ./package.nix { };
        default = ncplayer;
      });

      overlays.default = final: prev: {
        ncplayer = final.callPackage ./package.nix { };
      };

      nixosModules.ncplayer = import ./module.nix;
      nixosModules.default = self.nixosModules.ncplayer;

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
