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
		
		(Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSesh | Select-Object -Property @{ N = "Name"; E = { $_.Caption } }, @{
			N						    = "Version"; E = {
				switch ($OSVersion.Version)
				{
					"10.0.18362" { Write-Host "1903" }
					"10.0.17763" { Write-Host "1809" }
				}
			}
			
		}, OSArchitecture | Format-List | Out-String).Trim()
		<#
		
		Write-Host "OS Info" -Foreground Green -BackgroundColor Black
		(Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSesh | `
			Select-Object -Property @{ N = "Name"; E = { $_.Caption } }, `
						  @{
				N = "Version"; E = {
					if ($_.Version -like "*18362*")
					{
						$_.Version + " (1903)"
					}
					elseif ($_.Version -like "*17763*")
					{
						$_.Version + " (1809)"
					}
					elseif ($_.Version -like "*17134*")
					{
						$_.Version + " (1803)"
					}
					elseif ($_.Version -like "*16299*")
					{
						$_.Version + " (1709)"
					}
					elseif ($_.Version -like "*15063*")
					{
						$_.Version + " (1703)"
					}
					elseif ($_.Version -like "*14393")
					{
						$_.Version + " (1607)"
					}
					elseif ($_.Version -like "*10586*")
					{
						$_.Version + " (1511)"
					}
					elseif ($_.Version -like "*10240*")
					{
						$_.Version + " (1507)"
					}
					else
					{
						$_.Version
					}
				}
			}, `
						  OSArchitecture | `
			Format-List | Out-String).Trim()
		#>
		
		
		Write-Host "`n-------------------`n"
		Write-Host "Disk Info" -ForegroundColor Green -BackgroundColor Black
		
		(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -CimSession $CimSesh | `
			Select-Object @{ Name = "Drive Letter"; Expression = { $_.DeviceID } }, `
						  @{ Name = "Disk Size"; Expression = { [string][int32]($_.Size / 1GB) + " GB" } }, `
						  @{ Name = "Free Space"; Expression = { [string][int32]($_.FreeSpace / 1GB) + " GB" } }, `
						  @{ Name = "Bitlocker Status"; Expression = {
					$BitlockerStatus = (Get-CimInstance -CimSession $CimSesh -ClassName win32_EncryptableVolume -Namespace root\cimv2\Security\MicrosoftVolumeEncryption | ? { $_.DriveLetter -eq "C:" }).ProtectionStatus
					if ($BitlockerStatus -eq "1")
					{
						Write-Output "On"
					}
					else
					{
						Write-Output "Off"
					}
				}
			} | `
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
