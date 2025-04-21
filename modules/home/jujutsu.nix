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
        paginate = "never";
        default-command = "log";
      };
    };
  };
}
