Param([string] $iconDirPath)
$iconDirPath = $iconDirPath + "\*"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
$outputDirectory = $scriptDirectory + "\output"

New-Item -ItemType Directory -Force -Path $outputDirectory
Remove-Item ($outputDirectory + "\*") -Include *.svg
Copy-Item -Path $iconDirPath -Filter *.svg -Destination $outputDirectory

$svgs = Get-ChildItem ($outputDirectory + "\*") -Filter *.svg

$cmdArgList = New-Object System.Collections.Generic.List[System.Object]

ForEach($svg in $svgs) {
	echo($svg)
	[xml]$svgXml = Get-Content $svg
	
	foreach ($rect in $svgXml.svg.g.rect) {
		if ($rect.height -eq 48 -and $rect.width -eq 48) {
			echo "Found a rectangle.  Removing it."
			$rect.ParentNode.RemoveChild($rect)
		}
	}

	$cmdArgs = New-Object System.Collections.Generic.List[String]
	$cmdArgs.Add('--file="' + $svg +'"')
	$cmdArgs.Add('--verb="ToolNode"')

	$idCounter = 0
	foreach ($path in $svgXml.svg.g.path) {
		if ($path.id -eq $null) {
			$path.SetAttribute("id", "")
		}
		$path.id = ("strokeToPath" + $idCounter)
		$cmdArgs.Add('--select="strokeToPath' + $idCounter +'"')
		$cmdArgs.Add('--verb="StrokeToPath"')
		$idCounter++
	}

	$cmdArgs.Add('--verb="FileSave"')
	$cmdArgs.Add('--verb="FileClose"')

	$svgXML.Save($svg)

	$cmdArgList.Add($cmdArgs)
}

ForEach($cmdArg in $cmdArgList) {
	echo "Executing inkscape: "
	echo $cmdArg
	& 'C:\Program Files\Inkscape\inkscape.exe' $cmdArg | Out-Null
}