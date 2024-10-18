const { Window, EventBox, Box, Label } = Widget

export default (name, buttons, iconsPerRow) => {
  let icons = []
  let iconDescs = []
  let hoveredIconIndex = 0
  let isIconHovered = false
  let selectedIconIndex = 0
  let iconChangeHandlers = []

  const hoverIcon = n => {
    isIconHovered = true
    hoveredIconIndex = n
    icons.forEach((icon, index) => {
      if (index === n) {
        icon.className = icon.className.replace('placeholder1', 'hover')
        CurrentDisplayMode.children[0].label = iconDescs[n]
      } else {
        icon.className = icon.className.replace('hover', 'placeholder1')
      }
    })
    for (const handler of iconChangeHandlers) {
      handler()
    }
  }
  const unHover = () => {
    isIconHovered = false
    icons.forEach(icon => {
      icon.className = icon.className.replace('hover', 'placeholder1')
    })
    if (selectedIconIndex >= 0) {
      CurrentDisplayMode.children[0].label = iconDescs[selectedIconIndex]
    }
  }

  const selectIcon = n => {
    hoveredIconIndex = n
    unHover()
    selectedIconIndex = n
    icons.forEach((icon, index) => {
      if (index === n) {
        icon.className = icon.className.replace('placeholder2', 'selected')
        CurrentDisplayMode.children[0].label = iconDescs[n]
      } else {
        icon.className = icon.className.replace('selected', 'placeholder2')
      }
    })
    for (const handler of iconChangeHandlers) {
      handler()
    }
  }

  const onIconChange = handler => {
    iconChangeHandlers.push(handler)
  }
  const selectNextIcon = () => {
    selectIcon((selectedIconIndex + 1) % icons.length)
  }
  const submit = () => {
    buttons[selectedIconIndex].action()
    window.hide()
  }

  const DisplayModeButton = (label, icon) => {
    const iconText = icon.map((icon) => String.fromCodePoint(icon)).join(' ')
    const iconObj = Label({
      className: 'icon placeholder1 placeholder2',
      label: iconText
    })
    icons.push(iconObj)
    iconDescs.push(label)
    const eventBox = EventBox({
      child: iconObj,
      'on-hover': () => {
        hoverIcon(icons.indexOf(iconObj))
      },
      'on-hover-lost': () => { 
        unHover()
      },
      'on-primary-click': () => {
        selectIcon(icons.indexOf(iconObj))
        setTimeout(submit, 100)
      }
    })
    return eventBox
  }

  const CurrentDisplayMode = Box({
    className: 'selection-label',
    children: [
      Label({
        hexpand: true,
        justification: 'center',
        label: 'Duplicate'
      })
    ]
  })

  const ButtonRows = buttons
    .map(buttonData => DisplayModeButton(buttonData.label, buttonData.icon))
    .reduce((rows, button, index) => {
      if (index % iconsPerRow === 0) {
        rows.push([button])
      } else {
        rows[rows.length - 1].push(button)
      }
      return rows
    }, [])
    .map(row => Box({ children: row }))

  const window = Window({
    name,
    // exclusivity: 'ignore',
    // keymode: 'none',
    keymode: 'exclusive',
    visible: false,
    layer: 'overlay',
    child: Box({
      vertical: true,
      children: [
        ...ButtonRows,
        CurrentDisplayMode,
      ]
    }),
  }).on('key-press-event', (_, event) => {
    const [, keyval] = event.get_keyval()
    switch (keyval) {
      case 65361: // left
      case 65056: // shift+tab
        hoverIcon((hoveredIconIndex - 1 + icons.length) % icons.length)
        break
      case 65363: // right
      case 65289: // tab
        hoverIcon((hoveredIconIndex + 1) % icons.length)
        break
      case 65362: // up
        hoverIcon((hoveredIconIndex - iconsPerRow + icons.length) % icons.length)
        break
      case 65364: // down
        hoverIcon((hoveredIconIndex + iconsPerRow) % icons.length)
        break
      case 65307: // escape
        window.hide()
        break
      case 65293: // enter
        if (isIconHovered) {
          selectIcon(hoveredIconIndex)
          setTimeout(submit, 100)
        } else {
          submit()
        }
        break
    }
  })

  return { window, selectNextIcon, selectIcon, submit, onIconChange }
}