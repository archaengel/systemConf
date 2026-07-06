{
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation {
  pname = "macbook12-spi-driver";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Heratiki";
    repo = "macbook12-spi-driver";
    rev = "touchbar-driver-hid-driver";
    hash = "sha256-hkPfoX1PLNCNu2YoxbX7vvbOP6nwDXL8QyusYMaitf0=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  # postPatch = ''
  #   # HID fixup const removal
  #   sed -i 's/static const __u8 \*appleib_report_fixup/static __u8 *appleib_report_fixup/' apple-ibridge.c

  #   # appletb platform remove fix
  #   sed -i 's/static void appletb_platform_remove/static int appletb_platform_remove/' apple-ib-tb.c
  #   sed -i '/static int appletb_platform_remove/,/^}/ s/^\(\s*\)return;$/\1return 0;/' apple-ib-tb.c
  #   sed -i '/static int appletb_platform_remove/,/^}/ { /return 0;/! s/^}$/\treturn 0;\n}/ }' apple-ib-tb.c

  #   # appleals platform remove fix
  #   sed -i 's/static void appleals_platform_remove/static int appleals_platform_remove/' apple-ib-als.c
  #   sed -i '/static int appleals_platform_remove/,/^}/ s/^\(\s*\)return;$/\1return 0;/' apple-ib-als.c
  #   sed -i '/static int appleals_platform_remove/,/^}/ { /return 0;/! s/^}$/\treturn 0;\n}/ }' apple-ib-als.c
  # '';

  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      modules
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/extra/
  '';
}
