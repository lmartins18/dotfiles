Invoke-Expression (&/opt/homebrew/bin/starship  init powershell)
Import-Module -Name Terminal-Icons
$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
$env:PATH = "$HOME/.local/bin:" + $env:PATH
Set-Alias cura cursor-agent
