#!/bin/bash

### CONSTANTS
NAME="config-keeper"

### FUNCTIONS

# Export files specified in the list file
# $1 - the full path of the source base directory
# $2 - the full path to the list file, which contains paths for the files to be exported, relative to the base directory and each on a new line
# $3 - the full path of the .tar.gz file to be created
exportFiles() {
	local srcBaseDir="$1"
	local listFile="$2"
	local destFile="$3"
	local tmpDir="ck-tmp"
	local currentDir="$(pwd)"

	mapfile -t lines < "$listFile"
	cd "$srcBaseDir"
	mkdir "$tmpDir"
	for line in "${lines[@]}"; do
		if [[ "$line" != \#* ]] && [[ "$line" != "" ]]; then
			copyFile "$line" "$tmpDir"
		fi
	done

	cd $srcBaseDir/$tmpDir
	echo "Compressing files in $srcBaseDir..."
	tar -czvf "$destFile" *
	echo "Config files exported to $destFile"
	rm -rf "$srcBaseDir/$tmpDir"

	cd "$currentDir"
}

# Import files from a .tar.gz file
# $1 - the full path of the destination base directory
# $2 - the full path of the .tar.gz file to be imported
importFiles() {
	local destBaseDir="$1"
	local archive="$2"
	local tmpDir="ck-tmp"
	local currentDir="$(pwd)"

	cd "$destBaseDir"
	tar -xzvf "$archive"
	cd "$currentDir"
}

# Copy a file from the current base directory to another base directory, preserving the file's path relative to the base directory
# $1 - the path of the file to be copied, relative to the current directory
# $2 - the full path of the base destination directory
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

	options=""
	if [ -d "$currentDir/$path" ]; then
		options="-r"
	fi

	cp $options "$currentDir/$path" .
	cd "$currentDir"
}

# Get the full path for a file
# $1 - the path to the file (either full or relative to the current directory)
getFullPath() {
	if [[ "$1" == /* ]]; then
		echo "$1"
	else
		echo "$(pwd)/$1"
	fi
}

usage() {
        echo -e "$NAME: a tool for exporting and importing users' configuration files\n"
        echo -e "Usage: ./$NAME.sh [command] [file] [options]"
        echo -e "    command - import or export"
        echo -e "    file - .tar.gz file containing exported config files (for import)"
        echo -e "           OR .txt file containing list of config files (for export)"
        echo -e "    options -"
        echo -e "       -b | --base-dir         base directory from which the paths in [file] are relative"
        echo -e "       -h | --help             print this usage screen"
        echo -e "       -o | --out-file         the file into which the export should be placed (export only)"
}

### MAIN

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
        file="$(getFullPath $1)"
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
	exportFiles "$baseDir" "$file" "$outFile"
elif [[ "$cmd" == "import" ]]; then
	importFiles "$baseDir" "$file" 
fi
