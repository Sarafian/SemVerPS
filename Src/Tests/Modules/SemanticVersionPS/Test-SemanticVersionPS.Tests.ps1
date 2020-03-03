& $PSScriptRoot\..\..\..\Modules\Import-SemanticVersionPS.ps1
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

Describe "SemVersion.Tests" {
    It "ConvertTo-SemanticVersion" {
        $semVersions=$versions|ConvertTo-SemanticVersion
        $semVersions.Count | Should BeExactly $versions.Count
        $semVersions|ForEach-Object {$_.ToString()} | Should Be $versions
    }
    It "Test-SemanticVersion -Stable" {
        $stable=$versions|Test-SemanticVersion -Stable
        ($stable|Where-Object {$_}).Count | Should BeExactly $expectedStable.Count
    }
    It "Test-SemanticVersion -Prerelease" {
        $beta=$versions|Test-SemanticVersion -Prerelease beta
        ($beta|Where-Object {$_}).Count | Should BeExactly $expectedBeta.Count
    }
    It "Limit-SemanticVersion -Stable" {
        $stable=$versions|Limit-SemanticVersion -Stable
        $stable.Count | Should BeExactly $expectedStable.Count
        $stable|ForEach-Object {$_.ToString()} | Should Be $expectedStable
    }
    It "Limit-SemanticVersion -Prerelease" {
        $beta=$versions|Limit-SemanticVersion -Prerelease beta
        $beta.Count | Should BeExactly $expectedBeta.Count
        $beta|ForEach-Object {$_.ToString()} | Should Be $expectedBeta
    }
}

Describe "Object.Tests" {
    $items=$versions|ForEach-Object {
        [pscustomobject]@{
            Name="item-"+$_
        }
    }
    It "Add-SemanticVersionMember -Expression" {
        $items|Add-SemanticVersionMember -Expression 'Name.Replace("item-","")'
        $items|Select-Object -ExpandProperty SemVersion|ForEach-Object {$_.ToString()} | Should Be $versions
    }
    It "Test-SemanticVersion -Stable" {
        $stable=$items|Test-SemanticVersion -Stable
        ($stable|Where-Object {$_}).Count | Should BeExactly $expectedStable.Count
    }
    It "Test-SemanticVersion -Prerelease" {
        $beta=$items|Test-SemanticVersion -Prerelease beta
        ($beta|Where-Object {$_}).Count | Should BeExactly $expectedBeta.Count
    }
    It "Limit-SemanticVersion -Stable" {
        $stable=$items|Limit-SemanticVersion -Stable
        $stable|Select-Object -ExpandProperty SemVersion|ForEach-Object {$_.ToString()} | Should Be $expectedStable
    }
    It "Limit-SemanticVersion -Prerelease" {
        $beta=$items|Limit-SemanticVersion -Prerelease beta
        $beta|Select-Object -ExpandProperty SemVersion|ForEach-Object {$_.ToString()} | Should Be $expectedBeta
    }
}

Remove-Module -Name SemanticVersionPS -Force
