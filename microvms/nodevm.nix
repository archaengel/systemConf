{ pkgs, ... }:
{
  # Development environment for Go Protobuf
  environment.systemPackages = with pkgs; [
    nodejs_24
  ];
}
