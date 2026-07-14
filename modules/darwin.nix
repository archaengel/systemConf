{
  config,
  lib,
  pkgs,
  username,
  ghostty,
  emacs-overlay,
  ...
}:

{
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs.overlays = [
    (import ../overlays/darwin.nix { inherit pkgs; })
    emacs-overlay.overlay
  ];

  fonts.packages = with pkgs; [
    #maple-mono.NL-NF
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.zsh;
    home = "/Users/${username}";
    packages = with pkgs; [
      # (vivaldi.override {
      #   proprietaryCodecs = true;
      #   enableWidevine = true;
      #   commandLineArgs = [
      #     "--enable-features=UseOzonePlatform"
      #     "--ozone-platform=wayland"
      #     "--ozone-platform-hint=auto"
      #     "--enable-features=WaylandWindowDecorations"
      #   ];
      # })
      ghostty-bin
      tmux
      btop
      tree
      mosh
      python3
      cachix
      radicle-node
    ];
  };

  programs.direnv.enable = true;
  programs.zsh.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    man-pages
    man-pages-posix
  ];

  nix.settings = {
    trusted-users = [ username ];
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    substituters = [
      "https://cache.iog.io"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
