###
### Setup a PowerShell profile that will look at our loader for modules
###

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (!(test-path $profile)) 
{
    New-Item -path $profile -type file -force
}

Add-Content $profile "Import-Module ""$ScriptPath\Profile.psm1"" -DisableNameChecking"