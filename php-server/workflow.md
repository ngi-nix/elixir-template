## Workflow

- install [composer2nix](https://github.com/svanderburg/composer2nix) and `nix-build` it
- import the flake template to your php project
- follow
- copy `composer.json` and `composer.lock`
- run `./update.sh` in the `pkgs` directory
- edit `flake.nix` and `module.nix` by replacing the project name and such at designated places
- run `nix develop` or `nix build`