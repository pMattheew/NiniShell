$domain = "your.domain"

function IsInDomain {
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    if ($cs.domain -eq $domain) { return $true } else { return $false }
}

function Enter-Domain {
    param(
        [bool]$restart = $false
    )
    
    $patrimony = Read-Host "
Write the machine's patrimony:    

"
    
    $params = @{
        DomainName  = $domain
        Credential  = Get-Credential
        Force       = $true
        NewName     = "N$($patrimony)"
        ErrorAction = "Stop"
    }

    try {
        if ($restart) { Add-Computer @params -Restart }
        else { Add-Computer @params }

        Write-Output "The '$($params.NewName)' computer now is part of '$domain'."
        if(-not $restart) { Write-Output "Restart the computer for it to take effect." }
        
        $global:4err = ""
    }
    catch {
        $global:4err = "`nERROR: There was an error trying to enter the domain: `n$_`n"
    }
}