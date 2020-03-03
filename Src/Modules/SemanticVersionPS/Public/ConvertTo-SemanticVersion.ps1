<#
.Synopsis
   Converts a string version to semantic version
.DESCRIPTION
   Converts a string version to semantic version
.EXAMPLE
   ConvertTo-SemanticVersion -Version "1.0.0"
.EXAMPLE
   ConvertTo-SemanticVersion -Version "1.0.0" -Strict
.LINK
   Test-SemanticVersion
#>
Function ConvertTo-SemanticVersion {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([Semver.SemVersion[]])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Parameter")]
        [string[]]$Version,
        [Parameter(Mandatory=$false,ParameterSetName="Parameter")]
        [switch]$Strict=$false
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}
    }

    process {
        $Version | ForEach-Object {
            [Semver.SemVersion]::Parse($_,$Strict)
        }

    }

    end {

    }
}