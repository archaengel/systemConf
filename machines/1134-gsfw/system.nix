{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      brightnessctl
      bluetui
      hyprlock
      hyprpaper
      fw-ectool
      lm_sensors
      wl-clipboard
    ];
    pathsToLink = [ "/share/zsh" ];
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libgcc
    ];
  };

  # ncspot dependency errors because of api sunset
  # https://github.com/hrkfdn/ncspot/issues/1676#issue-3290312497
  networking.extraHosts = ''
    0.0.0.0 apresolve.spotify.com
    ::0 apresolve.spotify.com
  '';

  virtualisation.docker.enable = true;

  # Avoid bugs with npm like https://github.com/NixOS/nixpkgs/issues/16441
  programs.npm.enable = true;

  programs.ssh.startAgent = true;

  security.pam.services.greetd = {
    rules.auth.unix = {
      enable = true;
      control = "sufficient";
      args = [
        "try_first_pass"
        "likeauth"
        "nullok"
      ];
    };

    rules.auth.fprintd = {
      enable = true;
      order = config.security.pam.services.greetd.rules.auth.unix.order + 1;
      control = "sufficient";
    };
  };

  # Disabling due to disputed: CVE-2024-37408
  security.pam.services.sudo.fprintAuth = false;
  security.pam.services.su.fprintAuth = false;

  security.pam.services.hyprlock = {
    rules.auth.unix = {
      enable = true;
      control = "sufficient";
      args = [
        "try_first_pass"
        "likeauth"
        "nullok"
      ];
    };

    rules.auth.fprintd = {
      enable = true;
      order = config.security.pam.services.hyprlock.rules.auth.unix.order + 1;
      control = "sufficient";
    };
  };

  services.fprintd = {
    enable = true;
  };

  services.twingate = {
    enable = true;
  };
}
