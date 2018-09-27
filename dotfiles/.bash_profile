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
echo $PATH

# Finally we can source the dotfiles (order matters)

for DOTFILE in "$SETUP_DIR"/dotfiles/system/.{function,path,env,alias,completion,prompt,nvm,rvm,*}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
  echo $DOTFILE
done

# Clean up

unset DOTFILE

# Export

export SETUP_DIR