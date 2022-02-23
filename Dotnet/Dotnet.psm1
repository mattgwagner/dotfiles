## Yes, I know these are two distinct different versions

## This should probably be refactored to use vswhere.exe instead

$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$env:PATH += ";$Here"

$Vs2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"

$Vs2022 = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

$Ssms = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"

$MsBuild = (& "$Here\Get-Msbuild.ps1")

function Check-DotnetUpgrade($Project)
{
    Ensure-DotnetUpgradeAssistant

    upgrade-assistant analyze $Project
}

function Ensure-DotnetUpgradeAssistant
{
    dotnet tool install -g upgrade-assistant --ignore-failed-sources
}

Export-ModuleMember -Alias * -Function * -Variable Vs2019, Vs2022, Ssms, MsBuild
