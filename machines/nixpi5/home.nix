{ pkgs, username, ... }:
{
  imports = [ ../../users/${username}/home.nix ];

  home.stateVersion = "24.11";
}
