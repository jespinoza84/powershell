<#
	.SYNOPSIS
		Gather system information via CIM Instance
	
	.DESCRIPTION
		Will gather System Info, Disk Info, SCCM Agent Info, Diagnostic info
	
	.PARAMETER ComputerName
		Specify ComputerName
	
	.EXAMPLE
				PS C:\> Get-SystemInfo -ComputerName <hostName>
	
	.NOTES
		None
#>

$ErrorActionPreference = 'Stop'

function Get-SystemInfo
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string[]]$ComputerName
	)
	
	foreach ($Computer in $ComputerName)
	{
		cls
		#Clearing and setting new CIM Session
		try
		{
			#Get-CimSession | Remove-CimSession
			$CimSesh = New-CimSession -ComputerName $Computer
		}
		catch
		{
			Write-Host $Error.Exception.Message[0] -BackgroundColor Black -ForegroundColor Red
			break
		}
		
		#CIM Session successful, gather CIM Instance information
		Write-Host "System Info" -Foreground Green -BackgroundColor Black
		(Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $CimSesh | `
			Select-Object -Property Name, `
						  Manufacturer, `
						  Model, `
						  @{ N = "BIOS Version"; E = { (Get-CimInstance -ClassName Win32_BIOS -CimSession $CimSesh).SMBIOSBIOSVersion } }, `
						  @{ N = "Physical Memory"; E = { [string][int32]($_.TotalPhysicalMemory / 1GB) + " GB" } } | `
			Format-List | Out-String).Trim()
		
		Write-Host "`n-------------------`n"
		
		Write-Host "OS Info" -Foreground Green -BackgroundColor Black
		(Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSesh | `
			Select-Object -Property Caption, `
						  Version, `
						  OSArchitecture | `
			Format-List | Out-String).Trim()
		
		Write-Host "`n-------------------`n"
		Write-Host "Disk Info" -ForegroundColor Green -BackgroundColor Black
		
		(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -CimSession $CimSesh | `
			Select-Object @{ Name = "Drive Letter"; Expression = { $_.DeviceID } }, `
						  @{ Name = "Disk Size"; Expression = { [string][int32]($_.Size / 1GB) + " GB" } }, `
						  @{ Name = "Free Space"; Expression = { [string][int32]($_.FreeSpace / 1GB) + " GB" } }, `
						  @{ Name = "Bitlocker Status"; Expression = { (Get-CimInstance -CimSession $CimSesh -ClassName win32_EncryptableVolume -Namespace root\cimv2\Security\MicrosoftVolumeEncryption | ? { $_.DriveLetter -eq "C:" }).ProtectionStatus } } | `
			Format-List | Out-String).Trim()
		
		Write-Host "`n-------------------`n"
		Write-Host "SCCM Agent Info" -ForegroundColor Green -BackgroundColor Black
		$SCCMAgentVer = (Get-CimInstance -Query "SELECT ClientVersion FROM SMS_Client" -Namespace "root/ccm" -CimSession $CimSesh).ClientVersion
		
		if (!($null -eq $SCCMAgentVer))
			{
				((Get-CimInstance -Query "SELECT ClientVersion FROM SMS_Client" -Namespace "root/ccm" -CimSession $CimSesh).ClientVersion | Format-List | Out-String).Trim()
			}
			else
			{
				Write-Host "SCCM Agent Not Found" -ForegroundColor Red
			}
			Write-Host "`n"
	}
}
