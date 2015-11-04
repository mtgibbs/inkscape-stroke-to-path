Param([string] $iconDirPath)
$iconDirPath = $iconDirPath + "\*"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
$outputDirectory = $scriptDirectory + "\nested-g-node-svgs"

New-Item -ItemType Directory -Force -Path $outputDirectory
Remove-Item ($outputDirectory + "\*") -Include *.svg

$svgs = Get-ChildItem $iconDirPath -Filter *.svg

ForEach($svg in $svgs) {
	Try {
		[xml]$svgXml = Get-Content $svg

		if ($g -ne $svgXml.svg.g.g) {
			Write-Host $svg
			Copy-Item $svg -Destination $outputDirectory
		}
	}
	Catch [System.Exception] {
		Write-Host $_.Exception.Message -foregroundcolor "red"
	}
}