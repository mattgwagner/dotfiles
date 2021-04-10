param(
	[String]$Server = "localhost" 
)

Push-Location

# Stop SQL Server service

# Launch SQLServer.exe -m 

# SQLCmd -S localhost

$User = "$($env:USERDOMAIN)\$($env:USERNAME)"

Invoke-Sqlcmd -ServerInstance $Server -Query "CREATE LOGIN [$User] FROM WINDOWS"

Invoke-Sqlcmd -ServerInstance $Server -Query "exec sp_addsrvrolemember @loginname='$User', @rolename = 'sysadmin'"

# Re-Start SQL Server service

Pop-Location
