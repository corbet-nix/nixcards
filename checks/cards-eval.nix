# SPDX-License-Identifier: MIT OR Apache-2.0
# Evaluates ../modules/cards.nix against the small NixOS surface it writes.
# This keeps the deployment wiring under `nix flake check` without building
# any Rust, fetching pass-me sources, or requiring consumer packages.
{ pkgs, lib ? pkgs.lib }:
let
  nixosSurfaceStub = { lib, ... }: {
    options = {
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
      };
      systemd.services = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
      users.users = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
      users.groups = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
      };
    };
  };

  evalWith = cfg: (lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      nixosSurfaceStub
      ../modules/cards.nix
      { services.passme-cards = cfg; }
    ];
  }).config;

  disabled = evalWith { };
  webRoot = evalWith {
    enable = true;
    webRoot = "/srv/passme-cards";
  };

  results = {
    "disabled deployment contributes no service or users" =
      disabled.systemd.services == { }
      && disabled.users.users == { };

    "webRoot deployment serves the supplied checkout on the default port" =
      webRoot.systemd.services.passme-cards.wantedBy == [ "multi-user.target" ]
      && lib.hasInfix "--directory /srv/passme-cards"
        webRoot.systemd.services.passme-cards.serviceConfig.ExecStart
      && lib.hasInfix "8099"
        webRoot.systemd.services.passme-cards.serviceConfig.ExecStart;
  };

  failed = lib.attrNames (lib.filterAttrs (_: passed: !passed) results);
in
if failed == [ ]
then pkgs.emptyFile
else
  throw ''
    nixcards: cards-eval check failed. Failing assertions:
    ${lib.concatMapStringsSep "\n" (failure: "  - ${failure}") failed}
  ''
