Describe 'Get-Subnet' {
    It 'Returns an object tagged with the type Indented.Net.IP.Subnet' {
        $Subnets = Get-Subnet 0/24 -NewSubnetMask 25
        $Subnets[0].PSTypeNames | Should -Contain 'Indented.Net.IP.Subnet'
    }

    It 'Creates two /26 subnets from 10/25' {
        $Subnets = Get-Subnet 10/25 -NewSubnetMask 26
        $Subnets[0].NetworkAddress | Should -Be '10.0.0.0'
        $Subnets[1].NetworkAddress | Should -Be '10.0.0.64'
    }

    It 'Handles both subnet mask and mask length formats for NewSubnetMask' {
        $Subnets = Get-Subnet 10/24 -NewSubnetMask 26
        $Subnets.Count | Should -Be 4

        $Subnets = Get-Subnet 10/24 -NewSubnetMask 255.255.255.192
        $Subnets.Count | Should -Be 4
    }

    It 'Throws an error if requested to subnet a smaller network into a larger one' {
        { Get-Subnet 0/24 -NetSubnetMask 23 } | Should -Throw
    }

    It 'Generates maximum sized subnets for a range starting <Start> and ending <End>' -TestCases @(
        @{ Start = '10.0.0.0'; End = '10.0.0.15'; Expects = '10.0.0.0/28' }
        @{ Start = '10.0.0.1'; End = '10.0.0.16'; Expects = @('10.0.0.1/32', '10.0.0.2/31', '10.0.0.4/30', '10.0.0.8/29', '10.0.0.16/32') }
        @{ Start = '10.0.0.1'; End = '10.0.0.151'; Expects = @('10.0.0.1/32', '10.0.0.2/31', '10.0.0.4/30', '10.0.0.8/29', '10.0.0.16/28', '10.0.0.32/27', '10.0.0.64/26', '10.0.0.128/28', '10.0.0.144/29') }
    ) {
        Get-Subnet -Start $Start -End $End | Should -Be $Expects
    }
}
