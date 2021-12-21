$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Import-Module $Here\AutoComplete.psm1

$env:Path = "$($env:Path);$Here;"

function ExportRepositoriesForOrganization($Organization)
{
    $Repos = (& $Here\Get-AllRepositories.ps1 -Organization $Organization)

    $Selected = ($Repos | Select-Object -Property name, git_url, archived)

    $Csv = (ConvertTo-CSV $Selected)

    Write-Content $Csv -Path "$Organization.csv"
}

Export-ModuleMember -Alias * -Function *