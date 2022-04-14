const I3 = require('i3') 
const { spawn, exec } = require('child_process')
const { existsSync, readFileSync, writeFileSync, unlinkSync } = require('fs')
const { createServer } = require('net')

const stateFile = "/tmp/i3-sidebar.json"
const state = existsSync(stateFile) ? JSON.parse(readFileSync(stateFile).toString('utf8')) : {}
const saveState = () => writeFileSync(stateFile, JSON.stringify(state))

const i3 = I3.createClient()
let winWidth, winHeight
let sidebarPids = []

i3.tree((err, tree) => {
  winWidth = tree.rect.width
  winHeight = tree.rect.height
})

i3.on('window', (data) => {
  if (data.change === 'new') {
    const windowId = data.container.window
    exec(`xprop -id 0x${windowId.toString(16)} _NET_WM_PID`, (err, resp) => {
      if (err) {
        console.error(err)
      } else if (resp) {
        const windowPid = resp.replace(/^.+?([0-9]+)$/, '$1')
        const isThisWindow = pidEntry => pidEntry.pid !== windowPid
        if (windowPid && sidebarPids.some(isThisWindow)) {
          const sidebarName = sidebarPids.find(isThisWindow).name
          sidebarPids = sidebarPids.filter(x => !isThisWindow(x))
          const { ratio, pos } = state[sidebarName]
          const { x, y, w, h } = calcPosition(ratio, pos)
          state[sidebarName].id = windowId
          const hideTaskbarCmd = `xprop -f _NET_WM_STATE 32a -id ${windowId} -set _NET_WM_STATE _NET_WM_STATE_SKIP_TASKBAR`
          spawn(hideTaskbarCmd, { shell: true, detached: true })
          saveState()
          i3.command([
            `[id=${windowId}]`,
            `floating enable,`,
            `fullscreen disable,`,
            `resize set ${w}px ${h}px,`,
            `move position ${x}px ${y}px,`,
            `sticky enable,`,
            `mark hide_in_scratchpad`
          ].join(' '))
        }
      }
    })
  }
})

const run = (name, position, ratio, cmd) => {
  if (state[name]) {
    const { id: winId, isHidden } = state[name]
    i3.tree((err, tree) => {
      winWidth = tree.rect.width
      winHeight = tree.rect.height
      const sidebarWindows = getMatchingWindows(tree, n => n.window === winId)
      if (sidebarWindows.length) {
        if (isHidden) {
          i3.command(`[id="${winId}"] scratchpad show`)
          state[name].isHidden = false
        } else {
          i3.command(`[id="${winId}"] move scratchpad`)
          state[name].isHidden = true
        }
        saveState()
      } else {
        spawnNewSidebarWindow(cmd, name)
      }
    })
  } else {
    state[name] = { pos: position, ratio }
    saveState()
    spawnNewSidebarWindow(cmd, name)
  }
}

const spawnNewSidebarWindow = (cmd, name) => {
  const { pid } = spawn(cmd, { shell: true, detached: true })
  sidebarPids.push({ pid, name })
}

const getMatchingWindows = (root, cond) => {
  const children = (root.nodes || []).concat((root.floating_nodes || []))
  return children.reduce((prev, node) => [
    ...prev,
    ...(cond(node) ? [node] : []),
    ...getMatchingWindows(node, cond)
  ], [])
}

const calcPosition = (ratio, pos) => {
  if (pos === 'top' || pos == 'bottom') {
    return {
      x: 0,
      y: pos === 'top' ? 0 : Math.floor((1 - ratio) * winHeight),
      w: winWidth,
      h: Math.floor(ratio * winHeight)
    }
  } else {
    return {
      x: pos === 'left' ? 0 : Math.floor((1 - ratio) * winWidth),
      y: 0,
      w: Math.floor(ratio * winWidth),
      h: winHeight
    }
  }
}

const SOCKET = '/tmp/i3-sidebar.sock';
if (existsSync(SOCKET)) unlinkSync(SOCKET)
createServer(stream => stream.on('data', data => {
  const msg = JSON.parse(data)
  run(msg.name, msg.position, msg.ratio, msg.cmd)
})).listen(SOCKET)