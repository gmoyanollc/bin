#!/bin/bash 
set -x
xrandr
# xrandr --output DVI-I-1 --mode 1680x1050 --left-of VGA-1
xrandr --output VGA-1 --mode 1680x1050
xrandr --output DVI-I-1 --mode 1280x1024 --right-of VGA-1
xrandr
