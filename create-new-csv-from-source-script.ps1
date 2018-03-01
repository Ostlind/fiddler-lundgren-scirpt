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
        $ErrorActionPreference = "SilentlyContinue"
        $root = $PSScriptRoot
        $sourceFile = 'S:\powershell-scripts\fiddler-lundgren\orlik45.csv'
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
            $delim = ".", ";", "-", " "
            $localContent = $content[$i] -split '\r\n'
            $header1 = $localContent[0]
            $header2 = $localContent[1]
            $csvFileRows = $localContent | Select-Object -Skip 1 | ConvertFrom-Csv -UseCulture
            Try
            {
                $csvFileRows | ForEach-Object {
                    if ((Get-Member -inputobject $PSItem -name "A_IODV" -Membertype Properties) -and ($PSItem.A_IODV -eq "SIX"))
                    {
                        if (Get-Member -inputobject $PSItem -name "A_IOAD" -Membertype Properties  )
                        {
                            if ([string]::IsNullOrEmpty($PSItem.A_IOAD))
                            {
                                return
                            }

                            $dataType = [string]::Empty
                            $tagName = $PSItem.A_TAG
                            $address = (( $PSItem.A_IOAD) -split ':')[1]

                            if (!$address)
                            {
                                return
                            }

                            $description = $PSItem.A_DESC
                            $dataTypeChar = ($address -split { $_ -eq " " -or $_ -eq "," } )[1].Substring(0, 1)
                            $addressSplit = $address.Split(".,  ")                            # $dataTypeChar = ($address -split {$delim -contains $_} )[1].Substring(0, 1)

                            if ($addressSplit[0].length -eq 1)
                            {
                                $dataTypeChar = $addressSplit[0]
                            }
                            else {

                                $dataTypeChar = $addressSplit[1].Substring(0,1)
                            }

                            switch ($dataTypeChar.ToLower())
                            {
                                'd' { $dataType = "DWord" }
                                'w' { $dataType = "Word"}
                                'x' { $dataType = "Boolean" }
                                'q' { $dataType = "Boolean"}
                                Default {}
                            }

                            $newRow = """$tagName"",""$address"",$dataType,1,R/W,1000,,,,,,,,,,""$description"","

                            Add-Content -Path ".\$newFileName" -Value $newRow

                        }
                    }
                }
            }
            Catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Break
            }
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