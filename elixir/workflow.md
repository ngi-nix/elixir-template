## Workflow 

- install (mix2nix)[https://github.com/ydlr/mix2nix] and `nix-build` it
- import the flake template to your mix project 
- `git add flake.nix` to make it visible to git
- make sure the `mix2nix` binary is available in your path, or run it from the nix store path
- run `mix2nix > deps.nix` -- this will build a `deps.nix` expression from your mix.exs
- edit `flake.nix` by replacing the project name and the deps names.
- `nix develop` / `nix build`
