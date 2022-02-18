#!/usr/bin/env bash
. "$HOME/.cache/wal/colors.sh"
darker() {
  "./darker.sh" "$@"
}
mix() {
  "./mix.sh" "$@"
}
torgb() {
  hex=$1
  printf "%d,%d,%d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

#BG=$(darker ${color0:1} -20)
BG=${color0:1}
FG=${color15:1}
MENU_BG=${color0:1}
MENU_FG=${color15:1}
HDR_BG=${color0:1}
HDR_FG=${color15:1}
SEL_BG=${color1:1}
SEL_FG=${color0:1}
TXT_BG=${color0:1}
TXT_FG=${color15:1}
BTN_BG=${color2:1}
BTN_FG=${color15:1}
HDR_BTN_BG=${color3:1}
HDR_BTN_FG=${color15:1}

INACTIVE_FG=$(mix "$FG" "$BG" 0.75)
INACTIVE_BG=$(mix "$BG" "$FG" 0.75)
INACTIVE_MENU_FG=$(mix "$MENU_FG" "$MENU_BG" 0.75)
INACTIVE_MENU_BG=$(mix "$MENU_BG" "$MENU_FG" 0.75)
INACTIVE_TXT_MIX=$(mix "$TXT_FG" "$TXT_BG")
INACTIVE_TXT_FG=$(mix "$TXT_FG" "$TXT_BG" 0.75)
INACTIVE_TXT_BG=$(mix "$TXT_BG" "$BG" 0.75)

cat <<EOF | sudo tee $HOME/.local/share/color-schemes/pywal.colors 
[ColorEffects:Disabled]
Color=$(torgb ${color7:1})
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=$(torgb ${color7:1})
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=true
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=$(torgb ${BTN_BG})
BackgroundNormal=$(torgb ${BTN_BG})
DecorationFocus=$(torgb $(darker ${INACTIVE_FG} -15))
DecorationHover=$(torgb $(darker ${INACTIVE_FG} 15))
ForegroundActive=$(torgb ${BTN_FG})
ForegroundInactive=$(torgb $(mix ${BTN_FG} ${BTN_BG} 0.75))
ForegroundLink=$(torgb $(darker ${SEL_BG} -20))
ForegroundNegative=240,1,1
ForegroundNeutral=255,221,0
ForegroundNormal=$(torgb ${TXT_FG})
ForegroundPositive=128,255,128
ForegroundVisited=$(torgb $(darker ${SEL_BG} 10))

[Colors:Selection]
BackgroundAlternate=$(torgb ${SEL_BG} )
BackgroundNormal=$(torgb ${SEL_BG})
DecorationFocus=$(torgb $(darker ${INACTIVE_FG} -15))
DecorationHover=$(torgb $(darker ${INACTIVE_FG} 15))
ForegroundActive=$(torgb ${SEL_FG})
ForegroundInactive=$(torgb $(mix ${SEL_FG} ${SEL_BG} 0.75))
ForegroundLink=$(torgb $(darker ${SEL_BG} -10))
ForegroundNegative=240,1,1
ForegroundNeutral=255,221,0
ForegroundNormal=$(torgb ${TXT_FG})
ForegroundPositive=128,255,128
ForegroundVisited=$(torgb $(darker ${SEL_BG} 10))

[Colors:Tooltip]
BackgroundAlternate=$(torgb ${HDR_BG})
BackgroundNormal=$(torgb ${HDR_BG})
DecorationFocus=$(torgb $(darker ${INACTIVE_FG} -15))
DecorationHover=$(torgb $(darker ${INACTIVE_FG} 15))
ForegroundActive=$(torgb ${HDR_FG})
ForegroundInactive=$(torgb ${INACTIVE_HDR_FG})
ForegroundLink=$(torgb $(darker ${SEL_BG} -10))
ForegroundNegative=240,1,1
ForegroundNeutral=255,221,0
ForegroundNormal=$(torgb ${TXT_FG})
ForegroundPositive=128,255,128
ForegroundVisited=$(torgb $(darker ${SEL_BG} 10))

[Colors:View]
BackgroundAlternate=$(torgb $(darker ${MENU_BG} -5))
BackgroundNormal=$(torgb ${MENU_BG})
DecorationFocus=$(torgb $(darker ${INACTIVE_FG} -15))
DecorationHover=$(torgb $(darker ${INACTIVE_FG} 15))
ForegroundActive=$(torgb ${MENU_FG})
ForegroundInactive=$(torgb $(mix ${MENU_FG} ${MENU_BG} 0.75))
ForegroundLink=$(torgb $(darker ${SEL_BG} -20))
ForegroundNegative=240,1,1
ForegroundNeutral=255,221,0
ForegroundNormal=$(torgb ${TXT_FG})
ForegroundPositive=128,255,128
ForegroundVisited=$(torgb $(darker ${SEL_BG} 10))

[Colors:Window]
BackgroundAlternate=$(torgb ${BG})
BackgroundNormal=$(torgb ${BG})
DecorationFocus=$(torgb $(darker ${INACTIVE_FG} -15))
DecorationHover=$(torgb $(darker ${INACTIVE_FG} 15))
ForegroundActive=$(torgb ${FG})
ForegroundInactive=$(torgb ${INACTIVE_FG})
ForegroundLink=$(torgb $(darker ${SEL_BG} -20))
ForegroundNegative=240,1,1
ForegroundNeutral=255,221,0
ForegroundNormal=$(torgb ${TXT_FG})
ForegroundPositive=128,255,128
ForegroundVisited=$(torgb $(darker ${SEL_BG} 10))

[General]
ColorScheme=Pywal
Name=Pywal
shadeSortColumn=true

[KDE]
contrast=0

[WM]
activeBackground=$(torgb ${MENU_BG})
activeBlend=$(torgb ${MENU_BG})
activeForeground=$(torgb ${TXT_FG})
inactiveBackground=$(torgb ${BG})
inactiveBlend=$(torgb ${BG})
inactiveForeground=$(torgb ${TXT_FG})
EOF
