. "$(Get-Location)\components\applications\applications.ps1"

$global:apps += [PSCustomObject]@{
    option = "Install applications"
    interface = {
        Initialize-Applications
    
        $return = $false
    
        while (-not $return) {
            Clear-Host
    
            $select = Read-Host "
    Select the applications that you want to install from these options:
    $(Get-Installables -Enumerated $true)
    
    Send a valid array of numbers to continue.
    Send H for help.
    Send B to go back.
    
    "
            switch ($select) {
                'H' {
                    Clear-Host
    
                    Read-Host "
    To select the desired applications you must return a valid array
    separated by spaces. Like in the following example, these are the
    options of applications to be installed:
    
    1 - WinRAR
    2 - Chrome
    3 - Drive
    
    Then it is answered with this:
    
    : 1 3
    
    So only WinRAR and Drive are going to be installed.
    
    PS: It MUST be separated using spaces.
                    
    "
    
                    Clear-Host
                }
                'B' {
                    $return = $true
                }
                default { Select-Apps }
            }
        }
    }
}

