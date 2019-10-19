#!/bin/bash
# external tools are found in ~/.config/gedit/tools
# tool file permission requires read-write and 'allow executing file as a program'
# [Gedit Tool]
# Name=g-encrypt-g@gmoyano.com
# Applicability=all
# Output=replace-document
# Input=document
# Save-files=nothing

stdin=$(cat)
echo "$stdin" | gpg -a -e -r g@gmoyano.com --no-tty -
