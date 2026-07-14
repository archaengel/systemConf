{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ../../modules/darwin.nix
    ./system.nix
  ];

  nix.gc = {
    automatic = true;
    interval = [
      {Weekday = 7;}
    ];
  };

  networking.hostName = "gsmac"; # Define your hostname.
}
