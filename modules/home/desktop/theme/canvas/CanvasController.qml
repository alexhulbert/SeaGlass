import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Item {
    id: root

    readonly property var settings: SettingsData.getPluginSettingsForPlugin("seaglassCanvas")
    readonly property string presetFile: settings.preset ? Paths.strip(Qt.resolvedUrl(`themes/${settings.preset.name === "reading" ? "reading-sepia" : settings.preset.name}.json`)) : ""
    readonly property string opacityFile: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/hypr/dms/canvas-opacity"
    readonly property bool presetActive: !!settings.preset && Theme.currentTheme === "custom" && SettingsData.customThemeFile === presetFile

    onPresetActiveChanged: Qt.callLater(() => {
        if (settings.preset && !presetActive)
            setPreset("", false);
    })

    Component.onCompleted: {
        for (const mode of ["dark", "light"])
            if (!settings[mode])
                save(mode, { "brightness": 100, "opacity": mode === "light" ? 78 : 86 });
        applyPreset();
        if (settings.preset)
            selectTheme();
        applyOpacity();
    }

    function save(key, value) {
        PluginService.savePluginData("seaglassCanvas", key, value);
    }

    function restore(saved) {
        for (const key in saved.session)
            SessionData[key] = saved.session[key];
        if (saved.smartMode !== undefined)
            SettingsData.set("matugenSmartMode", saved.smartMode);
        if (saved.fillMode !== undefined) {
            SettingsData.set("wallpaperFillMode", saved.fillMode);
            SessionData.syncWallpaperForCurrentMode();
        }
        SessionData.saveSettings();
    }

    function selectTheme() {
        if (settings.preset)
            SettingsData.set("customThemeFile", presetFile);
        Theme.switchTheme(settings.preset ? "custom" : "dynamic", true, false);
    }

    function setPreset(name, select = true) {
        const previous = settings.preset;
        if (previous?.restore)
            restore(previous.restore);
        const next = name && name !== previous?.name ? { name } : null;
        save("preset", next);
        applyPreset();
        if (select)
            selectTheme();
        else
            applyTimer.restart();
        applyOpacity();
    }

    function setHue(value) {
        if (value >= 0)
            save("hue", value);
        SettingsData.setMatugenSeedColor(value < 0 ? "" : Qt.hsva(value / 360, 0.65, 0.9, 1).toString());
        if (Theme.currentTheme !== "dynamic")
            Theme.switchTheme("dynamic", true, false);
    }

    function applyPreset() {
        if (settings.preset?.name !== "reading") {
            applyPaperPreset();
            return;
        }
        // applyPaperPreset();
        if (!settings.preset.restore) {
            save("preset", { name: "reading", restore: {
                session: {
                    isLightMode: SessionData.isLightMode,
                    themeModeAutoEnabled: SessionData.themeModeAutoEnabled
                },
                smartMode: SettingsData.matugenSmartMode
            } });
        }
        SessionData.themeModeAutoEnabled = false;
        SettingsData.set("matugenSmartMode", false);
        SessionData.setLightMode(true, true);
    }

    function applyPaperPreset() {
        const name = settings.preset?.name;
        if (name !== "oled" && name !== "reading")
            return;
        const oled = name === "oled";
        const values = {
            "wallpaperPath": oled ? "#000000" : Paths.strip(Qt.resolvedUrl(`themes/paper-${Theme.isLightMode ? "light" : "dark"}.png`)),
            "perMonitorWallpaper": false,
            "perModeWallpaper": false,
            "wallpaperCyclingEnabled": false
        };
        if (oled) {
            values.isLightMode = false;
            values.themeModeAutoEnabled = false;
        }
        if (!settings.preset.restore) {
            const session = {};
            for (const key in values)
                session[key] = SessionData[key];
            const saved = { session };
            if (oled)
                saved.smartMode = SettingsData.matugenSmartMode;
            else
                saved.fillMode = SettingsData.wallpaperFillMode;
            save("preset", { name, restore: saved });
        }
        for (const key in values)
            SessionData[key] = values[key];
        if (oled) {
            SettingsData.set("matugenSmartMode", false);
            SessionData.setLightMode(false, true);
        } else {
            SettingsData.set("wallpaperFillMode", "Tile");
            SessionData.saveSettings();
        }
    }

    function saveProfile(mode, brightness, opacity) {
        const previous = settings[mode];
        save(mode, { "brightness": brightness, "opacity": opacity });
        if (opacity !== previous?.opacity)
            applyOpacity();
        if (brightness !== previous?.brightness)
            applyTimer.restart();
    }

    function applyOpacity() {
        const value = mode => settings.preset?.name === "oled" ? 1 : (settings[mode]?.opacity ?? 100) / 100;
        Proc.runCommand("canvas-opacity", ["sh", "-c", 'printf "%s %s\\n" "$1" "$2" > "$3" && hyprctl reload config-only', "canvas-opacity", String(value("dark")), String(value("light")), opacityFile], (output, code) => {
            if (code !== 0)
                ToastService.showError(I18n.tr("Theme"), output);
        });
    }

    Timer {
        id: applyTimer

        interval: 250
        onTriggered: {
            CacheData.set("matugenAppliedKey", "");
            Theme.generateSystemThemesFromCurrentTheme();
        }
    }

    Connections {
        target: Theme

        function onIsLightModeChanged() {
            if (root.settings.preset?.name === "reading")
                root.applyPreset();
        }

        function onMatugenCompleted(mode, result) {
            if (result !== "error")
                gtkRefresh.running = true;
        }
    }

    Process {
        id: gtkRefresh

        // Toggling the color scheme makes GTK4 re-read the imported CSS
        command: ["sh", "-c", `
            schema=org.gnome.desktop.interface
            scheme=$1
            trap 'gsettings set "$schema" color-scheme "$scheme"' EXIT
            case $scheme in
                *prefer-dark*) next=prefer-light ;;
                *) next=prefer-dark ;;
            esac
            gsettings set "$schema" color-scheme "$next" && sleep 0.2
        `, "gtk-refresh", Theme.isLightMode ? "prefer-light" : "prefer-dark"]
        onExited: code => {
            if (code !== 0)
                console.warn("Canvas: GTK refresh failed:", code);
        }
    }

    IpcHandler {
        function status() : string {
            return JSON.stringify({
                "mode": Theme.isLightMode ? "light" : "dark",
                "profiles": root.settings
            });
        }

        function set(mode: string, brightness: int, opacity: int) : string {
            if (!["dark", "light"].includes(mode) || brightness < 0 || brightness > 100 || opacity < 0 || opacity > 100)
                return "ERROR: mode must be dark/light and values between 0 and 100";

            root.saveProfile(mode, brightness, opacity);
            return "OK";
        }

        function preset(name: string) : string {
            root.setPreset(name === "off" ? "" : name);
            return "OK";
        }

        function hue(value: int) : string {
            if (value < -1 || value > 359)
                return "ERROR: hue must be -1 (automatic) or 0 to 359";
            if (root.settings.preset)
                return "ERROR: deselect the preset before changing hue";
            root.setHue(value);
            return "OK";
        }

        target: "canvas"
    }

}
