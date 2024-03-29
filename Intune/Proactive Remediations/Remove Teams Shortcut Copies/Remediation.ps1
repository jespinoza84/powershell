# Remediation

# User Context
# Removing Teams - Copy (*) shortcut .lnk generated by Onedrive KFM 

# James Espinoza - 3-1-2022

BEGIN {
    function Write-Log {
        [CmdletBinding()]
        param(
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [string]$Message,
    
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [ValidateSet('Information', 'Warning', 'Error')]
            [string]$Severity = 'Information',
    
            [string]$LogPath = "$env:SystemDrive\Temp\Logs",
            [string]$ScriptName = "Remediate-ShortcutCopies",
            [string]$FileName = "$($ScriptName).log"
    
        )
    
        $LogFilePath = Join-Path -Path $LogPath -ChildPath $FileName
        $Timestamp = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
        
        $LogEntry = "$TimeStamp [$Severity] - $Message"
    
        Out-File -InputObject $LogEntry -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
}


PROCESS {
    $ShortcutCopies = Get-ChildItem -Path $env:USERPROFILE -Filter "*.lnk" -Recurse | Where-Object { $_.Name -like "*Teams*- Copy*" }
    Write-Log "Discovered $($ShortcutCopies.Count) shortcut copies."

    foreach ($Shortcut in $ShortcutCopies) {
        Write-Log "Removing $($Shortcut.Name)"
        Remove-Item $Shortcut.FullName
    }
}
