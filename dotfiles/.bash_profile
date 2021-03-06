# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve SETUP_DIR

if [ -d "$HOME/.setup" ]; then
  SETUP_DIR="$HOME/.setup"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$SETUP_DIR/bin:$PATH"

# Finally we can source the dotfiles (order matters)

BACKUP_DOTGLOB=$(shopt -p dotglob)
shopt -s dotglob

for DOTFILE in "$SETUP_DIR"/dotfiles/{system/.{function,path},custom/*}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

$BACKUP_DOTGLOB
unset BACKUP_DOTGLOB

# Clean up

unset DOTFILE

# Export

export SETUP_DIR
