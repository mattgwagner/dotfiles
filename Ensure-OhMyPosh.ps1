$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if( ! (Get-Command "oh-my-posh.exe" -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

    & RefreshEnv.cmd
}

oh-my-posh init pwsh --config $Here\oh-my-posh.json | Invoke-Expression