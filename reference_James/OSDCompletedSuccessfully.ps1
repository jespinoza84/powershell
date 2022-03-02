$uri = ''
# Date and Time
$DateTime = Get-Date -Format g #Time
# Time
$Time = get-date -format HH:mm
# Computer Make
$Make = (Get-WmiObject -Class Win32_BIOS).Manufacturer
# Computer Model
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
# Computer Name
$Name = (Get-WmiObject -Class Win32_ComputerSystem).Name
# Computer Serial Number
[string]$SerialNumber = (Get-WmiObject win32_bios).SerialNumber
# IP Address of the Computer
$IPAddress = (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{ $_.ipaddress -notlike $null }).IPaddress | Select-Object -First 1
# Uses TS Env doesnt give much on x64 arch
#$TSenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
#$TSlogPath = $TSenv.Value("_SMSTSLogPath")
# these values would be retrieved from or set by an application
$body = ConvertTo-Json -Depth 4 @{
	title = "$Name Completed Successfully"
	text  = " "
	sections = @(
		@{
			activityTitle    = 'Task Sequence'
			activitySubtitle = 'BIOS Upgrade Test - DO NOT USE'
			#activityText   = ' '
			activityImage    = 'http://www.newdesignfile.com/postpic/2012/06/system-center-configuration-manager-2012-icon-png_230438.png' # this value would be a path to a nice image you would like to display in notifications
		},
		@{
			title = '<h2 style=color:blue;>Deployment Details'
			facts = @(
				@{
					name  = 'Name'
					value = $Name
				},
				@{
					name  = 'Finished'
					value = "$DateTime"
				},
				@{
					name  = 'IP Addresss'
					value = $IPAddress
				},
				@{
					name  = 'Make'
					value = $Make
				},
				@{
					name  = 'Model'
					value = $Model
				},
				@{
					name  = 'Serial'
					value = $SerialNumber
				}
			)
		}
	)
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'