# SPDX-License-Identifier: MIT OR Apache-2.0
# nixcards deployment: Nix delivery for pass-me/cards.
#
# This repository contains ONLY Nix deployment code. No Rust sources, no
# card content, no product application code live here. The real code
# (behavior core, store, TUI, web PWA, catalogue) lives in
# https://github.com/pass-me/cards under FSL-1.1-ALv2 / CC-BY-NC-SA-4.0.
#
# This flake exposes a NixOS module that deploys a prebuilt pass-me/cards
# checkout. It never builds Rust itself: the consumer supplies `package`
# (or serves a prebuilt `web/dist`), so no FSL sources enter the nixpkgs
# closure through this flake.
{
  description = "nixcards deployment — NixOS delivery for pass-me/cards, no Rust sources";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules.cards = ./modules/cards.nix;
      nixosModules.default = ./modules/cards.nix;

      lib.cards = import ./lib/cards.nix;
      lib.policy = ./modules/cards.nix;

      checks = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          cards-eval = import ./checks/cards-eval.nix { inherit pkgs; };
        });
    };
}
