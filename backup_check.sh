#!/bin/bash

#Ensure LOCALE is set to C for compatibility
export LC_ALL=C

#Vars
_help=false
_workdir=
_backupdir=

compareFiles() {
    #Returns 0 if contents are equal, 1 if not
    #Using md5sum

    sum1=($(md5sum "$1")) #Transformar num array e aceder ao primeiro indice
    sum2=($(md5sum "$2")) # (checksum filename)
    if [[ "${sum1[0]}" == "${sum2[0]}" ]] 
    then
        return 0
    fi
    return 1
}

backupCheck() {
    local workdir="$1"
    local backupdir="$2"

    for fpath in "$workdir"/*
    do
        fname=$(basename "$fpath")

        if [[ "$fname" == "*" ]]
        then
            break
        fi

        if [[ -d "$fpath" ]]
        then
            backupCheck "$fpath" "$backupdir/$fname"
            continue
        fi
        
        compareFiles "$fpath" "$backupdir/$fname"
        if [[ $? -eq 1 ]]
        then
            echo ${fpath##$_workdir} ${backupdir##$_backupdir}/$fname differ 
        fi
    done
}

while getopts ":h" flag
do 
    case $flag in
        h)
            _help=true
            ;;
        *)
            echo "Unsuported flag -$flag: quitting backup_check.sh"
            exit 1
            ;;
    esac
done

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
echo DONE
