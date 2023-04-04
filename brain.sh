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
    echo $(cat ~/.brain/.version)
    exit 0
fi