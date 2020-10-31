# speedtest.exe --help
# for more info

# Look to converting to scheduled task w/ burnt toast notification

$Speedtest = .\speedtest.exe -A --format csv --output-header | ConvertFrom-Csv