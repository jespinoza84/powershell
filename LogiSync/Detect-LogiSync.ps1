# Detect LogiSync Install

$LogiSyncExe = "${env:ProgramFiles(x86)}\Logitech\LogiSync\sync-agent\LogiSyncHandler.exe"

if (Test-Path $LogiSyncExe -PathType Leaf) {
    Write-Host 'Installed'
}
else {

}