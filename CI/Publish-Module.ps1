param(
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [string]$Repository="PSGallery",
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [switch]$AutoIncrementMinor=$false,
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [switch]$KeepManifests=$false
)

if (-not ("Semver.SemVersion" -as [type]))
{
    Write-verbose "Adding Semver.SemVersion type"
    Add-Type -Path "$PSScriptRoot\CS\SemVersion.cs"
}

$sourceModuleItems=Get-ChildItem -Path "$PSScriptRoot\..\Src\Modules" -Directory

$sourceModuleItems |ForEach-Object {
    $sourceModuleItem=$_

    $moduleName=$sourceModuleItem.Name
    $modulePath=$sourceModuleItem.FullName
    $psm1Path=Join-Path $modulePath "$moduleName.psm1"
    $psd1Path=Join-Path $modulePath "$moduleName.psd1"

    Write-Debug "moduleName=$moduleName"
    Write-Debug "modulePath=$modulePath"
    Write-Debug "psm1Path=$psm1Path"
    Write-Debug "psd1Path=$psd1Path"

    Remove-Item -Path $psd1Path -Force -ErrorAction SilentlyContinue

    $progressSplat=@{
        Activity=$moduleName
    }
    
    try {
    
        Write-Progress @progressSplat -Status "Exporting manifest"
        $psm1Source=Get-Content -Path $psm1Path -Raw
        Write-Debug "psm1Source=$psm1Source"
        $contentRegEx="<\#PSManifest[\r\n]+(?<content>[\s\S]+)\#>"
        Write-Debug "contentRegEx=$contentRegEx"
    
        if($psm1Source -notmatch $contentRegEx)
        {
            Write-Error "$psm1Path doesn't contain PSManifest tag"
            return -1
        }
        $content=$Matches["content"]
        Write-Debug "content=$content"
        $moduleHash=Invoke-Expression $content
    
        Write-Debug "Querying repository $Repository"
        Write-Progress @progressSplat -Status "Querying repository $Repository"
    
        $publishedModule=Find-Module -Name $moduleName -Repository $Repository -ErrorAction SilentlyContinue
        Write-Verbose "Queried $moduleName on $Repository"
        $shouldTryPublish=$false
        if($publishedModule)
        {
            $publishedVersion=$publishedModule.Version
            
            # Implicitly check the version of powershell and PowerShellGet module
            if($publishedVersion -is [string])
            {
                $publishedVersion=[Semver.SemVersion]::Parse($publishedVersion)
                $sourceModuleVersion=[Semver.SemVersion]::Parse($moduleHash.ModuleVersion)
            }
            else {
                $sourceModuleVersion=[System.Version]::Parse($moduleHash.ModuleVersion)
            }
            Write-Debug "publishedVersion=$publishedVersion"
            Write-Debug "sourceModuleVersion=$sourceModuleVersion"
    
            if($publishedVersion -lt $sourceModuleVersion)
            {
                Write-Host "Module $moduleName has source version $sourceModuleVersion that is higher than found published version $publishedVersion"
                $shouldTryPublish=$true
            }
            elseif($AutoIncrementMinor)
            {
                $moduleHash.ModuleVersion="$($publishedVersion.Major).$($publishedVersion.Minor+1)"
                Write-Debug "moduleHash.ModuleVersion=$moduleHash.ModuleVersion"
                Write-Host "Module $moduleName has new autoincremented minor $($moduleHash.ModuleVersion) from found published version $publishedVersion"
                $shouldTryPublish=$true
            }
            else
            {
                Write-Warning "Module $moduleName has source version $sourceModuleVersion that is not higher than found published version $publishedVersion. Will skip publishing"
            }
        }
        else
        {
            Write-Host "Module $moduleName is not yet published to the $Repository"
            $shouldTryPublish=$true
        }
    
        #region manifest
        Write-Debug "Generating manifest"
        Write-Progress @progressSplat -Status "Generating manifest"
    
        Import-Module $psm1Path -Force 
        $newModuleManifestSplat=@{}+$moduleHash
        $exportedNames=Get-Command -Module $moduleName | Select-Object -ExpandProperty Name
        Write-Debug "exportedNames=$($exportedNames -join ',')"
        $newModuleManifestSplat.Add("CmdletsToExport",$exportedNames)
        $newModuleManifestSplat.Add("FunctionsToExport",$exportedNames)
    
    <#
        $hash=@{
            "Author"="SDL plc"
            "CompanyName" = "SDL plc"
            "Copyright"="SDL plc. All rights reserved."
            "RootModule"=$psm1Name
            "Description"=$moduleDescription
            "Guid"=$guid
            "ModuleVersion"=$sourceVersion
            "Path"=$psd1Path
            "LicenseUri"='https://stash.sdl.com/projects/SCTA/repos/core/browse'
            "ProjectUri"= 'https://stash.sdl.com/projects/SCTA/repos/core/browse'
    #        "ReleaseNotes"= $releaseNotes -join [System.Environment]::NewLine
            "CmdletsToExport" = $exportedNames
            "FunctionsToExport" = $exportedNames
        }
    #>    
        New-ModuleManifest @newModuleManifestSplat -Path $psd1Path
    
        Write-Verbose "Generated manifest $psd1Path"
        
        #endregion
    
        if($shouldTryPublish)
        {
            Write-Debug "Publishing  $modulePath to $Repository"
            Write-Progress @progressSplat -Status "Publishing  $modulePath to $Repository"
            if($NuGetApiKey)
            {
                Publish-Module -Repository $Repository -Path $modulePath -NuGetApiKey $NuGetApiKey -Force
            }
            else
            {
                $mockKey="MockKey"
                Publish-Module -Repository $Repository -Path $modulePath -NuGetApiKey $mockKey -WhatIf
            }
            Write-Host "Published $($sourceModuleItem.FullName)"
        }
    }
    finally{
        if(-not $KeepManifests)
        {
            Remove-Item -Path $psd1Path -Force -ErrorAction SilentlyContinue
        }
        Write-Progress @progressSplat -Completed
    }
}