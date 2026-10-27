import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Widgets

DOSD {
    id: root
    property string pluginId: ""
    property var pluginService
    blurNamespace: "dms:voice-edit"
    modelData: Quickshell.screens.find(s => s.name === CompositorService.getFocusedScreenName()) ?? Quickshell.screens[0]
    osdWidth: 280
    osdHeight: 56
    autoHideInterval: 125000

    content: Item {
        Row {
            anchors.centerIn: parent
            spacing: 12
            DSpinner { size: 20; anchors.verticalCenter: parent.verticalCenter }
            StyledText {
                text: "Rewriting selection…"
                font.pixelSize: 16
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    IpcHandler {
        target: "handyEdit"
        function show(): void { root.show(); }
        function hide(): void { root.hide(); }
    }
}
