# mac-setup
Setup script for mac os

*I highly recommended reading through the shell scripts and dotfiles before installing this.*

# Running

The following command will run `setup.sh`, download this repository, and execute `install.sh`.

```
curl -o- https://raw.githubusercontent.com/drewterry/mac-setup/master/setup.sh | bash
```

# Customization
If you would like to tweak these files, please feel free to fork the repo.  A few helpful hints:
- Anything in the dotfiles subdirectory will be sym-linked to `~/`.
- `Brewfile` can be used to install anything except Mac App Store apps, due to [bug #164](https://github.com/mas-cli/mas/issues/164). Try `brew search` to find the proper names.
- VS Code Setting Sync Extension syncs all of your extensions and settings to a gist, which is very helpful.  `install.sh` installs this extension, then prompts you to open VS Code and type `Shift-Alt-D` to setup your environment.

