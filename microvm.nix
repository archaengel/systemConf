{
  config,
  microvm,
  nixpkgs,
  home-manager,
  dotfiles,
  system,
  ...
}:

let
  microvmBase = import ./microvms/microvm-base.nix;
in
{
  microvm.vms.nodevm = {
    autostart = false;
    config = {
      imports = [
        microvm.nixosModules.microvm
        (microvmBase {
          hostName = "nodevm";
          ipAddress = "10.10.0.2";
          tapId = "microvm4";
          mac = "02:00:00:00:00:05";
          workspace = "/home/edwardnuno/microvm/nodevm";
          inherit
            nixpkgs
            home-manager
            dotfiles
            system
            ;
        })
        ./microvms/nodevm.nix
      ];
    };
  };
}
