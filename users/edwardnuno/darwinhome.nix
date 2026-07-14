{
  pkgs,
  dotfiles,
  username,
  glide-browser,
  ...
}:

let
  gj = pkgs.writeShellScriptBin "gj" ''
    rev=$1; shift
    bm=$(jj bookmark list -r $rev -T name)

    gh "$@" $bm
  '';
  isDarwin = system: (builtins.elem pkgs.hostPlatform.system pkgs.lib.platforms.darwin);
  homePrefix = if isDarwin pkgs.hostPlatform.system then "/Users" else "/home";
in
{
  imports = [
    ../../modules/home/jujutsu.nix
    ../../modules/home/tmux.nix
  ];

  home = {
    inherit username;
    sessionVariables = {
      EDITOR = "nvim";
    };
    homeDirectory = "${homePrefix}/${username}";
    packages = with pkgs; [
      autossh
      delta
      dotfiles.packages.${stdenv.hostPlatform.system}.nvim
      fzf
      gh
      gj
      utm
      lima
      glide-browser.packages.${stdenv.hostPlatform.system}.glide-browser-bin
      (google-cloud-sdk.withExtraComponents (
        with google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))
      google-cloud-sql-proxy
      jq
      kubectl
      nixfmt
      nmap
      meld
      mergiraf
      patchelf
      quickemu
      ripgrep
      slack
      spotify
      terraform
      unison-ucm
      cloudflare-warp
    ];
  };
  programs.home-manager.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    keymap = {
      manager.prepend_keymap = [
        {
          on = "y";
          run = [
            "shell 'for path in \"$@\"; do echo \"file://$path\"; done | pbcopy text/uri-list'"
            "yank"
          ];
        }
      ];
    };
  };

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs-git-nox;
    extraPackages =
      epkgs: with epkgs; [
        ghostel
        tree-sitter
        treesit-grammars.with-all-grammars
      ];
    extraBinPackages = with pkgs; [
      ripgrep
      fd
      typescript-language-server
      nixd
      prettier
      eslint_d
    ];
    provideEmacs = false;
    doomDir = "${dotfiles}/doom/.config/doom";
  };

  programs.emacs = {
    enable = true;
    package = dotfiles.packages.${pkgs.stdenv.hostPlatform.system}.emacs;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = username;
        email = "god11341258@gmail.com";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
    lfs.enable = true;
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

      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line
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
}
