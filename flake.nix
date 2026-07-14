{
  description = "archaengel's NixOS Flake";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
    ];

    extra-substituters = [

    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # The nixpkgs entry in the flake registry.
    nixpkgsRegistry.url = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };

    unison-lang = {
      url = "github:ceedubs/unison-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-rpi5 = {
      url = "gitlab:vriska/nix-rpi5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    dotfiles = {
      url = "github:archaengel/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide-browser = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixvim,
      microvm,
        nix-darwin,
      nix-doom-emacs-unstraightened,
      ...
    }:
    let
      personalUser = "archaengel";
      personalArgs = {
        username = personalUser;
      };
      nonPersonalUser = "edwardnuno";
      nonPersonalArgs = {
        username = nonPersonalUser;
      };
    in
    {
      nixosConfigurations = {
        "1134-nixos" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = with personalArgs; [
            ./machines/1134-nixos/configuration.nix
            ./users/${username}/nixos.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/1134-nixos/home.nix;
              home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
              home-manager.extraSpecialArgs = inputs // personalArgs;
            }
          ];

          specialArgs = inputs // personalArgs;
        };

        "1134-nixmac" = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = with personalArgs; [
            ./machines/1134-nixmac/configuration.nix
            ./users/${username}/nixos.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/1134-nixmac/home.nix;
              home-manager.sharedModules = [
                nixvim.homeManagerModules.nixvim
              ];
              home-manager.extraSpecialArgs = inputs // personalArgs;
              home-manager.backupFileExtension = "backup";
            }
          ];

          specialArgs = inputs // personalArgs // { inherit system; };
        };
        "1134-gsfw" = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = with nonPersonalArgs; [
            ./machines/1134-gsfw/configuration.nix
            ./users/${username}/nixos.nix
            home-manager.nixosModules.home-manager
            microvm.nixosModules.host
            ./microvm.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/1134-gsfw/home.nix;
              home-manager.sharedModules = [
                nixvim.homeManagerModules.nixvim
                nix-doom-emacs-unstraightened.homeModule
              ];
              home-manager.extraSpecialArgs = inputs // nonPersonalArgs;
              home-manager.backupFileExtension = "backup";
            }
          ];

          specialArgs = inputs // nonPersonalArgs // { inherit system; };
        };

        "nixpi5" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = with personalArgs; [
            ./machines/nixpi5/configuration.nix
            ./users/${username}/nixos.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/nixpi5/home.nix;
              home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
              home-manager.extraSpecialArgs = inputs // personalArgs;
            }
          ];

          specialArgs = inputs // personalArgs;
        };
      };

      darwinConfigurations."gsmac" = nix-darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          modules = with nonPersonalArgs; [
            ./machines/gsmac/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/gsmac/home.nix;
              home-manager.sharedModules = [
                nix-doom-emacs-unstraightened.homeModule
              ];
              home-manager.extraSpecialArgs = inputs // nonPersonalArgs;
              home-manager.backupFileExtension = "backup";
            }
          ];

          specialArgs = inputs // nonPersonalArgs // { inherit system; };
      };
    };
}
