param(
    [Parameter(Mandatory = $true)]
    [int]$Port = (Read-Host -Prompt "Port")
)

$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

& "$Here\ngrok.exe" http --host-header=rewrite localhost:$Port