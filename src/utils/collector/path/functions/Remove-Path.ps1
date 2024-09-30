function Remove-Path {
    <#
    .SYNOPSIS
        Removes path from environment variable.
    .DESCRIPTION
        Removes path from environment variable.
    .EXAMPLE
        PS C:\> Remove-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path
        Removes path "C:\Path\Does\Not\Exists" from environment variable $env:Path and return string.
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.String]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # Path to remove
        [Parameter(
            Mandatory   = $true,
            HelpMessage = "Path to remove"
        )]
        [string]
        $Path,

        # Scope. Default is $env:Path
        [Parameter()]
        [string]
        $Scope = $env:Path
    )
    [string]$myName             = "$($MyInvocation.InvocationName):"
    Write-Verbose -Message "$myName Starting the function..."

    [string[]]$pathSplitted     = Split-PathVariable -Path $Scope
    [string]$pathToReturn   = [string]::Join([System.IO.Path]::PathSeparator, $pathSplitted)

    Write-Verbose -Message "$myName Getting the full path..."
    [string]$Path           = [System.IO.Path]::GetFullPath($Path)

    if (-not $pathSplitted.Contains($Path)) {
        Write-Verbose -Message "$myName The given path `"$pathToReturn`" does not contain substring `"$Path`". Nothing to do!"
        return $pathToReturn
    }

    Write-Verbose -Message "$myName Excluding substring `"$Path`" from the given path `"$pathToReturn`"..."
    $pathSplitted           = $pathSplitted -ne $Path
    [string]$pathToReturn   = [string]::Join([System.IO.Path]::PathSeparator, $pathSplitted)
    Write-Verbose -Message "$myName Returning result: $pathToReturn"
    return $pathToReturn
}
