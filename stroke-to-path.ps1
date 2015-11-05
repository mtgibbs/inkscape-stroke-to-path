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
	Write-Host $svg

	# read the svg xml in
	# there is currently a failure to read the .svg if an xml namespace is defined but not in the xml
	# i.e. - sketch:type="MSShapeGroup"
	Try {
		[xml]$svgXml = [xml]([System.IO.File]::ReadAllText($svg))

		# resize the canvas to center on
		foreach ($svgNode in $svgXml.svg) {
			$svgNode.SetAttribute("viewBox", "0 0 30 30")
			$svgNode.SetAttribute("enable-background", "new 0 0 30 30")
		}

		# Search for nested <g> elements and take their children and move them to the parent <g> element
		foreach ($g in $svgXml.svg.g.g) {
			$parentNode = $g.ParentNode
			if ($g.HasChildNodes) {
				# TODO: Figure out how to suppress the console output of this call
				$nodes = $g.SelectNodes("*")
				foreach ($child in $nodes) {
					[void] $parentNode.AppendChild($child)
				}
				$parentNode.RemoveChild($g)
			}
		}

		# remove the solid rectables in the back of the icons
		# comment out or remove this if you are having trouble with this
		foreach ($rect in $svgXml.svg.g.rect) {
			if ($rect.height -eq 48 -and $rect.width -eq 48) {
				[void] $rect.ParentNode.RemoveChild($rect)
			}
		}

		$strokeToPathTargets = New-Object System.Collections.Generic.List[String]
		$allNodes = New-Object System.Collections.Generic.List[String]

		$idCounter = 0
		foreach ($node in $svgXml.svg.g.SelectNodes("*") ) {
			$nodeId = "strokeToPath" + $idCounter
			$node.SetAttribute("id", $nodeId)
			if ($node.stroke -ne $null) {
				$strokeToPathTargets.Add($nodeId)
			}
			$allNodes.Add($nodeId)
			$idCounter++
		}

		Write-Host $strokeToPathTargets
		Write-Host $unionTargets

		# save the modified svg
		$svgXML.Save($svg)

		$cmdArgs = New-Object System.Collections.Generic.List[String]
		$cmdArgs.Add('--file="' + $svg +'"')

		if ($strokeToPathTargets.Count -gt 0) {
			$cmdArgs.Add('--verb="ToolNode"')
			foreach ($tar in $strokeToPathTargets) {
				$cmdArgs.Add('--select="' + $tar + '"')
			}
			$cmdArgs.Add('--verb="StrokeToPath"')
		}

		if ($allNodes.Count -gt 0) {
			$cmdArgs.Add('--verb="EditDeselect"')
			foreach ($tar in $allNodes) {
				$cmdArgs.Add('--select="' + $tar + '"')
			}

			$cmdArgs.Add('--verb="AlignVerticalHorizontalCenter"')
			$cmdArgs.Add('--verb="SelectionUnion"')
		}
		
		$cmdArgs.Add('--verb="FileSave"')
		$cmdArgs.Add('--verb="FileQuit"')

		$cmdArgList.Add($cmdArgs)
	}
	Catch [System.Exception] {
		Write-Host $_.Exception.Message -foregroundcolor "red"
	}
	
}

ForEach($cmdArg in $cmdArgList) {
	$inkscapeExePath = "C:\Program Files\Inkscape\inkscape.exe"
	Write-Host "&" $inkscapeExePath $cmdArg -foregroundcolor "yellow"
	& $inkscapeExePath $cmdArg | Out-Null
}
