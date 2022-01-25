$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Code = Join-Path $Home "Code"

if(!(test-path $Code))
{
    New-Item -Path $Code -ItemType Directory
}

# Reference https://gist.github.com/timsneath/19867b12eee7fd5af2ba

# Useful shortcuts for traversing directories
function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }

function New-ShellAs($user)
{
    runas.exe /netonly /user:$user pwsh
}

Export-ModuleMember -variable * -Function *