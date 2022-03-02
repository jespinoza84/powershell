<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.167
	 Created on:   	9/16/2019 1:37 PM
	 Created by:   	james.espinoza
	 Filename:     	Anti-virus Compliance
	===========================================================================
	.DESCRIPTION
		Determine if an endpoint has Trendmicro or Windows Defender running
#>
$ErrorActionPreference = 'SilentlyContinue'

$OSVersion = [string]([System.Environment]::OSVersion.Version).Major + "." + [string]([System.Environment]::OSVersion.Version).Minor

switch ($OSVersion)
{
	"10.0" {
		$TrendSvc = Get-Service -Name DSASvc
		$DefenderSvc = Get-Service -Name WinDefend
		$ATPSvc = Get-Service -Name Sense
		
		if (($TrendSvc).Status -eq "Running")
		{
			#Trend is running, compliant
			return 0
		}
		
		elseif (($DefenderSvc).Status -eq "Running" -and ($ATPSvc).Status -eq "Running")
		{
			# Defender/ATP is running, compliant
			return 0
		}
		
		else
		{
			#Neither is running, non-compliant
			return 1
		}
	}
	
	{ ($_ -eq "6.3") -or ($_ -eq "6.1") } {
		$TrendSvc = Get-Service -Name DSASvc
		$DefenderSvc = Get-Service -Name WinDefend
				
		if (($TrendSvc).Status -eq "Running" -or ($DefenderSvc).Status -eq "Running")
		{
			#Antivirus is running, compliant
			return 0
		}
		
		else
		{
			#Neither is running, non-compliant
			return 1
		}
	}
}



