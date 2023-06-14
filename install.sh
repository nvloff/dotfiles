#!/bin/bash

set -e

shopt -s extglob

# ln -vnsf "$PWD/bash" "$HOME/.bash"
# ln -vnsf "$PWD/bashrc" "$HOME/.bashrc"
# ln -vnsf "$PWD/bundle.bash" "$HOME/.bundle.bash"
# ln -vnsf "$PWD/profile" "$HOME/.profile"

ln -vnsf "$PWD/gitconfig" "$HOME/.gitconfig"

ln -vnsf "$PWD/nvim" "$HOME/.config/nvim"
