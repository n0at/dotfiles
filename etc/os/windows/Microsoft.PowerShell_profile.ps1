# Windows Terminalで起動した時のみ適用する
if ($env:WT_PROFILE_ID) {
    Import-Module posh-git
    Import-Module oh-my-posh
    Set-PoshPrompt -Theme aliens
}

# キーバインドをEmacs風に変更
Set-PSReadlineOption -EditMode Emacs

# インストールしたコマンドのエイリアスを設定
Set-Alias ls lsd
Set-Alias cat bat

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'