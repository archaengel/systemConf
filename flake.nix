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
      "https://nix-community.cachix.org"
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

    nix-rpi5 = {
      url = "gitlab:vriska/nix-rpi5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:archaengel/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    fw-fanctrl = {
      url = "github:TamtamHero/fw-fanctrl/packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixvim,
      dotfiles,
      ghostty,
      fw-fanctrl,
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

        "1134-gsfw" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = with nonPersonalArgs; [
            fw-fanctrl.nixosModules.default
            ./machines/1134-gsfw/configuration.nix
            ./users/${username}/nixos.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./machines/1134-gsfw/home.nix;
              home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
              home-manager.extraSpecialArgs = inputs // nonPersonalArgs;
              home-manager.backupFileExtension = "backup";
            }
          ];

          specialArgs = inputs // nonPersonalArgs;
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
    };
}
