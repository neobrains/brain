#!/bin/bash

set -e

if ! command -v brain &>/dev/null; then
    echo -e "\e[31mError: brain is not installed.\e[0m"
    exit 1
fi

check_sudo() {
    if ! sudo -v >/dev/null 2>&1; then
        echo -e "\e[31mError: You need to have sudo privileges to uninstall brain\e[0m"
        exit 1
    fi
}

printf "\e[33mUninstalling brain...\e[0m\n"

check_sudo

sudo rm -f /usr/local/bin/brain

if [ -d ~/.brain ]; then
    sudo rm -rf ~/.brain
fi

printf "\e[32mbrain has been uninstalled.\e[0m\n"

exit 0
