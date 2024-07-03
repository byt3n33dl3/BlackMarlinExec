Describe PSScriptAnalyzer {
    BeforeDiscovery {
        $moduleRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.IndexOf('{0}tests' -f [System.IO.Path]::DirectorySeparatorChar))
        $projectRoot = $moduleRoot | Split-Path -Parent
        $settings = Join-Path $projectRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'

        $rules = Get-ChildItem -Path $moduleRoot -File -Recurse -Include *.ps1 -Exclude *.tests.ps1 |
            ForEach-Object {
                Invoke-ScriptAnalyzer -Path $_.FullName -Settings $settings
            } |
            Where-Object RuleName -NE 'TypeNotFound' |
            ForEach-Object {
                @{
                    Rule = [PSCustomObject]@{
                        RuleName   = $_.RuleName
                        Message    = $_.Message -replace '(.{1,100})(?:\s|$)', "`n        `$1" -replace '^\n        '
                        ScriptName = $_.ScriptName
                        Line       = $_.Line
                        ScriptPath = $_.ScriptPath
                    }
                }
            }
    }

    It (
        @(
            '<rule.RuleName>'
            '        <rule.Message>'
            '    in <rule.ScriptName> line <rule.Line>'
        ) | Out-String
    ) -TestCases $rules {
        $rule.ScriptPath | Should -BeNullOrEmpty
    }
}
