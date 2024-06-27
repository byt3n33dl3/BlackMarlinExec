Describe 'Get-NetworkRange' {
    It 'Returns an array of IPAddress' {
        Get-NetworkRange 1.2.3.4/32 -IncludeNetworkAndBroadcast | Should -BeOfType [IPAddress]
    }

    It 'Returns 255.255.255.255 when passed 255.255.255.255/32' {
        $Range = Get-NetworkRange 0/30
        $Range -contains '0.0.0.1' | Should -BeTrue
        $Range -contains '0.0.0.2' | Should -BeTrue

        $Range = Get-NetworkRange 0.0.0.0/30
        $Range -contains '0.0.0.1' | Should -BeTrue
        $Range -contains '0.0.0.2' | Should -BeTrue

        $Range = Get-NetworkRange 0.0.0.0 255.255.255.252
        $Range -contains '0.0.0.1' | Should -BeTrue
        $Range -contains '0.0.0.2' | Should -BeTrue
    }

    It 'Accepts pipeline input' {
        '20/24' | Get-NetworkRange | Select-Object -First 1 | Should -Be '20.0.0.1'
    }

    It 'Throws an error if passed something other than an IPAddress' {
        { Get-NetworkRange 'abcd' } | Should -Throw
    }

    It 'Returns correct values when used with Start and End parameters' {
        $StartIP = [IPAddress]'192.168.1.1'
        $EndIP = [IPAddress]'192.168.2.10'
        $Assertion = Get-NetworkRange -Start $StartIP -End $EndIP

        $Assertion.Count | Should -BeExactly 266
        $Assertion[0].IPAddressToString | Should -Be '192.168.1.1'
        $Assertion[-1].IPAddressToString | Should -Be '192.168.2.10'
    }
}
