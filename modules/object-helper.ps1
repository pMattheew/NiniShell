function Add-Property {
    param(
        [PSCustomObject] $obj,
        [string] $name,
        [string] $value
    )

    Add-Member -InputObject $obj -MemberType NoteProperty -Name $name -Value $value
}

function Add-Method {
    param(
        [PSCustomObject] $obj,
        [string] $name,
        [scriptblock] $value
    )
    Add-Member -InputObject $obj -MemberType ScriptMethod -Name $name -Value $value
}