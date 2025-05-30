{
  config,
  lib,
  pkgs,
  username,
  ghostty,
  ...
}:

{
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "ctrl:nocaps";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
      "docker"
    ];
    packages = with pkgs; [
      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
        commandLineArgs = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
          "--ozone-platform-hint=auto"
          "--enable-features=WaylandWindowDecorations"
        ];
      })
      kitty
      ghostty.packages.${system}.default
      grimblast
      tmux
      btop
      tree
      mosh
      python3
      keepassxc
      syncthing
      cachix
      wofi
    ];
  };

  programs.direnv.enable = true;
  programs.zsh.enable = true;
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  programs.sway.enable = true;
  programs.hyprland.enable = true;
  xdg.portal.wlr.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.flatpak.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
                ${pkgs.greetd.tuigreet}/bin/tuigreet \
        	  --time \
        	  --asterisks \
        	  --user-menu \
        	  --cmd Hyprland
      '';
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
    sway
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  nix.settings.trusted-users = [ username ];
  nixpkgs.config.allowUnfree = true;
}
