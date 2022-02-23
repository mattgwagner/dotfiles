$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$NuGetExe = "$Here\nuget.exe"

if(!(Test-Path $NuGetExe))
{
	$DownloadUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

	$Client = New-Object -TypeName System.Net.WebClient

	$Client.DownloadFile($DownloadUri, $NuGetExe)
}

return $NuGetExe