param (
    $Source = "app.config",
    $Replacement = "app.Release.config",
    $Output = "Release.config"
)

$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Import-Module "$Here\Dotnet.psm1"

& $MsBuild "$Here\Transform.msbuild" /p:SourceConfig=$Source /p:valuesConfig=$Replacement /p:outputConfig=$Output