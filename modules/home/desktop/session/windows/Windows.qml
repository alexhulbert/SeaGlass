import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginComponent {
    ccWidgetIcon: "grid_view"
    ccWidgetPrimaryText: "Windows"
    ccWidgetSecondaryText: "Restart"
    ccWidgetIsToggle: false

    Component.onCompleted: if (parent?.parent && "iconContent" in parent.parent) parent.parent.iconContent = logo
    property Component logo: DIcon {
        name: "grid_view"
        filled: true
        size: Theme.iconSize
        color: Theme.primary
    }

    onCcWidgetToggled: {
        Proc.runCommand("close-control-center", ["dms", "ipc", "call", "control-center", "hide"]);
        Proc.runCommand("switch-to-windows", ["switch-to-windows"]);
    }
}
