$Apps = (
	"Excel 2016",
	"Outlook 2016",
	"Word 2016",
	"OneDrive for Business",
	"Acrobat Reader DC"
)

foreach ($App in $Apps)
{
	Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$App.lnk" -Destination "$env:PUBLIC\Desktop" -Force -ErrorAction SilentlyContinue
}
