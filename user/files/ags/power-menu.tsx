import { exec } from "ags/process"
import ButtonGroup from "./button-group"

const buttons = [
  {
    label: "Power Off",
    action: () => exec("poweroff"),
    icon: [0xf0425]
  },
  {
    label: "Reboot",
    action: () => exec("reboot"),
    icon: [0xf0709]
  },
  {
    label: "Sleep",
    action: () => exec("systemctl suspend"),
    icon: [0xf0904]
  },
  {
    label: "Switch to Windows",
    action: () => {
      const bootEntries = exec("efibootmgr")
      const matches = bootEntries.match(/Boot(\d{4})\* Windows Boot Manager/)
      if (matches) {
        exec(`sudo efibootmgr --bootnext ${matches[1]}`)
        exec("sudo reboot")
      }
    },
    icon: [0xf05b3]
  },
  {
    label: "Hibernate",
    action: () => exec("systemctl hibernate"),
    icon: [0xf0901]
  },
  {
    label: "Change Theme",
    action: () => exec("seaglass-theme"),
    icon: [0xf0e09]
  },
  {
    label: "Lock",
    action: () => exec("hyprlock"),
    icon: [0xf033e]
  },
  {
    label: "Restart Session",
    action: () => exec("hyprctl dispatch exit"),
    icon: [0xf0450]
  }
]

export default function PowerMenu() {
  return (
    <ButtonGroup
      name="power-menu"
      buttons={buttons}
      iconsPerRow={4}
    />
  )
}
