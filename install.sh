#!/bin/bash

set -e

check_sudo() {
  if ! sudo -v >/dev/null 2>&1; then
    echo "Error: You need to have sudo privileges to install brain"
    exit 1
  fi
}

echo "Installing brain..."

if [ -x "$(command -v brain)" ]; then
  latest_version=$(curl -s https://api.github.com/repos/neobrains/brain/releases/latest | grep tag_name | cut -d '"' -f 4)

  if brain --version | grep -q "$latest_version"; then
    echo "brain is already installed and up-to-date."
    exit 0
  else
    read -p "brain is already installed, but there is a new version available. Do you want to update it? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
      curl -o brain https://raw.githubusercontent.com/neobrains/brain/$latest_version/brain.sh
      chmod +x brain
      check_sudo
      if [ ! -d ~/.brain ]; then
        mkdir ~/.brain
      fi
      printf "$latest_version" > ~/.brain/version
      sudo mv brain /usr/local/bin/
      echo "brain has been updated."
    else
      echo "Installation aborted."
      exit 0
    fi
  fi
else
  latest_version=$(curl -s https://api.github.com/repos/example/brain/releases/latest | grep tag_name | cut -d '"' -f 4)
  curl -o brain https://raw.githubusercontent.com/neobrains/brain/$latest_version/brain.sh
  chmod +x brain
  check_sudo
  if [ ! -d ~/.brain ]; then
    mkdir ~/.brain
  fi
  printf "$latest_version" > ~/.brain/version
  sudo mv brain /usr/local/bin/
  echo "brain installed."
fi

exit 0