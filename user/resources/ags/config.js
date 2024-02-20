import DisplaySwitcher from "./display-switcher.js"
import PowerMenu from "./power-menu.js"

export default {
  stackTraceOnError: true,
  style: './style.css',
  windows: [
    DisplaySwitcher.window,
    PowerMenu.window
  ]
}
