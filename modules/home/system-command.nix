{ pkgs }:
names: let
  list = pkgs.lib.toList names;
in pkgs.runCommand (builtins.head list) { meta.mainProgram = builtins.head list; } ''
  mkdir -p "$out/bin"
  ${pkgs.lib.concatMapStrings (name: "ln -s /usr/bin/${name} \"$out/bin/${name}\"\n") list}
''
