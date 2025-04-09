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

  # Disabling due to disputed: CVE-2024-37408
  security.pam.services.sudo.fprintAuth = false;
  security.pam.services.su.fprintAuth = false;


  services.fprintd = {
    enable = true;
  };
}
