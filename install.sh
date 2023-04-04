#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Variables
brain_url="https://raw.githubusercontent.com/neobrains/brain/main/brain.sh"
brain_dir="$HOME/.brain"
brain_bin="/usr/local/bin/brain"

if ! command -v curl &>/dev/null; then
  echo -e "${RED}Error: curl is not installed. Please install curl to continue.${NC}"
  exit 1
fi

check_sudo() {
  if ! sudo -v >/dev/null 2>&1; then
    echo -e "${RED}Error: You need to have sudo privileges to install brain${NC}"
    exit 1
  fi
}

echo -e "Installing brain..."

# Extract latest version from Github API response
latest_version=$(curl -s https://api.github.com/repos/neobrains/brain/releases/latest | jq -r '.tag_name')

if [ -x "$brain_bin" ]; then
  if [[ "$(brain --version)" == *"$latest_version"* ]]; then
    echo "brain is already installed and up-to-date."
    exit 0
  else
    read -p "Brain is already installed, but there is a new version available. Do you want to update it? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
      # Download and install latest version of brain
      curl -o brain "$brain_url" -L
      chmod +x brain
      check_sudo
      printf "$latest_version" >"$brain_dir/version"
      sudo mv brain "$brain_bin"
      sudo chown root:root "$brain_bin"
      sudo chmod +x "$brain_bin"
      echo -e "${GREEN}brain has been updated.${NC}"
    else
      echo "Installation aborted."
      exit 0
    fi
  fi
else
  # Download and install brain
  curl -o brain "$brain_url" -L
  chmod +x brain
  check_sudo
  mkdir -p "$brain_dir"
  printf "$latest_version" >"$brain_dir/version"
  sudo mv brain "$brain_bin"
  sudo chown root:root "$brain_bin"
  sudo chmod +x "$brain_bin"
  echo -e "${GREEN}brain installed successfully.${NC}"
fi

exit 0
