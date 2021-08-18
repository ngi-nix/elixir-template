final: prev: {
  my-mix-project = with prev; prev.callPackage ./mix-project.nix { };

  devShell = final.my-mix-project;
}