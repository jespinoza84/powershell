$ServerName = '.'
$AppName = 'Zscaler'
$Services = ('ZSAService',
'ZSATunnel',
'ZSAUpdater')

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