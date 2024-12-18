#!/bin/bash

#Ensures locale is set to C standard
export LC_ALL=C

#Globing now includes "dot files"
shopt -s dotglob

#Vars
_help=false
_workdir=""
_backupdir=""

function compareFiles() {
    # Returns 0 if contents are equal, 1 if not
    # Using md5sum
    # Output of md5sum: "checksum fname"
    # Transform output into an array and compare first element (checksum)

    sum1=($(md5sum "$1"))
    sum2=($(md5sum "$2"))
    
    if [[ "${sum1[0]}" == "${sum2[0]}" ]]
    then
        return 0  # Files are identical
    else
        return 1  # Files differ
    fi
}

function backupCheck() {
    local workdir="$1"
    local backupdir="$2"

    for fpath in "$workdir"/*
    do
        fname=$(basename "$fpath")

        [[ "$fname" == "*" ]] && break

        [[ -d "$fpath" ]] && backupCheck "$fpath" "$backupdir/$fname" && continue
        
        if [[ ! -f "$backupdir/$fname" ]] 
        then
            echo "${backupdir##$_backupdir}/$fname doesn't exist"
            continue
        fi
    
        compareFiles "$fpath" "$backupdir/$fname"
        if [[ ! $? -eq 0 ]]
        then
            echo "$(basename $_workdir)${fpath##$_workdir} $(basename $_backupdir)${backupdir##$_backupdir}/$fname differ" 
        fi
    done
}

while getopts ":h" flag
do 
    case $flag in   
        h)
            _help=true ;;
        *)
            echo "Unsuported flag -$flag: quitting backup_check.sh"
            exit 1 ;;
    esac
done

#Strip flags and flag arguments from argument list
shift $(($OPTIND - 1))

if $_help
then
    echo "Usage: backup_check.sh workdir backupdir"
    exit 0
fi 

if [[ $# -ne 2 ]]
then
    echo "Wrong number of arguments"
    exit 1
fi

if [[ ! -d "$1" ]]
then
      echo "Bad argument: $1 is not a directory"
      exit 1
fi

if [[ ! -d "$2" ]]
then
      echo "Bad argument: $2 is not a directory"
      exit 1
fi

#Resolve full paths
_workdir=$(realpath "$1")
_backupdir=$(realpath "$2")

backupCheck "$_workdir" "$_backupdir"

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
