#!/bin/bash 
set -x
xrandr
xrandr --output VGA1 --right-of LVDS1
#xrandr --output DVI-I-1 --mode 1680x1050 --left-of VGA-1
xrandr
