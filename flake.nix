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
    };
    in utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) my-mix-project;
      };
      defaultPackage = packages.my-mix-project;
      devShell = self.devShells.${system}.dev;
      devShells = {
        dev = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db";
          MIX_ENV = "dev";
        };
        test = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_test";
          MIX_ENV = "test";
        };
      };
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
      hydraJobs = { inherit (legacyPackages) my-mix-project; };
      checks = { inherit (legacyPackages) my-mix-project; };
    }) // { overlay = overlay ;};
}
