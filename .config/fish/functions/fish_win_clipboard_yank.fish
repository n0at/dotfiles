function fish_win_clipboard_yank
    # Copy the current selection, or the entire commandline if that is empty.
    
    set -l cmdline (commandline --current-selection)
    test -n "$cmdline"; or set cmdline (commandline)
    if type -q win32yank.exe
        printf '%s' $cmdline | win32yank.exe -i
    end
end