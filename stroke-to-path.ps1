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

	# read the svg xml in
	# there is currently a failure to read the .svg if an xml namespace is defined but not in the xml
	# i.e. - sketch:type="MSShapeGroup"
	[xml]$svgXml = Get-Content $svg
	
	# remove the solid rectables in the back of the icons
	# comment out or remove this if you are having trouble with this
	foreach ($rect in $svgXml.svg.g.rect) {
		if ($rect.height -eq 48 -and $rect.width -eq 48) {
			$rect.ParentNode.RemoveChild($rect)
		}
	}

	$strokeArgs = New-Object System.Collections.Generic.List[String]

	$idCounter = 0
	foreach ($path in $svgXml.svg.g.path) {
		# if the path doesn't have a stroke, ignore it
		if ($path.stroke -ne $null) {

			$path.SetAttribute("id", "strokeToPath" + $idCounter)
			$strokeArgs.Add('--select="strokeToPath' + $idCounter +'"')
			$idCounter++
		}
	}

	foreach ($path in $svgXml.svg.g.polyline) {
		# if the path doesn't have a stroke, ignore it
		if ($path.stroke -ne $null) {

			$path.SetAttribute("id", "strokeToPath" + $idCounter)
			$strokeArgs.Add('--select="strokeToPath' + $idCounter +'"')
			$idCounter++
		}
	}

	# save the modified svg
	$svgXML.Save($svg)

	# if no paths were found as strokes, do not execute on this .svg
	if ($idCounter -gt 0) {

		$cmdArgs = New-Object System.Collections.Generic.List[String]
		$cmdArgs.Add('--file="' + $svg +'"')
		$cmdArgs.Add('--verb="ToolNode"')
		$cmdArgs.AddRange($strokeArgs)
		$cmdArgs.Add('--verb="StrokeToPath"')

		# union the paths together if there are more than one
		# this may be completely unnecessary, will check font output and then decide
		if ($idCounter -gt 1) {
			$cmdArgs.Add('--verb="SelectionUnion"')
		}
		$cmdArgs.Add('--verb="FileSave"')
		$cmdArgs.Add('--verb="FileQuit"')

		$cmdArgList.Add($cmdArgs)
	}
}

ForEach($cmdArg in $cmdArgList) {
	echo "Executing inkscape: "
	echo $cmdArg
	& 'C:\Program Files\Inkscape\inkscape.exe' $cmdArg | Out-Null
}
