function Initialize-Applications {
    $apps = Get-GitHubFile -File "apps.json" | ConvertFrom-Json

    $apps = $apps.PSObject.Properties

    foreach ($app in $apps) {
        $appNames += , $app.Name
    }

    Set-InstallFunctions
}