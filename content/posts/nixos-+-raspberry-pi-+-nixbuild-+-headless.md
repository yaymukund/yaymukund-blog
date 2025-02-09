+++
date = 2024-02-05
title = "Headless NixOS + Raspberry Pi + nixbuild from OSX!"
+++

I had to install NixOS on my Raspberry Pi 4, Model B recently. I didn't have
the HDMI→ micro HDMI cable so I decided to install it headlessly. This is a
fairly intricate setup because I wanted to:

1. Cross-compile from `aarch64-darwin`→ `aarch64-linux`.
2. Remote build using [nixbuild.net][nixbuild] to speed up build times.
3. Build from my memory-constrained 1GB Raspberry Pi.\*

It involved a few gotchas which I want to document here.

\* **Note:** Although it is possible to offload the compilation to nixbuild, you
still need memory on the Pi to evaluate the nix code. [There is an open
issue for eval memory usage][memory-usage-in-eval] which may alleviate this.

## Making a NixOS SD Image

First, make a `flake.nix` that produces the SD image:

```nix
{
  inputs = {
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { nixos-generators
    , nixos-hardware
    , nixpkgs
    }: {
      # This produces the install ISO.
      packages.aarch64-linux.installer-sd-image =
        nixos-generators.nixosGenerate {
          specialArgs = { inherit dotfiles-private; };
          system = "aarch64-linux";
          format = "sd-aarch64-installer";
          modules = [
            ./modules/hardware-configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            ./modules/base.nix
            ./modules/builder.nix
            ./modules/networking.nix
            ./modules/users.nix

            # Anything else you like...
          ];
        };
    };
}
```

Onto the modules...

<!-- more -->

## `modules/base.nix`

```nix
{ pkgs, ... }: {
  programs.ssh.extraConfig = ''
    Host nixbuild
        HostName eu.nixbuild.net
        User root
        PubKeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentitiesOnly yes
        IdentityFile ~/.ssh/nixbuild

    # SSH config for your favorite code forge, needed so you can clone your
    # repository containing flake.nix for rebuilds.
  '';

  # Not strictly necessary, but nice to have.
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Depends on the size of your storage.

  # Reduces writes to hardware memory, which increases the lifespan
  # of an SSD.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;

  # Needed for rebuilding on the Pi. You might not need this with more
  #memory, but my Pi only has 1GB.
  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];
}
```

## `modules/builder.nix`

The remote builder lets us do two things:

1. Cross-compile the SD image from a different architecture (`aarch64-darwin` in my case).
2. Remote-build from the Raspberry Pi 4B. Compiling things locally on a Pi takes
   longer.

I (happily) use [nixbuild.net][nixbuild], but you don't have to. Any
builder will do, as long as it can build `aarch64-linux`.

```nix
{
  nix.settings = {
    trusted-users = [ "my_username" ];
    builders-use-substitutes = true;
  };
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "eu.nixbuild.net";
    sshUser = "root";
    sshKey = "/home/my_username/.ssh/nixbuild";
    systems = [ "aarch64-linux" ];
    maxJobs = 100;
    speedFactor = 2;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
    ];
  }];
}
```

## `modules/networking.nix`

It's important to get this right with a headless setup or else you won't be
able to SSH to diagnose any other issues. You probably want to use a secrets
management system to configure the WiFi passkey.

```nix
{ ... }: {
  # Setup wifi
  networking = {
    hostName = "my_hostname";
    wireless.enable = true;
    useDHCP = false;
    interfaces.wlan0.useDHCP = true;
    wireless.networks = {
      my_ssid.pskRaw = "...";
    };
  };

  # And expose via SSH
  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."my_username".openssh.authorizedKeys.keys = [
    "ssd-ed25519 ..." # public key
  ];
}
```

## `modules/users.nix`

```nix
{
  users.users.my_username = {
    isNormalUser = true;
    home = "/home/my_username";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
  };

  security.sudo.execWheelOnly = true;

  # don't require password for sudo
  security.sudo.extraRules = [{
    users = [ "my_username" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}
```

## `modules/hardware-configuration.nix`

I don't think there's a good way to generate this before installing. Luckily,
lots of people with Raspberry Pi 4Bs have put their
`hardware-configuration.nix` online. Any of them should work. Here's mine:

```nix
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.end0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
```
Once you have SSH access, you can generate it with `nixos-generate-config` to
verify it matches.

## Putting it all together

1. (From `aarch64-darwin`) Build the SD image.
   ```zsh
   # -max-jobs 0: needed to force remote building for cross-compilation.
   # -system aarch64-linux: we need to override this bc we're on darwin.
   nix build \
       --max-jobs 0 \
       --system aarch64-linux \
       .#installer-sd-image

   zstd \
       -d result/sd-image/*.img.zst \
       -o installer-sd-image.img
   ```
2. (From `aarch64-darwin`) Write it to your SD card.
   ```zsh
   diskutil unmountDisk /dev/diskN
   sudo dd \
       if=..path/to/installer-sd-image.img \
       of=/dev/diskN \
       status=progress bs=1M
   diskutil eject /dev/diskN
   ```
3. Put the SD card in your Raspberry Pi and start it up. It should appear on
   your local network.
4. (From `aarch64-darwin`) `ssh my_hostname` and you should see it.

## Rebuilding locally on the Pi

To rebuild on the Pi, there are a few more steps.

First, you'll need to add the non-SD build target to your `flake.nix`:

```nix
nixosConfigurations.dave = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit dotfiles-private; };
  system = "aarch64-linux";
  modules = [
    ./modules/hardware-configuration.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    ./modules/base.nix
    ./modules/builder.nix
    ./modules/networking.nix
    ./modules/users.nix

    # Anything else you like...
  ];
};
```

Then, a few manual steps:

1. `ssh` into your Pi and `ssh-keygen -t ed25519 /.ssh/nixbuild`
2. `ssh` into your Pi and `ssh-keygen -t ed25519 /root/.ssh/nixbuild` (as root)
3. [Add the public key to your nixbuild.net account.][adding-nixbuild-keys]
4. `git clone` your config on the Pi.

(I'm not sure why both root and non-root keys are needed for `nixos-rebuild`
to do its thing here. If you know, please tell me.)

Then you should be able to run:

```zsh
nixos-rebuild switch \
    --use-remote-sudo \
    --max-jobs 0 \
    --flake /path/to/dir/containing/my/flake/
```

## Takeaways

### Nice things

* Everything works--- remote builds are fast, headless setup was successful.
* Most of this is in Nix rather than in state, so redoing everything from scratch is simple.

### Potential improvements

* With a little bit more work, you could move the SSH keys and `git clone` into the config.
* Use something like [deploy-rs][deploy-rs] to remote deploy and we can skip
  setting up SSH keys on the Pi altogether. This seems ideal.

## References

* [NixOS Wiki: Distributed builds][wiki-distributed-builds]
* [Github NixOS/nix: Memory usage in eval #8621][memory-usage-in-eval]
* [Github NixOS/nixos-hardware: `raspberry-pi."4".audio.enable = true;` broken: DTOVERLAY[error]: can't find symbol 'audio'][kernel-params-bug-workaround]

[deploy-rs]: https://github.com/serokell/deploy-rs
[nixbuild]: https://nixbuild.net
[adding-nixbuild-keys]: https://docs.nixbuild.net/configuration/#ssh-keys
[kernel-params-bug-workaround]: https://github.com/NixOS/nixos-hardware/issues/703#issuecomment-1869075978
[wiki-distributed-builds]: https://nixos.wiki/wiki/Distributed_build
[memory-usage-in-eval]: https://github.com/NixOS/nix/issues/8621
