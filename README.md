## inkscape-stroke-to-path.ps1

Powershell script leveraging [inkscape](https://inkscape.org)'s command line interface to modify .svg files of icons from strokes to paths for input into a [font engine workflow](https://github.com/sapegin/grunt-webfont).

For a Linux solution, please take a look at [AutomatedStrokeToPath](https://github.com/kd96/AutomatedStrokeToPath).

### Usage

Make sure that you have [inkscape](https://inkscape.org) installed on your machine.  
Currently the script relies on the installation path:

```
C:\Program Files\Inkscape\
```

Possible future enhancement by making that an argument you can pass.  Until then, simply modify the script if you installation path is different.

Then from Windows Powershell:

```
PS ScriptDirectory> .\inkscape-stroke-to-path.ps1 "<full-path-to-icon-directory>"
```

Modified .svgs will be moved to the \output directory then the script will execute inkscape in sequential order.
