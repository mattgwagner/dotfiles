if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall"))
{
	Write-Host "Chocolatey Not Found, Installing..."
	Invoke-Expression ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1')) 
}