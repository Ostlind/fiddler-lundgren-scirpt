Set-StrictMode -Version 5.1
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
# $csvFile = 'defaultlist.csv'
$mainFile = 'ORLIK lista nya servern.csv'
$prefix = "siemens.s7400."
$A_IODV = "IDS"
$transformedFile = 'done.csv'

$lineSplit = '\r\n\r\n'
$content2 = (Get-Content -Path 'S:\powershell-scripts\fiddler-lundgren\ORLIK lista nya servern.csv' -Raw) -Split $lineSplit
$sectionCount = $content2.Count - 2
for ($i = 1; $i -lt $sectionCount; $i++)
{

    $localContent = $content2[$i] -split '\r\n'
    $header1 = $localContent[0]
    $header2 = $localContent[1]
    $csvFileRows = $localContent | Select-Object -Skip 1 | ConvertFrom-Csv

    $csvFileRows | ForEach-Object {

        if ( (Get-Member -inputobject $PSItem -name "A_IODV" -Membertype Properties) -and ($PSItem.A_IODV -eq "SIX"))
        {
            if (Get-Member -inputobject $PSItem -name "A_IOAD" -Membertype Properties  )
            {
                $PSItem.A_IODV = $A_IODV

                $PSItem.A_IOAD = $prefix + $PSItem.A_TAG
            }
        }
    }

    Add-Content -Path ".\$transformedFile" -Value $header1
    Add-Content -Path ".\$transformedFile" -Value $header2

    # $csvFileRows | ConvertTo-Csv  | Select-Object -Skip 1 | Out-File -Append -FilePath ".\$transformedFile" -Encoding utf8
    $csvFileRows  | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Add-Content -Path ".\$transformedFile" -Encoding UTF8
    Add-Content -Path ".\$transformedFile" -Value  "`n"
    # Export-Csv -Append -Path ".\$transformedFile" -Encoding utf8 -Force

}

