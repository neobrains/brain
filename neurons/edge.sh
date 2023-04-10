#!/bin/bash

ARCH=$(uname -m)
PACKAGE_MANAGER=
PACKAGE_MANAGER_UPDATE_CMD=
PACKAGE_MANAGER_INSTALL_CMD=
PACKAGE_MANAGER_UNINSTALL_CMD=

case "$ARCH" in
x86_64 | amd64)
    if [ -x "$(command -v dpkg)" ]; then
        PACKAGE_MANAGER="apt-get"
        PACKAGE_MANAGER_UPDATE_CMD="sudo dpkg -i ./microsoft-edge-stable_*.deb"
        PACKAGE_MANAGER_INSTALL_CMD="sudo dpkg -i ./microsoft-edge-stable_*.deb"
        PACKAGE_MANAGER_UNINSTALL_CMD="sudo apt remove microsoft-edge-stable"
        URL=$(curl -s https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ | grep -o '<a href="[^"]*deb"' | grep -o '[^"]*deb' | sort -V | tail -n 1 | awk '{print "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/"$0}')
    elif [ -x "$(command -v rpm)" ]; then
        PACKAGE_MANAGER="dnf"
        PACKAGE_MANAGER_UPDATE_CMD="sudo rpm -i ./microsoft-edge-stable_*.rpm"
        PACKAGE_MANAGER_INSTALL_CMD="sudo rpm -U ./microsoft-edge-stable_*.rpm"
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
    if [ -z "$PACKAGE_MANAGER" ]; then
        echo "Unknown package manager"
        exit 1
    fi
    if [ ! -f "$(basename "$URL")" ]; then
        echo "Downloading package..."
        curl -O "$URL"
    fi
    echo "Installing package..."
    $PACKAGE_MANAGER_INSTALL_CMD
    rm -f ./microsoft-edge-stable_*.deb
    ;;
-update)
    if [ -z "$PACKAGE_MANAGER" ]; then
        echo "Unknown package manager"
        exit 1
    fi
    echo "Updating package list..."
    $PACKAGE_MANAGER_UPDATE_CMD
    rm -f ./microsoft-edge-stable_*.deb
    ;;
-uninstall)
    if [ -z "$PACKAGE_MANAGER" ]; then
        echo "Unknown package manager"
        exit 1
    fi
    echo "Uninstalling package..."
    $PACKAGE_MANAGER_UNINSTALL_CMD
    ;;
*)
    echo "Usage: $0 {-install | -update | -uninstall}"
    exit 1
    ;;
esac
