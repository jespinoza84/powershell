<# 

Get all files in a given folder including subfolders and 
display a result that shows the total number of files, 
the total size of all files, the average file size, the computer name, 
and the date when you ran the command.

#>

$Measurement = get-childitem -Path ~\Desktop -Recurse -File | Measure-Object -Property Length -sum -Average
[pscustomobject]@{
    Count = $Measurement.Count
    Average = $Measurement.Average
    Sum = $Measurement.Sum
    Date = Get-Date
    ComputerName = $env:Computername 
}