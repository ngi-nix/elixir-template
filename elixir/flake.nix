{
  description = "A flake template for Elixir projects built with Mix";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    # specify the system since Nix doesn't have access to the currentSystem value.
    with import nixpkgs { system = "x86_64-linux";};
    let
      pkgsForSystem = system: rec {
        inherit system beamPackages;
        deps = with pkgs; import ./deps.nix { inherit beamPackages lib ;};
        pkgs = beam.packagesWith beam.interpreters.erlang;
        my-mix-project = pkgs.mixRelease rec {
          pname = "my-mix-project";
          src = ./.;
          version = "0.0.0";
          mixNixDeps = deps;
        };
      };
    in utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ] (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) my-mix-project;
      };
      defaultPackage = packages.my-mix-project;
      devShell = pkgs.mkShell { buildInputs = [ packages.my-mix-project ] ;};
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
      hydraJobs = { inherit (legacyPackages) my-mix-project; };
      checks = { inherit (legacyPackages) my-mix-project; };
  });
}
