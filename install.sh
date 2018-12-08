#!/bin/bash

set -e

shopt -s extglob

dotfiles_dir="$HOME/rcfiles"

main() {
  local exclude=".git|.gitignore|.gitmodules|install.sh|.config|.|..|"


  for entry in ./!($exclude)
  do
    ln -vnsf $dotfiles_dir/$entry $HOME/$entry
  done
}

copy_config() {

  for entry in .config/*
  do
    ln -vns $dotfiles_dir/$entry $HOME/$entry
  done

}


main
copy_config

