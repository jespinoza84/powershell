function Write-Log {
    <#
    .SYNOPSIS
        Writes a timestamped, severity-tagged message to a log file and optionally to the console.
    .PARAMETER Message
        The text to log.
    .PARAMETER Severity
        INFO, WARN, or ERROR. Defaults to INFO.
    .PARAMETER LogPath
        Full path to the log file. Defaults to $env:TEMP\<calling-script-name>-<date>.log
    .PARAMETER NoConsole
        Suppress console output; write to file only.
    .EXAMPLE
        Write-Log -Message "Service started" -Severity INFO -LogPath "C:\Logs\app.log"
    .EXAMPLE
        Write-Log -Message "Disk space low" -Severity WARN
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,

        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Severity = 'INFO',

        [string]$LogPath,

        [switch]$NoConsole
    )

    begin {
        if (-not $LogPath) {
            $callerName = if ($MyInvocation.ScriptName) {
                [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName)
            } else {
                'Write-Log'
            }
            $LogPath = Join-Path $env:TEMP "$callerName-$(Get-Date -Format 'yyyy-MM-dd').log"
        }

        $logDir = Split-Path $LogPath -Parent
        if ($logDir -and -not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        # Rotate if log exceeds 5 MB
        if (Test-Path $LogPath) {
            if ((Get-Item $LogPath).Length -gt 5MB) {
                Remove-Item $LogPath -Force
                $rotateMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Log rotated — previous file exceeded 5 MB"
                Add-Content -Path $LogPath -Value $rotateMsg -Encoding UTF8
            }
        }
    }

    process {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $entry     = "[$timestamp] [$Severity] $Message"

        Add-Content -Path $LogPath -Value $entry -Encoding UTF8

        if (-not $NoConsole) {
            switch ($Severity) {
                'ERROR' { Write-Host $entry -ForegroundColor Red    }
                'WARN'  { Write-Host $entry -ForegroundColor Yellow }
                default { Write-Host $entry }
            }
        }
    }
}

Export-ModuleMember -Function Write-Log
