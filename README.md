# brain

Yet another unix package manager written in bash.

## Why?

Our package manager is designed to address issues that may arise when using packages installed through Flatpak. While Flatpak aims to enhance desktop security through sandboxing, this can sometimes lead to complications when using certain applications. To overcome these issues, our package manager allows for direct installation of packages using formats such as .tar.gz, .deb, and .rpm. By simplifying the installation process, we make it easier for users to install and use these packages without encountering the same issues that can occur with Flatpak.

## Installation

```bash
curl -sL https://neobrains.dev/brain | bash
```

or

```bash
curl -sL https://raw.githubusercontent.com/neobrains/brain/main/install.sh | bash
```

## Usage

Use `brain` / `brain -h` / `brain --help` / `brain help` to get a list of all available commands.

```sh
Usage: brain [options] [command]
brain version v0.0.4
Options:
  -h, --help      Show this help message and exit
  -v, --version   Show version and exit
  -u, --upgrade   Update brain to the latest version
  -f, --force     Force update brain to the latest version
  -r, --remove    Remove brain from your system
Commands:
  install         Install a package
  remove          Remove a package
  update          Update a package
  neurons         List (all / installed) / search / info about packages

For more information, visit https://github.com/neobrains/brain
```

_note that these maybe not be the latest commands and some are not implemented as of now_

## Package requests and issues
If you want to ask support for any package or you are are facing an issue, please open an issue or join our [Discord](https://discord.gg/xEEpJvE9py) server.

## Contribution

Feel free to open a pull request or an issue. We are happy to help you :smile:

Also, if you want to add a package, please open a pull request and join our [Discord](https://discord.gg/xEEpJvE9py) server for easier communication.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
