{ config, lib, pkgs, ... }: let
  wine = pkgs.callPackage ./wine.nix {};
  prefix = "${config.xdg.dataHome}/wineprefixes/ableton";
  live = "${prefix}/drive_c/ProgramData/Ableton/Live 12 Suite";
  chromeFile = "${config.xdg.cacheHome}/ableton/wine-colors.reg";
  themeFile = "${config.xdg.cacheHome}/ableton/Seaglass.ask";
  windowsPath = path: "Z:${lib.replaceStrings [ "/" ] [ "\\" ] (toString path)}";
  wineasio = (pkgs.wineasio.override {
    wineWow64Packages.stable = wine;
  }).overrideAttrs {
    wineasio-settings = null;
    installPhase = ''
      runHook preInstall
      install -Dm644 build64/wineasio64.dll "$out/lib/wine/x86_64-windows/wineasio64.dll"
      install -Dm755 build64/wineasio64.dll.so "$out/lib/wine/x86_64-unix/wineasio64.dll.so"
      runHook postInstall
    '';
  };
  wineEnvironment = pkgs.runCommand "ableton-wine" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    makeWrapper ${wine}/bin/wine "$out/bin/wine" \
      --set WINEPREFIX ${lib.escapeShellArg prefix} \
      --set WINEARCH win64 \
      --set-default WINEDEBUG -all,+winediag \
      --prefix WINEDLLPATH : ${wineasio}/lib/wine \
      --prefix LD_LIBRARY_PATH : ${pkgs.pipewire.jack}/lib \
      --set WINEDLLOVERRIDES 'winex11.drv=d;winemenubuilder.exe=d;d3d10core,d3d11,dxgi=b' \
      --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
      --set VK_DRIVER_FILES ${pkgs.mesa}/share/vulkan/icd.d/intel_icd.x86_64.json \
      --set WINE_D3D_CONFIG csmt=0x1 \
      --set WINED3D_DCOMP_FORCE_FULL_REDRAW 1 \
      --set WINE_WIN32_FULLSCREEN_CLASS 'Ableton Live Window Class' \
      --set WINE_WIN32_RESIZABLE_CLASS 'Ableton Live Window Class' \
      --set WINE_DISABLE_UNIX_MOUNT_REPARSE 1 \
      --set WINEASIO_CLIENT_NAME Live \
      --set WINEASIO_NUMBER_INPUTS 0 \
      --set WINEASIO_NUMBER_OUTPUTS 2 \
      --set WINEASIO_AUTOSTART_SERVER off \
      --set WINEASIO_CONNECT_TO_HARDWARE on \
      --set WINEASIO_FIXED_BUFFERSIZE off \
      --set WINEASIO_PREFERRED_BUFFERSIZE 256 \
      --set PIPEWIRE_QUANTUM 256/48000 \
      --set PIPEWIRE_PROPS '{ jack.default-as-system = true }' \
      --unset DISPLAY
  '';
  launch = pkgs.writeShellApplication {
    name = "ableton-live";
    runtimeInputs = [ pkgs.util-linux ];
    text = ''
      output=$(/usr/bin/wpctl inspect @DEFAULT_AUDIO_SINK@)
      # PipeWire jack uses serial number to identify physical ports
      serial='object\.serial = "([0-9]+)"'
      [[ $output =~ $serial ]]
      export PIPEWIRE_NODE="''${BASH_REMATCH[1]}"
      arguments=()
      for argument in "$@"; do
        arguments+=("$(${wineEnvironment}/bin/wine winepath -w "$argument")")
      done
      exec chrt -r 10 ${wineEnvironment}/bin/wine \
        ${lib.escapeShellArg "${live}/Program/Ableton Live 12 Suite.exe"} "''${arguments[@]}"
    '';
  };
  desktop = pkgs.makeDesktopItem {
    name = "ableton";
    desktopName = "Ableton Live";
    genericName = "Digital Audio Workstation";
    exec = "${launch}/bin/ableton-live %F";
    icon = "ableton";
    categories = [ "AudioVideo" "Audio" "Midi" "Sequencer" ];
    mimeTypes = [ "application/x-ableton-live-set" "application/x-ableton-live-pack" ];
    startupNotify = true;
  };
  registry = pkgs.writeText "ableton.reg" ''
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Software\Wine]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\Drivers]
    "Graphics"="wayland"

    [HKEY_CURRENT_USER\Control Panel\Desktop]
    "LogPixels"=dword:000000c0

    [HKEY_CURRENT_USER\Software\Wine\DllOverrides]
    "winemenubuilder.exe"=""
    "concrt140"="native,builtin"
    "msvcp140"="native,builtin"
    "msvcp140_1"="native,builtin"
    "msvcp140_2"="native,builtin"
    "msvcp140_atomic_wait"="native,builtin"
    "msvcp140_codecvt_ids"="native,builtin"
    "vcruntime140"="native,builtin"
    "vcruntime140_1"="native,builtin"
    "vcruntime140_threads"="native,builtin"
    "d3d10core"="builtin"
    "d3d11"="builtin"
    "dxgi"="builtin"

    [HKEY_CLASSES_ROOT\CLSID\{48D0C522-BFCC-45CC-8B84-17F25F33E6E8}\InprocServer32]
    @="Z:${lib.replaceStrings [ "/" ] [ "\\\\" ] "${wineasio}/lib/wine/x86_64-unix/wineasio64.dll.so"}"
  '';
in {
  xdg.configFile."hypr/dms/profile.lua".text = ''
    hl.window_rule({
        name = "ableton-installer",
        match = {
            class = "^[Aa]bleton [Ll]ive.* [Ii]nstaller\\.(exe|tmp)$",
            title = "^Setup - Ableton Live.*$",
        },
        float = true,
        center = true,
        size = "700 500",
    })
    hl.window_rule({
        name = "ableton-dialogs",
        match = {
            class = "^[Aa]bleton [Ll]ive.*\\.exe$",
            title = "^(Open.*|Save.*|Export.*|Preferences|Settings|Authorization.*|Select.*|Browse.*)$",
        },
        float = true,
        center = true,
    })
  '';
  seaglass.matugen.templates.ableton = {
    input_path = "${./theme.ask}";
    output_path = themeFile;
  };
  seaglass.matugen.templates.ableton-chrome = {
    input_path = "${./wine-colors.reg}";
    output_path = chromeFile;
    post_hook = "${wineEnvironment}/bin/wine reg import ${lib.escapeShellArg (windowsPath chromeFile)}";
  };
  home.activation.ableton = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run /usr/bin/update-mime-database ${lib.escapeShellArg "${config.xdg.dataHome}/mime"}
    run /usr/bin/update-desktop-database ${lib.escapeShellArg "${config.xdg.dataHome}/applications"}
    run ${wineEnvironment}/bin/wine regsvr32 /s ${wineasio}/lib/wine/x86_64-unix/wineasio64.dll.so
    run ${wineEnvironment}/bin/wine reg import ${lib.escapeShellArg (windowsPath registry)}
    if [[ -f ${lib.escapeShellArg chromeFile} ]]; then
      run ${wineEnvironment}/bin/wine reg import ${lib.escapeShellArg (windowsPath chromeFile)}
    fi
  '';
  xdg.dataFile."ableton/wine".source = "${wineEnvironment}/bin/wine";
  xdg.dataFile."wineprefixes/ableton/drive_c/users/${config.home.username}/Documents" = {
    source = config.lib.file.mkOutOfStoreSymlink config.xdg.userDirs.documents;
    force = true;
  };
  xdg.dataFile."${lib.removePrefix "${config.xdg.dataHome}/" live}/Resources/Themes/Seaglass.ask" = {
    source = config.lib.file.mkOutOfStoreSymlink themeFile;
    force = true;
  };
  systemd.user.settings.Manager = {
    DefaultLimitMEMLOCK = "infinity";
    DefaultLimitRTPRIO = 88;
  };
  xdg.dataFile."applications/ableton.desktop".source = "${desktop}/share/applications/ableton.desktop";
  xdg.dataFile."mime/packages/ableton.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <!-- Override Wine's generated extension associations -->
      <mime-type type="application/x-ableton-live-set">
        <comment>Ableton Live Set</comment>
        <glob pattern="*.als" weight="60"/>
      </mime-type>
      <mime-type type="application/x-ableton-live-pack">
        <comment>Ableton Live Pack</comment>
        <glob pattern="*.alp" weight="60"/>
      </mime-type>
    </mime-info>
  '';
  xdg.mimeApps.defaultApplications = {
    "application/x-ableton-live-set" = "ableton.desktop";
    "application/x-ableton-live-pack" = "ableton.desktop";
  };
}
