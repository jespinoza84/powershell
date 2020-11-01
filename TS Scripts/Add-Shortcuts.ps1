$Apps = (
	"Excel",
	"Outlook",
	"Word",
	"OneDrive",
	"Acrobat Reader DC"
)

foreach ($App in $Apps)
{
	Copy-Item -Path ('{0}\Microsoft\Windows\Start Menu\Programs\{1}.lnk' -f $env:ProgramData, $App) -Destination ('{0}\Desktop' -f $env:PUBLIC) -Force -ErrorAction SilentlyContinue
}
