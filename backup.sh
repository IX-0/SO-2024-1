#!/bin/bash

#Ensure LOCALE is set to C for compatibility
export LC_ALL=C

#Vars
_checking=false
_help=false
_regex=false
_file=false
_workdir=
_backupdir=

#Helper functions for use of _checking
cpHelper(){
    echo "cp -a $1 $2"
    if ! $_checking 
    then
        cp -a "$1" "$2"
        return $?
    fi
}

mkdirHelper(){
    echo "mkdir $1"
    if ! $_checking 
    then
        mkdir "$1"
        return $?
    fi
}

rmHelper(){
    echo "rm -r $1"
    if ! $_checking
    then
        rm -r "$1"
        return $?
    fi
}

backUp() {

    local workdir="$1"
    local backupdir="$2"



    #Create backupDir if needed
    if [[ ! -d "$backupdir" ]]
    then
        mkdirHelper "$backupdir"
    fi

    for fpath in "$workdir"/*
    do
        fname=$(basename "$fpath")

        if [[ "$fname" == "*" ]]
        then
            break
        fi
        
        if [[ -d "$fpath" ]]
        then

            relPath=${fpath##$_workdir/} 
            grepstr=$(grep -i -E "^($_workdir)?/?$relPath/?$" "$_tfile")
<<debugTools
            echo "workdir_path: $_workdir/"
            echo "relPath: $relPath"
            echo "grepstr: $grepstr"
debugTools
            if $_file
            then
                if [[ "$grepstr" == "$relPath/" ]] || [[ "$grepstr" == "$fpath" ]]
                then
                    echo "$fname ignored"
                    continue
                fi
            fi
            backUp "$fpath" "$backupdir/$fname"
            continue
        fi

        if [[ ! -f "$backupdir/$fname" ]] || [[ "$fpath" -nt "$backupdir/$fname" ]]
        then
            #Check for regex
            if $_regex && [[ ! "$fname" =~ $_regexpr ]]
            then
                continue
            fi

            
            relPath=${fpath##$_workdir/} 
            grepstr=$(grep -i -E "^($_workdir)?/?$relPath$" "$_tfile")
<<debugTools
            echo "workdir_path: $_workdir/"
            echo "relPath: $relPath"
            echo "grepstr: $grepstr"

debugTools
            if $_file
            then
                if [[ "$grepstr" == "$relPath" ]] || [[ "$grepstr" == "$fpath" ]]
                then
                    echo "$fname ignored"
                    continue
                fi
            fi
            cpHelper "$fpath" "$backupdir/$fname"
            
        elif [[ "$fpath" -ot "$backupdir/$fname" ]]
        then
            echo "WARNING"
        fi
    done

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
    _flags="$_flags -$flag $OPTARG"
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
    echo "Bad argument: '$1' is not a directory"
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

backUp "$_workdir" "$_backupdir"
echo BACKUP DONE

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
