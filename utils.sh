#!/bin/bash

cpHelper(){


    if [[ ! -d "$1" ]]
    then
        echo "no such work diretory to backup" #If workdir doesnt exist, exit immediatly
        exit 1
    elif [[ ! -d "$2" ]]
    then
        echo "mkdir $2"
        if ! $_checking 
        then
            mkdir $2
        fi
    fi
    backupdir=$(realpath "$2")
    workdir=$(realpath "$1")
    for file in $workdir
        do
        if [[ -e "$backupdir/$file" ]]
        then
            if [[ "$file" -nt "$backupdir/$file" ]]
            then
                echo "cp -a $file "$backupdir/$file""
                if ! $_checking
                then
                    cp -a $file "$backupdir/$file"
                fi
            else
                echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
                continue
            fi
        else
            if ! $_checking
            then
                cp -a $file "$backupdir/$file"
            fi
            echo "cp -a $file "$backupdir/$file""
        fi 
    done

}
