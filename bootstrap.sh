#!/usr/bin/env bash

DOTFILES=$(pwd -P)

# TODO: Allow multiple targets by using array
INSTALL_TARGET="all"
while [[ $# -gt 0 ]]
do

# Parse command line params
key="$1"
case $key in
  -h|--help)
  HELP=YES
  ;;
  (-v|--vim)
  INSTALL_TARGET="vim"
  ;;
  -b|--bash)
  INSTALL_TARGET="bash"
  ;;
  -t|--tmux)
  INSTALL_TARGET="tmux"
  ;;
  -g|--git)
  INSTALL_TARGET="git"
  ;;
  -c|--cpp)
  INSTALL_TARGET="cpp"
  ;;
  --misc)
  INSTALL_TARGET="misc"
  ;;
  --ccache)
  INSTALL_TARGET="ccache"
  ;;
esac
shift # past argument or value
done

function show_help {
  echo "By default all dotfiles are installed."
  echo "Supported parameters are:"
  echo "-v|--vim             Install vim configuration"
  echo "-b|--bash            Install bash configuration"
  echo "-t|--tmux            Install tmux configuration"
  echo "-c|--cpp             Install cpp development environment"
  echo "-g|--git             Install git configuration"
  echo "--ccahe              Install ccache and configuration"
  echo "--misc               Install misc help packages"
}

if [ -n "$HELP" ]; then
  show_help
  exit
fi

printInfo() {
  printf "\e[38;5;82m$@\e[0m\n"
}

installPackage() {
  PKG_AV=$(sudo apt-cache search $1)
  if [ -z "$PKG_AV" ]; then
    printInfo "!!! Package $1 is not available for installation"
    return
  fi
  PKG_OK=$({ dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed"; } 2>&1)
  if [ -z "$PKG_OK" ]; then
    printInfo "** Installing $1"
    sudo apt-get -qq install -y $1 > /dev/null
  else
    printInfo "** $1 already installed, skipping.."
  fi
}

update() {
  if [ -d .git ]; then
    printInfo "Updating dotfiles repository"
    git pull origin master > /dev/null 2>&1
  fi
  printInfo "Updating apt repository"
  sudo apt-get -qq update
  printInfo "Updating existing packages"
  sudo apt-get -qq -y --allow-unauthenticated upgrade > /dev/null 2>&1
}

reloadBash() {
  read -n 1 -s -r -p "Press any key to reload bash"
  source ~/.bashrc
}

backupConfiguration() {
  if [ -e $1 ]; then
    if [ -e $1.dotfiles.bak ]; then
      printInfo "** Restoring previous backup from $1.dotfiles.bak"
      mv $1.dotfiles.bak $1
    fi
    printInfo "** Moving original $1 to $1.dotfiles.bak"
    mv $1 $1.dotfiles.bak
  fi
}

installGit() {
  printInfo "* Configuring git"
  installPackage git
  installPackage git-svn
  installPackage gitk
  backupConfiguration ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global
  printInfo "** DONE"
}

installBash() {
  printInfo "* Configuring bash"
  backupConfiguration ~/.bashrc
  printInfo "** Installing fortune"
  installPackage fortune-mod
  printInfo "** Adding new .bashrc"
  cp $DOTFILES/.bashrc ~/.bashrc
  printInfo "** DONE"
  if [ "$INSTALL_TARGET" == "bash" ] ; then
    reloadBash
  fi
}

installVim() {
  printInfo "* Configuring VIM"
  backupConfiguration ~/.vimrc
  printInfo "** Adding new .vimrc"
  mkdir -p ~/.vim
  mkdir -p ~/.vim/tags
  mkdir -p ~/.vim/templates

  cp $DOTFILES/.vimrc ~/.vim/vimrc
  ln -s ~/.vim/vimrc ~/.vimrc
  cp $DOTFILES/.vim/tags/cpp ~/.vim/tags/
  backupConfiguration ~/.vim/.ycm_extra_conf.py
  cp $DOTFILES/.vim/.ycm_extra_conf ~/.vim/
  cp $DOTFILES/.vim/tags/generate_tags.sh ~/.vim/tags/
  cp $DOTFILES/.vim/templates/* ~/.vim/templates/

  installPackage vim
  installPackage ctags
  installPackage silversearcher-ag
  installPackage curl
  VIMVERSION=$(vim --version | head -1 | cut -d ' ' -f 5)
  if [ ! $(echo "$VIMVERSION >= 8.0" | bc -l) ]; then
    printInfo "** Installing VIM version 8+"
    sudo add-apt-repository -y ppa:jonathonf/vim > /dev/null 2>&1
    sudo apt-get -qq update
    installPackage vim
  fi

 PKG_AV=$(sudo apt-cache search clang-tools-7)
 if [ "" = "$PKG_AV" ]; then
   printInfo "** Adding apt.llvm.org repository"
   sudo wget -q -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
   sudo add-apt-repository -y "deb http://apt.llvm.org/$(lsb_release -s -c)/ llvm-toolchain-$(lsb_release -s -c) main" > /dev/null 2>&1
   sudo apt-get -qq update
 fi

 printInfo "** Installing clang tools"
 installPackage clang-tools-7
 installPackage clang-format-7
 installPackage clang-tidy-7
 if [ ! -e "/usr/bin/clangd" ]; then
   sudo ln -fsn /usr/bin/clangd-7 /usr/bin/clangd
 fi
 if [ ! -e "/usr/bin/clang-format" ]; then
   sudo ln -fsn /usr/bin/clang-format-7 /usr/bin/clang-format
 fi
 if [ ! -e "/usr/bin/clang-tidy" ]; then
   sudo ln -fsn /usr/bin/clang-tidy-7 /usr/bin/clang-tidy
 fi

  printInfo "** Installing default .clang-format"
  backupConfiguration ~/.clang-format
  cp $DOTFILES/.clang-format ~

  printInfo "** Installing python-language-server"
  installPackage python-pip
  sudo -H pip install --upgrade python-language-server > /dev/null 2>&1
  printInfo "** Installing VIM plugins"
  vim +'PlugInstall --sync' +qa
  printInfo "** DONE"
}

installTmux() {
  printInfo "* Configuring tmux"
  backupConfiguration ~/.tmux.conf
  printInfo "** Adding new .tmux.conf"
  cp $DOTFILES/.tmux.conf ~/.tmux.conf
  installPackage tmux
  installPackage xsel
  printInfo "** Installing plugin manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm > /dev/null 2>&1
  printInfo "** Installing plugins"
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh > /dev/null 2>&1
  printInfo "** DONE"
}

installCcache() {
  printInfo "* Installing ccache and configuration"
  installPackage ccache
  mkdir -p ~/.ccache
  backupConfiguration ~/.ccache/ccache.conf
  printInfo "** Adding new .ccache/ccache.conf"
  cp $DOTFILES/.ccache/ccache.conf ~/.ccache/ccache.conf
  printInfo "** DONE"
}

installCppEnv() {
  printInfo "* Installing cpp development environment"
  installPackage gcc
  installPackage build-essential
  installPackage cmake
  installPackage doxygen
  installPackage graphviz
  installPackage python-pip
  installPackage ninja-build
  installPackage gdb
  installPackage subversion
  installPackage valgrind
  installPackage libboost-all-dev
  installPackage autotools-dev
  installPackage autoconf
  installPackage python-dev
  installPackage python3-dev

  # Install CPP lint and CPP clean
  sudo -H pip install -q --upgrade pip
  sudo -H pip install -q --upgrade cpplint
  sudo -H pip install -q --upgrade cppclean
  printInfo "** DONE"
}

installMisc() {
  printInfo "* Installing misc packages"
  installPackage curl
  installPackage ffmpeg
  installPackage htop
  installPackage unrar
  installPackage gparted

  # Chrome
  PKG_AV=$(sudo apt-cache search google-chrome-stable)
  if [ -z "$PKG_AV" ]; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get -qq update
  fi
  installPackage google-chrome-stable
  printInfo "** DONE"
}

installAll() {
  printInfo "Installing all packages"
  printInfo "----"
  installGit
  printInfo "----"
  installCppEnv
  printInfo "----"
  installCcache
  printInfo "----"
  installBash
  printInfo "----"
  installVim
  printInfo "----"
  installTmux
  printInfo "----"
  installMisc
  printInfo "Installation DONE"
  reloadBash
}

update
if [ "$INSTALL_TARGET" == "vim" ] ; then
  installVim
elif [ "$INSTALL_TARGET" == "bash" ] ; then
  installBash
elif [ "$INSTALL_TARGET" == "tmux" ] ; then
  installTmux
elif [ "$INSTALL_TARGET" == "cpp" ] ; then
  installCppEnv
elif [ "$INSTALL_TARGET" == "git" ] ; then
  installGit
elif [ "$INSTALL_TARGET" == "misc" ] ; then
  installMisc
elif [ "$INSTALL_TARGET" == "ccache" ] ; then
  installCcache
else
  installAll
fi
