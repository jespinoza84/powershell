# For problematic clients in SMS_MP_Control_Manager

function Find-CMClientByGUID {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$true)]
    [string]$GUID,
    [Parameter(Mandatory=$true)]
    [string]$PrimaryServer
    )
    
    $params = @{Namespace=”ROOT\SMS\site_NOR“
    Class=”SMS_R_System”
    ComputerName=$PrimaryServer
    Recurse = $true}

    Get-WmiObject @params | Where-Object {$_.SMSUniqueIdentifier -match $GUID.TrimStart("GUID:")}
}