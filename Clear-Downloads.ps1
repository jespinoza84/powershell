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
    
            [string]$LogPath = "$env:windir\logs",
            [string]$ScriptName = 'Clear-Downloads',
            [string]$FileName = "$($ScriptName).log"
    
        )
    
        $LogFilePath = Join-Path -Path $LogPath -ChildPath $FileName
        $Timestamp = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
        
        $LogEntry = "$TimeStamp [$Severity] - $Message"
    
        Out-File -InputObject $LogEntry -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
}

PROCESS {
    Write-Log -Message " ---------- START $($ScriptName) at $(Get-Date) ---------- "
    
    # Grab items
    $Downloads = Get-ChildItem -Path "$env:SystemDrive\Users\kioskUser0\Downloads" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddHours(-8)}
    Write-Log -Message "$($Downloads.Count) items will be deleted."

    # Move items to recycle bin temporarily
    foreach ($Download in $Downloads){
        try {
            Remove-Item -Path $Download.FullName -Confirm:$false -Recurse -WhatIf
        }
        catch {
            Write-Log "Failed to remove $($Download.Name)"
        }

        if ($Download.PSIsContainer -eq $true){
            Write-Log -Message "DIRECTORY - $($Download.Name) and contents have been recursively deleted."
        }
        else {
            Write-Log -Message "FILE - $($Download.Name) has been deleted."
        }
    }
}

END {
    Write-Log -Message " ---------- END - Finished $($ScriptName) at $(Get-Date) ---------- "
}
