<#
.Synopsis
   Limits a set of objects based on their semantic version values
.DESCRIPTION
   Limits a set of objects depending on if their semantic version value is stable or specific pre-release. The object can be a 
   - string
   - semversion as created by ConvertTo-SemanticVersion
   - any object with attached SemVersion property
.EXAMPLE
   "1.0.0"|Limit-SemanticVersion -Stable
.EXAMPLE
   "1.0.0-alpha+1"|Limit-SemanticVersion -Prerelease alpha
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemanticVersionMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru|Limit-SemanticVersion -Stable
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0-alpha+1"}|Add-SemanticVersionMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru|Limit-SemanticVersion -Prerelease alpha
.LINK
   Add-SemanticVersionMember
.LINK
   Test-SemanticVersion
#>
Function Limit-SemanticVersion {
    [CmdletBinding(SupportsShouldProcess=$true)]
#    [OutputType([Semver.SemVersion[]])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object")]
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - Stable")]
        [object]$InputObject,
        [Parameter(Mandatory=$false,ParameterSetName="Object")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - Stable")]
        [string]$Property="SemVersion",
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
            $_|Test-SemanticVersion @newParameters
        }
    }

    end {

    }
}