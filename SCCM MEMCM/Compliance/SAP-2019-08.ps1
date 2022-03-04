$BCVersion = (Get-ItemProperty "${env:ProgramFiles(x86)}\SAP\NWBC65\NWBC.exe").VersionInfo.ProductVersion
$GUIVersion = (Get-ItemProperty "${env:ProgramFiles(x86)}\SAP\FrontEnd\SAPgui\SapGui.exe").VersionInfo.FileVersion

if ($BCVersion -eq "6.5 Final Release PL 16" -and $GUIVersion -eq "7500.2.11.8960")
{
	Write-Host "Installed"
}

else
{
}