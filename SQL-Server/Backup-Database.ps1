param(
	[String]$BackupPath,
	[String]$Database,
	[String]$Server,
	[String]$BackupFile = "$BackupPath\$Database.bak",
	[String]$Compression = "On" # CompressionOption isn't available in SQL Server Express
)

Backup-SqlDatabase `
	-BackupAction Database `
	-SkipTapeHeader `
	-NoRewind `
	-NoRecovery `
	-FormatMedia `
	-Initialize `
	-BackupSetDescription "$Database-Full-Backup" `
	-Database $Database `
	-ServerInstance $Server `
	-BackupFile $BackupFile `
	-CompressionOption $Compression

Write-Host "Completed Database Backup to $BackupPath"

return $BackupFile