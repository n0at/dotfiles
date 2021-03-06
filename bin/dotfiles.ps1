Param([String]$mode)

if (($mode -eq "i") -Or ($mode -eq "init")) {
    # envs
    [System.Environment]::SetEnvironmentVariable("GOPATH", $env:USERPROFILE, "User")
    [System.Environment]::SetEnvironmentVariable("PYTHONUSERBASE", "$env:USERPROFILE", "User")

    $https_proxy = [System.Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
    $http_proxy = [System.Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")

    # プロキシを設定
    if (-not [string]::IsNullOrEmpty($https_proxy)) {
        $proxy = New-Object System.Net.WebProxy $https_proxy, $True
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    } elseif (-not [string]::IsNullOrEmpty($http_proxy)) {
        $proxy = New-Object System.Net.WebProxy $http_proxy, $True
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    }

    $newPath = @(
        "$env:USERPROFILE\bin"
        "$env:USERPROFILE\.dotfiles\bin"
        "$env:USERPROFILE\.cargo\bin"
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

    # 設定済みのPATHの内容が$newPathと一致しない場合別名の環境変数として退避
    $oldPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($oldPath -ne $newPath) {
        [System.Environment]::SetEnvironmentVariable("_PATH_" + (Get-Date -UFormat "%Y%m%d"), $oldPath, "User")
    }
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    $env:PATH = $newPath + ";" + $env:PATH

    # WSLでUSERPROFILEを参照するために設定
    [System.Environment]::SetEnvironmentVariable("WSLENV", "USERPROFILE:USERNAME", "User")

    # Pythonの実行時にデフォルトの文字コードがcp932になるのを防ぐ
    [System.Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")

    # .dotfilesの配置ディレクトリを設定
    $DOTFILES = "$env:USERPROFILE\.dotfiles"

    $ErrorActionPreference = "Stop"

    try {
        Get-Command -Name scoop -ErrorAction $ErrorActionPreference 
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
        "rust"
)

    $PACKAGES = @(
        "bat"
        "fzf"
        "corretto11"
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

    # rust
    cargo install lsd navi hexyl bingrep tokei

    # dotfilesの取得
    if (-Not (Test-Path ("$DOTFILES"))) {
        git config --global core.autoCRLF false
        git clone https://github.com/n0at/dotfiles.git $DOTFILES
    }

    # posh-git、oh-my-poshのインストール
    $MAJOR_VERSION = (Get-Host).Version.Major
    Install-Module PSFzf -Scope CurrentUser -Force
    Install-Module posh-git -Scope CurrentUser -Force
    if ($MAJOR_VERSION -le 5) {
        Install-Module oh-my-posh -Scope CurrentUser -Force
    } else {
        Install-Module oh-my-posh -Scope CurrentUser -AllowPrerelease -Force
    }

    # 更紗ゴシックのダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic"))) {
        Write-Output "Download sarasa-gothic.7z"
        (New-Object Net.WebClient).DownloadFile("https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.31.0/sarasa-gothic-ttc-0.31.0.7z", ".\sarasa-gothic.7z")
        7z x .\sarasa-gothic.7z -o"$env:USERPROFILE\font\sarasa-gothic"
        Remove-Item sarasa-gothic.7z
    }

    # UniteTTCをダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\bin\unitettc"))) {
        (New-Object Net.WebClient).DownloadFile("http://yozvox.web.fc2.com/unitettc.zip", ".\unitettc.zip")
        unzip unitettc.zip -d $env:USERPROFILE\bin
        Move-Item $env:USERPROFILE\bin\unitettc\unitettc64.exe $env:USERPROFILE\bin
        Remove-Item unitettc.zip
    }

    # nerd-fontsのダウンロード
    if (-Not (Test-Path ("$env:USERPROFILE\.nerd-fonts"))) {
        git clone https://github.com/ryanoasis/nerd-fonts $env:USERPROFILE\.nerd-fonts
        # fontforge.cmdがfont-patcherをpythonスクリプトと認識しないためfont-patcher.pyにリネームする
        Move-Item $env:USERPROFILE\.nerd-fonts\font-patcher $env:USERPROFILE\.nerd-fonts\font-patcher.py
    }

    # 更紗等幅ゴシックJのみ抽出
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic-ttf"))) {
        mkdir $env:USERPROFILE\font\sarasa-gothic-ttf
        Get-ChildItem $env:USERPROFILE\font\sarasa-gothic\*.ttc | % { unitettc64.exe $_.FullName }
        Move-Item $env:USERPROFILE\font\sarasa-gothic\*017.ttf $env:USERPROFILE\font\sarasa-gothic-ttf
        Remove-Item $env:USERPROFILE\font\sarasa-gothic\*.ttf
    }

    # 更紗等幅ゴシックJにNerd fontsを合成したフォントを生成
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic-nerd"))) {
        Get-ChildItem $env:USERPROFILE\font\sarasa-gothic-ttf | % { fontforge.cmd -script $env:USERPROFILE\.nerd-fonts\font-patcher.py $_.FullName -ext ttf -w --fontlogos --fontawesome --powerline --powerlineextra -l -q -out $env:USERPROFILE\font\sarasa-gothic-nerd }
    }

    # Vscodesの拡張機能をインストール
    Get-Content $env:USERPROFILE\.dotfiles\etc\os\windows\vscode\extensions | % { code.cmd --install-extension $_ }

} elseif (($mode -eq "d") -Or ($mode -eq "deploy")) {

    # シンボリックリンクの作成には管理者権限が必要なので管理者権限のときのみ実行
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

        $WINDOTFILES = "$env:USERPROFILE\.dotfiles\etc\os\windows"

        # ------------------------------------------------------------
        # Windows Terminal
        # ------------------------------------------------------------
        $WindowsTerminalPath = Get-ChildItem $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal*_*\LocalState\
        echo $WindowsTerminalPath

        if ((Test-Path ("$WindowsTerminalPath\settings.json")) -And ((Get-Item ("$WindowsTerminalPath\settings.json")).Attributes.ToString() -match "ReparsePoint")) {
            echo "WindowsTerminal: rm settings.json (symbolic link)"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # 新しい設定ファイルの元ファイルがない場合
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.base.json"))) {
            while (-Not (Test-Path ("$WindowsTerminalPath\settings.json"))) {
                Read-Host "WindowsTerminal: Please start Windows Terminal"
            }

            echo "WindowsTerminal: mv settings.json settings.$env:COMPUTERNAME.base.json"
            Move-Item $WindowsTerminalPath\settings.json $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.base.json
        } elseif (Test-Path ("$WindowsTerminalPath\settings.json")) {
            echo "WindowsTerminal: rm settings.json"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # 新しい設定ファイルを生成する
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json"))) {
            echo "WindowsTerminal: create settings.$env:COMPUTERNAME.json"
            $Profiles = (Get-Content $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.base.json -Encoding UTF8 | Select-String "\s*//" -NotMatch | ConvertFrom-Json).profiles.list | ConvertTo-Json
            Get-Content $WINDOTFILES\WindowsTerminal\settings_base.json -Encoding UTF8 | % { $_ -replace """list"": \[\]", """list"": $Profiles" } | Out-File -Encoding utf8 $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
        }

        # WindowsTerminalのシンボリックリンクを生成する
        echo "WindowsTerminal: create settings.json (symbolic link)"
        New-Item -ItemType SymbolicLink -Path $WindowsTerminalPath -Name settings.json -Value $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json

        # ------------------------------------------------------------
        # VSCode
        # ------------------------------------------------------------
        $VscodePath = "$env:USERPROFILE\AppData\Roaming\Code\User"

        # 存在していた設定はバックアップする
        if ((Test-Path ("$VscodePath\settings.json")) -And (-Not ((Get-Item ("$VscodePath\settings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            echo "vscode: mv settings.json settings.backup.json"
            Move-Item $VscodePath\settings.json $VscodePath\settings.backup.json
        }

        # 存在していたキーバインドはバックアップする
        if ((Test-Path ("$VscodePath\keybindings.json")) -And (-Not ((Get-Item ("$VscodePath\keybindings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            echo "vscode: mv keybindings.json keybindings.backup.json"
            Move-Item $VscodePath\keybindings.json $VscodePath\keybindings.backup.json
        }

        if (-Not (Test-Path ("$VscodePath\settings.json"))) {
            echo "vscode: create settings.json (symbolic link)"
            New-Item -ItemType SymbolicLink -Path $VscodePath -Name settings.json -Value $WINDOTFILES\vscode\settings.json
        }
        if (-Not (Test-Path ("$VscodePath\keybindings.json"))) {
            echo "vscode: create keybindings.json (symbolic link)"
            New-Item -ItemType SymbolicLink -Path $VscodePath -Name keybindings.json -Value $WINDOTFILES\vscode\keybindings.json
        }

        # ------------------------------------------------------------
        # .wslconfig
        # ------------------------------------------------------------
        # .wslconfig が存在しない場合のみ配置
        if (-Not (Test-Path ("$env:USERPROFILE\.wslconfig"))) {
            echo "wsl: create .wslconfig (symbolic link)"
            New-Item -ItemType SymbolicLink -Path $env:USERPROFILE -Name .wslconfig -Value $WINDOTFILES\.wslconfig
        }

        # ------------------------------------------------------------
        # posh profile
        # ------------------------------------------------------------
        if (-Not (Test-Path ("$PROFILE"))) {
            echo "wsl: create Microsoft.PowerShell_profile.ps1 (symbolic link)"
            New-Item -ItemType SymbolicLink -Path $PROFILE -Value $WINDOTFILES\Microsoft.PowerShell_profile.ps1
        }
    } else {
        echo "Please run with administrator privileges"
    }
}
