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
  #safe-termfilechooser = (
  #pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs (
  #finalAttrs: prevAttrs: {
  #patches = [
  #../../patches/xdg-desktop-portal-termfilechooser.patch
  #];
  #}
  #)
  #);

  gj = pkgs.writeShellScriptBin "gj" ''
    rev=$1; shift
    bm=$(jj bookmark list -r $rev -T name)

    gh "$@" $bm
  '';

in
{
  imports = [
    ../../modules/home/jujutsu.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/tmux.nix
    ../../modules/home/qutebrowser.nix
  ];

  home = {
    inherit username;
    sessionVariables = {
      EDITOR = "nvim";
    };
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      delta
      discord
      dotfiles.packages.${pkgs.system}.nvim
      gh
      gj
      (google-cloud-sdk.withExtraComponents (
        with google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))
      grimblast
      hyprnotify
      jq
      kubectl
      ncspot
      nixfmt-rfc-style
      nmap
      pavucontrol
      playerctl
      ripgrep
      slack
      spotify
      swappy
      terraform
      twingate
      uutils-coreutils-noprefix
    ];
  };
  programs.home-manager.enable = true;

  xdg.mimeApps.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-termfilechooser
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
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
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

  programs.git = {
    enable = true;
    userName = username;
    userEmail = "god11341258@gmail.com";
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  # TODO: Checkout `dotDir` to attempt to setup nixCats-style unwrapped rc for
  # quick development loops on the zsh config
  programs.zsh = {
    defaultKeymap = "viins";
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    initContent = ''
      [[ ! -f ${./p10k.zsh} ]] || source ${./p10k.zsh}
    '';
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    shellAliases = {
      lr = "ls -hartl";
    };
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
}
