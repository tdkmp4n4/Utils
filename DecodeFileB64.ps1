$Encoded = ""
$FilePath = ""
[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Encoded)) | Out-File -Encoding "ASCII" $FilePath
$Content2 = get-content $FilePath
Write-Host $Content2