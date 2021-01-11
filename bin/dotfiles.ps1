Param([String]$mode)

if (($mode -eq "i") -Or ($mode -eq "init")) {
    # envs
    [System.Environment]::SetEnvironmentVariable("GOPATH", $env:USERPROFILE, "User")
    [System.Environment]::SetEnvironmentVariable("PYTHONUSERBASE", "$env:USERPROFILE", "User")

    $https_proxy = [System.Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
    $http_proxy = [System.Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")

    # プロキシを設定
    if ([string]::IsNullOrEmpty($https_proxy)) {
        $proxy = New-Object System.Net.WebProxy $https_proxy, $True
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    } elseif ([string]::IsNullOrEmpty($http_proxy)) {
        $proxy = New-Object System.Net.WebProxy $http_proxy, $True
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    }

    $newPath = @(
        "$env:USERPROFILE\bin"
        "$env:USERPROFILE\.dotfiles\bin"
        "$env:USERPROFILE\scoop\shims"
        "$env:USERPROFILE\scoop\apps\python\current"
        "$env:USERPROFILE\scoop\apps\python\current\Scripts"
        "$env:USERPROFILE\scoop\apps\nodejs-lts\current\bin"
        "$env:USERPROFILE\scoop\apps\nodejs-lts\current"
        "$env:USERPROFILE\scoop\apps\ruby\current\gems\bin"
        "$env:USERPROFILE\scoop\apps\ruby\current\bin"
        "$env:USERPROFILE\scoop\apps\git\current\usr\bin"
        "$env:USERPROFILE\scoop\apps\git\current\mingw64\bin"
        "$env:USERPROFILE\scoop\apps\git\current\mingw64\libexec\git-core"
        "$env:USERPROFILE\scoop\apps\fontforge\current\bin"
        "$env:USERPROFILE\AppData\Local\Programs\Python\Launcher"
        "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
        "$env:USERPROFILE\.nerd-fonts"
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
        "python"
)

    $PACKAGES = @(
        "bat"
        "fzf"
        "ghq"
        "go"
        "googlechrome"
        "msys2"
        "neovim-nightly"
        "nodejs-lts"
        "pwsh"
        "ripgrep"
        "vscode"
        "powertoys"
        "jq"
        "fontforge"
    )

    scoop install $UTILS
    scoop bucket add versions
    scoop bucket add extras
    scoop bucket add java
    scoop update *
    scoop install $PACKAGES

    # python3
    $PIP3PACKAGES = @(
        "wheel"
        "pip"
        "pynvim"
    )
    python -m pip install --upgrade $PIP3PACKAGES

    # dotfilesの取得
    if (-Not (Test-Path ("$DOTFILES"))) {
        git config --global core.autoCRLF false
        git clone https://github.com/n0at/dotfiles.git $env:USERPROFILE\.dotfiles
    }

    # oh-my-poshのインストール
    Install-Module posh-git -Scope CurrentUser
    Install-Module oh-my-posh -Scope CurrentUser

    # keyhacのインストール
    if (-Not (Test-Path ("$env:USERPROFILE\bin\keyhac"))) {
        (New-Object Net.WebClient).DownloadFile("http://crftwr.github.io/keyhac/download/keyhac_182.zip", ".\keyhac.zip")
        unzip .\keyhac.zip -d $env:USERPROFILE\bin
        Remove-Item keyhac.zip
    }

    # スタートアップにkeyhacのショートカットを作成
    # if (-Not (Test-Path ("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk"))) {
    #     $Shortcut = (New-Object -ComObject WScript.Shell).createshortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk")
    #     $Shortcut.TargetPath = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
    #     $Shortcut.IconLocation = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
    #     $Shortcut.Save()
    # }

    # 更紗ゴシックのダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic"))) {
        Write-Output "Download sarasa-gothic.7z"
        (New-Object Net.WebClient).DownloadFile("https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.12.7/sarasa-gothic-ttc-0.12.7.7z", ".\sarasa-gothic.7z")
        7z x sarasa-gothic.7z -o"$env:USERPROFILE\font\sarasa-gothic"
        Remove-Item sarasa-gothic.7z
    }

    # nerd-fontsのダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\.nerd-fonts"))) {
        git clone https://github.com/ryanoasis/nerd-fonts $env:USERPROFILE\.nerd-fonts
    }

    # UniteTTCをダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\bin\unitettc"))) {
        (New-Object Net.WebClient).DownloadFile("http://yozvox.web.fc2.com/unitettc.zip", ".\unitettc.zip")
        unzip unitettc.zip -d $env:USERPROFILE\bin
        Move-Item $env:USERPROFILE\bin\unitettc\unitettc64.exe $env:USERPROFILE\bin
        Remove-Item unitettc.zip
    }

    # 更紗等幅ゴシックJのみ抽出
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic-ttf"))) {
        mkdir $env:USERPROFILE\font\sarasa-gothic-ttf
        ls $env:USERPROFILE\font\sarasa-gothic\*.ttc | % { unitettc64.exe $_.FullName }
        Move-Item $env:USERPROFILE\font\sarasa-gothic\*017.ttf $env:USERPROFILE\font\sarasa-gothic-ttf
        Remove-Item $env:USERPROFILE\font\sarasa-gothic\*.ttf
    }

    # 更紗等幅ゴシックJにNerd fontsを合成したフォントを生成
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic-nerd"))) {
        ls $env:USERPROFILE\font\sarasa-gothic-ttf | % { fontforge.exe -script font-patcher $_.FullName -ext ttf -w --fontlogos --fontawesome --powerline --powerlineextra -l --careful -q -out $env:USERPROFILE\font\sarasa-gothic-nerd }
    }
    
    # Vscodesの拡張機能をインストール
    Get-Content $env:USERPROFILE\.dotfiles\etc\os\windows\vscode\extensions | % { code --install-extension $_ }

} elseif (($mode -eq "d") -Or ($mode -eq "deploy")) {

    # 管理者権限のときのみ実行
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

        $WINDOTFILES = "$env:USERPROFILE\.dotfiles\etc\os\windows"

        # ------------------------------------------------------------
        # keyhac
        # ------------------------------------------------------------
        # シンボリックリンクが存在すれば削除する
        if ((Test-Path ("$env:USERPROFILE\bin\keyhac\config.py")) -And ((Get-Item ("$env:USERPROFILE\bin\keyhac\config.py")).Attributes.ToString() -match "ReparsePoint")) {
            echo "keyhacのシンボリックリンクを削除します"
            Remove-Item $env:USERPROFILE\bin\keyhac\config.py
        }

        # 既存の設定ファイルがあればバックアップ
        if (Test-Path ("$env:USERPROFILE\bin\keyhac\config.py")) {
            echo "keyhacの設定ファイルをバックアップします"
            Move-Item $env:USERPROFILE\bin\keyhac\config.py $WINDOTFILES\keyhac\config.backup.py
        }

        # keyhacのシンボリックリンクを作成
        New-Item -Type SymbolicLink $env:USERPROFILE\bin\keyhac\config.py -Value $WINDOTFILES\keyhac\config.py

        # ------------------------------------------------------------
        # Windows Terminal
        # ------------------------------------------------------------
        $WindowsTerminalPath = Get-ChildItem $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\
        echo $WindowsTerminalPath

        if ((Test-Path ("$WindowsTerminalPath\settings.json")) -And ((Get-Item ("$WindowsTerminalPath\settings.json")).Attributes.ToString() -match "ReparsePoint")) {
            echo "WindowsTerminalのシンボリックリンクを削除します"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # 新しい設定ファイルの元ファイルがない場合
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json"))) {
            while (-Not (Test-Path ("$WindowsTerminalPath\settings.json"))) {
                Read-Host "WindowsTerminalを起動してからEnterを押してください"
            }

            echo "WindowsTerminalの設定ファイルをバックアップします"
            Move-Item $WindowsTerminalPath\settings.json $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json
        } elseif (Test-Path ("$WindowsTerminalPath\settings.json")) {
            echo "不要なWindowsTerminalの設定ファイルを削除します"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # 新しい設定ファイルを生成する
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json"))) {
            echo "WindowsTerminalの新しい設定ファイルを生成します"
            $Profiles = (Get-Content $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json -Encoding UTF8 | Select-String "\s*//" -NotMatch | ConvertFrom-Json).profiles.list | ConvertTo-Json
            Get-Content $WINDOTFILES\WindowsTerminal\settings_base.json -Encoding UTF8 | % { $_ -replace """list"": \[\]", """list"": $Profiles" } | Out-File -Encoding utf8 $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
        }

        # WindowsTerminalのシンボリックリンクを生成する
        New-Item -Type SymbolicLink $WindowsTerminalPath\settings.json -Value $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json

        # ------------------------------------------------------------
        # VSCode
        # ------------------------------------------------------------
        $VscodePath = "$env:USERPROFILE\AppData\Roaming\Code\User"

        # 存在していた設定はバックアップする
        if ((Test-Path ("$VscodePath\settings.json")) -And (-Not ((Get-Item ("$VscodePath\settings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            Move-Item $VscodePath\settings.json $VscodePath\settings.backup.json
        }

        # 存在していたキーバインドはバックアップする
        if ((Test-Path ("$VscodePath\keybindings.json")) -And (-Not ((Get-Item ("$VscodePath\keybindings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            Move-Item $VscodePath\keybindings.json $VscodePath\keybindings.backup.json
        }

        if (-Not (Test-Path ("$VscodePath\settings.json"))) {
            echo "settings.jsonのシンボリックリンクを生成します"
            New-Item -Type SymbolicLink $VscodePath\settings.json -Value $WINDOTFILES\vscode\settings.json
        }
        if (-Not (Test-Path ("$VscodePath\keybindings.json"))) {
            echo "keybindings.jsonのシンボリックリンクを生成します"
            New-Item -Type SymbolicLink $VscodePath\keybindings.json -Value $WINDOTFILES\vscode\keybindings.json
        }

        # ------------------------------------------------------------
        # .wslconfig
        # ------------------------------------------------------------
        # .wslconfig が存在しない場合のみ配置
        if (-Not (Test-Path ("$env:USERPROFILE\.wslconfig"))) {
            echo ".wslconfigのシンボリックリンクを生成します"
            New-Item -Type SymbolicLink $env:USERPROFILE\.wslconfig -Value $WINDOTFILES\.wslconfig
        }

        # ------------------------------------------------------------
        # posh profile
        # ------------------------------------------------------------
        if (-Not (Test-Path ("$PROFILE"))) {
            echo "Microsoft.PowerShell_profile.ps1のシンボリックリンクを生成します"
            New-Item -Type SymbolicLink $PROFILE -Value $WINDOTFILES\Microsoft.PowerShell_profile.ps1
        }
    } else {
        echo "管理者権限で実行してください"
    }
}
