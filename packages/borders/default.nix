{
  stdenv,
  fetchFromGitHub,
  darwin,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "borders";
  version = "main";
  src = fetchFromGitHub {
    repo = "JankyBorders";
    owner = "FelixKratz";
    rev = "29c657b50c83d73b1f2806fb981fa48fa4929ecb";
    sha256 = "sha256-CgXd5pQFR4MW88uDXcBh9D+HCzwMRRvLwmastrOhOSM=";
  };

  buildInputs = with darwin.apple_sdk.frameworks; [
    CoreGraphics
    ApplicationServices
    AppKit
    pkgs.darwin.apple_sdk_11_0.frameworks.SkyLight
  ];

  patches = [ ./borders.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/borders $out/bin
  '';

  meta = {
    description = "Borders around active windows";
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
