# mac-setup

Setup script for Mac OS X, which does the following:

- Install CommandLineTools
- Install Homebrew
- Install Brewfile
  - `package-lists/Brewfile` shows all applications to be installed.  RVM and NVM are optional during installation.

The script will also prompt to do the following:

- Install custom MacOSDefaults
- Install custom dotfiles
- Install rvm and Ruby
- Install nvm and Node LTS
  - Also installs global npm packages listed in `package-lists/npm-global`
- Configure Github SSH
- Install VS Code Extension "Setting Sync" which syncs preferences and extensions via a gist.

*I highly recommended reading through the shell scripts and dotfiles before installing this.  Many of these settings are preferences, and yours may differ.*

## Running

The following command will run `setup.sh`, download this repository, and execute `install.sh`.

```shell
bash <(curl -sL https://raw.githubusercontent.com/drewterry/mac-setup/master/setup.sh)
```

## Customization

If you would like to tweak these files, please feel free to fork the repo.  A few helpful hints:

- Anything in `dotfiles\custom` is sourced in `.bash_profile`, so adding dotfiles here will cause them to be run on load.
- `package-lists/Brewfile` can be used to install most applications. Try `brew search` to find the proper names.
  - Note: Mac App Store apps are not currently supported, due to [bug #164](https://github.com/mas-cli/mas/issues/164).
- `package-lists/npm-global` will install any listed packages during the installation of nvm.
- VS Code Setting Sync Extension syncs all of your extensions and settings to a gist, which is very helpful.  `install.sh` installs this extension, then prompts you to open VS Code and type `Shift-Alt-D` to setup your environment.
