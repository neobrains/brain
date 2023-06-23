#!/bin/bash

set -e

VERSIONS_JSON=$(curl -sL https://nodejs.org/dist/index.json)
LATEST_VERSION=$(echo "$VERSIONS_JSON" | jq -r '.[0].version')
CURRENT_VERSION=$(cat /usr/local/node/brain_version 2>/dev/null) || CURRENT_VERSION="node"


arch=$(uname -m)

case $arch in
x86_64)
    arch="linux-x64"
    ;;
aarch64)
    arch="linux-arm64"
    ;;
armv7l)
    arch="linux-armv7l"
    ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

unpack() {
    curl -o node.tar.xz -L "https://nodejs.org/dist/$LATEST_VERSION/node-$LATEST_VERSION-$arch.tar.xz"
    if [ -d "/usr/local/node" ]; then
        echo "Removing old version of NodeJS..."
        rm -rf /usr/local/node
    fi
    echo "Installing NodeJS $LATEST_VERSION..."
    tar -xf node.tar.xz -C /usr/local/
    echo "$LATEST_VERSION" >/usr/local/node-$LATEST_VERSION-$arch/brain_version
    ln -sf /usr/local/node-$LATEST_VERSION-$arch/bin/node /usr/local/bin/node
    ln -sf /usr/local/node-$LATEST_VERSION-$arch/bin/npm /usr/local/bin/npm
    ln -sf /usr/local/node-$LATEST_VERSION-$arch/bin/npx /usr/local/bin/npx
    echo "Cleaning up..."
    rm -f node.tar.xz
    echo "Done."
}

update() {
    echo "Checking for updates..."
    if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
        echo "NodeJS is already up to date ($CURRENT_VERSION)."
        exit 0
    else
        echo "Updating NodeJS $CURRENT_VERSION -> $LATEST_VERSION"
        unpack
    fi
}

if [[ $1 =~ (-install) ]]; then
    if [[ "$CURRENT_VERSION" == "node" ]]; then
        echo "Installing NodeJS..."
        unpack
    else
        echo "NodeJS is already installed ($CURRENT_VERSION). If you want to update use brain update <name>"
    fi
elif [[ $1 =~ (-update) ]]; then
    update
elif [[ $1 =~ (-uninstall) ]]; then
    echo "Removing NodeJS ($CURRENT_VERSION)"
    if [ -d "/usr/local/node-$LATEST_VERSION-$arch" ]; then
        rm -rf /usr/local/node-$LATEST_VERSION-$arch
    fi
    if [ -f "/usr/local/bin/node" ]; then
        rm -f /usr/local/bin/node
        rm -f /usr/local/bin/npm
        rm -f /usr/local/bin/npx
    fi
    echo "NodeJS has been removed from your system."
else
    exit 1
fi
