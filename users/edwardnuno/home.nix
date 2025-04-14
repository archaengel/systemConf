{
  config,
  pkgs,
  nixvim,
  dotfiles,
  username,
  ...
}:

let
  # TODO: Should put this in an overlay
  # The original package overrides the PATH var in the wrapper script
  # which prevents systems without `sed` in `usr/bin:bin` from executing
  # the service.
  safe-termfilechooser = (
    pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs (
      finalAttrs: prevAttrs: {
        patches = [
          ../../patches/xdg-desktop-portal-termfilechooser.patch
        ];
      }
    )
  );

in
{
  home = {
    inherit username;
    sessionVariables = {
      EDITOR = "nvim";
    };
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      nixfmt-rfc-style
      swappy
      grimblast
      gh
      dotfiles.packages.${pkgs.system}.nvim
      playerctl
      slack
      spotify
      pavucontrol
    ];
  };
  programs.home-manager.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      safe-termfilechooser
    ];
    config = {
      common = {
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    text = ''
      [filechooser]
      cmd=${safe-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      env=TERMCMD=ghostty -e
    '';
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
      manager.prepend_keymap = [
        {
          on = "y";
          run = [
            "shell 'for path in \"$@\"; do echo \"file://$path\"; done | wl-copy -t text/uri-list'"
            "yank"
          ];
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        cursor = false;
      };
      background = {
        path = "screenshot";
        blur_passes = 2;
      };
      input-field = {
        size = "400, 50";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(0, 0, 0)";
        inner_color = "rgb(200, 200, 200, 0.1)";
        outer_color = "rgb(24, 25, 38)";
        outline_thickness = 3;
        placeholder_text = "...";
        rounding = 4;
      };
      label = {
        monitor = "";
        font_size = 48;
        font_family = "Jet Brains Mono";
        text = "$TIME";
        halign = "center";
        valign = "center";
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "hyprlock";
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [
        "${../../modules/wallpaper/blueghost_firefly.jpg}"
      ];
      wallpaper = [
        " , ${../../modules/wallpaper/blueghost_firefly.jpg}"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 16;
        spacing = 3;

        "modules-left" = [
          "hyprland/workspaces"
          "group/usage"
        ];
        "modules-center" = [ "clock" ];
        "modules-right" = [
          "wireplumber"
          "group/bat"
          "group/net"
          "tray"
        ];

        "group/usage" = {
          "orientation" = "horizontal";
          "modules" = [
            "memory"
            "temperature"
          ];
        };

        "group/bat" = {
          "orientation" = "horizontal";
          "modules" = [
            "battery"
            "backlight"
          ];
        };

        "group/net" = {
          "orientation" = "horizontal";
          "modules" = [
            "hyprland/language"
            "network"
            "bluetooth"
          ];
        };

        "hyprland/workspaces" = {
          "format" = "{icon}";
          "on-click" = "activate";
          "format-icons" = {
            "1" = "";
            "2" = "";
            "3" = "󰖟";
            "4" = "󰀻";
            "5" = "󰓇";
          };
          "icon-size" = 20;
          "sort-by-number" = true;
          "persistent-workspaces" = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "clock" = {
          "format" = "{:%d.%m.%Y | %H:%M}";
        };

        "wireplumber" = {
          "format" = "󰖀 {volume}%";
          "max-volume" = 100;
          "scroll-step" = 5;
        };

        "battery" = {
          "bat" = "BAT1";
          "interval" = 60;
          "format" = "{icon}  {capacity}%";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "backlight" = {
          "format" = "󰃞 {percent}%";
        };

        "memory" = {
          "interval" = 30;
          "format" = "󰍛 {used:0.1f}G";
        };

        "temperature" = {
          "format" = " {temperatureC}°C";
        };

        "network" = {
          "format" = "";
          "format-ethernet" = "󰲝 ";
          "format-wifi" = "{icon} ";
          "format-disconnected" = "󰲜 ";
          "format-icons" = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          "tooltip-format-wifi" = "{essid} ({signalStrength}%)";
          "tooltip-format-ethernet" = "{ifname}";
          "tooltip-format-disconnected" = "Disconnected";
        };

        "bluetooth" = {
          "format" = "󰂯";
          "format-disabled" = "󰂲";
          "format-connected" = "󰂱";
          "tooltip-format" = "{controller_alias}\t{controller_address}";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
        };

        "hyprland/language" = {
          "format" = "{short}";
        };

        "tray" = {
          "icon-size" = 16;
          "spacing" = 16;
        };
      };
    };
    style = ''
      @define-color foreground #eff0f1;
      @define-color foreground-inactive #7f8c8d;
      @define-color background #232629;
      @define-color background-alt #31363b;

      * {
          font-family: JetBrainsMono Nerd Font;
          font-size: 12px;
          padding: 0;
          margin: 0;
      }

      #waybar {
          color: @foreground;
          background-color: @background;
      }

      #workspaces button {
          padding-left: 1em;
          padding-right: 1.3em;
      }

      #workspaces button.empty {
          color: @foreground-inactive;
      }

      #workspaces button.active {
          background-color: @background-alt;
          border-radius: 3px;
      }

      #wireplumber,
      #bat,
      #tray,
      #usage,
      #net {
          background-color: @background-alt;
          border-radius: 3px;
          padding-left: 0.5em;
          padding-right: 0.5em;
          margin-left: 0.3em;
      }

      #battery,
      #memory,
      #language,
      #network {
          margin-right: 0.8em;
      }
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile "${dotfiles}/tmux/.tmux.conf";
  };

  programs.git = {
    enable = true;
    userName = username;
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

  programs.wofi = {
    enable = true;
    settings = {
      gtk_dark = true;
      prompt = "";
      term = "ghostty";
    };
    style = ''
      * {
        font-family: JetBrainsMono;
        color: #e5e9f0;
        background: transparent;
      }

      #window {
        background: rgba(41, 46, 66, 0.5);
        margin: auto;
        padding: 16px;
        border-radius: 4px;
        border: 2px solid #33ccff;
      }

      #input {
        padding: 2px;
        padding-left: 4px;
        margin-bottom: 8px;
        border-radius: 4px;
      }

      #outer-box {
        padding: 8px;
      }

      #img {
        margin-right: 6px;
      }

      #entry {
        padding: 4px;
        border-radius: 4px;
      }

      #entry:selected {
        background-color: #2e3440;
      }

      #text {
        margin: 0px;
      }
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mainMod" = "ALT";
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.hyprpaper}/bin/hyprpaper"
      ];
    };
    extraConfig = ''
      # This is an example Hyprland config file.
      # Refer to the wiki for more information.
      # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

      # Please note not all available settings / options are set here.
      # For a full list, see the wiki

      # You can split this configuration into multiple files
      # Create your files separately and then link them to this file like this:
      # source = ~/.config/hypr/myColors.conf


      ################
      ### MONITORS ###
      ################

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=,preferred,auto,auto


      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      $terminal = ghostty
      $fileManager = ghostty -e yazi
      $menu = wofi --show drun


      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      env = GRIMBLAST_EDITOR,swappy -f 


      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general { 
          gaps_in = 5
          gaps_out = 20

          border_size = 2

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false 

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false

          layout = dwindle
      }

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration {
          rounding = 10

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 1.0

          shadow {
               enabled = true
               range = 4
               render_power = 3
               color = rgba(1a1a1aee)
          }

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 3
              passes = 1
              vibrancy = 0.1696
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations {
          enabled = true

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # You probably want this
      }

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc { 
          force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
      }


      #############
      ### INPUT ###
      #############

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options = ctrl:nocaps
          kb_rules =

          follow_mouse = 1

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          touchpad {
              natural_scroll = false
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures {
          workspace_swipe = false
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device {
          name = epic-mouse-v1
          sensitivity = -0.5
      }


      ####################
      ### KEYBINDINGSS ###
      ####################

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
      bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%

      bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl = , XF86AudioPlay, exec, playerctl play-pause

      bind = , Print, exec, grimblast edit area
      bind = $mainMod, Q, exec, $terminal
      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, pkill wofi || $menu
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle

      # Move focus with mainMod + arrow keys
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, focusworkspaceoncurrentmonitor, 1
      bind = $mainMod, 2, focusworkspaceoncurrentmonitor, 2
      bind = $mainMod, 3, focusworkspaceoncurrentmonitor, 3
      bind = $mainMod, 4, focusworkspaceoncurrentmonitor, 4
      bind = $mainMod, 5, focusworkspaceoncurrentmonitor, 5
      bind = $mainMod, 6, focusworkspaceoncurrentmonitor, 6
      bind = $mainMod, 7, focusworkspaceoncurrentmonitor, 7
      bind = $mainMod, 8, focusworkspaceoncurrentmonitor, 8
      bind = $mainMod, 9, focusworkspaceoncurrentmonitor, 9
      bind = $mainMod, 0, focusworkspaceoncurrentmonitor, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Example special workspace (scratchpad)
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow


      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      # Example windowrule v1
      # windowrule = float, ^(kitty)$

      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

      windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

      layerrule = blur, wofi
      layerrule = ignorealpha 0, wofi
    '';
  };
}
