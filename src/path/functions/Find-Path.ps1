function Find-Path {
    <#
    .SYNOPSIS
        The function finds path by keyword.
    .DESCRIPTION
        The function finds path by keyword.
    .EXAMPLE
        PS C:\> Find-Path -Keyword putty -Path $env:Path
        Returns from environment variable $env:Path path with keyword "putty":
        PS C:\> C:\Program Files\PuTTY\
    .EXAMPLE
        PS C:\> Find-Path -Keyword pageant -Path $env:Path -InContent
        Function will get paths from $env:Path and will search for files with keyword "pageant", then will return paths to folders where the files are present:
        PS C:\> C:\Program Files\PuTTY\
        PS C:\> C:\Program Files\Git\cmd
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
        # Search string
        [Parameter(
            Mandatory   = $true,
            HelpMessage = "Keyword for search, mandatory parameter"
        )]
        [string]
        $Keyword,

        # Path to search, default is $env:Path
        [Parameter()]
        [string]
        $Path = $env:Path,

        # If set, will search for matches in filenames in path folders.
        [Parameter()]
        [Alias('InContent')]
        [switch]
        $FileName,

        # If set, will search for exact matches in folder names or, if the switch "-FileName" is set, for existing files with exact names.
        [Parameter()]
        [switch]
        $Exact
    )

    [string]$myName             = "$($MyInvocation.InvocationName):"
    Write-Verbose -Message "$myName Starting the function..."

    [string[]]$pathSplitted     = Split-PathVariable -Path $Path
    if (-not $pathSplitted) {
        Write-Warning -Message "$myName The given path `"$Path`" is empty or invalid! Exiting."
        return
    }

    if (-not $FileName) {
        [string[]]$pathsMatching    = $pathSplitted.ForEach({
            Find-FolderName -Path $_ -Keyword $Keyword -Exact:$Exact
        }).Where({$_})
    }
    else {
        [string[]]$pathsMatching    = $pathSplitted.ForEach({
            Find-FileName   -Path $_ -Keyword $Keyword -Exact:$Exact
        }).Where({$_})
    }

    if (-not $pathsMatching) {
        Write-Verbose -Message "$myName The path matching to the keyword `"$Keyword`"not found! Exiting."
        return
    }

    Write-Verbose -Message "$myName Found $($pathsMatching.Count) path(s) matching to the keyword `"$Keyword`". Returning:"
    return $pathsMatching
}
