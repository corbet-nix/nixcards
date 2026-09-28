# SPDX-License-Identifier: MIT OR Apache-2.0
# Shared defaults for the pass-me/cards deployment. No code, no content:
# pure policy values the NixOS module consumes.
{
  defaultPort = 8099;
  defaultDataDir = "/var/lib/passme-cards";
  defaultUser = "passme-cards";
}
