#!/bin/bash

set -e

arch=$(uname -m)

case $arch in
x86_64)
    arch="linux"
    ;;
aarch64)
    arch="linuxARM64"
    ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

SOURCE_JSON=$(curl -sL "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release&build=&_=1692659271714")
LATEST_VERSION=$(echo "$SOURCE_JSON" | jq -r '.PCC[0].version')
CURRENT_VERSION=$(cat /usr/local/zig/brain_version 2>/dev/null) || CURRENT_VERSION="pycharm"


unpack() {
    if pgrep pcc >/dev/null; then
        pkill -9 pcc || true
    fi
    curl -o pycharm.tar.gz -L "$(echo "$SOURCE_JSON" | jq -r ".PCC[0].downloads.\"$arch\".link")"
    echo "Stopping PyCharm, if it's running..."
    if [ -d "/opt/pycharm-$CURRENT_VERSION" ]; then
        rm -rf "/opt/pycharm-$CURRENT_VERSION"
    fi
    tar -xzf pycharm.tar.gz -C /opt/
    echo "$LATEST_VERSION" >"/opt/pycharm-community-$LATEST_VERSION/brain_version"
    ln -sf /opt/"pycharm-community-$LATEST_VERSION/bin/pycharm.sh" /usr/local/bin/pcc
    echo "Creating desktop entry for PyCharm..."
    printf "[Desktop Entry]\nName=PyCharm Community\nExec=/usr/local/bin/pcc\nIcon=/opt/pycharm-community-$LATEST_VERSION/bin/pycharm.png\nTerminal=false\nType=Application\n" >/usr/share/applications/pcc.desktop
    echo "Cleaning up..."
    rm -f pycharm.tar.gz
    echo "Done."
}

update() {
    echo "Checking for updates..."
    if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
        echo "PyChram is already up to date ($CURRENT_VERSION)."
        exit 0
    else
        echo "Updating PyChram $CURRENT_VERSION -> $LATEST_VERSION"
        unpack
    fi
}

if [[ $1 =~ (-install) ]]; then
    if [[ "$CURRENT_VERSION" == "pycharm" ]]; then
        echo "Installing PyCharm..."
        unpack
    else
        echo "PyCharm is already installed ($CURRENT_VERSION). If you want to update use brain update <name>"
    fi
elif [[ $1 =~ (-update) ]]; then
    update
elif [[ $1 =~ (-uninstall) ]]; then
    if pgrep pcc >/dev/null; then
    pkill -9 pcc
    fi
    echo "Removing PyCharm..."
    if [ -d "/opt/pycharm-community-$CURRENT_VERSION" ]; then
        rm -rf /opt/pycharm-community-$CURRENT_VERSION
    fi
    if [ -f "/usr/share/applications/pcc.desktop" ]; then
        rm -f /usr/share/applications/pcc.desktop
    fi
    if [ -f "/usr/local/bin/pcc" ]; then
        rm -f /usr/local/bin/pcc
    fi
    echo "PyCharm has been removed from your system."
else
    exit 1
fi
