cls

# Specify Paths
$UpdatesSource = "C:\Users\james.espinoza\Desktop\Office2016"
$ExtractFolder = "C:\Users\james.espinoza\Desktop\Office2016Extract"

# Start Extract
$UpdateFiles = Get-ChildItem -Path $UpdatesSource -Recurse -Filter *.cab | select Name, Directory

foreach ($Update in $UpdateFiles)
{
	Write-Host "Expanding $($Update.Name) from:`n`t $($Update.Directory)"
	
	$null = expand.exe -R -F:* "$($Update.Directory)\$($Update.Name)" $ExtractFolder
	
	$Update.Name = ($Update.Name).Substring(0, $Update.Name.Length - 4)
	$MSPName = $Update.Name + ".msp"
	$NewName = ($Update.Name) + (Get-Random) + ".msp"
	
	# Rename Avoids Duplicates
	Rename-Item -Path "$ExtractFolder\$MSPName" -NewName $NewName
}

# Remove XML Metadata
Remove-Item -Path "$ExtractFolder\*.xml"
