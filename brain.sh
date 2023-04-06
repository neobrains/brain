#!/bin/bash

set -e

readonly brain_dir="$HOME/.brain"
readonly VERSION_FILE=~/.brain/version
readonly _brain_bin="/usr/local/bin/brain"
readonly neurons_git="https://raw.githubusercontent.com/neobrains/brain/main/neurons"
readonly brain_url="https://raw.githubusercontent.com/neobrains/brain/main/brain.sh"

valid_commands=("install" "uninstall" "update" "upgrade" "search" "list" "info")

usage() {
    echo "Usage: $(basename "$0") [options] [command]"
    echo "brain version $(cat "$VERSION_FILE")"
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -v, --version   Show version and exit"
    echo "  -u, --upgrade   Update brain to the latest version"
    echo "  -f, --force     Force update brain to the latest version"
    echo "  -r, --remove    Remove brain from your system"
    echo "Commands:"
    echo "  install         Install a package"
    echo "  uninstall       Uninstall a package"
    echo "  update          Update a package"
    echo "  neurons         List (all / locally installed) / search / info about packages"
    echo ""
    echo "For more information, visit https://github.com/neobrains/brain"
}

neurons_usage() {
    echo "Usage: $(basename "$0") [options] [command]"
    echo "Commands:"
    echo "  list all        List all available packages"
    echo "  list installed  List locally installed packages"
    echo "  search          Search for a package"
    echo "  info            Show information about a package"
    echo ""
    echo "For more information, visit https://github.com/neobrains/brain"
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
    cat "$VERSION_FILE"
    exit 0
fi

if [[ $1 =~ (-u|--upgrade) ]]; then
    update_brain() {
        echo "Updating brain..."
        check_sudo
        curl -fsSL -o brain $brain_url
        chmod +x brain
        if [ ! -d "$brain_dir" ]; then
            mkdir "$brain_dir"
        fi
        latest_version=$(curl -s https://api.github.com/repos/neobrains/brain/releases/latest | jq -r '.tag_name')
        echo "$latest_version" >"$VERSION_FILE"
        sudo mv brain /usr/local/bin/
        printf "\e[32mbrain has been updated.\e[0m\n"
    }
    update_brain
    exit 0
fi

if [[ $1 =~ (-r|--remove) ]]; then
    read -r -p "Are you sure you want to remove brain? (y/n) " answer
    if [[ $answer =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Removing brain..."
        check_sudo
        sudo rm -f /usr/local/bin/brain
        if [ -d ~/.brain ]; then
            sudo rm -rf ~/.brain
        fi
        printf "\e[32mbrain has been removed.\e[0m\n"
    fi
fi

if [[ $1 =~ (neurons) ]]; then
    if [ -z "$2" ]; then
        echo -e "\e[31mError: You must provide a command to neurons\e[0m"
        neurons_usage
        exit 1
    fi

    case "$2" in
    "list")
        if [ -z "$3" ]; then
            echo -e "\e[31mError: You must provide a package name to list\e[0m"
            neurons_usage
            exit 1
        fi
        case "$3" in
        "all")
            echo "not implemented yet"
            ;;
        "installed")
            echo "not implemented yet"
            ;;
        *)
            echo -e "\e[31mError: Unknown command '$3'\e[0m"
            neurons_usage
            exit 1
            ;;
        esac
        ;;
    "search")

        if [ -z "$3" ]; then
            echo -e "\e[31mError: You must provide a package name to search\e[0m"
            neurons_usage
            exit 1
        fi

        echo "not implemented yet"
        ;;
    "info")
        if [ -z "$3" ]; then
            echo -e "\e[31mError: You must provide a package name to info\e[0m"
            neurons_usage
            exit 1
        fi

        echo "not implemented yet"
        ;;
    *)
        echo -e "\e[31mError: Unknown command '$2'\e[0m"
        neurons_usage
        exit 1
        ;;
    esac
    exit 0
fi

if [[ $1 =~ (install|update|uninstall) ]]; then
    case "$1" in
    "install")
        action="-install"
        ;;
    "update")
        action="-update"
        ;;
    *)
        action="-uninstall"
        ;;
    esac
    if [ -z "$2" ]; then
        echo -e "\e[31mError: You must provide a package name to $1\e[0m"
        usage
        exit 1
    fi

    script=$(curl -sL "$neurons_git/$2.sh")

    if [ "$script" == "404: Not Found" ]; then
        echo -e "\e[31mError: Package '$2' not found\e[0m"
        exit 1
    fi

    echo "$script" | sudo bash -s -- "$action"

    exit_status=$?

    if [ $exit_status -ne 0 ]; then
        echo -e "\e[31mError: $2 failed to $1\e[0m"
        exit 1
    fi
    exit 0
fi

case $1 in
"${valid_commands[@]}") ;;
*)
    echo -en "\e[31mError: Unknown command '$1'\e[0m\n"
    usage
    exit 1
    ;;
esac
