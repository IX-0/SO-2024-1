#!/bin/bash

#Ensure LOCALE is set to C for compatibility
export LC_ALL=C

#Global vars
_c=1 #False by default
_args=""

#Flag and argument parsing v2
while (( $# ))
do
    case "$1" in
    -c|--checking)
        _c=0
        shift
    ;;
    -h|--help)
        echo "Usage: $0 [-c] workdir backupdir"
        exit 0
    ;;
    -*|--*=)
        echo "Unsuported flag $1"
        exit 1
    ;;
    *)
        _args="$_args $1"
        shift
    ;;
    esac
done

#Set posicional arguments
eval set $_args > /dev/null #Trash output

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

#Traverse the fs
for fname in $1*
do
    fbasename=$(basename $fname)
    if [[ -d $fname ]]
    then
        echo DIR: $fname
        bash "$0" "$1$fbasename" "$2$fbasename"
        echo DIREND
    elif [[ -f $fname ]]
    then
        echo FILE: "$fname"
    fi
done

exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
