# config-keeper

config-keeper is a free and open-source tool for exporting and importing users' configuration files. It allows you to export a list of files from within a base directory and import a tar file's contents into a base directory.

## Installation

Installation is simple: just download `config-keeper.sh` and make it executable (`chmod a+x path/to/config-keeper.sh`).

## Usage

The basic command syntax is `./config-keeper.sh [command] [file] [options]`.
- command: either `export` or `import`, depending on the operation you wish to perform
- file: a .txt file containing a list of files to be exported OR a .tar.gz file containing the files to be imported
- options:
  - `-b [base dir]` or `--base-dir [base-dir]`: specify the base directory from which the paths in `[file]` are relative; by default, the current directory is used
  - `-h` or `--help`: print the usage information
  - `-o [out file]` or `--out-file [out file]`: specify the name of the exported .tar.gz file (export only); by default, it is `my-configs.tar.gz`

### Export

The export operation allows you to specify a list of files or directories from within a base directory to compress in a .tar.gz file. Simply list the files/directories to be exported in a text file (separated by new lines and relative to the base directory).

#### Example

*File Tree Structure*  
- config-keeper.sh
- list-file.txt
- base-dir
  - file1.txt
  - file2.txt
  - dir1/
    - file3.txt
    - file4.txt
  - dir2/
    - file5.txt
    - dir3/
      - file6.txt
  - dir4/
    - file7.txt

*list-file.txt*  
```
file1.txt
dir1
dir2/dir3
```

*Command*  
`./config-keeper.sh export list-file.txt -b base-dir -o exported.tar.gz`

*Contents of exported.tar.gz*  
- file1.txt
- dir1/
  - file3.txt
  - file4.txt
- dir2/
  - dir3/
    - file6.txt

### Import

The import operation allows you to import files from a .tar.gz file into a base directory. Existing files are preserved, but any files with the same name as imported files will be overwritten.

#### Example

*Original File Tree Structure*  
- config-keeper.sh
- exported.tar.gz
- base-dir
  - existing1.txt
  - dir1/
    - existing2.txt
  - dir4/

*Contents of exported.tar.gz*  
- file1.txt
- dir1/
  - file2.txt
  - file3.txt
- dir2/
  - dir3/
    - file4.txt

*Command*  
`./config-keeper.sh import exported.tar.gz -b base-dir`

*Resulting File Tree Structure*  
- config-keeper.sh
- exported.tar.gz
- base-dir
  - file1.txt
  - existing1.txt
  - dir1/
    - existing2.txt
    - file2.txt
    - file3.txt
  - dir2/
    - dir3/
      - file4.txt
  - dir4/
