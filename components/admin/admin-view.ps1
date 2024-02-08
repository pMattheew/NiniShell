. "$(Get-Location)\components\admin\admin.ps1"

$global:apps += [PSCustomObject]@{
    title = "Activate administrator user"
    interface = { 
        if (Test-Admin) {
            $global:warn = "`nWARN: The administrator account is already enabled in this computer.`n"
            break
        }
        else { $global:warn = "" }

        $return = $false

        while (-not $return) {
            Clear-Host

            $confirm = Read-Host "
This option will activate the administrator user and
exclude all other local accounts.
$global:3err
Send C to continue.
Send B to go back.

"

            switch ($confirm) {
                'C' { Set-Admin }
                'B' { $return = $true }
            }
        }
        
    }
}