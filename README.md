# nixcards deployment

Nix-only delivery for [pass-me/cards](https://github.com/pass-me/cards).
This repository ships **only Nix deployment code**: `flake.nix`,
`modules/cards.nix`, `lib/cards.nix`, `checks/cards-eval.nix`. No Rust
sources, no card content, no product application code live here.

The real code lives in `pass-me/cards` under FSL-1.1-ALv2 /
CC-BY-NC-SA-4.0:

```text
crates/nixcards-core/   behavior core: parser, validation, search, cram, progress, WASM API
crates/nixcards-store/  Git-native partial clone and sparse selection
crates/nixcards-tui/    terminal interface, catalogue manager, local progress store
web/                    mobile-first Svelte PWA
cards/                  canonical Markdown catalogue, committed in-tree
```

## Using

```nix
{
  inputs.nixcards.url = "github:corbet-nix/nixcards";

  outputs = { ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        nixcards.nixosModules.cards
        {
          services.passme-cards = {
            enable = true;
            webRoot = "/srv/passme-cards"; # prebuilt web/dist
          };
        }
      ];
    };
  };
}
```

The module never builds Rust itself. Supply `package` or `webRoot` from a
prebuilt `pass-me/cards` checkout; see `modules/cards.nix` for options.

## Status

Deployment wrapper only. History was scrubbed to Nix deployment code;
earlier Rust sources now live exclusively in `pass-me/cards`.

## Licence

Outbound licence is `MIT OR Apache-2.0`. See `LICENSE-MIT` and
`LICENSE-APACHE`.

## Contributing

Default instructions are in `CONTRIBUTING.md`. Every external contribution must be submitted through a pull request whose description contains this exact affirmation:

> I have read and agree to version 1.0 of the Individual Contributor License Agreement at
> https://github.com/corbet-nix/.github/blob/cla-v1.0/CLA.md.

The pull-request record is the acceptance record. A maintainer must not merge an external contribution without that affirmation.
