function ConvertTo-Subnet {
    <#
    .SYNOPSIS
        Convert a start and end IP address to the closest matching subnet.

    .DESCRIPTION
        ConvertTo-Subnet attempts to convert a starting and ending IP address from a range to the closest subnet.

    .EXAMPLE
        ConvertTo-Subnet -Start 0.0.0.0 -End 255.255.255.255

        Returns a subnet object describing 0.0.0.0/0.
    .EXAMPLE
        ConvertTo-Subnet -Start 192.168.0.1 -End 192.168.0.129

        Returns a subnet object describing 192.168.0.0/24. The smallest subnet which can encapsulate the start and end range.
    .EXAMPLE
        ConvertTo-Subnet 10.0.0.23/24

        Returns a subnet object describing 10.0.0.0/24.
    .EXAMPLE
        ConvertTo-Subnet 10.0.0.23 255.255.255.0

        Returns a subnet object describing 10.0.0.0/24.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromIPAndMask')]
    [OutputType('Indented.Net.IP.Subnet')]
    param (
        # Any IP address in the subnet.
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromIPAndMask')]
        [string]
        $IPAddress,

        # A subnet mask.
        [Parameter(Position = 2, ParameterSetName = 'FromIPAndMask')]
        [string]
        $SubnetMask,

        # The first IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]
        $Start,

        # The last IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]
        $End
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromIPAndMask') {
        try {
            $network = ConvertToNetwork @PSBoundParameters
            NewSubnet -NetworkAddress (Get-NetworkAddress $network.ToString()) -MaskLength $network.MaskLength
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'FromStartAndEnd') {
        if ($Start -eq $End) {
            $MaskLength = 32
        } else {
            $DecimalStart = ConvertTo-DecimalIP $Start
            $DecimalEnd = ConvertTo-DecimalIP $End

            if ($DecimalEnd -lt $DecimalStart) {
                $Start = $End
            }

            # Find the point the binary representation of each IP address diverges
            $i = 32
            do {
                $i--
            } until (($DecimalStart -band ([UInt32]1 -shl $i)) -ne ($DecimalEnd -band ([UInt32]1 -shl $i)))

            $MaskLength = 32 - $i - 1
        }

        NewSubnet -NetworkAddress (Get-NetworkAddress $Start -SubnetMask $MaskLength) -MaskLength $MaskLength
    }
}
