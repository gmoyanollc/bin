#!/bin/sh

# add display to right of laptop 

xrandr --output VGA1 --left-of LVDS1

read -p "...done."