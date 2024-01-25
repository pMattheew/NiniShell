$ProgressPreference = 'SilentlyContinue'

function Initialize-App {

    Initialize-Config $true # exposes $config

    Initialize-Gui # exposes $gui

    # check if $repo is set. $token should be optional
    if (-not $config.REPO) {
        $v = Get-View "no-repo"
        $gui.add($v)
        $gui.show("There was an error when trying to launch NiniShell", "error")
    }
 

    # do request for config.json
    Write-Host "App setup finished! Ready to start." 
}

function Add-Method {
    param(
        [PSCustomObject] $obj,
        [string] $name,
        [scriptblock] $value
    )
    Add-Member -InputObject $obj -MemberType ScriptMethod -Name $name -Value $value
}

function Get-RepoFile {
    param(
        [string] $file,
        [string] $repo = 'pMattheew/ninishell'
    )

    $src = "https://raw.githubusercontent.com/$repo/main/$file"

    if ($global:config.DEBUG -eq $true) { $src = "$(Get-Location)/$file" }

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

function Get-View {
    param([string] $view)
    $v = Get-RepoFile "views/$view/$view.csv"
    $psPath = "$($config.ROOT)\views\$view.ps1"
    if(-not (Test-Path $psPath)) {
        $ps = Get-RepoFile "views/$view/$view.ps1"
        Set-Content $psPath $ps
    }
    return $v
}

function Initialize-Config {
    param([bool] $debug = $null)

    $config = @{}

    if($debug -eq $true) { $config.DEBUG = $true }

    $rootPath = "$env:appdata\NiniShell"

    if (-not (Test-Path $rootPath)) {
        New-Item $rootPath -ItemType Directory > $null
        New-Item "$rootPath\views" -ItemType Directory > $null 
    }

    $configPath = "$env:appdata\NiniShell\ninishell.cfg"

    Add-Content $configPath "ROOT=$rootPath"

    Get-Content $configPath | ForEach-Object {
        $key, $value = $_ -split '='
        if (-not [string]::IsNullOrWhiteSpace($value)) { 
            $config[$key] = $value 
        }
    }

    $global:config = $config
}

function Initialize-Gui {
    if (-not (Get-Module -ListAvailable -Name "PSScriptMenuGui")) {
        Install-Module PSScriptMenuGui -Scope CurrentUser -Force
    }
    Import-Module PSScriptMenuGui
    
    $gui = [PSCustomObject]@{ path = "$env:temp\ninishell-view.csv" }
    
    # Get icons
    function Get-Icon {
        param([string] $name)
        $path = "$($config.ROOT)\$name"
        if (Test-Path $path) { return $path }
        $res = Get-RepoFile "assets/$name"
        [IO.File]::WriteAllBytes($path, $res.Content)
        return $path
    }

    $global:icons = @{
        logo  = Get-Icon "ninishell-logo.ico"
        error = Get-Icon "error.ico"
    }

    # Add methods
    Add-Method $gui "reset" {
        Set-Content $gui.path "Section,Method,Command,Arguments,Name,Description"
    }

    Add-Method $gui "add" {
        param([string] $content)
        Add-Content $gui.path $content
    }

    Add-Method $gui "show" {
        param(
            [string] $windowTitle,
            [string] $icon = "logo"
        )

        $process = Start-Process powershell -ArgumentList "-Command & { Show-ScriptMenuGui -csvPath '$($gui.path)' -windowTitle '$windowTitle' -iconPath '$($icons.$icon)' -Verbose -noExit }" -PassThru

        Wait-Process $process.Id
    }

    $gui.reset()

    $global:gui = $gui
}

try {
    Initialize-App
}
finally {
    Remove-Item "$env:temp\ninishell-view.csv"
}




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