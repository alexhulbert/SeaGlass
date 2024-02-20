import ButtonGroup from './button-group.js'

const getMonitors = (onlyEnabled) => {
  const command = onlyEnabled ? 'hyprctl monitors enabled -j' : 'hyprctl monitors all -j'
  return JSON.parse(Utils.exec(command))
}

const DisplaySwitcher = ButtonGroup(
  'display-switcher',
  [
    {
      label: 'Laptop Only',
      action: () => {
        const monitors = getMonitors().filter(m => m.name !== 'eDP-1')
        for (const { name } of monitors) {
          Utils.exec(`hyprctl keyword monitor ${name},disable`)
        }
        Utils.exec('hyprctl keyword monitor eDP-1,preferred,auto,auto')
      },
      icon: [0xf0322]
    },
    {
      label: 'Duplicate Screen',
      action: () => {
        const monitors = getMonitors().filter(m => m.name !== 'eDP-1')
        Utils.exec('hyprctl keyword monitor eDP-1,preferred,0x0,auto')
        for (const { name } of monitors) {
          Utils.exec(`hyprctl keyword monitor ${name},preferred,auto,auto,mirror,eDP-1`)
        }
      },
      icon: [0xf037a]
    },
    {
      label: 'Extend Screen',
      action: () => {
        const monitors = getMonitors().filter(m => m.name !== 'eDP-1')
        Utils.exec('hyprctl keyword monitor eDP-1,preferred,0x0,auto')
        for (const { name } of monitors) {
          Utils.exec(`hyprctl keyword monitor ${name},preferred,auto,auto`)
        }
      },
      icon: [0xf1724]
    },
    {
      label: 'Second Screen Only',
      action: () => {
        const monitors = getMonitors().filter(m => m.name !== 'eDP-1')
        if (monitors.length) {
          Utils.exec('hyprctl keyword monitor eDP-1,disable')
          for (const { name } of monitors) {
            Utils.exec(`hyprctl keyword monitor ${name},preferred,auto,auto`)
          }
        }
      },
      icon: [0xf0379]
    }
  ], 4
)

let switcherHandle = null
globalThis.switchDisplay = () => {
  if (DisplaySwitcher.window.visible) {
    DisplaySwitcher.selectNextIcon()
  } else {
    const monitors = getMonitors(true)
    const containsInternal = monitors.some(m => m.name === 'eDP-1')
    const containsExternal = monitors.some(m => m.name !== 'eDP-1')
    if (containsInternal && containsExternal) {
      DisplaySwitcher.selectIcon(2) // Mirror is identical to laptop only
    } else if (containsInternal) {
      DisplaySwitcher.selectIcon(0)
    } else if (containsExternal) {
      DisplaySwitcher.selectIcon(3)
    }
    DisplaySwitcher.window.show()
  }
}
DisplaySwitcher.onIconChange(() => {
  clearTimeout(switcherHandle)
  switcherHandle = setTimeout(() => {
    if (DisplaySwitcher.window.visible) {
      DisplaySwitcher.submit()
    }
  }, 5000)
})

export default DisplaySwitcher
