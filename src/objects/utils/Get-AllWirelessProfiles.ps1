<#
.Notes
    Developed by Steven Holtman and Written in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman

.Synopsis
    Get's the Wireless Networks and Passwords and outputs the information to a log file.

.DESCRIPTION
    Get's the wireless information using the netsh command to get all network info and password in plain text and outputs the data into a log file with just the network name and the wireless passphrase.

.EXAMPLE
    Get-AllWirelessNames
#>
function Get-AllWirelessNames {
# Writting the log file
$LogFile = "$Env:USERPROFILE\Wireless Profiles.log"
$Networks = $(Invoke-Command -ScriptBlock { cmd /c netsh wlan show profiles * | findstr /r /s /i /m /c:"\<SSID\>" }).split(':').Trim("SSID name") -ne "$null"
foreach ($Network in $Networks) {
        $NetworkName = (Invoke-Command -ScriptBlock { cmd /c netsh wlan show profile $Network | findstr /r /s /i /m /c:"\<SSID\>" }).split(':')[1].Trim()
        $NetworkPassword = (Invoke-Command -ScriptBlock { cmd /c netsh wlan show profile $Network key=clear | findstr /r /s /i /m /c:"\<key content\>" }).split(':')[1].Trim()
        Write-Output "Wireless Network `n SSID: $($Network.Trim('"')) `n Passphrase: $NetworkPassword `n" | Out-File $LogFile -Append
}
Invoke-Item $LogFile
}