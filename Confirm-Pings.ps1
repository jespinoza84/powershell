$WarningPreference = 'SilentlyContinue'

$List = Get-Content -Path .\list.txt

foreach ($item in $List) {
    if (Test-NetConnection -ComputerName $item | select PingSucceeded -ExpandProperty PingSucceeded -WarningVariable Warnings){
    Write-Host "$item is pinging"
    }

    else {
    Write-Host "$item is NOT pinging"
    }
}