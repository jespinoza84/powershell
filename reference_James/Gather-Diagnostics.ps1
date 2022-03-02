$ErrorActionPreference = "Stop"

Clear-Host

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

Write-Host "============================" -ForegroundColor Green
Write-Host " Gather Diagnostics" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try
{
	
	# Create Temp Gather Directory
	$GatherDir = "$env:TEMP\GatherTemp"
	
	if (Test-Path -Path $GatherDir)
	{
		Remove-Item -Path $GatherDir -Recurse -Force
	}
	else
	{
		Write-Host "Creating temporary directory at $GatherDir"
		$null = New-Item -ItemType Directory -Path "$env:TEMP\GatherTemp" -Force
	}
	
	# Get Mini Dump
	$MiniDump = "$env:SystemRoot\MiniDump"
	
	if (Test-Path -Path $MiniDump)
	{
		Write-Host "--Minidump present. Gathering." -ForegroundColor Yellow
		Copy-Item -Path $MiniDump -Destination $GatherDir -Recurse -Force
	}
	else
	{
		Write-Host "--Minidump not present. Skipping." -ForegroundColor Yellow
	}
	
	# Get Event Logs
	$LogTypes = ("System", "Application", "Security")
	$null = New-Item -Path "$GatherDir\EventLogs" -ItemType Directory
	
	foreach ($LogType in $LogTypes) {
		Write-Host "Creating $LogType Log."
		
		$arg1 = "epl $LogType"
		$arg2 = "$GatherDir\EventLogs\$LogType.evtx"
		Start-Process -FilePath "$env:windir\system32\wevtutil.exe" -ArgumentList $arg1, $arg2
	}
	
	# Grab System Info
	Write-Host "Creating System Info text file."
	systeminfo | Out-File "$GatherDir\SystemInfo.txt"
	
	# Grab Installed Apps
	Write-Host "Gathering Installed Applications (x64)  "
	Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
	Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | `
	Sort-Object DisplayName | `
	ConvertTo-Html -Head $Header | `
	Out-File -FilePath "$GatherDir\InstalledAppsx64.html"
	
	Write-Host "Gathering Installed Applications (x64/x86)  "
	Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
	Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | `
	Sort-Object DisplayName | `
	ConvertTo-Html -Head $Header | `
	Out-File -FilePath "$GatherDir\InstalledAppsx86.html"
	
	# Grab Installed Drivers
	Write-Host "Gathering Driver information."
	Get-WindowsDriver -Online | `
	Select-Object ProviderName, ClassName, Driver, Date, Version | `
	Sort-Object -Descending Date | `
	ConvertTo-Html -Head $Header | `
	Out-File -FilePath "$GatherDir\InstalledDrivers.html"
	
	# Zip contents
	Write-Host "Zipping contents."
	Compress-Archive -Path "$GatherDir\*" `
					 -DestinationPath "$GatherDir\$env:COMPUTERNAME.zip" `
					 -CompressionLevel Optimal `
					 -Force
	
	# Send email to ServiceNow
	$LoggedOnUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
	
	Write-Host "Sending $env:COMPUTERNAME.zip to user@address.com"
	
	Send-MailMessage -From "  " `
					 -To "user@address.com" `
					 -Subject "Gathered information for $env:COMPUTERNAME - Submitted by $LoggedOnUser" `
					 -BodyAsHtml `
					 -Body "System diagnostics gathered for $env:COMPUTERNAME attached." `
					 -Attachments "$GatherDir\$env:COMPUTERNAME.zip" `
					 -SmtpServer "smtprelay"
	
	Write-Host "Successfully sent." -ForegroundColor Green
	
	# Delete GatherTemp
	Write-Host "Deleting temporary directory at $GatherDir"
	Remove-Item -Path $GatherDir -Recurse -Force
	
	# End
	Write-Host "Script has completed. You may press any key or close the window."
	& cmd /c pause
	exit
	
}

catch [System.Net.Mail.SmtpException] {
	Write-Host "Sending email failed due to the following reason:" -ForegroundColor Red
	Write-Host $_.Exception.Message -ForegroundColor Red
}

catch
{
	Write-Host "Script failed due to the following reason:" -ForegroundColor Red
	Write-Host $_.Exception.Message -ForegroundColor Red
}

finally
{
	Exit-PSHostProcess
}