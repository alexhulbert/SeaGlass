{ config
, pkgs
, lib
, ...
}:

let
  cfg = config.mutableConfig;

  # Helper to generate activation script for a single file
  makeActivationScript = filePath: settings: let
    jsonFormat = pkgs.formats.json {};
  in ''
    tmp="$(mktemp)"
    touch "${filePath}"
    if [[ -v DRY_RUN ]]; then
      echo tmp="\$(mktemp)"
      echo ${pkgs.jq}/bin/jq -s "'reduce .[] as \$x ({}; . * \$x)'" "${filePath}" "${
        jsonFormat.generate "user-settings" settings
      }" ">" "$tmp"
    else
      ${pkgs.jq}/bin/jq -s 'reduce .[] as $x ({}; . * $x)' "${filePath}" "${
        jsonFormat.generate "user-settings" settings
      }" > "$tmp"
    fi
    $DRY_RUN_CMD mv "$tmp" "${filePath}"
  '';

  # Convert the attribute set of file configs into activation scripts
  allActivationScripts = lib.concatStrings (
    lib.mapAttrsToList makeActivationScript cfg.files
  );
in
{
  options.mutableConfig = {
    files = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Attribute set mapping file paths to their settings";
    };
  };

  config = {
    # Disable home manager's management of configured files
    home.file = lib.mkMerge (
      lib.mapAttrsToList (file: _: {
        ${file}.enable = lib.mkForce false;
      }) cfg.files
    );

    # Add activation script to merge settings
    home.activation.injectMutableSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${allActivationScripts}
    '';
  };
}