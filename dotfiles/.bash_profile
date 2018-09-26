# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve SETUP_DIR

if [ -d "$HOME/.setup/dotfiles" ]; then
  SETUP_DIR="$HOME/.setup/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Finally we can source the dotfiles (order matters)

for DOTFILE in "$DOTFILES_DIR"/system/.{function,path,env,alias,completion,prompt,nvm,rvm,vsc}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
  echo "$DOTFILE"
done

# Clean up

unset DOTFILE

# Export

export SETUP_DIR