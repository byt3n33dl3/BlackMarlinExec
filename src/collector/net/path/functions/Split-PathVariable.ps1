#Requires -Assembly 'System.Linq.Enumerable, System.Core, Version=4.0.0.0'
function Split-PathVariable {
    [CmdletBinding()]
    [OutputType('System.String[]')]
    param (
        # Path string
        [Parameter(Mandatory)]
        [string]
        $Path
    )
    [string]$myName = "$($MyInvocation.InvocationName):"
    Write-Verbose   -Message "$myName Starting the function..."

    [string[]]$pathSplitted = $Path.Split([System.IO.Path]::PathSeparator).Where({$_})

    if ($pathSplitted.Count -eq 1) {
        Write-Verbose -Message "$myName Seems like the given string either is not path variable or contains only one path. Anyway returning single member: $($pathSplitted[0])"
        return $pathSplitted[0]
    }

    Write-Verbose -Message "$myName Found $($pathSplitted.Count) strings total. Removing duplicates..."
    [string[]]$pathsToReturn = [System.Linq.Enumerable]::Distinct($pathSplitted)
    Write-Verbose -Message "$myName Found $($pathsToReturn.Count) unique paths. Returning..."
    return $pathsToReturn
}