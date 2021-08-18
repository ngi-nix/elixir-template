{
  description = "A flake for Elixir projects built with Mix";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

  #inputs.utils.url = "github:numtide/flake-utils";

  inputs.src = { 
    url = "/home/apok/code/summer-of-nix/flakes-templates/elixir/flaketest";
    flake = false; };

    outputs = { self, nixpkgs, src }:
      let
      # System types to support.
      supportedSystems = [  ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: 
          import nixpkgs { 
            inherit system; 
            pkgs = beam.packagesWith beam.interpreters.erlang;
            overlays = [ self.overlay ]; 
            }
          );

      pname = "your_project";
      version = "0.0.1";
      mixEnv = "prod";

      mixFodDeps = beams.fetchMixDeps {
        pname = "mix-deps-${pname}";
        inherit src mixEnv version;
        # nix will complain and tell you the right value to replace this with
        sha256 = "H7yiBHoxuiqWcNbWwPU5X0Nnv8f6nM8z/ZAfZAGPZjE=";
        # if you have build time environment variables add them here
        MY_ENV_VAR="my_value";
      };
      in {
        overlay = final: prev: {

        my-project = with prev; beams.mixRelease rec {
        inherit src pname version mixEnv mixFodDeps ;
        # if you have build time environment variables add them here
        MY_ENV_VAR="my_value";
        };

      };

      # Provide some binary packages for selected system types.
      packages.${system}.${pname} = pkgs.
      
      forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) my-project;
        });
      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.my-project);
  };
}

#    let
#      localOverlay = import ./overlay.nix { inherit src; };
#
#      pkgsForSystem = system: import nixpkgs rec {
#        overlays = [
#          localOverlay
#        ];
#
#        inherit system;
#      };
#    in utils.lib.eachDefaultSystem (system: rec {
#      legacyPackages = pkgsForSystem system;
#      packages = utils.lib.flattenTree {
#        inherit (legacyPackages) my-mix-project;
#      };
#      defaultPackage = packages.my-mix-project ; 
#      apps.my-mix-project = utils.lib.mkApp { drv = packages.my-mix-project; };
#  }) // {
#    overlays = { };
#    };
# }
