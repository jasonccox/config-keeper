#!/bin/bash

### CONSTANTS
NAME="config-keeper"
LOG_FILE="log.txt"

### FUNCTIONS

exportFiles() {
	local srcBaseDir="$1"
	local destFile="$2"
	local listFile="$3"
	local tmpDir="ck-tmp"
	local currentDir="$(pwd)"

	mapfile -t lines < "$listFile"
	cd "$srcBaseDir"
	mkdir "$tmpDir"
	for line in "${lines[@]}"; do
		copyFile "$line" "$tmpDir"
	done

	cd $srcBaseDir/$tmpDir
	echo "Compressing files in $srcBaseDir..."
	tar -czvf "$destFile" *
	echo "Config files exported to $destFile"
	rm -rf "$srcBaseDir/$tmpDir"

	cd "$currentDir"
}

copyFile() {
	local path="$1"
	local dest="$2"
	local currentDir="$(pwd)"

	IFS='/' read -r -a files <<< "$path"
	unset 'files[${#files[@]}-1]'

	cd "$dest"
	for f in "${files[@]}"; do
		if [ ! -d "$f" ]; then
			mkdir "$f"
		fi
		cd "$f"
	done

	cp "$currentDir/$path" .
	cd "$currentDir"
}

getFullPath() {
	if [[ "$1" == /* ]]; then
		echo "$1"
	else
		echo $(pwd)/$1
	fi
}

usage() {
        echo -e "$NAME: a tool for exporting and importing users' configuration files\n"
        echo -e "Usage:\n  ./$NAME.sh [command] [file] [options]"
        echo -e "    command - import or export"
        echo -e "    file - .tar.gz file containing exported config files (for import)"
        echo -e "           OR .txt file containing list of config files (for export)"
        echo -e "    options -"
        echo -e "       -b | --base-dir         base directory from which the paths in [file] are relative"
        echo -e "       -h | --help             print this usage screen"
        echo -e "       -o | --out-file         the file into which the export should be placed (export only)"
}


# read in command line args
if [[ "$1" == export ]]; then
        cmd=export
elif [[ "$1" == import ]]; then
        cmd=import
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
        exit
else
        echo "Error: invalid command"
        echo "'./$NAME.sh --help' for help" 
        exit 1
fi
shift

if [[ "$1" == "" ]]; then
        echo "Error: missing file"
        echo "'./$NAME.sh --help' for help" 
        exit 1
else
        file="$1"
fi
shift

baseDir="$(pwd)"
outFile="$(pwd)/my-configs.tar.gz"
while [ "$1" != "" ]; do
    case "$1" in
        -b | --base-dir )	shift
                        	baseDir="$(getFullPath $1)"

                            ;;
        -h | --help )       usage
                        	exit
                            ;;
        -o | --out-file )    shift
                            outFile="$(getFullPath $1)"
							;;
        * )                 usage
                            exit 1
    esac
    shift
done

if [[ "$cmd" == "export" ]]; then
	exportFiles "$baseDir" "$outFile" "$file"
fi
