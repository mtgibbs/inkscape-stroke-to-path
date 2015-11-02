Param([string] $iconDirPath)
$iconDirPath = $iconDirPath + "\*"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
$outputDirectory = $scriptDirectory + "\output"

New-Item -ItemType Directory -Force -Path $outputDirectory
Remove-Item ($outputDirectory + "\*") -Include *.svg
Copy-Item -Path $iconDirPath -Filter *.svg -Destination $outputDirectory

$svgs = Get-ChildItem ($outputDirectory + "\*") -Filter *.svg

ForEach($svg in $svgs) {
	(Get-Content $svg).replace('<path ', '<path id="strokeToPath" ') | Set-Content $svg | Out-Null
}

ForEach($svg in $svgs) {
	& 'C:\Program Files\Inkscape\inkscape.exe' --file="$svg" --verb="ToolNode" --select="strokeToPath" --verb="StrokeToPath" --verb="FileSave" --verb="FileClose"
}