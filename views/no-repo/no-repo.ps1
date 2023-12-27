$r = Read-Host "Insert your GitHub repository path`n"

Add-Content "$env:appdata\NiniShell\ninishell.cfg" "REPO=$r" 