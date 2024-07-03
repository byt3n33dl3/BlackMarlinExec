Describe 'ConvertTo-HexIP' {
    It 'Returns a string' {
        ConvertTo-HexIP 1.2.3.4 | Should -BeOfType [String]
    }

    It 'Converts 0.0.0.0 to 00000000' {
        ConvertTo-HexIP 0.0.0.0 | Should -Be '00000000'
    }

    It 'Converts 255.255.255.255 to FFFFFFFF' {
        ConvertTo-HexIP 255.255.255.255 | Should -Be 'FFFFFFFF'
    }

    It 'Converts 1.2.3.4 to 01020304' {
        ConvertTo-HexIP 1.2.3.4 | Should -Be '01020304'
    }

    It 'Accepts pipeline input' {
        '1.2.3.4' | ConvertTo-HexIP | Should -Be '01020304'
    }

    It 'Throws an error if passed an unrecognised format' {
        { ConvertTo-HexIP abcd -ErrorAction Stop } | Should -Throw
    }
}
