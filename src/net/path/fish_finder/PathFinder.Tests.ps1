#Requires   -Module @{  ModuleName  =   'Pester';           ModuleVersion   =   '5.0.2'     }
#Requires   -Module @{  ModuleName  =   'PSScriptAnalyzer'; ModuleVersion   =   '1.19.0'    }

[string]$psTestDataPath         =   [System.IO.Path]::ChangeExtension($PSCommandPath, 'psd1')
if (-not [System.IO.File]::Exists($psTestDataPath)) {
    Write-Warning -Message "PowerShell data file not found: $psTestDataPath"
    return
}

$psTestData                     =   Import-PowerShellDataFile -Path $psTestDataPath
#   Constants
##  The module root folder:
$psTestData.psModuleRoot        =   $PSScriptRoot
##  The module name:
#[string]$psModuleName           =   [System.IO.Path]::GetFileNameWithoutExtension($PSScriptRoot)
$psTestData.psModuleName        =   [System.IO.Path]::GetFileNameWithoutExtension($PSScriptRoot)
##  The expected manifest name:
#[string]$psManifestName         =   "$($psModuleName).psd1"
$psTestData.psManifestName      =   "$($psModuleName).psd1"
##  The expected module manifest path:
#[string]$psManifestPath         =   [System.IO.Path]::Combine($PSScriptRoot, $psManifestName)
$psTestData.psManifestPath      =   [System.IO.Path]::Combine($PSScriptRoot, $psManifestName)

##  The expected root module names:
$psTestData.psRootNames         =   $psTestData.psModuleExtensions.ForEach({
    "$($psTestData.psModuleName)$($_)"
})

##  The expected directory structure:
$psTestData.psDirsShouldPresent =   $psTestData.psDirsShouldPresent.ForEach({
    [System.IO.Path]::Combine($PSScriptRoot, $_)
})

Describe "General tests for the module: $($psTestData.psModuleName)" {
    Context "Inventory: $($psTestData.psModuleName)" {

        It "Subfolders should be present" -TestCases $psTestData {
            param(
                $psDirsShouldPresent
            )
            $psDirsShouldPresent.ForEach({
                Write-Verbose "Subfolder `"$_`" should exist"
                [bool]$folderExists =   [System.IO.Directory]::Exists($_)
                $folderExists       |   Should -BeTrue
            })
        }

        It "Subfolders should contain scripts" -TestCases $psTestData {
            param(
                $psDirsShouldPresent
            )
            $psDirsShouldPresent.ForEach({
                Write-Verbose "Subfolder `"$_`" should contain scripts"
                [System.IO.Directory]::EnumerateFiles($_, '*.ps1') |   Should -BeGreaterThan 0
            })
        }

        It "The module file should be present" -TestCases $psTestData {
            param(
                $psRootNames
            )
            [string[]]$rootFilesPresent = $psRootNames.ForEach({
                [System.IO.Directory]::EnumerateFiles($PSScriptRoot, $_)
            })
            $rootFilesPresent.Count |   Should -BeGreaterThan 0
        }
    }

    Context "General tests of the scripts" {

        It "Invoke PSScriptAnalyzer for scripts" -TestCases $psTestData {
            param (
                $psDirsShouldPresent,
                $psScriptAnalyzerRules
            )
            [string[]]$scriptsAll   =   $psDirsShouldPresent.ForEach({
                [System.IO.Directory]::EnumerateFiles($_, '*.ps1')
            }) -notmatch '\.tests\.ps1$'

            $scriptsAll.ForEach({
                Invoke-ScriptAnalyzer   -Path $_ `
                                    -ExcludeRule $psScriptAnalyzerRules.ExcludeRule `
                                    -Severity $psScriptAnalyzerRules.Severity `
                                    | Should -BeNullOrEmpty
            })
        }
    }

    if ([System.IO.File]::Exists($psTestData.psManifestPath)) {
        Context "Testing the manifest $($psTestData.psManifestName)" {
            
            It "Invoke PSScriptAnalyzer for the module manifest: $($psTestData.psManifestName)" -TestCases $psTestData {
                param(
                    $psManifestPath,
                    $psScriptAnalyzerRules
                )
                Invoke-ScriptAnalyzer   -Path $psManifestPath `
                                        -ExcludeRule $psScriptAnalyzerRules.Manifest.ExcludeRule `
                                        -Severity $psScriptAnalyzerRules.Manifest.Severity `
                                        | Should -BeNullOrEmpty
            }

            It "Read the manifest: $($psTestData.psManifestPath)" -TestCases $psTestData {
                param(
                    $psManifestPath
                )
                $psManifestData                 =   Import-PowerShellDataFile -Path $psManifestPath
                $psManifestData                 |   Should -BeOfType 'System.Collections.Hashtable'
                [string]$psManifestRootModule   =   $psManifestData.RootModule
                if ($psManifestRootModule)
                {
                    [System.IO.Path]::GetExtension($psManifestRootModule)   | Should -Not -BeIn @('.ps1', '.psd1')
                }
            }
        }
    }

    Context "Test load: $($psTestData.psModuleName)" {
        It "Get-Module $($psTestData.psModuleName)" -TestCases $psTestData {
            param(
                $psModuleRoot
            )
            $psModuleInfo       =   Get-Module -Name $psModuleRoot -ListAvailable
            $psModuleInfo       |   Should -BeOfType 'System.Management.Automation.PSModuleInfo'
        }

        It "Import and remove module $($psTestData.psModuleName)" -TestCases $psTestData {
            param(
                $psModuleRoot,
                $psModuleName
            )
            $psImportResult             =   Import-Module -Name $psModuleRoot
            $psImportResult             |   Should -BeNullOrEmpty
            $psModuleInfo               =   Get-Module -Name $psModuleName
            $psModuleInfo               |   Should -BeOfType 'System.Management.Automation.PSModuleInfo'
            $psModuleInfo.Name          |   Should -BeExactly $psModuleName
            $psModuleInfo.ModuleBase    |   Should -BeExactly $PSScriptRoot
        }
    }
}
