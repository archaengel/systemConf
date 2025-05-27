{
  dotfiles,
  ...
}:
{
  programs.tmux = {
    enable = true;
    escapeTime = 250;
    extraConfig = builtins.readFile "${dotfiles}/tmux/.tmux.conf";
  };
}
