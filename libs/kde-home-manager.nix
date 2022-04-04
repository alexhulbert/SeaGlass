{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.kde;

  baseDir = "plasma-workspace/env";

  # TODO: this isn't done yet
  environmentFile = pkgs.writeScript "10-environment.sh" (lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v:
    ''# export ${k}="${toString v}"''
  ) (config.home.sessionVariables // config.programs.bash.sessionVariables)));

  settingsFile = pkgs.writeScript "50-kde-settings.sh" ''
    ${cfg.scriptHeader}

    # extraSettings
    ${cfg.extraSettings}

    # settings
    for f in ${lib.concatStringsSep " " (lib.attrNames cfg.settings)}; do
      echo "Processing: $f"
      ${lib.getBin pkgs.crudini}/bin/crudini --merge \
        ${config.xdg.configHome}/$f < \
        ${etcDrv}/etc/$f || true
    done
  '';

  actualFiles = [
    { sequence = "01"; name = "peterpeter"; contents = "# hello world"; }
    { sequence = "10"; name = "woot"; contents = "# bar"; }
  ] ++ cfg.files;

  etcDrv = pkgs.stdenv.mkDerivation {
    pname = "kde-settings";
    version = toString (builtins.length (lib.attrNames cfg.settings));

    buildCommand = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v:
      "install -Dm444 ${pkgs.writeText k (lib.generators.toINI {} v)} $out/etc/${k}"
    ) cfg.settings);
  };

in {
  meta.maintainers = with maintainers; [ peterhoeg ];

  options = {
    programs.kde = {
      enable = mkEnableOption "KDE";

      scriptHeader = mkOption {
        default = "";
        description = "Extra settings added to the top of scripts.";
        type = types.lines;
      };

      extraSettings = mkOption {
        default = "";
        description = "Extra settings added verbatim.";
        type = types.lines;
      };

      settings = mkOption {
        default = {};
        example = literalExample ''{ kwinrc = { General.Foo = "bar"; }; }'';
        description = "KDE settings";
        type = types.attrs;
      };

      files = mkOption {
        default = [];
        description = "The files we write.";
        type = types.listOf types.attrs;
      };
    };
  };

  config = mkIf cfg.enable {
    # xdg.configFile = builtins.listToAttrs (e:
    #   lib.nameValuePair
        
    # ) actualFiles;
    #   target = "${baseDir}/${toString e.sequence}-${e.name}.sh";
    #   text = e.contents;
    # }) actualFiles;

    xdg.configFile."${baseDir}/${environmentFile.name}".source = environmentFile;
    xdg.configFile."${baseDir}/${settingsFile.name}".source = settingsFile;
  };
}

