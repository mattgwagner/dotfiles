$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Code = Join-Path $($env:USERPROFILE) "Code"

if(!(test-path $Code))
{
    New-Item -Path $Code -ItemType Directory
}

Export-ModuleMember -variable * -Function *