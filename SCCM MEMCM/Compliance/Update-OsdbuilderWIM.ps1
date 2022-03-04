function Update-WindowsImage {

  [cmdletbinding()]
  
  param (
    [Parameter(Mandatory=$true)]
    [string]$DriveLetter,
    [ValidateScript({Test-Path $_})]
    [IO.FileInfo]$IsoPath = "F:\ISOs\Windows 10 20H2\SW_DVD9_Win_Pro_10_20H2_64BIT_English_Pro_Ent_EDU_N_MLF_-2_X22-41520.ISO"
  )

  $LogPath = "${DriveLetter}:\Logs\OSDBuilder"
  if (!(Test-Path -Path $LogPath))
  {
    New-Item -Path $LogPath -ItemType Directory
  }

  function Write-Log
  {
    [cmdletbinding()]
    Param (
      [AllowNull()]
      [string]$LogString
    )

    $LogFile = "${DriveLetter}:\Logs\OSDBuilder\OSBuild-$(Get-Date -Format MM-dd-yy).log"
    $DateTime = '[{0:MM/dd/yy} {0:HH:mm:ss}]' -f (Get-Date)
    $LogMessage = "$Datetime $LogString"

    Add-Content -Path $LogFile -Value $LogMessage
  }

  Write-Output "Starting log file at $($LogFile)"
  Write-Log -LogString "Running OSDBuilder for $($IsoPath)"

  # Import OSDBuilder module  
  Write-Log -LogString "Importing OSDBuilder module"
  if($null -eq (Get-Module osdbuilder)) {
    Import-Module osdbuilder
  }

  # Set OSDBuilder home folder
  Write-Log -LogString "Setting OSDBuilder home to ${DriveLetter}:\OSDBuilder"
  Get-OSDBuilder -SetHome "${DriveLetter}:\OSDBuilder"

  # Update modules
  # Separate scheduled task


  # Check for mounted image
  Write-Log -LogString "Checking for mounted image..."
  $MountedISO = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=5" | Where-Object {$_.DeviceID -eq "E:"}

  if (!($MountedISO))
  {
    Write-Log -LogString 'ISO not mounted. Mounting.'
    Mount-DiskImage -ImagePath "$IsoPath"
  }

  else
  {
    Write-Log -LogString 'ISO mounted. Continuing.'
  }

  Write-Log -LogString 'OSDBuilder tasks starting.'
  
  # OneDrive Enterpise
  Write-Log -LogString "Downloading latest Onedrive Enterprise client."
  OSDBuilder -Download OneDriveEnterprise

  Write-Log -LogString "Import OS, update LCU/SSU/.NET, enable .NET 3.5 Framework -"
  Import-OSMedia -ImageIndex 3 -Update -BuildNetFX -SkipGrid

  # Remove superseded OSBuild revisions
  Write-Log "Checking for superseded OS Builds.
  "
  $OSBuildHistory = Get-osbuilds
  foreach ($OS in $OSBuildHistory){
    if ($OS.Revision -eq 'Superseded'){
      Write-Log -LogString "$($OS.Name) 'OS build is superseded. Removing.'"
      Remove-Item -Path $OS.FullName -Recurse -Force
    }
    
    if ($OS.Revision -eq 'OK'){
      Write-Log -LogString "$($OS.Name) is the current OS build."
    }
  }

  # Remove superseded OSMedia revisions

  $OSMediaHistory = Get-osmedia
  foreach ($OSMedia in $OSMediaHistory){
    if ($OSMedia.Revision -eq 'Superseded'){
      Write-Log -LogString "$($OSMedia.Name) 'OS Media is superseded. Removing.'"
      Remove-Item -Path $OSMedia.FullName -Recurse -Force
    }
    
    if ($OSMedia.Revision -eq 'OK'){
      Write-Log -LogString "$($OSMedia.Name) is the current OSMedia build."
    }
  }

  Write-Log -LogString 'OSDBuilder tasks completed.'

  }