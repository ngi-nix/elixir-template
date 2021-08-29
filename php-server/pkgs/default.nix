# - Set derivation name
# - Copy composer.json and composer.lock.
# - Run ./update.sh

{ system, pkgs }:
{ src, version, name }:
(import ./composition.nix { inherit system pkgs; }).overrideAttrs (attrs: rec
{
  inherit src version name;
})