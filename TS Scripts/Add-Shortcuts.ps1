$Add = (
  'Excel',
  'Outlook',
  'Word',
  'OneDrive',
  'Acrobat Reader DC'
)

foreach ($App in $Add)
{
  Copy-Item -Path ('{0}\Microsoft\Windows\Start Menu\Programs\{1}.lnk' -f $env:ProgramData, $App) -Destination ('{0}\Desktop' -f $env:PUBLIC) -Force -ErrorAction SilentlyContinue
}

$Remove = (
  'VLC Media Player'
)

foreach ($App in $Remove)
{
  Remove-Item -Path ('{0}\Desktop\{1}' -f $env:PUBLIC,$App) -Force -ErrorAction SilentlyContinue
}