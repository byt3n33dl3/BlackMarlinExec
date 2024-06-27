<#
.Notes
    Developed by Steven Holtman and Written in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman

.Synopsis
    Get's the Current Wireless Profile and Password and outputs the information to the console.

.DESCRIPTION
    Get's the wireless information using the netsh command to get the currently connected wireless profile info and password in plain text and outputs the data to the console.

.EXAMPLE
    Get-CurrentWirelessProfile
#>
function Get-CurrentWirelessProfile {
        try {
                $NetworkState = (Invoke-Command -ScriptBlock { cmd /c netsh wlan show interfaces | findstr /r /s /i /m /c:"\<state\>" }).split(':')[1].Trim()
                if ($NetworkState -eq "connected") {
                        $NetworkName = (Invoke-Command -ScriptBlock { cmd /c netsh wlan show interfaces | findstr /r /s /i /m /c:"\<ssid\>" }).split(':')[1].Trim()
                        $NetworkPassword = (Invoke-Command -ScriptBlock { cmd /c netsh wlan show profile "$NetworkName" key=clear | findstr /r /s /i /m /c:"\<key content\>" }).split(':')[1].Trim()
                        Write-Output $("Network Name: $NetworkName `n" + "Network Password: $NetworkPassword")
                }
        }
        catch {
                Write-Host $($Env:COMPUTERNAME + " does not appear to be connected to wireless.")
        }
}