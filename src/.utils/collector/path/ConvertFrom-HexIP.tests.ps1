Describe 'ConvertFrom-HexIP' {
    It 'Returns an IPAddress' {
        ConvertFrom-HexIP '12345678' | Should -BeOfType [IPAddress]
    }

    It 'Converts 30201000 to 48.32.16.0' {
        ConvertFrom-HexIP '30201000' | Should -Be '48.32.16.0'
    }

    It 'Converts 00000000 to 0.0.0.0' {
        ConvertFrom-HexIP '00000000' | Should -Be '0.0.0.0'
    }

    It 'Converts FFFFFFFF to 255.255.255.255' {
        ConvertFrom-HexIP 'FFFFFFFF' | Should -Be '255.255.255.255'
    }

    It 'Converts "0xFFFFFFFF" to 255.255.255.255' {
        ConvertFrom-HexIP '0xFFFFFFFF' | Should -Be '255.255.255.255'
    }

    It 'Accepts pipeline input' {
        '00FF00FF' | ConvertFrom-HexIP | Should -Be '0.255.0.255'
    }

    It 'Throws an error if the input format is not valid' {
        { ConvertFrom-HexIP '1GFFFFFF' } | Should -Throw
    }
}
