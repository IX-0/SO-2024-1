#!/bin/bash     

#Ensure LOCALE is set to C for compatibility
export LC_ALL=C

#Vars
_checking=false
_help=false

#Argument and flag parsing
while getopts ":ch" flag
do 
    case $flag in
        c) 
            _checking=true ;;
        h) 
            _help=true ;;
        ?)
            echo "Invalid option -$OPTARG: aborting backup"
            exit 1 ;;
    esac
done

#Strip flags and argument flags from argument list
shift $(($OPTIND - 1))

if $_help
then
    echo "Usage: backup_files [-c] workingDir backupDir"
    exit 0
fi

if [[ ! -d $1 ]]
then
    echo "no such work diretory to backup" #If workdir doesnt exist, exit immediatly
    exit 1
fi

#Resolve full paths
workdir=$(realpath "$1")
backupdir=$(realpath "$2")

#Check if backupDir is a subdirectory of workingDir
if [[  "${backupdir##$workdir}" != "$backupdir" ]]
then
    echo "Error: Backup directory is a sub-directory of working directory"
    exit 1
fi

#Create backupDir if needed
if [[ ! -d "$backupdir" ]]
then
    mkdirHelper $backupdir
fi

for file in $workdir
do
    if [[ -e "$backupdir/$file" ]]
    then
        if [[ $file -nt $backupdir/$file ]]
        then
            cpHelper $file "$backupdir/$file"
        else
            echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
            continue
        fi
    else
        cpHelper $file "$backupdir/$file"
    fi 
done

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
