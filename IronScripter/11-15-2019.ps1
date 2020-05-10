<#
  IronScripter Challenge, November 15, 2019
  https://ironscripter.us/a-beginner-powershell-function-challenge/
#>

function ConvertFrom-FahrenheitToCelsius
{
  [cmdletbinding()]
  param (
    [Parameter(Mandatory,ValueFromPipeline)]
    [int]$Fahrenheit
  )
  
  Write-Host "Converting $fahrenheit Fahrenheit to Celsius"
  $Conversion = ($Fahrenheit - 32) / 1.8
  $RoundedResult = [math]::Round($Conversion,2)
  Write-Host "$Fahrenheit Fahrenheit is $RoundedResult Celsius"
}

function ConvertFrom-CelsiusToFahrenheit
{
  [cmdletbinding()]
  param (
    [Parameter(Mandatory,ValueFromPipeline)]
    [int]$Celsius
  )
  
  Write-Host "Converting $Celsius Celsius to Fahrenheit"
  $Conversion = ($Celsius * 1.8) + 32 
  $RoundedResult = [math]::Round($Conversion,2)
  Write-Host "$Celsius Celsius is $Conversion Fahrenheit"
}