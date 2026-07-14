{
  pkgs,
  username,
  ...
}:

{
  imports = [ ../../users/${username}/darwinhome.nix ];

  home.stateVersion = "23.11";
}
