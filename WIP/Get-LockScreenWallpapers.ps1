# add param for destination so it can be set - test-path for the user inputted destination and create if it doesn't exist
# Get-WmiObject -query "SELECT * FROM Win32_VideoController" # to get resolution

BEGIN {
  function Get-FileMetaData {
    <#
        .Synopsis
        This function gets file metadata and returns it as a custom PS Object 
        .Description
        This function gets file metadata using the Shell.Application object and
        returns a custom PSObject object that can be sorted, filtered or otherwise
        manipulated.
        .Example
        Get-FileMetaData -folder "e:\music"
        Gets file metadata for all files in the e:\music directory
        .Example
        Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName
        This example uses the Get-ChildItem cmdlet to do a recursive lookup of 
        all directories in the e:\music folder and then it goes through and gets
        all of the file metada for all the files in the directories and in the 
        subdirectories.  
        .Example
        Get-FileMetaData -folder "c:\fso","E:\music\Big Boi"
        Gets file metadata from files in both the c:\fso directory and the
        e:\music\big boi directory.
        .Example
        $meta = Get-FileMetaData -folder "E:\music"
        This example gets file metadata from all files in the root of the
        e:\music directory and stores the returned custom objects in a $meta 
        variable for later processing and manipulation.
        .Parameter Folder
        The folder that is parsed for files 
        .Notes
        NAME:  Get-FileMetaData
        AUTHOR: ed wilson, msft
        LASTEDIT: 01/24/2014 14:08:24
        KEYWORDS: Storage, Files, Metadata
        HSG: HSG-2-5-14
        .Link
        Http://www.ScriptingGuys.com
        #Requires -Version 2.0
    #>
    Param(
      [Parameter(Mandatory = $true)]
      [string[]]$folder
    ) 
    foreach ($sFolder in $folder) { 
      $a = 0 
      $objShell = New-Object -ComObject Shell.Application 
      $objFolder = $objShell.namespace($sFolder) 
   
      foreach ($File in $objFolder.items()) {  
        $FileMetaData = New-Object PSOBJECT 
        for ($a ; $a -le 266; $a++) {  
          if ($objFolder.getDetailsOf($File, $a)) { 
            $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a)) = 
              $($objFolder.getDetailsOf($File, $a)) 
            } 
            $FileMetaData | Add-Member $hash 
            $hash.clear()  
          } #end if 
        } #end for  
        $a = 0 
        $FileMetaData 
        
      } #end foreach $file 
    } #end foreach $sfolder 
  } #end Get-FileMetaData
}

PROCESS {

  $Destination = "$env:USERPROFILE\Pictures\LockScreenWallpapers"
  $Source = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\"
  $NewImages = Get-ChildItem -Path $Source -Recurse

  if (!(Test-Path -Path $Destination -PathType Container)) {
    New-Item -Path $Destination -ItemType Directory -Force | Out-Null
  }
  
  foreach ($Wallpaper in $NewImages) {
    if (!(Test-Path -Path "$Destination\$($Wallpaper.Name).jpg" -PathType Leaf)){
      # File doesn't exist. Copy.
      Copy-Item -Path $Wallpaper.FullName -Destination "$Destination\$Wallpaper.jpg"
    }
    else {
      # File exists. Do not copy. Affects File metadata.
    }
  }
    
  $Resolution = Get-FileMetaData -folder $Destination
  foreach ($CopiedWallpaper in $Resolution) {
    if (!($CopiedWallpaper.Dimensions -eq '1920 x 1080')) {
      Remove-Item -Path $CopiedWallpaper.Path -Force -Confirm:$false
    }
  }
    
  $NewWallpapers = Get-ChildItem -Path $Destination | Where-Object { $_.LastAccessTime -gt (Get-Date).AddSeconds(-10)}
  
  if ($NewWallpapers.Count -ge 1){
    New-BurntToastNotification -Text "Nice!","Lockscreen wallpapers updated.`n$($NewWallpapers.Count) new wallpapers created." -AppLogo "$env:USERPROFILE\Documents\Happy.png"
  }
  else {
    New-BurntToastNotification -Text "Sad!","No new lockscreen wallpapers found." -AppLogo "$env:USERPROFILE\Documents\Sad.png"
  }
}