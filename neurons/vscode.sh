#!/bin/bash

set -e

if [ "$( uname -m )" == "x86_64" ] ; then
  ARCH="x64" 
elif [ "$( uname -m )" == "aarch64" ] ; then
  ARCH="arm64" 
elif [ "$( uname -m )" == "armv7l" ] ; then
  ARCH="armhf" 
else 
  echo "Unsupported architecture: $( uname -m )" 
  exit 1 
fi

LATEST_VERSION_URL=$( curl -w "%{url_effective}\n" -I -L -s -S "https://code.visualstudio.com/sha/download?build=stable&os=linux-$ARCH" -o /dev/null )
LATEST_VERSION=$( "$LATEST_VERSION_URL" | awk -F '/' '{print $6}' | sed -r 's/.*-([0-9]+)\.tar\.gz/\1/' )
CURRENT_VERSION=$( cat /opt/VSCode-linux-$ARCH/brain_version 2>/dev/null )  || CURRENT_VERSION="0"

unpack() {
  curl -o vscode.tar.gz -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-$ARCH"
  echo "Stopping VSCode, if it's running..."
  if pgrep code > /dev/null; then
    pkill -9 code || true
  fi
  if [ -d "/opt/VSCode-linux-$ARCH" ]; then
    rm -rf /opt/VSCode-linux-$ARCH
  fi
  tar -xzf vscode.tar.gz -C /opt/
  echo "$LATEST_VERSION" > /opt/VSCode-linux-$ARCH/brain_version
  ln -sf /opt/VSCode-linux-$ARCH/bin/code /usr/local/bin/code
  echo "Creating desktop entry for VSCode..."
  printf "%s" "[Desktop Entry]\nName=VSCode\nComment=Visual Studio Code\nExec=/usr/local/bin/code\nIcon=/opt/VSCode/VSCode-linux-$ARCH/resources/app/resources/linux/code.png\nTerminal=false\nType=Application\nCategories=Development;\n" > /usr/share/applications/code.desktop
  echo "Cleaning up..."
  rm -f vscode.tar.gz
  echo "Starting VSCode ($LATEST_VERSION)"
  /usr/local/bin/code --no-sandbox --user-data-dir ~/.config/Code & disown
  echo "Done."
}

if [ "$1" == "-install" ]; then
  echo "Downloading Visual Studio Code $LATEST_VERSION..."
  unpack
elif [ "$1" == "-update" ]; then
  echo "Checking for updates..."
  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    echo "Visual Studio Code is already up to date ($CURRENT_VERSION)."
    exit 0
  else
    echo "Updating Visual Studio Code $CURRENT_VERSION -> $LATEST_VERSION"
    unpack
  fi
elif [ "$1" == "-remove" ]; then
  if pgrep code > /dev/null; then
    pkill -9 code
  fi
  echo "Removing Visual Studio Code..."
  if [ -d "/opt/VSCode-linux-$ARCH" ]; then
    rm -rf /opt/VSCode-linux-$ARCH
  fi
  if [ -f "/usr/share/applications/code.desktop" ]; then
    rm -f /usr/share/applications/code.desktop
  fi
  if [ -f "/usr/local/bin/code" ]; then
    rm -f /usr/local/bin/code
  fi
  echo "Visual Studio Code has been removed from your system."
else
  exit 1
fi