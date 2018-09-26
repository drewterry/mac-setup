#! /bin/bash

mkdir -p "$HOME/.dotfiles"

curl -L https://github.com/drewterry/mac-setup/tarball/master | tar -xzv -C ~/.dotfiles --strip-components=1 --exclude='{.gitignore}'

. "$HOME/.dotfiles/install.sh"