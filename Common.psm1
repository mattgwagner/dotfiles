$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Code = Join-Path $($env:USERPROFILE) "Code"

if(!(test-path $Code))
{
    New-Item -Path $Code -ItemType Directory
}

# Reference https://gist.github.com/timsneath/19867b12eee7fd5af2ba

# Useful shortcuts for traversing directories
function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }

Export-ModuleMember -variable * -Function *