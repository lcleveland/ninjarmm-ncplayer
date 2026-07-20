# ninjarmm-ncplayer

A standalone Nix flake that packages [NinjaOne](https://www.ninjaone.com/)'s remote
session player (`ncplayer`) for NixOS and registers it as the handler for
`ninjarmm://` URLs.

NinjaOne ships `ncplayer` only as an x86_64 RPM. This flake fetches that RPM, extracts
the self-contained binary, wraps it in an FHS environment to satisfy its runtime
library dependencies, and (via the NixOS module) installs a desktop entry so remote
sessions launched from the NinjaOne web console open the native player.

Only `x86_64-linux` is supported (the upstream RPM is x86_64-only).

## Usage

### As a NixOS module (recommended)

Add the flake as an input and import its module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ncplayer.url = "github:lcleveland/ninjarmm-ncplayer";
  };

  outputs = { nixpkgs, ncplayer, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ncplayer.nixosModules.default
        {
          programs.ninjarmm-ncplayer.enable = true;
        }
      ];
    };
  };
}
```

This installs the player, adds the `ninjarmm-ncplayer.desktop` entry, and sets it as
the default handler for `x-scheme-handler/ninjarmm`.

Options:

- `programs.ninjarmm-ncplayer.enable` — enable the player and URL handler.
- `programs.ninjarmm-ncplayer.package` — override the package (defaults to the one
  built from this flake).

### As a package

```console
$ nix build github:lcleveland/ninjarmm-ncplayer#ncplayer
$ nix run github:lcleveland/ninjarmm-ncplayer#ncplayer -- ninjarmm://…
```

### As an overlay

```nix
nixpkgs.overlays = [ ncplayer.overlays.default ];
# then pkgs.ncplayer is available
```

## Verifying it works

After a rebuild with the module enabled:

```console
$ xdg-mime query default x-scheme-handler/ninjarmm
ninjarmm-ncplayer.desktop
$ xdg-open 'ninjarmm://test'   # should launch the player
```

## Updating the version

The pinned `version` and `hash` live in [`package.nix`](./package.nix).

1. Bump `version` to the new release.
2. Set `hash = lib.fakeHash;` temporarily.
3. Run `nix build .#ncplayer` — the error prints the real hash.
4. Paste the real hash back into `package.nix`.

If the extraction path inside the RPM changes, update the `installPhase` in
`package.nix` (currently `opt/NinjaRemote/ncplayer/ncplayer`).
