$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$SolutionRoot = (Split-Path -parent $Here)

$Src = Join-Path $SolutionRoot "src"

$NugetFolder = Join-Path $Src ".nuget"

$NuGetExe = "$NugetFolder\nuget.exe"

if(!(Test-Path $NuGetExe))
{
	$DownloadUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

	$Client = New-Object -TypeName System.Net.WebClient

	$Client.DownloadFile($DownloadUri, $NuGetExe)
}

return $NuGetExe