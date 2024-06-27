function Find-FolderName {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # String: folder path
        [Parameter(Mandatory)]
        [string]
        $Path,

        # String: keyword for search
        [Parameter()]
        [string]
        $Keyword,

        # Switch: exact matches
        [Parameter()]
        [switch]
        $Exact
    )
    [string]$myName         = "$($MyInvocation.InvocationName):"
    Write-Verbose -Message "$myName Starting the function..."

    if (-not [System.IO.Directory]::Exists($Path)) {
        Write-Warning -Message "$myName The directory does not exist: $Path"
        return
    }
    [char[]]$dirSeparators  = @(
        [System.IO.Path]::DirectorySeparatorChar
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    [string[]]$pathSplitted = $Path.Split($dirSeparators).Where({
        (-not [string]::IsNullOrEmpty($_))  -and `
        (-not [string]::IsNullOrWhiteSpace($_)) -and `
        -not $_.EndsWith([System.IO.Path]::VolumeSeparatorChar)
    })

    if (-not $pathSplitted) {
        Write-Warning -Message "$myName Seems like the given path contains only root! Root paths does not included in the search scope. Returning NULL."
        return
    }

    Write-Verbose -Message "$myName The given path contains $($pathSplitted.Count) segments including root."
    if ($Exact) {
        Write-Verbose -Message "$myName Searching for directories with name `"$Keyword`" in the $($pathSplitted.Count) paths..."
        [bool]$pathIsMatch  = $pathSplitted.Contains($Keyword)
    }
    else {
        Write-Verbose -Message "$myName Searching for matches to the keyword `"$Keyword`" in the $($pathSplitted.Count) paths..."
        [bool]$pathIsMatch  = $null -ne [regex]::Matches($pathSplitted, $Keyword).Success
    }

    if (-not $pathIsMatch) {
        Write-Verbose -Message "$myName Given path `"$Path`" does not match the keyword `"$Keyword`". Returning NULL."
        return
    }

    Write-Verbose -Message "$myName Given path `"$Path`" does match the keyword `"$Keyword`". Returning."
    return $Path
}