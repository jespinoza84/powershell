# Site configuration
$SiteCode = "abc" # Site code 
$ProviderMachineName = "server.site.com" # SMS Provider machine name

# Customizations
$initParams = @{}

# Import the ConfigurationManager.psd1 module 
if ($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams
function Get-SUGBootTime {

    [cmdletbinding()]
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$SUGName
        )

    # Begin Script

    # Get collections from Software Update Group

    $Collections = (Get-CMSoftwareUpdateDeployment -Name $SUGName).TargetCollectionID

    # % collection in SUG, get the Roesource ID of each server in the collection

    foreach ($Collection in $Collections) {
        $ResourceIDs = Get-CMDevice -CollectionID $Collection | select -ExpandProperty ResourceID
    }

    foreach ($Resource in $ResourceIDs){
        $Servers = Get-CMResource -ResourceId $Resource -Fast | select -ExpandProperty ResourceNames
    }

    $output = foreach ($Server in $Servers) {
       
        $CheckBoot = Get-CimInstance -Query "Select * FROM Win32_OperatingSystem" -ComputerName $Server -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty LastBootUpTime
       
                 
        $Table = [PSCustomObject]@{
            Name = $Server
            LastBootUpTime = $CheckBoot
        }
        $Table
    }

    $output | Sort-Object Name | Format-Table -AutoSize
}