{ lib, config, pkgs, inputs, ... }: let
  repoPath = "${config.xdg.configHome}/home-manager";
  mergeJson = pkgs.writeShellScript "merge-json" ''
    target=$(realpath -m -- "$1")
    shift
    mkdir -p "$(dirname -- "$target")"
    tmp=$(mktemp -- "$target.XXXXXX")
    trap 'rm -f -- "$tmp"' EXIT
    ${pkgs.jq}/bin/jq -s 'reduce .[] as $x ({}; . * $x)' <([[ -s $target ]] && cat -- "$target" || echo '{}') "$@" > "$tmp"
    mv -f -- "$tmp" "$target"
  '';
in {
  imports = [
    ./programs/git.nix
    ./programs/terminal.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  options.seaglass.jsonSettings = lib.mkOption {
    type = lib.types.attrsOf (pkgs.formats.json {}).type;
    default = {};
    description = "Sets properties in json files without overwriting the whole file";
  };

  config._module.args = { inherit repoPath mergeJson; link = path: config.lib.file.mkOutOfStoreSymlink "${repoPath}/${path}"; };
  config.news.display = "silent";
  config.home.packages = [ pkgs.comma ];
  config.home.stateVersion = lib.mkDefault "22.11";
  config.programs.home-manager.enable = true;
  config.programs.man.package = null;
  config.systemd.user.sessionVariables.DISABLE_TELEMETRY = "true";
  config.home.activation.jsonSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] (lib.concatStrings (lib.mapAttrsToList (path: value:
    "run ${mergeJson} ${lib.escapeShellArg path} ${(pkgs.formats.json {}).generate (baseNameOf path) value}\n"
  ) config.seaglass.jsonSettings));
}
