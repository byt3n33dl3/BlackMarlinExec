param (
    [string[]]$TaskName = ('Clean', 'Build', 'UpdateHelp', 'Test'),

    [Hashtable]$BuildConfig = (
        Join-Path -Path $PSScriptRoot -ChildPath 'buildConfig.psd1' | Import-PowerShellDataFile -LiteralPath { $_ } -ErrorAction SilentlyContinue
    ),

    $ExcludeCustomTasks
)

function Setup {
    Install-Module -Name Pester -SkipPublisherCheck -Force
    Install-Module -Name ModuleBuilder, PlatyPS, PSScriptAnalyzer -Force
}

function Clean {
    $path = Join-Path -Path $PSScriptRoot -ChildPath 'build'
    if (Test-Path $path) {
        Remove-Item $path -Recurse
    }
}

function Build {
    Build-Module -Path (Resolve-Path $PSScriptRoot\*\build.psd1)

    $rootModule = Join-Path -Path $PSScriptRoot -ChildPath 'build\*\*\*.psm1' | Resolve-Path
    $tokens = $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $rootModule,
        [ref]$tokens,
        [ref]$errors
    )
    $dscResourcesToExport = $ast.FindAll(
        {
            param ( $node )

            $node -is [System.Management.Automation.Language.TypeDefinitionAst] -and
            $node.IsClass -and
            $node.Attributes.TypeName.FullName -contains 'DscResource'
        },
        $true
    ).Name

    if ($dscResourcesToExport) {
        $moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath 'build\*\*\*.psd1' |
            Get-Item |
            Where-Object { $_.BaseName -eq $_.Directory.Parent.Name }

        Update-Metadata -Path $moduleManifest.FullName -PropertyName DscResourcesToExport -Value $dscResourcesToExport
    }
}

function Test {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath 'build\*\*\*.psd1' |
        Get-Item |
        Where-Object { $_.BaseName -eq $_.Directory.Parent.Name }
    $rootModule = $modulePath -replace 'd1$', 'm1'
    $moduleManifest = Import-PowerShellDataFile -Path $modulePath

    if ($moduleManifest.CompatiblePSEditions -contains $PSVersionTable.PSEdition) {
        $stubPath = Join-Path -Path $PSScriptRoot -ChildPath '*\tests\stub\*.psm1'
        if (Test-Path -Path $stubPath) {
            foreach ($module in $stubPath | Resolve-Path) {
                Import-Module -Name $module -Global
            }
        }

        Import-Module -Name $modulePath -Force -Global

        $configuration = @{
            Run          = @{
                Path     = [string[]](Join-Path -Path $PSScriptRoot -ChildPath '*\tests' | Resolve-Path)
                PassThru = $true
            }
            CodeCoverage = @{
                Enabled    = $true
                Path       = $rootModule
                OutputPath = Join-Path -Path $PSScriptRoot -ChildPath 'build\codecoverage.xml'
            }
            TestResult   = @{
                Enabled    = $true
                OutputPath = Join-Path -Path $PSScriptRoot -ChildPath 'build\nunit.xml'
            }
            Output       = @{
                Verbosity = 'Detailed'
            }
        }
        $testResult = Invoke-Pester -Configuration $configuration

        if ($testResult.FailedCount -gt 0) {
            throw 'One or more tests failed!'
        }
    }
}

function UpdateHelp {
    Start-Job {
        try {
            Import-Module PlatyPS

            $modulePath = Join-Path -Path $using:PSScriptRoot -ChildPath 'build\*\*\*.psd1' | Get-Item | Where-Object {
                $_.BaseName -eq $_.Directory.Parent.Name
            }

            $stubPath = Join-Path -Path $using:PSScriptRoot -ChildPath '*\tests\stub\*.psm1'
            if (Test-Path -Path $stubPath) {
                foreach ($module in $stubPath | Resolve-Path) {
                    Import-Module -Name $module -Global
                }
            }

            $moduleInfo = Import-Module $modulePath.FullName -Global -ErrorAction Stop -PassThru

            $outputPath = Join-Path -Path $using:PSScriptRoot -ChildPath $modulePath.BaseName | Join-Path -ChildPath 'help'
            if (Test-Path -Path $outputPath) {
                Remove-Item -Path $outputPath -Recurse
            }
            $null = New-Item -Path $outputPath -ItemType Directory

            if ($moduleInfo.ExportedCommands.Count -gt 0) {
                $null = New-MarkdownHelp -Module $modulePath.BaseName -Force -OutputFolder $outputPath
            }
        } catch {
            throw
        }
    } | Receive-Job -Wait
}

function Publish {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath 'build\*\*\*.psd1' |
        Get-Item |
        Where-Object { $_.BaseName -eq $_.Directory.Parent.Name } |
        Select-Object -ExpandProperty Directory

    Publish-Module -Path $modulePath.FullName -NuGetApiKey $env:NuGetApiKey -Repository PSGallery -ErrorAction Stop
}

function WriteMessage {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,

        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Category = 'Information',

        [string]$Details
    )

    process {
        $params = @{
            Object          = ('{0}: {1}' -f $Message, $Details).TrimEnd(' :')
            ForegroundColor = switch ($Category) {
                'Information' { 'Cyan' }
                'Warning' { 'Yellow' }
                'Error' { 'Red' }
            }
        }
        Write-Host @params
    }
}

function InvokeTask {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ExecuteFunction')]
        [string]$TaskName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ExecuteScript')]
        [Alias('FullName')]
        [string]$Path
    )

    begin {
        Write-Host ('Build {0}' -f $PSCommandPath) -ForegroundColor Green
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ExecuteScript') {
            $TaskName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        }

        $ErrorActionPreference = 'Stop'
        try {
            $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

            WriteMessage -Message ('Task {0}' -f $TaskName)
            if ($PSCmdlet.ParameterSetName -eq 'ExecuteFunction') {
                & "Script:$TaskName"
            } else {
                & $Path
            }
            WriteMessage -Message ('Done {0} {1}' -f $TaskName, $stopWatch.Elapsed)
        } catch {
            WriteMessage -Message ('Failed {0} {1}' -f $TaskName, $stopWatch.Elapsed) -Category Error -Details $_.Exception.Message

            exit 1
        } finally {
            $stopWatch.Stop()
        }
    }
}

$path = Join-Path -Path $PSScriptRoot -ChildPath 'buildTask'
@(
    $TaskName
    if (-not $ExcludeCustomTasks -and (Test-Path $path)) {
        Get-ChildItem -Path $path
    }
) | Where-Object { -not $BuildConfig -or $BuildConfig['Skip'] -notcontains $_ } | InvokeTask
