{
  pkgs,
  username,
  ...
}:

{
  imports = [ ../../users/${username}/home2.nix ];

  home.stateVersion = "23.11";
}
