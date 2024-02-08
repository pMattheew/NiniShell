<# Checks if Administrator account is enabled. #>
function Test-Admin {
    $a = Get-LocalUser -Name "Administrator"
    return $a.Enabled
}

function Set-Admin { 
    $username = "Administrator"
    $password = Read-Host "Write the desired password:`n"
    $password = ConvertTo-SecureString -String $password -AsPlainText -Force

    try {
        $a = Get-LocalUser -Name $username

        if ($null -eq $a) {
            $a = New-LocalUser -Name $username -Password $password -FullName $username -Description "Administrator account"
        }
        else {
            Enable-LocalUser -Name $username
            Set-LocalUser -Name $username -Password $password
        }

        Remove-NotDefaultAccounts
    }
    catch {
        $global:3err = "`nAn error occurred while trying to set the administrator account:`n$_`n"
    }
}

function Remove-NotDefaultAccounts {
    try {
        $defaultAccounts = $("Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount")
        Get-LocalUser | Where-Object { $_.Name -notin $defaultAccounts } | Remove-LocalUser
        $global:3err = ""
    }
    catch {
        $global:3err = "`nAn error occurred while trying to remove default accounts:`n$_`n"
    }
}