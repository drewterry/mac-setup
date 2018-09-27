# mac-setup
Setup script for mac os

__NOTE THIS IS A WIP__

*I highly recommended reading through the shell scripts and dotfiles before installing this.  Many of these settings are preferences, and yours may differ.*

# Running

The following command will run `setup.sh`, download this repository, and execute `install.sh`.

```
bash <(curl -sL https://raw.githubusercontent.com/drewterry/mac-setup/master/setup.sh)
```

# Customization
If you would like to tweak these files, please feel free to fork the repo.  A few helpful hints:
- Anything in `dotfiles\custom` is sourced in `.bash_profile`, so adding dotfiles here will cause them to be run on load.
- `package-lists/Brewfile` can be used to install most applications. Try `brew search` to find the proper names.
  - Note: Mac App Store apps are not currently supported, due to [bug #164](https://github.com/mas-cli/mas/issues/164).
- `package-lists/npm-global` will install any listed packages during the installation of nvm.
- VS Code Setting Sync Extension syncs all of your extensions and settings to a gist, which is very helpful.  `install.sh` installs this extension, then prompts you to open VS Code and type `Shift-Alt-D` to setup your environment.

