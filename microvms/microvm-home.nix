{
  config,
  lib,
  dotfiles,
  system,
  ...
}:

{
  options.microvm = {
    extraZshInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines to add to zsh initContent";
    };
  };

  config = {
    home.username = "edwardnuno";
    home.homeDirectory = lib.mkForce "/home/edwardnuno";
    home.packages = [
      dotfiles.packages.${system}.nvim
    ];

    programs.zsh = {
      enable = true;
      history = {
        size = 4000;
        save = 10000000;
        ignoreDups = true;
        share = false;
        append = true;
      };

      initContent = ''
        export CLAUDE_CONFIG_DIR=/home/edwardnuno/claude-microvm
        ${config.microvm.extraZshInit}
      '';
    };

    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
    programs.direnv.enable = true;
  };
}
