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
      deps = import ./deps.nix { inherit beamPackages lib ;};

      pkgsForSystem = system: rec { 
        inherit system beamPackages; 
        pkgs = beam.packagesWith beam.interpreters.erlang;
        my-mix-project = pkgs.buildMix rec {
          name = "my-mix-project";
          src = ./.;
          version = "0.0.0";
          beamDeps = [
            # update the names here with your deps from mix.exs
            deps.my-first-dep
            deps.my-second-dep 
          ];
        };
      };
    in utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ] (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) my-mix-project;
      };
      defaultPackage = packages.my-mix-project;
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
      hydraJobs = { inherit (legacyPackages) my-mix-project; };
      checks = { inherit (legacyPackages) my-mix-project; };
  });
}
