cls

# Create Temp Gather Directory
$GatherDir = "$env:TEMP\GatherTemp"

Write-Host "Creating temporary directory at $GatherDir"
$null = New-Item -ItemType Directory -Path "$env:TEMP\GatherTemp"

# Get Mini Dump
$MiniDump = "$env:SystemRoot\MiniDump"

if (Test-Path -Path $MiniDump){
    Write-Host "Minidump present. Gathering."
    Copy-Item -Path $MiniDump -Destination $GatherDir -Recurse -Force
}
else {
    Write-Host "Minidump not present. Skipping."
}

# Get Event Logs
$LogTypes = @("System","Application","Security")
$HoursLapsed = (Get-Date).AddDays(-2)
$null = New-Item -Path "$GatherDir\EventLogs" -ItemType Directory
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

foreach ($LogType in $LogTypes){
    Write-Host "Creating $LogType Log."
    Get-EventLog -LogName $LogType -After $HoursLapsed | Select TimeGenerated,EntryType,Message | ConvertTo-Html -Head $Header | Out-File -FilePath "$GatherDir\EventLogs\$LogType.html"
}

# Grab System Info
Write-Host "Creating System Info text file."
systeminfo | Out-File "$GatherDir\SystemInfo.txt"

# Grab Installed Apps
Write-Host "Gathering Installed Applications."
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
                 Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | `
                 Sort DisplayName | `
                 ConvertTo-Html -Head $Header | `
                 Out-File -FilePath "$GatherDir\InstalledApps.html"

# Grab Installed Drivers
Write-Host "Gathering Driver information."
Get-WindowsDriver -Online | `
                  select ProviderName,ClassName,Driver,Date,Version | `
                  Sort -Descending Date | `
                  ConvertTo-Html -Head $Header | `
                  Out-File -FilePath "$GatherDir\InstalledDrivers.html"

# Zip contents
Write-Host "Zipping contents."
Compress-Archive -Path "$GatherDir\*" `
                 -DestinationPath "$GatherDir\$env:COMPUTERNAME.zip" `
                 -CompressionLevel Optimal `
                 -Force

# Send email to ServiceNow
$LoggedOnUser = Get-WmiObject -Class Win32_ComputerSystem | select -ExpandProperty UserName

try {
    Write-Host "Sending $env:COMPUTERNAME.zip to <recipient>"
    Send-MailMessage -From "<sender>" `
                     -To "<recipient>" `
                     -Subject "Gathered information for $env:COMPUTERNAME - Submitted by $LoggedOnUser" `
                     -BodyAsHtml `
                     -Body "System diagnostics gathered for $env:COMPUTERNAME attached." `
                     -Attachments "$GatherDir\$env:COMPUTERNAME.zip" `
                     -SmtpServer "<server>" `
                     -ErrorAction SilentlyContinue
    Write-Host "Successfully sent." -ForegroundColor Green
}

catch {
    Write-Host "Sending email failed." -ForegroundColor Red
}

# Delete GatherTemp
Write-Host "Deleting temporary directory at $GatherDir"
Remove-Item -Path $GatherDir -Recurse -Force

# End
Write-Host "Script has completed. You may press any key or close the window."
& cmd /c pause
exit