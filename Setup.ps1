$ProgressPreference = 'SilentlyContinue'

<#
.SYNOPSIS
This function retrieves a file from soumasp/scripts repository.

.DESCRIPTION
The function first constructs the URL for the file in the specified GitHub 
repository. It then makes a GET request to this URL using a bearer token 
for authorization. The function returns the content of the file.

.PARAMETER File
The name of the file to retrieve from the GitHub repository.

.EXAMPLE
PS C:\> Get-GitHubFile -File "MyScript.ps1"

This command retrieves the "MyScript.ps1" file from the GitHub repository.
#>
function Get-GitHubFile {
    param(
        [string]$file
    )

    $token = "your-gh-token"

    $headers = @{
        'Accept'               = 'application/json'
        'Authorization'        = "Bearer $token"
        'X-GitHub-Api-Version' = '2022-11-28'
    }

    $src = "https://api.github.com/repos/soumasp/scripts/contents/$file"

    $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $src | ConvertFrom-Json

    Invoke-WebRequest -UseBasicParsing -Uri $response.download_url
}

Get-GitHubFile -File "modules/Applications.ps1" | Invoke-Expression
Get-GitHubFile -File "modules/Admin.ps1" | Invoke-Expression
Get-GitHubFile -File "modules/Domain.ps1" | Invoke-Expression

$exit = $false

while (-not $exit) {
    Clear-Host

    $choice = Read-Host "
    
Please choose an option: 

1. Install all applications
2. Select applications to install
3. Activate administrator 
4. Rename computer and add to domain
$global:warn
Send Q to quit the program.

"

    switch ($choice) {
        '1' {
            Initialize-Applications

            $return = $false

            while (-not $return) {
                Clear-Host

                $confirm = Read-Host "
This option is going to install all these applications:
$(Get-Installables)
    
Send C to continue.
Send B to go back.
    
"
                switch ($confirm) {
                    'C' { Install-Apps }
                    'B' { $return = $true }
                }
            }        
        }
        '2' {
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
        '3' { 

            if (IsAdminEnabled) {
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
        '4' {

            if (IsInDomain) {
                $global:warn = "`nWARN: You're already in a domain. This action is not possible.`n"
                break
            }
            else { $global:warn = "" }

            $return = $false

            while (-not $return) {
                Clear-Host

                $confirm = Read-Host "
This option will add this computer to the MASP domain and
rename it using its patrimony number.

To take effect, you must be connected to the MASP network
and then restart the computer.
$global:4err
Send C to continue.
Send R to continue and restart computer.
Send B to go back.

"

                switch ($confirm) {
                    'C' { Enter-Domain }
                    'R' { Enter-Domain -Restart $true }
                    'B' { $return = $true }
                }
            }
        }
        'Q' {
            Write-Host "Exiting the script."
            $exit = $true 
        }
    }
}