
set -g theme_color_scheme dracula
set -g theme_project_dir_length 0
set -g theme_newline_cursor yes
set -g theme_newline_prompt '$ '
set -g theme_date_timezone "Asia/Tokyo"

set -U FZF_LEGACY_KEYBINDINGS 0

function fish_right_prompt; end

function attach_tmux_session_if_needed
    set new_session "Create New Session"
    set ID (string join \n $new_session (tmux list-sessions) | fzf | cut -d: -f1)
    if test "$ID" = "$new_session"
        tmux new-session
    else if test -n "$ID"
        tmux attach-session -t "$ID"
    end
end

function ta
    attach_tmux_session_if_needed
end

function fssh -d "Fuzzy-find ssh host via ag and ssh into it"
    grep --ignore-case '^host [^*]' ~/.ssh/config 2>/dev/null | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
end
# キーバインドをvi, emacs混合に設定
function hybrid_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
end
set -g fish_key_bindings hybrid_bindings

# vi modeでクリップボードに内容をコピー
# bind -M visual -m default y 'fish_win_clipboard_yank; commandline -f kill-selection yank end-selection repaint-mode'
# bind yy 'commandline -f beginning-of-line begin-selection end-of-line; fish_win_clipboard_yank; commandline -f kill-whole-line yank end-selection repaint-mode'
# bind Y 'commandline -f beginning-of-line begin-selection end-of-line; fish_win_clipboard_yank; commandline -f kill-whole-line yank end-selection repaint-mode'
# bind dd 'commandline -f beginning-of-line begin-selection end-of-line; fish_win_clipboard_yank; commandline -f kill-whole-line end-selection repaint-mode'

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

umask 022

if test -z $TMUX && status --is-login
    attach_tmux_session_if_needed
end

# tmuxか否かでプロンプトを変更する
if test -z $TMUX
    set -g theme_display_git yes
    set -g fish_prompt_pwd_dir_length 0
    # set -g theme_display_vi yes
else
    set -g theme_display_git no
    set -g fish_prompt_pwd_dir_length 1
    # set -g theme_display_vi no

    # TMUX起動時にはコピーモード用のキーバインドを設定
    bind -M default c 'tmux copy-mode'
    bind -M default -m insert p 'win32yank.exe -o | tmux load-buffer - && tmux paste-buffer; commandline -f repaint-mode;'
end

if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

alias ssh="TERM=xterm /usr/bin/ssh"
