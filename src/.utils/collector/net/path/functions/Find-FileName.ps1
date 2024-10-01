function Find-FileName {
    [CmdletBinding()]
    [OutputType('System.String', 'System.String[]')]
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

    if ($Exact) {
        Write-Verbose -Message "$myName Search for exact filename `"$Keyword`" in path `"$Path`"..."
        [string]$filePath   = [System.IO.Path]::Combine($Path, $Keyword)
        if ([System.IO.File]::Exists($filePath)) {
            Write-Verbose -Message "$myName File exists: $filePath"
            return $filePath
        }
        else {
            Write-Verbose -Message "$myName File `"$Keyword`" not found in folder `"$Path`". Returning NULL."
            return
        }
    }
    else {
        [string]$searchPattern  = "*$($Keyword)*"
        Write-Verbose -Message "$myName Searching in directory `"$Path`" for filenames matching to the pattern `"$searchPattern`"..."
        [System.IO.FileInfo[]]$filesFoundObj    = [System.IO.Directory]::EnumerateFiles($Path, $searchPattern)  # Just because PSScriptAnalyzer warns about it:)
        [string[]]$filesFound                   = $filesFoundObj.FullName
        if ($filesFound) {
            Write-Verbose -Message "$myName Found $($filesFound) files matching to the pattern in folder `"$Path`". First 10 matches:"
            $filesFound[0..9].ForEach({
                Write-Verbose -Message "$myName File found: $_"
            })
            Write-Verbose -Message "$myName Returning file path(s):"
            return $filesFound
        }
        else {
            Write-Verbose -Message "$myName The directory `"$Path`" does not contain files with names like `"$Keyword`". Returning NULL."
            return
        }
    }
}