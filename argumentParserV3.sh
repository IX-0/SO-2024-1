#!/bin/bash

_checking=false
_help=false
_regex=false
_file=false

#Argument and flag parsing
while getopts ":chb:r:" flag
do 
    case $flag in
        c) 
            _checking=true ;;
        h) 
            _help=true ;;
        b)  
            _tfile=$OPTARG
            _file=true ;;
        r)
            _regexpr=$OPTARG
           _regex=true ;;
        ?)
            echo "Invalid option -$OPTARG: aborting backup"
            exit 1 ;;
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
        echo "Bad argument for -b: '$_tfile' is not a file"
        exit 1
    fi
fi

if $_regex
then
    #Using grep as a pattern validator
    echo "" | grep -P "$_regexpr" 2>/dev/null
    if [[ $? -eq 2 ]]
    then
        echo "Bad argument for -r: '$_regexpr' is an invalid regex expression"
        exit 1
    fi
fi

#Check if there are the right number of arguments
if [[ ! $# -eq 2 ]]
then
    if [[ $# -lt 2 ]] 
    then 
        echo "Missing arguments"
    else
        echo "Too many arguments"
    fi
    exit 1
fi

#Check for the existence of the workingDir
if [[ ! -d "$1" ]]
then
    echo "Bad argument: '$1' is not a directory"
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
    mkdir "$backupdir"
fi

echo -e "Tfile: $_tfile\nRegexpr: $_regexpr\nPosicional arguments: $@"

exit 0
