if (Test-Path -Path "${env:ProgramFiles(x86)}\Dell\CommandUpdate") {
    & ${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe /import /policy .\DCUpolicy.xml
    New-Item -Path "${env:ProgramFiles(x86)}\Dell\CommandUpdate" -Name "Compliant.txt" -ItemType File
} else {
    exit
}