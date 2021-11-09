$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$env:Path = "$($env:Path);$Here;C:\Program Files\nodejs"

Set-ExecutionPolicy Unrestricted process

& "$Here\Ensure-Chocolatey.ps1"

& "$Here\Ensure-OhMyPosh.ps1"

Set-PoshPrompt mt

Import-Module $Here\Git.psm1 -DisableNameChecking -Force

Import-Module $Here\Common.psm1 -DisableNameChecking -Force

Import-Module $Here\Docker\Docker.psm1 -DisableNameChecking -Force

New-PSDrive -Root $Code -Name Code -PSProvider FileSystem -Scope Global

Write-Host ""
Write-Host "Mapped $Code to Code:"
Write-Host ""

Push-Location "Code:"