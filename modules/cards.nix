# SPDX-License-Identifier: MIT OR Apache-2.0
# NixOS delivery for pass-me/cards. Deployment only: this module installs
# and runs a caller-supplied prebuilt checkout. It contains no Rust sources
# and builds nothing from FSL-licensed code itself.
#
# Real code: https://github.com/pass-me/cards
#   crates/nixcards-core, crates/nixcards-store, crates/nixcards-tui,
#   web/, cards/ — all FSL-1.1-ALv2 / CC-BY-NC-SA-4.0, committed in-tree.
{ config, lib, pkgs, ... }:
let
  cfg = config.services.passme-cards;
  defaults = import ../lib/cards.nix;
in
{
  options.services.passme-cards = {
    enable = lib.mkEnableOption "pass-me/cards flashcard deployment";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Prebuilt pass-me/cards package (TUI binary plus web/dist).
        Supplied by the consumer; this module never builds it from source.
      '';
    };

    webRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Prebuilt PWA directory (web/dist) to serve. Takes precedence over
        package web output when set. Null disables static serving.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaults.defaultUser;
      description = "Service user owning the deployment.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = defaults.defaultDataDir;
      description = "State directory for progress and store checkouts.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = defaults.defaultPort;
      description = "Local port for the static PWA service.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package != null || cfg.webRoot != null;
        message = "services.passme-cards: set `package` or `webRoot` to a prebuilt pass-me/cards checkout.";
      }
    ];

    users.users = lib.mkIf (cfg.user == defaults.defaultUser) {
      ${defaults.defaultUser} = {
        isSystemUser = true;
        group = defaults.defaultUser;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.user == defaults.defaultUser) {
      ${defaults.defaultUser} = { };
    };

    systemd.services.passme-cards = {
      description = "pass-me/cards flashcard deployment";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        User = cfg.user;
        StateDirectory = builtins.baseNameOf cfg.dataDir;
        ExecStart =
          let
            root =
              if cfg.webRoot != null then cfg.webRoot
              else "${cfg.package}/share/passme-cards/web";
          in
          "${pkgs.python3}/bin/python3 -m http.server ${toString cfg.port} --directory ${root}";
        Restart = "on-failure";
      };
    };
  };
}
