{
  description = "An example for a PHP server program that uses an SQL database.";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-21.05"; };

  # Used to include dependencies.
  inputs.composer2nix = { type = "github"; owner = "svanderburg"; repo = "composer2nix"; ref = "v0.0.5"; flake = false; };

  # TODO: Add the source of the server.

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # TODO: Generate a user-friendly version numer, replace with server name
      versions =
        let
          generateVersion = builtins.substring 0 8;
        in
        nixpkgs.lib.genAttrs
          [ "server" ]
          (n: generateVersion inputs."${n}-src".lastModifiedDate);

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in
    {

      # A Nixpkgs overlay.
      overlay = final: prev:
        with final;
        {
          # TODO: Replace with server name.
          server = callPackage ./pkgs { } {
            src = inputs.server-src;
            version = versions.server;
            name = "server";
          };

        };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system})
            hubzilla;
        });

      # The default package for 'nix build'. In this case the server itself.
      defaultPackage = forAllSystems (system: self.packages.${system}.server);

      # TODO: A NixOS module, to configure the server. (Rename)
      nixosModules.server =
        { pkgs, ... }:
        {
          imports =
            [
              ./module.nix
            ];
          nixpkgs.overlays = [ self.overlay ];
        };

      # NixOS system configuration, an example of the server and required resources.
      nixosConfigurations.container =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [
              # Include the server's configuration
              self.nixosModules.server
              ({ pkgs, ... }: {
                system.configurationRevision = "whatever"; # ?
                boot.isContainer = true;
                networking.useDHCP = false;
                networking.firewall.allowedTCPPorts = [ 80 443 25 465 ];
                # TODO: Rename to name of server.
                services.server = {
                  enable = true;
                };
                # Setup the database, TODO: adjust name.
                services.mysql = {
                  enable = true;
                  package = pkgs.mariadb;
                  ensureDatabases = [ "server-name" ];
                  ensureUsers = [
                    {
                      name = "server-name";
                      ensurePermissions = {
                        "server-name.*" = "ALL PRIVILEGES";
                      };
                    }
                  ];
                };
              })
            ];
        };
    };
}