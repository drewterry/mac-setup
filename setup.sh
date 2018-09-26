#! /bin/bash

mkdir -p "$HOME/.setup"

curl -L https://github.com/drewterry/mac-setup/tarball/master | tar -xzv -C ~/.setup --strip-components=1 --exclude='{.gitignore}'

. "$HOME/.setup/install.sh" < <(echo anything)