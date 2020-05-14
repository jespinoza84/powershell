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
    
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $True
    
     
  } catch {
  
    return $False
    
  
  }
  
}

# Example 
# Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Value "Lync"