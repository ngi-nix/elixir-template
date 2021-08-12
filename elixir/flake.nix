{
  description = "A flake for Elixir projects built with Mix";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

  inputs.utils.url = "github:numtide/flake-utils";

  inputs.nix-elixir = { 
    url = "github:hauleth/nix-elixir";
    flake = false;
  };

  outputs = { self, nixpkgs, utils, nix-elixir }: 
    let
      localOverlay = import ./overlay.nix;

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          localOverlay
          nix-elixir
        ];
        inherit system;
      };
    in utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) devShell my-mix-project;
      };
      defaultPackage = packages.my-mix-project ; 
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
  }) // {
    overlays = { };
    };
}
