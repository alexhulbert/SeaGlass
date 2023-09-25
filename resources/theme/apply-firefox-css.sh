#!/usr/bin/env bash
background=$(grep -A 1 Background] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color2=$(grep -A 1 Color2] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)

echo "
html body a {
  color: rgb($color2) !important;
}

@-moz-document regexp('^(?!http).*') {
  :root>* {
    background: rgba($background) !important;
  }
}

" | tee ~/.mozilla/firefox/ssb/chrome/userContent.css >~/.mozilla/firefox/default/chrome/userContent.css
