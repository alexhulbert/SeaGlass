# a nix home manager module that accepts a single array for configuration called "templates"
# each template has a source string, destination string, and filename
# the source string is symlinked into ~/.config/wal/templates/$filename
# ~/.cache/wal/$filename is symlinked to $destination
# the module also adds a hook to the home-manager activation script to create ~/.cache/wal/$filename if it doesn't exist

{ config, lib, pkgs, ... }:

let
  cfg = config.pywalTemplates;
in {
  options.pywalTemplates = lib.mkOption {
    type = lib.types.listOf (lib.types.attrsOf {
      source = lib.types.string;
      destination = lib.types.string;
      filename = lib.types.string;
    });
    default = [];
    description = "List of templates to configure pywal";
  };

  config = lib.mkIf (cfg != []) {
    home.file = (builtins.foldl' (a: b: a // b) {} (map (template: {
      "${config.xdg.configHome}/wal/templates/${template.filename}".source = "${template.source}";
      "${template.destination}".source = "${config.xdg.cacheHome}/wal/${template.filename}";
    }) cfg));
    activation.mkPywalCacheFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      "mkdir -p ${config.xdg.cacheHome}/wal\n" +
      builtins.concatStringsSep "\n" (map (template: ''
        touch ${config.xdg.cacheHome}/wal/${template.filename}
      '') cfg)
    );
  };
}
