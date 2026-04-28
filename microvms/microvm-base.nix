{
  hostName,
  ipAddress,
  tapId,
  mac,
  workspace,
  nixpkgs,
  home-manager,
  system,
  extraZshInit ? "",
  dotfiles,
}:

{
  config,
  ...
}:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  imports = [ home-manager.nixosModules.home-manager ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.edwardnuno = {
    imports = [ ./microvm-home.nix ];
    microvm.extraZshInit = extraZshInit;
  };
  home-manager.extraSpecialArgs = { inherit system dotfiles workspace; };

  # Claude Code CLI (from nixpkgs-unstable, unfree)
  environment.systemPackages = with pkgs; [
    claude-code
    ghostty.terminfo
  ];
  networking.hostName = hostName;

  system.stateVersion = "26.05";

  services.openssh.enable = true;

  users.groups.edwardnuno = {
    gid = 1000;
  };
  users.users.edwardnuno = {
    shell = pkgs.zsh;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAADS3gZkCcw0kG0kIeJcslEB2Az/uisFp+eOvhoCHWj edwardnuno@1134-gsfw"
    ];
    group = "edwardnuno";
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  programs.zsh.enable = true;

  virtualisation.docker.enable = true;

  services.resolved.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.tempAddresses = "disabled";
  systemd.network.enable = true;
  systemd.network.networks."10-e" = {
    matchConfig.Name = "e*";
    addresses = [ { Address = "${ipAddress}/24"; } ];
    routes = [ { Gateway = "10.10.0.1"; } ];
  };
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # Disable firewall for faster boot and less hassle;
  # we are behind a layer of NAT anyway.
  networking.firewall.enable = false;

  systemd.settings.Manager = {
    # fast shutdowns/reboots! https://mas.to/@zekjur/113109742103219075
    DefaultTimeoutStopSec = "5s";
  };

  # Fix for microvm shutdown hang (issue #170):
  # Without this, systemd tries to unmount /nix/store during shutdown,
  # but umount lives in /nix/store, causing a deadlock.
  systemd.mounts = [
    {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    }
  ];

  # Use SSH host keys mounted from outside the VM (remain identical).
  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/host-keys/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  microvm = {
    # Enable writable nix store overlay so nix-daemon works.
    # This is required for home-manager activation.
    # Uses tmpfs by default (ephemeral), which is fine since we
    # don't build anything in the VM.
    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 8192; # MB
      }
      {
        mountPoint = config.microvm.writableStoreOverlay;
        image = "nix-store-overlay.img";
        size = 8192 * 4; # MB
      }
    ];

    shares = [
      {
        # use proto = "virtiofs" for MicroVMs that are started by systemd
        proto = "virtiofs";
        tag = "ro-store";
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "virtiofs";
        tag = "ssh-keys";
        source = "${workspace}/ssh-host-keys";
        mountPoint = "/etc/ssh/host-keys";
      }
      {
        proto = "virtiofs";
        tag = "claude-credentials";
        source = "/home/edwardnuno/claude-microvm";
        mountPoint = "/home/edwardnuno/claude-microvm";
      }
      {
        proto = "virtiofs";
        tag = "workspace";
        source = workspace;
        mountPoint = workspace;
      }
    ];

    interfaces = [
      {
        type = "tap";
        id = tapId;
        mac = mac;
      }
    ];

    hypervisor = "cloud-hypervisor";
    vcpu = 8;
    mem = 4096 * 4;
    socket = "control.socket";
  };
}
