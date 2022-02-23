##
## This script will run a configuration transform on an Web/App.config file for a given environment
##
## Usage: .\Run-ConfigTransforms.ps1 .\App.Web\Web.config .\App.Web\Web.Staging.config .\TransformResult.config
##

Param(
	[String]$ConfigFile = "Web.config",
	[String]$TransformFile = "Web.Test.config",
	[String]$OutputFile = "TransformResult.config"
)

$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$NuGet = & "$Here\Ensure-Nuget.ps1"

$RunnerPackage = "WebConfigTransformRunner"
$RunnerVersion = "1.0.0.1"

$Runner = Join-Path $Here "$RunnerPackage.exe"

if ( !(Test-Path $Runner) )
{
	. $NuGet install $RunnerPackage -version $RunnerVersion -OutputDirectory $Here
}

. $Runner $ConfigFile $TransformFile $OutputFile