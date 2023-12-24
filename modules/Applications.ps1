$global:initialized = $false

function Initialize-Applications {
    if(-not $global:initialized) {
        $global:apps = Get-GitHubFile -File "apps.json" | ConvertFrom-Json
    
        $global:apps = $apps.PSObject.Properties
    
        foreach ($app in $global:apps) {
            $global:appNames += , $app.Name
        }
    
        Set-InstallFunctions

        $global:initialized = $true
    }
}

$global:functions = {
    function Get-App {
        param(
            [string]$url,
            [string]$name
        )
    
        $dest = "$env:TEMP\$name"
    
        Start-BitsTransfer -Source $url -Destination $dest
    
        while ((Get-BitsTransfer | Where-Object { $_.Destination -eq $dest }).JobState -eq "Connecting") {
            Start-Sleep -Seconds 1
        }

        return $dest
    }

    function Install-App {
        param(
            [string]$path,
            [string]$arguments = "/S"
        )

        Start-Process -FilePath $path -ArgumentList $arguments -Wait
        Remove-Item -Path $path
    }
}

function Get-LifeCycleScript {
    param(
        [string] $cycle
    )
    if ($cycle -match ".*\.ps1$") {
        $script = Get-GitHubFile -File "scripts/$($cycle)"
        "`n $($script)"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($cycle)) {
        "`n $($cycle)"
    }
    else { "" }
}

function Set-InstallFunctions {
    foreach ($app in $global:apps) {

        # is msstore app
        if ($app.Value.id) {
            $body = "$(Get-LifeCycleScript -Cycle $app.Value.preinstall)winget install --id=$($app.Value.id) -s=msstore --accept-package-agreements --accept-source-agreements -h$(Get-LifeCycleScript -Cycle $app.Value.postinstall)"
        }
        else {
            # replaces empty string with "/S"
            $arguments = ($app.Value.arguments -replace "^$", "/S")

            $body = "
        `$path = Get-App -Url '$($app.Value.url)' -Name '$($app.Name).$($app.Value.extension)' $(Get-LifeCycleScript -Cycle $app.Value.preinstall)
        Install-App -Path `$path -Arguments $arguments $(Get-LifeCycleScript -Cycle $app.Value.postinstall)
    "
        }

        $global:functions = [scriptblock]::Create("$global:functions`nfunction Install-$($app.Name) {`n$body`n}")
    }
}

function Write-JobsFeedback {
    while ((Get-Job -State Running).Count -gt 0) {
        Clear-Host

        Get-Job | ForEach-Object {
            if ($_.State -eq 'Running') {
                Write-Host "$($_.Name) is still running"
            }
            else {
                Write-Host "$($_.Name) has completed"
            }
        }

        Start-Sleep -Seconds 5
    }

    Get-Job | Wait-Job

    Write-Host "All applications have been successfully installed."
}

function Install-Apps {
    param(
        [string[]]$namesList = $global:appNames
    )

    $selectedApps = $apps | Where-Object { $_.Name -in $namesList }

    foreach ($app in $selectedApps) {
        $functionCall = [scriptblock]::Create("Install-$($app.Name)")
        Start-Job -ScriptBlock $functionCall -InitializationScript $global:functions -Name "$($app.Name) installation"
    }

    Write-JobsFeedback
}

function Get-Installables {
    param(
        [bool]$enumerated = $false
    )

    $installables = ""

    $i = 0
    foreach ($name in $global:appNames) {
        if ($enumerated) {
            $i += 1
            $installables = "$installables `n $($i) - $($name)"
        }
        else {
            $installables = "$installables `n - $($name)"        
        }
    }

    return $installables
}

function Select-Apps {
    if ([string]::IsNullOrWhiteSpace($select)) { break }

    $selected = $select -Split ' '

    $namesList = $()

    foreach ($i in $selected) {
        try {
            $i = [convert]::ToInt32($i)
            $namesList += , $global:appNames[$i - 1]
        }
        catch {
            Write-Output "Cannot convert '$i' to an integer."
            Start-Sleep -Seconds 1
        }
    }

    Install-Apps -NamesList $namesList
}