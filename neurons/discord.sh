#!/bin/bash

set -e

LATEST_VERSION_URL=$(curl -w "%{url_effective}\n" -I -L -s -S "https://discord.com/api/download?platform=linux&format=tar.gz" -o /dev/null)
LATEST_VERSION=$(echo "$LATEST_VERSION_URL" | awk -F '/' '{print $6}')
CURRENT_VERSION=$(cat /opt/Discord/brain_version 2>/dev/null)  || CURRENT_VERSION="0.0.0"

unpack() {
  curl -o discord.tar.gz -L "https://discord.com/api/download?platform=linux&format=tar.gz"
  echo "Stopping Discord, if it's running..."
  if pgrep Discord > /dev/null; then
    pkill -9 Discord || true
  fi
  if [ -d "/opt/Discord" ]; then
    rm -rf /opt/Discord
  fi
  tar -xzf discord.tar.gz -C /opt/
  echo "$LATEST_VERSION" > /opt/Discord/brain_version
  ln -sf /opt/Discord/Discord /usr/local/bin/Discord
  echo "Creating desktop entry for Discord..."
  printf '[Desktop Entry]\nName=Discord\nComment=All-in-one voice and text chat for gamers.\nExec=/usr/local/bin/Discord\nIcon=/opt/Discord/discord.png\nTerminal=false\nType=Application\nCategories=Network;InstantMessaging;\n' > /usr/share/applications/discord.desktop
  echo "Cleaning up..."
  rm -f discord.tar.gz
  echo "Done."
}


if [ "$1" == "-install" ]; then
  echo "Downloading Discord $LATEST_VERSION..."
  unpack
elif [ "$1" == "-update" ]; then
  echo "Checking for updates..."
  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    echo "Discord is already up to date ($CURRENT_VERSION)."
    exit 0
  else
    echo "Updating Discord $CURRENT_VERSION -> $LATEST_VERSION"
    unpack
  fi
elif [ "$1" == "-remove" ]; then
  if pgrep Discord > /dev/null; then
    pkill -9 Discord
  fi
  echo "Removing Discord..."
  if [ -d "/opt/Discord" ]; then
    rm -rf /opt/Discord
  fi
  if [ -f "/usr/share/applications/discord.desktop" ]; then
    rm -f /usr/share/applications/discord.desktop
  fi
  if [ -f "/usr/local/bin/Discord" ]; then
    rm -f /usr/local/bin/Discord
  fi
  echo "Discord has been removed from your system."
else
  exit 1
fi