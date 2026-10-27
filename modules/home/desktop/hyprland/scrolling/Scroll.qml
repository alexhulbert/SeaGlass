import QtQuick
import Quickshell.Hyprland
import qs.Common
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    ccWidgetIcon: "view_carousel"
    ccWidgetPrimaryText: I18n.tr("Scroll")
    ccWidgetSecondaryText: ccWidgetIsActive ? I18n.tr("On") : I18n.tr("Off")

    function refresh() {
        Proc.runCommand("scroll-layout-status", ["hyprctl", "-j", "getoption", "general:layout"], (output, code) => {
            if (code === 0)
                root.ccWidgetIsActive = JSON.parse(output).str === "scrolling";
        });
    }

    Component.onCompleted: refresh()

    onCcWidgetToggled: {
        Proc.runCommand("scroll-layout-toggle", ["hyprctl", "eval", "require('layouts').toggle()"], (output, code) => {
            if (code !== 0 || output.startsWith("error:"))
                ToastService.showError(I18n.tr("Scroll"), output);
        });
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "configreloaded" || (event.name === "custom" && event.data === "seaglass-layout"))
                root.refresh();
        }
    }
}
