#!/bin/bash

eval "ZSH_VERSION=$ZSH_VERSION"

# zshのインストール
if [ -z "$(command -v zsh)" -o "$(zsh --version | awk '{print $2}')" != "$ZSH_VERSION" ]; then
    sudo apt install -y wget tar make
    wget https://sourceforge.net/projects/zsh/files/zsh/$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz/download -O zsh-$ZSH_VERSION.tar.xz
    tar xvf zsh-$ZSH_VERSION.tar.xz -C ~/
    mv ~/zsh-$ZSH_VERSION ~/.zsh
    cd ~/.zsh
    ./configure --enable-multibyte
    make && sudo make install
fi

# zplugのインストール
if [ ! -d "$HOME/.zplug" ]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi