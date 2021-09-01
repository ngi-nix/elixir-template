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
        inherit (legacyPackages) devShell my-mix-project;
      };
      defaultPackage = packages.my-mix-project;
      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
      hydraJobs = { inherit (legacyPackages) my-mix-project; };
      checks = { inherit (legacyPackages) my-mix-project; };
      devShell = legacyPackages.mkShell {
        buildInputs = [ legacyPackages.mix2nix legacyPackages.git legacyPackages.beam.packages.erlangR24.elixir_1_11];
        shellHook = ''
          # this allows mix to work on the local directory 
          mkdir -p $PWD/.nix-mix
          mkdir -p $PWD/.nix-hex
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-mix
          export PATH=$MIX_HOME/bin:$PATH
          export PATH=$HEX_HOME/bin:$PATH
          mix local.hex --if-missing
          export ERL_AFLAGS="-kernel shell_history enabled" 
        '';
      };
    });
}
