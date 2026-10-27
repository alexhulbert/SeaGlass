{ config, pkgs, lib, repoPath, ... }: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  iconDirectory = "${config.xdg.stateHome}/seaglass/icons";
  overrides = config.seaglass.iconOverrides;
  papirus = pkgs.fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "papirus-colors";
    rev = "0474c96a4eafcf76cc0d55501025375a51e495df";
    hash = "sha256-oY7PO7KLFwnqApEdWusL6+2freNArRhsoHayjjrNLW0=";
  };
  yamis = pkgs.fetchzip {
    url = "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set/get/227359bea788.tar.gz";
    hash = "sha256-auY9G706HBivoGJCiUvDKouTnu2AvpJOcPVw5ZFS73c=";
  };
  iconSource = pkgs.runCommand "seaglass-icon-source" {} ''
    mkdir -p "$out"
    for theme in Papirus-Colors Papirus-Colors-Dark; do
      cp -r --no-preserve=mode ${papirus}/$theme "$out/$theme"
      cp -r --no-preserve=mode ${yamis}/apps "$out/$theme/apps"
      sed -i '/^Directories=/s|$|,apps/16,apps/scalable|' "$out/$theme/index.theme"
      sed -n '/^\[apps\//,/^$/p' ${yamis}/index.theme >> "$out/$theme/index.theme"
      for pair in ${lib.escapeShellArgs (lib.mapAttrsToList (name: icon: "${name}:${icon}") overrides)}; do
        test -f "$out/$theme/apps/scalable/''${pair#*:}.svg"
        ln -sf "''${pair#*:}.svg" "$out/$theme/apps/scalable/''${pair%:*}.svg"
      done
    done
  '';
  iconCommand = "/usr/bin/python ${lib.escapeShellArg "${repoPath}/modules/home/desktop/icons/recolor.py"} ${iconSource} ${lib.escapeShellArg iconDirectory} ${lib.escapeShellArg "${config.xdg.cacheHome}/papirus-colors.json"}";
in {
  options.seaglass.iconOverrides = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "App icon names mapped to YAMIS icons.";
  };

  config = {
    xdg.dataFile."icons/Papirus-Colors".source = mkOutOfStoreSymlink "${iconDirectory}/Papirus-Colors";
    xdg.dataFile."icons/Papirus-Colors-Dark".source = mkOutOfStoreSymlink "${iconDirectory}/Papirus-Colors-Dark";

    home.activation.papirusColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${iconCommand}
    '';

    seaglass.matugen.templates.papirus-colors = {
      input_path = "${repoPath}/modules/home/desktop/icons/palette.json";
      output_path = "${config.xdg.cacheHome}/papirus-colors.json";
      post_hook = iconCommand;
    };
  };
}
