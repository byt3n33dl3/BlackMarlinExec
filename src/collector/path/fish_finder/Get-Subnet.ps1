using namespace System.Collections.Generic

function Get-Subnet {
    <#
    .SYNOPSIS
        Get a list of subnets of a given size within a defined supernet.

    .DESCRIPTION
        Generates a list of subnets for a given network range using either the address class or a user-specified value.

    .EXAMPLE
        Get-Subnet 10.0.0.0 255.255.255.0 -NewSubnetMask 255.255.255.192

        Four /26 networks are returned.

    .EXAMPLE
        Get-Subnet 0/22 -NewSubnetMask 24

        64 /24 networks are returned.

    .EXAMPLE
        Get-Subnet -Start 10.0.0.1 -End 10.0.0.16

        Get the largest possible subnets between the start and end address.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectUsageOfAssignmentOperator', '')]
    [CmdletBinding(DefaultParameterSetName = 'FromSupernet')]
    [OutputType('Indented.Net.IP.Subnet')]
    param (
        # Any address in the super-net range. Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromSupernet')]
        [string]
        $IPAddress,

        # The subnet mask of the network to split. Mandatory if the subnet mask is not included in the IPAddress parameter.
        [Parameter(Position = 2, ParameterSetName = 'FromSupernet')]
        [string]
        $SubnetMask,

        # Split the existing network described by the IPAddress and subnet mask using this mask.
        [Parameter(Mandatory, ParameterSetName = 'FromSupernet')]
        [string]
        $NewSubnetMask,

        # The first IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]
        $Start,

        # The last IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]
        $End
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromSupernet') {
        $null = $PSBoundParameters.Remove('NewSubnetMask')
        try {
            $network = ConvertToNetwork @PSBoundParameters
            $newNetwork = ConvertToNetwork 0 $NewSubnetMask
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        if ($network.MaskLength -gt $newNetwork.MaskLength) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]'The subnet mask of the new network is shorter (masks fewer addresses) than the subnet mask of the existing network.',
                'NewSubnetMaskTooShort',
                'InvalidArgument',
                $newNetwork.MaskLength
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $numberOfNets = [Math]::Pow(2, ($newNetwork.MaskLength - $network.MaskLength))
        $numberOfAddresses = [Math]::Pow(2, (32 - $newNetwork.MaskLength))

        $decimalAddress = ConvertTo-DecimalIP (Get-NetworkAddress $network.ToString())
        for ($i = 0; $i -lt $numberOfNets; $i++) {
            $networkAddress = ConvertTo-DottedDecimalIP $decimalAddress

            NewSubnet -NetworkAddress $networkAddress -MaskLength $newNetwork.MaskLength

            $decimalAddress += $numberOfAddresses
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'FromStartAndEnd') {
        $range = @{ Start = ConvertTo-DecimalIP $Start; End = ConvertTo-DecimalIP $End; Type = 'Whole' }
        if ($range['Start'] -gt $range['End']) {
            # Could just swap them, but it implies a problem with the request
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]'The end address in the range falls before the start address.',
                'InvalidNetworkRange',
                'InvalidArgument',
                $range
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $inputQueue = [Queue[object]]::new()
        $inputQueue.Enqueue($range)

        # Find an initial maximum number of host bits. Reduces work in the main loops.
        $maximumHostBits = 32
        do {
            $maximumHostBits--
        } until (($range['Start'] -band ([UInt32]1 -shl $maximumHostBits)) -ne ($range['End'] -band ([UInt32]1 -shl $maximumHostBits)))
        $maximumHostBits++

        # Guards against infinite loops when I've done something wrong
        $maximumIterations = 200
        $iteration = 0

        $subnets = do {
            $range =  $inputQueue.Dequeue()
            $rangeSize = $range['End'] - $range['Start'] + 1

            if ($rangeSize -eq 1) {
                NewSubnet -NetworkAddress $range['Start'] -BroadcastAddress $range['End']
                continue
            }
            $subnetStart = $subnetEnd = $null
            for ($hostBits = $maximumHostBits; $hostBits -gt 0; $hostBits--) {
                $subnetSize = [Math]::Pow(2, $hostBits)

                if ($subnetSize -le $rangeSize) {
                    if ($remainder = $range['Start'] % $subnetSize) {
                        $subnetStart = $range['Start'] - $remainder + $subnetSize
                    } else {
                        $subnetStart = $range['Start']
                    }
                    $subnetEnd = $subnetStart + $subnetSize - 1

                    if ($subnetEnd -gt $range['End']) {
                        continue
                    }

                    NewSubnet -NetworkAddress $subnetStart -BroadcastAddress $subnetEnd -MaskLength (32 - $hostBits)
                    break
                }
            }
            if ($subnetStart -and $subnetStart -gt $range['Start']) {
                $inputQueue.Enqueue(@{ Start = $range['Start']; End = $subnetStart - 1; Type = 'Start' } )
            }
            if ($subnetEnd -and $subnetEnd -lt $range['End']) {
                $inputQueue.Enqueue(@{ Start = $subnetEnd + 1; End = $range['End']; Type = 'End' })
            }
            $iteration++
        } while ($inputQueue.Count -and $iteration -lt $maximumIterations)

        if ($iteration -ge $maximumIterations) {
            Write-Warning 'Exceeded the maximum number of iterations while generating subnets.'
        }

        $subnets | Sort-Object { [Version]$_.NetworkAddress.ToString() }
    }
}
