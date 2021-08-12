clear-host
 
# Encode
 
$File1 = "C:\Users\pastudent124\Desktop\AlisecTools_Nuevas\AlisecTools_Nuevas\powercat.ps1"
 
$Content1 = get-content $File1
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Content1)
$Encoded = [System.Convert]::ToBase64String($Bytes) | Out-File -FilePath "C:\Users\pastudent124\Desktop\AlisecTools_Nuevas\AlisecTools_Nuevas\powercat.b64"
