function Test-RegistryValue
{
  [cmdletbinding()]
  param(
    [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]$Path,
    
    [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]$Value
  )

  try {
    
    Get-ItemProperty -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $True
    
     
  } catch {
  
    return $False
    
  
  }
  
}

if (Test-RegistryValue -Path "HKLM:\Software\TeamsRooms" -Value "TeamsRoomsBG-09-2021") {
    Write-Host "installed"
}

else {
    Write-Host "not installed"
}