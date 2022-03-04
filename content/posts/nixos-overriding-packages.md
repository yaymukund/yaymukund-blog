+++
date = 2021-06-02
title = "Overriding packages in NixOS"
+++

In NixOS, it's sometimes desirable to override a package in order to extend
or modify its behavior. For example, I override my Neovim to add plugins so
they get all the benefits of being in the nix store. Here's how I do it.

<!-- more -->

```nix
# in configuration.nix
nixpkgs.overlays = [
  (import ./overlays.nix)
];

# in overlays.nix
self: super: {
  neovim-mukund = self.callPackage ./packages/neovim-mukund.nix {};
}

# finally, in packages/neovim-mukund.nix
{ pkgs }:
  neovim.override {
    vimAlias = true;
    viAlias = true;
    configure = {
      packages.mukund-plugins = with pkgs.vimPlugins; {
        start = [
          ale
          fzf-vim
          # ...
        ];
      };
    };
  }

# putting it all together
environment.systemPackages = [
  neovim-mukund
];
```

## Bonus: Installing a single package from `main`

If you need to install a single package from the `main` branch but keep the
rest of your code on your nix channel (usually the main channel or
`nixos-unstable`), then try this:

```nix
# in packages/neovim-mukund.nix
let neovim-master = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {}).neovim
in
  environment.systemPackage = [
    neovim-master
  ]
```
This time, I'm fetching and installing from the `master.tar.gz` file. This is
handy if there's an update upstream that you want to use immediately. For
example, I often use this when `Discord` releases an update. Nixpkgs usually
merges the version bump fairly quickly, but it doesn't reach the release
channels for many days during which Discord is unusable.

## References

- [NixOS Wiki: Overlays](https://nixos.wiki/wiki/Overlays)
- [/r/NixOS: Install a package from specific version of NixOS](https://old.reddit.com/r/NixOS/comments/a3w67x/install_a_package_from_a_specific_version_of/eb9q19s/?context=3)
