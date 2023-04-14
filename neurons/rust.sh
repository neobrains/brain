#!/bin/bash

set -e


if [[ $1 =~ (-install) ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
elif [[ $1 =~ (-update) ]]; then
    rustup update
elif [[ $1 =~ (-uninstall) ]]; then
    rustup self uninstall
else
    exit 1
fi