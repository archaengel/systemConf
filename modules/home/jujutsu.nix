{ pkgs, username, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = username;
        email = "god11341258@gmail.com";
      };
      ui = {
        default-command = [
          "log"
          "--no-pager"
        ];
        pager = "delta";
        diff.format = "git";
      };
    };
  };
}
