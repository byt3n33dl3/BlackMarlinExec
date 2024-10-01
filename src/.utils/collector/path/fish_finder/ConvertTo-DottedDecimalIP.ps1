using namespace System.Management.Automation

function ConvertTo-DottedDecimalIP {
    <#
    .SYNOPSIS
        Converts either an unsigned 32-bit integer or a dotted binary string to an IP Address.

    .DESCRIPTION
         ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.

    .INPUTS
        System.String

    .EXAMPLE
        ConvertTo-DottedDecimalIP 11000000.10101000.00000000.00000001

        Convert the binary form back to dotted decimal, resulting in 192.168.0.1.

    .EXAMPLE
        ConvertTo-DottedDecimalIP 3232235521

        Convert the decimal form back to dotted decimal, resulting in 192.168.0.1.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # A string representation of an IP address from either UInt32 or dotted binary.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]
        $IPAddress
    )

    process {
        try {
            [long]$value = 0
            if ([long]::TryParse($IPAddress, [ref]$value)) {
                return [IPAddress]([IPAddress]::NetworkToHostOrder([long]$value) -shr 32 -band [UInt32]::MaxValue)
            } else {
                [IPAddress][UInt64][Convert]::ToUInt32($IPAddress.Replace('.', ''), 2)
            }
        } catch {
            $errorRecord = [ErrorRecord]::new(
                [ArgumentException]'Cannot convert this format.',
                'UnrecognisedFormat',
                'InvalidArgument',
                $IPAddress
            )
            Write-Error -ErrorRecord $errorRecord
        }
    }
}
