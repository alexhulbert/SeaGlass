{ pkgs }:
{ name, cmds }:

let
  pName = name;
in pkgs.stdenv.mkDerivation rec {
  name = pName;
  builder = pkgs.writeShellScript "builder" ''
    ${pkgs.coreutils}/bin/mkdir -p $out/bin
    for cmd in "${builtins.concatStringsSep " " cmds}"
    do
      ${pkgs.coreutils}/bin/ln -s /usr/bin/$cmd $out/bin/$cmd
    done
  '';
}
