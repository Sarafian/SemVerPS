[![Build status](https://ci.appveyor.com/api/projects/status/3y00c9g65v43eok1/branch/master?svg=true)](https://ci.appveyor.com/project/Alex61243/semverps/branch/master)

# SemVerPS
PowerShell module to work with Semantic Versioning

# Usage

The modules offers the ability to work with [Semantic Version] utilizing the .net implementation from [Max Hauser's SemVer] repository. 

Use the `ConvertTo-SemVer` to convert strings to semantic version objects. For example:

```powershell
ConvertTo-SemVer -Version "1.0.0"
```
```text
Major      : 1
Minor      : 0
Patch      : 0
Prerelease : 
Build      : 
```
```powershell
ConvertTo-SemVer -Version "1.0.1-alpha+1" -Strict
```
```text
Major      : 1
Minor      : 0
Patch      : 1
Prerelease : alpha
Build      : 1
```


Use the `Test-SemVer` to test if a string or an semantic version is stable or prerelease. For example:

```powershell
Test-SemVer -InputObject "1.0.0"
#True

Test-SemVer -InputObject "1.0.0" -Stable
#True

Test-SemVer -InputObject "1.0.0-alpha+1" -PreRelease alpha
#True
```

Often there is a need to attach a semantic version notation to an object or a list of objects. Use the `Add-SemVerMember` to add a member where the semantic version value is derived either from an expression or a script block. By default the semantic version is add to a property named `SemVer` but this can be changed by defining the `Property` parameter. For example:

```powershell
[pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -Expression 'Name.Replace("example-","")' -PassThru
[pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru -Name "AnotherProperty"
```
```text
Name          SemVer
----          ------
example-1.0.0 1.0.0


Name          AnotherProperty
----          ---------------
example-1.0.0 1.0.0


```

As an extension of the `Test-SemVer`, use the `Limit-SemVer` to filter objects based on semantic version conditions. Each object can be in the form of a string, or a semantic version instance or an object that has been enhanced with `Add-SemVerMember`. For example:

```powershell
$versions=@(
    "1.0.0"
    "1.0.0-alpha+1"
)
$versions|Limit-SemVer -Stable
$versions|Limit-SemVer -Prerelease alpha
```
```text
1.0.0

1.0.0-alpha+1
```

```powershell
$objectsWithVersions=@(
    "example-1.0.0"
    "example-1.0.0-alpha+1"
)|Foreach-Object {
    [pscustomobject]@{Name=$_}| Add-SemVerMember -Expression 'Name.Replace("example-","")' -PassThru  
}
$objectsWithVersions
$objectsWithVersions|Limit-SemVer -Stable
$objectsWithVersions|Limit-SemVer -Prerelease alpha
```
```text
Name          SemVer
----          ------
example-1.0.0 1.0.0

Name                  SemVer
----                  ------
example-1.0.0-alpha+1 1.0.0-alpha+1
```

## Cmdlets

- `Add-SemVerMember`
- `Convert-SemVer`
- `Test-SemVer`
- `Limit-SemVer`

[Semantic Version]: http://semver.org/
[Max Hauser's SemVer]: maxhauser/semver
