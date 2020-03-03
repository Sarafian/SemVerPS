<#
.Synopsis
   Test if an object's semantic version value is stable or specific pre-release
.DESCRIPTION
   Test if an object's semantic version value is stable or specific pre-release. The object can be a 
   - string
   - semversion as created by ConvertTo-SemVer
   - any object with attached SemVersion property
.EXAMPLE
   Test-SemVer -InputObject "1.0.0"
.EXAMPLE
   Test-SemVer -InputObject "1.0.0" -Stable
.EXAMPLE
   Test-SemVer -InputObject "1.0.0-alpha+1" -PreRelease alpha
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -Expression 'Name.Replace("example-","")' -PassThru|Test-SemVer -Stable
.LINK
   Add-SemVerMember
.LINK
   ConvertTo-SemVer
#>
Function Test-SemVer {
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
        [string]$Property="SemVer",
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
                    ($InputObject|ConvertTo-SemVer).PreRelease -eq ""
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
                    ($InputObject|ConvertTo-SemVer).PreRelease -eq $PreRelease
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