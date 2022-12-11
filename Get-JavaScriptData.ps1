[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [Int32]
    $BikeId
)

. ./StromerFunctions.ps1

$dataDir = Join-Path $PSScriptRoot 'stromer-data'

$filesToProcess = Get-ChildItem $dataDir -Filter "bike-$($BikeId)-position-*"

$dataArray = @()

foreach ($jsonFile in $filesToProcess) {
    $jsonContent = Get-Content $jsonFile.FullName -Encoding utf8 | ConvertFrom-Json
    $dataArray += $jsonContent
}

# $dataArray

$dataArray | ?{$_.result -ne 'not reachable'} | %{[PSCustomObject]@{
    x = "$(Get-Date -UnixTime ($_.data.timets))"
    y = $_.data.speed
}} | ConvertTo-Json