# dotfiles
.files for configuration in Debian/Ubuntu

## Installation

Clone the repository and run ./bootstrap.sh

The bootstrap will take backup of your existing configuration files.

TODO: There will be command line parameters to:
* select what you want to install
* reverting changes
* showing help

You can also do manual installation by replacing existing files in your home folder
with the ones in the repository. You will also need to install required packages manually.

## Files

* .bashrc
  * Configuration for Bash
* .vimrc
  * Configuration for VIM
* .tmux.conf
  * Configuration for tmux

TODO:
* SSH config
* GIT config
* Fonts
* CCache
* Valgrind
* Additional useful scripts
