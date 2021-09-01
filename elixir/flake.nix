{
  description = "A flake template for Elixir projects built with Mix";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?ref=master;
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: 
    let
    pkgsForSystem = system: import nixpkgs {
        overlays = [ overlay ];
        inherit system;
      };

    overlay = final: prev: rec {

      my-mix-project = with final;
        let
          beamPackages = beam.packagesWith beam.interpreters.erlangR24; 
          mixNixDeps = import ./deps.nix { inherit lib beamPackages; }; 
        in beamPackages.mixRelease {
          inherit mixNixDeps;
          pname = "my-mix-project";
          src = ./.;
          version = "0.0.0";
         };
      devShell = final.my-mix-project;
    };
    in utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) devShell my-mix-project;
      };
      defaultPackage = packages.my-mix-project;
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
      hydraJobs = { inherit (legacyPackages) my-mix-project; };
      checks = { inherit (legacyPackages) my-mix-project; };
    });
}
