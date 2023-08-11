#!/bin/bash

set -e

LATEST_VERSION=$(curl -sL "https://go.dev/dl/?mode=json" | jq -r '.[0].version')
CURRENT_VERSION=$(cat /usr/local/go/brain_version 2>/dev/null) || CURRENT_VERSION="go"

arch=$(uname -m)

case $arch in
x86_64)
    arch="amd64"
    ;;
x86 | i386 | i686)
    arch="386"
    ;;
aarch64)
    arch="arm64"
    ;;
loongarch64)
    arch="loong64"
    ;;
mips64)
    arch="mips64"
    ;;
mips64le)
    arch="mips64le"
    ;;
mips)
    arch="mips"
    ;;
mipsle)
    arch="mipsle"
    ;;
ppc64)
    arch="ppc64"
    ;;
ppc64le)
    arch="ppc64le"
    ;;
riscv64)
    arch="riscv64"
    ;;
s390x)
    arch="s390x"
    ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

unpack() {
    curl -o go.tar.gz -L "https://dl.google.com/go/$LATEST_VERSION.linux-$arch.tar.gz"
    if [ -d "/usr/local/go" ]; then
        echo "Removing old version of Go..."
        rm -rf /usr/local/go
    fi
    echo "Installing Go $LATEST_VERSION..."
    tar -xzf go.tar.gz -C /usr/local/
    echo "$LATEST_VERSION" >/usr/local/go/brain_version
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
    echo "Cleaning up..."
    rm -f go.tar.gz
    echo "Done."
}

update() {
    echo "Checking for updates..."
    if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
        echo "Go is already up to date ($CURRENT_VERSION)."
        exit 0
    else
        echo "Updating Go $CURRENT_VERSION -> $LATEST_VERSION"
        unpack
    fi
}

if [[ $1 =~ (-install) ]]; then
    if [[ "$CURRENT_VERSION" == "go" ]]; then
        echo "Installing Go..."
        unpack
    else
        echo "Go is already installed ($CURRENT_VERSION). If you want to update use brain update <name>"
    fi
elif [[ $1 =~ (-update) ]]; then
    update
elif [[ $1 =~ (-uninstall) ]]; then
    echo "Removing Go ($CURRENT_VERSION)"
    if [ -d "/usr/local/go" ]; then
        rm -rf /usr/local/go
    fi
    if [ -f "/usr/local/bin/go" ]; then
        rm -f /usr/local/bin/go
    fi
    echo "Go has been removed from your system."
else
    exit 1
fi
