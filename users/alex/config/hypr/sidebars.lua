return {
    todoist = { key = "A", class = "todoist", label = "Todoist", width = 480, enter = "left", leave = "right",
        command = "uwsm app -- coloreader-electron env DESKTOPINTEGRATION=false todoist --no-sandbox" },
    messages = { key = "D", class = "Beeper", label = "Messages", width = 850, enter = "right", leave = "left",
        command = "uwsm app -- coloreader-electron beeper --no-sandbox" },
    slack = { key = "S", class = "slack", label = "Slack", enter = "bottom", leave = "top",
        command = "uwsm app -- coloreader-electron slack --ozone-platform=wayland" },
}
