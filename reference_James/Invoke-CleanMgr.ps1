$Paths = @(
	"Active Setup Temp Folders",
	"BranchCache",
	"Downloaded Program Files",
	"GameNewsFiles",
	"GameStatisticsFiles",
	"GameUpdateFiles",
	"Internet Cache Files",
	"Memory Dump Files",
	"Offline Pages Files",
	"Old ChkDsk Files",
	"Previous Installations",
	"Recycle Bin",
	"Service Pack Cleanup",
	"Setup Log Files",
	"System error memory dump files",
	"System error minidump files",
	"Temporary Files",
	"Temporary Setup Files",
	"Temporary Sync Files",
	"Thumbnail Cache",
	"Update Cleanup",
	"Upgrade Discarded Files",
	"User file versions",
	"Windows Defender",
	"Windows Error Reporting Archive Files",
	"Windows Error Reporting Queue Files",
	"Windows Error Reporting System Archive Files",
	"Windows Error Reporting System Queue Files",
	"Windows ESD installation files",
	"Windows Upgrade Log Files"
)

foreach ($Path in $Paths)
{
	if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$($Path)")
	{
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$($Path)" -Name StateFlags0099 -PropertyType DWORD -Value 2 -Force
	}
	else
	{
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$($Path)"
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$($Path)" -Name StateFlags0099 -PropertyType DWORD -Value 2 -Force
	}
}

Start-Process -FilePath "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList "/sagerun:99" -Wait