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

$dataToExport = $dataArray | ?{$_.result -ne 'not reachable'} | %{$_.data}

$kmlHeader = @"
<?xml version="1.0" encoding="UTF-8"?>
	<kml xmlns="http://www.opengis.net/kml/2.2">	
		<Document>
			<name>myStromer Export</name>
			<Style id="st-default">
				<LineStyle>
					<color>ff0000ff</color>
					<colorMode>normal</colorMode>
					<width>3</width>
				</LineStyle>
			</Style>
			<Placemark>
				<styleUrl>#st-default</styleUrl>
				<LineString>
					<altitudeMode>relativeToGround</altitudeMode>
					<coordinates>
"@

$kmlFooter = @"
</coordinates>
				</LineString>
			</Placemark>
		</Document>
	</kml>
"@

$kmlPositionString = ""
foreach ($element in $dataToExport) {
    #altitudeMode relativeToGround -> 2m über Grund
    $kmlPositionString += "$($element.longitude),$($element.latitude),2 "
}

$kmlFileContent = $kmlHeader + $kmlPositionString + $kmlFooter

$kmlFilePath = Join-Path $Global:EXPORT_DIR "bike-$($BikeId)-positions.kml"

$kmlFileContent | Out-File -FilePath $kmlFilePath -Encoding utf8 -Force
