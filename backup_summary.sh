#!/bin/bash

#Compatibility opts
export LC_ALL=C
shopt -s dotglob

#Vars
_checking=false
_help=false
_regex=false
_file=false
_workdir=""
_backupdir=""

function summaryAdd() {
    # summaryAdd key amount
    #   adds amount to key in summary dic
    key=$1; amount=$2
    summary[$key]=$(( summary[$key] + $amount ))
}

function printSummary() {
    echo -n "-> While backing up $(basename $_workdir)${workdir##$_workdir}:"
    echo -n " ${summary[errors]} errors; ${summary[warnings]} warnings;"
    echo -n " ${summary[num_updated]} updated;"
    echo " ${summary[num_copied]} copied (${summary[size_copied]}B); ${summary[num_removed]} removed (${summary[size_removed]}B)"
}

#Helper functions for use of _checking
function cpHelper() {
    echo "cp -a $(basename $_workdir)${1##$_workdir} $(basename $_backupdir)${2##$_backupdir}"
    
    local size=$(stat -c %s "$1")
    local updated=false
    [[ "$1" -nt  "$2" && -f "$2" ]] && updated=true 

    $_checking || cp -a "$1" "$2"

    if [[ $? -ne 0 ]]
    then
        summaryAdd errors 1
    else
        $updated && summaryAdd num_updated 1 || {
            summaryAdd num_copied 1; 
            summaryAdd size_copied $size;
        }
    fi

    return 0
}

function mkdirHelper() {
    echo "mkdir $(basename $_backupdir)${1##$_backupdir}"
    $_checking || mkdir "$1"
    if [[ $? -ne 0 ]] 
    then
        summaryAdd errors 1   
    fi

    return 0
}

function rmHelper() {
    echo "rm -r ${1##$_backupdir}"
    local size=$(stat -c %s "$1")
    $_checking || rm -r "$1" 
    if [[ $? -ne 0 ]]
    then
        summaryAdd errors 1
    else
        summaryAdd num_removed 1
        summaryAdd size_removed $size
    fi

    return 0
}

function fileFiltering() {
    fpath=$1
    if [[ -d "$fpath" ]]
    then
        return 1
    fi
        
    relPath=${fpath##$_workdir/} #passar fpath
    grepstr="$(grep -i -E "^($_workdir)?/?$relPath$" "$_tfile")"
    if [[ "$grepstr" == "$relPath" ]] || [[ "$grepstr" == "$fpath" ]]
    then

        fname=$(basename "$fpath")    
        return 0
    fi
    return 1
}


function backUp() {

    local workdir="$1"
    local backupdir="$2"

    #summary dic
    local -A summary=(['errors']=0 ['warnings']=0 ['num_updated']=0 ['num_copied']=0 ['num_removed']=0 ['size_removed']=0 ['size_copied']=0)

    #Create backupDir if needed
    [[ ! -d "$backupdir" ]] && mkdirHelper "$backupdir"

    for fpath in "$workdir"/*
    do
        local fname=$(basename "$fpath")
        
        [[ "$fname" == "*" ]] && break
        
        if [[ -d "$fpath" ]]
        then
            backUp "$fpath" "$backupdir/$fname" 
        elif [[ ! -f "$backupdir/$fname" ]] || [[ "$fpath" -nt "$backupdir/$fname" ]]
        then
            
            $_regex && [[ ! "$fname" =~ $_regexpr ]] && continue
            
            $_file && fileFiltering "$fpath" &&  echo "$fpath ignored" && continue
            
            cpHelper "$fpath" "$backupdir/$fname"
            
        elif [[ "$fpath" -ot "$backupdir/$fname" ]]
        then
            summaryAdd warnings 1 
            echo "WARNING: smthing wrong happened"
        fi
    done

    for fpath in "$backupdir"/* 
    do
        fname=$(basename "$fpath")
        
        [[ "$fname" == "*" ]] && break

        [[ ! -e "$workdir/$fname" ]] && rmHelper "$fpath"
    done

    $_checking || printSummary

    return 0
}

#Argument and flag parsing
while getopts ":chb:r:" flag
do 
    case $flag in
        c) 
            _checking=true 
            ;;
        h) 
            _help=true 
            ;;
        b)  
            _tfile=$OPTARG
            _file=true 
            ;;
        r)
            _regexpr=$OPTARG
            _regex=true
            ;;
        ?)
            echo "Invalid option -$OPTARG: aborting backup"
            exit 1 
            ;;
    esac
done

#Strip flags and argument flags from argument list
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
    echo "" | grep -P "$_regexpr" 2>/dev/null
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
        0) echo "Missing workdir argument"
        ;;
        1) echo "Missing backupdir argument"
        ;;
        *) echo "Too many arguments"
        ;;
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
if [[  "${_backupdir##$_workdir}" != "$_backupdir" ]]
then
    echo "Error: Backup directory is a sub-directory of working directory"
    exit 1
fi

backUp "$_workdir" "$_backupdir"
echo BACKUP DONE

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
