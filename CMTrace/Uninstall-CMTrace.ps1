# Uninstall CMTrace from $env:windir

if (Test-Path -Path "$env:windir\CMTrace.exe" -PathType Leaf){
    Remove-Item $env:windir\CMTrace.exe -Force
}

else {

}