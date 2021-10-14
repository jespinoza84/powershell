BEGIN {
    #region Variables
    $SourcePath = '\\source\unc\path\Updates'
    $ExtractPath = 'C:\temp\office2016'
    $Office2016Path = '\\application\unc\path'
    $StartTime = Get-Date
    $CmAppName = "Office 2016"
    #endregion

    #region ConfigMgr Module
    $SiteCode = "XYZ" # site code
    $ProviderMachineName = "primary.com" # Primary server

    # Import the ConfigurationManager.psd1 module 
    if ($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" 
    }

    # Add site's drive if it is not already present
    if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
    }
    #endregion

    function Write-Log {
        [CmdletBinding()]
        param(
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [string]$Message,

            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [ValidateSet('Information', 'Warning', 'Error')]
            [string]$Severity = 'Information',

            [string]$LogPath = "$env:windir\logs",
            [string]$ScriptName = 'Update-Office2016',
            [string]$FileName = "$($ScriptName).log"

        )

        $LogFilePath = Join-Path -Path $LogPath -ChildPath $FileName
        $Timestamp = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
        
        $LogEntry = "$TimeStamp [$Severity] - $Message"

        Out-File -InputObject $LogEntry -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
}

PROCESS {
    
    Write-Log -Message " ----- Starting $ScriptName at $StartTime ----- "

    # Check for local extract folder
    if (!(Test-Path -Path $ExtractPath -PathType Container)) {
        Write-Log -Message ('Creating directory at {0}' -f $ExtractPath)
        $null = New-Item -Path $ExtractPath -ItemType Directory
    }
    else {
        Write-Log -Message "$($ExtractPath) exists. Clearing."
        Remove-Item -Path "$ExtractPath/*" -Recurse -Force
    }
  
    #Copy items locally
    Write-Log -Message "Copying content from $($SourcePath) to $($ExtractPath)"
    $SourceFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter '*.cab'
     
    foreach ($sFile in $SourceFiles) {
        Write-Log -Message "Copying $($sFile.Name) to $ExtractPath"
        Copy-Item -Path $sFile.FullName -Destination $ExtractPath -Force
    }

    # Start extract, excluding lip* (language packs)
    Write-Log -Message 'Beginning CAB file extract'
    $UpdateFiles = Get-ChildItem -Path $ExtractPath -Recurse -Filter '*.cab' -Exclude 'lip*'

    foreach ($Update in $UpdateFiles) {
        Write-Log -Message ('Extracting {0}' -f $Update.Name)
        $null = & "$env:windir\system32\expand.exe" -F:* ('{0}\{1}' -f $Update.Directory, $Update.Name) $ExtractPath
    }

    # Remove XML Metadata
    Write-Log -Message 'Removing XML metadata'
    Remove-Item -Path $ExtractPath -Filter '*.xml' -Force -Recurse

    # Copy to office 2016 application source
    Write-Log -Message "Copying MSP files back to $($Office2016Path)"
    $ExtractedFiles = Get-ChildItem -Path $ExtractPath -Recurse -Filter '*.msp'

    foreach ($eFile in $ExtractedFiles) {
        Write-Log -Message "Copying $($eFile.Name) to $Office2016Path"
        Copy-Item -Path $eFile.FullName -Destination $Office2016Path -Force
    }

    # Set location to NOR:\
    Write-Log -Message "Setting location to $($Sitecode):\"
    Set-Location "$($SiteCode):\"

    # Update application content on distribution points
    Write-Log -Message 'Updating distribution points for Office 2016'
    Update-CMDistributionPoint -ApplicationName $CmAppName -DeploymentTypeName 'Install'

    # Clear out local content
    Write-Log -Message "Removing local content from $($ExtractPath)"
    Set-Location $env:SystemDrive
    Remove-Item -Path "$ExtractPath/*" -Recurse -Force
}

END {
    $ElapsedTime = (Get-Date) - $StartTime
    Write-Log -Message " ----- END - $([math]::Round($ElapsedTime.TotalMinutes,2)) minutes to complete ----- "
}