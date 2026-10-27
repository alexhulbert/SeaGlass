import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginComponent {
    ccWidgetIcon: "wallpaper"
    ccWidgetPrimaryText: I18n.tr("Wallpaper")
    ccWidgetIsToggle: false

    onCcWidgetToggled: {
        Proc.runCommand("wallpaper-control-center", [Proc.dmsBin, "ipc", "call", "control-center", "hide"], () => {
            Proc.runCommand("wallpaper-browser", [Proc.dmsBin, "ipc", "call", "wallhavenCarousel", "open"]);
        });
    }
}
