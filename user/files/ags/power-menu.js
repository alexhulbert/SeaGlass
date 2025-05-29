import ButtonGroup from './button-group.js'

const PowerMenu = ButtonGroup(
  'power-menu',
  [
    {
      label: 'Power Off',
      action: () => {
        Utils.exec('poweroff')
      },
      icon: [0xf0425]
    },
    {
      label: 'Reboot',
      action: () => {
        Utils.exec('reboot')
      },
      icon: [0xf0709]
    },
    {
      label: 'Sleep',
      action: () => {
        Utils.exec('systemctl suspend')
        PowerMenu.selectIcon(-1)
      },
      icon: [0xf0904]
    },
    {
      label: 'Switch to Windows',
      action: () => {
        const bootEntries = Utils.exec('efibootmgr')
        const matches = bootEntries.match(/Boot(\d{4})\* Windows Boot Manager/)
        Utils.exec(`sudo efibootmgr --bootnext ${matches[1]}`)
        Utils.exec('sudo reboot')
      },
      icon: [0xf05b3]
    },
    {
      label: 'Hibernate',
      action: () => {
        Utils.exec('systemctl hibernate')
        PowerMenu.selectIcon(-1)
      },
      icon: [0xf0901]
    },
    {
      label: 'Change Theme',
      action: () => {
        Utils.exec('seaglass-theme')
      },
      icon: [0xf0e09]
    },
    {
      label: 'Lock',
      action: () => {
        console.log('Lock')
        PowerMenu.selectIcon(-1)
      },
      icon: [0xf033e]
    },
    {
      label: 'Restart Session',
      action: () => {
	      Utils.exec('hyprctl dispatch exit')
      },
      icon: [0xf0450]
    }
  ], 4
)

export default PowerMenu
