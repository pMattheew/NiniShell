$ProgressPreference = 'SilentlyContinue'

function Initialize-App {
    param([switch] $verbose)

    if ($verbose) { $VerbosePreference = "Continue" }

    . "$(Get-Location)\modules\object-helper.ps1"
    . "$(Get-Location)\modules\config.ps1"
    . "$(Get-Location)\modules\cli.ps1"

    $global:config = Initialize-Config

    $global:cli = Initialize-Cli

    $cli.show()

    # Get-ChildItem "$(Get-Location)\components" | ForEach-Object {
    #     write-host $_
    # }

#     Write-Host -ForegroundColor Magenta '
# 888b    888 d8b          d8b  .d8888b.  888               888 888 
# 8888b   888 Y8P          Y8P d88P  Y88b 888               888 888 
# 88888b  888                  Y88b.      888               888 888 
# 888Y88b 888 888 88888b.  888  "Y888b.   88888b.   .d88b.  888 888 
# 888 Y88b888 888 888 "88b 888     "Y88b. 888 "88b d8P  Y8b 888 888 
# 888  Y88888 888 888  888 888       "888 888  888 88888888 888 888 
# 888   Y8888 888 888  888 888 Y88b  d88P 888  888 Y8b.     888 888 
# 888    Y888 888 888  888 888  "Y8888P"  888  888  "Y8888  888 888 
# '
}

function Fetch {
    param(
        [string] $file,
        [string] $repo = 'pMattheew/ninishell'
    )

    $src = "https://raw.githubusercontent.com/$repo/main/$file"

    if ($VerbosePreference -eq "Continue") { $src = "$(Get-Location)/$file" }

    try {
        if ($config.TOKEN) {
            $src = "https://api.github.com/repos/$repo/contents/$file"
            $headers = @{
                'Accept'               = 'application/json'
                'Authorization'        = "Bearer $($config.TOKEN)"
                'X-GitHub-Api-Version' = '2022-11-28'
            }
    
            $response = Invoke-WebRequest -UseBasicParsing -Uri $src -Headers $headers | ConvertFrom-Json
            $result = Invoke-WebRequest -UseBasicParsing -Uri $response.download_url
        }
        else { $result = Invoke-WebRequest -UseBasicParsing -Uri $src }
    }
    catch { throw "Couldn't fetch '$file'. Error message:`n$_" }

    return $result
}

Initialize-App -Verbose


# function Get-GitHubFile {
#     param(
#         [string]$file
#     )

#     $token = "your-gh-token"

#     $headers = @{
#         'Accept'               = 'application/json'
#         'Authorization'        = "Bearer $token"
#         'X-GitHub-Api-Version' = '2022-11-28'
#     }

#     $src = "https://api.github.com/repos/soumasp/scripts/contents/$file"

#     $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $src | ConvertFrom-Json

#     Invoke-WebRequest -UseBasicParsing -Uri $response.download_url
# }

# Get-GitHubFile -File "modules/Applications.ps1" | Invoke-Expression
# Get-GitHubFile -File "modules/Admin.ps1" | Invoke-Expression
# Get-GitHubFile -File "modules/Domain.ps1" | Invoke-Expression

# $exit = $false

# while (-not $exit) {
#     Clear-Host

#     $choice = Read-Host "
    
# Please choose an option: 

# 1. Install all applications
# 2. Select applications to install
# 3. Activate administrator 
# 4. Rename computer and add to domain
# $global:warn
# Send Q to quit the program.

# "

#     switch ($choice) {
#         '1' {
#             Initialize-Applications

#             $return = $false

#             while (-not $return) {
#                 Clear-Host

#                 $confirm = Read-Host "
# This option is going to install all these applications:
# $(Get-Installables)
    
# Send C to continue.
# Send B to go back.
    
# "
#                 switch ($confirm) {
#                     'C' { Install-Apps }
#                     'B' { $return = $true }
#                 }
#             }        
#         }
#         '2' {
#             Initialize-Applications

#             $return = $false

#             while (-not $return) {
#                 Clear-Host

#                 $select = Read-Host "
# Select the applications that you want to install from these options:
# $(Get-Installables -Enumerated $true)

# Send a valid array of numbers to continue.
# Send H for help.
# Send B to go back.

# "
#                 switch ($select) {
#                     'H' {
#                         Clear-Host

#                         Read-Host "
# To select the desired applications you must return a valid array
# separated by spaces. Like in the following example, these are the
# options of applications to be installed:

#  1 - WinRAR
#  2 - Chrome
#  3 - Drive

# Then it is answered with this:

# : 1 3

# So only WinRAR and Drive are going to be installed.

# PS: It MUST be separated using spaces.
                        
# "

#                         Clear-Host
#                     }
#                     'B' {
#                         $return = $true
#                     }
#                     default { Select-Apps }
#                 }
#             }
#         }
#         '3' { 

#             if (IsAdminEnabled) {
#                 $global:warn = "`nWARN: The administrator account is already enabled in this computer.`n"
#                 break
#             }
#             else { $global:warn = "" }

#             $return = $false

#             while (-not $return) {
#                 Clear-Host

#                 $confirm = Read-Host "
# This option will activate the administrator user and
# exclude all other local accounts.
# $global:3err
# Send C to continue.
# Send B to go back.

# "

#                 switch ($confirm) {
#                     'C' { Set-Admin }
#                     'B' { $return = $true }
#                 }
#             }
            
#         }
#         '4' {

#             if (IsInDomain) {
#                 $global:warn = "`nWARN: You're already in a domain. This action is not possible.`n"
#                 break
#             }
#             else { $global:warn = "" }

#             $return = $false

#             while (-not $return) {
#                 Clear-Host

#                 $confirm = Read-Host "
# This option will add this computer to the MASP domain and
# rename it using its patrimony number.

# To take effect, you must be connected to the MASP network
# and then restart the computer.
# $global:4err
# Send C to continue.
# Send R to continue and restart computer.
# Send B to go back.

# "

#                 switch ($confirm) {
#                     'C' { Enter-Domain }
#                     'R' { Enter-Domain -Restart $true }
#                     'B' { $return = $true }
#                 }
#             }
#         }
#         'Q' {
#             Write-Host "Exiting the script."
#             $exit = $true 
#         }
#     }
# }