+++
date = 2021-10-18
title = "Restic + Backblaze B2 on NixOS"
+++

While NixOS fully supports making `restic` backups using Backblaze, I couldn't
find documentation for it. From browsing configs on GitHub, many people seem to
_also_ use `rclone` but I'd rather not introduce another dependency.

Here's how I did it:

```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups.myaccount = {
    initialize = true;
    # since this uses an `agenix` secret that's only readable to the
    # root user, we need to run this script as root. If your
    # environment is configured differently, you may be able to do:
    #
    # user = "myuser
    #
    passwordFile = config.age.secrets.my_backups_pw.path;
    # what to backup.
    paths = ["/home/myusername"];
    # the name of your repository.
    repository = "b2:my_repo_name";
    timerConfig = {
      # backup every 1d
      OnUnitActiveSec = "1d";
    };


    # keep 7 daily, 5 weekly, and 10 annual backups
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-yearly 10"
    ];
  };

  # Instead of doing this, you may alternatively hijack the
  # `awsS3Credentials` argument to pass along these environment
  # vars.
  #
  # If you specified a user above, you need to change it to:
  # systemd.services.user.restic-backups-myaccount = { ... }
  #
  systemd.services.restic-backups-myaccount = {
    environment = {
      B2_ACCOUNT_ID = "my_account_id_abc123";
      B2_ACCOUNT_KEY = "my_account_key_def456";
    };
  };

}
```
