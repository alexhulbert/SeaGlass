let {commands} = vimfx.modes.normal

const locBarHelper = (symbol) => (args) => {
  let {vim} = args
  let {gURLBar, addEventListener} = vim.window
  addEventListener('keyup', () => {
    gURLBar.value = ''
  }, { once: true })
  gURLBar.value = ''
  commands.focus_location_bar.run(args)
  gURLBar.value = symbol + ' '
  gURLBar.dispatchEvent(new Event('input', {
    bubble: true,
    cancellable: true
  }))
}

vimfx.addCommand({
  name: 'search_tabs',
  description: 'Search tabs',
  category: 'tabs',
  order: commands.focus_location_bar.order + 1,
}, locBarHelper('%'))

vimfx.addCommand({
  name: 'search_bookmarks',
  description: 'Search tabs',
  category: 'tabs',
  order: commands.focus_location_bar.order + 1,
}, locBarHelper('*'))

vimfx.addCommand({
  name: 'password_click_toolbar_button',
  description: 'Open 1Password',
}, ({vim}) => {
  vim.window.document.querySelector('toolbarbutton[label="1Password"]').click()
})

vimfx.set('custom.mode.normal.search_tabs', 'gt')
vimfx.set('custom.mode.normal.search_bookmarks', 'gb')
vimfx.set('custom.mode.normal.password_click_toolbar_button', '1')
