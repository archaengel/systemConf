{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "zsh-jj";
  version = "0.1.0";
  src = fetchFromGitHub {
    # https://github.com/rkh/zsh-jj/blob/main/README.md
    owner = "rkh";
    repo = "zsh-jj";
    rev = "b6453d6ff5d233d472e5088d066c6469eb05c71b";
    hash = "sha256-GDHTp53uHAcyVG+YI3Q7PI8K8M3d3i2+C52zxnKbSmw=";
  };

  installPhase = ''
    mkdir -p $out/share/zsh-jj

    cp -R functions $out/share/zsh-jj

    echo "fpath+=\"$out/share/zsh-jj/functions\"" > $out/share/zsh-jj/zsh-jj.plugin.zsh
    echo "autoload -Uz vcs_info" >> $out/share/zsh-jj/zsh-jj.plugin.zsh
    echo "autoload -U colors && colors" >> $out/share/zsh-jj/zsh-jj.plugin.zsh
    echo "zstyle ':vcs_info:*' enable jj git" >> $out/share/zsh-jj/zsh-jj.plugin.zsh
  '';
}
