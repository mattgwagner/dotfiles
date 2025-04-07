$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if($IsWindows)
{
    $env:Path = "$($env:Path);$Here;C:\Program Files\nodejs"

    Set-ExecutionPolicy Unrestricted process

    & "$Here\Ensure-Chocolatey.ps1" 
}

& "$Here\Ensure-OhMyPosh.ps1"

Import-Module $Here\Git\Git.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Common.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Docker\Docker.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Dotnet\Dotnet.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\GitHub\GitHub.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\Browser-Tools.psm1 -DisableNameChecking -Force -NoClobber

Import-Module $Here\..\Overrides.ps1 -DisableNameChecking -ErrorAction Ignore

if($IsWindows)
{
    New-PSDrive -Root $Code -Name Code -PSProvider FileSystem -Scope Global

    Write-Host ""
    Write-Host "Mapped $Code to Code:"
    Write-Host ""

    Push-Location "Code:"
    
    Set-DotEnv
}

function Show-ProfileCommands {
    Write-Host "`nAvailable Commands:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    Write-Host "`nNavigation:" -ForegroundColor Yellow
    Write-Host "  cd...     -> Go up two directories"
    Write-Host "  cd....    -> Go up three directories"
    Write-Host "  Go-ToCode -> Navigate to your Code directory"
    
    Write-Host "`nGit Commands:" -ForegroundColor Yellow
    Write-Host "  prb (Push-ReleaseBranch) -> Pull from main and push to release branch"
    
    Write-Host "`nUtility Commands:" -ForegroundColor Yellow
    Write-Host "  New-ShellAs   -> Open new shell as different user"
    Write-Host "  Sudo          -> Run command as different user"
    Write-Host "  Set-DotEnv    -> Load environment variables from .env file"
    
    Write-Host "`nType 'Get-Command -Module *' to see all available commands`n" -ForegroundColor Gray
}

Show-ProfileCommands