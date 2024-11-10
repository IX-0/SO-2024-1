#!/bin/bash

#Ensures locale is set to C standard
export LC_ALL=C

#Globing now includes "dot files"
shopt -s dotglob

#Vars
_checking=false
_help=false
_regex=false
_file=false
_workdir=""
_backupdir=""

#Helper functions for use of _checking
function cpHelper() {
    echo "cp -a $(basename $_workdir)${1##$_workdir} $(basename $_backupdir)${2##$_backupdir}"
    if ! $_checking 
    then
        cp -a "$1" "$2" &>/dev/null
        [[ ! $? -eq 0 ]] && echo "Error copying file $"
    fi
}

function mkdirHelper() {
    echo "mkdir $(basename $_backupdir)${1##$_backupdir}"
    if ! $_checking 
    then
        mkdir "$1" &>/dev/null
    fi
}

function rmHelper() {
    echo "rm -r ${1##$_backupdir}"
    if ! $_checking
    then
        rm -r "$1" &>/dev/null
    fi
}

function fileFiltering() {
    local fpath=$1
    if [[ -d "$fpath" ]]
    then
        return 1
    fi
        
    local relPath=${fpath##$_workdir/} #passar fpath
    local grepstr="$(grep -i -E "^($_workdir)?/?$relPath$" "$_tfile")"
    if [[ "$grepstr" == "$relPath" ]] || [[ "$grepstr" == "$fpath" ]]
    then
        return 0
    fi
    return 1
}


function backUp() {

    local workdir="$1"
    local backupdir="$2"
    #Create backupDir if needed
    if [[ ! -d "$backupdir" ]]
    then
        mkdirHelper "$backupdir"
    fi

    #Copy/Update
    for fpath in "$workdir"/*
    do
        local fname=$(basename "$fpath")

        if [[ "$fname" == "*" ]]
        then
            break
        fi
        
        if [[ -d "$fpath" ]]
        then
            
            $_file && fileFiltering "$fpath"
            if [[ $? -eq 0 ]]
            then
                continue
            fi
            
            backUp "$fpath" "$backupdir/$fname"
            continue
        fi

        if [[ ! -f "$backupdir/$fname" ]] || [[ "$fpath" -nt "$backupdir/$fname" ]]
        then

            $_regex && [[ ! "$fname" =~ $_regexpr ]]
            if [[ $? -eq 0 ]]             
            then
                continue
            fi
            
            $_file && fileFiltering "$fpath"
            if [[ $? -eq 0 ]]
            then
                echo "$fpath ignored"
                continue 
            fi

            cpHelper "$fpath" "$backupdir/$fname"
            
        elif [[ "$fpath" -ot "$backupdir/$fname" ]]
        then
            echo "WARNING"
        fi
    done

    #Remove files not in workdir
    for fpath in "$backupdir"/* 
    do
        fname=$(basename "$fpath")
        if [[ "$fname" == "*" ]]
        then
            break
        fi

        if [[ ! -e "$workdir/$fname" ]]
        then 
            rmHelper "$fpath"
        fi
    done
}

#Argument and flag parsing
while getopts ":chb:r:" flag
do 
    case $flag in
        c) 
            _checking=true;;
        h) 
            _help=true;;
        b)  
            _tfile=$OPTARG
            _file=true;;
        r)
            _regexpr=$OPTARG
            _regex=true;;
        ?)
            echo "Invalid option -$OPTARG: aborting backup"
            exit 1;;
    esac
done

#Strip flags and flag arguments from argument list
shift $(($OPTIND - 1))

if $_help
then
    echo "Usage: [-c] [-b tfile] [-r regexpr] workingDir backupDir"
    exit 0
fi

if $_file
then
    if [[ ! -f $_tfile ]]
    then  
        echo "Bad argument for -b: '$_tfile' is not a file or doesn't exist"
        exit 1
    fi
fi

if $_regex
then
    #Using grep as a pattern validator
    echo "" | grep -P "$_regexpr" &>/dev/null
    if [[ $? -eq 2 ]]
    then
        echo "Bad argument for -r: '$_regexpr' isn't a valid regex expression"
        exit 1
    fi
fi

#Ensure no missing or excess argument
if [[ $# -ne 2 ]]
then
    case "$#" in
        0) echo "Missing workdir argument" ;;
        1) echo "Missing backupdir argument" ;;
        *) echo "Too many arguments" ;;
    esac
    exit 1
fi

#Check for the existence of the workDir
if [[ ! -d "$1" ]]
then
    echo "Bad argument: '$1' is not a directory or doesn't exist"
    exit 1
fi

#Resolve full paths
_workdir=$(realpath "$1")
_backupdir=$(realpath "$2")

#Check if backupDir is a subdirectory of workingDir
if [[  "${backupdir##$workdir}" != "$backupdir" ]]
then
    echo "Error: Backup directory is a sub-directory of working directory"
    exit 1
fi

#Create backupDir if needed
[[ ! -d "$_backupdir" ]] && mkdirHelper "$_backupdir"

backUp "$_workdir" "$_backupdir"
echo BACKUP DONE

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida