$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if($IsWindows)
{
    $env:Path = "$($env:Path);$Here;C:\Program Files\nodejs"

    Set-ExecutionPolicy Unrestricted process

    & "$Here\Ensure-Chocolatey.ps1" 
}

& "$Here\Ensure-OhMyPosh.ps1"

Import-Module $Here\Git.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Common.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Docker\Docker.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Dotnet\Dotnet.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\GitHub\GitHub.psm1 -DisableNameChecking -Force -NoClobber

if($IsWindows)
{
    New-PSDrive -Root $Code -Name Code -PSProvider FileSystem -Scope Global

    Write-Host ""
    Write-Host "Mapped $Code to Code:"
    Write-Host ""

    Push-Location "Code:"
}
if($IsMacOs)
{
    Push-Location "$Home/Code"
}
