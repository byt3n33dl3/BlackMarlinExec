Describe 'ConvertTo-Mask' {
    It 'Returns an IPAddress' {
        ConvertTo-Mask 1 | Should -BeOfType [IPAddress]
    }

    It 'Converts 0 to 0.0.0.0' {
        ConvertTo-Mask 0 | Should -Be '0.0.0.0'
    }

    It 'Converts 24 to 255.255.255.0' {
        ConvertTo-Mask 24 | Should -Be '255.255.255.0'
    }

    It 'Converts 9 to 255.128.0.0' {
        ConvertTo-Mask 9 | Should -Be '255.128.0.0'
    }

    It 'Converts 32 to 255.255.255.255' {
        ConvertTo-Mask 32 | Should -Be '255.255.255.255'
    }

    It 'Accepts pipeline input' {
        1 | ConvertTo-Mask | Should -Be '128.0.0.0'
    }

    It 'Throws an error if passed an invalid value' {
        { ConvertTo-Mask 33 -ErrorAction Stop } | Should -Throw
    }
}
