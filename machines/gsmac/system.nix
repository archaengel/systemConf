{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      qemu
      qmk
      git
      gcc
    ];
    pathsToLink = [ "/share/zsh" ];
  };

  # virtualisation = {
  #   docker.enable = true;
  #   containers.enable = true;
  #   podman = {
  #     enable = true;
  #     defaultNetwork.settings.dns_enabled = true;
  #   };
  # };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  system.primaryUser = username;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # services.yabai.enable = false;
  # services.yabai.enableScriptingAddition = true;
  # services.yabai.config = {
  #   top_padding = 6;
  #   bottom_padding = 6;
  #   right_padding = 6;
  #   left_padding = 6;
  #   window_gap = 6;
  # };
  # services.yabai.extraConfig = ''
  #   yabai -m config debug_output on
  #   yabai -m config external_bar all:30:0
  #   yabai -m space --layout bsp
  #   yabai -m signal --add event=window_destroyed \
  #     action="yabai -m window --focus last"

  #   borders active_color=0xf7768eff inactive_color=0x00000000 width=5.0 2>/dev/null 1>&2&
  # '';
  # services.skhd.enable = true;
  # services.skhd.skhdConfig = let mod = "alt"; in ''
  #   ${mod} - h : yabai -m window --focus west &> /dev/null \
  #       || yabai -m window --focus stack.prev &> /dev/null || yabai -m display --focus west
  #   ${mod} - j : yabai -m window --focus south &> /dev/null \
  #       || yabai -m window --focus stack.prev &> /dev/null || yabai -m display --focus south
  #   ${mod} - k : yabai -m window --focus north &> /dev/null \
  #       || yabai -m window --focus stack.next &> /dev/null || yabai -m display --focus north
  #   ${mod} - l : yabai -m window --focus east &> /dev/null \
  #       || yabai -m window --focus stack.next &> /dev/null || yabai -m dipslay --focus east

  #   ${mod} + shift - j : yabai -m window --swap west
  #   ${mod} + shift - k : yabai -m window --swap east
  #   ${mod} + shift + ctrl - j : yabai -m window --space next
  #   ${mod} + shift + ctrl - k : yabai -m window --space prev

  #   ${mod} - 0x12 : yabai -m space --focus 1 2>/dev/null
  #   ${mod} - 0x13 : yabai -m space --focus 2 2>/dev/null
  #   ${mod} - 0x14 : yabai -m space --focus 3 2>/dev/null
  #   ${mod} - 0x15 : yabai -m space --focus 4 2>/dev/null
  #   ${mod} - 0x17 : yabai -m space --focus 5 2>/dev/null
  #   ${mod} - 0x16 : yabai -m space --focus 6 2>/dev/null
  #   ${mod} - 0x1A : yabai -m space --focus 7 2>/dev/null
  #   ${mod} - 0x1C : yabai -m space --focus 8 2>/dev/null
  #   ${mod} - 0x19 : yabai -m space --focus 9 2>/dev/null

  #   ${mod} + shift - return : kitty --single-instance --working-directory /Users/god
  #   ${mod} - space : yabai -m space --layout `yabai -m query --spaces | jq -r 'map(select(."has-focus")) | .[0].type as $current | {layouts: ["bsp", "stack", "float"]} | { layouts: .layouts, next: (.layouts | (index($current) + 1) % 3)} | nth(.next; .layouts[])'`
  # '';
}
