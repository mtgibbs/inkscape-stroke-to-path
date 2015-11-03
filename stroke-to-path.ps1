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
	
	foreach ($rect in $svgXml.svg.g.rect) {
		if ($rect.height -eq 48 -and $rect.width -eq 48) {
			echo "Found a rectangle.  Removing it."
			$rect.ParentNode.RemoveChild($rect)
		}
	}

	$strokeArgs = New-Object System.Collections.Generic.List[String]

	# get the paths to check
	$paths = $svgXml.svg.g.path, $svgXml.svg.g.polyline

	$idCounter = 0
	foreach ($path in $paths) {
		# if the path doesn't have a stroke, ignore it
		if ($path.stroke -ne $null) {

			# define the path id if it doesn't exist
			if ($path.id -eq $null) {
				$path.SetAttribute("id", "")
			}
			$path.id = ("strokeToPath" + $idCounter)
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
