{
  pkgs,
  username,
  ...
}:

{
  imports = [ ../../users/${username}/home.nix ];

  home.stateVersion = "23.11";
}
