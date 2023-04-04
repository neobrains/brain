#!/bin/bash

set -e

echo "Checking for updates to Discord..."

# Get the latest version number from the Discord website
LATEST_VERSION_URL=$(curl -w "%{url_effective}\n" -I -L -s -S "https://discord.com/api/download?platform=linux&format=tar.gz" -o /dev/null)

LATEST_VERSION=$(echo $LATEST_VERSION_URL | awk -F '/' '{print $6}')

# Get the currently installed version of Discord
CURRENT_VERSION=$(cat /opt/Discord/version 2>/dev/null)  || CURRENT_VERSION="0.0.0"

if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
  echo "Discord is already up to date."
  exit 0
fi

echo "Downloading Discord $LATEST_VERSION..."

# Download the latest version of Discord
curl -o discord.tar.gz -L "https://discord.com/api/download?platform=linux&format=tar.gz"

echo "Stopping Discord, if it's running..."

if pgrep Discord > /dev/null; then
  pkill -9 Discord
fi

echo "Removing old version of Discord..."

if [ -d "/opt/Discord" ]; then
  rm -rf /opt/Discord
fi

echo "Installing Discord $LATEST_VERSION..."

# Install the latest version of Discord
tar -xzf discord.tar.gz -C /opt/

printf "$LATEST_VERSION" > /opt/Discord/version

ln -sf /opt/Discord/Discord /usr/bin/Discord

if [ ! -f "/usr/share/applications/discord.desktop" ]; then
  echo "Creating desktop entry for Discord..."
  printf '[Desktop Entry]\nName=Discord\nComment=All-in-one voice and text chat for gamers.\nExec=/usr/bin/Discord\nIcon=/opt/Discord/discord.png\nTerminal=false\nType=Application\nCategories=Network;InstantMessaging;\n' > /usr/share/applications/discord.desktop
fi

echo "Cleaning up..."

rm -f discord.tar.gz

echo "Starting Discord..."

/usr/bin/Discord --no-sandbox & disown

echo "Done."