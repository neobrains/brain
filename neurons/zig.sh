#!/bin/bash

set -e

VERSIONS_JSON=$(curl -sL https://ziglang.org/download/index.json)
LATEST_VERSION=$(echo "$VERSIONS_JSON" | jq -r '.master.version')
CURRENT_VERSION=$(cat /usr/local/zig/brain_version 2>/dev/null) || CURRENT_VERSION="zig"

arch=$(uname -m)

case $arch in
x86_64)
    arch="x86_64-linux"
    ;;
aarch64)
    arch="aarch64-linux"
    ;;
riscv64)
    arch="riscv64-linux"
    ;;
powerpc64le)
    arch="powerpc64le-linux"
    ;;
powerpc)
    arch="powerpc-linux"
    ;;
x86 | i386 | i686)
    arch="x86-linux"
    ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

unpack() {
    curl -o zig.tar.xz -L "$(echo "$VERSIONS_JSON" | jq -r ".master.\"$arch\".tarball")"
    if [ -d "/usr/local/zig" ]; then
        echo "Removing old version of Zig..."
        rm -rf /usr/local/zig
    fi
    echo "Installing Zig $LATEST_VERSION..."
    mkdir -p /usr/local/zig
    tar -xJf zig.tar.xz -C /usr/local/zig --strip-components=1
    rm zig.tar.xz
    echo "$LATEST_VERSION" > /usr/local/zig/brain_version
}

update() {
    echo "Checking for updates..."
    if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
        echo "Zig is already up to date ($CURRENT_VERSION)."
        exit 0
    else
        echo "Updating Zig $CURRENT_VERSION -> $LATEST_VERSION"
        unpack
    fi
}

if [[ $1 =~ (-install) ]]; then
    if [[ "$CURRENT_VERSION" == "zig" ]]; then
        echo "Installing Zig..."
        unpack
    else
        echo "Zig is already installed ($CURRENT_VERSION). If you want to update use brain update <name>"
    fi
elif [[ $1 =~ (-update) ]]; then
    update
elif [[ $1 =~ (-uninstall) ]]; then
    echo "Removing Zig ($CURRENT_VERSION)"
    if [ -d "/usr/local/zig" ]; then
        rm -rf /usr/local/zig
    fi
    if [ -f "/usr/local/bin/zig" ]; then
        rm -f /usr/local/bin/zig
    fi
    echo "Zig has been removed from your system."
else
    exit 1
fi
