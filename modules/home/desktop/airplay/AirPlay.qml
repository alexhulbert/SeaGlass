pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.ControlCenter.Widgets
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    property var streams: []
    property var available: ({})
    property var devices: []
    property string error: ""
    property string starting: ""
    property var moonlightSession: null
    property bool sawMoonlight: false
    readonly property bool moonlightActive: AudioService.pipewireNodes.some(node => node.ready && node.properties?.["application.process.binary"] === "sunshine" && node.properties?.["media.class"] === "Stream/Input/Audio" && node.properties?.["stream.is-live"] === "true")
    onMoonlightActiveChanged: {
        if (moonlightActive)
            sawMoonlight = true;
        else
            moonlightSession = null;
    }
    readonly property var receivers: {
        const result = devices.slice();
        for (const stream of streams)
            if (!result.some(device => device.ip === stream.device_ip))
                result.push({ name: stream.device, ip: stream.device_ip });
        return result;
    }

    Timer {
        interval: 4000
        running: root.sawMoonlight && !root.moonlightActive
        onTriggered: Proc.runCommand("moonlight-stop", ["systemctl", "--user", "stop", "app-dev.lizardbyte.app.Sunshine.service"], null, 0, 60000);
    }

    FileView {
        id: configFile
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/dms-airplay.json"
        printErrors: false
        onLoadFailed: config.moonlight = []
        JsonAdapter {
            id: config
            property var moonlight: []
        }
    }

    function moonlightFor(device) {
        const matches = item => [device.device_id, device.name, device.ip].includes(item.receiver);
        if (moonlightActive && moonlightSession && matches(moonlightSession))
            return moonlightSession;
        return config.moonlight.find(item => matches(item) && (item.check === false || available[item.address + ":" + (item.port ?? 5555)])) ?? null;
    }

    function send(request) {
        if (!["status", "devices"].includes(request.cmd))
            error = "";
        transaction.createObject(root, { request, connected: true });
    }

    function cast(device, stop) {
        if (starting === device.ip)
            return;
        const moonlight = moonlightFor(device);
        if (!moonlight || (stop && streams.some(stream => stream.device_ip === device.ip))) {
            send({ cmd: stop ? "disconnect" : "connect", target: device.ip, port: device.port ?? 7000 });
            return;
        }
        error = "";
        starting = device.ip;
        if (!stop)
            moonlightSession = moonlight;
        Proc.runCommand("moonlight-" + device.ip, ["/usr/bin/bash", Paths.strip(Qt.resolvedUrl("moonlight")), moonlight.address + ":" + (moonlight.port ?? 5555), stop ? "stop" : String(moonlight.appId), moonlight.resolution ?? ""], (output, code) => {
            starting = "";
            if (code !== 0)
                error = output || "Moonlight could not connect to the external display";
            if (stop || code !== 0)
                moonlightSession = null;
        }, 0, 60000);
    }

    Component {
        id: transaction
        Socket {
            id: connection
            required property var request
            property bool replied: false
            path: Quickshell.env("XDG_RUNTIME_DIR") + "/doubletake.sock"
            onConnectionStateChanged: if (connected) {
                write(JSON.stringify(request) + "\n");
                flush();
            }
            onError: {
                if (!replied)
                    root.error = "AirPlay service unavailable";
                destroy();
            }
            parser: SplitParser {
                onRead: data => {
                    connection.replied = true;
                    try {
                        const reply = JSON.parse(data);
                        if (reply.error)
                            root.error = reply.error;
                        else if (root.error === "AirPlay service unavailable")
                            root.error = "";
                        if (["status", "devices"].includes(connection.request.cmd)) {
                            const key = connection.request.cmd === "devices" ? "devices" : "streams";
                            const value = reply[key] ?? [];
                            if (JSON.stringify(root[key]) !== JSON.stringify(value))
                                root[key] = value;
                        } else
                            root.send({ cmd: "status" });
                    } catch (e) {
                        root.error = "Invalid AirPlay response";
                    }
                    connection.destroy();
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            configFile.reload();
            for (const item of config.moonlight.filter(item => item.check !== false)) {
                const target = item.address + ":" + (item.port ?? 5555);
                Proc.runCommand("moonlight-probe-" + target, ["nc", "-z", "-w", "1", item.address, String(item.port ?? 5555)], (_, code) => {
                    const available = Object.assign({}, root.available);
                    available[target] = code === 0;
                    root.available = available;
                }, 0, 2000);
            }
            root.send({ cmd: "status" });
            root.send({ cmd: "devices" });
        }
    }

    ccWidgetIcon: "airplay"
    ccWidgetPrimaryText: "Cast"
    ccWidgetSecondaryText: moonlightActive ? "Casting · Moonlight" : streams.length ? streams.map(stream => stream.device).join(", ") : "Select a device"
    ccWidgetIsActive: moonlightActive || streams.some(stream => stream.state === "streaming")
    ccWidgetIsToggle: false
    ccDetailHeight: 240

    ccDetailContent: Component {
        DFlickable {
            contentHeight: column.implicitHeight
            clip: true
            Column {
                id: column
                width: parent.width
                spacing: Theme.spacingM
                StyledText {
                    width: parent.width
                    visible: root.error !== ""
                    text: root.error
                    color: Theme.error
                    wrapMode: Text.WordWrap
                }
                CcEmptyState {
                    visible: root.receivers.length === 0
                    iconName: "airplay"
                    title: "No receivers found"
                    subtitle: "Turn on your AirPlay receiver and ensure it is connected to the same network."
                }
                Repeater {
                    model: root.receivers
                    delegate: CcListRow {
                        id: receiver
                        required property var modelData
                        readonly property var moonlight: root.moonlightFor(modelData)
                        readonly property var airplay: root.streams.find(stream => stream.device_ip === modelData.ip)
                        readonly property bool moonlightStreaming: moonlight !== null && root.moonlightActive && (!root.moonlightSession || root.moonlightSession.receiver === moonlight.receiver)
                        readonly property var stream: airplay ?? (moonlightStreaming ? { state: "streaming" } : null)
                        readonly property bool busy: root.starting === modelData.ip || airplay?.state === "connecting"
                        width: column.width
                        title: modelData.name
                        subtitle: root.starting === modelData.ip ? "Connecting…" : airplay ? ({ streaming: "Casting", connecting: "Connecting…", pin_required: "Pairing required" })[airplay.state] : moonlight ? (moonlightStreaming ? "Casting · Moonlight" : "Moonlight") : modelData.model ?? modelData.ip
                        iconName: busy ? "" : "airplay"
                        active: stream?.state === "streaming"
                        clickable: true
                        enabled: !busy
                        onClicked: root.cast(modelData, !!stream)
                        leading: DSpinner {
                            size: Theme.iconSize
                            color: receiver.iconColor
                            visible: receiver.busy
                            running: visible
                        }
                        body: DTextField {
                            width: parent.width
                            visible: receiver.stream?.state === "pin_required"
                            showAcceptButton: true
                            acceptButtonName: "Pair"
                            placeholderText: receiver.stream?.credential_kind === "password" ? "AirPlay password" : "Code shown on the external display"
                            echoMode: receiver.stream?.credential_kind === "password" ? TextInput.Password : TextInput.Normal
                            onAccepted: if (text.length) {
                                root.send({ cmd: "connect", target: receiver.modelData.ip, pin: text });
                                clear();
                            }
                        }
                    }
                }
            }
        }
    }
}
