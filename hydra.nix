{ nixpkgs ? <nixpkgs> }:
let
  nixos = "${nixpkgs}/nixos";
  system = import nixos
    {
      configuration = ./default.nix;
    };
in
{
  inherit (system) system;
}
