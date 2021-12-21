$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Import-Module $Here\AutoComplete.psm1

$env:Path = "$($env:Path);$Here;"

function GetAllReposAsCsv($Organization)
{
    $Repos = (& Get-AllRepositories.ps1 -Organization $Organization)

    $Content = ($Repos | Select-Object -Property name, url, archived)

    $Csv = (ConvertTo-Csv $Content)

    return $Csv
}

Export-ModuleMember -Alias * -Function *