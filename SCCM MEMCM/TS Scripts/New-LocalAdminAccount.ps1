# Function to create local admin account from TS variable

function New-LocalAdminAccount {

  Param(
    [Parameter(Mandatory=$true)]
    [string]$AdminName
  )
  
  $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

  # Task sequence varaible ITAdminPass should be set and obfuscated in TS
  $Password = ConvertTo-SecureString $tsenv.Value("ITAdminPass") -AsPlainText -Force

  New-LocalUser -Name $AdminName -AccountNeverExpires -PasswordNeverExpires -Password $Password
  Add-LocalGroupMember -Group Administrators -Member $AdminName
}

New-LocalAdminAccount -AdminName "AdminName"