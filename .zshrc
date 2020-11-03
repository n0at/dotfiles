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
# deleteキーを有効化
bindkey "^[[3~" delete-char

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
# export ZPLUG_HOME="$HOME/.zplug"
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
# pyenv
# -------------------------------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

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

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# cw - change worktree
cw() {
    # カレントディレクトリがGitリポジトリ上かどうか
    git rev-parse &>/dev/null
    if [ $? -ne 0 ]; then
        echo fatal: Not a git repository.
        return
    fi

    local selectedWorkTreeDir=`git worktree list | fzf | awk '{print $1}'`

    if [ "$selectedWorkTreeDir" = "" ]; then
        # Ctrl-C.
        return
    fi

    cd ${selectedWorkTreeDir}
}

fadd() {
    local out q n addfiles
    while out=$(
        git status --short |
        awk '{if (substr($0,2,1) !~ / /) print $2}' |
        fzf-tmux --multi --exit-0 --expect=ctrl-d); do
        q=$(head -1 <<< "$out")
        n=$[$(wc -l <<< "$out") - 1]
        addfiles=(`echo $(tail "-$n" <<< "$out")`)
        [[ -z "$addfiles" ]] && continue
        if [ "$q" = ctrl-d ]; then
            git diff --color=always $addfiles | less -R
        else
            git add $addfiles
        fi
    done
}

fzf-z-search() {
    local res=$(z | cut -c 12- | sort -rn | uniq | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}

ta() {
    if [ -z "$(command -v fzf)" ]; then
        echo "fzf not found"
        return
    fi

    if [[ -z $TMUX && $- == *l* ]]; then
        new_session="Create New Session"
        session_id=$(echo -e "$new_session\n$(tmux list-sessions 2>/dev/null)" | fzf | cut -d: -f1)

        if [ "$session_id" = "$new_session" ]; then
            tmux new-session
        elif [ -n "$session_id" ]; then
            tmux attach-session -t "$session_id"
        fi
    fi
}

update_tmux() {
    if [ -n "$TMUX" ]; then
        tmux refresh-client -S
    fi
}
add-zsh-hook precmd update_tmux

zle -N fzf-z-search
bindkey '^f' fzf-z-search

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
# zinit light zdharma/fast-syntax-highlighting # このプラグインを使用するとpromptのtruecolorが効かなくなる
zinit light rupa/z
zinit load zdharma/history-search-multi-word
zinit load romkatv/powerlevel10k

# fzfの読み込み
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# typeset -g POWERLEVEL9K_DIR_BACKGROUND='#047681'
typeset -g POWERLEVEL9K_DIR_BACKGROUND='#243a47'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#e7e8e9'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#e7e8e9'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#e7e8e9'

typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND='#243a47'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=2
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND='#243a47'

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='#f7df68'

typeset -g POWERLEVEL9K_TIME_BACKGROUND='#ffffff'

typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND='#00e8c6'
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='#eaa64d'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=2
typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=3
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8