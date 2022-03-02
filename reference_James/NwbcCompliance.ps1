$ErrorActionPreference = 'SilentlyContinue'

if (Test-Path -Path "${env:ProgramFiles(x86)}\SAP\NWBC65\NWBC.exe")
{
	$ProductVersion = Get-ItemProperty -Path "${env:ProgramFiles(x86)}\SAP\NWBC65\NWBC.exe" | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty ProductVersion
	if ($ProductVersion -like "*PL 13*")
	{
		# PL 13 is installed
		return 0
	}
	else
	{
		# Something other than PL 13 is installed
		return 1
	}
}

else
{
	return 0
}