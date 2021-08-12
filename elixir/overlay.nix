final: prev: {
  my-mix-project = nixpkgs.beam.packages.erlang.buildMix' { 
      pname = "my-mix-project";
      version = "0.1";
      src = ./.;
  };

  devShell = final.my-mix-project;
}