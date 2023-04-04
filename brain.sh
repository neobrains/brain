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
    echo "  upgrade         Upgrade all packages"
    echo "  search          Search for a package"
    echo "  list            List installed packages"
    echo "  info            Show information about a package"
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

if [ "$1" == "--version" ] || [ "$1" == "-v" ]; then
    echo $(cat ~/.brain/version)
    exit 0
fi

if [ "$1" == "--update" ] || [ "$1" == "-u" ]; then
    echo "Updating brain..."
    if ! sudo -v >/dev/null 2>&1; then
    echo "Error: You need to have sudo privileges to update brain"
    exit 1
  fi
    curl -o brain https://raw.githubusercontent.com/neobrains/brain/main/brain.sh -L
    chmod +x brain
    check_sudo
    if [ ! -d ~/.brain ]; then
      mkdir ~/.brain
    fi
    printf "$latest_version" > ~/.brain/version
    sudo mv brain /usr/local/bin/
    echo "brain has been updated."
    exit 0
fi

if [ "$1" == "install" ]; then
    if [ -z "$2" ]; then
        usage
        exit 1
    fi
    curl -sL "https://raw.githubusercontent.com/neobrains/brain/main/$2.sh" | bash
    exit 0
fi