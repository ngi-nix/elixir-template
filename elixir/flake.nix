{
  description = "A flake for Elixir projects built with Mix";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

  inputs.src = { 
    url = "path/to/mix-project/";
    flake = false; };

    outputs = { self, nixpkgs, src }:
      with import nixpkgs { 
          system = "x86_64-linux";
          };
      let 
        pkgs = beam.packagesWith beam.interpreters.erlang;
      in  {
      defaultPackage.x86_64-linux =
        pkgs.mixRelease rec {
         pname = "your_project";
         inherit src;
         version = "0.0.1";
         mixEnv = "prod";           

         mixFodDeps = pkgs.fetchMixDeps {
           pname = "mix-deps-${pname}";
           inherit src mixEnv version;
           # nix will complain and tell you the right value to replace this with
           sha256 = lib.fakeSha256;
         };
      };
  };
}