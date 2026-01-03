import Astal from "gi://Astal?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import { createState, createComputed } from "ags"
import app from "ags/gtk3/app"

interface ButtonConfig {
  label: string
  icon: number[]
  action: () => void
}

interface ButtonGroupProps {
  name: string
  buttons: ButtonConfig[]
  iconsPerRow: number
  onIconChange?: () => void
  ref?: (api: ButtonGroupAPI) => void
}

export interface ButtonGroupAPI {
  show: () => void
  hide: () => void
  selectNextIcon: () => void
  selectIcon: (n: number) => void
  submit: () => void
  get visible(): boolean
}

export default function ButtonGroup({ name, buttons, iconsPerRow, onIconChange, ref }: ButtonGroupProps) {
  const [hoveredIndex, setHoveredIndex] = createState(-1)
  const [selectedIndex, setSelectedIndex] = createState(0)
  const [isHovered, setIsHovered] = createState(false)

  let windowRef: Astal.Window | null = null

  const hoverIcon = (n: number) => {
    setIsHovered(true)
    setHoveredIndex(n)
    onIconChange?.()
  }

  const unHover = () => {
    setIsHovered(false)
    setHoveredIndex(-1)
  }

  const selectIcon = (n: number) => {
    setHoveredIndex(n)
    setIsHovered(false)
    setSelectedIndex(n)
    onIconChange?.()
  }

  const selectNextIcon = () => {
    selectIcon((selectedIndex() + 1) % buttons.length)
  }

  const submit = () => {
    const idx = selectedIndex()
    if (idx >= 0 && idx < buttons.length) {
      buttons[idx].action()
    }
    windowRef?.hide()
  }

  const handleKeyPress = (_: Astal.Window, event: Gdk.Event) => {
    const keyval = event.get_keyval()[1]
    const count = buttons.length
    const hovered = hoveredIndex()

    switch (keyval) {
      case Gdk.KEY_Left:
      case Gdk.KEY_ISO_Left_Tab:
        hoverIcon((hovered - 1 + count) % count)
        break
      case Gdk.KEY_Right:
      case Gdk.KEY_Tab:
        hoverIcon((hovered + 1) % count)
        break
      case Gdk.KEY_Up:
        hoverIcon((hovered - iconsPerRow + count) % count)
        break
      case Gdk.KEY_Down:
        hoverIcon((hovered + iconsPerRow) % count)
        break
      case Gdk.KEY_Escape:
        windowRef?.hide()
        break
      case Gdk.KEY_Return:
        if (isHovered()) {
          selectIcon(hovered)
          setTimeout(submit, 100)
        } else {
          submit()
        }
        break
    }
  }

  const currentLabel = createComputed(() => {
    const hovered = hoveredIndex()
    const selected = selectedIndex()
    if (isHovered() && hovered >= 0 && buttons[hovered]) {
      return buttons[hovered].label
    }
    if (selected >= 0 && buttons[selected]) {
      return buttons[selected].label
    }
    return ""
  })

  const api: ButtonGroupAPI = {
    show: () => windowRef?.show(),
    hide: () => windowRef?.hide(),
    selectNextIcon,
    selectIcon,
    submit,
    get visible() { return windowRef?.visible ?? false }
  }

  ref?.(api)

  return (
    <window
      name={name}
      namespace={name}
      keymode={Astal.Keymode.EXCLUSIVE}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      application={app}
      onKeyPressEvent={handleKeyPress}
      $={(self: Astal.Window) => { windowRef = self }}
    >
      <box vertical>
        {Array.from({ length: Math.ceil(buttons.length / iconsPerRow) }, (_, rowIndex) => (
          <box>
            {buttons.slice(rowIndex * iconsPerRow, (rowIndex + 1) * iconsPerRow).map((button, i) => {
              const index = rowIndex * iconsPerRow + i
              const iconText = button.icon.map(code => String.fromCodePoint(code)).join(" ")
              const iconClass = createComputed(() => {
                let cls = "icon"
                if (isHovered() && hoveredIndex() === index) cls += " hover"
                if (selectedIndex() === index) cls += " selected"
                return cls
              })
              return (
                <eventbox
                  onHover={() => hoverIcon(index)}
                  onHoverLost={() => unHover()}
                  onClick={() => {
                    selectIcon(index)
                    setTimeout(submit, 100)
                  }}
                >
                  <label label={iconText} class={iconClass} />
                </eventbox>
              )
            })}
          </box>
        ))}
        <box class="selection-label">
          <label hexpand justify={0.5} label={currentLabel} />
        </box>
      </box>
    </window>
  )
}
