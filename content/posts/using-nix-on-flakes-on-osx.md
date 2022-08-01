+++
date = 2022-08-01
title = "Using Nix on Flakes on OSX"
+++

I use Nix Flakes on OSX to setup my development environment. I've not seen
anyone else document this approach. Maybe you will find it useful.

## What's in a development environment?

By "development environment," I mean three things:

1. Adding and mutating shell environment variables (e.g. `$EDITOR`)
2. Installing command line applications (e.g. `/usr/bin/nvim`)
3. Adding config files (e.g. `$HOME/.config/nvim/init.lua`)

Unfortunately, 2 and 3 are "impure" according to Nix because they require
access to mutable paths. But there are simple workarounds:

- Instead of installing binaries to `/usr/bin/`, I can install it to the store
  and add it to the `$PATH`. For example, instead of installing
  `/usr/bin/nvim`, I would install `/nix/store/abc123-nvim/bin/nvim`.
- Instead of adding config files, I can wrap a binary to point to the store.
  For example, instead of generating `$HOME/.config/nvim/init.lua`, I'd:
  - Generate `/nix/store/abc123-init.lua/init.lua`.
  - Generate `/nix/store/abc123-nvim-wrapped/bin/nvim`, which just does `nvim
    -u /nix/store/abc123-init.lua/init.lua $@`. The `-u` flag lets you pass a
    path to the config, and [`$@` forwards arguments][what-does-dollar-at-do].
  - Add `/nix/store/abc123-nvim-wrapped/bin` to `$PATH`.

So if I can mutate environment variables--- including `$PATH`---  then I can do
everything!

But first, I need to explain Flakes a little bit.

[what-does-dollar-at-do]: https://stackoverflow.com/questions/9994295/what-does-mean-in-a-shell-script

## A Nix Flakes primer

Sorry, I feel like every Nix article that touches on Flakes has to explain
Flakes from scratch. I'll try and stick with what's relevant to what I'm doing.
If you're interested in a deep dive, I recommend Xe Iaso's [Nix Flakes: an
Introduction][flakes-introduction].

Flakes, at their core, are a configuration format for the Nix toolchain. This
format accepts inputs, which are dependencies that live in the Nix store, and
produces outputs, which are read by various tools. For example, the `nix` CLI
tool's `nix build` subcommand builds the `packages.default` output for the
flake.

See? That wasn't so bad, was it? If this still seems a bit abstract, read on
for an example.

**Note:** In versions of `nix` prior to 2.7, `packages.default` was known as
`defaultPackage`. If you care about compatibility with old versions, you may
want to alias it to point to `packages.default`.

[flakes-introduction]: https://xeiaso.net/blog/nix-flakes-1-2022-02-21

## Designing a development environment

Using Flakes, I need to mutate environment variables. To do this, I'll use a
little-known command called [`nix print-dev-env`][nix-print-dev-env]:

> `nix print-dev-env` - print shell code that can be sourced by bash to reproduce
> the build environment of a derivation

If you run `nix print-dev-env`, it will build the `packages.default` output of
your current `flake.nix`.

This approach has two steps:

1. Make a `packages.default` output that mutates shell environment variables as
   desired. For example, it should add `/nix/store/abc123-nvim-wrapped/bin` to
   the `$PATH`.
2. Source the output of `nix print-dev-env` in my development shell.

## Putting the pieces together

To construct the `packages.default` output, you can use `pkgs.mkShell`:

```nix
# In flake.nix
let
  neovim-with-config = neovim.override {
    customRC = ''
      lua << EOF
        -- init.lua goes here
      EOF
    '';
  };
in 
  {
    outputs = flake-utils.lib.eachDefaultSystem (_system: {
        packages.default = pkgs.mkShell {
          packages = with pkgs; [
            neovim-with-config
            # anything else
          ];

          shellHook = ''
            # Optionally, inject other stuff into your shell
            # environment.
          '';
        };
      });
  }
```

Since the shell requires `neovim-with-config`, its 'build environment' will
append `/nix/store/abc123-neovim-with-config/bin/` to `$PATH`. That's exactly
what we want.

**And finally, source the output of `nix print-dev-env`:**

```zsh
# `print-dev-env` assumes bash. It mutates env variables such as
# `LINENO` that # are immutable in zsh, so I need to exclude them.
# This is annoying, but in practice works fine.
$ nix print-dev-env \
  | grep -v LINENO \
  | grep -v EPOCHSECONDS \
  | grep -v EPOCHREALTIME \
  > $HOME/development-configuration.zsh 

$ echo 'source $HOME/development-configuration.zsh' >> $HOME/.zshrc
```

If you inspect `development-configuration.zsh`, you'll see a giant RC file that includes:

```zsh
PATH='...:/nix/store/abc123-neovim-with-config/bin:...'
```

Indeed, running `nvim` works as expected. We have set up a development
environment using Nix Flakes!

[nix-print-dev-env]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-print-dev-env.html

## Full dotfiles

If you want to see my full dotfiles, [it lives on sourcehut][dotfiles]. [Here's
a link to where I define `packages.default`][define-default] and [here's where
I run `print-dev-env`][print-dev-env-invocation]

[dotfiles]: https://git.sr.ht/~yaymukund/dotfiles/tree
[define-default]: https://git.sr.ht/~yaymukund/dotfiles/tree/main/item/hosts/work/flake.nix#L81
[print-dev-env-invocation]: https://git.sr.ht/~yaymukund/dotfiles/tree/main/item/hosts/work/rebuild#L21
