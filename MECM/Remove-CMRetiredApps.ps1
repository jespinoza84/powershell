# Will not pull SDMPackageXML property if run with -Fast param
$RetiredApps = Get-CMApplication | Where-Object {$_.IsExpired -eq 'True'}

foreach ($App in $RetiredApps) {
  # Extracting network path from SDMPackageXML
  $NetworkPath = Select-String -InputObject $App.SDMPackageXML -Pattern '\B<Location>(.*?)<\/Location>'
  
  Write-Host "Removing CM Application: $($App.LocalizedDisplayName)"
  Remove-CMApplication -ID $App.CI_ID
  
  Write-Host "Removing content path: $($NetworkPath.Matches.Groups[1].Value)"
  Remove-Item -Path filesystem::$($NetworkPath.Matches.Groups[1].Value) -Recurse -Force
}
