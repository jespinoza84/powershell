$ErrorActionPreference = 'SilentlyContinue'

if (Test-Path 'HKCU:\SOFTWARE\SAP\SAPGUI Front\SAP Frontend Server\Security')
{
	$DefaultAction = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\SAP\SAPGUI Front\SAP Frontend Server\Security').DefaultAction
	$SecurityLevel = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\SAP\SAPGUI Front\SAP Frontend Server\Security').SecurityLevel
	if ($DefaultAction -eq "1" -or $SecurityLevel -eq "1")
	{
		return 1
	}
	
	else
	{
		return 0
	}
}
else
{
	return 0
}