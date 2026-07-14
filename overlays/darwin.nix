{ pkgs, ... }:
with pkgs;
(final: prev: {

  borders = callPackage ./packages/borders { };

  zsh-jj = callPackage ./packages/zsh-jj { };
})
