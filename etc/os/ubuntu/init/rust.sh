#!/bin/bash

curl https://sh.rustup.rs -sSf | sh

if [ ! -z "$(command -v fish)" -a -z "$(fish -c 'echo $fish_user_paths' | grep .cargo)" ]; then
    fish -c 'set -Ux fish_user_paths $HOME/.cargo/bin $fish_user_paths'
fi