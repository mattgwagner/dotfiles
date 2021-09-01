$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Code = Join-Path $($env:USERPROFILE) "Code"

Export-ModuleMember -variable * -Function *