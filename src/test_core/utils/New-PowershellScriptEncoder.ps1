<#
.Notes
    Developed by Steven Holtman and Written in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman

.Synopsis
    Encodes PoweShell script into Base64 and Generates it with the Execution Bypass

.EXAMPLE
    Get-Base64Encoder
#>
function New-PowershellScriptEncoded {
    try {
        # Adding Form Assembly
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'Powershell Files (*.ps1)|*.ps1'
            Title            = 'Select the batch script or powershell script you want to encode'
        }
        $DialogforFile = $FileBrowser.ShowDialog()
    }
    catch {
        Write-Host $_.Exception.Message
    }
    finally {
        # Defining Variables
        $GetScriptName = $FileBrowser.FileName
        $ScriptDirectory = Split-Path -Parent $FileBrowser.FileName
        $ScriptName = ($GetScriptName).split('\')[-1]
        $Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes([System.IO.File]::ReadAllText("$GetScriptName")))
        Write-Output "powershell.exe -ExecutionPolicy Bypass -EncodedCommand $($($Base64).Trim())" | Out-File "$ScriptDirectory\Encoded-$ScriptName"
        Start $ScriptDirectory
    }
}