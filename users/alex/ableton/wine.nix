{ pkgs }:
let
  upstream = pkgs.fetchFromGitHub {
    owner = "shibco";
    repo = "ableton-linux";
    rev = "aceb236a81656c609274afbf27fd54eb5017e5e2";
    hash = "sha256-be3tn4FY7Nl7ITw7+/XyjuR59q0uWrTLUQOtIyNGhNA=";
  };
  reference = pkgs.callPackage "${upstream}/nix/wine.nix" {
    wineSrc = "${upstream}/vendor/wine-base-5c23dd1c.tar.zst";
    patchesDir = "${upstream}/patches";
    ntsyncUapi = "${upstream}/vendor/ntsync-uapi";
  };
in
(pkgs.wineWow64Packages.unstable.override {
  gstreamerSupport = true;
}).overrideAttrs (old: {
  pname = "wine-ableton";
  version = "11.13-aceb236";
  src = reference.src;
  sourceRoot = "source";
  nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.zstd pkgs.gitMinimal ];
  unpackPhase = ''
    runHook preUnpack
    mkdir source
    zstd -dc --long=27 "$src" | tar -x -C source
    runHook postUnpack
  '';
  prePatch = reference.postUnpack;
  patches = (old.patches or []) ++ [
    ./wine-wayland-surface-clip.patch
    ./wine-wayland-popup-management.patch
    ./wine-wayland-scale-lock.patch
    ./wine-wayland-frame-contents.patch
  ];
  configureFlags = old.configureFlags ++ [ "--disable-tests" "--with-gstreamer" ];
  postConfigure = ''
    grep -q '^#define HAVE_LINUX_NTSYNC_H 1' include/config.h
  '';
  postInstall = (old.postInstall or "") + ''
    test -s "$out/lib/wine/x86_64-unix/winewayland.so"
    test -s "$out/lib/wine/x86_64-windows/winewayland.drv"
    test -s "$out/lib/wine/x86_64-unix/winealsa.so"
    test -s "$out/lib/wine/x86_64-unix/winegstreamer.so"
  '';
  meta = old.meta // {
    description = "Ableton Linux's complete Wine patch series with native Wayland";
    homepage = "https://github.com/shibco/ableton-linux";
  };
})
