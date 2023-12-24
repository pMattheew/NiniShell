# When Kaspersky and SupportAssist are being installed together, 
# SupportAssist throws an error in the installation. This script
# should avoid this behavior by starting Kaspersky installation 
# after SupportAssist installation.

$j = Get-Job -Name "Install-SupportAssist" -ErrorAction SilentlyContinue

if ($j) { Receive-Job -Name "Install-SupportAssist" -Wait }