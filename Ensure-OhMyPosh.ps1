$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if( ! (Get-Command "oh-my-posh.exe" -ErrorAction SilentlyContinue))
{
    if($IsWindows)
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force;

        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

        & RefreshEnv.cmd
    }

    if($IsMacOs)
    {
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    }
}

oh-my-posh init pwsh --config $Here\oh-my-posh.json | Invoke-Expression