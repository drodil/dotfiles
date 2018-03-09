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
esac
shift # past argument or value
done

function show_help {
    echo "By default all dotfiles are installed."
    echo "Supported parameters are:"
    echo "-v|--vim             Install vim configuration"
    echo "-b|--bash            Install bash configuration"
    echo "-t|--tmux            Install tmux configuration"
}

if [ -n "$HELP" ]; then
    show_help
    exit
fi

installPackage() {
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
  if [ "" == "$PKG_OK" ]; then
    echo "--- Installing $1"
    sudo apt-get -qq install -y $1
  fi
}

printInfo() {
    printf "\e[38;5;82m$@\e[0m\n"
}

update() {
    printInfo "Updating repository"
    git pull origin master > /dev/null 2>&1
}

reloadBash() {
   read -n 1 -s -r -p "Press any key to reload bash"
   source ~/.bashrc
}

installBash() {
   printInfo "* Configuring bash"
    if [ -e ~/.bashrc ]; then
        if [ -e ~/.bashrc.dotfiles.bak ]; then
            printInfo "** Restoring previous backup from .bashrc.dotfiles.bak"
            mv ~/.bashrc.dotfiles.bak ~/.bashrc
        fi
        printInfo "** Moving original .bashrc to .bashrc.dotfiles.bak"
        mv ~/.bashrc ~/.bashrc.dotfiles.bak
    fi
    printInfo "** Installing fortune"
    installPackage fortune-mod
    printInfo "** Adding new .bashrc"
    cp .bashrc ~/.bashrc
    printInfo "** DONE"
    if [ "$INSTALL_TARGET" == "bash" ] ; then
      reloadBash
    fi
}

installVim() {
    printInfo "* Configuring VIM"
    if [ -e ~/.vimrc ]; then
        if [ -e ~/.vimrc.dotfiles.bak ]; then
            printInfo "** Restoring previous backup from .vimrc.dotfiles.bak"
            mv ~/.vimrc.dotfiles.bak ~/.vimrc
        fi
        printInfo "** Moving original .vimrc to .vimrc.dotfiles.bak"
        mv ~/.vimrc ~/.vimrc.dotfiles.bak
    fi
    printInfo "** Adding new .vimrc"
    mkdir -p .vim
    mkdir -p .vim/tags

    cp .vimrc ~/.vim/vimrc
    ln -s ~/.vim/vimrc ~/.vimrc
    cp .vim/tags/cpp ~/.vim/tags/
    cp .vim/tags/generate_tags.sh ~/.vim/tags/

    VIMVERSION=$(vim --version | head -1 | cut -d ' ' -f 5)
    if [ ! $(echo "$VIMVERSION >= 8.0" | bc -l) ]; then
        printInfo "** Installing VIM version 8+"
        sudo add-apt-repository -y ppa:jonathonf/vim > /dev/null 2>&1
        sudo apt-get -qq update
        installPackage vim
    fi

    printInfo "** Installing clang packages"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' clang-tools-7|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        sudo wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
        sudo add-apt-repository -y "deb http://apt.llvm.org/$(lsb_release -s -c)/ llvm-toolchain-$(lsb_release -s -c) main" > /dev/null 2>&1
        sudo apt-get -qq update
        installPackage clang-tools-7
        sudo ln -fsn /usr/bin/clangd-7 /usr/bin/clangd
    fi
    installPackage clang-format-7
    sudo ln -fsn /usr/bin/clang-format-7 /usr/bin/clang-format

    installPackage clang-tidy-7
    sudo ln -fsn /usr/bin/clang-tidy-7 /usr/bin/clang-tidy

    printInfo "** Installing python-language-server"
    installPackage python-pip
    sudo -H pip install --upgrade python-language-server > /dev/null 2>&1
    printInfo "** Installing VIM plugins"
    vim +PlugInstall +qall
    printInfo "** DONE"
}

installTmux() {
    printInfo "* Configuring tmux"
    if [ -e ~/.tmux.conf ]; then
        if [ -e ~/.tmux.conf.dotfiles.bak ]; then
            printInfo "** Restoring previous backup from .tmux.conf.dotfiles.bak"
            mv ~/.tmux.conf.dotfiles.bak ~/.tmux.conf
        fi
        printInfo "** Moving original .tmux.conf to .tmux.conf.dotfiles.bak"
        mv ~/.tmux.conf ~/.tmux.conf.dotfiles.bak
    fi
    printInfo "** Adding new .tmux.conf"
    cp .tmux.conf ~/.tmux.conf
    printInfo "** Installing tmux"
    installPackage tmux
    printInfo "** DONE"
}

installAll() {
    printInfo "Installing all packages"
    printInfo "----"
    installBash
    printInfo "----"
    installVim
    printInfo "----"
    installTmux
    printInfo "Installation DONE"
    reloadBash
}

installPackage git
update
if [ "$INSTALL_TARGET" == "vim" ] ; then
    installVim
elif [ "$INSTALL_TARGET" == "bash" ] ; then
    installBash
elif [ "$INSTALL_TARGET" == "tmux" ] ; then
    installTmux
else
    installAll
fi
