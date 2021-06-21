BeforeAll {
    & $PSScriptRoot\..\..\..\Modules\Import-SemVerPS.ps1
    . $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1

    $versions=@(
        "1.0.0"
        "1.0.1-alpha"
        "1.0.1-alpha+1"
        "1.0.1-beta"
        "1.0.1-beta+1"
        "1.0.1"
    )
    $expectedStable=@(
        "1.0.0"
        "1.0.1"
    )
    $expectedBeta=@(
        "1.0.1-beta"
        "1.0.1-beta+1"
    )
}


Describe -Tag @("SemVer","Module","String") "String Versions" {
    It "ConvertTo-SemVer" {
        $SemVers=$versions|ConvertTo-SemVer
        $SemVers.Count | Should -BeExactly $versions.Count
        $SemVers|ForEach-Object {$_.ToString()} | Should -Be $versions
    }
    It "Test-SemVer -Stable" {
        $stable=$versions|Test-SemVer -Stable
        ($stable|Where-Object {$_}).Count | Should -BeExactly $expectedStable.Count
    }
    It "Test-SemVer -Prerelease" {
        $beta=$versions|Test-SemVer -Prerelease beta
        ($beta|Where-Object {$_}).Count | Should -BeExactly $expectedBeta.Count
    }
    It "Limit-SemVer -Stable" {
        $stable=$versions|Limit-SemVer -Stable
        $stable.Count | Should -BeExactly $expectedStable.Count
        $stable|ForEach-Object {$_.ToString()} | Should -Be $expectedStable
    }
    It "Limit-SemVer -Prerelease" {
        $beta=$versions|Limit-SemVer -Prerelease beta
        $beta.Count | Should -BeExactly $expectedBeta.Count
        $beta|ForEach-Object {$_.ToString()} | Should -Be $expectedBeta
    }
}

Describe -Tag @("SemVer","Module","Object") "Enhanced Objects" {
    BeforeAll {
        $items=$versions|ForEach-Object {
            [pscustomobject]@{
                Name="item-"+$_
            }
        }
    }
    It "Add-SemVerMember -Expression" {
        $items|Add-SemVerMember -Expression 'Name.Replace("item-","")'
        $items|Select-Object -ExpandProperty SemVer|ForEach-Object {$_.ToString()} | Should -Be $versions
    }
    It "Test-SemVer -Stable" {
        $stable=$items|Test-SemVer -Stable
        ($stable|Where-Object {$_}).Count | Should -BeExactly $expectedStable.Count
    }
    It "Test-SemVer -Prerelease" {
        $beta=$items|Test-SemVer -Prerelease beta
        ($beta|Where-Object {$_}).Count | Should -BeExactly $expectedBeta.Count
    }
    It "Limit-SemVer -Stable" {
        $stable=$items|Limit-SemVer -Stable
        $stable|Select-Object -ExpandProperty SemVer|ForEach-Object {$_.ToString()} | Should -Be $expectedStable
    }
    It "Limit-SemVer -Prerelease" {
        $beta=$items|Limit-SemVer -Prerelease beta
        $beta|Select-Object -ExpandProperty SemVer|ForEach-Object {$_.ToString()} | Should -Be $expectedBeta
    }
}

AfterAll {
    Remove-Module -Name SemVerPS -Force
}
