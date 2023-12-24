Expand-Archive -Path $path -DestinationPath $env:TEMP -Force     # Unzip

$src = "$env:TEMP\Office"

$path = "$src\setup.exe"

$xml = @"
<Configuration>
    <Info Description="Office Standard 2019 (64-bit)" />
    <Add OfficeClientEdition="64" Channel="PerpetualVL2019" SourcePath="SOURCE_PATH_PLACEHOLDER">
        <Product ID="Standard2019Volume" PIDKEY="your-office-key">
        <Language ID="pt-br" />
        </Product>
    </Add>
    <RemoveMSI />
    <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@

$xml = $xml.Replace("SOURCE_PATH_PLACEHOLDER", $src)

$configPath = "$src\configuration.xml"

$xml | Out-File -FilePath $configPath -Encoding utf8 