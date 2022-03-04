function Expand-Office2016Updates {

  Param (
    [Parameter(Mandatory = $true)]
    [string]$Source = '\\path\source',
    [Parameter(Mandatory = $true)]
    [string]$Destination = "\\path\destination"
  )
  # Check Destination
  if (!(Test-Path -Path $Destination)){
    Write-Output -InputObject ('Creating directory at {0}' -f $Destination)
    $null = New-Item -Path $Destination -ItemType Directory
  }
  
  # Start expand, excluding lip* (language packs)
  $UpdateFiles = Get-ChildItem -Path $Source -Recurse -Filter '*.cab' -Exclude 'lip*'

  foreach ($Update in $UpdateFiles)
  {
      Write-Output -InputObject ('Expanding {0}' -f $Update.Name)
      $null = & "$env:windir\system32\expand.exe" -F:* ('{0}\{1}' -f $Update.Directory, $Update.Name) $Destination
  }

  # Remove XML Metadata
  Remove-Item -Path ('{0}\*.xml' -f $Destination)

}