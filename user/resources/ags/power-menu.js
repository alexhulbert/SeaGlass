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
      label: 'Hibernate',
      action: () => {
        Utils.exec('systemctl hibernate')
        PowerMenu.selectIcon(-1)
      },
      icon: [0xf0901]
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
  ], 3
)

export default PowerMenu
