{ config
, pkgs
, lib
, ...
}:

let
  cfg = config.outOfStoreSymlinks;
  mapSymlinksToCmds = (baseDir: symlinks: builtins.map
    (src: (
      let
        dest = builtins.getAttr src symlinks;
      in
      ''
        rm "${baseDir}/${src}" || true 2> /dev/null
        touch "${dest}"
        ln -s "${dest}" "${baseDir}/${src}"
      ''
    ))
    (builtins.attrNames symlinks)
  );
in
{
  # Allows symlinking without the file being created beforehand
  options.outOfStoreSymlinks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
    default = {
      xdgConfig = { };
      xdgData = { };
      home = { };
    };
    description = "A map of files to symlink out of store";
  };

  config.home.activation.touchOutOfStoreSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.concatStringsSep "\n" (
      (mapSymlinksToCmds "${config.home.homeDirectory}" (cfg.home or { })) ++
      (mapSymlinksToCmds "${config.xdg.configHome}" (cfg.xdgConfig or { })) ++
      (mapSymlinksToCmds "${config.xdg.dataHome}" (cfg.xdgData or { }))
    )
  );
}
