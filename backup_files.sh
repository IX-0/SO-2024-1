#!/bin/bash     

#Ensures locale is set to C standard
export LC_ALL=C

#Globing now includes "dot files"
shopt -s dotglob

#Vars
_checking=false
_help=false
_workdir=""
_backupdir=""

#Helper functions for use of _checking
function cpHelper(){
    echo "cp -a $(basename $_workdir)${1##$_workdir} $(basename $_backupdir)${2##$_backupdir}"
    if ! $_checking 
    then
        cp -a "$1" "$2"
    fi
}

function mkdirHelper(){
    echo "mkdir $(basename $_backupdir)${1##$_backupdir}"
    if ! $_checking 
    then
        mkdir "$1"
    fi
}

function rmHelper(){
    echo "rm -r ${1##$_backupdir}"
    if ! $_checking
    then
        rm "$1"
    fi
}

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

#Strip flags and flag arguments from argument list
shift $(($OPTIND - 1))

if $_help
then
    echo "Usage: backup_files [-c] workingDir backupDir"
    exit 0
fi

if [[ ! -d "$1" ]]
then
    echo "no such work diretory to backup" 
    exit 1
fi

#Resolve full paths
_workdir=$(realpath "$1")
_backupdir=$(realpath "$2")

#Check if backupDir is a subdirectory of workingDir
if [[  "${_backupdir##$_workdir}" != "$_backupdir" ]]
then
    echo "Error: Backup directory is a sub-directory of working directory"
    exit 1
fi

#Create backupDir if needed
if [[ ! -d "$_backupdir" ]]
then
    mkdirHelper $_backupdir
fi

#Copy/Update
for fpath in "$_workdir"/*
do
    fname=$(basename "$fpath")
    if [[ ! -f "$fpath" ]]
    then
        continue
    fi

    if [[ ! -f "$_backupdir/$fname" ]] || [[ "$fpath" -nt "$_backupdir/$fname" ]]
    then
        cpHelper "$fpath" "$_backupdir/$fname"    
    elif [[ "$fpath" -ot "$_backupdir/$fname" ]]
    then
        echo "WARNING"
    fi
done

#Remove files not in workdir
for fpath in "$_backupdir"/*
do
    fname=$(basename "$fpath")
    if [[ ! -f "$_workdir/$fname" ]]
    then 
        rmHelper "$fpath"
    fi
done 

echo "BACKUP DONE"
exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida