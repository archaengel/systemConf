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

  # Enable fw-fanctrl
  programs.fw-fanctrl.enable = true;

  # Avoid bugs with npm like https://github.com/NixOS/nixpkgs/issues/16441
  programs.npm.enable = true;

  programs.ssh.startAgent = true;

  # Add a custom config
  programs.fw-fanctrl.config = {
    defaultStrategy = "lazy";
    strategies = {
      "lazy" = {
        fanSpeedUpdateFrequency = 5;
        movingAverageInterval = 30;
        speedCurve = [
          {
            temp = 0;
            speed = 25;
          }
          {
            temp = 50;
            speed = 25;
          }
          {
            temp = 65;
            speed = 35;
          }
          {
            temp = 70;
            speed = 45;
          }
          {
            temp = 75;
            speed = 60;
          }
          {
            temp = 80;
            speed = 100;
          }
        ];
      };
    };
  };

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
