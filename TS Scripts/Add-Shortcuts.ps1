# Task sequence powershell script to add shortcuts to public desktop (for all users)

$Add = (
  'Excel',
  'Excel 2016',
  'Outlook',
  'Outlook 2016',
  'Word',
  'Word 2016',
  'OneDrive',
  'Acrobat Reader DC'
)

foreach ($App in $Add)
{
  Copy-Item -Path ('{0}\Microsoft\Windows\Start Menu\Programs\{1}.lnk' -f $env:ProgramData, $App) -Destination ('{0}\Desktop' -f $env:PUBLIC) -Force
}

$Remove = (
  'VLC Media Player'
)

foreach ($App in $Remove)
{
  Remove-Item -Path "$env:PUBLIC\Desktop\$App" -Force
}