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
	echo($svg)
	[xml]$svgXml = Get-Content $svg

	foreach ($rect in $svgXml.svg.g.rect) {
		if ($rect.height -eq 48 -and $rect.width -eq 48) {
			echo "Found a rectangle.  Removing it."
			$rect.ParentNode.RemoveChild($rect)
		}
	}

	$idCounter = 0
	foreach ($path in $svgXml.svg.g.path) {
		if ($path.id -eq $null) {
			$path.SetAttribute("id", "")
		}
		$path.id = ("strokeToPath" + $idCounter)
	}

	$svgXML.Save($svg)
}

ForEach($svg in $svgs) {
	& 'C:\Program Files\Inkscape\inkscape.exe' --file="$svg" --verb="ToolNode" --select="strokeToPath0" --verb="StrokeToPath" --verb="FileSave" --verb="FileClose" --Close | Out-Null
}