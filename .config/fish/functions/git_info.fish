
function git_info
    set -l current_dir $argv

    set -l git_info
    set -l git_toplevel (command git -C $argv rev-parse --show-toplevel 2>/dev/null)
    if [ "$git_toplevel" ]
        set -l ref (command git -C $argv symbolic-ref --short HEAD 2>/dev/null)
        set -l tag (command git -C $argv describe --tags --exact-match 2>/dev/null)
        set -l branch (command git -C $argv show-ref --head -s --abbrev 2>/dev/null | head -n1 2>/dev/null)
        set OLDIDF $IFS
        set IFS ""
        set -l git_status (git -C $argv status --branch --porcelain 2>/dev/null)
        set IFS $OLDIDF

        set -l git_relative_path
        if [ "$git_toplevel" != "$current_dir" ]
            set git_relative_path (string replace "$git_toplevel/" "" "$current_dir")
        end
        set current_dir (basename $git_toplevel)

        set -l location
        if [ "$ref" ]
            set location $ref
        else if [ "$tag" ]
            set location $tag
        else if [ "$branch" ]
            set location $branch
        end

        set git_info "#[bg=#363a43,fg=colour255] $location"
        set -l num_ahead 0
        set -l num_behind 0
        for line in ( command git -C $argv rev-list --left-right '@{upstream}...HEAD' 2>/dev/null)
            set -l ahead (string match '>*' "$line")
            set -l behind (string match '<*' "$line")
            if [ "$ahead" ]
                set num_ahead (math $num_ahead + 1 )
            else if [ "$behind" ]
                set num_behind (math $num_behind + 1 )
            end
        end

        set -l symbol_clean "#[fg=green,bg=#363a43] ✔"
        set -l symbol_ahead "#[fg=green,bg=#363a43]⇡ "
        set -l symbol_behind "#[fg=green,bg=#363a43]⇣ "
        set -l symbol_merging "#[fg=magenta,bg=#363a43]⚡︎"
        set -l symbol_modified "#[fg=yellow,bg=#363a43]*"
        set -l symbol_staged "#[fg=yellow,bg=#363a43]+"
        set -l symbol_untracked "#[fg=yellow,bg=#363a43]~"

        set -l flags
        set -l is_modified (echo -e "$git_status" | grep -E '^[ MARC]M')
        set -l is_staged (echo -e "$git_status" | grep -E '^[MARC]')
        set -l is_untracked (echo -e "$git_status" | grep -E '^\?')
        if [ "$is_modified" ]
            set flags "$flags$symbol_modified"
        end

        if [ "$is_staged" ]
            set flags "$flags$symbol_staged"
        end

        if [ "$is_untracked" ]
            set flags "$flags$symbol_untracked"
        end

        if [ $num_ahead -gt 0 ]
            set flags "$flags $symbol_ahead$num_ahead"
        end

        if [ $num_behind -gt 0 ]
            set flags "$flags $symbol_behind$num_behind"
        end

        if [ -z "$flags" ]
            set flags $symbol_clean
        end

        set git_info "#[fg=#262a33,bg=#363a43] $git_info$flags #[bg=#262a33,fg=#363a43]"
        if [ "$git_relative_path" ]
            set git_info "$git_info#[fg=#262a33,bg=#363a43]#[fg=colour255,bg=#363a43] $git_relative_path #[bg=#262a33,fg=#363a43]"
        end
    end

    echo "#[fg=colour32,bg=#262a33]#[fg=colour255,bg=colour32] #{pane_pid} #[fg=colour32,bg=#262a33]#[fg=#262a33,bg=#363a43]#[fg=colour255,bg=#363a43] #(whoami) #[bg=#262a33,fg=#363a43]#[fg=#262a33,bg=#363a43]#[fg=colour255,bg=#363a43] $current_dir #[bg=#262a33,fg=#363a43]$git_info#[fg=#262a33,bg=colour32]#[bg=#262a33,fg=colour32]#[default]"
end