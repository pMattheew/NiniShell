# Depends on: object-helper.ps1

function Initialize-Cli {

    $cli = [PSCustomObject]@{ closed = $false }
    
    Add-Method $cli "init" {
        $global:apps = $()

        Get-ChildItem "$(Get-Location)\components" | ForEach-Object {
            $component = Split-Path $_ -Leaf
            . "$_\$component-view.ps1"
        }
    }

    Add-Method $cli "show" {
        while (-not $cli.closed) {
            $choice = Read-Host "Welcome to NiniShell!"
            switch ($choice) {
                'C' { $cli.close() }
                Default {}
            }
        }
    }

    Add-Method $cli "close" { $cli.closed = $true }

    return $cli
}