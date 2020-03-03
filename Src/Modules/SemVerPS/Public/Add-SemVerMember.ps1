<#
.Synopsis
   Adds a semantic version property to an existing object
.DESCRIPTION
   Adds a semantic version property to an existing object using a an expression that is expected to execute on each item or a script block
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -Expression 'Name.Replace("example-","")' -PassThru
.EXAMPLE
   [pscustomobject]@{Name="example-1.0.0"}|Add-SemVerMember -ScriptBlock {$_.Name.Replace("example-","")} -PassThru -Name "SemVer"
.LINK
   Test-SemVer
.LINK
   ConvertTo-SemVer
#>
Function Add-SemVerMember {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([psobject[]])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - Expression")]
        [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Object - ScriptBlock")]
        [object[]]$InputObject,
        [Parameter(Mandatory=$false,ParameterSetName="Object - Expression")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - ScriptBlock")]
        [string]$Name="SemVer",
# ScriptProperty not working yet
#        [Parameter(Mandatory=$false,ParameterSetName="Object - ScriptBlock")]
#        [ValidateSet("NoteProperty","ScriptProperty")]
#        [string]$MemberType="NoteProperty",
        [Parameter(Mandatory=$true,ParameterSetName="Object - Expression")]
        [string]$Expression,
        [Parameter(Mandatory=$true,ParameterSetName="Object - ScriptBlock")]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory=$false,ParameterSetName="Object - ScriptBlock")]
        [switch]$Dynamic=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Object - Expression")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - ScriptBlock")]
        [switch]$Strict=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Object - Expression")]
        [Parameter(Mandatory=$false,ParameterSetName="Object - ScriptBlock")]
        [switch]$PassThru=$false
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}
    }

    process {
        $InputObject|ForEach-Object {
            $item=$_
            switch($PSCmdlet.ParameterSetName)
            {
                'Object - Expression' {
                    $command='$item.'+$Expression
                    Write-Debug "command=$command"
                    $version=Invoke-Expression -Command $command
                    Write-Debug "version=$version"
                    $semVersion=ConvertTo-SemVer -Version $version -Strict:$Strict
                    Write-Debug "semVersion=$semVersion"
                    $item|Add-Member -MemberType NoteProperty -Name $Name -Value $semVersion
                }
                'Object - ScriptBlock' {
#                    if($MemberType -eq "NoteProperty")
#                    {
                        $version=$item|Select-Object @{Name=$Name;Expression=$ScriptBlock} | Select-Object -ExpandProperty $Name
                        Write-Debug "version=$version"
                        $semVersion=ConvertTo-SemVer -Version $version -Strict:$Strict
                        Write-Debug "semVersion=$semVersion"
                        $item|Add-Member -MemberType NoteProperty -Name $Name -Value $semVersion
<#
                    }
                    else
                    {
                        $scriptBlockString=@"
    `$version={$($ScriptBlock.ToString())}
    Write-Host "version=`$version"
    `$semVersion=ConvertTo-SemVer -Version `$version -Strict:$Strict
    Write-Host "semVersion=`$semVersion"
    `$semVersion
"@

Write-Debug "scriptBlockString=$scriptBlockString"

$block=[scriptblock]::Create($scriptBlockString)
                        $item|Add-Member -MemberType ScriptProperty -Name $Name -Value $block

                    }
                    
#>
                }
            }

            if($PassThru)
            {
                $item
            }
        }

    }

    end {

    }
}