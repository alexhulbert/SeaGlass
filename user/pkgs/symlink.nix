{ config
, pkgs
, lib
, ...
}:

let
  cfg = config.outOfStoreSymlinks;
  
  # Helper to convert attrs to format: "baseDir/src|dest"
  attrsToList = baseDir: attrs: builtins.map
    (src: "${baseDir}/${src}|${builtins.getAttr src attrs}")
    (builtins.attrNames attrs);

  # Combine all symlinks into a single list
  allSymlinks = 
    (attrsToList "${config.home.homeDirectory}" (cfg.home or { })) ++
    (attrsToList "${config.xdg.configHome}" (cfg.xdgConfig or { })) ++
    (attrsToList "${config.xdg.dataHome}" (cfg.xdgData or { }));

  # Path to symlink state file
  stateFile = "${config.xdg.dataHome}/home-manager/symlinks";
in
{
  options.outOfStoreSymlinks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
    default = {
      xdgConfig = { };
      xdgData = { };
      home = { };
    };
    description = "A map of files to symlink out of store";
  };

  config.home.activation.touchOutOfStoreSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname "${stateFile}")"
    touch "${stateFile}"
    
    # Read current symlinks from state file
    old_symlinks=$(cat "${stateFile}")
    
    # Generate new symlinks list
    new_symlinks="${builtins.concatStringsSep "\n" allSymlinks}"
    
    # Remove old symlinks not in new config
    echo "$old_symlinks" | while IFS='|' read -r src dest; do
      if ! echo "$new_symlinks" | grep -q "^$src|"; then
        rm "$src" 2>/dev/null || true
      fi
    done
    
    # Create new symlinks
    echo "$new_symlinks" | while IFS='|' read -r src dest; do
      rm "$src" 2>/dev/null || true
      ln -s "$dest" "$src"
    done
    
    # Update state file
    echo "$new_symlinks" > "${stateFile}"
  '';
}