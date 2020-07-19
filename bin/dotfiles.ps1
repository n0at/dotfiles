Param([String]$mode)

if (($mode -eq "i") -Or ($mode -eq "init")) {
    # envs
    [System.Environment]::SetEnvironmentVariable("GOPATH", $env:USERPROFILE, "User")
    [System.Environment]::SetEnvironmentVariable("PYTHONUSERBASE", "$env:USERPROFILE", "User")

    $newPath = @(
        "$env:USERPROFILE\bin"
        "$env:USERPROFILE\.dotfiles\bin"
        "$env:USERPROFILE\scoop\shims"
        "$env:USERPROFILE\scoop\apps\python\current"
        "$env:USERPROFILE\scoop\apps\python\current\Scripts"
        "$env:USERPROFILE\scoop\apps\python27\current\scripts"
        "$env:USERPROFILE\scoop\apps\nodejs-lts\current\bin"
        "$env:USERPROFILE\scoop\apps\nodejs-lts\current"
        "$env:USERPROFILE\scoop\apps\ruby\current\gems\bin"
        "$env:USERPROFILE\scoop\apps\ruby\current\bin"
        "$env:USERPROFILE\scoop\apps\git\current\usr\bin"
        "$env:USERPROFILE\scoop\apps\git\current\mingw64\bin"
        "$env:USERPROFILE\scoop\apps\git\current\mingw64\libexec\git-core"
        "$env:USERPROFILE\AppData\Local\Programs\Python\Launcher"
        "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
    ) -join ";"

    $oldPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($oldPath -ne $newPath) {
    [System.Environment]::SetEnvironmentVariable("_PATH_" + (Get-Date -UFormat "%Y%m%d"), $oldPath, "User")
    }
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    $env:PATH = $newPath + ";" + $env:PATH

    [System.Environment]::SetEnvironmentVariable("WSLENV", "USERPROFILE:USERNAME", "User")

    $DOTFILES = "$env:USERPROFILE\.dotfiles"

    $ErrorActionPreference = "Stop"

    try {
        Get-Command -Name scoop -ErrorAction Stop
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Invoke-Expression (new-object net.webclient).downloadstring("https://get.scoop.sh")
    }

    $UTILS = @(
        "aria2"
        "lessmsi"
        "dark"
        "7zip"
        "git"
    )

    $PACKAGES = @(
        "bat"
        "fzf"
        "ghq"
        "go"
        "googlechrome"
        "msys2"
        "neovim"
        "nodejs-lts"
        "pwsh"
        "python"
        "ripgrep"
        "vscode"
        "powertoys"
        "android-studio"
        "jq"
    )

    scoop install $UTILS
    scoop bucket add versions
    scoop bucket add extras
    scoop bucket add java
    scoop update *
    scoop install $PACKAGES
    scoop install "python27"
    scoop reset "python"

    # python2
    $PIP2PACKAGES = @(
        "pip"
        "pynvim"
    )
    python2 -m pip install --upgrade $PIP2PACKAGES

    # python3
    $PIP3PACKAGES = @(
        "pip"
        "pynvim"
    )
    python -m pip install --upgrade $PIP3PACKAGES

    # dotfilesの取得
    if (-Not (Test-Path ("$DOTFILES"))) {
        git config --global core.autoCRLF false
        git clone https://github.com/n0at/dotfiles.git $env:USERPROFILE\.dotfiles
    }

    # keyhacのインストール
    if (-Not (Test-Path ("$env:USERPROFILE\bin\keyhac"))) {
        (New-Object Net.WebClient).DownloadFile("http://crftwr.github.io/keyhac/download/keyhac_182.zip", ".\keyhac.zip")
        unzip .\keyhac.zip -d $env:USERPROFILE\bin
        Remove-Item keyhac.zip
    }

    # スタートアップにkeyhacのショートカットを作成
    if (-Not (Test-Path ("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk"))) {
        $Shortcut = (New-Object -ComObject WScript.Shell).createshortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk")
        $Shortcut.TargetPath = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
        $Shortcut.IconLocation = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
        $Shortcut.Save()
    }

    # 更紗ゴシックのダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic"))) {
        Write-Output "Download sarasa-gothic.7z"
        (New-Object Net.WebClient).DownloadFile("https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.12.7/sarasa-gothic-ttc-0.12.7.7z", ".\sarasa-gothic.7z")
        7z x sarasa-gothic.7z -o"$env:USERPROFILE\font\sarasa-gothic"
        Remove-Item sarasa-gothic.7z
    }
    
    # Vscodesの拡張機能をインストール
    Get-Content $env:USERPROFILE\.dotfiles\etc\os\windows\vscode\extensions | % { code --install-extension $_ }

} elseif (($mode -eq "d") -Or ($mode -eq "deploy")) {

    $WINDOTFILES = "$env:USERPROFILE\.dotfiles\etc\os\windows"

    # keyhac
    if (-Not (Test-Path ("$env:USERPROFILE\bin\keyhac\config.py"))) {
        New-Item -Type SymbolicLink $env:USERPROFILE\bin\keyhac\config.py -Value $WINDOTFILES\keyhac\config.py
    } elseif (-Not ((Get-Item ("$env:USERPROFILE\bin\keyhac\config.py")).Attributes.ToString() -match "ReparsePoint")) {
        Copy-Item $env:USERPROFILE\bin\keyhac\config.py $env:USERPROFILE\bin\keyhac\config.py.bak
        Remove-Item $env:USERPROFILE\bin\keyhac\config.py
        New-Item -Type SymbolicLink $env:USERPROFILE\bin\keyhac\config.py -Value $WINDOTFILES\keyhac\config.py
    }

    # Windows Terminal
    $WindowsTerminalPath = Get-ChildItem $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\
    echo $WindowsTerminalPath
    if (-Not (Test-Path ("$WindowsTerminalPath\settings.json"))) {
        Copy-Item \settings_base.json $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
        New-Item -Type SymbolicLink $WindowsTerminalPath\settings.json -Value $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
    } elseif (-Not ((Get-Item ("$WindowsTerminalPath\settings.json")).Attributes.ToString() -match "ReparsePoint")) {
        $Profiles = (Get-Content $WindowsTerminalPath\settings.json | ConvertFrom-Json).profiles.list | ConvertTo-Json
        Get-Content $WINDOTFILES\WindowsTerminal\settings_base.json | % { $_ -replace """list"": \[\]", """list"": $Profiles" } > $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
        Remove-Item $WindowsTerminalPath\settings.json
        New-Item -Type SymbolicLink $WindowsTerminalPath\settings.json -Value $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
    }

    # Vscode
    $VscodePath = "$env:USERPROFILE\AppData\Roaming\Code\User"

    # 存在していた設定はバックアップする
    if ((Test-Path ("$VscodePath\settings.json")) -And (-Not ((Get-Item ("$VscodePath\settings.json")).Attributes.ToString() -match "ReparsePoint"))) {
        Move-Item $VscodePath\settings.json $VscodePath\settings.json.bak
    }

    # 存在していたキーバインドはバックアップする
    if ((Test-Path ("$VscodePath\keybindings.json")) -And (-Not ((Get-Item ("$VscodePath\keybindings.json")).Attributes.ToString() -match "ReparsePoint"))) {
        Move-Item $VscodePath\keybindings.json $VscodePath\keybindings.json.bak
    }

    if (-Not (Test-Path ("$VscodePath\settings.json"))) {
        New-Item -Type SymbolicLink $VscodePath\settings.json -Value $WINDOTFILES\vscode\settings.json
    }
    if (-Not (Test-Path ("$VscodePath\keybindings.json"))) {
        New-Item -Type SymbolicLink $VscodePath\keybindings.json -Value $WINDOTFILES\vscode\keybindings.json
    }
}
