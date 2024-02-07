# Depends on: object-helper.ps1

function Initialize-Config {
    $config = [PSCustomObject]@{
        ROOT = "$env:appdata\NiniShell"
        PATH = "$env:appdata\NiniShell\ninishell.cfg"
    }
    
    Add-Method $config "init" {
        try {
            if (-not (Test-Path $config.ROOT)) {
                New-Item $config.ROOT -ItemType Directory > $null
            }   
        }
        catch { throw "config.init(): It wasn't possible to create root NiniShell folders.`nError message:`n$_" }
    } 

    Add-Method $config "reset" { Remove-Item $config.PATH }

    Add-Method $config "append" {
        param(
            [string] $key,
            [string] $value
        )
        Add-Content $config.PATH "$key=$value"
        if (-not $config.$key) {
            Add-Property $config $key $value
        }
    }

    Add-Method $config "get" {
        Get-Content $config.PATH | ForEach-Object {
            $key, $value = $_ -split '='
            if (-not [string]::IsNullOrWhiteSpace($value)) { 
                Add-Property $config $key $value
            }
        }
        return $config
    }

    $config.init()

    return $config.get()
}
