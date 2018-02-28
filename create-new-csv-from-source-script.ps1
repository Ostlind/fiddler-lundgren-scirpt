function Convert-CsvFile
{
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $CsvSourcePath
    )

    begin
    {

        # Set-StrictMode -Version 5.1
        $ErrorActionPreference = "Stop"
        $root = $PSScriptRoot
        $sourceFile = 'S:\powershell-scripts\fiddler-lundgren\ORLIK fullexport old server.csv'
        $newFileHeader = 'Tag Name,Address,Data Type,Respect Data Type,Client Access,Scan Rate,Scaling,Raw Low,Raw High,Scaled Low,Scaled High,Scaled Data Type,Clamp Low,Clamp High,Eng Units,Description,Negate Value'

        $newFileName = 'new-s7300.csv'

        if (Test-Path ".\$newFileName")
        {
            Remove-Item ".\$newFileName" -Force
        }

        New-Item -Path ".\$newFileName" -ItemType File

        $lineSplit = '\r\n\r\n'
        $content = (Get-Content -Path $sourceFile -Raw ) -Split $lineSplit
        $sectionCount = $content.Count - 2

        Add-Content -Path ".\$newFileName" -Value $newFileHeader

        for ($i = 1; $i -le $sectionCount; $i++)
        {

            $localContent = $content[$i] -split '\r\n'
            $header1 = $localContent[0]
            $header2 = $localContent[1]
            $csvFileRows = $localContent | Select-Object -Skip 1 | ConvertFrom-Csv -UseCulture

            $csvFileRows | ForEach-Object {

                if ((Get-Member -inputobject $PSItem -name "A_TAG" -Membertype Properties) -and ($PSItem.A_IODV -eq "SIX"))
                {
                    if (Get-Member -inputobject $PSItem -name "A_IOAD" -Membertype Properties  )
                    {
                        $dataType = [string]::Empty
                        $tagName = $PSItem.A_TAG
                        $address = (( $PSItem.A_IOAD) -split ':')[1]
                        $description = $PSItem.A_DESC
                        $dataTypeChar = (( $($PSItem.A_IOAD) -split ':')[1] -split ',')[1].Substring(0, 1)

                        switch ($dataTypeChar)
                        {
                            'D' { $dataType = "DWord" }
                            'W' { $dataType = "Word"}
                            'X' { $dataType = "Boolean" }
                            Default {}
                        }

                        $newRow = """$tagName"",""$address"",$dataType,1,R/W,1000,,,,,,,,,,""$description"","

                        Add-Content -Path ".\$newFileName" -Value $newRow

                    }
                }
            }

            # $csvFileRows | ConvertTo-Csv  | Select-Object -Skip 1 | Out-File -Append -FilePath ".\$transformedFile" -Encoding utf8
            # $csvFileRows  | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Add-Content -Path ".\$transformedFile"
            # Add-Content -Path ".\$transformedFile" -Value  "`n"
            # Export-Csv -Append -Path ".\$transformedFile" -Encoding utf8 -Force

        }

    }

    process
    {
    }

    end
    {
    }
}


Convert-CsvFile