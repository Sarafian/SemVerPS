<#
.Synopsis
   Limits a set of objects based on their semantic version values
.DESCRIPTION
   Limits a set of objects depending on if their semantic version value is stable or specific pre-release. The object can be a 
   - string
   - semversion as created by ConvertTo-SemVer
   - any object with attached SemVersion property
.EXAMPLE
   "1.0.0"|Limit-SemVer -Stable
.EXAMPLE
   "1.0.0-alpha+1"|Limit-SemVer -Prerelease alpha
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru|Limit-SemVer -Stable
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0-alpha+1"}|Add-SemVerMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru|Limit-SemVer -Prerelease alpha
.LINK
   Add-SemVerMember
.LINK
   Test-SemVer
#>
Function Limit-SemVer {
    [CmdletBinding(SupportsShouldProcess=$true)]
#    [OutputType([Semver.SemVersion[]])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object")]
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - Stable")]
        [object]$InputObject,
        [Parameter(Mandatory=$false,ParameterSetName="Object")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - Stable")]
        [string]$Property="SemVer",
        [Parameter(Mandatory=$true,ParameterSetName="Object - Stable")]
        [switch]$Stable,
        [Parameter(Mandatory=$true,ParameterSetName="Object")]
        [string]$PreRelease
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}

        $newParameters=@{}+$PSBoundParameters
        $null=$newParameters.Remove("InputObject")
    }

    process {
        $InputObject|Where-Object {
            $_|Test-SemVer @newParameters
        }
    }

    end {

    }
}