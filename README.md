# dotfiles
.files for configuration in Debian/Ubuntu

## Installation

Clone the repository and run ./bootstrap.sh

The bootstrap will take backup of your existing configuration files.

TODO: There will be command line parameters to:
* select what you want to install (with multiple support)
* reverting changes

You can also do manual installation by replacing existing files in your home folder
with the ones in the repository. You will also need to install required packages manually.

## Files

* .bashrc
  * Configuration for Bash
* .vimrc
  * Configuration for VIM
* .tmux.conf
  * Configuration for tmux
* scripts
  * Helper scripts for development

TODO:
* SSH config
* Fonts
* CCache
* Valgrind
* Additional useful scripts
