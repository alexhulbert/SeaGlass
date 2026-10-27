export function load() {
    const style = document.head.appendChild(document.createElement("style"));
    let socket, timer;
    function connect() {
        socket = new WebSocket("ws://127.0.0.1:7521");
        socket.onmessage = ({ data }) => {
            let p;
            try { p = JSON.parse(data); } catch { return; }
            if (p?.v !== 1 || !["light", "dark"].includes(p.mode)) return;
            const mode = p.mode === "dark" ? "Dark" : "Light";
            const colors = {
                "main sidebar misc": p[`bg${mode}`],
                "text": p[`fg${mode}`],
                "subtext": p.muted,
                "player card notification": p.surface,
                "main-elevated highlight highlight-elevated button-disabled": p.surfaceHigh,
                "selected-row tab-active button button-active": p.accent,
                "shadow button-text": p.onAccent,
                "notification-error": p.error,
            };
            if (!Object.values(colors).every(c => /^#[0-9a-f]{6}$/i.test(c))) return;
            style.textContent = `:root { color-scheme: ${p.mode}; ${Object.entries(colors)
                .flatMap(([names, color]) => names.split(" ").map(name =>
                    `--spice-${name}: ${color} !important; --spice-rgb-${name}: ${color.slice(1).match(/../g).map(c => parseInt(c, 16)).join(",")} !important;`))
                .join(" ")} }`;
        };
        socket.onclose = () => { timer = setTimeout(connect, 1000); };
    }
    connect();
    return () => { socket.onclose = null; clearTimeout(timer); socket.close(); style.remove(); };
}
