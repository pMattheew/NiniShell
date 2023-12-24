function IsAdminEnabled {
    $a = Get-LocalUser -Name "Administrator"
    return $a.Enabled
}

$username = "Administrator"
$password = ConvertTo-SecureString -String "a-strong-pswd" -AsPlainText -Force

function Set-Admin {
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