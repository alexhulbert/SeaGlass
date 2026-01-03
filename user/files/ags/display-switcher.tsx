import GLib from "gi://GLib"
import { exec } from "ags/process"
import { writeFile } from "ags/file"
import ButtonGroup, { ButtonGroupAPI } from "./button-group"

const HOME = GLib.get_home_dir()
const MONITORS_CONFIG = `${HOME}/.config/hypr/monitors.conf`
const LAPTOP = "eDP-1"

interface Monitor {
  name: string
}

const getMonitors = (onlyEnabled = false): Monitor[] => {
  const cmd = onlyEnabled ? "hyprctl monitors -j" : "hyprctl monitors all -j"
  return JSON.parse(exec(cmd))
}

const writeConfig = (lines: string[]) => writeFile(MONITORS_CONFIG, lines.join("\n") + "\n")

const getExternalMonitors = () => getMonitors().filter(m => m.name !== LAPTOP)

const buttons = [
  {
    label: "Laptop Only",
    action: () => writeConfig([
      `monitor=${LAPTOP},preferred,auto,auto`,
      ...getExternalMonitors().map(m => `monitor=${m.name},disable`)
    ]),
    icon: [0xf0322]
  },
  {
    label: "Duplicate Screen",
    action: () => writeConfig([
      `monitor=${LAPTOP},preferred,0x0,auto`,
      ...getExternalMonitors().map(m => `monitor=${m.name},preferred,auto,auto,mirror,${LAPTOP}`)
    ]),
    icon: [0xf037a]
  },
  {
    label: "Extend Screen",
    action: () => writeConfig([
      `monitor=${LAPTOP},preferred,0x0,auto`,
      ...getExternalMonitors().map(m => `monitor=${m.name},preferred,auto,auto`)
    ]),
    icon: [0xf1724]
  },
  {
    label: "Second Screen Only",
    action: () => writeConfig([
      `monitor=${LAPTOP},disable`,
      ...getExternalMonitors().map(m => `monitor=${m.name},preferred,auto,auto`)
    ]),
    icon: [0xf0379]
  }
]

let api: ButtonGroupAPI | null = null
let autoSubmitHandle: ReturnType<typeof setTimeout> | null = null

export function switchDisplay() {
  if (!api) return

  if (api.visible) {
    api.selectNextIcon()
  } else {
    const monitors = getMonitors(true)
    const hasLaptop = monitors.some(m => m.name === LAPTOP)
    const hasExternal = monitors.some(m => m.name !== LAPTOP)

    if (hasLaptop && hasExternal) api.selectIcon(2)
    else if (hasLaptop) api.selectIcon(0)
    else if (hasExternal) api.selectIcon(3)

    api.show()
  }
}

export default function DisplaySwitcher() {
  return (
    <ButtonGroup
      name="display-switcher"
      buttons={buttons}
      iconsPerRow={4}
      onIconChange={() => {
        if (autoSubmitHandle) clearTimeout(autoSubmitHandle)
        autoSubmitHandle = setTimeout(() => api?.visible && api.submit(), 5000)
      }}
      ref={a => { api = a }}
    />
  )
}
