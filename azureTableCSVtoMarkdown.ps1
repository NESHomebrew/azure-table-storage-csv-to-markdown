# 
#    azureTableCSVtoMarkdown.ps1
#    Date: Mar 15, 2022
#    Author: Brad Bateman
#    Description: Converts an exported .csv from Azure Table Storage and
#                 creates a markdown table. Usefull for documenting database
#                 design.
#    Usage: .\azureTableCSVtoMarkdown.ps1 tableName.csv
#    Usage: .\azureTableCSVtoMarkdown.ps1 -o ALL (creates 1 document for all .csv in current directory)
#

param (
    [string]$param = "",
    [string]$o = ""
)

function createMD {
    param(
        [string]$param1,
        [string]$fileName
    )

    $name = $fileName
    $tableName = (Get-Item $param1 ).Basename 
    if (!($fileName)) {
        $name = $tableName    
    }
    $directory = (Get-Item $PSCommandPath ).DirectoryName 
    $path = $directory + '\' + $param1
    $contents = (Get-Content $param1)
    $properties = $contents[0] -split ","
    $types = $properties | Where-Object { $_ -match "@type" } | Select-Object

    $path = $directory + '\' + $param1
    $outputlocation = $directory + '\' + $name + '.md'

    $csv = Import-CSV $path


    $pk = $csv[0] | Select-Object -property "PartitionKey"
    $rk = $csv[0] | Select-Object -property "RowKey"
    $pkDescription = ""
    $rkDescription = ""

    $h = $csv[0].psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value } -end { $h }

    foreach ($a in $h.Keys) {
        if ( ($h.$a -eq $pk.PartitionKey) -and ($a -ne "PartitionKey")) {
            $pkDescription = "PK is **$a**"
        }
        if (($h.$a -eq $rk.RowKey) -and ($a -ne "RowKey")) {
            $rkDescription = "RK is **$a**"
        }
    }

    $objTypes = @{} 
    Foreach ($type in $types) { 
        $val = "" 
        $csv |  Select-Object $type -Unique | ForEach-Object { if ($_.$type -eq "") { $val += "***null*** " } else { $val += "**" + $_.$type + "** " } }
        $objTypes += @{$type = $val }
    }

    if (!($fileName)) {
        Out-File -FilePath $outputlocation -Append -NoClobber -InputObject ""
    }
    Out-File -FilePath $outputlocation -Append -NoClobber -InputObject "## $tableName"
    Out-File -FilePath $outputlocation -Append -NoClobber -InputObject "| Property Name | Type | Description |"
    Out-File -FilePath $outputlocation -Append -NoClobber -InputObject "|---------------|------|-------------|"

    $length = $properties.Length

    for ($i = 0; $i -lt $length; $i++) {
        $obj = $properties[$i] 
        if ( ($i -lt $length - 1) -and !($obj -match "@type")) {
            if ($properties[$i + 1] -match "@type") {
                $content = "|" + $properties[$i] + "|" + $objTypes.($properties[$i + 1]) + "|"
            }
            else {
                $content = "|" + $properties[$i] + "|"
                if ($i -eq 0) { $content += "**String**" }
                if ($i -eq 1) { $content += "**String**" }
                if ($i -eq 2) { $content += "**DateTime**" }
                $content += "|"
                if ($i -eq 0) { $content += $pkDescription }
                if ($i -eq 1) { $content += $rkDescription }
                if ($i -eq 2) { $content += "Automatically generated" }
            }
            Out-File -FilePath $outputlocation -Append -NoClobber -InputObject $content
        }
    }
}

if (($param -and $o) -or ($o -and ($o -ne "ALL" )))
{ Write-Host "`nUsage: .\azureTableCSVtoMarkdown.ps1 -o ALL" -back Red; Exit 1 }
if (!($param) -and !($o) ) {
    Write-Host "`n -o   Options:  ALL" -back Red; 
    Write-Host ".\azureTableCSVtoMarkdown.ps1 someFile.csv" -back Red;
    Exit 1
}

if (!($o)) {
    if (!$param) 
    { Write-Host "`nUsage: .\azureTableCSVtoMarkdown.ps1 someTable.csv" -back Red; Exit 1 }
    if (!($param -match '([a-zA-Z0-9\s_\\.\-\(\):])+(.csv)')) 
    { Write-Host "`n$param does not appear to be a valid .csv file" -back Red; Exit 1 }
    if (!(test-path $param))
    { Write-Host "`n$param does not appear to exist in this directory" -back Red; Exit 1 }

    createMD($param)
    Exit 0 
}


$myPath = (Get-Item $PSCommandPath ).DirectoryName + "\*.csv"
$files = @(Get-ChildItem -Path $myPath)

foreach ($file in $files) {
    createMD $file.Name allTables
}
