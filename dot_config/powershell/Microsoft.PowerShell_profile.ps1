Invoke-Expression (&/opt/homebrew/bin/starship  init powershell)
Import-Module -Name Terminal-Icons
$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
$env:PATH = "$HOME/.local/bin:" + $env:PATH
$env:GOPATH = "$HOME/go"
Set-Alias cura cursor-agent
Set-Alias libgen ~/go/bin/libgen-cli
