import subprocess
import sys
import glob
import os
import ntpath

# C:\Users\matt\Desktop\test-icons\achievement.svg
INKSCAPE_EXE_PATH = 'C:\\Program Files\\Inkscape\\inkscape.exe'
GIVEN_PATH_ID = 'strokeToPath'
OUTPUT_FOLDER_NAME = 'output'

def main(args):

    if len(args) < 1:
        print('No arguments found');
        return

    cleanUp()
    files_to_process = prepFiles(args[0])
    print(files_to_process)
    processFiles(files_to_process)


def prepFiles(icon_dir):
    files_to_process = []
    for svg_path in glob.glob('%s\\*.svg' % (icon_dir)):
        svg_filename = ntpath.basename(svg_path)
        file_path_out = ntpath.join(os.path.dirname(os.path.realpath(__file__)), OUTPUT_FOLDER_NAME, svg_filename)
        with open(svg_path, 'rt') as svg_file:
            with open(file_path_out, 'wt') as output_file:
                for line in svg_file:
                    i = line.find('path')
                    if i > 0:
                        cut = i + len('path')
                        line = ''.join([line[0:cut], ' id="%s"' % (GIVEN_PATH_ID), line[cut:]])
                    output_file.write(line)
        files_to_process.append(file_path_out)
    return files_to_process

def processFiles(files_to_process):
    for path in files_to_process:
        cmd = [
            INKSCAPE_EXE_PATH,
            '--file="%s"' % (path),
            '--verb="ToolNode"',
            '--select="%s"' % (GIVEN_PATH_ID),
            '--verb="StrokeToPath"',
            '--verb="FileSave"',
            '--verb="FileClose"'
        ]

        subprocess.Popen(cmd)

def cleanUp():
    if not os.path.exists(OUTPUT_FOLDER_NAME):
        os.makedirs(OUTPUT_FOLDER_NAME)
    else:
        for file in glob.glob('%s\\*.svg' % (OUTPUT_FOLDER_NAME)):
            os.remove(file)

if __name__=='__main__':main(sys.argv[1:])
