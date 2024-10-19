{
  config,
  pkgs,
  nixvim,
  dotfiles,
  ...
}:

{
  home.username = "archaengel";
  home.homeDirectory = "/home/archaengel";

  programs.nixvim = {
    enable = true;
    colorschemes.gruvbox.enable = true;
    plugins.lualine.enable = true;
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile "${dotfiles}/tmux/.tmux.conf";
  };

  programs.git = {
    enable = true;
    userName = "archaengel";
    userEmail = "god11341258@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  programs.zsh = {
    defaultKeymap = "viins";
    enable = true;
    syntaxHighlighting.enable = true;
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    initExtra = ''
      [[ ! -f ${./p10k.zsh} ]] || source ${./p10k.zsh}
    '';
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
