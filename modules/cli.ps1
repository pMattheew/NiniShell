# Depends on: object-helper.ps1

function Initialize-Cli {

    $cli = [PSCustomObject]@{ closed = $false }    

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