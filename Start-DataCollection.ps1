[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [switch]
    $runAsService = $false,

    [Parameter(Mandatory=$false)]
    [Int32]
    $requestInterval = 60 * 5
)

$ErrorActionPreference = 'Stop'

$coreFunctions = Join-Path $PSScriptRoot 'StromerFunctions.ps1'
. $coreFunctions

if(-not (Test-Path $Global:DATA_DIR))
{
    New-Item -Path $Global:DATA_DIR -ItemType Directory | Out-Null
}

do {

    $StartTime = Get-Date

    Write-Host "Start time: $($StartTime)"

    Write-Host "Requesting Bike List..."
    Get-StromerBikelist

    Write-Host "Requesting Bike Overview..."
    Get-StromerBikeOverview

    Write-Host "Requesting Statistics..."
    Get-StromerStatistics

    Write-Host "Requesting Serviceinfo..."
    Get-StromerServiceInfo

    Write-Host "Requesting Position..."
    Get-StromerPosition
    
    Write-Host "Requesting State..."
    Get-StromerState 


    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    $TotalExecutionDuration = $Duration.TotalSeconds

    Write-Host "Requests completet after [$($TotalExecutionDuration)] second(s)"

    if($runAsService)
    {
        $sleepTime = $requestInterval - $TotalExecutionDuration

        if($sleepTime -gt 0)
        {
            Write-Host "Sleeping for [$($sleepTime)] second(s)"
            Start-Sleep -Seconds $sleepTime    
        }
    }

} while ($runAsService)
