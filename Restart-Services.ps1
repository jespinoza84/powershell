$ServerName = '.'
$AppName = 'Zscaler'
$Services = ('ZSAService',
'ZSATunnel',
'ZSAUpdater')


<#
foreach ($Service in $Services)
{
  $ServiceStatus = Get-Service -Name $Service -ComputerName $ServerName
  if ($ServiceStatus.Status -eq 'Running'){
    Write-Host "$Service is running."
  }
  if ($ServiceStatus.Status -eq 'Stopped'){
    Write-Host "$Service has stopped. Restarting..."
    Restart-Service -Name $Service -Force
    
    Start-Sleep 30
    
    $Confirm = Get-Service -Name $Service -ComputerName $ServerName
    if ($Confirm.Status -eq 'Stopped'){
      New-BurntToastNotification -Text "$AppName Service Check","$Service on $ServerName will not restart properly" -AppLogo "C:\Users\james.espinoza\OneDrive - Chobani LLC\Documents\AppDeployToolkitLogo.ico" -SnoozeAndDismiss
    }
    else {
      Write-Host "$Service has restarted and is running"
    }
  }

}
#>

$Results = foreach ($Service in $Services)
{
  $ServiceStatus = Get-Service -Name $Service -ComputerName $ServerName
  if ($ServiceStatus.Status -eq 'Running'){
    Write-Host "$Service is running."
  }
  else {
    Write-Host "$Service is not running."
  }
}

$Results | gm