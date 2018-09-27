#!/bin/bash

export SETUP_DIR="$HOME/.setup"

# Make utilities available

PATH="$SETUP_DIR/bin:$PATH"

# Main Script is at the bottom of this file

function installCommandLineTools() {
  info "Checking for Command Line Tools..."

  if [[ ! "$(type -P gcc)" || ! "$(type -P make)" ]]; then
    local osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
    local cmdLineToolsTmp="${tmpDir}/.com.apple.dt.CommandLineTools.installondemand.in-progress"

    # Create the placeholder file which is checked by the software update tool
    # before allowing the installation of the Xcode command line tools.
    touch "${cmdLineToolsTmp}"

    # Find the last listed update in the Software Update feed with "Command Line Tools" in the name
    cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | tail -1 | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)

    softwareupdate -i "${cmd_line_tools}" -v

    # Remove the temp file
    if [ -f "${cmdLineToolsTmp}" ]; then
      rm ${v} "${cmdLineToolsTmp}"
    fi
  fi

  success "Command Line Tools installed"
}

function installHomebrew () {
  # Check for Homebrew
  info "Checking for Homebrew..."
  if [ ! "$(type -P brew)" ]; then
    info "No Homebrew. Gots to install it..."
    #   Ensure that we can actually, like, compile anything.
    if [[ ! $(type -P gcc) && "$OSTYPE" =~ ^darwin ]]; then
      info "XCode or the Command Line Tools for XCode must be installed first."
      installCommandLineTools
    fi
    # Check for Git
    if [ ! "$(type -P git)" ]; then
      info "XCode or the Command Line Tools for XCode must be installed first."
      installCommandLineTools
    fi
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    installHomebrewTaps
  fi

  # Check for mas
  if [ ! "$(type -P mas)" ]; then
    brew install mas
  fi

  # Login to App Store
  ### mas issue #164 prevents this from working
  # mas signout
  # input "Please enter your Mac app store username: "
  # read macStoreUsername
  # input "Please enter your Mac app store password: "
  # read -s macStorePass
  # echo ""
  # mas signin "$macStoreUsername" "$macStorePass"

  success "Homebrew installed"
}

function brewCleanup () {
  # This function cleans up an initial Homebrew installation

  info "Running Homebrew maintenance..."

  brew cleanup
}

function installBrewfile() {
  function appendBrewfile() {
    BREWFILE=${BREWFILE}$'\n'${*}
  }

  info "Executing Brewfile..."

  unset BREWFILE

  # filter out mas entries, since it crashes on HighSierra/Mojave
  while read l; do
    if ! [ "${l:0:1}" = "#" ]; then
      if [ "${l:0:3}" = "mas" ]; then
        warning "${l:4} not installed due to bug in App Store, please install manually"
      else
        appendBrewfile ${l}
      fi
    fi
  done <"$SETUP_DIR/package-lists/Brewfile"

  brew bundle --file=- <<EOF
  ${BREWFILE}
EOF

  brewCleanup

  success "Brewfile installed"
}

function installMacOSDefaults() {
  seek_confirmation "Would you like to install the custom Mac OS Defaults?"
  if is_confirmed; then
    info "Installing Mac OS Defaults..."

    . "$SETUP_DIR/macOSDefaults.sh"

    success "Mac OS Defaults Installed"
  fi
}

function installDotfiles() {
  seek_confirmation "Would you like to install custom dotfiles?"
  if is_confirmed; then
    info "Installing Dotfiles..."

    ln -sfv "$SETUP_DIR/dotfiles/.bash_profile" ~
    ln -sfv "$SETUP_DIR/dotfiles/.inputrc" ~
    ln -sfv "$SETUP_DIR/dotfiles/.gitconfig" ~
    ln -sfv "$SETUP_DIR/dotfiles/.gitignore_global" ~

    input "(gitconfig) Enter your first and last name.\n"
    read gitName
    git config --global --add user.name "$gitName"
    input "(gitconfig) Enter your email.\n"
    read gitEmail
    git config --global --add user.email "$gitEmail"

    PS1="tmp"
    . ~/.bash_profile
    get PS1
    
    success "Dotfiles Installed"
  fi
}

function installRuby() {

  info "Checking for RVM (Ruby Version Manager)..."

  local RUBYVERSION="2.5" # Version of Ruby to install via RVM

  # Check for RVM
  if [ ! "$(type -P rvm)" ]; then
    seek_confirmation "Couldn't find RVM. Install it?"
    if is_confirmed; then
      curl -L https://get.rvm.io | bash -s stable
      #rvm get stable --autolibs=enable
      rvm install ${RUBYVERSION}
      rvm use ${RUBYVERSION} --default

      gem cleanup
      rvm cleanup all
    fi
  fi

  success "RVM and Ruby are installed"
}

function installNode() {

  info "Checking for NVM (Node Version Manager)..."

  # Check for NVM

  . "${SETUP_DIR}/dotfiles/custom/.nvm"
  if [[ ! $(nvm --version 2>/dev/null) ]]; then
    seek_confirmation "Couldn't find NVM. Install it?"
    if is_confirmed; then
      # curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
      # export NVM_DIR="$HOME/.nvm"
      # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
      # nvm install --lts

      brew install nvm

      . "${SETUP_DIR}/dotfiles/custom/.nvm"
      
      # nvm install --lts

      # # Globally install with npm

      # packages=()
      # while read -r; do packages+=("$REPLY"); done <"$SETUP_DIR/package-lists/npm-global"

      # npm install -g "${packages[@]}"
      
      # npm cache clean

      success "NVM installed"
    else
      return 0
    fi
  fi

  seek_confirmation "Install Node LTS and global NPM packages?"
  if is_confirmed; then
    nvm install --lts

    # Globally install with npm

    packages=()
    while read -r; do packages+=("$REPLY"); done <"$SETUP_DIR/package-lists/npm-global"

    npm install -g "${packages[@]}"
    
    success "Node LTS and global NPM packages installed"
  fi
}

function configureSSH() {
  info "Configuring SSH"

  info "Checking for SSH key in ~/.ssh/id_rsa.pub, generating one if it doesn't exist"
  [[ -f "${HOME}/.ssh/id_rsa.pub" ]] || ssh-keygen -t rsa

  info "Copying public key to clipboard"
  [[ -f "${HOME}/.ssh/id_rsa.pub" ]] && cat "${HOME}/.ssh/id_rsa.pub" | pbcopy

  # Add SSH keys to Github
  seek_confirmation "Add SSH key to Github?"
  if is_confirmed; then
    info "Paste the key into Github"

    open https://github.com/account/ssh

    seek_confirmation "Test Github Authentication via ssh?"
    if is_confirmed; then
      info "Note that even when successful, this will fail the script."
      ssh -T git@github.com
    fi

    success "SSH Configured"
  fi
}

function syncVSCodeSettings() {
  seek_confirmation "Would you like to install the VS Code Settings Sync extension?"
  if is_confirmed; then
    if [ ! "$(type -P code)" ]; then
      cat << EOF >> ~/.bash_profile
        # Add Visual Studio Code (code)
        export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF
    fi
    code -—install-extension shan.code-settings-sync
    success "VS Code Sync Extension Installed."
    info "Press 'Shift + Alt + D' in VS Code to sync settings."
    code
    seek_confirmation "Continue?"
  fi 
}

# Logging and Colors
# -----------------------------------------------------
# Here we set the colors for our script feedback.
# Example usage: success "sometext"
#------------------------------------------------------

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)
cyan=$(tput setaf 6)
yellow=$(tput setaf 11)

function _alert() {
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${yellow}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}${cyan}"; printLog="false"; fi
  if [ "${1}" = "info" ]; then local color=""; fi
  if [ "${1}" = "header" ]; then local color="${bold}"; fi
  echo -e "$(date +"%r") ${color}$(printf "[%9s]" "${1}") ${_message}${reset}";
}

function error ()     { local _message="${*}"; echo "$(_alert error)"; }
function warning ()   { local _message="${*}"; echo "$(_alert warning)"; }
function info ()      { local _message="${*}"; echo "$(_alert info)"; }
function header ()    { local _message="${*}"; echo "$(_alert header)"; }
function success ()   { local _message="${*}"; echo "$(_alert success)"; }
function input()      { local _message="${*}"; echo -n "$(_alert input)"; }

function seek_confirmation() {
  # Asks questions of a user and then does something with the answer.
  # y/n are the only possible answers.
  #
  # USAGE:
  # seek_confirmation "Ask a question"
  # if is_confirmed; then
  #   some action
  # else
  #   some other action
  # fi
  #
  # Credt: https://github.com/kevva/dotfiles
  # ------------------------------------------------------

  input "$@"
  read -p " (y/n) " -n 1
  echo ""
}

function is_confirmed() {
  if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

function safeExit() {
  sudo -k

  exit 2
}
######################

header "Mac OS Setup"
info "This script will install your brewfile and optionally perform additional setup tasks."
info "To begin, enter your password, to exit use Control-C"

trap "safeExit" 2
sudo -v

# installCommandLineTools
# installHomebrew
# installBrewfile

# installMacOSDefaults
installDotfiles
# installRuby
# installNode
# configureSSH
syncVSCodeSettings

sudo -k

success "Mac OS Setup Complete"
