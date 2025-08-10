import ButtonGroup from './button-group.js'
const monitorsConfig = Utils.HOME + '/.config/hypr/monitors.conf'

const getMonitors = (onlyEnabled) => {
  const command = onlyEnabled ? 'hyprctl monitors enabled -j' : 'hyprctl monitors all -j'
  return JSON.parse(Utils.exec(command))
}

const writeMonitorConfig = async (lines) => {
  try {
    await Utils.writeFile(lines.join('\n') + '\n', monitorsConfig)
  } catch (err) {
    console.error('Failed to write monitor config:', err)
  }
}

const DisplaySwitcher = ButtonGroup(
  'display-switcher',
  [
    {
      label: 'Laptop Only',
      action: async () => {
        const monitors = getMonitors()
        const lines = []
        
        // Enable laptop display
        const laptop = monitors.find(m => m.name === 'eDP-1')
        if (laptop) {
          lines.push(`monitor=eDP-1,preferred,auto,auto`)
        }
        
        // Disable all other monitors
        monitors.filter(m => m.name !== 'eDP-1').forEach(monitor => {
          lines.push(`monitor=${monitor.name},disable`)
        })
        
        await writeMonitorConfig(lines)
      },
      icon: [0xf0322]
    },
    {
      label: 'Duplicate Screen',
      action: async () => {
        const monitors = getMonitors()
        const lines = []
        
        // Set laptop as primary at 0x0
        lines.push(`monitor=eDP-1,preferred,0x0,auto`)
        
        // Mirror all other monitors to laptop
        monitors.filter(m => m.name !== 'eDP-1').forEach(monitor => {
          lines.push(`monitor=${monitor.name},preferred,auto,auto,mirror,eDP-1`)
        })
        
        await writeMonitorConfig(lines)
      },
      icon: [0xf037a]
    },
    {
      label: 'Extend Screen',
      action: async () => {
        const monitors = getMonitors()
        const lines = []
        
        // Set laptop at 0x0
        lines.push(`monitor=eDP-1,preferred,0x0,auto`)
        
        // Extend other monitors
        monitors.filter(m => m.name !== 'eDP-1').forEach(monitor => {
          lines.push(`monitor=${monitor.name},preferred,auto,auto`)
        })
        
        await writeMonitorConfig(lines)
      },
      icon: [0xf1724]
    },
    {
      label: 'Second Screen Only',
      action: async () => {
        const monitors = getMonitors()
        const lines = []
        
        // Disable laptop
        lines.push(`monitor=eDP-1,disable`)
        
        // Enable all other monitors
        monitors.filter(m => m.name !== 'eDP-1').forEach(monitor => {
          lines.push(`monitor=${monitor.name},preferred,auto,auto`)
        })
        
        await writeMonitorConfig(lines)
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
