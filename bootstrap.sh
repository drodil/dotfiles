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

printInfo() {
    printf "\033[00;34m$@\033[0m\n"
}

update() {
    printInfo "Updating repository"
    git pull origin master > /dev/null 2>&1
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
    sudo apt-get -qq install -y fortune-mod
    printInfo "** Adding new .bashrc"
    cp .bashrc ~/.bashrc
    printInfo "** DONE"
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
    cp .vimrc ~/.vimrc

    VIMVERSION=$(vim --version | head -1 | cut -d ' ' -f 5)
    if [ ! $(echo "$VIMVERSION >= 8.0" | bc -l) ]; then
        printInfo "** Installing VIM version 8+"
        sudo add-apt-repository -y ppa:jonathonf/vim > /dev/null 2>&1
        sudo apt-get -qq update
        sudo apt-get -qq install -y vim
    fi


    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' clang-tools-7|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        sudo wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
        sudo add-apt-repository -y "deb http://apt.llvm.org/$(lsb_release -s -c)/ llvm-toolchain-$(lsb_release -s -c)-7.0 main" > /dev/null 2>&1
        sudo apt-get -qq update
  	    sudo apt-get install -y clang-tools-7
        sudo ln -fsn /usr/bin/clangd-7 /usr/bin/clangd
    fi

    printInfo "** Installing python-language-server"
    sudo apt-get -qq install -y python-pip
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
    sudo apt-get -qq install -y tmux
    printInfo "** DONE"
}

installAll() {
    printInfo "Installing all packages"
    printInfo "----"
    installBash
    printInfo "----"
    installGit
    printInfo "----"
    installTmux
    printInfo "Installation DONE"
    read -n 1 -s -r -p "Press any key to continue"
    source ~/.bashrc
}

update
if [ "$INSTALL_TARGET" == "vim" ] ; then
    installVim
elif [ "$INSTALL_TARGET" == "bash" ] ; then
    installBash
elif [ "INSTALL_TARGET" == "tmux"] ; then
    installTmux
else
    installAll
fi
