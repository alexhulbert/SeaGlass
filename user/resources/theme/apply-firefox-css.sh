#!/usr/bin/env bash
background=$(grep -A 1 Background] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color2=$(grep -A 1 Color2] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)

echo "
html[data-darkreader-mode] body a {
  color: rgb($color2) !important;
}

@-moz-document regexp('^(?!http).*') {
  :root>* {
  background: rgb($background) !important;
  }
}

#urlbar-input-container, .urlbarView {
  background-color: color-mix(in srgb, rgb($background) 87%, black);
}

#navigator-toolbox, #urlbar-background {
  background: rgb($background) !important;
}

" | tee ~/.mozilla/firefox/ssb/chrome/userContent.css >~/.mozilla/firefox/default/chrome/userContent.css
