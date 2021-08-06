{
  description = "A collection of flake templates from Summer of Nix";

  outputs = { self }: {

    templates = {

      # import your flake.nix template from a subfolder like this:
      # trivial = {
      #   path = ./trivial;
      #   description = "A very basic flake";
      # };

    };

    defaultTemplate = self.templates.trivial;

  };
}
