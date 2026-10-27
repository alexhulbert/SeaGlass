import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    readonly property string mode: Theme.isLightMode ? "light" : "dark"
    readonly property var profile: pluginData[mode] ?? ({})
    readonly property int brightness: profile.brightness
    readonly property int canvasOpacity: profile.opacity
    readonly property string preset: pluginData.preset?.name ?? ""
    readonly property bool customHue: !!SettingsData.matugenSeedColor
    readonly property color seed: SettingsData.matugenSeedColor || Theme.getMatugenColor("source_color", Theme.primary)
    readonly property int hue: !customHue && pluginData.hue !== undefined ? pluginData.hue : Math.max(0, Math.round(seed.hsvHue * 360) % 360)
    readonly property var presets: [
        { name: "oled", label: "OLED", icon: "dark_mode" },
        { name: "reading", label: I18n.tr("Reading"), icon: "menu_book" },
        { name: "blush", label: I18n.tr("Cute"), icon: "favorite" },
        { name: "catppuccin", label: "Catppuccin", icon: "local_cafe" },
        { name: "nord", label: "Nord", icon: "ac_unit" }
    ]

    function hueColor(degrees) {
        return Qt.hsva(degrees / 360, 0.65, 0.9, 1);
    }

    function command(method, args) {
        Proc.runCommand("canvas-" + method, [Proc.dmsBin, "ipc", "--", "call", "canvas", method, ...args.map(String)], (output, code) => {
            if (code !== 0 || output.startsWith("ERROR:"))
                ToastService.showError(I18n.tr("Theme"), output);
        });
    }

    ccWidgetIcon: "palette"
    ccWidgetPrimaryText: I18n.tr("Theme")
    ccWidgetSecondaryText: presets.find(p => p.name === preset)?.label || brightness + "% · " + canvasOpacity + "%"
    ccWidgetIsToggle: false

    ccDetailContent: Component {
        Column {
            id: panel

            readonly property string mode: root.mode
            readonly property string savedProfile: JSON.stringify([root.brightness, root.canvasOpacity, root.hue, root.preset])
            readonly property bool dragging: hueSlider.isDragging || brightnessSlider.isDragging || opacitySlider.isDragging

            function sync() {
                brightnessSlider.value = root.brightness;
                opacitySlider.value = root.canvasOpacity;
                hueSlider.value = root.hue;
            }

            function edited() {
                if (!dragging)
                    debounce.restart();
            }

            function commit() {
                if (root.customHue && !root.preset && hueSlider.value !== root.hue)
                    root.command("hue", [hueSlider.value]);
                if (brightnessSlider.value !== root.brightness || opacitySlider.value !== root.canvasOpacity)
                    root.command("set", [panel.mode, brightnessSlider.value, opacitySlider.value]);
            }

            Component.onCompleted: sync()
            Component.onDestruction: debounce.flush()
            spacing: Theme.spacingM
            onImplicitHeightChanged: root.ccDetailHeight = implicitHeight + Theme.spacingL * 2
            onDraggingChanged: dragging ? debounce.cancel() : debounce.restart()
            onSavedProfileChanged: {
                if (!dragging && !debounce.pending)
                    sync();
            }
            onModeChanged: {
                debounce.cancel();
                sync();
            }

            DeferredAction {
                id: debounce

                interval: 300
                onTriggered: panel.commit()
            }

            Row {
                width: parent.width
                spacing: Theme.spacingS

                Repeater {
                    model: root.presets

                    Column {
                        required property var modelData
                        width: (parent.width - parent.spacing * (root.presets.length - 1)) / root.presets.length
                        spacing: Theme.spacingXS

                        DIconButton {
                            width: parent.width
                            iconName: modelData.icon
                            tooltipText: modelData.label
                            checkable: true
                            checked: root.preset === modelData.name
                            containerColor: Theme.primary
                            contentColor: Theme.primaryText
                            onClicked: {
                                debounce.flush();
                                root.command("preset", [modelData.name]);
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: modelData.label
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            DToggle {
                width: parent.width
                text: I18n.tr("Custom hue")
                enabled: !root.preset
                checked: root.customHue
                onToggled: checked => {
                    debounce.flush();
                    root.command("hue", [checked ? root.hue : -1]);
                }
            }

            DSlider {
                id: hueSlider

                width: parent.width
                enabled: root.customHue && !root.preset
                minimum: 0
                maximum: 359
                unit: "°"
                alwaysShowValue: true
                fillColor: root.hueColor(value)
                fillTextColor: Theme.isLightColor(fillColor) ? "#000000" : "#ffffff"
                Accessible.name: I18n.tr("Hue")
                trackGradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: root.hueColor(0) }
                    GradientStop { position: 1 / 6; color: root.hueColor(60) }
                    GradientStop { position: 2 / 6; color: root.hueColor(120) }
                    GradientStop { position: 3 / 6; color: root.hueColor(180) }
                    GradientStop { position: 4 / 6; color: root.hueColor(240) }
                    GradientStop { position: 5 / 6; color: root.hueColor(300) }
                    GradientStop { position: 1; color: root.hueColor(360) }
                }
                onSliderValueChanged: panel.edited()
            }

            StyledText {
                text: I18n.tr("Surface brightness")
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
            }

            DSlider {
                id: brightnessSlider

                width: parent.width
                enabled: !root.preset
                minimum: 0
                maximum: 100
                unit: "%"
                alwaysShowValue: true
                endIcon: panel.mode === "light" ? "brightness_high" : "brightness_low"
                Accessible.name: I18n.tr("Surface brightness")
                onSliderValueChanged: panel.edited()
            }

            StyledText {
                width: parent.width
                text: panel.mode === "light" ? I18n.tr("Decrease to darken and tint window background") : I18n.tr("Decrease to brighten and tint window background")
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }

            StyledText {
                text: I18n.tr("Background opacity")
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
            }

            DSlider {
                id: opacitySlider

                width: parent.width
                enabled: !["oled", "reading"].includes(root.preset)
                minimum: 40
                maximum: 100
                unit: "%"
                alwaysShowValue: true
                endIcon: "opacity"
                Accessible.name: I18n.tr("Background opacity")
                onSliderValueChanged: panel.edited()
            }
        }
    }
}
