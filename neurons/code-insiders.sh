#!/bin/bash

set -e

if [ "$(uname -m)" == "x86_64" ]; then
  ARCH="x64"
elif [ "$(uname -m)" == "aarch64" ]; then
  ARCH="arm64"
elif [ "$(uname -m)" == "armv7l" ]; then
  ARCH="armhf"
else
  echo "Unsupported architecture: $(uname -m)"
  exit 1
fi

LATEST_VERSION_URL=$(curl -w "%{url_effective}\n" -I -L -s -S "https://code.visualstudio.com/sha/download?build=insider&os=linux-$ARCH" -o /dev/null)
LATEST_VERSION=$(echo "$LATEST_VERSION_URL" | awk -F '/' '{print $6}' | sed -r 's/.*-([0-9]+)\.tar\.gz/\1/')
CURRENT_VERSION=$(cat /opt/VSCode-linux-$ARCH/brain_version 2>/dev/null) || CURRENT_VERSION="0"

unpack() {
  curl -o vscode-insider.tar.gz -L "https://code.visualstudio.com/sha/download?build=insider&os=linux-$ARCH"
  echo "Stopping VSCode Insider, if it's running..."
  if pgrep code >/dev/null; then
    pkill -9 code-insiders || true
  fi
  if [ -d "/opt/VSCode-linux-$ARCH" ]; then
    rm -rf /opt/VSCode-linux-$ARCH
  fi
  tar -xzf vscode-insider.tar.gz -C /opt/
  echo "$LATEST_VERSION" >/opt/VSCode-linux-$ARCH/brain_version
  ln -sf /opt/VSCode-linux-$ARCH/bin/code-insiders /usr/local/bin/code-insiders
  echo "Creating desktop entry for VSCode Insiders..."
  echo -en "[Desktop Entry]\nName=VSCode Insiders\nComment=Visual Studio Code Insiders\nExec=/usr/local/bin/code\nIcon=/opt/VSCode-linux-$ARCH/resources/app/resources/linux/code.png\nTerminal=false\nType=Application\nCategories=Development;\n" >/usr/share/applications/code.desktop
  echo "Cleaning up..."
  rm -f vscode-insiders.tar.gz
  echo "Done."
}

update() {
  echo "Checking for updates..."
  if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "Visual Studio Code is already up to date ($CURRENT_VERSION)."
    exit 0
  else
    echo "Updating Visual Studio Code $CURRENT_VERSION -> $LATEST_VERSION"
    unpack
  fi
}

if [[ $1 =~ (-install) ]]; then
  if [[ "$CURRENT_VERSION" == "0" ]]; then
    echo "Installing Visual Studio Code..."
    unpack
  else
    echo "Visual Studio Code is already installed ($CURRENT_VERSION). If you want to update use brain update <name>"
  fi
elif [[ $1 =~ (-update) ]]; then
  update
elif [[ $1 =~ (-uninstall) ]]; then
  if pgrep code >/dev/null; then
    pkill -9 code
  fi
  echo "Removing Visual Studio Code..."
  if [ -d "/opt/VSCode-linux-$ARCH" ]; then
    rm -rf /opt/VSCode-linux-$ARCH
  fi
  if [ -f "/usr/share/applications/code-insiders.desktop" ]; then
    rm -f /usr/share/applications/code-insiders.desktop
  fi
  if [ -f "/usr/local/bin/code" ]; then
    rm -f /usr/local/bin/code
  fi
  echo "Visual Studio Code Insiders has been removed from your system."
else
  exit 1
fi
