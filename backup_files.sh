#!/bin/bash     

workdir=$(realpath "$1")
backupdir=$(realpath "$2")

if [[] ! -d $workdir ]];then
    echo "no such work diretory to backup"; #If workdir doesnt exist, exit immediatly
    exit 1;
fi
for file in $workdir;do
    if [[ -e "$2
        $file" ]];then
        if [[ $file -nt $backupdir/$file ]];then
            cp -a $file "$backupdir/$file";
        else
            echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
            continue; 
        fi
    else
        cp -a $file "$backupdir/$file";
    fi 
done;



