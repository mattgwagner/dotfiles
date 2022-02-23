$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

& "$Here\Ensure-Chocolatey.ps1"

if(!(Get-Command vswhere -ErrorAction SilentlyContinue))
{
    choco install vswhere
}

$MSBuild = vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1

Write-Output "MSBuild Path: $MSBuild"

return $MSBuild