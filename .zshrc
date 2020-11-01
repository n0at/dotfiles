# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz add-zsh-hook
autoload -Uz compinit && compinit

# emacs風キーバインド
bindkey -e

# ディレクトリ名のみ指定で移動
setopt auto_cd

# ディレクトリ移動時に自動でpushdする
setopt auto_pushd

# すでにpushdしているディレクトリはpushdせずに無視する
setopt pushd_ignore_dups

# 同じ履歴が存在する場合は古いものから順に削除する
setopt hist_ignore_all_dups

# スペースから始まる入力は履歴に保存しない
setopt hist_ignore_space


zstyle ':completion:*:default' menu select=1
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# 2, 3階層上のディレクトリへの移動の簡易化
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --color=auto'

umask 022

# 環境変数を設定
export ZPLUG_HOME="$HOME/.zplug"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# lsコマンドに色をつける
export LSCOLORS=gxfxcxdxbxegedabagacad
# 履歴ファイルの保存先
export HISTFILE=$HOME/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# -------------------------------------------------------------------
# 関数
# -------------------------------------------------------------------

colortest() {
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}

fbr() {
    local branches branch
    branches=$(git branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

update_tmux() {
    if [ ! -z "$TMUX" ]; then
        tmux refresh-client -S
    fi
}
add-zsh-hook precmd update_tmux

# -------------------------------------------------------------------
# zplug
# -------------------------------------------------------------------

# zplugの読み込み
source $HOME/.zplug/init.zsh

# ハイライト
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# 補完
zplug "zsh-users/zsh-autosuggestions", defer:2

# テーマ
zplug romkatv/powerlevel10k, as:theme, depth:1

# 未インストール項目をインストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose

# fzfの読み込み
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet