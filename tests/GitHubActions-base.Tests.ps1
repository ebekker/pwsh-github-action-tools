
Import-Module Pester

Import-Module $PSScriptRoot/../GitHubActions

if (-not (Get-Variable -Scope script -Name EOL -ErrorAction Ignore)) {
    $script:EOL = [System.Environment]::NewLine
}

BeforeAll {
    . $PSScriptRoot/test-helpers.ps1
}

## TODO: Can't test these by inspecting output anymore, now they write to a file
# Describe 'Set-ActionVariable' {
#     $testCases = @(
#         @{ Name = 'varName1'  ; Value = 'varValue1' }
#         @{ Name = 'var name 2'; Value = 'var value 2' }
#         @{ Name = 'var,name;3'; Value = 'var,value;3'
#             Expected = "::set-env name=var%2Cname%3B3::var,value;3$EOL" }
#     )
#     It 'Given valid -Name and -Value, and -SkipLocal' -TestCases $testCases {
#         param($Name, $Value, $Expected)

#         if (-not $Expected) {
#             $Expected = "::set-env name=$($Name)::$($Value)$EOL"
#         }
        
#         $output = Set-ActionVariable $Name $Value -SkipLocal
#         $output | Should -Be $Expected
#         [System.Environment]::GetEnvironmentVariable($Name) | Should -BeNullOrEmpty
#     }
#     It 'Given valid -Name and -Value, and NOT -SkipLocal' -TestCases $testCases {
#         param($Name, $Value, $Expected)

#         if (-not $Expected) {
#             $Expected = "::set-env name=$($Name)::$($Value)$EOL"
#         }
        
#         Set-ActionVariable $Name $Value | Should -Be $Expected
#         [System.Environment]::GetEnvironmentVariable($Name) | Should -Be $Value
#     }
# }

Describe 'Add-ActionSecretMask' {
    It 'Given a valid -Secret' {
        $secret = 'f00B@r!'
        Add-ActionSecretMask $secret | Should -Be "::add-mask::$($secret)$EOL"
    }
}

## TODO: Can't test these by inspecting output anymore, now they write to a file
# Describe 'Add-ActionPath' {
#     It 'Given a valid -Path and -SkipLocal' {
#         $addPath = '/to/some/path'
#         $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
#         Add-ActionPath $addPath -SkipLocal | Should -Be "::add-path::$($addPath)$EOL"
#         [System.Environment]::GetEnvironmentVariable('PATH') | Should -Be $oldPath
#     }

#     It 'Given a valid -Path and NOT -SkipLocal' {
#         $addPath = '/to/some/path'
#         $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
#         $newPath = "$($addPath)$([System.IO.Path]::PathSeparator)$($oldPath)"
#         Add-ActionPath $addPath | Should -Be "::add-path::$($addPath)$EOL"
#         [System.Environment]::GetEnvironmentVariable('PATH') | Should -Be $newPath
#     }
# }

Describe 'Get-ActionInput' {
    [System.Environment]::SetEnvironmentVariable('INPUT_INPUT1', 'Value 1')
    [System.Environment]::SetEnvironmentVariable('INPUT_INPUT3', 'Value 3')

    $testCases = @(
        @{ Name = 'input1' ; Should = @{ Be = $true; ExpectedValue = 'Value 1' } }
        @{ Name = 'INPUT1' ; Should = @{ Be = $true; ExpectedValue = 'Value 1' } }
        @{ Name = 'Input1' ; Should = @{ Be = $true; ExpectedValue = 'Value 1' } }
        @{ Name = 'input2' ; Should = @{ BeNullOrEmpty = $true } }
        @{ Name = 'INPUT2' ; Should = @{ BeNullOrEmpty = $true } }
        @{ Name = 'Input2' ; Should = @{ BeNullOrEmpty = $true } }
    )

    It 'Given valid -Name' -TestCases $testCases {
        param($Name, $Should)

        Get-ActionInput $Name | Should @Should
        Get-ActionInput $Name | Should @Should
        Get-ActionInput $Name | Should @Should
        Get-ActionInput $Name | Should @Should
        Get-ActionInput $Name | Should @Should
        Get-ActionInput $Name | Should @Should
    }
}

Describe 'Get-ActionInputs' {
    [System.Environment]::SetEnvironmentVariable('INPUT_INPUT1', 'Value 1')
    [System.Environment]::SetEnvironmentVariable('INPUT_INPUT3', 'Value 3')

    $testCases = @(
        @{ Name = 'InPut1' ; Should = @{ Be = $true; ExpectedValue = "Value 1" } }
        @{ Name = 'InPut2' ; Should = @{ BeNullOrEmpty = $true } }
        @{ Name = 'InPut3' ; Should = @{ Be = $true; ExpectedValue = "Value 3" } }
    )
    It 'Given 2 predefined inputs' {
        $inputs = Get-ActionInputs
        $inputs.Count | Should -Be 2
    }

    It 'Given 2 predefined inputs, and a -Name in any case' -TestCases $testCases {
        param($Name, $Should)

        $inputs = Get-ActionInputs

        $key = $Name
        $inputs[$key] | Should @Should
        $inputs.$key | Should @Should
        $key = $Name.ToUpper()
        $inputs[$key] | Should @Should
        $inputs.$key | Should @Should
        $key = $Name.ToLower()
        $inputs[$key] | Should @Should
        $inputs.$key | Should @Should
    }
}

Describe 'Set-ActionOutput' {
    It 'Given a valid -Name and -Value' {
        Set-ActionOutput 'foo_bar' 'foo bar value'
        $env:GITHUB_OUTPUT | Should -FileContentMatch "foo_bar=foo bar value"
    }
}

Describe 'Write-ActionDebug' {
    It 'Given a valid -Message' {
        $output = Write-ActionDebug 'This is a sample message'
        $output | Should -Be "::debug::This is a sample message$EOL"
    }
}

Describe 'Write-ActionError' {
    It 'Given a valid -Message' {
        $output = Write-ActionError 'This is a sample message'
        $output | Should -Be "::error::This is a sample message$EOL"
    }
    It 'Given file details' {
        $output = Write-ActionError 'Sample message with file' -File 'sample.txt' -Line 10 -Col 5
        $output | Should -Be "::error file=sample.txt,line=10,col=5::Sample message with file$EOL"
    }
}

Describe 'Write-ActionWarning' {
    It 'Given a valid -Message' {
        $output = Write-ActionWarning 'This is a sample message'
        $output | Should -Be "::warning::This is a sample message$EOL"
    }
    It 'Given file details' {
        $output = Write-ActionWarning 'Sample message with file' -File 'sample.txt' -Line 10 -Col 5
        $output | Should -Be "::warning file=sample.txt,line=10,col=5::Sample message with file$EOL"
    }
}

Describe 'Write-ActionInfo' {
    It 'Given a valid -Message' {
        $output = Write-ActionInfo 'This is a sample message'
        $output | Should -Be "This is a sample message$EOL"
    }
}

Describe 'Set-ActionFailed' {
    It 'Given a valid -Message' {
        $output =  pwsh -c "ipmo $PSScriptRoot/../GitHubActions; Set-ActionFailed 'failed message'"
        $output[0] | Should -Be "::error::failed message"
        $LASTEXITCODE | Should -Be 1
    }
}

Describe 'Enter-ActionOutputGroup' {
    It 'Given a valid -Name' {
        $output = Enter-ActionOutputGroup 'Sample Group'
        $output | Should -Be "::group::Sample Group$EOL"
    }
}

Describe 'Exit-ActionOutputGroup' {
    It 'Given everything is peachy' {
        $output = Exit-ActionOutputGroup
        $output | Should -Be "::endgroup::$EOL"
    }
}

Describe 'Invoke-ActionWithinOutputGroup' {
    It 'Given a valid -Name and -ScriptBlock' {
        $output = Invoke-ActionWithinOutputGroup 'Sample Group' {
            Write-ActionInfo "Message 1"
            Write-ActionInfo "Message 2"
        }

        $output | Should -Be @(
            "::group::Sample Group$EOL"
            "Message 1$EOL"
            "Message 2$EOL"
            "::endgroup::$EOL"
        )
    }
}
