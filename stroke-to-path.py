import subprocess
import sys
import glob
import os
import ntpath
import stat
import time

# C:\Users\matt\Desktop\test-icons\achievement.svg
INKSCAPE_EXE_PATH = 'C:\\Program Files\\Inkscape\\inkscape.exe'
GIVEN_PATH_ID = 'strokeToPath'

def main(args):

    if len(args) < 2:
        print('No arguments found');
        return

    cleanUp(args[1])
    files_to_process = prepFiles(args[0], args[1])

    print(files_to_process)
    time.sleep(10)
    processFiles(files_to_process)


def prepFiles(icon_dir, output_dir):
    files_to_process = []
    for svg_path in glob.glob('%s\\*.svg' % (icon_dir)):
        svg_filename = ntpath.basename(svg_path)
        file_path_out = ntpath.join(output_dir, svg_filename)
        with open(svg_path, 'rt') as svg_file:
            with open(file_path_out, 'wt') as output_file:
                for line in svg_file:
                    i = line.find('path')
                    if i > 0:
                        cut = i + len('path')
                        line = ''.join([line[0:cut], ' id="%s"' % (GIVEN_PATH_ID), line[cut:]])
                    output_file.write(line)
                os.close(output_file.fileno())
        files_to_process.append(file_path_out)
    return files_to_process

def processFiles(files_to_process):
    for path in files_to_process:
        os.chmod(path, stat.S_IWRITE)
        cmd = [
            INKSCAPE_EXE_PATH,
            '--file="%s"' % (path),
            #'--verb="ToolNode"',
            #'--select="%s"' % (GIVEN_PATH_ID),
            #'--verb="StrokeToPath"',
            #'--verb="FileSave"',
            #'--verb="FileClose"'
        ]
        print(' '.join(cmd))
        subprocess.Popen(cmd)

def cleanUp(output_path):
    if os.path.exists(output_path):
        for file in glob.glob('%s\\*.svg' % (output_path)):
            os.remove(file)


if __name__=='__main__':main(sys.argv[1:])
