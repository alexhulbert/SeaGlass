#!/usr/bin/env bash
#move pywal generated colors to a kde colorscheme, names the color scheme after the first given argument
#to be run after pywal
# from https://github.com/bakerk98/pywal-plasma-script/blob/main/move-colors-kde.sh

background=$(grep -A 1 Background] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1),215
transparent=$(grep -A 1 Background] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1),0
foreground=$(grep -A 1 Foreground] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)

color0=$(grep -A 1 Color0Intense] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color1=$(grep -A 1 Color1] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color2=$(grep -A 1 Color2] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color3=$(grep -A 1 Color3] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color4=$(grep -A 1 Color4] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color5=$(grep -A 1 Color5] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color6=$(grep -A 1 Color6] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)
color7=$(grep -A 1 Color7] ~/.cache/wal/colors-konsole.colorscheme | sed -r 's#.*=##' | tail -n 1)

name=$1 #take input for a name to be used for the colorscheme
echo "
[ColorEffects:Disabled]
Color=$background
ColorAmount=0
ColorEffect=3
ContrastAmount=0.55
ContrastEffect=1
IntensityAmount=-1
IntensityEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=$background
ColorAmount=0
ColorEffect=0
ContrastAmount=0
ContrastEffect=0
Enable=false
IntensityAmount=-1
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=$color0,215
BackgroundNormal=$background
DecorationFocus=$color3
DecorationHover=$color3
ForegroundActive=$color3
ForegroundInactive=$color0
ForegroundLink=$color3
ForegroundNegative=$color2
ForegroundNeutral=$color6
ForegroundNormal=$foreground
ForegroundPositive=$color5
ForegroundVisited=$color0

[Colors:Selection]
BackgroundAlternate=$color3,215
BackgroundNormal=$color3,215
DecorationFocus=$color3
DecorationHover=$color3
ForegroundActive=$background2
ForegroundInactive=$color0
ForegroundLink=$color3
ForegroundNegative=$color2
ForegroundNeutral=$color6
ForegroundNormal=$foreground
ForegroundPositive=$color5
ForegroundVisited=$color0

[Colors:Tooltip]
BackgroundAlternate=$color0,215
BackgroundNormal=$background
DecorationFocus=$color3
DecorationHover=$color3
ForegroundActive=$color3
ForegroundInactive=$color0
ForegroundLink=$color3
ForegroundNegative=$color2
ForegroundNeutral=$color6
ForegroundNormal=$foreground
ForegroundPositive=$color5
ForegroundVisited=$color0

[Colors:View]
BackgroundAlternate=$transparent
BackgroundNormal=$transparent
DecorationFocus=$color3
DecorationHover=$color3
ForegroundActive=$color3
ForegroundInactive=$color0
ForegroundLink=$color3
ForegroundNegative=$color2
ForegroundNeutral=$color6
ForegroundNormal=$foreground
ForegroundPositive=$color5
ForegroundVisited=$color0

[Colors:Window]
BackgroundAlternate=$color0,215
BackgroundNormal=$background
DecorationFocus=$color3
DecorationHover=$color3
ForegroundActive=$color3
ForegroundInactive=$color0
ForegroundLink=$color3
ForegroundNegative=$color2
ForegroundNeutral=$color6
ForegroundNormal=$foreground
ForegroundPositive=$color5
ForegroundVisited=$color0

[General]
ColorScheme=$1
Name=$1
shadeSortColumn=true

[KDE]
contrast=5

[WM]
activeBackground=$color3,215
activeBlend=$color3
activeForeground=$foreground
inactiveBackground=$color0,215
inactiveBlend=$color0
inactiveForeground=$color7" > ~/.local/share/color-schemes/$1.colors
kwriteconfig5 --file ~/.config/kdeglobals --group WM --key frame $color3 #these lines come from https://github.com/gikari/bismuth/blob/master/TWEAKS.md
kwriteconfig5 --file ~/.config/kdeglobals --group WM --key inactiveFrame $color0 #they are used to change the color of the border around windows, useful if you use borders
echo "Made a plasma color scheme at ~/.kde4/share/apps/color-schemes/$1.colors"
echo "Don't forget to add it! System Settings -> Appearance -> Colors -> Install from File"
