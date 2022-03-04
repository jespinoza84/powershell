$InstallPath = Test-path -Path "$env:ProgramData\bomgar*"

if ($InstallPath){
    Write-host "installed"
}

else {

}