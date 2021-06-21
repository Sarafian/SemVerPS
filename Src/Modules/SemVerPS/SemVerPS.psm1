<#PSManifest
# This the hash to generate the module's manifest with New-ModuleManifest
@{
	# Required fields
	"RootModule"="SemVerPS.psm1"
	"Description"="PowerShell module for Semantic Version"
	"Guid"="58cf296d-cc21-43fa-9e81-e883f0f44f16"
	"ModuleVersion"="1.0"
	# Optional fields
	"Author"="Alex Sarafian"
	# "CompanyName" = "Company name"
	# "Copyright"="Some Copyright"
	"LicenseUri"='https://github.com/Sarafian/SemVerPS/blob/master/LICENSE'
	"ProjectUri"= 'https://github.com/Sarafian/SemVerPS/'
	# Auto generated. Don't implement
}
#>

#requires -Version 4.0

if (-not ("Semver.SemVersion" -as [type]))
{
    Write-verbose "Adding Semver.SemVersion type"
	Add-Type -Path "$PSScriptRoot\CS\Semver.cs"
}

$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude @("*.Tests.ps1"))
#$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude @("*.Tests.ps1"))
$private=@()

Foreach($import in @($public + $private))
{
	. $import.FullName
}

Export-ModuleMember -Function $public.BaseName