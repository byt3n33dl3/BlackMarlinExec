function Get-Path {
    <#
    .SYNOPSIS
        The function converts string with delimiter (e.g. environment variable $env:Path) to array of strings.
    .DESCRIPTION
        The function converts string with delimiter (e.g. environment variable $env:Path) to array of strings.
    .EXAMPLE
        PS C:\> Get-Path -Path $env:Path
        Converts environment variable $env:Path to array of strings. Flag "OnlyAvailable" is unset, so the function will return all paths, including absent.
    .EXAMPLE
        PS C:\> Get-Path -Path $env:Path -OnlyAvailable
        Converts environment variable $env:Path to array of strings. Flag "OnlyAvailable" is set by default, so the function will return only existing paths.
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.String[]]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    [OutputType('System.String[]')]
    param (
        # Source path from $env:Path, $env:PSModulePath or from elsewhere like $env:SMS_ADMIN_UI_PATH. Default is $env:Path.
        [Parameter(HelpMessage="Source path from env:Path, env:PSModulePath or from elsewhere like env:SMS_ADMIN_UI_PATH. Default is env:Path.")]
        [string]
        $Path = $env:Path,

        # Returns only available paths if checked..
        [Parameter()]
        [switch]
        $OnlyAvailable
    )

    [string]$myName         = "$($MyInvocation.InvocationName):"
    Write-Verbose -Message "$myName Starting the function..."

    [string[]]$pathSplitted   = Split-PathVariable -Path $Path
    if (-not $pathSplitted) {
        Write-Warning -Message "$myName The given path `"$Path`" is empty or invalid! Exiting."
        return
    }

    if (-not $OnlyAvailable) {
        Write-Verbose -Message "$myName Returning all $($pathSplitted.Count) paths found. Some of them may not exist."
        return $pathSplitted
    }

    [string[]]$pathsExisting    = $pathSplitted.Where({
        [System.IO.Directory]::Exists($_)
    })
    if (-not $pathsExisting) {
        Write-Warning -Message "$myName Seems like no one of paths found does not exist! Nothing to return!"
        return
    }

    Write-Verbose -Message "$myName Found $($pathsExisting.Count) existing paths. Returning."
    return $pathsExisting
}
