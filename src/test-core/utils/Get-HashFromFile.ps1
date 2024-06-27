<#
.Notes
    Developed by Steven Holtman in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman

.Synopsis
    Get's the SHA256 Hash from a file, this is helpful for adding to your AV application or to confirm file hash after download from the developers site.

.DESCRIPTION
   It will prompt for you to enter the Source Directory and Destination Directoy to validate the hashes match in both direcoties for proper data integrity
   
.EXAMPLE
   Get-FolderComparison
#>
function Get-HashFromFile {
    try {
        # Adding Form Assembly
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'Any file type (*.*)|*.*|Executable Files (*.exe)|*.exe|Batch Files (*.bat)|*.bat|Powershell Files (*.ps1)|*.ps1'
            Title            = 'Select the File you need to retrieve the File Hash for'
        }
        $DialogforFile = $FileBrowser.ShowDialog()
        $GetFileName = Get-FileHash $FileBrowser.FileName
    }
    catch {
        Write-Host $_.Exception.Message
    }
    finally {
        # Defining Variables
        $FileName = ($GetFileName.Path).split('\')[-1]
        $FileHash = $GetFileName.hash
        Write-Output "$FileName's hash: $FileHash"
    }
}