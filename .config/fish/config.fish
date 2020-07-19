
set -g theme_color_scheme dracula
set -g theme_newline_cursor yes
set -g theme_newline_prompt '$ '
set -g theme_project_dir_length 0

set -g fish_prompt_pwd_dir_length 0

set -U FZF_LEGACY_KEYBINDINGS 0

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

if test -z $TMUX && status --is-login
    attach_tmux_session_if_needed
end

# function my_preexec --on-event fish_preexec
#   echo "preexec: $argv[1]"
# end

#function my_postexec --on-event fish_postexec
#    if test -z $TMUX
#        tmux refresh-client -S
#    end
#end

if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

alias ssh="TERM=xterm /usr/bin/ssh"

source ~/.config/fish/proxy.fish

umask 022
# set -gx DOCKER_HOST tcp://localhost:2375
# set_proxy
