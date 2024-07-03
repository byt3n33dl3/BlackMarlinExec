[hashtable]$moduleStructure = @{
    Private = "$($PSScriptRoot)\Functions\Private"
    Public  = "$($PSScriptRoot)\Functions\Public"
}

#   Importing classes before all
[string]$psClassesPath  = "$($PSScriptRoot)\Classes"
if ([System.IO.Directory]::Exists($psClassesPath)) {
    [System.IO.FileInfo[]]$psClassesScripts = [System.IO.Directory]::EnumerateFiles($psClassesPath, '*.ps1', 'AllDirectories')
    Write-Verbose -Message "Found $($psClassesScripts.Count) custom PowerShell classes..."
    $psClassesScripts.ForEach({
        [string]$psClassPath    = $_.FullName
        [string]$psClassName    = $_.BaseName
        Write-Verbose -Message "Importing custom class `"$($psClassName)`" from script: $($psClassPath)"
        .   $psClassPath
    })
}

#   Importing functions
$moduleStructure.Keys.ForEach({
    [string]$psFunctionType     = $_.ToLowerInvariant()
    [string]$psFunctionFolder   = $moduleStructure.$psFunctionType
    if ([System.IO.Directory]::Exists($psFunctionFolder)) {
        [System.IO.FileInfo[]]$psFunctionsAll   = [System.IO.Directory]::EnumerateFiles($psFunctionFolder, '*.ps1', 'AllDirectories')
        Write-Verbose -Message "Found $($psFunctionsAll.Count) $($psFunctionType) functions."
        $psFunctionsAll.ForEach({
            [string]$psFunctionName = $_.BaseName
            [string]$psFunctionPath = $_.FullName
            Write-Verbose -Message "Importing $($psFunctionType) function `"$($psFunctionName)`" from script: $($psFunctionPath)"
            .   $psFunctionPath

            if ($psFunctionType -eq 'Public') {
                Write-Verbose -Message "Exporting $($psFunctionType) function `"$($psFunctionName)`"."
                Export-ModuleMember -Function $psFunctionName 
                Write-Verbose -Message "Trying to get aliases for the function `"$($psFunctionName)`"..."
                try {
                    [System.Management.Automation.AliasInfo[]]$psAliasInfo = Get-Alias -Definition $psFunctionName -ErrorAction Stop
                    [string[]]$psAliases    = $psAliasInfo.Name
                    $psAliases.ForEach({
                        [string]$psAliasName    = $_
                        Write-Verbose -Message "Exporting alias `"$($psAliasName)`" for the function: $($psFunctionName)"
                        Export-ModuleMember -Alias $psAliasName
                    })
                }
                catch {
                    Write-Verbose -Message "The function has no aliases: $($psFunctionName)"
                }
            }
        })
    }
})