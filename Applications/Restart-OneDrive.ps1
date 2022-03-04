# Run in User Context

Function Restart-OneDrive {

    # Possible install paths
    $InstallPaths = (
              "$env:APPDATA\Microsoft\OneDrive\",
              "${env:ProgramFiles(x86)}\Microsoft Onedrive\"
              )


    # Check process
    if (!(Get-Process -Name Onedrive))
    {
        foreach ($Path in $InstallPaths){
           if (Test-Path -Path "$Path\OneDrive.exe" -PathType Leaf){           
                Start-Process -FilePath "$Path\OneDrive.exe"
                }
           }
        }
    else
    {
        Write-Host "It's running"
    }
}

Restart-OneDrive