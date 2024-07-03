function Add-Path {
    <#
    .SYNOPSIS
        Adds path to environment. Returns string.
    .DESCRIPTION
        Adds path to environment. Returns string.
    .EXAMPLE
        PS C:\> Add-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path
        Adds path "C:\Path\Does\Not\Exists" to environment variable $env:Path, if path "C:\Path\Does\Not\Exists" exists.
    .EXAMPLE
        PS C:\> Add-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path -OnlyIfExists:$false
        Adds path "C:\Path\Does\Not\Exists" to environment variable $env:Path, even if path "C:\Path\Does\Not\Exists" does NOT exists.
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
        # Path to add
        [Parameter(Mandatory=$true,HelpMessage="Path to add")]
        [string]
        $Path,

        # Scope. Default is $env:Path.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Scope = $env:Path,

        # Do not test path before addition.
        [Parameter()]
        [switch]
        $SkipCheck
    )
    [string]$myName             = "$($MyInvocation.InvocationName):"
    Write-Verbose -Message "$myName Starting the function..."

    [string[]]$pathSplitted     = Split-PathVariable -Path $Scope
    [string]$pathToReturn   = [string]::Join([System.IO.Path]::PathSeparator, $pathSplitted)

    Write-Verbose -Message "$myName Getting the full path..."
    [string]$Path           = [System.IO.Path]::GetFullPath($Path)

    switch ($true) {
        $SkipCheck                                  {
            Write-Warning -Message "$myName The function will not check the path if it does not exist or is the path to a file, or just incorrect path!"
            [string]$pathToAdd  = $Path
        }
        { [System.IO.Directory]::Exists($Path) }    {
            Write-Verbose -Message "$myName The directory `"$Path`" exists. Adding."
            [string]$pathToAdd  = $Path
        }
        { [System.IO.File]::Exists($Path) }         {
            Write-Verbose -Message "$myName The given path `"$Path`" is a filepath! Getting directory name..."
            [string]$pathToAdd  = [System.IO.Path]::GetDirectoryName($Path)
            Write-Verbose -Message "$myName The directory name resolved: `"$pathToAdd`"."
        }
        Default                                     {
            Write-Verbose -Message "$myName The given path `"$Path`" does not exist! Exiting."
            return $pathToReturn
        }
    }

    if ($pathSplitted.Contains($pathToAdd)) {
        Write-Verbose -Message "$myName Given path `"$pathToReturn`" already contains substring `"$pathToAdd`". Nothing to do!"
        return $pathToReturn
    }

    $pathSplitted           = $pathSplitted += $Path
    [string]$pathToReturn   = [string]::Join([System.IO.Path]::PathSeparator, $pathSplitted)
    Write-Verbose -Message "$myName The substring `"$Path`" successfully added to the path `"$Scope`". Returning result: $pathToReturn"
    return $pathToReturn
}
