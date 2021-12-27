$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

if(!(Get-Module -ListAvailable -Name oh-my-posh)) {
    Install-Module oh-my-posh -Scope CurrentUser
}

Import-Module oh-my-posh

# oh-my-posh --init --shell pwsh --config $Here/oh-my-posh | Invoke-Expression

Set-PoshPrompt -Theme $Here\oh-my-posh.json