# brain

Yet another unix package manager written in bash.

## Why?

Yes , we know you got flatpak and other package managers, but we wanted to create our own package manager , though it will not support many packages , but it will support the packages that have issues with flatpak. For example , with flatpak installed discord / vscode there are some known issues , but with brain installed discord / vscode there are no issues as we install then using the tar.gz / deb / rpm / etc. files.

## Installation

```bash
curl -sL https://raw.githubusercontent.com/neobrains/brain/main/install.sh | bash
```

## Usage

Use `brain` / `brain -h` / `brain --help` / `brain help` to get a list of all available commands.

For example:

```bash
brain install <package>
brain remove <package>
brain update <package>
```

are some of the available commands.

## Contribution

Feel free to open a pull request or an issue. We are happy to help you :smile:

Also, if you want to add a package, please open a pull request and join our [Discord](https://discord.gg/xEEpJvE9py) server for easier communication.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
