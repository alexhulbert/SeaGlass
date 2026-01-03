import app from "ags/gtk3/app"
import DisplaySwitcher, { switchDisplay } from "./display-switcher"
import PowerMenu from "./power-menu"

app.start({
  css: "./style.css",
  main() {
    DisplaySwitcher()
    PowerMenu()
  },
  requestHandler(argv: string[], res: (response: string) => void) {
    const [cmd] = argv
    if (cmd === "switchDisplay") {
      switchDisplay()
      res("ok")
    } else {
      res(`unknown command: ${cmd}`)
    }
  }
})
