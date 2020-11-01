<# 
Test
Download SpeedTest CLI @ https://www.speedtest.net/apps/cli
.\speedetest.exe --help

WIP:
- Look to converting to scheduled task w/ burnt toast notification


#>
$url = 'https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip'
Invoke-RestMethod -Uri $url -OutFile .\download.zip
Expand-Archive -Path .\download.zip | Out-Host


# $Speedtest = .\speedtest.exe -A --format csv --output-header | ConvertFrom-Csv
