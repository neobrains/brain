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
    if ! sudo -v >/dev/null 2>&1; then
        echo -e "\e[31mError: You need to have sudo privileges to use this command\e[0m"
        exit 1
    fi
}

if ! command -v curl &>/dev/null; then
    echo -e "\e[31mError: curl is not installed. Please install curl to continue.\e[0m"
    exit 1
fi

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "help" ]; then
    usage
    exit 0
fi

if [ "$1" == "--version" ] || [ "$1" == "-v" ]; then
    echo $(cat ~/.brain/version)
    exit 0
fi

if [ "$1" == "--upgrade" ] || [ "$1" == "-u" ] || [ "$1" == "upgrade" ]; then
    echo "Updating brain..."
    check_sudo
    curl -o brain https://raw.githubusercontent.com/neobrains/brain/main/brain.sh -L
    chmod +x brain
    if [ ! -d ~/.brain ]; then
        mkdir ~/.brain
    fi
    printf "$latest_version" >~/.brain/version
    sudo mv brain /usr/local/bin/
    echo -e "\e[32mbrain has been updated.\e[0m"
    exit 0
fi

if [ "$1" == "install" ] || [ "$1" == "update" ] || [ "$1" == "remove" ]; then
    if [ "$1" == "install" ]; then
        action="-i"
    elif [ "$1" == "update" ]; then
        action="-u"
    else
        action="-r"
    fi

    if [ -z "$2" ]; then
        echo -e "\e[31mError: You must provide a package name to $1\e[0m"
        usage
        exit 1
    fi

    response=$(curl -sL -w "%{http_code}" "https://raw.githubusercontent.com/neobrains/brain/main/$2.sh" | bash -s "$action")
    exit_status=$?

    if [ $exit_status -ne 0 ] || [ $response -ne 200 ]; then
        echo -e "\e[31mError: Failed to download package '$2'. Please check the package name and try again.\e[0m"
        exit 1
    fi

    exit 0
fi

echo -e "\e[31mError: Unknown command '$1'\e[0m"
usage
