#!/bin/bash

set -e

readonly brain_dir="$HOME/.brain"
readonly VERSION_FILE=~/.brain/version
readonly brain_bin="/usr/local/bin/brain"
readonly neurons_git="https://raw.githubusercontent.com/neobrains/brain/main/neurons"
readonly brain_url="https://raw.githubusercontent.com/neobrains/brain/main/brain.sh"

usage() {
    echo "Usage: $0 [options] [command]"
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -v, --version   Show version and exit"
    echo "  -u, --update    Update brain to the latest version"
    echo "Commands:"
    echo "  install         Install a package"
    echo "  remove          Remove a package"
    echo "  update          Update a package"
    echo "  upgrade         Upgrade the cli"
    echo "  search          Search for a package"
    echo "  list            List installed packages"
    echo "  info            Show information about a package"
}

check_sudo() {
    if ! sudo -v &>/dev/null; then
        printf "\e[31mError: You need to have sudo privileges to use this command\e[0m\n"
        exit 1
    fi
}

if ! command -v curl &>/dev/null; then
    printf "\e[31mError: curl is not installed. Please install curl to continue.\e[0m\n"
    exit 1
fi

if [[ $# -eq 0 || $1 =~ (-h|--help|help) ]]; then
    usage
    exit 0
fi

if [[ $1 =~ (-v|--version) ]]; then
    echo "$(cat "$VERSION_FILE")"
    exit 0
fi

if [[ $1 =~ (-U|--upgrade) ]]; then
    update_brain() {
        echo "Updating brain..."
        check_sudo
        curl -fsSL -o brain $brain_url
        chmod +x brain
        if [ ! -d "$brain_dir" ]; then
            mkdir "$brain_dir"
        fi
        latest_version=$(curl -s https://api.github.com/repos/neobrains/brain/releases/latest | jq -r '.tag_name')
        printf "$latest_version" >"$VERSION_FILE"
        sudo mv brain /usr/local/bin/
        printf "\e[32mbrain has been updated.\e[0m\n"
    }
    update_brain
    exit 0
fi

if [[ $1 =~ (install|update|remove) ]]; then
    if [ "$1" == "install" ]; then
        action="-install"
    elif [ "$1" == "update" ]; then
        action="-update"
    else
        action="-remove"
    fi
    if [ -z "$2" ]; then
        echo -e "\e[31mError: You must provide a package name to $1\e[0m"
        usage
        exit 1
    fi

    bash <(curl -fsSL "$neurons_git/$2.sh") "$action"

    exit 0
fi

if ! [[ ${COMMANDS[*]} =~ $1 ]]; then
    printf "\e[31mError: Unknown command '$1'\e[0m\n"
    usage
    exit 1
fi
