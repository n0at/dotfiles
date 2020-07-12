# n0at's dotfiles

## Installation

### Windows

```powershell
Invoke-Command -ScriptBlock ([scriptblock]::Create((new-object net.webclient).downloadstring("https://raw.github.com/n0at/dotfiles/master/bin/dotfiles.ps1"))) -ArgumentList "init"
```

### Linux

```bash
dotfiles.sh
```