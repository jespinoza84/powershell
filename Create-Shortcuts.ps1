# Install for Computer

# Copy folder to ProgramFiles(x86)\RemotePackages
Copy-Item -Path ".\RemotePackages" -Destination ${env:ProgramFiles(x86)} -Recurse

$Apps = ("Microsoft Dynamics AX 2012", "MR Report Designer", "MR Report Viewer")

# Create and save shortcut for each
foreach ($App in $Apps){
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\$App.lnk")
    $Shortcut.TargetPath = "${env:ProgramFiles(x86)}\RemotePackages\$App.rdp"
    $Shortcut.IconLocation = "${env:ProgramFiles(x86)}\RemotePackages\$App.ico"
$Shortcut.Save()
}
