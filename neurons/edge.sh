#!/bin/bash

ARCH=$(uname -m)
PACKAGE_MANAGER_UPDATE_CMD=
PACKAGE_MANAGER_INSTALL_CMD=
PACKAGE_MANAGER_UNINSTALL_CMD=

case "$ARCH" in
x86_64 | amd64)
    if [ -x "$(command -v dpkg)" ]; then
        PACKAGE_MANAGER_UPDATE_CMD="sudo dpkg -i ./microsoft-edge-stable_*.deb"
        PACKAGE_MANAGER_INSTALL_CMD="sudo dpkg -i ./microsoft-edge-stable_*.deb"
        PACKAGE_MANAGER_UNINSTALL_CMD="sudo apt remove microsoft-edge-stable"
        URL=$(curl -s https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ | grep -o '<a href="[^"]*deb"' | grep -o '[^"]*deb' | sort -V | tail -n 1 | awk '{print "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/"$0}')
    elif [ -x "$(command -v rpm)" ]; then
        PACKAGE_MANAGER_UPDATE_CMD="sudo rpm -i ./microsoft-edge-stable-*.rpm"
        PACKAGE_MANAGER_INSTALL_CMD="sudo rpm -U ./microsoft-edge-stable-*.rpm"
        PACKAGE_MANAGER_UNINSTALL_CMD="sudo rpm -e microsoft-edge-stable"
        URL=$(curl -s https://packages.microsoft.com/yumrepos/edge/Packages/m/ | grep -o '<a href="[^"]*rpm"' | grep -o '[^"]*rpm' | sort -V | tail -n 1 | awk '{print "https://packages.microsoft.com/yumrepos/edge/Packages/m/"$0}')
    else
        echo "Unknown package manager"
        exit 1
    fi
    ;;
*)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

case "$1" in
-install)
    if [ ! -f "$(basename "$URL")" ]; then
        echo "Downloading package..."
        curl -O "$URL"
    fi
    echo "Installing package..."
    $PACKAGE_MANAGER_INSTALL_CMD
    rm -f ./microsoft-edge-stable_*.deb
    echo "Done!"
    ;;
-update)
    echo "Updating package..."
    if [ -x "$(command -v dpkg)" ]; then
        VERSION_URL=$(curl -s https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ | grep -o '<a href="[^"]*deb"' | grep -o '[^"]*deb' | sort -V | tail -n 1)
        LATEST_WEB_VERSION=$(basename "$VERSION_URL" | grep -oP "(?<=microsoft-edge-stable_)\d+(\.\d+)+(-\d+)?")
        LATEST_LOCAL_VERSION=$(dpkg -s microsoft-edge-stable | grep Version | awk '{print $2}')
    elif [ -x "$(command -v rpm)" ]; then
        echo "Soon..."
        exit 1
    fi
    echo "Latest web version: $LATEST_WEB_VERSION"
    echo "Latest local version: $LATEST_LOCAL_VERSION"
    if [ "$LATEST_WEB_VERSION" = "$LATEST_LOCAL_VERSION" ]; then
        echo "Already up to date!"
        exit 0
    fi

    if [ ! -f "$(basename "$URL")" ]; then
        echo "Downloading package..."
        curl -O "$URL"
    fi
    $PACKAGE_MANAGER_UPDATE_CMD
    rm -f ./microsoft-edge-stable_*.deb
    echo "Done!"
    ;;
-uninstall)
    echo "Uninstalling package..."
    $PACKAGE_MANAGER_UNINSTALL_CMD
    echo "Done!"
    ;;
*)
    echo "Usage: $0 {-install | -update | -uninstall}"
    exit 1
    ;;
esac
