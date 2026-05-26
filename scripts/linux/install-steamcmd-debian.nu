#!/usr/bin/env nu

sudo apt update
# Only necessary for Debian 12/Bookworm. Debian 13/Trixie won't need this
# sudo apt install software-properties-common
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steamcmd
