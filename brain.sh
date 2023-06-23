#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # stands for No Color

readonly BRAIN_DIR="$HOME/.brain"
readonly VERSION_FILE="$HOME/.brain/version"
readonly _BRAIN_BIN="/usr/local/bin/brain"
readonly RAW_URI="https://raw.githubusercontent.com/neobrains/brain/main"

valid_commands=("install" "uninstall" "update" "upgrade" "search" "list" "info")

usage() {
    declare -A options
    options["-h, --help"]="Show this help message and exit"
    options["-v, --version"]="Show version and exit"
    options["-u, --upgrade"]="Update brain to the latest version"
    options["-f, --force"]="Force update brain to the latest version"
    options["-r, --remove"]="Remove brain from your system"

    declare -A commands
    commands["install"]="Install a package"
    commands["remove"]="Remove a package"
    commands["update"]="Update a package"
    commands["neurons"]="List (local / remote) / search / info about packages"

    echo "Usage: $(basename "$0") [options] [command]"
    echo "brain version $(cat "$VERSION_FILE")"
    echo "Options:"

    for opt in "${!options[@]}"; do
        printf "  %-20s %s\n" "$opt" "${options[$opt]}"
    done

    echo "Commands:"

    for cmd in "${!commands[@]}"; do
        printf "  %-20s %s\n" "$cmd" "${commands[$cmd]}"
    done

    echo ""
    echo "For more information, visit https://github.com/neobrains/brain"
}

neurons_usage() {
    declare -A commands

    commands["list remote"]="List all available packages"
    commands["list local"]="List locally installed packages"
    commands["info"]="Show information about a package"

    declare -r script_name=$(basename "$0")

    echo "Usage: $script_name [options] [command]"
    echo "Commands:"

    for cmd in "${!commands[@]}"; do
        printf "  %-15s %s\n" "$cmd" "${commands[$cmd]}"
    done

    echo ""
    echo "For more information, visit https://github.com/neobrains/brain"
}

check_sudo() {
    if ! sudo -v &>/dev/null; then
        printf "${RED}Error: You need to have sudo privileges to use this command${NC}\n"
        exit 1
    fi
}

if ! command -v curl &>/dev/null; then
    printf "${RED}Error: curl is not installed. Please install curl to continue.${NC}\n"
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
        curl -fsSL -o brain "${RAW_URI}/brain.sh"
        chmod +x brain
        if [ ! -d "$BRAIN_DIR" ]; then
            mkdir "$BRAIN_DIR"
        fi
        latest_version=$(curl -s https://api.github.com/repos/neobrains/brain/releases/latest | jq -r '.tag_name')
        echo "$latest_version" >"$VERSION_FILE"
        sudo mv brain /usr/local/bin/
        printf "${GREEN}brain has been updated.${NC}\n"
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
        printf "${GREEN}brain has been removed.${NC}\n"
    fi
fi

if [[ $1 =~ (neurons) ]]; then
    if [[ $# -eq 0 || $2 =~ (-h|--help|help) ]]; then
        neurons_usage
        exit 0
    fi

    case "$2" in
    "list")
        if [ -z "$3" ]; then
            echo -e "${RED}Error: You must provide a package name to list${NC}"
            neurons_usage
            exit 1
        fi
        case "$3" in
        "remote")
            echo -e "${GREEN}Available packages:${NC}\n"
            printf "%-30s %s\n" "Name" "Description"
            NEURONS=$(curl -s https://api.github.com/repos/neobrains/brain/contents/neurons | jq -r '.[].name')
            NEURONS_DESCRIPTION=$(curl -s https://raw.githubusercontent.com/neobrains/brain/main/descriptions.json)

            for package in $NEURONS; do
                package_name=$(echo "$package" | sed 's/\.sh$//')
                description=$(echo $NEURONS_DESCRIPTION | jq -r ".$package_name")
                printf "%-30s %s\n" "$package_name" "$description"
            done
            ;;
        "local")
            echo "not implemented yet"
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$3'${NC}"
            neurons_usage
            exit 1
            ;;
        esac
        ;;
    "info")
        if [ -z "$3" ]; then
            echo -e "${RED}Error: You must provide a package name to info${NC}"
            neurons_usage
            exit 1
        fi

        echo "not implemented yet"
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$2'${NC}"
        neurons_usage
        exit 1
        ;;
    esac
    exit 0
fi

if [[ $1 =~ (install|update|remove) ]]; then
    case "$1" in
    "install")
        action="-install"
        ;;
    "update")
        action="-update"
        ;;
    "remove")
        action="-uninstall"
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        usage
        exit 1
        ;;
    esac
    if [ -z "$2" ]; then
        echo -e "${RED}Error: You must provide a package name to $1${NC}"
        usage
        exit 1
    fi

    script=$(curl -sL "$RAW_URI/neurons/$2.sh")

    if [ "$script" == "404: Not Found" ]; then
        echo -e "${RED}Error: Package '$2' not found${NC}"
        exit 1
    fi

    echo "$script" | sudo bash -s -- "$action"

    exit_status=$?

    if [ $exit_status -ne 0 ]; then
        echo -e "${RED}Error: $2 failed to $1${NC}"
        exit 1
    fi
    exit 0
fi

case $1 in
"${valid_commands[@]}") ;;
*)
    echo -en "${RED}Error: Unknown command '$1'${NC}\n"
    usage
    exit 1
    ;;
esac