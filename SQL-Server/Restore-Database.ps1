param(
	[String]$BackupFile,
	[String]$FromDbName,
	[String]$TargetDb,
	[String]$TargetServer
)

# Find the default file location for the target server

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

$SMOServer = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $TargetServer

$DefaultFileLocation = $SMOServer.Settings.DefaultFile
$DefaultLogLocation = $SMOServer.Settings.DefaultLog

if ($DefaultFileLocation.Length -eq 0)
{
    $DefaultFileLocation = $SMOServer.Information.MasterDBPath
}
if ($DefaultLogLocation.Length -eq 0)
{
    $DefaultLogLocation = $SMOServer.Information.MasterDBLogPath
}

$Sql = "
	USE [master]
	GO

	if db_id('$TargetDb') is not null
	begin
		EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$TargetDb'

		ALTER DATABASE [$TargetDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

		DROP DATABASE [$TargetDb]
	end

	RESTORE DATABASE [$TargetDb]
	FROM  DISK = N'$BackupFile'
	WITH  FILE = 1,
	MOVE N'$FromDbName'
	TO N'$DefaultFileLocation$($TargetDb).mdf',
	MOVE N'$FromDbName_log'
	TO N'$DefaultLogLocation$($TargetDb)_log.ldf',
	NOUNLOAD,
	REPLACE,
	STATS = 1

	GO
"

Push-Location

Invoke-SqlCmd -Query $Sql -ServerInstance $TargetServer

Pop-Location

Write-Output "Completed Database Restore to $TargetDb"