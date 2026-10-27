{ lib, stdenvNoCC, stdenv, fetchurl, autoPatchelfHook, zstd }:
stdenvNoCC.mkDerivation (final: {
  pname = "spicetify-cli";
  version = "3.0.0-rc.3";
  src = fetchurl {
    url = "https://github.com/spicetify/cli/releases/download/v${final.version}/spicetify-${final.version}-linux-x86_64.tar.zst";
    hash = "sha256-0Y405jtLtAU7oEaYQXdt+/BxHl2jbqwauZsiSHQx7vo=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook zstd ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontBuild = true;
  installPhase = ''
    install -Dm755 spicetify spicetify-daemon -t "$out/bin"
    install -Dm644 ${fetchurl {
      url = "https://raw.githubusercontent.com/spicetify/cli/v${final.version}/rust/LICENSE";
      hash = "sha256-7xb8hSwDqpCctV065j0x+Ldiq6zPDLUUShSb+Azl1wE=";
    }} "$out/share/licenses/spicetify/LICENSE"
  '';
  meta = {
    mainProgram = "spicetify";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
