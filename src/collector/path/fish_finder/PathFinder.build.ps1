#Requires -Module @{ ModuleName = 'psake'; ModuleVersion = '4.9.0' }
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $PSManifestGenerator
)
[string]$psModuleName       =   [System.IO.Path]::GetFileNameWithoutExtension($PSScriptRoot)

Task    -Name           Test `
        -Description    "Run Pester tests for the module $psModuleName" `
        -Action `
        {
            Invoke-Pester -Path $PSScriptRoot -Show None -PassThru
        }

Task    -Name           Manifest `
        -Description    "Create manifest for the module $psModuleName" `
        -Action `
        {
            Get-Module -Name $PSManifestGenerator -ListAvailable | Import-Module
            New-ModuleManifestAuto -Path $PSScriptRoot
        }