# Detect CMTrace in $env:windir

if (Test-Path -Path "$env:windir\CMTrace.exe" -PathType Leaf){
    Write-Host 'Installed'
}

else {

}