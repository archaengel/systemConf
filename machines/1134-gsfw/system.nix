{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  security.pam.services.greetd = {
    rules.auth.unix = {
      enable = true;
      control = "sufficient";
      args = ["try_first_pass" "likeauth" "nullok"];
    };

    rules.auth.fprintd = {
      enable = true;
      order = config.security.pam.services.greetd.rules.auth.unix.order + 1;
      control = "sufficient";
    };
  };


  services.fprintd = {
    enable = true;
  };
}
