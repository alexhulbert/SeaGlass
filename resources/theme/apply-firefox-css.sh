#!/usr/bin/env bash
opaque=$(grep -A 1 Background] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
background=$opaque,0.84
color2=$(grep -A 1 Color2] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)

echo "
html body a {
  color: rgb($color2) !important;
}

:root {
  background: url('data:image/gif;base64,R0lGODlhAQABAAD8/ywAAAAAAQABAAAIBAABBAQAOwo=') !important;
  margin: 0 !important;
  padding: 0 !important;
  min-height: 100vh !important;
  width: 100% !important;
  overflow: auto !important;
  position: relative !important;
  scrollbar-width: none !important;
}

html:after {
  content: \"\";
  display: table;
  clear: both;
}

/*:root>* {
  margin: 0 !important;
  padding: 0 !important;
  height: max-content !important;
  min-height: 100vh !important;
  width: 100% !important;
  position: relative !important;
}*/

@-moz-document url-prefix(chrome:), url-prefix(moz-), url-prefix(about:dev) {
  :root {
    /* allow browser uis to be smallers than viewport size */
    min-height: 100% !important;
  }
  :root>* {
    background: rgba($background) !important;
    min-height: 100% !important;
  }
  .logo-and-wordmark {
    display: none !important;
  }
  .search-handoff-button {
    background: rgba(0, 0, 0, .5) !important;
  }
}

html:not(#main-window):before {
  content: \" \";
  background-color: rgba($background) !important;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  position: fixed !important;
  display: block !important;
  width: 100vw;
  height: 100vh;
  z-index: -1;
}

html > body {
  background-color: transparent !important;
}

:root ::selection {
  background-color:  rgba(255, 255, 255, 0.50) !important;
  color: rgba(0, 0, 0, 0.5) !important;
}

body > #outerContainer {
  height: 100vh !important;
}

*[data-darkreader-inline-bgcolor-opaque=""] {
  background-color: rgb($opaque) !important;
}

" | tee ~/.mozilla/firefox/ssb/chrome/userContent.css > ~/.mozilla/firefox/default/chrome/userContent.css
