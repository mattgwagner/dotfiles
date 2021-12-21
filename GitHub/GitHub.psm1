$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Import-Module $Here\AutoComplete.psm1

$env:Path = "$($env:Path);$Here;"

Export-ModuleMember -Alias * -Function *