<#
.Synopsis
   Test if an object's semantic version value is stable or specific pre-release
.DESCRIPTION
   Test if an object's semantic version value is stable or specific pre-release. The object can be a 
   - string
   - semversion as created by ConvertTo-SemanticVersion
   - any object with attached SemVersion property
.EXAMPLE
   Test-SemanticVersion -InputObject "1.0.0"
.EXAMPLE
   Test-SemanticVersion -InputObject "1.0.0" -Stable
.EXAMPLE
   Test-SemanticVersion -InputObject "1.0.0-alpha+1" -PreRelease alpha
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemanticVersionMember -Expression 'Name.Replace("example-","")' -PassThru|Test-SemanticVersion -Stable
.LINK
   Add-SemanticVersionMember
.LINK
   ConvertTo-SemanticVersion
#>
Function Test-SemanticVersion {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - Validate")]
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - Stable")]
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - PreRelease")]
        [object]$InputObject,
        [Parameter(Mandatory=$false,ParameterSetName="Object - Validate")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - Stable")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - PreRelease")]
        [string]$Property="SemVersion",
        [Parameter(Mandatory=$true,ParameterSetName="Object - Stable")]
        [switch]$Stable,
        [Parameter(Mandatory=$true,ParameterSetName="Object - PreRelease")]
        [string]$PreRelease
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}
    }

    process {
        switch($PSCmdlet.ParameterSetName)
        {
            'Object - Validate' {
                if($InputObject -is [Semver.SemVersion])
                {
                    $true
                }
                elseif($InputObject -is [string])
                {
                    $semVersion=$null
                    [Semver.SemVersion]::TryParse($InputObject,[ref]$semVersion)
                }
                else
                {
                    $InputObject.$Property -is [Semver.SemVersion]
                }
            }
            'Object - Stable' {
                if($InputObject -is [Semver.SemVersion])
                {
                    $InputObject.PreRelease -eq ""
                }
                elseif($InputObject -is [string])
                {
                    ($InputObject|ConvertTo-SemanticVersion).PreRelease -eq ""
                }
                else
                {
                    $InputObject.$Property.Prerelease -eq ""
                }
            }
            'Object - PreRelease' {
                if($InputObject -is [Semver.SemVersion])
                {
                    $InputObject.PreRelease -eq $PreRelease
                }
                elseif($InputObject -is [string])
                {
                    ($InputObject|ConvertTo-SemanticVersion).PreRelease -eq $PreRelease
                }
                else
                {
                    $InputObject.$Property.Prerelease -eq $PreRelease
                }
            }
        }

    }

    end {

    }
}