# Get OneDrive KFM status (CI)
Get-CMDeployment | ? {$_.ApplicationName -eq "onedrive KFM"} | Select-Object CollectionName,NumberSuccess | FT -GroupBy ApplicationName