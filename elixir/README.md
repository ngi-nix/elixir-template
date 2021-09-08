## README 

This flake is a template for Elixir projects which use Mix as a build tool. It also provides a dev environment which includes mix2nix, git, postgres, and elixir 1.12. (It does not provide everything you need for a full Phoenix project, which would include JS things.)

Mix2nix must be aware of your `mix.lock` dependencies in order to create nix expressions for each dependency (see the mix2nix [docs](https://github.com/ydlr/mix2nix)), so a typical workflow might look like: 
- create your mix project
- update your `mix.exs` with your deps and `mix compile` to create a `mix.lock` file
- create the `deps.nix` file with `mix2nix > deps.nix` 
- jump into your env with `nix develop`, and/or build a release with `nix build` when you're ready.

You will need to setup your postgres db and user if you want to use it in your project.
The default project name is `my-mix-project`, bulk update it to your own. 
