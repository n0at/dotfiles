Param([String]$mode)

if (($mode -eq "i") -Or ($mode -eq "init")) {
    # envs
    [System.Environment]::SetEnvironmentVariable("GOPATH", $env:USERPROFILE, "User")
    [System.Environment]::SetEnvironmentVariable("PYTHONUSERBASE", "$env:USERPROFILE", "User")

    $https_proxy = [System.Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
    $http_proxy = [System.Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")

    # �v���L�V��ݒ�
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
        "neovim-nightly"
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

    # dotfiles�̎擾
    if (-Not (Test-Path ("$DOTFILES"))) {
        git config --global core.autoCRLF false
        git clone https://github.com/n0at/dotfiles.git $env:USERPROFILE\.dotfiles
    }

    # keyhac�̃C���X�g�[��
    if (-Not (Test-Path ("$env:USERPROFILE\bin\keyhac"))) {
        (New-Object Net.WebClient).DownloadFile("http://crftwr.github.io/keyhac/download/keyhac_182.zip", ".\keyhac.zip")
        unzip .\keyhac.zip -d $env:USERPROFILE\bin
        Remove-Item keyhac.zip
    }

    # �X�^�[�g�A�b�v��keyhac�̃V���[�g�J�b�g���쐬
    if (-Not (Test-Path ("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk"))) {
        $Shortcut = (New-Object -ComObject WScript.Shell).createshortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk")
        $Shortcut.TargetPath = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
        $Shortcut.IconLocation = "$env:USERPROFILE\bin\keyhac\keyhac.exe"
        $Shortcut.Save()
    }

    # �X�уS�V�b�N�̃_�E�����[�h
    if (-Not (Test-Path ("$env:USERPROFILE\font\sarasa-gothic"))) {
        Write-Output "Download sarasa-gothic.7z"
        (New-Object Net.WebClient).DownloadFile("https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.12.7/sarasa-gothic-ttc-0.12.7.7z", ".\sarasa-gothic.7z")
        7z x sarasa-gothic.7z -o"$env:USERPROFILE\font\sarasa-gothic"
        Remove-Item sarasa-gothic.7z
    }

    if (-Not (Test-Path ("$env:USERPROFILE\font\meslolgs"))) {
        mkdir $env:USERPROFILE\font\meslolgs
        (New-Object Net.WebClient).DownloadFile("https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf", "$env:USERPROFILE\font\meslolgs\Regular.ttf")
        (New-Object Net.WebClient).DownloadFile("https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf", "$env:USERPROFILE\font\meslolgs\Bold.ttf")
        (New-Object Net.WebClient).DownloadFile("https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf", "$env:USERPROFILE\font\meslolgs\Italic.ttf")
        (New-Object Net.WebClient).DownloadFile("https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf", "$env:USERPROFILE\font\meslolgs\Bold_Italic.ttf")
    }
    
    # Vscodes�̊g���@�\���C���X�g�[��
    Get-Content $env:USERPROFILE\.dotfiles\etc\os\windows\vscode\extensions | % { code --install-extension $_ }

} elseif (($mode -eq "d") -Or ($mode -eq "deploy")) {

    # �Ǘ��Ҍ����̂Ƃ��̂ݎ��s
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

        $WINDOTFILES = "$env:USERPROFILE\.dotfiles\etc\os\windows"

        # ------------------------------------------------------------
        # keyhac
        # ------------------------------------------------------------
        # �V���{���b�N�����N�����݂���΍폜����
        if ((Test-Path ("$env:USERPROFILE\bin\keyhac\config.py")) -And ((Get-Item ("$env:USERPROFILE\bin\keyhac\config.py")).Attributes.ToString() -match "ReparsePoint")) {
            echo "keyhac�̃V���{���b�N�����N���폜���܂�"
            Remove-Item $env:USERPROFILE\bin\keyhac\config.py
        }

        # �����̐ݒ�t�@�C��������΃o�b�N�A�b�v
        if (Test-Path ("$env:USERPROFILE\bin\keyhac\config.py")) {
            echo "keyhac�̐ݒ�t�@�C�����o�b�N�A�b�v���܂�"
            Move-Item $env:USERPROFILE\bin\keyhac\config.py $WINDOTFILES\keyhac\config.backup.py
        }

        # keyhac�̃V���{���b�N�����N���쐬
        New-Item -Type SymbolicLink $env:USERPROFILE\bin\keyhac\config.py -Value $WINDOTFILES\keyhac\config.py

        # ------------------------------------------------------------
        # Windows Terminal
        # ------------------------------------------------------------
        $WindowsTerminalPath = Get-ChildItem $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\
        echo $WindowsTerminalPath

        if ((Test-Path ("$WindowsTerminalPath\settings.json")) -And ((Get-Item ("$WindowsTerminalPath\settings.json")).Attributes.ToString() -match "ReparsePoint")) {
            echo "WindowsTerminal�̃V���{���b�N�����N���폜���܂�"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # �V�����ݒ�t�@�C���̌��t�@�C�����Ȃ��ꍇ
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json"))) {
            while (-Not (Test-Path ("$WindowsTerminalPath\settings.json"))) {
                Read-Host "WindowsTerminal���N�����Ă���Enter�������Ă�������"
            }

            echo "WindowsTerminal�̐ݒ�t�@�C�����o�b�N�A�b�v���܂�"
            Move-Item $WindowsTerminalPath\settings.json $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json
        } elseif (Test-Path ("$WindowsTerminalPath\settings.json")) {
            echo "�s�v��WindowsTerminal�̐ݒ�t�@�C�����폜���܂�"
            Remove-Item $WindowsTerminalPath\settings.json
        }

        # �V�����ݒ�t�@�C���𐶐�����
        if (-Not (Test-Path ("$WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json"))) {
            echo "WindowsTerminal�̐V�����ݒ�t�@�C���𐶐����܂�"
            $Profiles = (Get-Content $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.backup.json -Encoding UTF8 | Select-String "\s*//" -NotMatch | ConvertFrom-Json).profiles.list | ConvertTo-Json
            Get-Content $WINDOTFILES\WindowsTerminal\settings_base.json -Encoding UTF8 | % { $_ -replace """list"": \[\]", """list"": $Profiles" } | Out-File -Encoding utf8 $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json
        }

        # WindowsTerminal�̃V���{���b�N�����N�𐶐�����
        New-Item -Type SymbolicLink $WindowsTerminalPath\settings.json -Value $WINDOTFILES\WindowsTerminal\settings.$env:COMPUTERNAME.json

        # Vscode
        $VscodePath = "$env:USERPROFILE\AppData\Roaming\Code\User"

        # ���݂��Ă����ݒ�̓o�b�N�A�b�v����
        if ((Test-Path ("$VscodePath\settings.json")) -And (-Not ((Get-Item ("$VscodePath\settings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            Move-Item $VscodePath\settings.json $VscodePath\settings.backup.json
        }

        # ���݂��Ă����L�[�o�C���h�̓o�b�N�A�b�v����
        if ((Test-Path ("$VscodePath\keybindings.json")) -And (-Not ((Get-Item ("$VscodePath\keybindings.json")).Attributes.ToString() -match "ReparsePoint"))) {
            Move-Item $VscodePath\keybindings.json $VscodePath\keybindings.backup.json
        }

        if (-Not (Test-Path ("$VscodePath\settings.json"))) {
            New-Item -Type SymbolicLink $VscodePath\settings.json -Value $WINDOTFILES\vscode\settings.json
        }
        if (-Not (Test-Path ("$VscodePath\keybindings.json"))) {
            New-Item -Type SymbolicLink $VscodePath\keybindings.json -Value $WINDOTFILES\vscode\keybindings.json
        }

        # .wslconfig �����݂��Ȃ��ꍇ�̂ݔz�u
        if (-Not (Test-Path ("$env:USERPROFILE\.wslconfig"))) {
            New-Item -Type SymbolicLink $env:USERPROFILE\.wslconfig -Value $WINDOTFILES\.wslconfig
        }
    } else {
        echo "�Ǘ��Ҍ����Ŏ��s���Ă�������"
    }
}
