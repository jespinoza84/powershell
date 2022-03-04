<#
As of 2019-08:

NWBC v6.5 is on Patch Level 16
SAP GUI is on Patch Level 11

If $true is returned, the proper patch levels are installed
#>

$BCVersion = (Get-ItemProperty "${env:ProgramFiles(x86)}\SAP\NWBC65\NWBC.exe").VersionInfo.ProductVersion
$GUIVersion = (Get-ItemProperty "${env:ProgramFiles(x86)}\SAP\FrontEnd\SAPgui\SapGui.exe").VersionInfo.FileVersion

if ($BCVersion -eq "6.5 Final Release PL 16" -and $GUIVersion -eq "7500.2.11.8960")
{
	Write-Host "Installed"
}

else
{
}
